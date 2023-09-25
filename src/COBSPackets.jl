module COBSPackets

export COBSencode, COBSdecode

"""
    COBSencode(data)

Return result of encoding `inputdata` into COBS packet format.
"""
function COBSencode(inputdata, marker = 0x00)
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
    COBSdecode(buffer)

    Return result of decoding `buffer` from COBS encoded format.
"""
function COBSdecode(buffer::AbstractVector, marker = 0x00)
    decoded = UInt8[]
    bdx, len = 1, length(buffer)
    while bdx < len
        code = buffer[bdx]
        bdx += 1
        for i in 1:code-1
            push!(decoded, buffer[bdx])
            bdx += 1
            bdx >= len && break
        end
        code < 0xff && bdx < len && push!(decoded, marker)
    end
    return decoded
end

end # module
