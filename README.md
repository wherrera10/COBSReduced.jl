# COBSReduced.jl

## COBS and COBS/Reduced packet encoding in Julia

   Features include that the marker can be a byte other than zero. Defaults to COBS protocol, but if
   the named argument `reduced` is set true will use COBS/R, which often saves a byte in packet overhead.

### Usage:

    using COBSReduced

    # COBS protocol use
    encoded = cobs_encode(bytes)
    decoded = cobs_decode(encoded)

    # COBS/R protocol use
    encoded = cobs_encode(bytes, reduced = true)
    decoded = cobs_decode(encoded, reduced = true)

    # or, using short names, and with marker byte chosen to be 0x05 instead of 0:

    encoded5 = cencode(bytes, marker = 5)
    decoded5 = cdecode(encoded5, marker =5)

    encoded5 = crencode(bytes, marker = 5)
    decoded5 = crdecode(encoded5, marker = 5)

    If the marker byte is other than 0, the packet is encoded with marker 0 but then translated to have a
    different marker by xor of the marker with the packet just before the encoded packet is returned. The 
    decoding process then undoes the xor of packet by xoring again with the nonzero marker before decoding.
    This allows packet transmission with a marker byte other than zero if needed.

#### Decoding packet error handling:

    By default decoding errors are ignored, since having user code send a CRC after each packet is good
    practice. This behavior can be changed using the function `setCOBSerrormode(mode::Symbol)`. This
    function allows setting of a decoding error reporting mode for detectable errors, such as a marker
    within a packet. 
    
    The default setting is `setCOBSerrormode(:IGNORE)`. Calling `setCOBSerrormode(:WARN)` will result
    in subsequent decoding errors be printed as warnings to stderr. `setCOBSerrormode(:THROW)`
    will cause errors to throw an exception which may cause immediate error exit.
