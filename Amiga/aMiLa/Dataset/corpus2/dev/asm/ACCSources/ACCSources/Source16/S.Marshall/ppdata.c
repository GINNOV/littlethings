/********************************************************************
*                                                                   *
*  PowerPacker DATA file support function V1.1                      *
*  -------------------------------------------                      *
*                            (Read Packer.doc for more information) *
*                                                                   *
*    error = PP_LoadData (file, col, typeofmem, buffer, length, pw) *
*    with:                                                          *
*       char *file;     filename                                    *
*       UBYTE col;      color (see ppdata.h)                        *
*       ULONG typeofmem type of memory that will be allocated       *
*       UBYTE **buffer  pointer to pointer to buffer                *
*       ULONG *length   pointer to buffer length                    *
*       char *pw;       pointer to password or NULL                 *
*                                                                   *
*  NOTE: - After loading you must free the allocated memory:        *
*          DO NOT FORGET !!!!!                                      *
*             FreeMem (buffer, length);                             *
*        - Errors are defined in ppdata.h                           *
*        - For encrypted data call first with pw = NULL, then       *
*          if error is PP_CRYPTED you know file is crypted.         *
*          Prompt the user for a password and call again with       *
*          pw pointing to this password. If the password is         *
*          incorrect error is PP_PASSERR, otherwise the file will   *
*          be loaded and decrypted.                                 *
*                                                                   *
*    Example:                                                       *
*                                                                   *
*      #include <ppdata.h>                                          *
*      ...                                                          *
*                                                                   *
*      UBYTE *mymem = NULL;                                         *
*      ULONG mylen = 0;                                             *
*                                                                   *
*      err = PP_LoadData ("df0:myfile.pp", DECR_POINTER,            *
*                     MEMF_PUBLIC+MEMF_CHIP, &mymem, &mylen, NULL); *
*      if (err == PP_LOADOK) {                                      *
*         DoSomething (mymem, mylen);                               *
*         FreeMem (mymem, mylen);                                   *
*         }                                                         *
*      else switch (err) {                                          *
*         case PP_CRYPTED:                                          *
*            puts ("File is encrypted !");                          *
*            break;                                                 *
*         case PP_READERR:                                          *
*            puts ("Loading error !!!");                            *
*            break;                                                 *
*         ...                                                       *
*         }                                                         *
*                                                                   *
********************************************************************/
/********************************************************************
*                                                                   *
*  'PP_LoadData' PowerPacker DATA file support function V1.1        *
*                                                                   *
*  You may use this code for non-commercial purposes provided this  *  
*  copyright notice is left intact !                                *
*                                                                   *
*                          Copyright (c) Aug 1989 by Nico François  *
********************************************************************/

#include <exec/types.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <libraries/dos.h>
/*
#include <functions.h>
*/
#include "ppdata.h"

#define SAFETY_MARGIN	64L
#define SIZEOF				(ULONG)sizeof
#define myRead(to,len)	if (Read (pp_lock, to, len) != len) {\
										pp_FreeStuff(); return (PP_READERR); }
struct FileLock *pp_lock;
struct FileInfoBlock *pp_FileInfoBlock;
UBYTE *pp_filestart;
ULONG pp_bufferlen;
UWORD pp_coladdr[4] = { 0xf180, 0xf182, 0xf1a2, 0xf102 };
UWORD pp_CalcCheckSum();
ULONG pp_CalcPasskey();

PP_LoadData (pp_file, color, typeofmem, buffer, length, pw)		/* Version 1.1 */
char *pp_file;
UBYTE color;
ULONG typeofmem;
UBYTE **buffer;
ULONG *length;
char *pw;
{
/*
	ULONG hdr;
*/
	char hdr[4];
	ULONG pp_seek;
	UWORD *decrcol, instr, hicol, locol;
	ULONG pp_filelen, pp_crunlen, pp_efficiency;
	UBYTE pp_crunched;
	extern void pp_DecrunchBuffer(), pp_DecrunchColor();

	pp_filestart = NULL;
	if (!(pp_FileInfoBlock = (struct FileInfoBlock *)AllocMem
		(SIZEOF(*pp_FileInfoBlock), MEMF_PUBLIC))) return (PP_NOMEMORY);

	/* Set decruncher color */
	decrcol = (UWORD *)pp_DecrunchColor;
	if (color != 4) {
		instr = 0x33c9; hicol = 0x00df;
		locol = pp_coladdr[color];				/* = move.w a1,$dff1xx */
		}
	else instr = hicol = locol = 0x4e71; 	/* nop */
	*decrcol = instr;
	*(decrcol+1) = hicol; *(decrcol+2) = locol;

	if (!(pp_lock = (struct FileLock *)Lock (pp_file, ACCESS_READ))) {
		pp_FreeStuff();
		return (PP_LOCKERR);
		}
	Examine (pp_lock, pp_FileInfoBlock);
	UnLock (pp_lock);
	pp_crunlen = pp_FileInfoBlock->fib_Size;

	/* read decrunched length */
	if (!(pp_lock = (struct FileLock *)Open (pp_file, MODE_OLDFILE))) {
		SimpleRequest("Can't Open");
		pp_FreeStuff();
		return (PP_OPENERR);
		}
	myRead (hdr, 4L);

	/* check if crunched */
/*
	if ( hdr == 'PP11' || hdr == 'PP20') && (pp_crunlen>16L)) {
*/
	if ( 
	(((hdr[0] == 'P') && (hdr[1] == 'P') && (hdr[2] == '2') &&(hdr[3] == '0'))
	|| ((hdr[0] == 'P') && (hdr[1] == 'P') && (hdr[2] == '1') &&(hdr[3] == '1')))
	 && (pp_crunlen>16L)) {
		pp_seek = 4L;
		Seek (pp_lock, pp_crunlen - 4L, OFFSET_BEGINNING);
		myRead (&pp_filelen, 4L);
		pp_filelen >>= 8L;
		pp_crunlen -= 4L + pp_seek;
		Seek (pp_lock, pp_seek, OFFSET_BEGINNING);
		myRead (&pp_efficiency, 4L);
		pp_bufferlen = pp_filelen + SAFETY_MARGIN;
		pp_crunched = TRUE;
		}
	else {
		Seek (pp_lock, 0L, OFFSET_BEGINNING);
		pp_bufferlen = pp_filelen = pp_crunlen;
		pp_crunched = FALSE;
		}
	if (!(pp_filestart=(UBYTE *)AllocMem (pp_bufferlen, typeofmem))) {
		SimpleRequest("Sorry,not enough mem...");
		pp_FreeStuff();
		return (PP_NOMEMORY);
		}
	/* load file */
	myRead (pp_filestart, pp_crunlen);

	Close (pp_lock);
	FreeMem (pp_FileInfoBlock, SIZEOF(*pp_FileInfoBlock));
	if (pp_crunched) {
		pp_DecrunchBuffer (pp_filestart + pp_crunlen,
											pp_filestart + SAFETY_MARGIN, pp_efficiency);
		FreeMem (pp_filestart, SAFETY_MARGIN);
		pp_filestart += SAFETY_MARGIN;
		}
	*buffer = pp_filestart;
	*length = pp_filelen;
	return (PP_LOADOK);
}

pp_FreeStuff()
{
	if (pp_lock) Close (pp_lock);
	if (pp_filestart) FreeMem (pp_filestart, pp_bufferlen);
	if (pp_FileInfoBlock) FreeMem (pp_FileInfoBlock, SIZEOF(*pp_FileInfoBlock));
}
