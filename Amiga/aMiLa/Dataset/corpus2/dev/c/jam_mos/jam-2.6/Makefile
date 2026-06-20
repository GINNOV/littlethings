# Makefile for jam

CC = cc
CFLAGS =
EXENAME = ./jam0
TARGET = -o $(EXENAME)

# Special flavors - uncomment appropriate lines

# AIX needs -lbsd, and has no identifying cpp symbol
# Use _AIX41 if you're not on 3.2 anymore.
# Also supports AIX53
#CC = gcc
#CFLAGS = -D_AIX
#LINKLIBS = -lbsd
#EXENAME = ./jam0
#TARGET = -o $(EXENAME)

# Darwin 90
# use gcc-4.2, gcc is linked to gcc-4.2
#CC = gcc$(COMPILER_SUFFIX)
#CFLAGS = -D__DARWIN__
#EXENAME = ./jam0
#TARGET = -o $(EXENAME)

# Cygwin - gcc & cygwin
#CC = gcc
#CFLAGS = -D__cygwin__

# Interix - gcc
#CC = gcc

# NCR seems to have a broken readdir() -- use gnu
#CC = gcc

# NT (with Microsoft compiler)
# Use FATFS if building on a DOS FAT file system
#Lib = $(MSVCNT)/lib
#Include = $(MSVCNT)/include
#CC = cl /nologo
#CFLAGS = -I $(Include) -DNT 
#TARGET = /Fejam0
#LINKLIBS = $(Lib)/oldnames.lib $(Lib)/kernel32.lib $(Lib)/libc.lib
#EXENAME = .\jam0.exe

# X64 NET 2005/2008/2010, settings already in environment.
# Turn off new CRT depreciation garb.
#CC = cl /nologo
#CFLAGS = /favor:blend /MT -D_M_AMD64 -DNT -D_CRT_SECURE_NO_DEPRECATE /wd4996
#TARGET = /Fejam0
#LINKLIBS = oldnames.lib kernel32.lib libcmt.lib
#EXENAME = .\jam0.exe

# X86 NET 2005/2008/2010, settings already in environment.
# Turn off new CRT depreciation garb.
#CC = cl /nologo
#CFLAGS = /MT -DNT -D_CRT_SECURE_NO_DEPRECATE /wd4996
#TARGET = /Fejam0
#LINKLIBS = oldnames.lib kernel32.lib libcmt.lib
#EXENAME = .\jam0.exe

# NT (with Microsoft compiler)
# People with DevStudio settings already in shell environment.
#CC = cl /nologo
#CFLAGS = -DNT
#TARGET = /Fejam0
#EXENAME = .\jam0.exe

# MingW32
#CC = gcc
#CFLAGS = -DMINGW

# MPEIX
#CC = gcc
#CFLAGS = -I/usr/include -D_POSIX_SOURCE

# SOLARIS
#CC = gcc

# QNX rtp (neutrino)
#CC = gcc

# AS400 - icc wrapper around ILE C compiler.
# CC = icc 
# CFLAGS = -DAS400 -qDUPPROC
#
# Can't use ./jam0 as EXENAME on AS/400. It confuses icc et al.
# EXENAME = jam0  

SOURCES = \
	builtins.c \
	command.c compile.c execas400.c execunix.c execvms.c expand.c \
	filent.c fileos2.c fileunix.c filevms.c glob.c hash.c \
	headers.c jam.c jambase.c jamgram.c lists.c make.c make1.c \
	newstr.c option.c parse.c pathunix.c pathvms.c regexp.c \
	rules.c scan.c search.c timestamp.c variable.c

all: $(EXENAME)
	$(EXENAME)

$(EXENAME):
	$(CC) $(TARGET) $(CFLAGS) $(SOURCES) $(LINKLIBS)
