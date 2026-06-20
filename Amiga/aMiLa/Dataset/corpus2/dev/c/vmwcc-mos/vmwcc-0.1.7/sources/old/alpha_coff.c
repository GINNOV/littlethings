#include <stdio.h>
#include <stdlib.h> /* exit() */
#include <fcntl.h> /* open() */
#include <unistd.h> /* close() */
#include <sys/stat.h>
#include <time.h>   /* time()*/
#include <string.h>

#define long long long

#include "css.h"
#include "csg.h"

#define NOP operate_instr(0x11,31,31,0x20,31)

#define ADDQ_OP   0x10 
#define ADDQ_FUNC 0x20 

#define SUBQ_OP   0x10
#define SUBQ_FUNC 0x29

#define MULQ_OP   0x13
#define MULQ_FUNC 0x20

#define AND_OP   0x11
#define AND_FUNC 0x00

#define BIS_OP   0x11
#define BIS_FUNC 0x20

#define XOR_OP   0x11
#define XOR_FUNC 0x40

#define BLBC     0x38
#define BLBS     0x3c

#define BSR      0x34
#define BR       0x30

#define LDQ_OP     0x29
#define STQ_OP    0x2d

#define CMPLE_OP   0x10
#define CMPLE_FUNC 0x6d

#define CMPLT_OP   0x10
#define CMPLT_FUNC 0x4d

#define CMPEQ_OP   0x10
#define CMPEQ_FUNC 0x2d

#define RET      0x1A
#define RET_FUNC 0x2

#define LDA      0x08

#define SLL_OP   0x12
#define SLL_FUNC 0x39

#define SRA_OP   0x12 
#define SRA_FUNC 0x3c

#define SRL_OP   0x12
#define SRL_FUNC 0x34

#define PAL      0x00
#define SYSCALL  0x83

#define RESULT  0
#define RESULT2 1
#define SPILL1  2
#define SPILL2  3
#define ARG0   16
#define ARG1   17
#define ARG2   18
#define ERRNO  19
#define LINK   26
#define FP 27
#define HP 28
#define GP 29
#define SP 30
#define ZERO 31

#if 0
#include <byteswap.h>


#define swap16(x) bswap_16(x)
#define swap32(x) bswap_32(x)
#define swap64(x) bswap_64(x)

#define htole16(x)      swap16(x)
#define htole32(x)      swap32(x)
#define htole64(x)      swap64(x)

#define HTOLE16(x)      (x) = htole16(x)
#define HTOLE32(x)      (x) = htole32(x)
#define HTOLE64(x)      (x) = htole64(x)
#endif

#define HTOLE16(x) (x) = (x)
#define HTOLE32(x) (x) = (x)
#define HTOLE64(x) (x) = (x)

int write_to_disk=1;

/* See /usr/src/linux/include/asm-alpha/a.out.h on a Linux box */


struct file_header {
   unsigned short f_magic;  /* 387 */
   unsigned short f_nschs;  /* number of section headers */
   unsigned int f_timedat; /* seconds since 1970 */
   unsigned long f_symptr;  /* offset to symbolic header [0 for us] */
   unsigned int f_nsyms;      /* size of symbolic header [0 for us] */
   unsigned short f_opthdr; /* Size of a.out header [80] */
   unsigned short f_flags;  /* flags [for us 0x007   */
};

struct aout_header {
   unsigned short magic;   /* 0x10b */
   unsigned short vstamp;  /* Version stamp 0x30d */
   unsigned short bldrev;  /* system tool revision number (14) */
   unsigned short padcell; /* 0 */
   signed long tsize;      /* Text segment size in bytes, 16-byte padded */
   signed long dsize;      /* data segment size in bytes, 16-byte padded */
   signed long bsize;      /* bss segment size in bytes, 16 byte padded */
   unsigned long entry;    /* program entry point (pc of first instr)   */
   unsigned long text_start; /* text base addr 0x1 2000 0000 */
   unsigned long data_start; /* data base addr 0x1 4000 0000 */
   unsigned long bss_start;  /* bss base addr  0x1 4000 0000 */
   unsigned int gpmask;      /* gp reg mask (unused) 0xffffffff*/
   unsigned int fpmask;      /* gp reg mask (unused) 0xffffffff*/
   signed long gp_value;     /* initial value of gp            */
};

struct section_header {
   
   char s_name[8]; /* Name */
   unsigned long s_paddr; /*  physical address (same as v_addr)  */
   unsigned long s_vaddr; /*  virtual address (0x12.. or 0x14.. or 0x14+data) */
   signed long s_size;         /* section size mult of 16 bytes */
   unsigned long s_scnptr;     /* File offset to raw data */
   unsigned long s_relptr;     /* relocation (we use 0) */
   unsigned long s_lnnoptr;    /* reserved (we use 0) */
   unsigned short s_nreloc;         /* no relocations (we use 0) */
   unsigned short s_alignment;      /* (1) meaning 16 bit alignment */
   unsigned int s_flags;            /* text=0x20, data=0x40, bss=0x80 */
  
};


int palcode_instr(int opcode,int instr) {
   
   return ((opcode&0x3f)<<26)|(instr&0x07ffffff);
}


int branch_instr(int opcode, int ra,int displacement) {
   
   return ((opcode&0x3f)<<26)|((ra&0x1f)<<21) | ((displacement>>2)&0x1fffff);
}


int memory_instr(int opcode, int ra, int rb, int displacement) {
   return ((opcode&0x3f)<<26)|((ra&0x1f)<<21)|((rb&0x1f)<<16)| 
           (displacement&0xffff);
}


int operate_instr(int opcode, int ra, int rb, int func, int rc) {
    return ((opcode&0x3f)<<26)|((ra&0x1f)<<21)|((rb&0x1f)<<16)| ((func&0x3ff)<<5) | (rc&0x1f);
}

int operate_instr_c(int opcode, int ra, int con, int func, int rc) {
    return ((opcode&0x3f)<<26)|((ra&0x1f)<<21)|
      ((con&0xff)<<13)|(1<<12)| ((func&0x3ff)<<5) | (rc&0x1f);
}

void write_code(int fd, int operation) {

  int buffer;
  buffer=operation;
  if (write_to_disk) write(fd,&buffer,sizeof(int));

}


int write_quad(int fd) {

  int write_cod[]={
    0x23deff30,  // lda     sp, -208(sp)
    0xb41e00c8,  // stq     r0, 200(sp)
    0xb43e00c0,  // stq     r1, 192(sp)
    0xb45e00b8,  // stq     r2, 184(sp)
    0xb47e00b0,  // stq     r3, 176(sp)
    0xb49e00a8,  // stq     r4, 168(sp)
    0xb4be00a0,  // stq     r5, 160(sp)
    0xb4de0098,  // stq     r6, 152(sp)
    0xb4fe0090,  // stq     r7, 144(sp)
    0xb51e0088,  // stq     r8, 136(sp)
    0xb61e0080,  // stq     r16, 128(sp)
    0xb63e0078,  // stq     r17, 120(sp)
    0xb65e0070,  // stq     r18, 112(sp)
    0xb67e0068,  // stq     r19, 104(sp)
    0xb69e0060,  // stq     r20, 96(sp)
    0xb6be0058,  // stq     r21, 88(sp)
    0xb6de0050,  // stq     r22, 80(sp)
    0xb6fe0048,  // stq     r23, 72(sp)
    0xb71e0040,  // stq     r24, 64(sp)
    0xb73e0038,  // stq     r25, 56(sp)
    0xb75e0030,  // stq     r26, 48(sp)
    0xb77e0028,  // stq     r27, 40(sp)
    0xb79e0020,  // stq     r28, 32(sp)
    0xb7be0018,  // stq     gp, 24(sp)
    0x46100412,  // bis     r16, r16, r18
    0x43f00531,  // subq    r31, r16, r17
    0x46110890,  // cmovlt  r16, r17, r16
    0x241f3333,  // ldah    r0, 13107(r31)
    0x20003333,  // lda     r0, 13107(r0)
    0x48041731,  // sll     r0, 0x20, r17
    0x42200400,  // addq    r17, r0, r0
    0x40003440,  // s4addq  r0, 0x1, r0
    0x223e0018,  // lda     r17, 24(sp)
    0x4e000601,  // umulh   r16, r0, r1
    0x48207681,  // srl     r1, 0x3, r1
    0x40210402,  // addq    r1, r1, r2
    0x40220642,  // s8addq  r1, r2, r2
    0x42020530,  // subq    r16, r2, r16
    0x42061410,  // addq    r16, 0x30, r16
    0x42203531,  // subq    r17, 0x1, r17
    0x3a110000,  // stb     r16, 0(r17)
    0x44210410,  // bis     r1, r1, r16
    0xfe1ffff6,  // bgt     r16, -10
    0xfa400003,  // bge     r18, 3
    0x42203531,  // subq    r17, 0x1, r17
    0x221f002d,  // lda     r16, 45(r31)
    0x3a110000,  // stb     r16, 0(r17)
    0x42203531,  // subq    r17, 0x1, r17
    0x221f0020,  // lda     r16, 32(r31)
    0x3a110000,  // stb     r16, 0(r17)
    0x47e09400,  // bis     r31, 0x4, r0
    0x47e03410,  // bis     r31, 0x1, r16
    0x225e0018,  // lda     r18, 24(sp)
    0x42510532,  // subq    r18, r17, r18
    0x00000083,  // call_pal callsys
    0xa41e00c8,  // ldq     r0, 200(sp)
    0xa43e00c0,  // ldq     r1, 192(sp)
    0xa45e00b8,  // ldq     r2, 184(sp)
    0xa47e00b0,  // ldq     r3, 176(sp)
    0xa49e00a8,  // ldq     r4, 168(sp)
    0xa4be00a0,  // ldq     r5, 160(sp)
    0xa4de0098,  // ldq     r6, 152(sp)
    0xa4fe0090,  // ldq     r7, 144(sp)
    0xa51e0088,  // ldq     r8, 136(sp)
    0xa61e0080,  // ldq     r16, 128(sp)
    0xa63e0078,  // ldq     r17, 120(sp)
    0xa65e0070,  // ldq     r18, 112(sp)
    0xa67e0068,  // ldq     r19, 104(sp)
    0xa69e0060,  // ldq     r20, 96(sp)
    0xa6be0058,  // ldq     r21, 88(sp)
    0xa6de0050,  // ldq     r22, 80(sp)
    0xa6fe0048,  // ldq     r23, 72(sp)
    0xa71e0040,  // ldq     r24, 64(sp)
    0xa73e0038,  // ldq     r25, 56(sp)
    0xa75e0030,  // ldq     r26, 48(sp)
    0xa77e0028,  // ldq     r27, 40(sp)
    0xa79e0020,  // ldq     r28, 32(sp)
    0xa7be0018,  // ldq     gp, 24(sp)
    0x23de00d0,  // lda     sp, 208(sp)
    0x6bfa8001  // ret     r31, (r26), 1
  };

  write(fd,&write_cod,sizeof(write_cod));

  return sizeof(write_cod);

}


int read_quad(int fd) {
  int read_code[]={
    0x23deff38,  // lda     sp, -200(sp)
    0xb43e00c0,  // stq     r1, 192(sp)
    0xb45e00b8,  // stq     r2, 184(sp)
    0xb47e00b0,  // stq     r3, 176(sp)
    0xb49e00a8,  // stq     r4, 168(sp)
    0xb4be00a0,  // stq     r5, 160(sp)
    0xb4de0098,  // stq     r6, 152(sp)
    0xb4fe0090,  // stq     r7, 144(sp)
    0xb51e0088,  // stq     r8, 136(sp)
    0xb53e0080,  // stq     r9, 128(sp)
    0xb55e0078,  // stq     r10, 120(sp)
    0xb61e0070,  // stq     r16, 112(sp)
    0xb63e0068,  // stq     r17, 104(sp)
    0xb65e0060,  // stq     r18, 96(sp)
    0xb67e0058,  // stq     r19, 88(sp)
    0xb69e0050,  // stq     r20, 80(sp)
    0xb6be0048,  // stq     r21, 72(sp)
    0xb6de0040,  // stq     r22, 64(sp)
    0xb6fe0038,  // stq     r23, 56(sp)
    0xb71e0030,  // stq     r24, 48(sp)
    0xb73e0028,  // stq     r25, 40(sp)
    0xb75e0020,  // stq     r26, 32(sp)
    0xb77e0018,  // stq     r27, 24(sp)
    0xb79e0010,  // stq     r28, 16(sp)
    0xb7be0008,  // stq     gp, 8(sp)
    0x47e01409,  // bis     r31, 0, r9
    0x47e0140a,  // bis     r31, 0, r10
    0x47e07400,  // bis     r31, 0x3, r0
    0x47e01410,  // bis     r31, 0, r16
    0x47de0411,  // bis     sp, sp, r17
    0x47e03412,  // bis     r31, 0x1, r18
    0x00000083,  // call_pal callsys
    0xec000020,  // ble     r0, 32
    0x2a1e0000,  // ldbu    r16, 0(sp)
    0x42041db1,  // cmple   r16, 0x20, r17
    0xf23ffff7,  // blbs    r17, -9
    0x4205b5b1,  // cmpeq   r16, 0x2d, r17
    0xe2200008,  // blbc    r17, 8
    0x215fffff,  // lda     r10, -1(r31)
    0x47e07400,  // bis     r31, 0x3, r0
    0x47e01410,  // bis     r31, 0, r16
    0x47de0411,  // bis     sp, sp, r17
    0x47e03412,  // bis     r31, 0x1, r18
    0x00000083,  // call_pal callsys
    0xec000014,  // ble     r0, 20
    0x2a1e0000,  // ldbu    r16, 0(sp)
    0x420619b1,  // cmplt   r16, 0x30, r17
    0xf2200011,  // blbs    r17, 17
    0x420759b1,  // cmplt   r16, 0x3a, r17
    0xe220000f,  // blbc    r17, 15
    0x41290411,  // addq    r9, r9, r17
    0x41310649,  // s8addq  r9, r17, r9
    0x42061530,  // subq    r16, 0x30, r16
    0x42090409,  // addq    r16, r9, r9
    0x47e07400,  // bis     r31, 0x3, r0
    0x47e01410,  // bis     r31, 0, r16
    0x47de0411,  // bis     sp, sp, r17
    0x47e03412,  // bis     r31, 0x1, r18
    0x00000083,  // call_pal callsys
    0xec000005,  // ble     r0, 5
    0x2a1e0000,  // ldbu    r16, 0(sp)
    0x420619b1,  // cmplt   r16, 0x30, r17
    0xf2200002,  // blbs    r17, 2
    0x420759b1,  // cmplt   r16, 0x3a, r17
    0xf23ffff1,  // blbs    r17, -15
    0x43e90531,  // subq    r31, r9, r17
    0x45510889,  // cmovlt  r10, r17, r9
    0x45290400,  // bis     r9, r9, r0
    0xa43e00c0,  // ldq     r1, 192(sp)
    0xa45e00b8,  // ldq     r2, 184(sp)
    0xa47e00b0,  // ldq     r3, 176(sp)
    0xa49e00a8,  // ldq     r4, 168(sp)
    0xa4be00a0,  // ldq     r5, 160(sp)
    0xa4de0098,  // ldq     r6, 152(sp)
    0xa4fe0090,  // ldq     r7, 144(sp)
    0xa51e0088,  // ldq     r8, 136(sp)
    0xa53e0080,  // ldq     r9, 128(sp)
    0xa55e0078,  // ldq     r10, 120(sp)
    0xa61e0070,  // ldq     r16, 112(sp)
    0xa63e0068,  // ldq     r17, 104(sp)
    0xa65e0060,  // ldq     r18, 96(sp)
    0xa67e0058,  // ldq     r19, 88(sp)
    0xa69e0050,  // ldq     r20, 80(sp)
    0xa6be0048,  // ldq     r21, 72(sp)
    0xa6de0040,  // ldq     r22, 64(sp)
    0xa6fe0038,  // ldq     r23, 56(sp)
    0xa71e0030,  // ldq     r24, 48(sp)
    0xa73e0028,  // ldq     r25, 40(sp)
    0xa75e0020,  // ldq     r26, 32(sp)
    0xa77e0018,  // ldq     r27, 24(sp)
    0xa79e0010,  // ldq     r28, 16(sp)
    0xa7be0008,  // ldq     gp, 8(sp)
    0x23de00c8,  // lda     sp, 200(sp)
    0x6bfa8001  // ret     r31, (r26), 1

  };
  write(fd,&read_code,sizeof(read_code));

  return sizeof(read_code); 
}

int divmod(int fd) {
 
  int div_mod_code[]={
    0x23deffd0,  // lda     sp, -48(sp)
    0xb61e0028,  // stq     r16, 40(sp)
    0xb63e0020,  // stq     r17, 32(sp)
    0xb65e0018,  // stq     r18, 24(sp)
    0xb67e0010,  // stq     r19, 16(sp)
    0xb69e0008,  // stq     r20, 8(sp)
    0xb6be0000,  // stq     r21, 0(sp)
    0xf6200001,  // bne     r17, 1
    0x00000000,  // call_pal halt
    0x4a07f794,  // sra     r16, 0x3f, r20
    0x43f00520,  // subq    r31, r16, r0
    0x46000890,  // cmovlt  r16, r0, r16
    0x4a27f795,  // sra     r17, 0x3f, r21
    0x43f10521,  // subq    r31, r17, r1
    0x46210891,  // cmovlt  r17, r1, r17
    0x42100400,  // addq    r16, r16, r0
    0x4a07f681,  // srl     r16, 0x3f, r1
    0x47e81413,  // bis     r31, 0x40, r19
    0x42603533,  // subq    r19, 0x1, r19
    0x40310532,  // subq    r1, r17, r18
    0xea400006,  // blt     r18, 6
    0x42520401,  // addq    r18, r18, r1
    0x4807f692,  // srl     r0, 0x3f, r18
    0x44320401,  // bis     r1, r18, r1
    0x40000400,  // addq    r0, r0, r0
    0x44003400,  // bis     r0, 0x1, r0
    0xc3e00004,  // br      r31, 4
    0x40210401,  // addq    r1, r1, r1
    0x4807f692,  // srl     r0, 0x3f, r18
    0x44320401,  // bis     r1, r18, r1
    0x40000400,  // addq    r0, r0, r0
    0xf67ffff2,  // bne     r19, -14
    0x48203681,  // srl     r1, 0x1, r1
    0x46950815,  // xor     r20, r21, r21
    0x43e00532,  // subq    r31, r0, r18
    0x46b204c0,  // cmovne  r21, r18, r0
    0x43e10533,  // subq    r31, r1, r19
    0x46930881,  // cmovlt  r20, r19, r1
    0xa61e0028,  // ldq     r16, 40(sp)
    0xa63e0020,  // ldq     r17, 32(sp)
    0xa65e0018,  // ldq     r18, 24(sp)
    0xa67e0010,  // ldq     r19, 16(sp)
    0xa69e0008,  // ldq     r20, 8(sp)
    0xa6be0000,  // ldq     r21, 0(sp)
    0x23de0030,  // lda     sp, 48(sp)
    0x6bfa8001  // ret     r31, (r26), 1
  };
  write(fd,&div_mod_code,sizeof(div_mod_code));

  return sizeof(div_mod_code); 
}

#define STDOUT 1

int write_line(int fd) {

  printf("Writing line!\n");
  write_code(fd,memory_instr(LDA,30,30,-64));
  write_code(fd,memory_instr(STQ_OP,1,30,0));	        
  write_code(fd,memory_instr(STQ_OP,2,30,8));	        
  write_code(fd,memory_instr(STQ_OP,3,30,16));	        
  write_code(fd,memory_instr(STQ_OP,4,30,24));	        
  write_code(fd,memory_instr(STQ_OP,5,30,32));	        
  write_code(fd,memory_instr(STQ_OP,6,30,40));	        
  write_code(fd,memory_instr(STQ_OP,7,30,48));	        
  write_code(fd,memory_instr(STQ_OP,8,30,56));
   
  write_code(fd,operate_instr_c(BIS_OP,31,4,BIS_FUNC,0));
  write_code(fd,operate_instr_c(BIS_OP,31,STDOUT,BIS_FUNC,16));
  write_code(fd,operate_instr_c(BIS_OP,GP,0,BIS_FUNC,17));
  write_code(fd,operate_instr_c(BIS_OP,31,1,BIS_FUNC,18));
  write_code(fd,palcode_instr(PAL,SYSCALL));
  write_code(fd,memory_instr(LDQ_OP,8,30,56));   
     write_code(fd,memory_instr(LDQ_OP,7,30,48));   
     write_code(fd,memory_instr(LDQ_OP,6,30,40));   
     write_code(fd,memory_instr(LDQ_OP,5,30,32));   
     write_code(fd,memory_instr(LDQ_OP,4,30,24));   
     write_code(fd,memory_instr(LDQ_OP,3,30,16));   
     write_code(fd,memory_instr(LDQ_OP,2,30,8));   
     write_code(fd,memory_instr(LDQ_OP,1,30,0));   
   
  write_code(fd,memory_instr(LDA,30,30,64));	           
  write_code(fd,memory_instr(RET,31,26,(RET_FUNC<<14)+1));  

  return 24*4;
}

int prolog(int fd) {
  return 4;
}


int pad_16_bytes(int fd, int offset) {

  int padding=0;

    /* Pad to 16 byte boundary */
    if (offset%16) {
      while(offset%16) {
        write_code(fd,NOP);
	padding+=4;
        offset+=4;
      }
    }
    return padding;
}

int load_constant(int fd,long val,int reg) {

  if (val<65536) {
    printf("Loading %lli into r%i\n",val,reg);
    write_code(fd,memory_instr(LDA,reg,31,val));
    return 4;
  }
  else {
    CSSError("Constant too large!\n");
  }
  return 0;
}

int branch_bsr(int fd,int reg,int offset) {

  printf("Offset=%i %i\n",offset>>2,(offset>>2)*4);
  write_code(fd,branch_instr(BSR,reg,(offset)));
  return 4;
}

void alpha_coff(Block root,char *name) {

   int fd,text_offset=0,data_offset=0,bss_offset=0;
   int temp_offset;
   int divmod_offset,writeq_offset,readq_offset,writel_offset;
   Block temp_block,master_block=NULL;
   Node temp_node;

   int op=0,func=0;
   
   int header_size=0;

   char linefeed[]="\nVMW";

   struct file_header fh;
   struct aout_header ah;

   struct section_header text,bss,data;

   off_t text_location,aout_location,data_location,bss_location;
   
   if (sizeof(struct file_header)!=24) {
      printf("Error!  Wrong size file header %i\n",
            sizeof(struct file_header));
      exit(1);
   }
   
   if (sizeof(struct aout_header)!=80) {
      printf("Error!  Wrong size of aout header\n");
      exit(1);
   }
   
	
   fd=open(name,O_CREAT|O_WRONLY,S_IRWXU);
   if (fd<0) {
      printf("Error opening file %s!\n",name);
      exit(1);
   }
   
   fh.f_magic=387;
   HTOLE16(fh.f_magic);
   fh.f_nschs=3;
   fh.f_timedat=time(NULL);
   HTOLE32(fh.f_timedat);
   fh.f_symptr=0L;
   fh.f_nsyms=0;
   fh.f_opthdr=80;
   HTOLE16(fh.f_opthdr);
   fh.f_flags=0x007;  /* License to Kill */
   HTOLE16(fh.f_flags);
   



   ah.magic=0x10b;
   HTOLE16(ah.magic);
   ah.vstamp=0x30d;
   HTOLE16(ah.vstamp);
   ah.bldrev=14;
   HTOLE16(ah.bldrev);
   ah.padcell=0;

   ah.tsize=0;
   ah.dsize=0;
   ah.bsize=0;
   ah.entry=0;
   ah.text_start=0x120000000;
   HTOLE64(ah.text_start);
   ah.data_start=0x140000000;
   HTOLE64(ah.data_start);
   ah.bss_start=0x140000000;
   HTOLE64(ah.bss_start);
   ah.gpmask=0xffffffff;
   ah.fpmask=0xffffffff; 
   ah.gp_value=0;
      
   
    write(fd,&fh,sizeof(struct file_header));
    aout_location=lseek(fd,0L,SEEK_CUR);
    write(fd,&ah,sizeof(struct aout_header));

    strncpy(text.s_name,".text",5);
    text.s_name[5]=0;
    text.s_name[6]=0;
    text.s_name[7]=0;
    text.s_paddr=0x120000000;
    text.s_vaddr=0x120000000;
    text.s_size=0;
    text.s_scnptr=0;
    text.s_relptr=0;
    text.s_lnnoptr=0;
    text.s_nreloc=0;
    text.s_alignment=1;
    text.s_flags=0x20;

    text_location=lseek(fd,0L,SEEK_CUR);
    write(fd,&text,sizeof(struct section_header));
    data_location=lseek(fd,0L,SEEK_CUR);
    write(fd,&data,sizeof(struct section_header));
    bss_location=lseek(fd,0L,SEEK_CUR);
    write(fd,&bss,sizeof(struct section_header));

    /* Find offsets for variables we use */
    data_offset=0;
    bss_offset=0;


    /* Load built-in routines */
    /* Really should do this conditionally on if we actually use them */

    writeq_offset=text_offset;
    text_offset+=write_quad(fd);
    text_offset+=pad_16_bytes(fd,text_offset);

    readq_offset=text_offset;
    text_offset+=read_quad(fd);
    text_offset+=pad_16_bytes(fd,text_offset);

    writel_offset=text_offset;
    text_offset+=write_line(fd);
    text_offset+=pad_16_bytes(fd,text_offset);

    divmod_offset=text_offset;
    text_offset+=divmod(fd);
    text_offset+=pad_16_bytes(fd,text_offset);
   
    /* First pass calculate offsets */
    /* Second pass write to disk    */

    write_to_disk=0;
    while(write_to_disk<2) {

      temp_offset=text_offset;

      temp_block=root;
      while(temp_block!=NULL) {

	    /* Beginning of a block */
	 
	    /* Are we the entry point??? */
         if (temp_block->entry) {
	         ah.entry=ah.text_start+sizeof(struct section_header)*3+
	                 sizeof(struct aout_header)+
	                 sizeof(struct file_header)+
	                 temp_offset;
         }
	    /* Store offset for jumps */
         temp_block->offset=temp_offset;      

	 
	    /* Handle function entry point */
         if (temp_block->kind==blockProc) {
	   /* we are main(), setup GP */
	   if (temp_block->entry) {
               temp_offset+=load_constant(fd,0x140,GP);
               write_code(fd,operate_instr_c(SLL_OP,GP,24,SLL_FUNC,GP));
	       temp_offset+=4;

	   }
	   /* we are leaf, backup reg26 */
           write_code(fd,memory_instr(LDA,30,30,-16));
           write_code(fd,memory_instr(STQ_OP,26,30,0));	        
           write_code(fd,memory_instr(STQ_OP,15,30,8));
	   temp_offset+=12; 
	   master_block=temp_block; 
	   if (write_to_disk==0) master_block->framesize=0;
	   
	   write_code(fd,memory_instr(LDA,30,30,-master_block->framesize));
	   write_code(fd,operate_instr(BIS_OP,30,30,BIS_FUNC,
		 		       15));

	   
	   temp_offset+=8;	    
		 

	 }

         temp_node=temp_block->first;
         while(temp_node!=NULL) {
	   if(!temp_node->deleted) {
        switch(temp_node->op) {


	 case vmwAdda:
	   
	   printf("ADDA\n");
	   if (temp_node->x->mode==CSGPtr) {
/*	      printf("Adding var of size %lli %lli\n",
		     (temp_node->x->x->type->size),
		      (temp_node->x->x->type->len));
	      master_block->framesize=3200;
	      temp_node->x->val=0;*/
	      bss_offset+=3200;
	      temp_node->x->val=data_offset;
	   }
	   
	   write_code(fd,memory_instr(LDA,temp_node->reg,temp_node->y->reg,
				      temp_node->x->val));
	   temp_offset+=4;
		
	   
	   break;
	   
	 case vmwAdd:
	 case vmwSub:
	 case vmwMul:
	 case vmwAnd:
	 case vmwOr:
	 case vmwXor:
	 case vmwLshift:
	 case vmwRshift:
	     if (temp_node->op==vmwAdd) {
		op=ADDQ_OP;
		func=ADDQ_FUNC;
	     }
	     if (temp_node->op==vmwSub) {
		op=SUBQ_OP;
		func=SUBQ_FUNC;
	     }
	     if (temp_node->op==vmwMul) {
		op=MULQ_OP;
		func=MULQ_FUNC;
	     }
	     if (temp_node->op==vmwAnd) {
		op=AND_OP;
		func=AND_FUNC;
	     }
	     if (temp_node->op==vmwOr) {
		op=BIS_OP;
		func=BIS_FUNC;
	     }
	     if (temp_node->op==vmwXor) {
		op=XOR_OP;
		func=XOR_FUNC;
	     }
	     if (temp_node->op==vmwLshift) {
		op=SLL_OP;
		func=SLL_FUNC;
	     }
	     if (temp_node->op==vmwRshift) {
		op=SRA_OP;
		func=SRA_FUNC;
	     }
	   
	   
	     	      
	  if ((temp_node->x->mode==CSGConst) && 
              (temp_node->y->mode==CSGConst)) 
              CSSError("Can't handle addition of two constants!\n");
          if (temp_node->x->mode==CSGConst) {
	     Node blah;
	     
	     blah=temp_node->y;
	     temp_node->y=temp_node->x;
	     temp_node->x=blah;
	  }
	   
		
           
          if (temp_node->y->mode==CSGConst) {
	    if (temp_node->y->val>256) CSSError("ADD const too big!\n");
	    write_code(fd,operate_instr_c(op,temp_node->x->reg,
                                          temp_node->y->val,
                                          func,
                                          temp_node->reg));
	    temp_offset+=4;
	  
          }
          else {
	       write_code(fd,
                  operate_instr(op,temp_node->x->reg,
                                       temp_node->y->reg,func,
		 		       temp_node->reg));
               temp_offset+=4;	  
          }	   
	   
	      break;
	   
	   
        case vmwBlbc:
          printf("Jumping to block %lli %i %i\n",temp_node->y->jump_target->num,
                                            temp_node->y->jump_target->offset,
                                            temp_offset);
	  write_code(fd,branch_instr(BLBC,temp_node->x->reg,
		       ((temp_node->y->jump_target->offset)-temp_offset)-4));
		     temp_offset+=4;

	  break;
        case vmwBlbs:
	  write_code(fd,branch_instr(BLBS,temp_node->x->reg,
		       ((temp_node->y->jump_target->offset)-temp_offset)-4));
		     temp_offset+=4;

	  break;

        case vmwBr:
         write_code(fd,branch_instr(BR,31,((temp_node->x->jump_target->offset)-temp_offset)-4));
         temp_offset+=4;
	  break;

        case vmwCmple:
	 case vmwCmplt:
	 case vmwCmpeq:
	  
	   if (temp_node->op==vmwCmple) {
	      op=CMPLE_OP;
	      func=CMPLE_FUNC;
	   }
	   if (temp_node->op==vmwCmplt) {
	      op=CMPLT_OP;
	      func=CMPLT_FUNC;
	   }
	   if (temp_node->op==vmwCmpeq) {
	      op=CMPEQ_OP;
	      func=CMPEQ_FUNC;
	   }
	   
		
	   
	   
	  if ((temp_node->x->mode==CSGConst) && 
              (temp_node->y->mode==CSGConst)) 
              CSSError("Can't handle comparison of two constants!\n");
          if (temp_node->x->mode==CSGConst) 
             CSSError("Can't compare x constant!\n");
          if (temp_node->y->mode==CSGConst) {
	    if (temp_node->y->val>256) {
	       
	       write_code(fd,memory_instr(LDA,0,31,temp_node->y->val));
	       	    write_code(fd,operate_instr(op,temp_node->x->reg,
                                          0,
                                          func,
                                          temp_node->reg));
	       temp_offset+=8;
	    }
	    else 
	       { 
		  
	    write_code(fd,operate_instr_c(op,temp_node->x->reg,
                                          temp_node->y->val,
                                          func,
                                          temp_node->reg));
	    temp_offset+=4;

	       }
	     
          }
          else {
	       write_code(fd,
                  operate_instr(op,temp_node->x->reg,
                                       temp_node->y->reg,func,
		 		       temp_node->reg));
               temp_offset+=4;	  
          }

	  break;

	   		
	 case vmwNeg:
		
	   
	    write_code(fd,operate_instr(SUBQ_OP,31,
                                          temp_node->x->reg,
                                          SUBQ_FUNC,
                                          temp_node->reg));
	    temp_offset+=4;
	  

	   break;
	   
	   
        case vmwMove:
	  if (temp_node->x->mode==CSGConst) {
	    printf("Moving a const %lli to r%lli!\n",temp_node->x->val,
                               temp_node->reg);
             temp_offset+=load_constant(fd,temp_node->x->val,temp_node->y->reg);
	  }
          else {
	       write_code(fd,operate_instr(BIS_OP,temp_node->x->reg,temp_node->x->reg,BIS_FUNC,
		 		       temp_node->y->reg));
	       temp_offset+=4;	  
          }
                    break;

	case vmwWrl:
	  	    temp_offset+=branch_bsr(fd,26,(writel_offset-temp_offset)-4);
                    break;
	   
	 case vmwDiv:
	 case vmwMod:
	   
             if (temp_node->x->mode==CSGConst) {
               temp_offset+=load_constant(fd,temp_node->x->val,16);
	     }
             else {
	       if(temp_node->x->reg>0) {
	       write_code(fd,operate_instr_c(BIS_OP,temp_node->x->reg,0,BIS_FUNC,
		 		       16));
               temp_offset+=4;
               }
	     }
	     if (temp_node->y->mode==CSGConst) {
               temp_offset+=load_constant(fd,temp_node->y->val,17);
	     }
             else {
	       if(temp_node->y->reg>0) {
	       write_code(fd,operate_instr_c(BIS_OP,temp_node->y->reg,0,BIS_FUNC,
		 		       17));
               temp_offset+=4;
               }
	     }
	   
	   
	   temp_offset+=branch_bsr(fd,26,(divmod_offset-temp_offset)-4);
	   if (temp_node->op==vmwDiv) {
	      write_code(fd,operate_instr_c(BIS_OP,0,0,BIS_FUNC,
		 		       temp_node->reg));
	      temp_offset+=4;
	   }
	   else {
	      write_code(fd,operate_instr_c(BIS_OP,1,0,BIS_FUNC,
		 		       temp_node->reg));
	      temp_offset+=4;
	   }
	   
		
	   break;
	case vmwRead:
               temp_offset+=branch_bsr(fd,26,(readq_offset-temp_offset)-4);
	       if (temp_node->reg>0) {
                 printf("Moving result to %lli\n",temp_node->reg);
	       		 write_code(fd,operate_instr_c(BIS_OP,0,0,BIS_FUNC,
		 		       temp_node->reg));
                 temp_offset+=4;
	       }
	  break;
           case vmwWrite:
             if (temp_node->x->mode==CSGConst) {
	       printf("Trying to write: %lli\n",temp_node->x->val);
               temp_offset+=load_constant(fd,temp_node->x->val,16);
	       temp_offset+=branch_bsr(fd,26,(writeq_offset-temp_offset)-4);
	     }
             else {
	       if(temp_node->x->reg>0) {
		 printf("Moving r%lli to 16\n",temp_node->x->reg);
	       write_code(fd,operate_instr_c(BIS_OP,temp_node->x->reg,0,BIS_FUNC,
		 		       16));
               temp_offset+=4;
	       temp_offset+=branch_bsr(fd,26,(writeq_offset-temp_offset)-4);
               }
	     }
	     break;

	 case vmwLoad:
	 case vmwStore:
	     if (temp_node->op==vmwLoad) {
		op=LDQ_OP;
		
	     }else 
	     {
		op=STQ_OP;
	     }
	   
	     if (temp_node->x->mode==CSGConst) {
		write_code(fd,memory_instr(LDA,0,31,temp_node->x->val));
		temp_node->x->reg=0;
		temp_offset+=4;
	     }
	   
	     if (temp_node->op==vmwLoad) {
		
	     write_code(fd,memory_instr(op,temp_node->reg,
					temp_node->x->reg,0));   
	     temp_offset+=4;  
	     }
	     else 
	     {
		  write_code(fd,memory_instr(op,temp_node->x->reg,
					temp_node->y->reg,0));   
	          temp_offset+=4;  
		
	     }
	   
	   
	     break;
	   
	 case vmwRet:

	   write_code(fd,memory_instr(LDA,30,30,master_block->framesize));
	   temp_offset+=4;	    
           write_code(fd,memory_instr(LDQ_OP,31,30,8));
	   write_code(fd,memory_instr(STQ_OP,26,30,0));	        
	   write_code(fd,memory_instr(LDA,30,30,16));
	   temp_offset+=12; 

	   
           write_code(fd,memory_instr(RET,31,26,(RET_FUNC<<14)+1));
	   temp_offset+=4;
	   
	   break;
	   
           case vmwHCF: 
             write_code(fd,operate_instr_c(BIS_OP,31,0x1,BIS_FUNC,0));
	                                     /* bis r31, 0x1, r0 */
	     write_code(fd,operate_instr_c(BIS_OP,31,0x1,BIS_FUNC,16));
	                                     /* bis r31, 0, r16  */
                     write_code(fd,0x00000083);  /* call_pal callsys */
                     temp_offset+=12;
                     printf("END!\n");
	             break;

	   default:
	     write_code(fd,NOP);
             temp_offset+=4;
                    

	   }

	   }
           temp_node=temp_node->next;
	   
	 }
          temp_block=temp_block->link;
       }
      write_to_disk++;
    }
    text_offset=temp_offset;

    header_size=sizeof(struct section_header)*3+
                            sizeof(struct aout_header)+
                            sizeof(struct file_header);

    text_offset+=pad_16_bytes(fd,text_offset+header_size);


    /* Pad to 8192 byte boundary? */
  
      while((text_offset+header_size)%8192) {
        write_code(fd,NOP);
        text_offset+=4;
      }
  


    /* DATA SEGMENT */
    write(fd,&linefeed,4);
    data_offset+=8;
    data_offset+=pad_16_bytes(fd,data_offset);    
   
    /* BSS SEGMENT */


    

    /* Fix up the text section header */
    header_size=sizeof(struct section_header)*3+
                            sizeof(struct aout_header)+
                            sizeof(struct file_header);
    text.s_size=text_offset+header_size;

    lseek(fd,text_location,SEEK_SET);
    write(fd,&text,sizeof(struct section_header));        

    /* Fix up the a_out header */

    ah.tsize=text_offset+header_size;
    ah.dsize=data_offset;
    ah.bsize=bss_offset;
    ah.bss_start=0x140000000+data_offset;

    lseek(fd,aout_location,SEEK_SET);
    write(fd,&ah,sizeof(struct aout_header));

    lseek(fd,data_location,SEEK_SET);

    strncpy(data.s_name,".data",5);
    data.s_name[5]=0;
    data.s_name[6]=0;
    data.s_name[7]=0;
    data.s_paddr=0x140000000;
    data.s_vaddr=0x140000000;
    data.s_size=data_offset;
    data.s_scnptr=text_offset+header_size;
    data.s_relptr=0;
    data.s_lnnoptr=0;
    data.s_nreloc=0;
    data.s_alignment=1;
    data.s_flags=0x40;

    write(fd,&data,sizeof(struct section_header));

    strncpy(bss.s_name,".bss",5);
    bss.s_name[4]=0;
    bss.s_name[5]=0;
    bss.s_name[6]=0;
    bss.s_name[7]=0;
    bss.s_paddr=0x140000000+data_offset;
    bss.s_vaddr=0x140000000+data_offset;
    bss.s_size=bss_offset;
    bss.s_scnptr=0;
    bss.s_relptr=0;
    bss.s_lnnoptr=0;
    bss.s_nreloc=0;
    bss.s_alignment=1;
    bss.s_flags=0x80;

    write(fd,&bss,sizeof(struct section_header));
   
    close(fd);
   
   
}

   


   
     
   

