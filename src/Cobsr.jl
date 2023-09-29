module Cobsr

export cobs_encode, cobs_decode, cencode, cdecode, crencode, crdecode 
export setCOBSerrormode

const _errormode = [:IGNORE]

""" 
    setCOBSerrormode(mode::Symbol)

   Set decoding error reporting mode.
   Default is :IGNORE. :WARN prints to stderr, :THROW will cause error exit.
"""
setCOBSerrormode(mode::Symbol) = begin _errormode[begin] = mode end

""" reporting for decoding errors (a marker byte in the wrong location) """
function _err(marker, position)
    if _errormode[begin] == :WARN
        @warn("packet error: found $marker at $position")
    elseif _errormode[begin] == :THROW
        error("packet error: found $marker at $position")
    end
end

"""
    cobs_encode(data; reduced = false, marker = 0x00)

    Return result of encoding `inputdata` into COBS or COBS/R packet format.
    If `reduced` is true will use the COBS/R protocol, if false the COBS protocol.
    The `marker` defaults to zero but may be any byte from 0 to 254.
    See also: COBS: www.stuartcheshire.org/papers/COBSforToN.pdf
              COBS/R: pythonhosted.org/cobs/cobsr-intro.html
"""
function cobs_encode(inputdata; reduced = false, marker = 0x00)
    output = [0xff]
    codeindex, lastindex, code = 1, 1, 1
    addlastcode = true
    for byte in inputdata
        if byte != 0x00
            push!(output, byte)
            code += 1
        end
        addlastcode = true
        if byte == 0x00 || code == 255
            code == 255 && (addlastcode = false)
            output[codeindex] = code
            code = 1
            push!(output, 0xff)
            codeindex = length(output)
            byte == 0x00 && (lastindex = codeindex)
        end
    end
    if addlastcode
        output[codeindex] = code
        push!(output, 0x00)
    else
        output[codeindex] = 0x00
    end
    # Reduce size output of by 1 char if can
    if reduced && lastindex > 1 && output[end-1] + lastindex > length(output)
        output[lastindex] = output[end-1]
        output[end-1] = 0x00
        pop!(output)
    end
    return marker == 0x00 ? output : UInt8.(output .⊻ marker)
end

""" short name for COBS encoding """
cencode(data; marker = 0x00) = cobs_encode(data, marker = marker, reduced = false)

""" short name for COBS/R encoding """
crencode(data; marker = 0x00) = cobs_encode(data, marker = marker, reduced = true)

"""
    cobs_decode(buffer; reduced = false, marker = 0x00)

    Return result of decoding `inputdata` from COBS or COBS/R packet format.
    If `reduced` is true will use the COBS/R protocol, if false the COBS protocol.
    The `marker` defaults to zero but may be any byte from 0 to 254.
    See also: COBS: www.stuartcheshire.org/papers/COBSforToN.pdf
              COBS/R: pythonhosted.org/cobs/cobsr-intro.html
"""
function cobs_decode(buffer::AbstractVector; reduced = false, marker = 0x00)
    buffer[end] != marker && _err(buffer[end], "end")
    buf = marker == 0 ? buffer : UInt8.(copy(buffer) .⊻ marker)
    decoded = UInt8[]
    bdx, len = 1, length(buf)
    lpos, lchar = 1, 0
    while bdx < len
        code = buf[bdx]
        code == 0x00 && bdx != 1 && _err(marker, bdx)
        lpos, lchar = bdx, code
        bdx += 1
        for _ = 1:code-1
            byte = buf[bdx]
            byte == 0x00 && bdx < len && _err(marker, bdx)
            push!(decoded, byte)
            bdx += 1
            if bdx > len
                !reduced && _err("index", "\b\b\bpast end of packet")
                break
            end
        end
        code < 0xff && bdx < len && push!(decoded, 0x00)
    end
    # Restore from reduced format if present
    reduced && lchar != 0x00 && lchar + lpos > len && (decoded[end] = lchar)
    return decoded
end

""" short name for COBS decoding """
cdecode(data; marker = 0x00) = cobs_decode(data, marker = marker, reduced = false)

""" short name for COBS/R decoding """
crdecode(data; marker = 0x00) = cobs_decode(data, marker = marker, reduced = true)

end # module
