//
//
//
//

#include <stdio.h>
#include <errno.h>
#include "tlcs900d.h"

//
//
//

int decode( struct tlcs900d *dd ) {
  unsigned char *b = dd->buffer + dd->pos;
  unsigned char mem;
  unsigned char zz;
  int n;


  if (n = decode_fixed(dd)) {
    return n;
  } else {
    mem = getmem(b);
    zz = getzz(b);

    if (*b >= 0x80) {
        if (zz == 0x03) {
            //
            // These are definitely instructions that include
            // mem (-x--xxxx) part in the opcode.. or then LADR..
            //
            // Opcodes are marked as: B0+mem
            //

            return decode_B0_mem(dd);
        } else {
            //
            // These are opcodes like: 
            //   E8+r
            //   D8+r
            //   C8+zz+r
            //   85+zz
            //   83+zz
            //   80+zz+mem
            //   80+zz+R
            //

            if (mem >= 0x17 && mem <= 0x1f) {
                return decode_zz_r(dd);
            } else if (mem <= 0x07 && b[1] >= 0x10 && b[1] <= 0x17) {
                return decode_zz_R(dd);
            } else if (mem <= 0x15) {
                return decode_zz_mem(dd);
            }
        }
    } else {
        return decode_xx(dd);
    }
  }
  return 0;
}

//
//
//

int checkrom( struct tlcs900d *dd, int verbose ) {

  // Check for Software Recongnition Code..

  if (strncmp("COPYRIGHT BY SNK CORPORATION",dd->buffer,28) &&
      strncmp(" LICENSED BY SNK CORPORATION",dd->buffer,28) ) {
    if (verbose) { printf("Not a NGP rom. Base address is %Xh\n",dd->base); }
    return 1;
  }

  // It's a NGP rom.. Base offset to 0x200000
  // only if the user has not overridden it..

  if (dd->base == 0) {
     dd->base = 0x200000;
  } else if (dd->base != 0x200000 && verbose) {
    printf("Warning! Base address is %Xh not 200000H\n",dd->base);
  }

  //

  if (verbose) {
    printf("The file is a %s NGP rom\n",
            dd->buffer[1] == 'C' ? "SNK" : "licensed");

     // Startup address
    printf("ROM code startup address is %Xh\n",get32u(dd->buffer+0x1c));

    // Card ID
    printf("The cart ID is %04Xh\n",get16u(dd->buffer+0x20));

    // Version
    printf("The cart version is %04Xh\n",get16u(dd->buffer+0x22));

    // Name
    printf("The cart name is '%12s'\n",dd->buffer+0x24);

  }

  if (dd->buffer[0x23] == 0 || dd->buffer[0x23] == 0x10 ) {
    if (verbose) {
      printf("The cart is %s compatible\n",
              dd->buffer[0x23] ? "Color" : "Monochrome");
    }
  } else {
    printf("Unknown Compatible System Code %02Xh ??\n",dd->buffer[0x23]);
  }

  return 0;
}

//
//
//

int loadrom_and_init( char *file, struct tlcs900d *dd ) {

  if (dd->fh = fopen(file,"r+b")) {
    fseek(dd->fh,0,SEEK_END);
    dd->len = ftell(dd->fh);
    fseek(dd->fh,0,SEEK_SET);

    if (dd->buffer = (uint8_t *)malloc(dd->len + dd->space + 16)) {
      if (fread(dd->buffer,1,dd->len,dd->fh) == dd->len) {
        fclose(dd->fh);
        dd->fh = NULL;

        printf("Loaded %d (%Xh) bytes. Extra space is %d bytes.\n\n",
                dd->len,dd->len,dd->space);

        checkrom(dd,0);

        // add some space that user requested..

        dd->len += dd->space;
        return 0;
      } else {
        printf("Error: fread() failed (errno: %d)\n",errno);
        fclose(dd->fh);
        dd->fh = NULL;
      }
    } else {
      printf("Error: malloc() failed (errno: %d)\n",errno);
    }
  } else {
    printf("Error: fopen(%s) failed (errno: %d)\n",file,errno);
  }
  return 1;
}
