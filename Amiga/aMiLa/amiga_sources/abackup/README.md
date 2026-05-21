# ABackup

**Description**: ABackup is a program which allows you to backup data from your hard disk. It
can be used on any Amiga model, providing you have Kickstart V37 or  higher,
and at least 1 Mb of memory. 

ABackup has all the features you might expect from such a program: 

  - Both full and selective backup and restore operations  (you  can  select
    the files by name, by date, by protection bits, but also one by one) 

  - Backup to floppy disks, to partitions (for example a  SyQuest  cartrige)
    or to an archive  file.  Optional  data  compression,  data  encryption,
    verification, and archive bit setting. 

  - Restore to  any  directory,  with  or  without  restoring  the  original
    directory tree, and handling of already existing  files.  Optional  date
    and empty directories restore. 

  - Backup of non-AmigaDOS partitions (PC, Mac, UNIX, ...) 

  - Optional report file for all operations 

  - Full Intuition interface, AmigaGuide documentation. 

However, ABackup is not just one more  backup  program.  This  program  also
provides unusual features, like: 

  - Support for removable disks  (SyQuest,  Zip,  Jaz,  etc...),  which  are
    handled like floppy disks. 

  - Transparent support of High Density floppy disks. Cyclic utilisation  of
    several disks drives. Supports mixing of Double Density and High Density
    floppy disks. Transparent support of the "diskspare.device". 

  - Asynchronous writes for maximal backup speed 

  - Data compression can be performed by the "xpk.library"  or  an  external
    program. Automatic exclusion of files already compressed. 

  - Allows full operation automatization : you can,  for  example,  start  a
    backup just with a double-click over an icon. 

  - Lots of controls, in order to avoid data loss due to handling errors. 

  - Supports of the "MultiUserFileSystem" :  access  rights  and  owner  are
    automatically backed up. When restoring files to a  partition  which  is
    managed by this filesystem, theses informations  will  be  automatically
    restored.

  - **Technology stack**: C, SAS/C, ReqTools, XPK, MultiUser
  - **Status**:  [CHANGELOG](https://gitlab.com/amigasourcecodepreservation/abackup/blob/master/CHANGELOG.md).

**Screenshot**:

![TO-DO](TO-DO)


## Dependencies

* Amiga OS Classic
* ReqTools
* XPK
* MultiUser

## Installation

Build with SAS/C. No smake in the root folder as of yet. 


## Configuration

TO-DO

## Usage

See included amigaguide.

## How to test the software

TO-DO

## Known issues

TO-DO

## Getting help

If you have questions, concerns, bug reports, etc, please file an issue in this repository's Issue Tracker.

## Getting involved

Contact your old amiga friends and tell them about our project, and ask them to dig out their source code or floppies and send them to us for preservation.

Clean up our hosted archives, and make the source code buildable with standard compilers like devpac, asmone, gcc 2.9x/Beppo 6.x, sas/c ,vbcc and friends.


Cheers!

Twitter
https://twitter.com/AmigaSourcePres

Gitlab
https://gitlab.com/AmigaSourcePres

WWW
https://amigasourcepres.gitlab.io/

     _____ ___   _   __  __     _   __  __ ___ ___   _   
    |_   _| __| /_\ |  \/  |   /_\ |  \/  |_ _/ __| /_\  
      | | | _| / _ \| |\/| |  / _ \| |\/| || | (_ |/ _ \ 
     _|_| |___/_/ \_\_|_ |_|_/_/_\_\_|__|_|___\___/_/_\_\
    / __|/ _ \| | | | _ \/ __| __|  / __/ _ \|   \| __|  
    \__ \ (_) | |_| |   / (__| _|  | (_| (_) | |) | _|   
    |___/\___/_\___/|_|_\\___|___|__\___\___/|___/|___|_ 
    | _ \ _ \ __/ __| __| _ \ \ / /_\_   _|_ _/ _ \| \| |
    |  _/   / _|\__ \ _||   /\ V / _ \| |  | | (_) | .` |
    |_| |_|_\___|___/___|_|_\ \_/_/ \_\_| |___\___/|_|\_|

----

## Open source licensing info

ABackup is distributed under the terms of the GNU General Public License, version 2 or later. See the [LICENSE](https://gitlab.com/amigasourcecodepreservation/abackup/LICENSE.md) file for details.

----

## Credits and references

Many thanks to Denis Gounelle for releasing the source code under GPL.

