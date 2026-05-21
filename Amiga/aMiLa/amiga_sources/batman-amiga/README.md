# Batman The Movie - Amiga A500
![Batman the Movie](/images/batman.jpeg)<br/>
[Batman The Movie, Amiga, 2 Disk Europe, Ocean](https://www.lemonamiga.com/games/details.php?id=131)

 - [Overview](#overview)
 - [Resources and Acknowledgements](#resources-and-acknowledgements)
 - [Progress to date](#progress-to-date)

This repo contains my progress of the disassembling of the 2 Disk version of Batman The Movie for the Amiga. Parts of the game can be reassembled an executed using VSCode and the Amiga Assembly plugin. 
**All Game Levels can be built and played from the Source Code using VSCode.**
There are a couple of minor bugs such as the Music & SFX to fix for the Batmobile/Batwing Level.

## Main Code Projects
The folder names for the projects below reflect the file names of the executables held on the original disks.
 - [Level 1 (Axis Chemicals) Code Project](./gamesource/code1)
<br/>![Axis Chemicals - Level 1](/images/axischemicals.jpeg)
 - [Level 2 (Batmobile/Batwing) Code Project](./gamesource/code)
<br/>![Batmobile - Level 2](/images/batmobile.jpeg)
 - [Level 3 (BatCave) Code Project](./gamesource/batcave)
<br/>![Batmobile - Level 3](/images/batcave.jpeg)
 - [Level 4 (Batmobile/Batwing) Code Project](./gamesource/code/)
<br/>![Batwing - Level 4](/images/batwing.jpeg)
 - [Level 5 (Cathedral) Code Project](./gamesource/code5)
<br/>![Cathedral - Level 5](/images/cathedral.jpeg)

## Additional Code Projects
 - [Title Screen](./gamesource/titleprg)
<br/>![Title Screen](/images/titleprg.jpeg)
 - [Boot Block](./loader/bootblock)
<br/>![Boot Block](/images/bootblock.jpeg)
 - [Game Loader](./loader/gameloader/modified/src)
<br/>![Game Loader](/images/batmanloader.jpeg)  


## Overview
This exercise is not one of speed, but of learning. The intention is to understand how an iconic game for the Amiga was organised and put together. This repo contains many individual code projects organised into its sub folders. The steps followed to disassemble along with links to individual code projects (all contained within this single repository) are listed below.

 - Disassemble the boot loader. [Code Folder](./loader/bootblock/)
 - Disassemble the game loader. [Code Folder](./loader/gameloader/modified/)
 - Disassemble the Rob Northen Disk Protection. [Code Folder](./loader/gameloader/modified/)
 - Ripping the files from the disk. [Files Folder](./rawrippedfiles/) 
 - Unpack the ripped files. [Files Folder](./rawrippedfiles/)
   - [Disk 1 Unpacked](./rawrippedfiles/disk1files-unpacked/)
   - [Disk 2 Unpacked](./rawrippedfiles/disk2files-unpacked/)
   - [File Memory Map](./FileRelocation.md) - File Relocation/Load Table
 - Disassemble the Game Panel
    - ['panel' Project](./gamesource/panel/)
    - [Test .adf disk image](./crack/packedcrack/DosCrackShrinkler_rebuild.adf)
 - Disassemble the Title Screen.
    - ['titleprg' Project](./gamesource/titleprg)
    - The Title Screen code can be rebuilt from source and executed in VSCode
    - Updated Test ADF with Title Screen rebuilt from Source Code - [DosCrackShrinkler_rebuild.adf](./crack/packedcrack/DosCrackShrinkler_rebuild.adf) 
 - Disassemble the Platform Levels 1 and 5.
    - ['chem' Project](./gamesource/chem/) - Music & SFX for Level1 - Done with test program to play Music/SFX
    - ['church' Project](./gamesource/church/) - Music & SFX for Level 5
    - ['code1' Project](./gamesource/code1/) - Axis Chemicals - Level1 
    - ['code5' Project](./gamesource/code5/) - Cathedral - Level5
    - ['batspr1 Project](./gamesource/batspr1/) - Game Sprites - Level1/5
    - ['mapgr' Project](./gamesource/mapgr/) - Level GFX & Data - Level1
    - ['mapgr2' Project](./gamesource/mapgr2/) - Level GFX & Data - Level5
 - Disassemble the Batmobile/Batwing Levels.
    - ['music' Project](./gamesource/music) - Music & SFX for Level 2 & 4 (**TODO Music**)
    - ['data' Project](./gamesource/data) - Shared common data file for Levels 2 & 4
    - ['data2' Project](./gamesource/data2) - Level 2 specific data file.
    - ['data4' Project](./gamesource/data4) - Level 4 specific data file.
    - ['code' Project](./gamesource/code) - Shared code executable for Levels 2 & 4
 - Disassemble the BatCave Level.
    - ['batcave' Project](./gamesource/batcave) - Code, GFX and Music

## Resources and Acknowledgements
The inspiration for this exercise was discovering the following cracking series run by **h0ffman**. Links to those resources shown below.

 - [Youtube](https://www.youtube.com/@HoffmanYouTube)
 - [Twitch](https://www.twitch.tv/djh0ffman)
 - [GitHub](https://github.com/djh0ffman)

Resources and code used in this project is listed below. If there's anything used which hasn't been credited, please let me know. Also thanks to the TTE Crew member **JAYCEE_1980** who supplied a download link for the RNC disk code in the h0ffman twitch stream: Episode #16 Lemmings.

- [Batman 2 Disk Europe](https://www.lemonamiga.com/games/details.php?id=131) 
- [WinUAE](https://www.winuae.net/) - Windows Amiga Emulator
- [FS-UAE](https://fs-uae.net/) - Linux Amiga Emulator
- Action Reply MKIII - Emulator ROMS
- [VS Code](https://code.visualstudio.com/) 
   - Amiga Assembly Extension
- RNC DosIO - Low level disk code
- [Shrinkler](https://github.com/askeksa/Shrinkler) - file cruncher/decruncher
- [Salvador](https://github.com/emmanuel-marty/salvador) - zxo file cruncher/decruncher
- [XFDMaster](http://aminet.net/package/util/pack/xfdmaster) - utilities for depacking almost any packed file format.



## Progress to Date

**2025-04-01 - BATMAN** - The whole game has now been disassembled and reversed so that every level can be built and executed from within VSCode.  There are the following issues to correct.
  - Title Screen (minor bugs to fix)
  - Level 5 Cathedral (Music & SFX not fully working in game yet)

**2025-04-01 - Level 3** - The Level now builds and runs from within VSCode with music and SFX.

**2025-03-29 - Level 3** - The GFX Glitches are now fixed and the level is playable.

**2025-03-28 - Level 3** - The Batcave Level is now executing within VSCode, There is Graphics corruption on the sprites making it unplayable for the moment.

**2025-03-08 - Level 3** - Started disassembling Level 3, unlike other levels this is a single load containing the Code, GFX and Music.

**2025-03-05 - Level 2 & 4**
  - Both levels are now buildable and playable from VSCode, the music/SFX is currently switched off as there are bugs still to fix.
  - To build and run the **Batmobile** Level ensure **TEST_BATMOBILE** equate is uncommented (i.e. no semicolon prefix)
  - To build and run the **Batwing** Level ensure that **TEST_BATMOBILE** is commented out. (i.e. with semicolon prefix)

**2025-02-28 - Level 2 & 4** 
  - The Batwing Level is now building and looks like its running as expected with the balloons displaying as expected. 
    - The music is not currently working in game but does work when testing on its own. Something to put on back-burner...
  - The Batmobile Level is now building and runnable from within Visual Studio Code. 
    - There are no other cars displayed on the road presently, obviously something stillnot quite right but almost there...
    - The music is not currently working in game but does work when testing on its own. Something to put on back-burner...
  - Added an EQU to switch between running the Batmobile & Batwing levels from VS Code.
    - Added 60 minutes on test build timer.
    
**2025-02-14 - Level 5** - Finished disassembling the Church.IFF file containing the music && SFX for Level 5 and added it to the test build. Next job,back to fixing bugs in Level 2 & 4 (Batmobile & Batwing).

**2025-02-11 - Levels 2 & 4** - Finished disassembling the Music.IFF file containing the music & SFX for Levels 2 & 4. Included a test program to allow playback of the sounds. You can also cycle through the sounds using the left mouse button.

**2025-02-07 - Levels 2 & 4** - Started disassembling the music code for the levels. Still work in progress.

**2025-02-07 - Levels 2 & 4** - Fixed all assembler errors,can now build the 'code' executable for the level. Nextjob is to begin including the data files and start getting the executable to run from within VSCode.

**2025-02-04 - Levels 2 & 4** - Added dumped data file projects that build to identical binary files for the BatMobile and BatWing stages. Also started on the development of some dumping, comparison and data conversion command line tool (not in github yet) which will help with future disassembly projects.

**2025-01-31 - Level 5** is now building from sourcecode, it hasn't been fully annotated (like code1.s) there are small differences in the code when compared with Level 1 (code1.s). I have played the level to the end successfully. Also, I'm using the music & SFX from level 1 as I haven't disassembled the music for Level 5 yet. I seems to work fine. 

 - [Test Build 31/01/2025](https://youtu.be/M6ibUszYYFk?si=_sq6yLV624n-uXKP)



**2025-01-26 - Level 5** - Disassembled the code for Level 5 ( Cathedral ), There are some differences in the code compared to Level 1. Some bugs remain in the enemy actor code. Work in progress.

**2025-01-17 - Level 5** - Started disassembling the code for Level 5 (Church - code5.s), the code looks almost identical to the Level 1 (Axis Chemicals - code1.s) code so far, some small differences.

**2025-01-16 - Level 1** is now assembling and can be played to the end.

 - [Test Build 05 - 16/01/2025](https://youtu.be/pkMAV1ocsOs)

Began disassembling Level 5 (Church), code5.iff. It is based on an almost identical code base.

**2025-01-04 - Level 1** - Have now debugged the scrolling, projectiles and player movement routines. The bad guy enemy routines are still buggy and causing some corruption. I've uploaded the latest video on Youtube at the following link.
 - [Test Build 04 - 04/01/2025](https://youtu.be/PPE2NbVPY78)

**2024-12-31 - Level 1** - The latest video of the Level 1 build and the Batman character being controlled, walking around the level.  Next job is to debug all of the player controls.

 - [YouTube Video](https://youtu.be/vJdWEZv0IVE)

**2024-12-30 - Level 1** - It's been a while, but that doesn't mean that I haven't been chipping away at this project in what little spare time I get. I've now disassembled large parts of the Level 1 code (Filename code1.s) and started to make a debug/test build in the project source. It successfully assembles, the level starts, playes the music and allows the player to walk around in a limited fashion. Lots left to debug to get it working properly.

 - Link to the [Test Build Project](./gamesource/code1/) 
 - Link to [YouTube Video](https://youtu.be/o6xnDrrz1gY) 

**2024-08-13 - Level 1** - Added test program to the 'chem' project which plays the level 1 music. [Project Link](./gamesource/chem/) - Left mouse button to cycle through music/sfx.

**2024-08-03 - Disk Image** - Rebuilt the test ADF image using the rebuilt batspr.shrunk and mapgr.shrunk files which were rebuilt from the source data. So this disk image now contains a rebuilt titleprg.shrunk, batspr1.shrunk and mapgr.shrunk files. [DosCrackShrinkler_rebuild.adf](./crack/packedcrack/DosCrackShrinkler_rebuild.adf) - give it a go ( works on my machine **:)** )

**2024-08-03 - Level 1** - Added raw data project for batspr1.iff, this file is data only. Need to get around to adding a test GFX viewer to the project in the furure.

**2024-08-03 - Level 1** - Added raw data project for mapgr.iff, this file is data only. Need to get around to adding a test GFX viewer to the project in the future.

**2024-08-01 - Level 1** - Have been disassmbling the 'code1' program for the level 1 of the game, have formatted the code enough to enable the code to assemble without error. There are a couple of code warnings remaining, I've also noticed some self modifying code contained with the program :-( [VSCode Project Link](./gamesource/code1/)

**2024-07-25 - Title Screen** - Successfully rebuilt the TitleScreen program from source code and added to test .adf disk image [DosCrackShrinkler_rebuild.adf](./crack/packedcrack/DosCrackShrinkler_rebuild.adf) - give it a go ( works on my machine **:)** )

**2024-07-20 - Level 1** - Started disassembling 'code1', the code for level 1 (Axis Chemicals). Began formatting the code, first steps to try to get the code to assemble without errors. Made a start but still much to do.

**2024-07-19 - Progress to Date**
  - Disassembled Game Source
      - Panel (Energy Panel, Lives, Scores etc) - Disassembled - [VSCode Project Link](./gamesource/panel/)
      - Title Screen - Disassembled - [VSCode Project Link](./gamesource/titleprg/)
      - Game Loader - Disassembled - [VSCode Project Link](./loader/gameloader/modified/) (tvd patched & decoded)
      - Boot Loader - Disassembled - [VSCode Project Link](./loader/bootblock/)

  - New Source
      - Custom Loader - MFM DOS Loader for ripped files - [VSCode Project Link](./crack/newloader/src)

  - ADF Test Disks
      - Single Disk Version (Shrinkler) - [Single Disk ADF](./crack/packedcrack/DosCrackShrinkler.adf)
      - Single Disk Version (Shrinkler) - Parts Rebuild from Source [Single Disk ADF](./crack/packedcrack/DosCrackShrinkler_rebuild.adf)

**2024-07-19 - Title Screen** - The title screen in now disassembled and can be reassembled and executed in vscode from the project code [titleprg](./gamesource/titleprg/)

**2024-07-14 - Title Screen** - Can reassemble and run the title screen in test, without gfx loaded. Music player has a fault. The title music drum track is not right, also vocals not playing correctly. It runs without crashing.

**2024-07-10 - Title Screen** - Been away for the weekend, now back and can re-assemble the title screen and execute it (without GFX or music playing). The GFX is missing as these are loaded into memory separately (to get the GFX will require a custom build of the title screen).  The music is not currently playing and is causing an exception to be thrown during the do_play_song routine which is called to play the current song during each VBL interrupt (level 3).  Will have to do a bit of tracing to find out whats going wrong (it's either some bad code disassembly or bad song data I guess).

**2024-07-03 - Title Screen** - Have disassembled the code to the game 'titleprg' (title screen code & music). The code assembles without error and is 90% documented, there are areas of the music format that are still to be uncovered. Also I haven't yet tested the re-assembled version of the title screen code.

**2024-06-05 - Game Panel** - Have disassembled the code to the game 'panel' file. I can now re-assemble the file and have tested it on the test .adf disk image here [DosCrackShrinkler_Rebuild.adf](./crack/packedcrack/DosCrackShrinkler_rebuild.adf)

**2024-06-03 - Game Panel** - First draft of the 'panel' program has been disassembled and can be reassembled in vscode. Some tidying up and splitting out into gfx includes required. Move on to the Title Screen next. Might gain a bit more insight into the VBL interrupts and timings there. 

**2024-05-30 - Game Panel** - Been disassembling the 'Panel' executable that is loaded to $7Cf7C in memory. It contains the gfx and code that manages the game status panel including keeping track of the player lives, energy, level count down timer. Looking for hints for why the 'cracked' version of the game speeds up on level 2 and beyond.  Can see that a level 3 vertical blank interrupt calls the 'update' routine every frame. At the moment it appear that this routine is being called more frequently in my version of the re-complied ADF images for level 2 and beyond. Will keep searching... probably wont find out why until I disassemble the level code and see exectly where the level 3 interrupt is raised in the game code (apart from by the vbl).

**2024-05-24 - Disk Image** - Created a zx0 version of the disk, it's not working perfoectly yet, I think the compressed files are larger, causing corruption/memory overwriting on loading. Also the game timer is speeding up when loading level 2 and above, 1 minute is taking about 50 seconds. It looks like the level 3 interrupt is being called 60 times a second(ish) instead of 50 times a second. The music and game is also running noticably faster. When returning to the title screen, the music is playing faster. Once this is sorted the game should be working on A500 and I can move on to disassembling other parts of the game.

**2024-05-24 - Disk Image** - Obtained source and built 'salvador' zx0 packer/unpacker tool and link to the depacker source code from git hub (see links above). Have packed ripped files with tool and added files to source control.

**2024-05-23 - Disk Image** - Created an Amiga DOS disk that can be played and completed, very slow loading times due to decompression (which needs to be fixed). Its a learning exercise and I'm learning loads. I think the clock timer is running too fast (also the music on the title screen), so I think the game timers aren't set quite right at the moment. Also affects game play of levels 2 & 4 which are very tight on the time limits. This needs to be looked at and fixed.

**2024-05-22 - Disk Image** - Been testing the game and have completed the cracked version. It showed the game-over screen instead of the completion screen. Also had an
intermittent crash on level 5. I've updated the new loader, so that it sets the original copy protection serial into the exception vectors.
May also need to insert other copy protection data into memory, will test when I have the time.

**2024-05-21 - Disk Image** - Noticed that Level 5 is crashing/corrupt when navigating through the level. Will have to double check the ripped data for this level, also see if there are any copy protection checksums happening during the level to cause the issue. (Also, you can get infinite energy by patching 3 NOPs into location $7fA76 when playing the game, using action replay, WIN UAE debugger, etc)

**2024-05-21 - Disk Image** - Created first verison of a single disk crack. The ADF can be found here [packedfiles.adf](./crack/packedcrack/packedfiles.adf). The load time is far too slow due to the packer used (shrinkler). Need to find a packer with a faster decruncher which still has a decent pack ratio.

**2024-05-20 - Disk Image** - Successfully created a test crack disk that boots the title screen and first level of the game from an Amiga DOS disk. [TestCrack.adf](./crack/testcrack.adf)

**2024-05-17 - Disk Image** - Created a test disk image [testcrack.adf](./crack/testcrack.adf) which can load the and start the *Title Screen* from the Amiga DOS formatted disk. The game will crash if you try to start it as theres no code to load the levels etc. *Ive borked the test loader, try running on emulator with plenty of memory, think its got stack corruption at the moment*

**2024-05-17 - Disk Image** - Created simple loader using RNC DosIO to load title screen from the ripped files.

**2024-05-17 - Disk Image** - Added RNC disk code tools which I intend to use to re-create a loader for the game.

**2024-05-15 - Disk Image** - Unpacked the ripped files and added them to source control and also as unpacked Amiga DOS format ADF files.

**2024-05-14 - File Ripping** - Completed quite a few tasks on the main game loader:-
 - Completed first draft of documenting the gameloader.s code [BATMAN Loader](./loader/gameloader/modified/src/gameloader.s)
 - Added a set of ripped raw files to the rawrippedfiles source directory [Ripped Files](./rawrippedfiles/)
     - Disk 1 raw ripped files [Disk1 Files](./rawrippedfiles/disk1files/)
     - Disk 2 raw ripped files [Disk2 Files](./rawrippedfiles/disk2files/)

**2024-04-26 - Game Loader** - Commented lots of the main game loader, still some of the copy protection left to comment [BATMAN Loader](./loader/gameloader/modified/src/gameloader.s).

**2024-04-09 - Game Loader** - Began adding the disassembly of the main game loader, the "BATMAN" file from disk 1.

**2024-04-07 - BootBlock** - Completed first draft of documenting the [bootblock.s](./loader/bootblock/bootblock.s) code. 

**2024-04-05 - BootBlock** - Almost finished documenting the Bootblock code (which builds in VSCode using the Amiga Assembly plug-in)

**2024-03-28 - File Ripping** - Uploaded ripped files on ADFs, Ripped files are 'IFF' files that are further processed/decrunched by the loader before relocated into memory. All files appear to have IFF headers apart from the the music file(s), not sure what format these are yet.

**2024-03-27 - File Ripping** - I have ripped the raw files from both disks, need to upload to the repo.

**2024-03-26 - File Ripping** - Up to this point I have successfully ripped the game loader, documented it and modified it sufficently to get the game to boot without the copy protection kicking in. I've decoded and disassembled the Rob Northen protection and spent some time understanding how it works. I need to upload these files to this repo.

**2024-03-25 - Copy Protection** - Spent quite a while stepping through and documenting the GameLoader (docs yet to be uploaded), also decoding the copy protection routines (early Rob Northen) trace vector decoder (again, docs to be uploaded)
