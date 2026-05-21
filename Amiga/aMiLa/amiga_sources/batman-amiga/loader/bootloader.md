# Boot Loader

              
Overview:


       1) Initialises the System, and Resets Disk Registers

       2) Relocates itself to address $400
  
       3) Loads track 0 into memory at $800 to get file table
               a) The Filetable is located at $c00
                    - Entry 1 = 16 bytes Disk Name
                    - Entry 2 - 13 = File Entries (11 char name, 3 byte length, 2 byte start sector)
                       00000C00 4241 544D 414E 204D 4F56 4945 2020 2030  BATMAN MOVIE   0
                       00000C10 4241 544D 414E 2020 2020 2000 22DA 0016  BATMAN     ."...
                       00000C20 4C4F 4144 494E 4720 4946 4600 A0D6 0028  LOADING IFF....(
                       00000C30 5041 4E45 4C20 2020 4946 4600 289E 0079  PANEL   IFF.(..y
                       00000C40 5449 544C 4550 5247 4946 4601 63A0 008E  TITLEPRGIFF.c...
                       00000C50 5449 544C 4550 4943 4946 4600 CCF6 0140  TITLEPICIFF....@
                       00000C60 434F 4445 3120 2020 4946 4600 37BE 01A7  CODE1   IFF.7...
                       00000C70 4D41 5047 5220 2020 4946 4600 5620 01C3  MAPGR   IFF.V ..
                       00000C80 434F 4445 3520 2020 4946 4600 3A86 01EF  CODE5   IFF.:...
                       00000C90 4D41 5047 5232 2020 4946 4600 530C 020D  MAPGR2  IFF.S...
                       00000CA0 4241 5453 5052 3120 4946 4600 C4B6 0237  BATSPR1 IFF....7
                       00000CB0 4348 454D 2020 2020 4946 4600 F6C6 029A  CHEM    IFF.....
                       00000CC0 4348 5552 4348 2020 4946 4600 D904 0316  CHURCH  IFF.....

       4) The main game loader 'BATMAN' is then located from the table and loaded to $800

       5) The file start address is pushed to the stack so RTS continues execution of 'BATMAN' game loader



