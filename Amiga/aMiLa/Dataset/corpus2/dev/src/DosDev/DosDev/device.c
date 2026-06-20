
/*
 *  DOSDEVICE.C 	V1.10	2 November 1987
 *
 *  EXAMPLE DOS DEVICE DRIVER FOR AZTEC.C   PUBLIC DOMAIN.
 *
 *  By Matthew Dillon.
 *
 *  Debugging routines are disabled by simply attempting to open the
 *  file "debugoff", turned on again with "debugon".  No prefix may be
 *  attached to these names (you must be CD'd to TEST:).
 *
 *  See Documentation for a detailed discussion.
 *
 *  BUGS:
 *	Currently the only known bug is with the implementation of the
 *	RAM disk itself.  Specifically, if filehandle A is at the end of
 *	the file, and somebody appends to the file with another filehandle,
 *	B, filehandle A will get confused as to it's current position in
 *	the file.
 *
 *	I am probably not updating all the right timestamps.  This is
 *	easy to fix... All you have to do is fool with the floppy and
 *	see which datestamps get updated for certain operations.
 */

#include "dos.h"

/*
 *  Since this code might be called several times in a row without being
 *  unloaded, you CANNOT ASSUME GLOBALS HAVE BEEN ZERO'D!!  This also goes
 *  for any global/static assignments that might be changed by running the
 *  code.
 */

PROC	*DosProc;   /*	Our Process				    */
DEVNODE *DosNode;   /*	Our DOS node.. created by DOS for us	    */
DEVLIST *DevList;   /*	Device List structure for our volume node   */

void	*SysBase;   /*	EXEC library base			*/
DOSLIB	*DOSBase;   /*	DOS library base for debug process	*/
RAMFILE RFRoot;     /*	Directory/File structure    (root node) */
LIST	FHBase;     /*	Open Files				*/
LIST	LCBase;     /*	Open Locks				*/

long	TotalBytes; /*	total bytes of data in filesystem	*/


		    /*	DEBUGGING			*/
PORT *Dbport;	    /*	owned by the debug process	*/
PORT *Dback;	    /*	owned by the DOS device driver	*/
short DBDisable;
MSG DummyMsg;	    /*	Dummy message that debug proc can use	*/

/*
 *  Don't call the entry point main().  This way, if you make a mistake
 *  with the compile options you'll get a link error.
 */

void
noname()
{
    register PACKET *packet;
    register short   error;
    MSG     *msg;
    ubyte   notdone;
    ubyte   buf[256];
    void    *tmp;

    /*
     *	Initialize all global variables.  SysBase MUST be initialized before
     *	we can make Exec calls.  AbsExecBase is a library symbol
     *	referencing absolute memory location 4.  The DOS library is openned
     *	for the debug process only.
     */

    DBDisable = 0;				/*  Init. globals	*/
    Dbport = Dback = NULL;
    TotalBytes = 0;
    SysBase = AbsExecBase;
    DOSBase = OpenLibrary("dos.library",0);
    DosProc = FindTask(NULL);
    {
	WaitPort(&DosProc->pr_MsgPort); 	/*  Get Startup Packet	*/
	msg = GetMsg(&DosProc->pr_MsgPort);
	packet = (PACKET *)msg->mn_Node.ln_Name;

	/*
	 *  Loading DosNode->dn_Task causes DOS *NOT* to startup a new
	 *  instance of the device driver for every reference.	E.G. if
	 *  you were writing a CON device you would want this field to
	 *  be NULL.
	 */

	if (DOSBase) {
	    DOSINFO *di = BTOC(((ROOTNODE *)DOSBase->dl_Root)->rn_Info);
	    register DEVLIST *dl = dosalloc(sizeof(DEVLIST));

	    DosNode = BTOC(packet->dp_Arg3);

	    /*
	     *	Create Volume node and add to the device list.	This will
	     *	cause the WORKBENCH to recognize us as a disk.	If we don't
	     *	create a Volume node, Wb will not recognize us.  However,
	     *	we are a RAM: disk, Volume node or not.
	     */

	    DevList = dl;
	    dl->dl_Type = DLT_VOLUME;
	    dl->dl_Task = &DosProc->pr_MsgPort;
	    dl->dl_DiskType = ID_DOS_DISK;
	    dl->dl_Name = (void *)DosNode->dn_Name;
	    dl->dl_Next = di->di_DevInfo;
	    di->di_DevInfo = (long)CTOB(dl);

	    /*
	     *	Set dn_Task field which tells DOS not to startup a new
	     *	process on every reference.
	     */

	    DosNode->dn_Task = &DosProc->pr_MsgPort;
	    packet->dp_Res1 = DOS_TRUE;
	    packet->dp_Res2 = 0;
	} else {			    /*	couldn't open dos.library   */
	    packet->dp_Res1 = DOS_FALSE;
	    returnpacket(packet);
	    return;			    /*	exit process		    */
	}
	returnpacket(packet);
    }

    /*
     *	Initialize debugging code
     */

    dbinit();	    /* this can be removed  */

    /*	Initialize  RAM disk	*/

    {
	ubyte *ptr = BTOC(DosNode->dn_Name);
	short len = *ptr;

	NewList(&FHBase);			    /*	more globals	*/
	NewList(&LCBase);
	bzero(&RFRoot,sizeof(RFRoot));
	RFRoot.type = FILE_DIR; 		    /*	root directory	*/
	DateStamp(&RFRoot.date);		    /*	datestamp	*/
	NewList(&RFRoot.list);			    /*	sub dirs	*/
	RFRoot.name = AllocMem(len+1, MEMF_PUBLIC); /*	Root NAME	*/
	bmov(ptr+1,RFRoot.name,len);
	RFRoot.name[len] = 0;
	dbprintf("ROOT NAME: %ld '%s'\n", len, RFRoot.name);
    }

    /*
     *	Here begins the endless loop, waiting for requests over our
     *	message port and executing them.  Since requests are sent over
     *	our message port, this precludes being able to call DOS functions
     *	ourselves (that is why the debugging routines are a separate process)
     */

top:
    for (notdone = 1; notdone;) {
	WaitPort(&DosProc->pr_MsgPort);
	while (msg = GetMsg(&DosProc->pr_MsgPort)) {
	    register ubyte *ptr;
	    packet = (PACKET *)msg->mn_Node.ln_Name;
	    packet->dp_Res1 = DOS_TRUE;
	    packet->dp_Res2 = 0;
	    error = 0;
	    dbprintf("Packet: %3ld %08lx %08lx %08lx %10s ",
		packet->dp_Type,
		packet->dp_Arg1, packet->dp_Arg2,
		packet->dp_Arg3,
		typetostr(packet->dp_Type)
	    );

	    switch(packet->dp_Type) {
	    case ACTION_DIE:	    /*	attempt to die? 		    */
		notdone = 0;	    /*	try to die			    */
		break;
	    case ACTION_OPENRW:     /*	FileHandle,Lock,Name	    Bool    */
	    case ACTION_OPENOLD:    /*	FileHandle,Lock,Name	    Bool    */
	    case ACTION_OPENNEW:    /*	FileHandle,Lock,Name	    Bool    */
		{
		    register RAMFILE *ramfile;
		    RAMFILE *parentdir = getlockfile(packet->dp_Arg2);
		    char    *ptr;

		    btos(packet->dp_Arg3,buf);
		    dbprintf("'%s' ", buf);
		    if (strcmp(buf,"debugoff") == 0)
			DBDisable = 1;
		    if (strcmp(buf,"debugon") == 0)
			DBDisable = 0;
		    if (ramfile = searchpath(&parentdir,buf,&ptr)) {
			if (ramfile->type == FILE_DIR) {
			    error = ERROR_OBJECT_WRONG_TYPE;
			    goto openbreak;
			}
			if (ramfile->locks < 0) {
			    error = ERROR_OBJECT_IN_USE;
			    goto openbreak;
			}
			if (packet->dp_Type == ACTION_OPENOLD) {
			    ++ramfile->locks;
			} else {
			    if (ramfile->locks > 0) {
				error = ERROR_OBJECT_IN_USE;
			    } else {
				if (packet->dp_Type == ACTION_OPENNEW) {
				    freedata(ramfile);
				    ramfile->protection = 0;
				}
				--ramfile->locks;
			    }
			}
		    } else {
			if (!parentdir) {
			    error = ERROR_INVALID_COMPONENT_NAME;
			    goto openbreak;
			}
			if (packet->dp_Type == ACTION_OPENNEW) {
			    ramfile = createramfile(parentdir, FILE_FILE, ptr);
			    --ramfile->locks;
			} else {
			    error = ERROR_OBJECT_NOT_FOUND;
			}
		    }
		    if (!error) {
			register MYFH *mfh = AllocMem(sizeof(MYFH), MEMF_PUBLIC|MEMF_CLEAR);
			((FH *)BTOC(packet->dp_Arg1))->fh_Arg1 = (long)mfh;
			mfh->file = ramfile;
			mfh->fentry = GetHead(&ramfile->list);
			AddHead(&FHBase,mfh);
		    }
		}
	      openbreak:
		if (!GetHead(&FHBase) && !GetHead(&LCBase))
		    notdone = 0;
		break;
	    case ACTION_READ:	    /*	 FHArg1,CPTRBuffer,Length   ActLength  */
		{
		    register MYFH   *mfh = (MYFH *)packet->dp_Arg1;
		    register FENTRY *fen = mfh->fentry;
		    register ubyte  *ptr = (ubyte *)packet->dp_Arg2;
		    register long   left = packet->dp_Arg3;
		    register long   scr;

		    while (left && fen) {
			scr = fen->bytes - mfh->offset;
			if (left < scr) {
			    bmov(fen->buf + mfh->offset, ptr, left);
			    mfh->offset += left;
			    left = 0;
			} else {
			    bmov(fen->buf + mfh->offset, ptr, scr);
			    left -= scr;
			    ptr += scr;
			    mfh->base += fen->bytes;
			    mfh->offset = 0;
			    fen = NextNode(fen);
			}
		    }
		    mfh->fentry = fen;
		    packet->dp_Res1 = packet->dp_Arg3 - left;
		}
		break;
	    case ACTION_WRITE:	    /*	 FHArg1,CPTRBuffer,Length   ActLength  */
		{
		    register MYFH   *mfh = (MYFH *)packet->dp_Arg1;
		    register FENTRY *fen = (FENTRY *)mfh->fentry;
		    ubyte  *ptr = (ubyte *)packet->dp_Arg2;
		    long   left = packet->dp_Arg3;
		    long   scr;

		    /*
		     *	Doesn't work right if multiple readers/appenders.
		     */

		    while (left) {
			if (fen) {
			    dbprintf("FEN: %ld  left: %ld\n", fen->bytes, left);
			    scr = fen->bytes - mfh->offset;
			    if (left < scr) {
				if (fen->bytes < mfh->offset + left)
				    dbprintf("PANIC! AWR0\n");
				else
				    bmov(ptr, fen->buf + mfh->offset, left);
				mfh->offset += left;
				left = 0;
			    } else {
				if (fen->bytes < mfh->offset + scr)
				    dbprintf("PANIC! AWR1\n");
				else
				    bmov(ptr, fen->buf + mfh->offset, scr);
				ptr += scr;
				left -= scr;
				mfh->base += fen->bytes;
				mfh->offset = 0;
				fen = NextNode(fen);
			    }
			} else {
			    fen = AllocMem(sizeof(FENTRY), MEMF_PUBLIC);
			    if (fen->buf = AllocMem(left, MEMF_PUBLIC)) {
				fen->bytes = left;
				mfh->file->bytes += left;
				mfh->base  += left;
				mfh->offset = 0;
				TotalBytes += left;
				AddTail(&mfh->file->list, fen);
				dbprintf("NEWFEN: (%ld)\n", fen->bytes);
				bmov(ptr, fen->buf, left);
				left = 0;
			    } else {
				FreeMem(fen, sizeof(FENTRY));
				dbprintf("NEWFEN: ****** Unable to allocate buffer %ld\n", left);
				mfh->offset = 0;
				break;
			    }
			    fen = NULL;     /*	cause append	*/
			}
		    }
		    packet->dp_Res1 = packet->dp_Arg3 - left;
		    mfh->fentry = fen;
		}
		break;
	    case ACTION_CLOSE:	    /*	 FHArg1 		    Bool:TRUE  */
		{
		    register MYFH   *mfh = (MYFH *)packet->dp_Arg1;
		    register RAMFILE *file = mfh->file;

		    Remove(mfh);
		    FreeMem(mfh,sizeof(*mfh));
		    if (--file->locks < 0)
			file->locks = 0;
		}
		if (!GetHead(&FHBase) && !GetHead(&LCBase))
		    notdone = 0;
		break;
	    case ACTION_SEEK:	    /*	 FHArg1,Position,Mode	    OldPosition*/
		{
		    register MYFH *mfh = (MYFH *)packet->dp_Arg1;
		    register FENTRY *fen;
		    register long absseek;

		    packet->dp_Res1 = mfh->base + mfh->offset;
		    absseek = packet->dp_Arg2;
		    if (packet->dp_Arg3 == 0)
			absseek += mfh->base + mfh->offset;
		    if (packet->dp_Arg3 == 1)
			absseek = mfh->file->bytes + absseek;
		    if (absseek < 0 || absseek > mfh->file->bytes) {
			error = ERROR_SEEK_ERROR;
			break;
		    }
		    mfh->base = mfh->offset = 0;

		    /*
		     *	Stupid way to do it but....
		     */

		    for (fen = GetHead(&mfh->file->list); fen; fen = NextNode(fen)) {
			if (mfh->base + fen->bytes > absseek) {
			    mfh->offset = absseek - mfh->base;
			    break;
			}
			mfh->base += fen->bytes;
		    }
		    mfh->fentry = fen;
		}
		break;
	    /*
	     *	This implementation sucks.  The right way to do it is with
	     *	a hash table.  The directory must be searched for the file
	     *	name, then the next entry retrieved.  If the next entry is
	     *	NULL there are no more entries.  If the filename could not
	     *	be found we return the first entry, if any.
	     *
	     *	You can't simply keep a pointer around to the next node
	     *	because it can be moved or removed at any time.
	     */

	    case ACTION_EXAMINE_NEXT: /*   Lock,Fib		      Bool	 */
		{
		    register FIB *fib = BTOC(packet->dp_Arg2);
		    register RAMFILE *dir = getlockfile(packet->dp_Arg1);
		    register RAMFILE *file;

		    if (dir->type == FILE_FILE) {
			error = ERROR_OBJECT_WRONG_TYPE;
			break;
		    }
		    file = GetHead(&dir->list);
		    if (fib->fib_DiskKey) {
			register int len = *(ubyte *)fib->fib_FileName;
			for (; file; file = NextNode(file)) {
			    if (strlen(file->name) == len && nccmp(file->name, fib->fib_FileName+1, len))
				break;
			}
			if (file)
			    file = NextNode(file);
			else
			    file = GetHead(&dir->list);
		    }
		    fib->fib_DiskKey = 1;
		    error = -1;
		    if (!(tmp=file)) {
			error = ERROR_NO_MORE_ENTRIES;
			break;
		    }
		}
		/*  fall through    */
	    case ACTION_EXAMINE_OBJECT: /*   Lock,Fib			Bool	   */
		{
		    register FIB *fib;
		    register RAMFILE *file;
		    register RAMFILE *dummy;

		    fib = BTOC(packet->dp_Arg2);
		    if (error) {
			file = tmp;	/*  fall through from above */
		    } else {
			file = getlockfile(packet->dp_Arg1);
			fib->fib_DiskKey = 0;
		    }
		    error = 0;
		    fib->fib_DirEntryType = file->type;
		    strcpy(fib->fib_FileName+1, file->name);
		    fib->fib_FileName[0] = strlen(file->name);
		    fib->fib_Protection = file->protection;
		    fib->fib_EntryType = NULL;
		    fib->fib_Size = file->bytes;
		    fib->fib_NumBlocks = file->bytes >> 9;
		    fib->fib_Date = file->date;
		    if (file->comment) {
			strcpy(fib->fib_Comment+1, file->comment);
			fib->fib_Comment[0] = strlen(file->comment);
		    } else {
			fib->fib_Comment[0] = 0;
		    }
		}
		break;
	    case ACTION_INFO:	    /*	Lock, InfoData	  Bool:TRUE    */
		tmp = BTOC(packet->dp_Arg2);
		error = -1;
		/*  fall through    */
	    case ACTION_DISK_INFO:  /*	InfoData	  Bool:TRUE    */
		{
		    register INFODATA *id;

		    /*
		     *	Note:	id_NumBlocks is never 0, but only to get
		     *	around a bug I found in my shell (where I divide
		     *	by id_NumBlocks).  Other programs probably break
		     *	as well.
		     */

		    (error) ? (id = tmp) : (id = BTOC(packet->dp_Arg1));
		    error = 0;
		    bzero(id, sizeof(*id));
		    id->id_DiskState = ID_VALIDATED;
		    id->id_NumBlocks	 = (TotalBytes >> 9) + 1;
		    id->id_NumBlocksUsed = (TotalBytes >> 9) + 1;
		    id->id_BytesPerBlock = 512;
		    id->id_DiskType = ID_DOS_DISK;
		    id->id_VolumeNode = (long)CTOB(DosNode);
		    id->id_InUse = (long)GetHead(&LCBase);
		}
		break;
	    case ACTION_PARENT:     /*	 Lock			    ParentLock */
		{
		    register RAMFILE *file = getlockfile(packet->dp_Arg1);
		    if (file->type == FILE_FILE) {
			error = ERROR_OBJECT_NOT_FOUND;
			break;
		    }
		    if (file->locks < 0) {
			error = ERROR_OBJECT_IN_USE;
			break;
		    }
		    if (file->parent)
			packet->dp_Res1 = (long)CTOB(ramlock(file->parent, ACCESS_READ));
		    else
			error = ERROR_OBJECT_NOT_FOUND;
		}
		break;
	    case ACTION_DELETE_OBJECT: /*Lock,Name		    Bool       */
		{
		    RAMFILE *parentdir = getlockfile(packet->dp_Arg1);
		    RAMFILE *ramfile;

		    btos(packet->dp_Arg2, buf);
		    if (ramfile = searchpath(&parentdir,buf,NULL)) {
			if (ramfile->locks || ramfile == &RFRoot) {
			    error = ERROR_OBJECT_IN_USE;
			    break;
			}
			if (ramfile->type == FILE_DIR) {
			    if (GetHead(&ramfile->list))
				error = ERROR_DIRECTORY_NOT_EMPTY;
			} else {
			    freedata(ramfile);
			}
			if (!error) {
			    freeramfile(ramfile);
			    DateStamp(&parentdir->date);
			}
		    } else {
			if (!parentdir)
			    error = ERROR_INVALID_COMPONENT_NAME;
			else
			    error = ERROR_OBJECT_NOT_FOUND;
		    }
		}
		if (!GetHead(&FHBase) && !GetHead(&LCBase))
		    notdone = 0;
		break;
	    case ACTION_CREATE_DIR: /*	 Lock,Name		    Lock       */
		{
		    RAMFILE *parentdir = getlockfile(packet->dp_Arg1);
		    RAMFILE *ramfile;
		    char *ptr;

		    btos(packet->dp_Arg2, buf);
		    if (ramfile = searchpath(&parentdir,buf,&ptr)) {
			error = ERROR_OBJECT_EXISTS;
			break;
		    }
		    if (!parentdir) {
			error = ERROR_INVALID_COMPONENT_NAME;
			break;
		    }
		    ramfile = createramfile(parentdir, FILE_DIR, ptr);
		    packet->dp_Res1 = (long)CTOB(ramlock(ramfile, ACCESS_WRITE));
		}
		break;
	    case ACTION_LOCATE_OBJECT:	/*   Lock,Name,Mode		Lock	   */
		{
		    RAMFILE *parentdir = getlockfile(packet->dp_Arg1);
		    RAMFILE *ramfile;

		    btos(packet->dp_Arg2, buf);
		    dbprintf("'%s' %ld ", buf, packet->dp_Arg3);
		    if (ramfile = searchpath(&parentdir,buf,NULL)) {
			if (ramfile->locks < 0 || (ramfile->locks && packet->dp_Arg3 == ACCESS_WRITE)) {
			    error = ERROR_OBJECT_IN_USE;
			    break;
			}
			packet->dp_Res1 = (long)CTOB(ramlock(ramfile, packet->dp_Arg3));
		    } else {
			if (!parentdir)
			    error = ERROR_INVALID_COMPONENT_NAME;
			else
			    error = ERROR_OBJECT_NOT_FOUND;
		    }
		}
		break;
	    case ACTION_COPY_DIR:   /*	 Lock,			    Lock       */
		{
		    register RAMFILE *ramfile = getlockfile(packet->dp_Arg1);
		    if (ramfile->locks < 0)
			error = ERROR_OBJECT_IN_USE;
		    else
			packet->dp_Res1 = (long)CTOB(ramlock(ramfile, ACCESS_READ));
		}
		break;
	    case ACTION_FREE_LOCK:  /*	 Lock,			    Bool       */
		if (packet->dp_Arg1);
		    ramunlock(BTOC(packet->dp_Arg1));
		if (!GetHead(&FHBase) && !GetHead(&LCBase))
		    notdone = 0;
		break;
	    case ACTION_SET_PROTECT:/*	 -,Lock,Name,Mask	   Bool       */
		{
		    register RAMFILE *ramfile;
		    RAMFILE *parentdir = getlockfile(packet->dp_Arg2);
		    char *ptr;

		    btos(packet->dp_Arg3, buf);
		    if (ramfile = searchpath(&parentdir,buf,&ptr)) {
			ramfile->protection = packet->dp_Arg4;
		    } else {
			if (parentdir)
			    error = ERROR_OBJECT_NOT_FOUND;
			else
			    error = ERROR_INVALID_COMPONENT_NAME;
		    }
		}
		break;
	    case ACTION_SET_COMMENT:/*	 -,Lock,Name,Comment	   Bool       */
		{
		    register RAMFILE *ramfile;
		    RAMFILE *parentdir = getlockfile(packet->dp_Arg2);
		    char *ptr;

		    btos(packet->dp_Arg3, buf);
		    if (ramfile = searchpath(&parentdir,buf,&ptr)) {
			btos(packet->dp_Arg4, buf);
			if (ramfile->comment)
			    FreeMem(ramfile->comment,strlen(ramfile->comment)+1);
			ramfile->comment = AllocMem(strlen(buf)+1, MEMF_PUBLIC);
			strcpy(ramfile->comment, buf);
		    } else {
			if (parentdir)
			    error = ERROR_OBJECT_NOT_FOUND;
			else
			    error = ERROR_INVALID_COMPONENT_NAME;
		    }
		}
		break;
	    case ACTION_RENAME_OBJECT:/* SLock,SName,DLock,DName    Bool       */
		{
		    register RAMFILE *file1;
		    RAMFILE *sourcedir = getlockfile(packet->dp_Arg1);
		    RAMFILE *destdir   = getlockfile(packet->dp_Arg3);
		    char *ptr;

		    btos(packet->dp_Arg2,buf);
		    dbprintf("\nRENAME '%s' (%ld)  ", buf, strlen(buf));
		    if (file1 = searchpath(&sourcedir,buf,NULL)) {
			btos(packet->dp_Arg4,buf);
			dbprintf("TO '%s' (%ld)", buf, strlen(buf));
			if (searchpath(&destdir,buf,&ptr)) {
			    error = ERROR_OBJECT_EXISTS;
			} else {
			    if (destdir) {
				if (file1 == destdir) { /* moving inside self */
				    error = ERROR_OBJECT_IN_USE;
				    break;
				}
				dbprintf("REN '%s' %ld", ptr, strlen(ptr));
				DateStamp(&sourcedir->date);
				DateStamp(&destdir->date);
				/*FreeMem(file1->name, strlen(file1->name)+1);*/
				Remove(file1);
				file1->name = AllocMem(strlen(ptr)+1,MEMF_PUBLIC);
				file1->parent = destdir;
				strcpy(file1->name, ptr);
				AddHead(&destdir->list, file1);
			    } else {
				error = ERROR_INVALID_COMPONENT_NAME;
			    }
			}
		    } else {
			if (sourcedir)
			    error = ERROR_OBJECT_NOT_FOUND;
			else
			    error = ERROR_INVALID_COMPONENT_NAME;
		    }
		}
		break;
	    /*
	     *	A few other packet types which we do not support
	     */
	    case ACTION_INHIBIT:    /*	 Bool			    Bool       */
		/*  Return success for the hell of it	*/
		break;
	    case ACTION_RENAME_DISK:/*	 BSTR:NewName		    Bool       */
	    case ACTION_MORECACHE:  /*	 #BufsToAdd		    Bool       */
	    case ACTION_WAIT_CHAR:  /*	 Timeout, ticks 	    Bool       */
	    case ACTION_FLUSH:	    /*	 writeout bufs, disk motor off	       */
	    case ACTION_RAWMODE:    /*	 Bool(-1:RAW 0:CON)	    OldState   */
	    default:
		error = ERROR_ACTION_NOT_KNOWN;
		break;
	    }
	    if (packet) {
		if (error) {
		    dbprintf("ERR=%ld\n", error);
		    packet->dp_Res1 = DOS_FALSE;
		    packet->dp_Res2 = error;
		} else {
		    dbprintf("RES=%06lx\n", packet->dp_Res1);
		}
		returnpacket(packet);
	    }
	}
    }
    dbprintf("Can we remove ourselves? ");
    Delay(50);	    /*	I wanna even see the debug message! */
    Forbid();
    if (packetsqueued(DosProc) || GetHead(&FHBase) || GetHead(&LCBase)
      || GetHead(&RFRoot.list)) {
	Permit();
	dbprintf(" ..  not yet!\n");
	goto top;		/*  sorry... can't exit     */
    }

    /*
     *	Causes a new process to be created on next reference
     */

    DosNode->dn_Task = FALSE;

    /*
     *	Remove Volume entry.  Since DOS uses singly linked lists, we
     *	must (ugg) search it manually to find the link before our
     *	Volume entry.
     */

    {
	DOSINFO *di = BTOC(((ROOTNODE *)DOSBase->dl_Root)->rn_Info);
	register DEVLIST *dl;
	register void *dlp;

	dlp = &di->di_DevInfo;
	for (dl = BTOC(di->di_DevInfo); dl && dl != DevList; dl = BTOC(dl->dl_Next))
	    dlp = &dl->dl_Next;
	if (dl == DevList) {
	    *(BPTR *)dlp = dl->dl_Next;
	    dosfree(dl);
	} else {
	    dbprintf("****PANIC: Unable to find volume node\n");
	}
    }

    /*
     *	Remove debug process, closedown, fall of the end of the world
     *	(which is how you kill yourself if a PROCESS.  A TASK would have
     *	had to RemTask(NULL) itself).
     */

    dbuninit();
    CloseLibrary(DOSBase);
}


/*
 *  PACKET ROUTINES.	Dos Packets are in a rather strange format as you
 *  can see by this and how the PACKET structure is extracted in the
 *  GetMsg() of the main routine.
 */

void
returnpacket(packet)
register struct DosPacket *packet;
{
    register struct Message *mess;
    register struct MsgPort *replyport;

    replyport		     = packet->dp_Port;
    mess		     = packet->dp_Link;
    packet->dp_Port	     = &DosProc->pr_MsgPort;
    mess->mn_Node.ln_Name    = (char *)packet;
    mess->mn_Node.ln_Succ    = NULL;
    mess->mn_Node.ln_Pred    = NULL;
    PutMsg(replyport, mess);
}

/*
 *  Are there any packets queued to our device?
 */

packetsqueued()
{
    return ((void *)DosProc->pr_MsgPort.mp_MsgList.lh_Head !=
	    (void *)&DosProc->pr_MsgPort.mp_MsgList.lh_Tail);
}

/*
 *  DOS MEMORY ROUTINES
 *
 *  DOS makes certain assumptions about LOCKS.	A lock must minimally be
 *  a FileLock structure, with additional private information after the
 *  FileLock structure.  The longword before the beginning of the structure
 *  must contain the length of structure + 4.
 *
 *  NOTE!!!!! The workbench does not follow the rules and assumes it can
 *  copy lock structures.  This means that if you want to be workbench
 *  compatible, your lock structures must be EXACTLY sizeof(struct FileLock).
 */

void *
dosalloc(bytes)
register ulong bytes;
{
    register ulong *ptr;

    bytes += 4;
    ptr = AllocMem(bytes, MEMF_PUBLIC|MEMF_CLEAR);
    *ptr = bytes;
    return(ptr+1);
}

dosfree(ptr)
register ulong *ptr;
{
    --ptr;
    FreeMem(ptr, *ptr);
}

/*
 *  Convert a BSTR into a normal string.. copying the string into buf.
 *  I use normal strings for internal storage, and convert back and forth
 *  when required.
 */

void
btos(bstr,buf)
ubyte *bstr;
ubyte *buf;
{
    bstr = BTOC(bstr);
    bmov(bstr+1,buf,*bstr);
    buf[*bstr] = 0;
}

/*
 *  Some EXEC list handling routines not found in the EXEC library.
 */

void *
NextNode(node)
NODE *node;
{
    node = node->mln_Succ;
    if (node->mln_Succ == NULL)
	return(NULL);
    return(node);
}

void *
GetHead(list)
LIST *list;
{
    if ((void *)list->mlh_Head != (void *)&list->mlh_Tail)
	return(list->mlh_Head);
    return(NULL);
}

/*
 *  Compare two names which are at least n characters long each,
 *  ignoring case.
 */

nccmp(p1,p2,n)
register ubyte *p1, *p2;
register short n;
{
    while (--n >= 0) {
	if ((p1[n]|0x20) != (p2[n]|0x20))
	    return(0);
    }
    return(1);
}

/*
 *  Create a file or directory and link it into it's parent directory.
 */

RAMFILE *
createramfile(parentdir, type, name)
RAMFILE *parentdir;
char *name;
{
    register RAMFILE *ramfile;

    ramfile = AllocMem(sizeof(RAMFILE), MEMF_CLEAR|MEMF_PUBLIC);
    AddTail(&parentdir->list, ramfile);
    ramfile->parent = parentdir;
    ramfile->name = AllocMem(strlen(name)+1, MEMF_PUBLIC);
    strcpy(ramfile->name, name);
    ramfile->type = type;
    ramfile->protection = 0;
    NewList(&ramfile->list);
    DateStamp(&ramfile->date);
    DateStamp(&ramfile->parent->date);
    return(ramfile);
}

/*
 *  Free all data associated with a file
 */

void
freedata(ramfile)
RAMFILE *ramfile;
{
    FENTRY *fen;

    TotalBytes -= ramfile->bytes;
    while (fen = RemHead(&ramfile->list)) {
	dbprintf("FREE FEN: %08lx %08lx %ld\n", fen, fen->buf, fen->bytes);
	FreeMem(fen->buf, fen->bytes);
	FreeMem(fen, sizeof(*fen));
    }
    ramfile->bytes = 0;
    DateStamp(&ramfile->date);
    DateStamp(&ramfile->parent->date);
}

/*
 *  Unlink and remove a file.  Any data associated with the file or
 *  directory has already been freed up.
 */

void
freeramfile(ramfile)
RAMFILE *ramfile;
{
    Remove(ramfile);		/*  unlink from parent directory    */
    if (ramfile->name)
	FreeMem(ramfile->name,strlen(ramfile->name)+1);
    if (ramfile->comment)
	FreeMem(ramfile->comment,strlen(ramfile->comment)+1);
    FreeMem(ramfile,sizeof(*ramfile));
}

/*
 *  The lock function.	The file has already been checked to see if it
 *  is lockable given the mode.
 */

LOCK *
ramlock(ramfile, mode)
RAMFILE *ramfile;
{
    LOCK *lock = dosalloc(sizeof(LOCK));
    LOCKLINK *ln;

    if (mode != ACCESS_WRITE)
	mode = ACCESS_READ;
    ln = AllocMem(sizeof(LOCKLINK), MEMF_PUBLIC);
    AddHead(&LCBase,ln);
    ln->lock = lock;
    lock->fl_Link= (long)ln;
    lock->fl_Key = (long)ramfile;
    lock->fl_Access = mode;
    lock->fl_Task = &DosProc->pr_MsgPort;
    lock->fl_Volume = (BPTR)CTOB(DosNode);
    if (mode == ACCESS_READ)
	++ramfile->locks;
    else
	ramfile->locks = -1;
    return(lock);
}

void
ramunlock(lock)
LOCK *lock;
{
    RAMFILE *file = (RAMFILE *)lock->fl_Key;

    Remove(lock->fl_Link);			/* unlink from list */
    FreeMem(lock->fl_Link, sizeof(LOCKLINK));	/* free link node   */
    if (lock->fl_Access == ACCESS_READ) 	/* undo lock effect */
	--file->locks;
    else
	file->locks = 0;
    dosfree(lock);				/* free lock	    */
}

/*
 *  GETLOCKFILE(bptrlock)
 *
 *  Return the RAMFILE entry (file or directory) associated with the
 *  given lock, which is passed as a BPTR.
 *
 *  According to the DOS spec, the only way a NULL lock will ever be
 *  passed to you is if the DosNode->dn_Lock is NULL, but I'm not sure.
 *  In anycase, If a NULL lock is passed to me I simply assume it means
 *  the root directory of the RAM disk.
 */

RAMFILE *
getlockfile(lock)
void *lock;		/*  actually BPTR to LOCK */
{
    register LOCK *rl = BTOC(lock);

    if (rl)
	return((RAMFILE *)rl->fl_Key);
    return(&RFRoot);
}

/*
 *  Search the specified path beginning at the specified directory.
 *  The directory pointer is updated to the directory containing the
 *  actual file.  Return the file node or NULL if not found.  If the
 *  path is illegal (an intermediate directory was not found), set *ppar
 *  to NULL and return NULL.
 *
 *  *ppar may also be set to NULL if the search path IS the root.
 *
 *  If pptr not NULL, Set *pptr to the final component in the path.
 */

RAMFILE *
searchpath(ppar,buf,pptr)
RAMFILE **ppar;
char *buf;
char **pptr;
{
    RAMFILE *file = *ppar;
    RAMFILE *srch;
    short len;
    char *ptr;

    *ppar = NULL;
    for (;*buf && file;) {
	ptr = getpathelement(&buf,&len);
	if (buf[0] == ':') {    /*  go to root          */
	    ++buf;
	    file = &RFRoot;
	    continue;
	}
	if (*ptr == '/') {          /*  go back a directory */
	    if (!file->parent) {    /*	no parent directory */
		return(NULL);
	    }
	    file = file->parent;
	    continue;
	}
	if (file->type == FILE_FILE)
	    return(NULL);
	for (srch = GetHead(&file->list); srch; srch = NextNode(srch)) {
	    if (srch->type && strlen(srch->name) == len && nccmp(srch->name, ptr, len)) {
		file = srch;	    /*	element found	    */
		break;
	    }
	}
	if (srch == NULL) {
	    if (*buf == 0)	/*  Element not found.	If it was the final */
		*ppar = file;	/*  element the parent directory is valid   */
	    if (pptr)
		*pptr = ptr;
	    return(NULL);
	}
    }
    if (pptr)
	*pptr = ptr;
    *ppar = file->parent;
    return(file);
}

/*
 *  Return the next path element in the string.  The routine effectively
 *  removes any trailing '/'s, but treats ':' as part of the next component
 *  (i.e. ':' is checked and skipped in SEARCHPATH()).
 */

char *
getpathelement(pstr,plen)
char **pstr;
short *plen;
{
    char *base;
    register char *ptr = *pstr;
    register short len = 0;

    if (*(base = ptr)) {
	if (*ptr == '/') {
	    ++ptr;
	    ++len;
	} else {
	    while (*ptr && *ptr != '/' && *ptr != ':') {
		++ptr;
		++len;
	    }
	    if (*ptr == '/')
		++ptr;
	}
    }
    *pstr = ptr;
    *plen = len;
    return(base);
}


char *
typetostr(ty)
{
    switch(ty) {
    case ACTION_DIE:		return("DIE");
    case ACTION_OPENRW: 	return("OPEN-RW");
    case ACTION_OPENOLD:	return("OPEN-OLD");
    case ACTION_OPENNEW:	return("OPEN-NEW");
    case ACTION_READ:		return("READ");
    case ACTION_WRITE:		return("WRITE");
    case ACTION_CLOSE:		return("CLOSE");
    case ACTION_SEEK:		return("SEEK");
    case ACTION_EXAMINE_NEXT:	return("EXAMINE NEXT");
    case ACTION_EXAMINE_OBJECT: return("EXAMINE OBJ");
    case ACTION_INFO:		return("INFO");
    case ACTION_DISK_INFO:	return("DISK INFO");
    case ACTION_PARENT: 	return("PARENTDIR");
    case ACTION_DELETE_OBJECT:	return("DELETE");
    case ACTION_CREATE_DIR:	return("CREATEDIR");
    case ACTION_LOCATE_OBJECT:	return("LOCK");
    case ACTION_COPY_DIR:	return("DUPLOCK");
    case ACTION_FREE_LOCK:	return("FREELOCK");
    case ACTION_SET_PROTECT:	return("SETPROTECT");
    case ACTION_SET_COMMENT:	return("SETCOMMENT");
    case ACTION_RENAME_OBJECT:	return("RENAME");
    case ACTION_INHIBIT:	return("INHIBIT");
    case ACTION_RENAME_DISK:	return("RENAME DISK");
    case ACTION_MORECACHE:	return("MORE CACHE");
    case ACTION_WAIT_CHAR:	return("WAIT FOR CHAR");
    case ACTION_FLUSH:		return("FLUSH");
    case ACTION_RAWMODE:	return("RAWMODE");
    default:			return("---------UNKNOWN-------");
    }
}

/*
 *  DEBUGGING CODE.	You cannot make DOS library calls that access other
 *  devices from within a DOS device driver because they use the same
 *  message port as the driver.  If you need to make such calls you must
 *  create a port and construct the DOS messages yourself.  I do not
 *  do this.  To get debugging info out another PROCESS is created to which
 *  debugging messages can be sent.
 *
 *  You want the priority of the debug process to be larger than the
 *  priority of your DOS handler.  This is so if your DOS handler crashes
 *  you have a better idea of where it died from the debugging messages
 *  (remember that the two processes are asyncronous from each other).
 */

extern void debugproc();

dbinit()
{
    TASK *task = FindTask(NULL);

    Dback = CreatePort(NULL,NULL);
    CreateProc("DEV_DB", task->tc_Node.ln_Pri+1, CTOB(debugproc), 4096);
    WaitPort(Dback);				    /* handshake startup    */
    GetMsg(Dback);				    /* remove dummy msg     */
    dbprintf("Debugger running V1.10, 2 November 1987\n");
    dbprintf("Works with WORKBENCH!\n");
}

dbuninit()
{
    MSG killmsg;

    if (Dbport) {
	killmsg.mn_Length = 0;	    /*	0 means die	    */
	PutMsg(Dbport,&killmsg);
	WaitPort(Dback);	    /*	He's dead jim!      */
	GetMsg(Dback);
	DeletePort(Dback);

	/*
	 *  Since the debug process is running at a greater priority, I
	 *  am pretty sure that it is guarenteed to be completely removed
	 *  before this task gets control again.  Still, it doesn't hurt...
	 */

	Delay(50);		    /*	ensure he's dead    */
    }
}

dbprintf(a,b,c,d,e,f,g,h,i,j)
{
    char buf[256];
    MSG *msg;

    if (Dbport && !DBDisable) {
	sprintf(buf,a,b,c,d,e,f,g,h,i,j);
	msg = AllocMem(sizeof(MSG)+strlen(buf)+1, MEMF_PUBLIC|MEMF_CLEAR);
	msg->mn_Length = strlen(buf)+1;     /*	Length NEVER 0	*/
	strcpy(msg+1,buf);
	PutMsg(Dbport,msg);
    }
}

/*
 *  BTW, the DOS library used by debugmain() was actually openned by
 *  the device driver.	Note: DummyMsg cannot be on debugmain()'s stack
 *  since debugmain() goes away on the final handshake.
 */

debugmain()
{
    MSG *msg;
    short len;
    void *fh;

    Dbport = CreatePort(NULL,NULL);
    fh = Open("con:0/0/640/100/debugwindow", 1006);
    PutMsg(Dback, &DummyMsg);
    for (;;) {
	WaitPort(Dbport);
	msg = GetMsg(Dbport);
	len = msg->mn_Length;
	if (len == 0)
	    break;
	--len;			      /*  Fix length up   */
	Write(fh, msg+1, len);
	FreeMem(msg,sizeof(MSG)+len+1);
    }
    Close(fh);
    DeletePort(Dbport);
    PutMsg(Dback,&DummyMsg);	      /*  Kill handshake  */
}

/*
 *  The assembly tag for the DOS process:  CNOP causes alignment problems
 *  with the Aztec assembler for some reason.  I assume then, that the
 *  alignment is unknown.  Since the BCPL conversion basically zero's the
 *  lower two bits of the address the actual code may start anywhere around
 *  the label....  Sigh....  (see CreatProc() above).
 */

#asm
	public	_debugproc
	public	_debugmain

	cseg
	nop
	nop
	nop
_debugproc:
	nop
	nop
	movem.l D2-D7/A2-A6,-(sp)
	jsr	_debugmain
	movem.l (sp)+,D2-D7/A2-A6
	rts
#endasm

