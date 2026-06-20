# Game Loader
The game loader file is loaded by the bootblock.s into memory from $800 to $3400, 
The loader loads in 2 tracks of data from the disk, mfm decodes them at this address.

The file on disk is called "BATMAN" and can be seen as the first entry in the file table on disk 1 
(located on sector 2 on track 0).



 - Entry 1 = 16 bytes Disk Name
 - Entry 2 - 13 = File Entries (11 char name, 3 byte length, 2 byte start sector)

## Disk 1 - File Table
                     000030D6 4241 544D 414E 204D 4F56 4945 2020 2030  BATMAN MOVIE   0
                     000030E6 4241 544D 414E 2020 2020 2000 22DA 0016  BATMAN     ."...
                     000030F6 4C4F 4144 494E 4720 4946 4600 A0D6 0028  LOADING IFF....(
                     00003106 5041 4E45 4C20 2020 4946 4600 289E 0079  PANEL   IFF.(..y
                     00003116 5449 544C 4550 5247 4946 4601 63A0 008E  TITLEPRGIFF.c...
                     00003126 5449 544C 4550 4943 4946 4600 CCF6 0140  TITLEPICIFF....@
                     00003136 434F 4445 3120 2020 4946 4600 37BE 01A7  CODE1   IFF.7...
                     00003146 4D41 5047 5220 2020 4946 4600 5620 01C3  MAPGR   IFF.V ..
                     00003156 434F 4445 3520 2020 4946 4600 3A86 01EF  CODE5   IFF.:...
                     00003166 4D41 5047 5232 2020 4946 4600 530C 020D  MAPGR2  IFF.S...
                     00003176 4241 5453 5052 3120 4946 4600 C4B6 0237  BATSPR1 IFF....7
                     00003186 4348 454D 2020 2020 4946 4600 F6C6 029A  CHEM    IFF.....
                     00003196 4348 5552 4348 2020 4946 4600 D904 0316  CHURCH  IFF.....


## Disk 2 - File Table
                     000030D6 4241 544D 414E 204D 4F56 4945 2020 2031  BATMAN MOVIE   1
                     000030E6 4241 5443 4156 4520 4946 4600 F8B2 0016  BATCAVE IFF.....
                     000030F6 434F 4445 2020 2020 4946 4600 57A4 0093  CODE    IFF.W...
                     00003106 4441 5441 2020 2020 4946 4600 4E5A 00BF  DATA    IFF.NZ..
                     00003116 4441 5441 3220 2020 4946 4601 131C 00E7  DATA2   IFF.....
                     00003126 4441 5441 3420 2020 4946 4601 38F2 0171  DATA4   IFF.8..q
                     00003136 4D55 5349 4320 2020 4946 4601 3691 020E  MUSIC   IFF.6...





From the second entry on line 00000C10 - the file starts at:-
 - Disk 1
 - Sector 0x16
   - 0x16 = 22, so 11 sectors per track, this is the start of track 2 (bottom side, cylinder 1) 
 - Length 0x22DA
   - 0x22DA = 8922 bytes = 8Kb
  
The boot loader actually loads two full disk tracks with a length of 0x1600 * 2 = 0x2c00
 - 0x2c00 = 11264 bytes = 11Kb

So the memory space used by the game loader when loading is 11Kb.

The bootblock remains in memory, having been located to $40E by itself previously, execution continues at $800 on completion of the bootblock.

By the time the game loader started executing memory is used from $40E - $3400 by the loader code.




## Files
 - The Ripped "BATMAN" loader binary can be found here.
    - (Not uploaded yet)
 - The Disassembled "BATMAN.s" loader code can be found here.
    - (Not uploaded yet)
 - The Disassembled "BATMAN.s" loader with a decoded rob northen protection code can be found here.
    - (Not uploaded yet)
  
    

   
