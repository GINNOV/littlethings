# Phantom Fighter Source Code

This is the source code for the Commodore Amiga game "Phantom Fighter" released commercially in 1988. It was my first commercial game. I found a floppy from Aug 1988 with the source code but no graphics files. I coded this when I was 19 years old and it's sorely lacking in comments. It's a combination of lattice C and 68000 assembler. 
The code was executed natively by booting from a floppy, no bootstrap. It uses a boot library and floppy driver written by Brian Kelly who worked at Emerald Software at the same time as me. This boot library was called KOS (Kel's operating system).

## Youtube demo

There are several youtube videos of the game in action. Here is one of them: https://www.youtube.com/watch?v=jH1GkEExdRs&t=1s

## Whats missing

I found a floppy containing this code when rummaging through stuff at my parents house. The game source, images, and music were actually complete. All essential files, including NTSC graphics and sound files, were recovered.

The code is organized around an event scheduler which executes every frame. The scheduler is a linked list of events which are executed in order of their time. The scheduler is updated every frame and events are added and removed from the scheduler as needed. The scheduler is the main loop of the game. I will try to comment the code and improve explaining how it works
over time. Meanwhile, I guess it's an interesting piece of history for those interested in the Amiga and game development in the late 80s.

## History

I joined Emerald Software in March 1988 to do my work experience at the company. I had finished the first 2 years and the 3rd year was split in to course work followed by a 6 month work experience with a software firm. I was hired by Mike Murphy. Mike Dixon was the Managing Director of Emerald Software. Dave Martin was the financial backer along with the IDA, which is the Irish Government. Dave Martin had a UK based games company called Martech Software. This was a 6 month job after which I returned to finish my Degree at Waterford Institute of Technology in Waterford Ireland. It was called Waterford Regional Technical College (WRTC) at the time. I started work there evaluating a CAPCOM coin op conversion for Tiger Road to home computers but ultimately ended up coding Phantom Fighter. The artist was Paul McLaughlin. Paul stayed in video games after Emerald Software failed and became a key figure in UK video games through his work at BullFrog.

Initially, we obtained what I think were some of the first Amiga 1000 computers in Europe. We used them with 2 floppy drives and later small external hard drives (maybe 5MB in size). We had the full hardware and software manual sets. We mostly used the hardware manuals as we decided to run the games natively with no operating system. We booted straight in to the game using a home grown operating system KOS (Kel's operating system) written by Brian Kelly.

## Graphics inspiration

Paul was responsible for the graphics. He was intrigued with the Alien movies and wanted an organic feel.

## Game Hardware overview

The game was designed around the dual playfield graphics mode on the Amiga. This provided 2 independent 320x256 8 color view fields, one on top of the other. Each can be scrolled independently. I used hardware sprites for player bullets and ships were rendered on the screen using the blitter. The blitter was used in a clever way. Normally, each bitplane for each playfield (there are 3 per playfield, hence 8 colors) is allocated in memory and then the hardware is setup to point at the 3 bitplanes memory for each playfield. We rendered the ships and graphics on the top playfield. Usually, this means we would need a blitter operation per bitplane to render a software sprite.

The game used the Copper chip to interact with the video hardware registers. This included setting up the dual playfield as described above, the hardware sprites and switching the video mode towards the bottom of the screen allowing a score board to be displayed. The dual playfield was only at the top portion of the screen, the playable area. The score board showed how many lives were left, the score and so on. This was a straight 16 color playfield.

## Generating the Copper programs for the various screen modes.

The copper was basically a simple microprocessor which could be programmed to change the video hardware registers at specific scan lines. This allowed us to change the video mode at the bottom of the screen to a single playfield mode and display the score board. The copper was also used to setup the hardware sprites and the dual playfield mode at the top of the screen. I generated copper programs by setting up what I wanted using a normal AmigaOS call and then dumping the Copper program to a file. I then "poked" the values in to the correct places in the copper program.

## Blitter optimization

Brian Kelly came up with the idea of interlacing the playfield bitplanes. Usually, you tell the hardware the bitplane starts at address X and each scan line is 40 bytes long. Instead, we interlaced the 3 bitplanes. This first we have 40 bytes for line 0 of bitplane 0, then the next 40 bytes is the line 0 for bitplane 1 and the next 40 bytes is line 0 for bitplane 2. We need to tell the hardware still the start in memory of line 0 for each bitplane like before but we tell it the skip to the next line is 120 bytes instead of 40. The Amiga hardware happily showed the bitplanes correctly. But, it also allowed us to use a single blitter operation to do all 3 bitplanes. I also interlaced the software sprites similarly in memory. This wasn't implemented in the code here but would be trivial to do.

## KOS (Kel's Operating System)

Initially, I tried developing the game as an Amiga Application. It used all the normal APIs but we found the game would skip frames and we didn't like that. Brian Kelly started developing his own bootstrap system called KOS (Kel's Operating System). He wrote his own MFM encode/decode for the bitstream floppies on the Amiga as well as the bootstrap code. He wrote libraries for Lattice C which could load a Lattice compiled executable from a floppy and bootstrap it. He also wrote file read/write routines which were used to construct the game floppy disk during development. KOS had a remote debugging capability inspired by PDS which was used for 8 bit game development. We had a parallel cable between a test Amiga and the developers Amiga. We could run the game remotely and it would load graphics from the source Amiga. He also implemented a simple source code level debugger which meant debugging was much easier.

Interestingly, when we were publishing the game in the USA, the KOS formatted disks would not boot on a US Commodore Amiga. This seemed to be a timing issue with 50 and 60Hz. If my memory serves me correctly, Brian had coded the MFM encoding slightly non standard and as a result we had this issue. Brian fixed the issue for the US version.

## Bob Editor

Mike Murphy had created his own Sprite/Bitmap editor for the Amiga. This was an improved version of the functionality of Deluxe Paint optimized for gaming. It was called the Bob Editor. Bob was for Bitmap object I think. The artists used that to do all the bitmaps for the games. Mike had written this before he helped start Emerald Software. It was a very good editor and was used for all the games at Emerald Software. It was used to create the graphics for Phantom Fighter.

## Game philosophy looking back

Hindsight is always 20/20. The game was unusual for the time. Most games were Atari ST ports. Other similar games used a cell based background with the software sprites layered on top. The Atari ST had no hardware support for Sprites or hardware scrolling. They were like a 16 bit ZX Spectrum in this regard. I wanted to use the hardware features of the Amiga, hence, split screen with dual playfields for the game and a status screen at the bottom. The game background screens during play were 4 screens wide and drawn as a single bitmap by Paul. We loaded the huge bitmap in to memory and then scrolled through it either vertically or horizontally during the game by changing the playfield base addresses and hardware scroll registers. We could have done this using cells instead. Paul would have made a palette of X 8x8 or 16x16 character cells and then used those to construct the backgrounds from those cells. This would have saved a lot of memory and would still have been easy to implement hardware wise. But, it was my first game and we didn't know any better. The game would have been easier to port to other platforms if we had used cells. The game was never ported to the Atari ST but Bobby Healy did a PC version which had to use different graphics due to the different capabilities. He had to support CGA/EGA/Tandy and VGA versions of the game.

A big mistake I made was using random patterns of alien waves. I should have used a fixed pattern of waves per level so people could learn the game and progress easier. It was too hard to play as a result I think. Defender inspired this as its aliens were random. But, regardless, should have used fixed wave patterns. The python version corrects this and only allows attacks from the front of the player ship.

## Best way to explore source code

The main.c file is the main entry point. From these, media files are loaded, the game main loop, the hardware initialization and so on.

## IFF file format

The IFF standard is a chunk based file format. Each chunk has a 4 byte ID, a 4 byte length and then the data. The data is padded to an even number of bytes. The Bob Editor used this format to store the bitmaps and sprites. The IFF format was used in Deluxe Paint and other Amiga software.

## Development hardware

I started with a 1MB Amiga 1000 and settled on a 1MB Amiga 500 for development with an external 5MB harddrive and a CBM color monitor. The hard drive was a US model and required 110V which we didn't have in Ireland. Mike's buddy Martin rigged up a choke which dropped the voltage from 240V down to 110V and this worked for a while until one day the drive made some awful noises and failed.

## Build optimizations

Lattice C was the compiler/assembler used by the game. In order to speed the development process, a RAM disk was created on the Amiga and the headers were precompiled and stored in the RAM disk. Subsequent builds then used the precompiled headers. If the headers were modified then the precompiled headers needed to be regenerated. The C and assembler files were compiled to object files and then linked together. The resulting executable file was then post processed by a KOS utility and prepped for remote execution on the test Amiga.

### Lattice C

Lattice had some advantages. The compiler was a 2 pass compiler. The first pass took the C code and translated it to 68k assembler files. A second pass took the assembler and generated the corresponding object files. This was handy as it allowed me to write an algorithm in C and then look at the assembler version of that code. I then usually hand tuned it to make it faster.

## 68010 issues

The game was developed on a 68000 Amiga. The 68010 Amigas came later and introduced compatibility problems due to their instruction prefetch. The 68010 would prefetch 3 16 bit words ahead. This caused problems with self modifying code which updated a following instruction. The code would execute incorrectly because the unmodified instruction was fetched during the modification instruction being executed thus the modification was lost.

## Legal Status and Licensing

I wrote Phantom Fighter in 1988 while employed by Emerald Software in Ireland.
As an employee, copyright in the original source code and assets was held by
Emerald Software. The game was published by Martech Software (UK) and
Broderbund Software (USA).

Emerald Software and Martech Software ceased operations long ago. Broderbund
was acquired through a series of corporate transactions. To the best of my
knowledge, no entity has commercially exploited or asserted rights over
Phantom Fighter in decades, and no active rightsholder can be identified.

I am sharing this repository in good faith as the original author, for
historical, educational, and preservation purposes. If any party holds a
legitimate claim to rights in this work, please open an issue and I will
address it promptly.

- **Python recreation** (`python/` directory): Licensed under the MIT License. See [LICENSE](LICENSE).
- **Original source code and assets**: Shared under the notice in [LICENSE](LICENSE). See above for background.

## Modern python version of the game

There is a modern claude generated version of the game in python.

## Javascript version of the game

This is a version which can be played from a browser. Based on the python version.
