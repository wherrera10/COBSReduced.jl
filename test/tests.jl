using COBSR
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
    @test t == COBSdecode(COBSencode(t))
    @test t == COBSdecode(COBSencode(t, 3), 3)
    @test t == COBSdecode(COBSencode(t, 0xfe), 0xfe)
    @test 0 ∉ t || t != COBSdecode(COBSencode(t, 0), 3)
    @test t == COBSRdecode(COBSRencode(t))
    @test t == COBSRdecode(COBSRencode(t, 3), 3)
    @test t == COBSRdecode(COBSRencode(t, 0xfe), 0xfe)
    @test 3 ∉ t || t != COBSRdecode(COBSRencode(t, 0), 3)
end
