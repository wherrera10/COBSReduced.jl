using COBSReduced
using Test

const COBS = COBSReduced

const TEST_ARRAYS = [
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

@testset "with_various_inputs           " begin    
    for t in TEST_ARRAYS
        setCOBSerrormode(:THROW)
        @test t == crdecode(crencode(t))
        @test t == crdecode(crencode(t, marker = 3), marker = 3)
        @test t == cdecode(cencode(t, marker = 0xfe), marker = 0xfe)
        if length(t) > 14
            for m in 0:254
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
            for m in 1:254 # marker type change
                @test t != cdecode(cencode(t, marker = m), marker = 0) 
                @test t != crdecode(crencode(t, marker = m), marker = 0) 
            end
        end
        setCOBSerrormode(:WARN)
        if !isempty(setdiff(cencode(t), crencode(t)))
            @test_warn "past" t != cdecode(crencode(t))
        end
    end

end

@testset "COBS marker validation         " begin
    for marker in (0, 254)
        input = UInt8[1, 0, 2, 254]
        @test COBS.cobs_decode(COBS.cobs_encode(input; marker); marker) == input
        @test COBS.cobs_decode(
            COBS.cobs_encode(input; reduced = true, marker); reduced = true, marker,
        ) == input
    end

    @test_throws ArgumentError COBS.cobs_decode(UInt8[])

    for marker in (-1, 255, 1.5, :invalid)
        @test_throws ArgumentError COBS.cobs_encode(UInt8[1]; marker)
        @test_throws ArgumentError COBS.cobs_decode(UInt8[1, 0]; marker)
    end
end

@testset "COBS and COBS/R round trips   " begin
    inputs = [
        UInt8[],
        UInt8[0],
        UInt8[0, 0],
        UInt8[1, 0, 5],
        fill(UInt8(0x7a), 253),
        fill(UInt8(0x7a), 254),
        fill(UInt8(0x7a), 255),
        vcat(fill(UInt8(0x7a), 253), UInt8[0]),
        vcat(fill(UInt8(0x7a), 254), UInt8[0]),
        vcat(fill(UInt8(0x7a), 255), UInt8[0]),
    ]

    for input in inputs, marker in (0, 254)
        standard_packet = COBS.cobs_encode(input; marker)
        @test COBS.cobs_decode(standard_packet; marker) == input

        reduced_packet = COBS.cobs_encode(input; reduced = true, marker)
        @test COBS.cobs_decode(reduced_packet; reduced = true, marker) == input
    end
end

@testset "COBS malformed-packet reporting" begin
    try
        COBS.setCOBSerrormode(:IGNORE)
        @test COBS.cobs_decode(UInt8[2, 1]) == UInt8[1]
        @test COBS.cobs_decode(UInt8[1, 0, 0]) == UInt8[0]
        @test COBS.cobs_decode(UInt8[5, 1, 2, 0]) == UInt8[1, 2, 0]

        COBS.setCOBSerrormode(:WARN)
        @test_logs (:warn, r"packet error: found 1 at end") (:warn, r"packet error: found index") COBS.cobs_decode(UInt8[2, 1])
        @test_logs (:warn, r"packet error: found 0 at 2") COBS.cobs_decode(UInt8[1, 0, 0])
        @test_logs (:warn, r"packet error: found index") COBS.cobs_decode(UInt8[5, 1, 2, 0])

        COBS.setCOBSerrormode(:THROW)
        @test_throws ErrorException COBS.cobs_decode(UInt8[2, 1])
        @test_throws ErrorException COBS.cobs_decode(UInt8[1, 0, 0])
        @test_throws ErrorException COBS.cobs_decode(UInt8[5, 1, 2, 0])
    finally
        COBS.setCOBSerrormode(:IGNORE)
    end
end

