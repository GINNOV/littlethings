// ------------------------------------------------------------------------------
//
// Genboot v1.0 - macOS Version
// Based on Andreas Fredriksson's python scripts
// https://github.com/deplinenoise/trackloader/blob/master/
//
// Copyright 2024 Nameless Algorithm
// See https://namelessalgorithm.com/ for more information.
//
// LICENSE
// You may use this source code for any purpose. If you do so, please attribute
// 'Nameless Algorithm' in your source, or mention us in your game/demo credits.
// Thank you.
//
// VERSION HISTORY
// 2024-04-19 1.0 First working version - seems to produce the same output as
//                Andreas Fredriksson's scripts, and works with WinUAE
// 2025-08-02 1.1 Modified for macOS compilation
//
// ------------------------------------------------------------------------------

#include <cstdio>
#include <cstdint>
#include <cstring>
#include <array>

const int DISKSIZE = 512 * 11 * 2 * 80;
const int DISKSIZE_LONGWORDS = DISKSIZE/4;

uint32_t swap_endian(uint32_t value) {
    return ((value & 0xFF) << 24) | 
           ((value & 0xFF00) << 8) | 
           ((value & 0xFF0000) >> 8) | 
           ((value & 0xFF000000) >> 24);
}

void write_buf(std::array<uint32_t, DISKSIZE_LONGWORDS> &buf, const char *filename)
{
	FILE* file;
	file = fopen(filename, "wb");
	if (file != nullptr)
	{
		printf("Opening '%s' for writing...\n", filename);
		size_t count = fwrite(buf.data(), 4, DISKSIZE_LONGWORDS, file);
		if (count != DISKSIZE_LONGWORDS)
		{
			printf("Error: Wrote %zu bytes, should have been %d!\n", count*4, DISKSIZE);
		}
		else
		{
			printf("Success: Wrote %zu bytes, expected %d.\n", count*4, DISKSIZE);
		}
		fclose(file);
	}
	else
	{
		printf("Couldn't open output file '%s'\n", filename);
	}
}

int read_buf(std::array<uint32_t, DISKSIZE_LONGWORDS>& buf, const char* filename)
{
	int result = -1;
	FILE* file;
	file = fopen(filename, "rb");
	if (file != nullptr)
	{
		size_t count = fread(buf.data(), 4, 256, file);
		printf("Read %zu bytes from '%s'\n", count * 4, filename);
		fclose(file);
		result = static_cast<int>(count);
	}
	else
	{
		printf("Couldn't open file '%s' for reading\n", filename);
	}
	return result;
}

int main(int argc, char **argv)
{
	printf("genboot 1.0 (c) 2024 Nameless Algorithm - macOS version\n");
	
	if (argc != 3)
	{
		printf("\n* Usage: genboot infile.bin outfile.adf\n");
		return -1;
	}
	
	const char* filename_in = argv[1];
	const char* filename_out = argv[2];
	
	std::array<uint32_t, DISKSIZE_LONGWORDS> buf{ 0 };
	
	int count = read_buf(buf, filename_in);
	if (count != -1)
	{
		uint64_t chksum = 0;
		uint32_t chksum32 = static_cast<uint32_t>(-1);
		
		for (int i = 0; i < count; ++i)
		{
			if (i % 8 == 0)
			{
				printf("\n %04x: ", i);
			}
			uint32_t longword = swap_endian(buf[i]);
			printf("%08x ", longword);
			
			// add with carry
			chksum += longword;
			if (chksum > 0xffffffff)
			{
				chksum = (chksum + 1) & 0xffffffff;
			}
		}
		
		chksum32 = static_cast<uint32_t>((~chksum) & 0xffffffff);
		chksum32 = swap_endian(chksum32);
		printf("\n\nChecksum: %08x\n", chksum32);
		
		// Set checksum longword
		buf[1] = chksum32;
		
		write_buf(buf, filename_out);
	}
	
	return 0;
}