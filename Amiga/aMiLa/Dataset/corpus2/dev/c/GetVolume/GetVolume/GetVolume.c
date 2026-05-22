/* GetVolume.c 	-- Written  02/13/87 by Chuck McManis feel free to use it
 * 
 * This simple Program can be used to get the Volume name for a given file. 
 * Works on any device, even the RAM: device.
 *
 * Note: The BADDR macro is in the dos.h file
 */

#include <exec/types.h>
#include <libraries/dos.h>
#include <libraries/dosextens.h>
#include <stdio.h>

void main()

{
  char	VolumeName[40], FileName[80], *MyVolume;
  struct FileLock	*MyLock;


  printf("Enter a file name :");
  gets(FileName);

  /* Simultaneous get a lock and convert BPTR to a C pointer */
  MyLock = (struct FileLock *)BADDR(Lock(FileName,ACCESS_READ));
  if (MyLock == NULL) {
    printf("File could not be found!\n");
    exit(20); /* Die appropriately on failure */
    }
  /* This next statement chases the BCPL pointers thru a FileLock and    *
   * DeviceList structures						 */
  MyVolume = (char *)
       BADDR(((struct DeviceList *)BADDR(MyLock->fl_Volume))->dl_Name);
  /* Lattice V3.10 function to copy a string and Null terminate it */
  stccpy(VolumeName,MyVolume+1,MyVolume[0]+1);
  printf("That file resides on Volume '%s' \n",VolumeName);
  UnLock(((long)MyLock) >> 2);  /* You must UnLock or the GURU visits */
  exit(0);
}


