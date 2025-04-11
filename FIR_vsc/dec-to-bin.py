# Converts MATLAB signed decimal coefficients to signed binary

def int_to_signed_binary(num, bits=24):
    # # Handle the case for negative numbers by converting them to two's complement
    # if num < 0:
    #     # Two's complement conversion for negative numbers
    #     num = (1 << bits) + num  # Add 2^bits to the number
    # # Format the number as a signed binary string
    # return format(num, f'0{bits}b')  # Ensure the binary string is `bits` long
    # Create a bitmask with only the lowest 'bits' bits set to 1
    mask = (1 << bits) - 1
    
    # For negative numbers, compute two's complement
    if num < 0:
        # Add 2^bits to get the two's complement representation
        # Then apply mask to ensure we only keep the lowest 'bits' bits
        num = (num & mask) | (1 << (bits - 1))
    else:
        # For positive numbers, just apply the mask to truncate
        num = num & mask
    
    # Format the number as a binary string with the correct length
    return format(num, f'0{bits}b')


# List of numbers
numbers = [
      -4423229,    -5477479,    -6433989,    -4912322,       68906,     8600745,
      19518378,    30471960,    38468272,    40803520,    36072584,    24894526,
       9993216,    -4490381,   -14306771,   -16595565,   -11024959,      -78739,
      11710054,    19383864,    19472860,    11462626,    -1814072,   -15114062,
     -22787042,   -21110620,   -10021354,     6532240,    21886984,    29232028,
      24496618,     8382019,   -13405744,   -32012080,   -38835612,   -29234184,
      -5034856,    25332598,    49427604,    55412592,    37103360,    -2474328,
     -50583064,   -87883608,   -94412696,   -56557536,    27364732,   145000016,
     272316704,   379928256,   441487680,   441487680,   379928256,   272316704,
     145000016,    27364732,   -56557536,   -94412696,   -87883608,   -50583064,
      -2474328,    37103360,    55412592,    49427604,    25332598,    -5034856,
     -29234184,   -38835612,   -32012080,   -13405744,     8382019,    24496618,
      29232028,    21886984,     6532240,   -10021354,   -21110620,   -22787042,
     -15114062,    -1814072,    11462626,    19472860,    19383864,    11710054,
        -78739,   -11024959,   -16595565,   -14306771,    -4490381,     9993216,
      24894526,    36072584,    40803520,    38468272,    30471960,    19518378,
       8600745,       68906,    -4912322,    -6433989,    -5477479,    -4423229
];

# Open a file to save the signed binary numbers
with open("fir-coeffs-24bit.txt", "w") as file:
    # Convert each number to signed binary and write to the file
    for number in numbers:
        signed_binary = int_to_signed_binary(number)
        ##file.write("32'b"+signed_binary +","+ "\n")
        file.write(signed_binary +"\n")
        