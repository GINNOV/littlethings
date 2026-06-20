/* Filename: CRC.C
 * Author:   Patrick Persson, Teracom Nu
 * Version:  1.0, 940203
 * Compiler: ANSI-C
 * Description: General Encoder/Decoder for CRC-32
 *              used in MPEG-2 systems
 */

#include <stdlib.h>
#include <stdio.h>

typedef unsigned long int UIMSBF;

UIMSBF Calculate_CRC(char *first,char *last)
{
  int bit_count = 0;
  int bit_in_byte = 0;
  unsigned short int data_bit;
  unsigned short int shift_reg[32];
  unsigned short int g[] = { 1,1,1,0,1,1,0,1,1,0,1,1,1,0,0,
			       0,1,0,0,0,0,0,1,1,0,0,1,0,0,0,
			       0,0,1 };
  int i,nr_bits;
  char *data;
  UIMSBF crc;
  
  /* Initialize shift register's to '1' */
  for(i=0; i<32; i++)
    shift_reg[i] = 1;
  
  /* Calculate nr of data bits */
  nr_bits = ((int) (last - first)) * 8;
  data = first;
  
  while (bit_count < nr_bits)
    {
      /* Fetch bit from bitstream */
      data_bit = (short int) (*data  & (0x80 >> bit_in_byte));
      data_bit = data_bit >> (7 - bit_in_byte);
      bit_in_byte++; bit_count++;
      if (bit_in_byte == 8)
	{
	  bit_in_byte = 0;
	  data++;
	}
      
      /* Perform the shift and modula 2 addition */
      data_bit ^= shift_reg[31];
      i = 31;
      while (i != 0)
	{
	  if (g[i])
	    shift_reg[i] = shift_reg[i-1] ^ data_bit;
	  else
	    shift_reg[i] = shift_reg[i-1];
	  i--;
	}
      shift_reg[0] = data_bit;
      
    }
  
  /* make CRC an UIMSBF */
  crc = 0x00000000;
  for (i= 0; i<32; i++)
    crc = (crc << 1) | ((UIMSBF) shift_reg[31-i]);
  
  /* Invert CRC before sending */
  crc = ~crc;
  
  return(crc);
}

int Check_CRC(char *first,char *last)
{
  int bit_count = 0;
  int bit_in_byte = 0;
  unsigned short int data_bit;
  unsigned short int shift_reg[32];
  unsigned short int g[] = { 1,1,1,0,1,1,0,1,1,0,1,1,1,0,0,
			       0,1,0,0,0,0,0,1,1,0,0,1,0,0,0,0,0,1 };
  int i,nr_bits,error;
  char *data;
  
  /* Preset the shift_registers to '1':s */
  for(i=0; i<32; i++)
    shift_reg[i] = 1;
  
  /* Get nr_bits */
  nr_bits = ((int) (last - first))*8;
  data = first;
  
  
  while (bit_count < nr_bits)
    {
      /* Fetch bit from bitstream */
      data_bit = (short int) (*data  & (0x80 >> bit_in_byte));
      data_bit = data_bit >> (7 - bit_in_byte);
      bit_in_byte++; bit_count++;
      if (bit_in_byte == 8)
	{
	  bit_in_byte = 0;
	  data++;
	}
      
      /* Check if we reached the CRC_part, if then invert bits */
      if ( bit_count > (nr_bits - 32) )
     	if (data_bit == 1)
	  data_bit  = 0;
	else
	  data_bit  = 1;
      
      /* Perform the shift and modula 2 addition */
      data_bit ^= shift_reg[31];
      i = 31;
      while (i != 0)
	{
	  if (g[i])
	    shift_reg[i] = shift_reg[i-1] ^ data_bit;
	  else
	    shift_reg[i] = shift_reg[i-1];
	  i--;
	}
      shift_reg[0] = data_bit;
    }
  
  /* OR shift_regs, '0' = no errors and '1' = errors */
  error = 0;
  for (i=0; i<32; i++)
    if (shift_reg[i] != 0)
      error = 1;
  
  return(error);
  
}


void main(void)
{
  char data_bits[100];
  unsigned short int g[100],preset[100];
  int nr_bits,nr_shift_regs;
  char *data_ptr,*crc_ptr;
  int not_ok,i;
  UIMSBF crc;
  
  data_ptr = data_bits;
  
  nr_bits = 16*8;
  data_ptr = &data_bits[0];

  /* PAT: 00 b0 11 00 64 c1 00 00 00 00 e0 22 00 01 e0 44 */
  /* SA-2 bitstream (PAT): CRC in bitstream was 99 e7 4f 4e */
  *data_ptr++ = 0x00;
  *data_ptr++ = 0xb0;
  *data_ptr++ = 0x11;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x64;
  *data_ptr++ = 0xc1;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0xe0;
  *data_ptr++ = 0x22;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x01;
  *data_ptr++ = 0xe0;
  *data_ptr++ = 0x44;
  crc_ptr = data_ptr;
  
  
  crc = Calculate_CRC(data_bits,crc_ptr);
  /* Add crc to last end */
  *data_ptr++ = (char) ( (0xff000000 & crc) >> 24);
  *data_ptr++ = (char) ( (0x00ff0000 & crc) >> 16);
  *data_ptr++ = (char) ( (0x0000ff00 & crc) >> 8);
  *data_ptr++ = (char) ( (0xff0000ff & crc) );
  
  data_ptr = data_bits;
  printf("Data bits (HEX): ");
  for (i=0; i<(nr_bits/8); i++)
    printf("%x ",(*data_ptr++ & 0xff));
  printf("\n");
  printf("CRC calculated to: %lx (Inverted %lx)\n",crc,~crc);
  
  
  
  not_ok = Check_CRC(data_bits,(crc_ptr+4));
  if (not_ok)
    printf("CRC showed parity error !!\n");
  else
    printf("CRC checked OK\n");
  data_ptr = data_bits;
  
  nr_bits = 20*8;
  data_ptr = &data_bits[0];

  /* Teracom_3 bitstream (PAT): CRC in bitstream was 97 c9 04 37 */
  *data_ptr++ = 0x00;
  *data_ptr++ = 0xb0;
  *data_ptr++ = 0x15;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x7b;
  *data_ptr++ = 0xc1;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0xe0;
  *data_ptr++ = 0x37;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x01;
  *data_ptr++ = 0xe0;
  *data_ptr++ = 0x4d;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x02;
  *data_ptr++ = 0xe0;
  *data_ptr++ = 0x4d;
  crc_ptr = data_ptr;
  
  
  crc = Calculate_CRC(data_bits,crc_ptr);
  /* Add crc to last end */
  *data_ptr++ = (char) ( (0xff000000 & crc) >> 24);
  *data_ptr++ = (char) ( (0x00ff0000 & crc) >> 16);
  *data_ptr++ = (char) ( (0x0000ff00 & crc) >> 8);
  *data_ptr++ = (char) ( (0xff0000ff & crc) );
  
  data_ptr = data_bits;
  printf("Data bits (HEX): ");
  for (i=0; i<(nr_bits/8); i++)
    printf("%x ",(*data_ptr++ & 0xff));
  printf("\n");
  printf("CRC calculated to: %lx (Inverted %lx)\n",crc,~crc);
  
  
  
  not_ok = Check_CRC(data_bits,(crc_ptr+4));
  if (not_ok)
    printf("CRC showed parity error !!\n");
  else
    printf("CRC checked OK\n");
  
  
  
  data_ptr = &data_bits[0];
  /* GI's bitstream: PAT (PID 0) */
  /* Their CRC was c7 75 37 e2 (faulty) */
  *data_ptr++ = 0x00;
  *data_ptr++ = 0xb0;
  *data_ptr++ = 0x11;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x31;
  *data_ptr++ = 0xc1;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x01;
  *data_ptr++ = 0xe0;
  *data_ptr++ = 0x32;
  *data_ptr++ = 0x00;
  *data_ptr++ = 0x02;
  *data_ptr++ = 0xe0;
  *data_ptr++ = 0x33;
  crc_ptr = data_ptr;
  
  
  crc = Calculate_CRC(data_bits,crc_ptr);
  /* Add crc to last end */
  *data_ptr++ = (char) ( (0xff000000 & crc) >> 24);
  *data_ptr++ = (char) ( (0x00ff0000 & crc) >> 16);
  *data_ptr++ = (char) ( (0x0000ff00 & crc) >> 8);
  *data_ptr++ = (char) ( (0xff0000ff & crc) );
  
  
  data_ptr = data_bits;
  printf("Data bits (HEX): ");
  for (i=0; i<(nr_bits/8); i++)
    printf("%x ",(*data_ptr++ & 0xff));
  printf("\n");
  printf("CRC calculated to: %lx (Inverted %lx)\n",crc,~crc);
  
  not_ok = Check_CRC(data_bits,(crc_ptr+4));
  if (not_ok)
    printf("CRC showed parity error !!\n");
  else
    printf("CRC checked OK\n");
  
}
