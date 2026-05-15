# Amiga m68k-elf-gcc toolchain with C++ support

## Why ?

I'm currently busy developing an Amiga game in C and wanted to give others the possibility to have an easy start into this topic.
I believe that C can be used as an alternative to assembler even on the Motorola 68000.
I can undergird this argument by presenting some [footage of the game](https://www.youtube.com/watch?v=k_PfDeDRdnE) in development.

It turns out there are quite some good tolchains for Amiga development out here.
I want to give credit to those I use.
- [The toolchain68k from haarer](https://github.com/haarer/toolchain68k) is a very good one. I currently use this as NDOS toolchain for developing without using AmigaDOS which saves some valuable memory for game development.
- [The amiga-gcc from bebbo](https://github.com/bebbo/amiga-gcc) is another very good example. It targets developing for AmigaDOS and I use this one for the harddisk port of my game.

So what is the issue then? I was thinking about if C++ could be used for developing for the Amiga and this project here gives some benchmarks in terms of speed and size about this topic. While bebbos's toolchain is working with C++ code, it turns out that the toolchain68k of haarer doesn't produce a working libstdc++ and now working global constructors. While g++ is working in general (range-loops are funcitonal) I'm not satisfied with the results as I wanted to use the C++11 potential during development.

So I decided to dive a little bit deeper and try to create my own m68k-elf-gcc toolchain.

## What this toolchain does different?

- Delivered with Bootloader and ADF construction kit for direct building of ADFs
- Working C++ examples with C++11 style code.
- Downsizing of newlib to save memory
	- Removal of floating point support of scanf and printf (I haven't found a purpose for it during development. Keep in mind that float and double datatypes are still usable and only take up space if used in the project.)
- Downsizing of libstdc++ to save memory
	- Deactivation of exceptions. (Unwind code takes up much space. Exceptions leads to abort() in this case)
	- Usage of stream type operators (like std::cout) is highly discouraged as it wastes about 300kB of memory. For systems with lots of FastRAM this might not be a big issue. But for A500 development the newlib-nano implementation of printf is much better suited. In The example project those can be enabled optionally to see the difference.

## Parts of this project which were fetched from other projects

Besides the mentionend toolchains above, I'd like to give credit and thanks to those projects

- DDE5-BootLoader.S is a BootLoader and Floppy driver by [Photon](http://coppershade.org/asmskool/SOURCES/Photon-snippets/DDE5-BootLoader.S).
- make-adf.py and sum-bootblock.py is from [this bootloader project](https://github.com/deplinenoise/trackloader).

## Prerequisites

- A linux machine as Windows support won't be tested by me. But feel free to inform me about successes.
- kick31.rom and kick13.rom must be placed in the example folder for execution. I can't supply this for copyright reasons.
- If you like to execute the AmigaDOS version of the example
	- Copy a valid Libs folder to harddrive from an AmigaDOS 3.1 installation. I can't supply this for copyright reasons.
	- You need to install the bebbo toolchain mentioned above as this project only produces an ELF kit.
- You need to install some build-essentials
	- sudo apt-get install  wget bzip2 git make tar flex bison diffutils texinfo gcc g++ libgmp-dev libmpc-dev libmpfr-dev libisl-dev
	- TODO this list might be incomplete. Please create an issue in github if you are having problems.
- For testing you also need an Amiga emulator. fs-uae is my currently favoured solution
    - sudo apt-get install fs-uae


## How to build the toolchain

First you might to edit the executed script as you might want to use a different folder for installation!


```bash
cd toolchain
./buildToolchain.sh
```

## How to build the example as NDOS application

```bash
cd example
./build.sh -DAMIGACROSS=1 -DBUILD_FOR_AMIGADOS=0
```

## How to build the example as AmigaDOS application (bebbo Toolchain is needed!)

```bash
cd example
./build.sh -DAMIGACROSS=1 -DBUILD_FOR_AMIGADOS=1
```

## How to build the example as a Linux application

```bash
cd example
./build.sh -DAMIGACROSS=0
```


## How to test the NDOS build

This is a very small example. You need a COM port emulation.
Execute this in one terminal

```bash
scripts/serialout.sh
```

Now execute this in another terminal

```bash
fs-uae a1200.fs-uae
```

## How to test the AmigaDOS build

This is a very small example. You need a COM port emulation.
Execute this in one terminal

```bash
scripts/serialout.sh
```

Now execute this in another terminal

```bash
fs-uae a1200hd.fs-uae
```
AmigaDOS should pop up and then execute "m". I went for this short name as it could be type very fast.


## Example Results of current build

### NDOS on unexpanded emulated Amiga 500

    Allocate 50 int arrays of size 4 and manage them
                c array of malloc'd pointers   5784 us    100%
                   c array of new'd pointers   7045 us    122%
                  c array of unique pointers   7621 us    132%
       reserve c++ vector of unique pointers   9034 us    156%
      presized c++ vector of unique pointers   8577 us    148%
                  c array of shared pointers   7009 us    121%
               c++ vector of unique pointers  10146 us    175%
                 c++ list of unique pointers  15569 us    269%
                c++ array of unique pointers   7669 us    133%

    Allocate 50 int arrays of size 64 and manage them
                c array of malloc'd pointers   6442 us    100%
                   c array of new'd pointers   7723 us    120%
                  c array of unique pointers  10361 us    161%
       reserve c++ vector of unique pointers  12083 us    188%
      presized c++ vector of unique pointers  11438 us    178%
                  c array of shared pointers   7329 us    114%
               c++ vector of unique pointers  13262 us    206%
                 c++ list of unique pointers  19122 us    297%
                c++ array of unique pointers  10550 us    164%

    Construct strings from 4 integers
                           sprintf   3887 us
            c++ stringstream build   5753 us
    Strings ok

    Iterate over 1000 ints and sum them up
                arraysum - for i++   1441 us    100%   results verified
                arraysum - for ++i   1441 us    100%   results verified
             arraysum - range loop   1441 us    100%   results verified
            vectorsum - range loop   1442 us    100%   results verified
         vectorsum - std::for_each   1441 us    100%   results verified
              vectorsum - iterator   1441 us    100%   results verified
       vectorsum - std::accumulate   1442 us    100%   results verified
              listsum - range loop   2000 us    139%   results verified
                listsum - iterator   1716 us    119%   results verified

### NDOS on unexpanded emulated Amiga 1200

    Allocate 50 int arrays of size 4 and manage them
                c array of malloc'd pointers   5784 us    100%
                   c array of new'd pointers   7045 us    122%
                  c array of unique pointers   7621 us    132%
       reserve c++ vector of unique pointers   9034 us    156%
      presized c++ vector of unique pointers   8577 us    148%
                  c array of shared pointers   7009 us    121%
               c++ vector of unique pointers  10146 us    175%
                 c++ list of unique pointers  15569 us    269%
                c++ array of unique pointers   7669 us    133%

    Allocate 50 int arrays of size 64 and manage them
                c array of malloc'd pointers   6442 us    100%
                   c array of new'd pointers   7723 us    120%
                  c array of unique pointers  10361 us    161%
       reserve c++ vector of unique pointers  12083 us    188%
      presized c++ vector of unique pointers  11438 us    178%
                  c array of shared pointers   7329 us    114%
               c++ vector of unique pointers  13262 us    206%
                 c++ list of unique pointers  19122 us    297%
                c++ array of unique pointers  10550 us    164%

    Construct strings from 4 integers
                           sprintf   3887 us
            c++ stringstream build   5753 us
    Strings ok

    Iterate over 1000 ints and sum them up
                arraysum - for i++   1441 us    100%   results verified
                arraysum - for ++i   1441 us    100%   results verified
             arraysum - range loop   1441 us    100%   results verified
            vectorsum - range loop   1442 us    100%   results verified
         vectorsum - std::for_each   1441 us    100%   results verified
              vectorsum - iterator   1441 us    100%   results verified
       vectorsum - std::accumulate   1442 us    100%   results verified
              listsum - range loop   2000 us    139%   results verified
                listsum - iterator   1716 us    119%   results verified


### AmigaDOS on unexpanded emulated Amiga 1200

These values are assumed to be faster as AmigaDOS correctly sets up the Caching of the 68020

    Allocate 50 int arrays of size 4 and manage them
                c array of malloc'd pointers   4802 us    100%
                   c array of new'd pointers   5274 us    110%
                  c array of unique pointers   6967 us    145%
       reserve c++ vector of unique pointers   6458 us    134%
      presized c++ vector of unique pointers   6368 us    133%
               c++ vector of unique pointers   7618 us    159%
                 c++ list of unique pointers  11264 us    235%
                c++ array of unique pointers   6324 us    132%

    Allocate 50 int arrays of size 64 and manage them
                c array of malloc'd pointers   4765 us    100%
                   c array of new'd pointers   5235 us    110%
                  c array of unique pointers   7696 us    161%
       reserve c++ vector of unique pointers   7257 us    152%
      presized c++ vector of unique pointers   7181 us    151%
               c++ vector of unique pointers   8323 us    175%
                 c++ list of unique pointers  11678 us    245%
                c++ array of unique pointers   7055 us    148%

    Construct strings from 4 integers
                           sprintf   1579 us
            c++ stringstream build   3057 us
    Strings ok

    Iterate over 1000 ints and sum them up
                arraysum - for i++   1000 us    100%   results verified
                arraysum - for ++i    998 us    100%   results verified
             arraysum - range loop   1138 us    114%   results verified
            vectorsum - range loop   1139 us    114%   results verified
         vectorsum - std::for_each   1000 us    100%   results verified
              vectorsum - iterator   1000 us    100%   results verified
       vectorsum - std::accumulate   1000 us    100%   results verified
              listsum - range loop   1419 us    142%   results verified
                listsum - iterator   1419 us    142%   results verified

# Conclusion

The C++ stringstream and iostream classes should not be used!

The current executable is 340 kB in size if used and 42 kB if absent. I'm not yet sure why this happens but a short search on the internet reveals that this is "normal" and libstdc++ is expected to have a size in hundreds of kB. Before, it was even bigger but the removal of Unwind and exception handling resulted in some decrease.

Some people encourage the usage of libsupc++. But I've found that too much of C++ is missing this way.

So if you plan to use C++ on the Amiga and plan to develop an AmigaDOS application for a system with some FastRAM I can guess that std::cout might be an option. For NDOS development I won't recommend it as space is quite valuable and printf is still a good solution for most use cases.

If a big number of std::stringstream is handled I can highly discourage this as the runtime is nearly doubled compared to sprintf. Even this doesn't makes any sense as sprintf has the additional load of parsing the format string at runtime and C++ could template-magic this out of the way.

The iteration tests reveal that down to the assembler level the code is nearly identical for all cases expect std::list which does make sense as the memory layout is different and the later must use pointers to get to the next entry.

TODO There are some systematic differences in run-time. I'm not yet sure why this happens but investigation might be needed.

On the allocation side I'm deeply confused. Malloc seems to be the fastest.
And then shared_ptr is faster than new? And even unique_ptr is slower than shared_ptr?
This doesn't makes any sense and I can only assume that the state of the heap as an effect on the results.
This tests might need a remake with a fresh heap for each test and mabye also with seperate allocation and deallocation measurements.

## Disclaimer

This project is provided as is. I can't held responsible for damages that it might cause on your hardware.
I'll encourage to first try this on an emulated machine and only do this on real hardware if you know what you are doing.

