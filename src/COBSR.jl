module COBSR

export COBSencode, COBSdecode, COBSRencode, COBSRdecode

"""
    COBSencode(data; reduced = false, marker::UInt8 = 0x00, io = nothing)

    Return result of encoding `inputdata` into COBS packet format.
    Marker defaults to zero but may be any byte from 0 to 254.
"""
function COBSencode(inputdata; reduced = false, marker::UInt8 = 0x00, io = nothing)
    writer(io, bytes) = io == nothing ? () : write(io, bytes)
    output = [0xff]
    codeindex, code = 1, 1
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
        end
    end
    if addlastcode
        output[codeindex] = code
        push!(output, marker)
    else
        output[codeindex] = marker
    end
    return output
end

"""
    COBSRencode(data, marker = 0x00)

    Return result of encoding `inputdata` into COBS/R packet format.
    Marker defaults to zero but may be any byte from 0 to 254.
    See also: pythonhosted.org/cobs/cobsr-intro.html
"""
function COBSRencode(inputdata, marker = 0x00)
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
    if lastindex > 1 && output[end-1] + lastindex > length(output)
        output[lastindex] = output[end-1]
        output[end-1] = marker
        pop!(output)
    end
    return output
end


"""
    COBSdecode(buffer, marker = 0x00)

    Return result of decoding `buffer` from COBS encoded format.
    The marker must be the same as was used for encode (defaults to zero).
"""
function COBSdecode(buffer::AbstractVector, marker = 0x00)
    decoded = UInt8[]
    bdx, len = 1, length(buffer)
    while bdx < len
        code = buffer[bdx]
        bdx += 1
        for _ = 1:code-1
            push!(decoded, buffer[bdx])
            bdx += 1
            bdx > len && break
        end
        code < 0xff && bdx < len && push!(decoded, marker)
    end
    return decoded
end

"""
    COBSRdecode(buffer, marker = 0x00)

    Return result of decoding `buffer` from COBS/R encoded format.
    The marker must be the same as was used for encode (defaults to zero).
    See also: pythonhosted.org/cobs/cobsr-intro.html
"""
function COBSRdecode(buffer::AbstractVector, marker = 0x00)
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
    lchar != marker && lchar + lpos > len && (decoded[end] = lchar)
    return decoded
end

end # module
