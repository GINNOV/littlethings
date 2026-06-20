#!/bin/bash

TARGETARCHITECTURE=m68k-elf

# Configure your path
HOSTINSTALLPATH="/opt/m68k-elf.slamy3"

# Configure as much as you like
MAKE_JOBS=4

if [ ! -d "$HOSTINSTALLPATH" ]; then
	echo Please create $HOSTINSTALLPATH and give the current user write rights to it
	exit 1
fi

set -e
export PATH=$PATH:$HOSTINSTALLPATH/bin/

function fetchAndExtract()
{
	url=$1
	file=$(echo $url | sed -E 's#.*/(.*)#\1#')
	folder=$2
	
	if [ ! -d "$folder" ]; then
		wget $url
		tar xf $file
	fi
}

function fetch_archives ()
{
	fetchAndExtract https://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.gz binutils-2.32
	fetchAndExtract ftp://ftp.fu-berlin.de/unix/languages/gcc/releases/gcc-9.1.0/gcc-9.1.0.tar.gz gcc-9.1.0
	fetchAndExtract ftp://sourceware.org/pub/newlib/newlib-3.1.0.tar.gz newlib-3.1.0
}

function build_binutils () {
	echo ---------------------- Building binutils -------------------------
	
	cd binutils-2.32
	mkdir -p build
	cd build
	

	../configure \
		--target=$TARGETARCHITECTURE \
		--prefix=$HOSTINSTALLPATH/ \
		--with-headers=../../newlib-3.1.0/newlib/libc/include/
	
	make -j$MAKE_JOBS
	make install
	cd ../..
}

# --disable-bootstrap					Dont test the GCC as the Target is not the Host
# --disable-newlib-io-float				Disable printf/scanf family float support.
# --enable-newlib-nano-formatted-io		This builds NEWLIB with a special implementation of formatted I/O functions, 
#										Designed to lower the size of application on small systems
# --disable-multilib						Do NOT generate for every library version. Only 68000 is needed here
# --enable-cxx-flags='...'				Custom flags for compiling libstdc++. In this case optimizing for size.	
# --disable-libssp						Disable stack smash protection
# --disable-libgomp						GNU Offloading and Multi Processing Runtime Library not needed


function build_bootstrap_gcc () {
	echo ---------------------- Building bootstrap GCC -------------------------
	
	cd gcc-9.1.0/
	mkdir -p build
	cd build
	
	../configure \
		--target=$TARGETARCHITECTURE \
		--prefix=$HOSTINSTALLPATH \
		--with-cpu=m68000 \
		--enable-languages=c,c++ \
		--disable-bootstrap \
		--with-newlib \
		--disable-libmudflap \
		--enable-lto \
		--disable-libssp \
		--disable-libgomp \
		--disable-threads \
		--with-gnu-as \
		--with-gnu-ld \
		--disable-nls \
		--disable-libstdcxx-threads \
		--disable-multilib \
		--with-headers=../../newlib-3.1.0/newlib/libc/include/ \
		--enable-cxx-flags='-fomit-frame-pointer -ffunction-sections -fno-exceptions'
		
	#build only gcc
	make -j$MAKE_JOBS all-gcc
	make install-gcc
	cd ../..
}

function build_newlib () {
	echo ---------------------- Building Newlib -------------------------
	
	cd  newlib-3.1.0/
	mkdir -p build
	cd build
	
	../configure \
		--target=$TARGETARCHITECTURE \
		--prefix=$HOSTINSTALLPATH \
		--with-cpu=m68000 \
		--disable-multilib \
		--enable-newlib-nano-formatted-io \
		--disable-newlib-io-float \
		--disable-newlib-supplied-syscalls \
		--enable-languages=c,c++ \
		--with-headers=../../newlib-3.1.0/newlib/libc/include/
		
	make -j$MAKE_JOBS
	make install
	cd ../..
}

function build_final_gcc () {
	echo ---------------------- Building Rest of GCC and Libstdc++ -------------------------
	
	cd gcc-9.1.0/build
	make -j$MAKE_JOBS
	make install
	cd ../..
}


fetch_archives
build_binutils
build_bootstrap_gcc
build_newlib
build_final_gcc

