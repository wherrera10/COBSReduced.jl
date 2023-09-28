module COBSR

export COBSRencode, COBSRdecode

"""
    COBSencode(data; reducedformat = true, marker::UInt8 = 0x00, io = nothing)

    Return result of encoding `inputdata` into COBS/R packet format (the default.
    If `reducedformat` is set to false, will translate instead into standard COBS format.
    `marker` defaults to zero but may be any byte from 0 to 254.
    if `io` is not nothing, will also write results to stream `io`.
"""
function COBSencode(inputdata; reduced = false, marker::UInt8 = 0x00, io = nothing)
    writer(io, bytes) = io == nothing ? () : write(io, bytes)
    lastoutputpos = 0
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
            writer(io, output[lastoutputpos+1:end]
            lastoutputpos = length(output)
            push!(output, 0xff)
            codeindex = lastoutputpos + 1
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
    if reducedformat && lastindex > 1 && output[end-1] + lastindex > length(output)
        output[lastindex] = output[end-1]
        output[end-1] = marker
        pop!(output)
    end
        writer(io, output[lastoutputpos+1:end])
    return output
end

"""
    COBSdecode(buffer; reducedformat = true, marker = 0x00, io = nothing)

    Return result of decoding `buffer` from COBS/R encoded format (COBS/R is default).
    If `reducedformat` is set to false, will translate as per standard COBS format.
    If `io` is not `nothing`, read input from stream io until eof() instead of from buffer input.
    The marker must be the same as was used for encode (defaults to zero).
    See also: pythonhosted.org/cobs/cobsr-intro.html
"""
function COBSdecode(buffer::AbstractVector = UInt8[]; reducedformat = true, marker = 0x00, io = nothing)
    decoded = UInt8[]
    bdx, len = 1, (io == nothing ? typemax(Int) : length(buffer))
    readbyte() = io == nothing ? buffer[bdx] : read(io, UInt8)
    code, lpos, lchar = 0x00, 1, marker
    while (code = readbyte()) != 0
        lpos, lchar = bdx, code
        bdx += 1
        for _ = 1:code-1
            push!(decoded, readbyte())
            bdx += 1
            bdx > len || decoded[end] == marker && break
        end
        code < 0xff && bdx < len && push!(decoded, marker)
    end
    # Restore from reduced format if using COBS/R and reduced format present
    reducedformat && lchar != marker && lchar + lpos > len && (decoded[end] = lchar)
    return decoded
end

end # module
