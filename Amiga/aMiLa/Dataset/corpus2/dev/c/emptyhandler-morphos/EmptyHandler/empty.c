/*
    EMPTY.c
    ------
    Beispiel für einen DOS-Handler mit minimalem Funktionsumfang

    von Oliver Wagner, © Amiga-DOS

*/


#include <proto/exec.h>
#include <proto/dos.h>
#include <string.h>
#include <libraries/filehandler.h>

#include "empty.h"

/* Der eigentliche Handler */

void SAVEDS empty_handler(void)
{
	struct ExecBase *SysBase;
	struct DosLibrary *DOSBase;
    struct Process *hproc;
    struct DosPacket *packet;
    struct DeviceNode *devnode;
    struct FileHandle *fh;

    short running=TRUE;
    long opencount=0;
	LONG emptylen;
    int readlen,c;
    char *nump;
    char filename[108];

	SysBase = *((APTR *)4);
	DOSBase = (struct DosLibrary *)OpenLibrary((STRPTR)&dosname, 36); 

    /* Handler initialisieren, Startup-Packet annehmen */

    hproc=(struct Process*)FindTask(0);
    packet=getpacket(SysBase,hproc);
    devnode=(struct DeviceNode*)BADDR(packet->dp_Arg3);
    devnode->dn_Task=&hproc->pr_MsgPort;

    /* und Startup-Packet zurückgeben. Damit läuft der Handler */

    returnpacket(SysBase,packet,hproc,DOSTRUE,0);

    /* Hauptschleife des Handlers */

    while(running) {
	packet = getpacket(SysBase,hproc);
	switch(packet->dp_Type) {


	    /* "File" öffnen */

	    case ACTION_FINDUPDATE:
	    case ACTION_FINDINPUT:
	    case ACTION_FINDOUTPUT:
		nump=(char *)((packet->dp_Arg3)<<2);
                for(c=0; c<(int)*nump; c++) filename[c]=nump[c+1];
		filename[c]=0;
		nump=filename;
		while(*nump && *nump!=':') nump++;
		if(*nump==':') nump++;
		if (DOSBase)
			StrToLong(nump, &emptylen);
		opencount++;
		/* FileHandle-Struktur */
		fh=(struct FileHandle*)BADDR(packet->dp_Arg1);
		/* Nicht-Interaktives File */
		fh->fh_Port=0;
		/* wird bei Read usw. übergeben */
		fh->fh_Args=(long)fh;
		/* Länge des Leerfiles */
		fh->fh_Arg2=(long)emptylen;
		/* Falls Ende der Liste, neu von vorne */
		/* Packet zurückgeben */
		returnpacket(SysBase,packet,hproc,DOSTRUE,0);
	      break;


	    /* File schließen... */

	    case ACTION_END:
		/* Falls kein "Öffner", Handler beenden */
		if(--opencount==0) running=0;
		returnpacket(SysBase,packet,hproc,DOSTRUE,0);
	      break;


	    /* lesen */

	    case ACTION_READ:
		/* FileHandle, bei Open eingetragen */
		fh=(struct FileHandle*)packet->dp_Arg1;
		nump=(char *)packet->dp_Arg2;
		emptylen=fh->fh_Arg2;
		readlen=packet->dp_Arg3;
		/* Falls mehr Zeichen angefordert, als lieferbar,
		   entsprechend kürzen */
		if(readlen>emptylen) readlen=emptylen;
		for(c=0; c<readlen; c++) *nump++=0;
		/* Länge subtrahieren */
		fh->fh_Arg2-=readlen;
		/* Packet zurückschicken */
		returnpacket(SysBase,packet,hproc,readlen,0);
	      break;


	    /* Schreiben leider nicht möglich */

	    case ACTION_WRITE:
		/* Schreibfehler */
		returnpacket(SysBase,packet,hproc,DOSFALSE,ERROR_DISK_WRITE_PROTECTED);
	      break;


	    /* Unbekanntes Packet */

	    default:
		returnpacket(SysBase,packet,hproc,DOSFALSE,ERROR_ACTION_NOT_KNOWN);
	      break;
	}
    }

    /* DevNode löschen, Handler beendet */

    devnode->dn_Task=FALSE;

	CloseLibrary((struct Library *)DOSBase);
}

const char __TEXTSEGMENT__ ver_version[]={"$VER: empty-handler v1.0 (3.12.08)"};
const char __TEXTSEGMENT__ dosname[] = "dos.library";

#if defined(__PPC__)
CONST ULONG __abox__ = 1;
#endif
