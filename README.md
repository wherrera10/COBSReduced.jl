# COBSR.jl

## COBS and COBS/R packet encoding in Julia

   Features include that the marker can be a byte other than zero.

### Usage:

    using COBSR

    encoded = COBSencode(bytes)
    decoded = COBSdecode(encoded)

    encoded = COBSRencode(bytes)
    decoded = COBSRdecode(encoded)

    # or with marker byte chosen to be 0x05 instead of 0:

    encoded5 = COBSencode(bytes, 5)
    decoded5 = COBSdecode(encoded5, 5)

    encoded5 = COBSRencode(bytes, 5)
    decoded5 = COBSRdecode(encoded5, 5)
    
