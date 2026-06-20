;Released to public. Version 0.22E
210194.834	Fixed Reset-entry stack problem.
240194.835	Fixed NMI-ROM parity.
270194.838	Added missing peeker functions.
      .840	HexEditor: BCPL functions moved to u/U
      	ASCII/Hex/Dis : p -> Peeker
      .842	Finished the editor fill function (only .b fill was made)
      .844	Added NOT-hunter.
280194.845	Added Height-control to peeker. Fixed bug in peeker.
      .846	Added NMIROM entry control.
      .847	Added Register display (Ctrl+HELP)
      .849	Added Snap Pasting on configurable key.
310194.850	Added PrefRevision# to preference header (to support GRDR)
      .851	Fixed keyboard table.
      .852	Keyboard now configurable (inserted marker)
      .853	Added ColdCapture Reset entry.
      .854	Fixed Reset-entry stackpointer.
      .857	Fixed System reset-entry. Now using CoolCapture for ZUP.
      .858	Added NMI-setter to ResetHandler.
010294.859	Forced PAL in copper. Fixed copper to run under AGA.
      .860	Fixed bug in CUS routine called at exit.
      .861	Added pal/ntsc command (changes mode at exit).
	Added pr_PALNTSC to prefs. Forces displaymode in GR.
      .862	Added support for Cold/Cool setting in GRDR.
      .863	Added KILL-flag to be used by cold!
	Fixed potential bug in the disassembler.
	ASCII-column in disassembler moved 16 chars right.
030294.864	Made exit displaymode reflect PAL/NTSC pref setting.
      .865	Default/Modified Prefs text at entry.
040294.866	CPU-text was not properly centered.
      .867	Made All diskroutines+resident stuff non-previewable.
060294.868	Made some changes to the cache routines.
080294.869	Added timeout on diskreads (if no SYNc->HANG)
	SYNC+tracklen init now on first entry.
      .870	Fixed RawReader+ Cleaned up init disk a bit.
      .871	Added DecodeMFM command.
040294..........Released to public. Version 0.32E.

050394.872	Fixed some dis/assembler bugs.
	Removed EntryCACR routine. This is done by CheckCPU.
      .874	Improved upwards disassembly.
      .877	Made disassembly a bit faster. 24/32 bit ctrl added to dised.

210394.880	Added monitor start address to exception printout.
230394.886	DisEditor works 90%.
	Improved Exception output. Added flag for internal NMI setting.
      .889	IRQ handling in GR now reduced to the first 48 vectors.
240394.891	Added DebugCounter and handler in VBlank. Use to find freezing
	routines.
      .892	Found the bug. A6 contents not specified in KeyIRQ... Stupid!
      .895	Fiddled some more with the upwards disassembly. Still not good
      	enough...
      .896	Added extern macrodefinitions of user names and #.
020494.897	Fixed BUS Error problem of AGA-generation machines.
040494.899	Found the bug causing lousy up-dis (Yesch!)
      .900	Peeker's vertical scrolling now width-relative.
      	Moved peeker-entry to 'p'.
      .902	Added 3xquick-jump to diseditor. Enabled C&F in diseditor.
050494.903	Improved BreakPoint handling. Now available from system.
	Historybuffer not cleared at entry.
080494.904	Fixed ODD-data access in DiskInfo.
090494.906	pc_CLRRest didn't clear last column. Fixed
	Added Edit-operation to the disassemble editor (REG only).
      .907	It is now possible to change register contents.
100494.908	Fixed bug in BreakPoint handler.
	Cursor is moved down after succesfull assembly in diseditor.
	Improved $Fxxx disassembly speed (checking bit 11=0)
	DisEditEdit input is now added to history.
230494.0910	Added some internal addresses for the System Interface
240494.0911	Improved CD command to UNIX-style. Also added to DIR.
270494.0912	Added path usage to load. Fixed a few things in DiskInfo.
290494.0913	Added ClearKeyboardMatrix to system entry.
020594.0914	Building delete and save file. Made saveblock del to 16bits.

030794.0917	Save and Delete still need to be finished but I want screen
	modes done first (coz' of my new monitor :-).
      .0917a	Added system display up'n'down when entering by the system.
           e	Now only displays GRPic on firstentry. Also changed ChipMem control
           f	Fixed o7o Error on '040 CPU.
           h	Added flag for clear screen at entry.
190794.0918	Fixed CACR bug at exit.
200794.0918t	Added screenmode control. 5 configurable structs in prefs.
           u	Bug in workmem handling fixed.
           v	Removed NiceScroll pref. Now all copper updates are made in vblank
      .0919a	Added cursor reposition on left mouse (only mainscreen)
           b	Added tabular indetion to editor (4 simple spaces)	
           d	Improved BusError handling. Now aborts operation (specific
           	handling for different functions possible).
           e	DefaultPrefs moved to BSS area. LibraryTable build in negative
	direction from BSSArea.
           f	Dis/Assembler now in binary library (5 secs faster assembly ~33%)
210794.0920l	Save command now finished.
220794.0920m	Save cmd unstable. Added precomp settings to fix
           p	Precomp no good :( Added correct diskside timings.
230794.0921	Now keyboard's handshake is timed with the CIA.
           b	Keyboard repeat is now timed with the CIA.
240794.0921d	Disk error texts now match trackdisk device error messages.
	Added sector header checksum checking.
           e	Save/load track cmds did not handle HD disks correct. Fixed
250794.0922	Load/Save now works 100% OK. (clock bit error in MFM encoder)
260794.0922e	Added cyl/sec display in header while accessing disk.
           f	R/W/S(eek) letter. (may seek while displaying prev track load)
           h	Both save&load now display progress.
270794.0922m	Save now correctly update a fileheader/cache if user breaks.
      .0923b	Moved TextArea so (b) references are possible.
           d	Format cmd completed.
           f	cls cmd changed to entry clear control.
280794.0923h	Fixed sp value bug.
           i	Now the ports list do not print taskname if no task.
           j	Now also diskroutines are in external library.
           l	Removed registration texts & IDs. Now a ShareWare program!
           m	Editors now nest CA at Offset jumps.
           n	If cop0 is not found at entry, it will not be set at exit!
           o	Both hunt and Fill now accept a single nibble as input.
           p	Improved Exec checker a bit (odd address check).
           q	Added automatic entry at reset if GURU.
           r	At reset exit, beamcon0 is set to PAL/NTSC native.
           	Also timer ticks are set according to P/N native display.
290794.0923t	Added some extra trashmem in the bottom of GR (app 66 bytes are fucked)
           u	Added watchdog timeout control
310794.0924	Added Commodore's CacheControl code.
      .0924a	Rewrote CheckCPU. Should work correct now. No more FPU ID though.
      	No more FPU text at entry.
030894.0924d	Added orgPC/Stack input to system entry.
           e	Fixed bug in SumExecBase.
040894.0924f	Fixed PAL line problem.
100894.0925d	Added ECS Super H-Res color control.
140894.0925k	Improved Work memory control. Possible to have STATIC workmem.

150894	* Released to public Version 1.0
