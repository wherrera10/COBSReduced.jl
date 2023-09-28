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
    setCOBSerrormode(:IGNORE)
    @test 0 ∉ t || t != cdecode(cencode(t, marker = 0), marker = 3)
    setCOBSerrormode(:THROW)
    @test t == crdecode(crencode(t))
    @test t == crdecode(crencode(t, marker = 3), marker = 3)
    @test t == crdecode(crencode(t, marker = 0xfe), marker = 0xfe)
    setCOBSerrormode(:IGNORE)
    @test 0 ∉ t || t != crdecode(crencode(t, marker = 0), marker = 3)
    setCOBSerrormode(:THROW)
end
