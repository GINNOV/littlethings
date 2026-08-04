
# Devices with non-standard (or rather - non-valid) size

Many existing devices (HDFs) have sizes not rounded to 512-byte blocks (like
2000000 or 5000000). Access to such devices using ADFlib is through 512-byte
blocks and, therefore, limited to:

    floor(size / 512) * 512

meaning that remaining, smaller than 512-byte part after the last full block
cannot be accessed.

Note that in such cases the size calculated from device's geometry:

    cylinders * heads * sectors * sector_size (512)

is different from the size of HDF file.
