# Cobsr.jl

## COBS and COBS/R packet encoding in Julia

   Features include that the marker can be a byte other than zero. Defaults to COBS protocol, but if
   the named argument `reduced` is set true will use COBS/R, which often saves a byte in packet overhead.

### Usage:

    using Cobsr

    # COBS protocol use
    encoded = cobs_encode(bytes)
    decoded = cobs_decode(encoded)

    # COBS/R protocol use
    encoded = cobs_encode(bytes, reduced = true)
    decoded = COBSRdecode(encoded, reduced = true)

    # or, using short names, and with marker byte chosen to be 0x05 instead of 0:

    encoded5 = cencode(bytes, 5)
    decoded5 = cdecode(encoded5, 5)

    encoded5 = crencode(bytes, 5)
    decoded5 = crdecode(encoded5, 5)
    
