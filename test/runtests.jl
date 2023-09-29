using COBSReduced
using Test

const tests = [
    [0x00],
    [0x00, 0x00],
    [0x00, 0x11, 0x00],
    [0x11, 0x22, 0x00, 0x33],
    [0x11, 0x22, 0x33, 0x44],
    [0x11, 0x00, 0x00, 0x00],
    collect(0x01:0xfe),
    collect(0x00:0xfe),
    collect(0x01:0xff),
    [collect(0x02:0xff); 0x00],
    [collect(0x03:0xff); 0x00; 0x01],
]

for t in tests
    setCOBSerrormode(:THROW)
    @test t == crdecode(crencode(t))
    @test t == crdecode(crencode(t, marker = 3), marker = 3)
    @test t == cdecode(cencode(t, marker = 0xfe), marker = 0xfe)
    if length(t) > 14
        for m in 0:255
            t2 = cencode(t, marker = m)
            t2[3:10] .= m # introduce error
            setCOBSerrormode(:WARN)
            @test_warn "error" length(t2) > 15 && t != cdecode(t2, marker = m)
            setCOBSerrormode(:THROW)
            @test_throws "error" t != cdecode(t2, marker = m)
            setCOBSerrormode(:IGNORE)
            @test_nowarn t != cdecode(t2, marker = m)
        end
    end
    @test t == crdecode(crencode(t))
    @test t == crdecode(crencode(t, marker = 3), marker = 3)
    @test t == crdecode(crencode(t, marker = 0xfe), marker = 0xfe)
    setCOBSerrormode(:IGNORE)
    if length(t) > 10
        for m in 1:255 # marker type change
            @test t != cdecode(cencode(t, marker = m), marker = 0) 
            @test t != crdecode(crencode(t, marker = m), marker = 0) 
        end
    end
    setCOBSerrormode(:WARN)
    if !isempty(setdiff(cencode(t), crencode(t)))
        @test_warn "past" t != cdecode(crencode(t))
    end
end

