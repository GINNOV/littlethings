Welcome to the shareware release of ProAsm 1.74




                                  ProAsm
                   Copyright © 1989-1996 by Daniel Weber
                            ProAsm is Shareware





1.74 Release Notes:
ProAsm(TM) Software

These notes address the following topics:
  - The ProAsm Assembler
  - ASX - The ProAsm User Interface
  - ProOpts - The ProAsm Configuration Program
  - Support Libraries
  - ProAsm Software Overview
  - Documentation
  - Author







                           The ProAsm Assembler
                           --------------------

The  ProAsm  assembler  is a traditional two pass assembler that emits code
for  the  entire  Motorola  MC68000  Family.  ProAsm is a high performance,
full-featured   assembler   with   enough  powerful  features  to  make  it
appropriate for all assembly tasks.  It produces native 68xxx code, and has
special  directives to enable the selection of the target processor and the
appropriate  code  optimization  for  that processor.  ProAsm supports both
addressing  mode  syntaxes  as defined by Motorola.  Programmers find these
capabilities  of  the  new  syntax  mode  particularly  useful for handling
advanced data structures common to sophisticated application and high level
languages.

The  output  produced  by  ProAsm  is  either  an  executable file that can
directly  be  run  under AmigaDOS or the Workbench, object modules that are
compatible with the Amiga standard linker and BLINK (the replacement linker
from  'The  Software  Distillery'),  binary  output  for ROM-able code (for
example),  pre-assembled  files,  or the Motorola S-record format.  Besides
the  normal  output files, ProAsm can also generate four types of auxiliary
output  files which reflect the results of the assembly process:  the error
file  and  the  equate  file,  the  source  listing and the cross-reference
listing.

ProAsm  has  a  tremendous number of switchable optimizations including the
multipass  facility to gain an even more optimized code.  ProAsm also has a
very  rich  set of directives including a wide range of synonyms that allow
source  code  written  for  other  assemblers  (Public  Domain software for
example) and the Commodore include files to be assembled.  Included as well
are  directives  to  deal  with  structures,  repeat loops and similar code
elements  very  easily.  Powerful macros with unlimited macro arguments and
many macro directives are available to permit code to be easily and clearly
arranged.

The  rich  set  of  available  facilities  allows  exact  control  over the
performance  of  the  assembler.   This  control  includes features such as
optimization,  case dependency for symbols, syntax control, and the default
behaviour  of ProAsm to name a few.  More advanced control features such as
precise  code  control  and  selectable  symbol  search  algorithm are also
included.

A   valuable  feature  of  ProAsm  is  the  configuration  file,  which  is
automatically  included in each assembly.  You can customize ProAsm to suit
your  particular  wishes  by  including  commonly  used  macros,  code  and
directives in the configuration file.

No  program  can  be  all  things  to  all  people.  So all assemblers have
limitations  -  ProAsm  tries  to put them as far as possible not to narrow
your  creativity.   This  results in the fact that the most limitations are
just  limited  only  by  available  memory  (line length, macro body, macro
nesting,  macro  arguments, nesting of macro directives, repeat and include
file nesting,...).

This  makes  ProAsm  an ideal assembler for the professional developer, the
high-level  language  programmer  (such  as  C,  Modula,...)  who  want  to
integrate  some  assembly language code into his programs, and the beginner
at assembly language programming.


                               Some Features
                               .............

  - Completely  written  in  carefully  hand-coded  assembly  language for
    maximum speed.
  - Supports the entire Motorola M68000 Family:
    MC68000, MC68008, MC68010, MC68020, MC68030, MC68040, MC68060, MC68EC020,
    MC68EC030 processors, and the MC68881, MC68882, MC68851 coprocessors.
  - Both  addressing  mode syntax supported as defined by Motorola for the
    M68000  Family.   (The syntax modes can individually be controlled by
    using the  NEWSYNTAX,  OLDSYNTAX  and  RELAX directives.)
  - Five different output file formats:
    executable, linkable, binary, preasm (pre-assembled symbol tables and
    macros), and the Motorola S-record format.
  - Produces Amiga standard object files compatible with the Amiga standard
    linker and BLINK (the replacement linker from 'The Software Distillery').
  - Rich set of optimization possibilities.
  - Multipass optimization to gain more compact code.
  - Powerful macros (and many macro directives). (Unlimited number of macro
    arguments and nesting - limited only by available memory)
  - Configuration file supported to customize ProAsm.
  - Convenience Pseudo-Opcodes: MEA, POP, PUSH, POPM, PUSHM, APOPM, APUSHM.
  - Special directives to allow powerful string-handling.
  - Support of text substitution using textual symbols.
  - Include files supported (unlimited nesting of include files - limited
    only by available memory).
  - Conditional assembly (conditional nesting up to 231 levels possible).
  - Directives to declare initialized data with restricted range
  - Directives to define C-type, BCPL, and OS9-type strings.
  - Supports symbol segmentation.
  - Special directives to change the default behaviour of ProAsm.
  - Structure offset directives allow the declaration of structures easily.
  - Frame offset directives to define stack frame data structures.
  - Repeat loop directives to allow text repetition (unlimited repeat
    nesting - limited only by available memory).
  - Up to 256 different hunks (code, data, and bss).
  - Support of debug information for the executable and linkable output.
    ProAsm generates either a standard or compressed debug hunk format that
    is compatible with the SAS/C.
  - A directive to attach an AmigaDOS comment to the output file.
  - A directive to set the AmigaDOS file protection flags to the output file.
  - Four auxiliary output files can be generated: the listing file, error
    file, equate file, and the cross-reference listing.
  - ProAsm allows the inclusion of binary images.
  - The assembly task priority can be set from within the source file.
  - ProAsm is entirely re-entrant, and can be made resident.
  - A rich set of directives and options to control the assemblers behaviour
    and to ease programming.
  - The standard directives are compatible with the most popular assemblers.
  - Many useful build-in symbols to make programming easier.
  - Comfortable support of relative bases.
  - XPK library system supported.
  - Directives to control the report of information timing.
  - Four selectable symbol search algorithm.
  - (OSV37 & OSV39 and higher hunks supported)
  - Six types of constants provided:
    decimal, hexadecimal, binary, octal, floating point, and string.
  - ProAsm (optionally) supports localization for the AmigaOS V38 and higher.
    (German error texts included to the software package).



                            System Requirements
                            ...................

  - Amiga with at least 512KByte of memory needed.
  - Workbench and Kickstart 1.2 or higher required.
  - Fully compatible with the entire Amiga family.






                      ASX - The ProAsm User Interface
                      -------------------------------
ASX  is  a user interface for the ProAsm assembler that is implemented as a
commodity.   Through the use of the commodities.library it can be installed
on any hotkey and fully controlled with the Commodities Exchange program.

ASX  loads  the ProAsm assembler which than can be accessed using the ARexx
interface,  the  asx.library,  or the AppIcon possibility.  The asx.library
and the AppIcon can optionally be enabled or disabled.

The  ARexx  commands  provide  a method of controlling ASX from an external
program.   These  ARexx  commands  can  be  used  to  create  an integrated
programming/development  environment  with  any  application that offers an
ARexx  interface.  For example, a program can be written by a programmer on
its  favourite ARexx equipped texteditor, then an ARexx command can be sent
to ASX to assemble the source code.  Any error messages and warnings of the
assembly  are  stored  by  ASX,  and  using  commands such as NEXTERROR and
PREVERROR  the  texteditor is capable to position the cursor in the line of
the  first  error.  After correcting that error a single keystroke can jump
to  the  next  error,  or  another  keystroke can jump back to the previous
error.

Another  method  of controlling ASX is the use of the optional asx.library.
The  various  functions  that this library offers can be used to design own
user interfaces with ease.

The AppIcon possibility is another visual user interface that allows one or
more  source  file icons to be assembled by just dropping them over the ASX
appicon.

Frequently  used include files can be loaded residently and managed by ASX.
Such residently loaded include files reduce assembly time since they do not
need to be loaded each time the assembler is called.

Preferred  include file paths can be added to a database that is managed by
ASX.   During  assembly the assembler uses then this database to know where
to look for the include files.

ASX  also  provides  a  feature  called  the source manager, which offers a
possibility  to  manage the current project per hotkey.  Through the use of
an  ARexx  script file the user can easily define the action that has to be
fulfilled  when  an  entry  in the source manager window had been selected.
Almost all shooting matches of the source manager can be set by the user to
his wishes and needs to allow a wide range of flexibility.

For  an  easy  use  of  ASX,  it  comes along with an on-line help feature.
Commodore's AmigaGuide is used to display the help text to the user.



                               Some Features
                               .............

  - Hotkeys to control ASX.
  - 53 ARexx commands that permits external programs to control ASX.
  - 13 asx.library functions.
  - Workbench 2.0's appicon feature supported.
  - Source manager to manage projects and source codes by a single hotkey.
  - Supports residently loaded include files to reduce assembly speed.
  - Include file paths can be stored in a database to let the assembler
    know where to look for the include files.
  - Context-sensitive on-line help using Commodore's AmigaGuide.
  - Settings can be saved and loaded.
  - Full intuition/gadtools user interface to allow all changes to be done
    using the mouse.
  - Font-sensitive user interface.


                            System Requirements
                            ...................

  - Amiga with at least 512KByte of memory needed.
  - Workbench and Kickstart 2.04 or higher required.
  - Fully compatible with the entire Amiga family.






                ProOpts - The ProAsm Configuration Program
                ------------------------------------------
ProOpts  provides a simple method of generating or changing a configuration
file  for  the ProAsm assembler.  Since ProAsm supports configuration files
to  be  loaded  each  time when it is called, the user is able to customize
ProAsm  to suit his particular wishes and needs.  The options for a project
can  be set by clicking on the gadget that corresponds to the option.  Even
options  for  which  the  ProOpts  utility  does  not  have a gadget can be
specified by a special string and listview gadget.

The  generated  configuration  file  is  an  ASCII  file  that contains the
specified options as assembly directives.  It is similar to an include file
except  that it is loaded at the very beginning of each assembly.  There is
no  restriction  on  the  use of as- sembler directives or even code in the
configuration  file.   The  user  can  also  re-edit or add options using a
texteditor.   Previously  generated config files can be loaded into ProOpts
and then be changed to the new option settings.



                               Some Features
                               .............

  - Configuration can be changed by using the mouse.
  - Generates an assembly language source file.
  - Supports options that have no specific gadget.
  - Menu item to reset all options to their default.
  - Full intuition/gadtools user interface to allow all changes to be done
    using the mouse.
  - Font-sensitive user interface.


                            System Requirements
                            ...................

  - Amiga with at least 512KByte of memory needed.
  - Workbench and Kickstart 2.04 or higher required.
  - Fully compatible with the entire Amiga family.






                             Support Libraries
                             -----------------
The  support  libraries  are  not  required  by  ProAsm  or  by  any of its
associated  utilities.   They  can  optionally  be  installed  to  increase
selectively the power and flexibility of ProAsm.

  - proasmlang.library	 - ProAsm localization support library for OS V38
                           and higher.
  - proasmoptim.library  - Library to enlarge ProAsm's optimization dictionary
                           to recognize more possible optimizations.
  - proasmfp.library	 - Library to boost ProAsm's floating-point support.

Please note that the last two libraries are currently not included to the
archive.






                         ProAsm Software Overview
                         ------------------------
Listed and described below is the software provided in this release.


                                 Programs
                                 ........

  - Pre2Src	- Converts pre-assembled files into readable source code.
  - ProHunk	- 680x0/688xx Hunk Analyser.
  - Profiler	- Small run-time statistics utility.
  - MMUInfo	- MMU information utility.
  - StripD	- Strips debugging symbols/information from an object file.
  - CLICalc	- CLI calculator.
  - FCalc	- CLI IEEE double precision calculator.
  - FCmp	- File compare utility.
  - Bin2DC	- Converts binary data files into assembler source using the DC.x directive.
  - FD2LVO	- Converts fd files to _LVO equate files.
  - BDiff	- Small binary file compare program.
  - UnBDiff	- Small binary un-diff.
  - Blink	- Replacement linker from 'The Software Distillery'.


                               Source Codes
                               ............
  - Pro68       - Shell-ASX Interface
  - crypt	- Small encryption program
  - perfmon	- Performance monitor
  - cxchange	- Controls system commodities
  - ...
 






                                 Routines
                                 --------
Routine  files  are  a library of useful routines that provide a simple and
time  saving  method  for  assembly  programming.  Special macros have been
designed  that  ensure  that  only the called routines get assembled.  This
makes the routine files a good foundation for assembly programming.

  - alert.r		- Alert support routines.
  - amigaguide.r	- AmigaGuide support routines.
  - amigaguideasync.r	- Asynchroneous AmigaGuide support.
  - AppIcon.r		- Routines for Workbench 2.0's appicon support.
  - ARexx.r		- For ARexx support.
  - ASLSupport.r	- For support of the ASL file requester.
  - basicmac.r		- Macros for selective routines assembly.
  - commodity.r		- Contains routines for commodity support.
  - configfile.r	- Configuration file support routines.
  - conio.r		- Routines for console window input/output.
  - conoc.r		- Single console window open/close routines.
  - conread.r		- Read routines for the console window.
  - conreadpkt.r	- Read routines for the console window using packets.
  - CRC16.r		- Routines to calculate an Ansi CRC16 checksum.
  - DiskObjectSupport.r	- DiskObject support routines.
  - dosfile.r		- Contains DOS file handling routines.
  - doslib.r		- DOS library open and close routines.
  - easylibrary.r	- Routines to open and close libraries simple.
  - extmsg.r		- External message support routines.
  - GadgetGroupSupport.r - GadgetGroup support routines for use with GTFace.
  - graphicslib.r	- Graphics library open and close routines.
  - gtface.r		- Window handling and gadtools interface routines.
  - gtfdefs.r		- Definitions for GTFace.
  - gtfguido.r		- GUI macros for GTFace.
  - gtfmacros.r		- Macros for GTFace (gadgets and menus).
  - gtfsupport.r	- Various GTFace support routines.
  - gtfsupport_reb.r	- More GTFace support routines
  - gtfxdefs.r		- External definitions for GTFace.
  - intuitionlib.r	- Intuition open and close routines.
  - IntuitionSupport.r	- Routines for the intuition BusyPointer.
  - locale.r		- Support routines for locale (locale.library).
  - locks.r		- Routines for locks, files, and directories.
  - memory.r		- Memory handling routines.
  - numbers.r		- Various routines for number conversion.
  - numbers.mac		- String to number macros.
  - packets.r		- DOS packet handling routines.
  - paraliner.r		- UNIX like parameter line parser.
  - parse.r		- Routines for text parsing.
  - patch.r		- Library function patch routines.
  - ports.r		- Contains ports, signal, and message handling
                          routines.
  - progressbars.r	- Routines to handle progress bars easily.
  - qsort.r		- Quicksort sorting algorithm.
  - readargs.r		- Interface routines to ReadArgs().
  - readrexx.r		- Routines for a passive ARexx port.
  - requester.r		- ASL and REQ file requester routine.
  - reset.r		- Software reboot routine.
  - script.r		- Routines to deal with batches.
  - scrollbars.r	- GTFace appendum for horiz./vert. scrollbars.
  - shortcut.r		- Routine to wait for a shortcut.
  - startup4.r		- Enhanced CLI and Workbench startup code
                          (with detach).
  - string.r		- String support routines.
  - stringmacros.r	- String support macros.
  - structs.r		- Macros for various structures.
  - support.mac		- Support macros.
  - tasks.r		- Some little routines for tasks.
  - tasktricks.r	- More routines for tasks.
  - tooltypes.r		- Routines to get ToolTypes from a Workbench started
                          program.
  - ToolTypeSupport.r	- ToolType support routines.
  - TypeOfProcessor.r	- Contains routine to determine installed processor and coprocessors.






                               Documentation
                               -------------
You find the complete online documentation in the Help/ and the Help/english/
directory of this distribution.

A printed version of the manual with about 320 pages will be available
as soon as possible.

Read the registration.doc or the registration part in the pro.guide file
for further information about registration and the shareware limitation.






                                  Author
                                  ------
If   you   have   bugreports,   questions,   ideas,  flames  or  complaints
(constructive  criticism is always welcome), or if you just want to contact
me, write or send a letter to:


                        Daniel Weber

        Internet:       dweber@amiga.icu.net.ch   (preferred)
                        dweber@iiic.ethz.ch

        Mail:           Daniel Weber
                        Hoeflistrasse 32
                        CH-8135 Langnau
                        Switzerland.



