# COBSPackets

## COBS packet encoding

   Features include that the marker can be a byte other than zero.

### Usage:

    using COBSPackets

    encoded = COBSencode(bytes)

    decoded = COBSdecode(encoded)

    # or with marker byte chose to be 0x05:

    encoded5 = COBSencode(bytes, 5)

    decoded5 = COBSdecode(encoded5, 5)

    
