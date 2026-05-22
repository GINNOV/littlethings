SRC =  amiga.c analyze.c decode_ea.c disasm_code.c disasm_data.c \
       fpu_opcodes.c globals.c hunks.c main.c mem.c mmu_opcodes.c \
       opcode_handler_cpu.c \
       opcode_handler_fpu.c opcode_handler_mmu.c opcodes.c ref_table.c \
       jmptab.c user_defined.c util.c

HDRS = defs.h refs.h string_recog.h

DOC = ADis.doc

OBJS = amiga.o analyze.o decode_ea.o disasm_code.o \
       disasm_data.o fpu_opcodes.o globals.o hunks.o \
       main.o mem.o mmu_opcodes.o \
       opcode_handler_cpu.o \
       opcode_handler_fpu.o opcode_handler_mmu.o \
       opcodes.o ref_table.o \
       jmptab.o user_defined.o util.o 

TARGET = ADis

DEFINES = -IGNU:Include -IINCLUDE: -DNDEBUG
OPTFLAGS = -O3
CFLAGS =  $(DEFINES) $(OPTFLAGS)
LFLAGS = 
#-lamy

all : $(TARGET)

$(TARGET) : $(OBJS) version.o
  gcc -o $(TARGET) $(OBJS) version.o $(LFLAGS)

clean:
  -delete #?.o quiet

amiga.o  : amiga.c
  gcc -c $(CFLAGS) -o $@ $*.c

analyze.o  : analyze.c
  gcc -c $(CFLAGS) -o $@ $*.c

decode_ea.o : decode_ea.c
  gcc -c $(CFLAGS) -o $@ $*.c

disasm_code.o : disasm_code.c
  gcc -c $(CFLAGS) -o $@ $*.c

disasm_data.o : disasm_data.c
  gcc -c $(CFLAGS) -o $@ $*.c

fpu_opcodes.o : fpu_opcodes.c
  gcc -c $(CFLAGS) -o $@ $*.c

globals.o : globals.c
  gcc -c $(CFLAGS) -o $@ $*.c

hunks.o : hunks.c
  gcc -c $(CFLAGS) -o $@ $*.c

main.o : main.c
  gcc -c $(CFLAGS) -o $@ $*.c

mem.o : mem.c
  gcc -c $(CFLAGS) -o $@ $*.c

mmu_opcodes.o : mmu_opcodes.c
  gcc -c $(CFLAGS) -o $@ $*.c

opcode_handler_cpu.o : opcode_handler_cpu.c
  gcc -c $(CFLAGS) -o $@ $*.c

opcode_handler_fpu.o : opcode_handler_fpu.c
  gcc -c $(CFLAGS) -o $@ $*.c

opcode_handler_mmu.o : opcode_handler_mmu.c
  gcc -c $(CFLAGS) -o $@ $*.c

opcodes.o : opcodes.c
  gcc -c $(CFLAGS) -o $@ $*.c

ref_table.o : ref_table.c refs.h
  gcc -c $(CFLAGS) -o $@ $*.c

jmptab.o : jmptab.c
  gcc -c $(CFLAGS) -o $@ $*.c

user_defined.o : user_defined.c
  gcc -c $(CFLAGS) -o $@ $*.c

util.o : util.c string_recog.h
  gcc -c $(CFLAGS) -o $@ $*.c

version.o : version.c
  gcc -c $(CFLAGS) -o $@ $*.c

$(OBJS) : defs.h
