module Cobsr

export cobs_encode, cobs_decode, cencode, cdecode, crencode, crdecode

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
        if byte != marker
            push!(output, byte)
            code += 1
        end
        addlastcode = true
        if byte == marker || code == 255
            code == 255 && (addlastcode = false)
            output[codeindex] = code
            code = 1
            push!(output, 0xff)
            codeindex = length(output)
            byte == marker && (lastindex = codeindex)
        end
    end
    if addlastcode
        output[codeindex] = code
        push!(output, marker)
    else
        output[codeindex] = marker
    end
    # Reduce size output of by 1 char if can
    if reduced && lastindex > 1 && output[end-1] + lastindex > length(output)
        output[lastindex] = output[end-1]
        output[end-1] = marker
        pop!(output)
    end
    return output
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
    decoded = UInt8[]
    bdx, len = 1, length(buffer)
    lpos, lchar = 1, marker
    while bdx < len
        code = buffer[bdx]
        lpos, lchar = bdx, code
        bdx += 1
        for _ = 1:code-1
            push!(decoded, buffer[bdx])
            bdx += 1
            bdx > len && break
        end
        code < 0xff && bdx < len && push!(decoded, marker)
    end
    # Restore from reduced format if present
    reduced && lchar != marker && lchar + lpos > len && (decoded[end] = lchar)
    return decoded
end

""" short name for COBS decoding """
cdecode(data; marker = 0x00) = cobs_decode(data, marker = marker, reduced = false)

""" short name for COBS/R decoding """
crdecode(data; marker = 0x00) = cobs_decode(data, marker = marker, reduced = true)

end # module
