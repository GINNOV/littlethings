
AGA Amigas have their OpenGL implementation. TinyGL is a subset of the OpenGL API and allows a software rendering. It's perfect to understand and start OpenGL programming !

I was interested in OpenGL but having a 060/AGA Amiga I was unable to start programming OpenGL demos. I had a look at TinyGL when Ruben Monteiro realized an AmigaDE port. Then I found out an already existing Atari version by Olivier Landemarre. It was enough to think about an Amiga port (even for 68k/AGA).


* Features of the Amiga version

- GCC lib and SAS/C lib : just link the good one and run
- !! StormC 3 is not supported for then moment because it seems its preprocessor is not fully able to compile the almost standard code of TinyGL !!
- glA functions to interface and display images
- GLUT main functions to compile examples without any changes (almost :)
- AGA (on a private screen) and CGFX/P96 (on window or fullscreen) supported
- only 1 window/display available
- limitations are described into the original file called LIMITATION
- small exe obtained (the lib is about 100 ko)


* What's new in this version ?

- now works with a display in a Workbench window if depth > 8 bits
- MorphOS supported !
- GLUT : timing and idle function management (GLUT_ELAPSED_TIME)
- tested with blazewcp on my 060/AGA machine : it's 2.5 times faster !
- GLUT : glutFullScreen function works now to display on screen with CGFX/P96
- more examples and a makefile to compile them
- -lauto option is not necessary anymore


* To do

- Join this version with the Ruben Monteiro's project (AmigaDE version) which supports blend and other stuff
- Clean the code and optimize (mainly the math parts)
- Map the GLUT key codes for using in the keyboard() function
- Compile the lib with VBCC


* What I did. Things about glX

Compile TinyGL without the glX part doesn't require anything except running make ;) The problem is you don't benefit glX functions which are interface functions between GL part and display.
So, I made changes into the glx.c file and renamed it in gla.c with all functions beginning with glA (X was for XWindow). It's possible to use the glA functions but I'm sure you will prefer to play with the GLUT functions. They are commonly used and it will be easier to compile existing code.


* How to install TinyGL ?

The archive contains several directories : include, lib, examples, src.

With GCC 68k compiler :
- include : copy the GL directiry into gg:m68k-amigaos/include for GCC.
- lib : copy libTinyGL.a into gg:m68k-amigaos/lib
- examples : original example and lesson3 from http://nehe.gamedev.net
- src : use make to compile the GCC library

With GCC MorphOS compiler :
The steps are mainly the same, but you have to rename lib/libTinyGL.a.mos
into lib/libTinyGL.a

With SAS/C compiler :
- include : copy the GL directory into sc:include
- lib : copy TinyGL.lib into sc:lib
- examples : original example and lesson3 from http://nehe.gamedev.net
- src : use smake to compile the SAS/C library


* First example

A makefile/smakefile is now in the 'examples' directory to build them, anyway :

- GCC compiler
gcc -c lesson3.c
gcc -o lesson3 lesson3.o -lTinyGL -lamiga

With MorphOS, don't forget to add "-lm" for the math library, otherwise the display willbe trashed :(

- SAS/C compiler (with the given SCOPTIONS file)
sc lesson3.c link to lesson3

If you have a 68060 CPU, change the 68020 option of the smakefie into 68060, you will increase the speed by ten.


* Thanks to Fabrice Bellard, Olivier Landemarre and Ruben Monteiro.

