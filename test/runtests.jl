using Cobsr
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
    @test t == crdecode(crencode(t))
    @test t == crdecode(crencode(t, marker = 3), marker = 3)
    @test t == cdecode(cencode(t, marker = 0xfe), marker = 0xfe)
    t2 = cencode(t, marker = 3)
    if length(t2) > 15
        t2[3:10] .= 0x00 # introduce error
        setCOBSerrormode(:WARN)
        @test_warn "error" length(t2) > 15 && t != cdecode(t2, marker = 0)
        setCOBSerrormode(:THROW)
        @test_throws "error" t != cdecode(t2, marker = 0)
        setCOBSerrormode(:IGNORE)
        @test_nowarn t != cdecode(t2, marker = 0)
    end
    @test t == crdecode(crencode(t))
    @test t == crdecode(crencode(t, marker = 3), marker = 3)
    @test t == crdecode(crencode(t, marker = 0xfe), marker = 0xfe)
    @test t != crdecode(crencode(t, marker = 3), marker = 0)
end

