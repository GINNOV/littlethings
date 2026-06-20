/*
 * Copyright (c) 1992 Commodore-Amiga, Inc.
 * 
 * This example is provided in electronic form by Commodore-Amiga, Inc. for 
 * use with the "Amiga ROM Kernel Reference Manual: Devices", 3rd Edition, 
 * published by Addison-Wesley (ISBN 0-201-56775-X).
 * 
 * The "Amiga ROM Kernel Reference Manual: Devices" contains additional 
 * information on the correct usage of the techniques and operating system 
 * functions presented in these examples.  The source and executable code 
 * of these examples may only be distributed in free electronic form, via 
 * bulletin board or as part of a fully non-commercial and freely 
 * redistributable diskette.  Both the source and executable code (including 
 * comments) must be included, without modification, in any copy.  This 
 * example may not be published in printed form or distributed with any
 * commercial product.  However, the programming techniques and support
 * routines set forth in these examples may be used in the development
 * of original executable software products for Commodore Amiga computers.
 * 
 * All other rights reserved.
 * 
 * This example is provided "as-is" and is subject to change; no
 * warranties are made.  All use is at your own risk. No liability or
 * responsibility is assumed.
 *
 *****************************************************************************
 *
 *
 * Track_Copy.c
 *
 * This program does a track by track copy from one drive to another
 *
 * Compile with SAS C 5.10  LC -cfist -ms -v -L
 *
 * This program will only run from the CLI.  If started from
 * the Workbench, it will just exit...
 *
 * Usage:  Track_Copy  dfx dfy
 */


#include <exec/types.h>
#include <exec/memory.h>
#include <devices/trackdisk.h>
#include <dos/dosextens.h> */

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/dos_protos.h>

#include <stdio.h>
#include <string.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }     /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

#define	TRACK_SIZE	((LONG)(NUMSECS * TD_SECTOR))
/*
 * Turn the BUSY flag off/on for the drive
 * If onflag is TRUE, the disk will be marked as busy...
 *
 * This is to stop the validator from executing while
 * we are playing with the disks.
 */
VOID disk_busy(UBYTE *drive,LONG onflag)
{
struct StandardPacket *pk;
struct Process        *tsk;

    tsk=(struct Process *)FindTask(NULL);
    if (pk=AllocMem(sizeof(struct StandardPacket),MEMF_PUBLIC|MEMF_CLEAR))
    {
        pk->sp_Msg.mn_Node.ln_Name=(UBYTE *)&(pk->sp_Pkt);

        pk->sp_Pkt.dp_Link=&(pk->sp_Msg);
        pk->sp_Pkt.dp_Port=&(tsk->pr_MsgPort);
        pk->sp_Pkt.dp_Type=ACTION_INHIBIT;
        pk->sp_Pkt.dp_Arg1=(onflag ? -1L : 0L);

        PutMsg(DeviceProc(drive),(struct Message *)pk);
        WaitPort(&(tsk->pr_MsgPort));
        GetMsg(&(tsk->pr_MsgPort));
        FreeMem(pk,(long)sizeof(*pk));
    }
}

/*
 * This turns the motor off
 */
VOID Motor_Off(struct IOExtTD *disk)
{
    disk->iotd_Req.io_Length=0;
    disk->iotd_Req.io_Command=TD_MOTOR;
    DoIO((struct IORequest *)disk);
}

/*
 * This turns the motor on
 */
VOID	Motor_On(struct IOExtTD *disk)
{
    disk->iotd_Req.io_Length=1;
    disk->iotd_Req.io_Command=TD_MOTOR;
    DoIO((struct IORequest *)disk);
}

/*
 * This reads a track, reporting any errors...
 */
SHORT Read_Track(struct IOExtTD *disk,UBYTE *buffer,SHORT track)
{
SHORT All_OK=TRUE;

    disk->iotd_Req.io_Length=TRACK_SIZE;
    disk->iotd_Req.io_Data=(APTR)buffer;
    disk->iotd_Req.io_Command=CMD_READ;
    disk->iotd_Req.io_Offset=(ULONG)(TRACK_SIZE * track);
    DoIO((struct IORequest *)disk);
    if (disk->iotd_Req.io_Error)
    {
        All_OK=FALSE;
        printf("Error %u when reading track %d",disk->iotd_Req.io_Error,track);
    }
    return(All_OK);
}

/*
 * This writes a track, reporting any errors...
 */
SHORT Write_Track(struct IOExtTD *disk,UBYTE *buffer,SHORT track)
{
SHORT All_OK=TRUE;

    disk->iotd_Req.io_Length=TRACK_SIZE;
    disk->iotd_Req.io_Data=(APTR)buffer;
    disk->iotd_Req.io_Command=TD_FORMAT;
    disk->iotd_Req.io_Offset=(ULONG)(TRACK_SIZE * track);
    DoIO((struct IORequest *)disk);
    if (disk->iotd_Req.io_Error)
    {
        All_OK=FALSE;
        printf("Error %d when writing track %d",disk->iotd_Req.io_Error,track);
    }
    return(All_OK);
}

/*
 * This function finds the number of TRACKS on the device.
 * NOTE That this is TRACKS and not cylinders.  On a Two-Head
 * drive (such as the standard 3.5" drives) the number of tracks
 * is 160, 80 cylinders, 2-heads.
 */
SHORT FindNumTracks(struct IOExtTD *disk)
{
    disk->iotd_Req.io_Command=TD_GETNUMTRACKS;
    DoIO((struct IORequest *)disk);
    return((SHORT)disk->iotd_Req.io_Actual);
}

/*
 * This routine allocates the memory for one track and does
 * the copy loop.
 */
VOID Do_Copy(struct IOExtTD *diskreq0,struct IOExtTD *diskreq1)
{
UBYTE *buffer;
SHORT track;
SHORT All_OK;
SHORT NumTracks;

    if (buffer=AllocMem(TRACK_SIZE,MEMF_CHIP|MEMF_PUBLIC))
    {
        printf(" Starting Motors\r");
        Motor_On(diskreq0);
        Motor_On(diskreq1);
        All_OK=TRUE;

        NumTracks=FindNumTracks(diskreq0);

        for (track=0;(track<NumTracks) && All_OK;track++)
        {
            printf(" Reading track %d\r",track);

            if (All_OK=Read_Track(diskreq0,buffer,track))
            {
                printf(" Writing track %d\r",track);

                All_OK=Write_Track(diskreq1,buffer,track);
            }
        }
        if (All_OK) printf(" * Copy complete *");
        printf("\n");
        Motor_Off(diskreq0);
        Motor_Off(diskreq1);
        FreeMem(buffer,TRACK_SIZE);
    }
    else printf("No memory for track buffer...\n");
}

/*
 * Prompts the user to remove one of the disks.
 * Since this program makes an EXACT copy of the disks
 * AmigaDOS would get confused by them so one must be removed
 * before the validator is let loose.  Also, note that the
 * disks may NEVER be in drives on the SAME computer at the
 * SAME time unless one of the disks is renamed.  This is due
 * to a bug in the system.  It would normally be prevented
 * by a diskcopy program that knew the disk format and modified
 * the creation date by one clock-tick such that the disks would
 * be different.
 */
VOID Remove_Disks(VOID)
{
    printf("\nYou *MUST* remove at least one of the disks now.\n");
    printf("\nPress RETURN when ready\n");
    while(getchar()!='\n');
}

/*
 * Prompts the user to insert the disks.
 */
VOID Insert_Disks(char drive1[], char drive2[])
{
    printf("\nPlease insert source disk in %s\n",drive1);
    printf("\n          and destination in %s\n",drive2);
    printf("\nPress RETURN when ready\n");
    while(getchar()!='\n');
}

/*
 * Open the devices and mark them as busy
 */
VOID Do_OpenDevice(struct IOExtTD *diskreq0,struct IOExtTD *diskreq1, long unit[])
{
char drive1[] = "DFx:";  /* String for source drive */
char drive2[] = "DFx:";  /* String for destination drive */

    drive1[2] = unit[0]+ '0';  /* Set drive number for source */

    if (!OpenDevice(TD_NAME,unit[0],(struct IORequest *)diskreq0,0L))
    {


          disk_busy(drive1,TRUE);

          drive2[2] = unit[1]+ '0';  /* Set drive number for destination */

        if (!OpenDevice(TD_NAME,unit[1],(struct IORequest *)diskreq1,0L))
        {


            disk_busy(drive2,TRUE);

            Insert_Disks(drive1,drive2);
            Do_Copy(diskreq0,diskreq1);
            Remove_Disks();

            disk_busy(drive2,FALSE);
            CloseDevice((struct IORequest *)diskreq1);
        }
        else printf("Could not open %s\n",drive2);

        disk_busy(drive1,FALSE);
        CloseDevice((struct IORequest *)diskreq0);
    }
    else printf("Could not open %s\n",drive1);
}


SHORT ParseArgs(int argc, char **argv, long Unit[])

#define OKAY 1

{
int j=1, params = OKAY;
char *position[]={"First","Second"};

if (argc != 3)
    {
    printf("\nYou must specify a source and destination disk\n");
    return(!OKAY);
    }
else if (strcmp(argv[1],argv[2]) == 0)
         {
         printf("\nYou must specify different disks for source and destination\n");
         return(!OKAY);
         }
     else while (params == OKAY && j<3)
               {
               if (strnicmp(argv[j],"df",2)==0)
                   {
                   if (argv[j][2] >= '0' && argv[j][2] <= '3' && argv[j][3] == '\0')
                       {
                       Unit[j-1] = argv[j][2] - 0x30;
                       }
                   else
                       {
                       printf("\n%s parameter is wrong, unit number must be 0-3\n",position[j-1]);
                       params = !OKAY;
                       return(!OKAY);
                       }
                   }
               else
                   {
                   printf("\n%s parameter is wrong, you must specify a floppy device df0 - df3\n",position[j-1]);
                   params=!OKAY;
                   return(!OKAY);
               }
               j++;
               }
return(OKAY);
}

VOID main(int argc,char **argv)
{
struct IOExtTD *diskreq0;
struct IOExtTD *diskreq1;
struct MsgPort *diskPort;
long unit[2];

    if (ParseArgs(argc, argv, unit))       /* Check inputs */
    {
        if (diskPort=CreatePort(NULL,NULL))
        {
            if (diskreq0=(struct IOExtTD *)CreateExtIO(diskPort,
                                                 sizeof(struct IOExtTD)))
            {
                if (diskreq1=(struct IOExtTD *)CreateExtIO(diskPort,
                                                 sizeof(struct IOExtTD)))
                {

                    Do_OpenDevice(diskreq0,diskreq1, unit);
                    DeleteExtIO((struct IORequest *)diskreq1);
                }
                else printf("Out of memory\n");
                DeleteExtIO((struct IORequest *)diskreq0);
            }
            else printf("Out of memory\n");
            DeletePort(diskPort);
        }
        else printf("Could not create diskReq port\n");
    }
}
