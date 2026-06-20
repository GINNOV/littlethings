 /* Attempt at an ACC menu in C. Will have to use assembler patches though
  for file viewer, ILBM displayer and NT-Replayer for the time being. When
  I get around to writing suitable replacements I will substitute them :-)
 */

/* Source organisation:

1. Main
				_main
2. IDCMP routines.
				handleIDCMP
				do_gadget
				do_menu
				do_keys
3. List-display functions.
				move_list
				DisplayIt
				fix_string
4. List-file functions.
				GetControl
				LoadFile
				build_list
				add_line
				free_list
5. Library open/close functions.
				open_libs
				close_libs
*/

/* Compilation details:
			>lc menu.c
			>blink with make
			
make:
	FROM LIB:c.o menu.o
	TO Menu
	LIB LIB:lc.lib LIB:amiga.lib LIB:reqtoolsnb.lib
	BATCH
*/


	/* ****************************************************** */
	/* 		Include Commodore files			  */
	/* ****************************************************** */

#include <stdio.h>
#include <time.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <exec/lists.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <libraries/dos.h>
#include <intuition/intuition.h>
#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/dos.h>

	/* ****************************************************** */
	/* 		Include other files			  */
	/* ****************************************************** */

#include <libraries/reqtools.h>
#include <proto/reqtools.h>
#include <libraries/ppbase.h>
#include "Menu_Window.h"

	/* ****************************************************** */
	/* 	    	    Declarations			  */
	/* ****************************************************** */

#define MY_NODE_ID 50
#define NUM_LINES 17			  /* 17 selection gadgets */

	/* ****************************************************** */
	/* 	    	Function Prototypes			  */
	/* ****************************************************** */

/* A number of these functions are adaptions of their generic versions that
   take advantage of global variables. This reduces size of code as the
   amount of initialisation required prior to calling each function is
   kept to a minimum.
*/

BOOL open_libs( void );
BOOL handleIDCMP( void );
BOOL do_gadget( void );
BOOL do_keys( void );
void set_slider( void );
void get_slider( void );

void load_text( void );
void load_sounds( void );
void load_ilbm( void );
void launch( void );

BOOL GetControl( void );
BOOL LoadFile( char *name );
BOOL build_list( void );
void add_line( UBYTE *line );
void free_list( void );

void DisplayIt( void );
void fix_string( char *from, char *to, int length);
void move_list( int dirn );

void do_date( void );
void close_libs( void );

	/* ****************************************************** */
	/* 	    	External Function Prototypes		  */
	/* ****************************************************** */

/* the following functions were all written in assembler. */

extern void ShowFile( char *fname );
extern void PlayFile( char *fname );
extern void StopPlaying( void );
extern void ViewILBM( char *fname );

	/* ****************************************************** */
	/* 		Global variable declerations		  */
	/* ****************************************************** */

struct IntuitionBase *IntuitionBase=NULL;
struct GfxBase *GfxBase=NULL;
struct ReqToolsBase *ReqToolsBase=NULL;
struct PPBase *PPBase=NULL;

struct Window *win;
struct rtFileRequester *file_request;
struct IntuiMessage *msg;
USHORT msg_code;
struct Gadget *gadg;

char filename[50];			/* contains name of file */
char loadname[50];
struct List *LineList;			/* -> list of line pointers */
char *text_buffer;			/* buffer containing control file */
LONG buffer_size;			/* size of above buffer */
LONG num_lines;				/* number of entries in file */
LONG top_line;				/* number of 1st line in display */

extern struct DOSBase *DOSBase;

	/* ****************************************************** */
	/* 			Main				  */
	/* ****************************************************** */

void _main( void)
{

BOOL ok=TRUE;

if( open_libs() )
    {
    strcpy( filename, "s:acc0" );
    if( GetControl() )
	{
	if ( win = OpenWindow( &MenuWindow ) )
		{
		DrawImage( win->RPort, &gfxImage, 0L, 0L );
		AddGList( win, &Gadget1, 0L, 29L, NULL );
		RefreshGList( &Gadget1, win, NULL, 29L );
		set_slider();
		do
			{
			WaitPort( win->UserPort );
			if ( msg=(struct IntuiMessage *)GetMsg( win->UserPort ) )
				ok=handleIDCMP( );
			}while( ok );
			
		StopPlaying();
		CloseWindow( win );
		}
	free_list();
	}
    FreeMem( text_buffer, buffer_size );
    }
close_libs();

}

	/* ****************************************************** */
	/* 		Handle Windows IDCMP Messages		  */
	/* ****************************************************** */

/* Acts on any messages passed. Returns FALSE if a quit routine is called */

BOOL handleIDCMP( void )
{
ULONG class;			/* for message class */
BOOL ok=TRUE;			/* default continue  */

class = msg->Class;
msg_code=msg->Code;
gadg=(struct Gadget *)msg->IAddress;

ReplyMsg( (struct Message *)msg );

if ( class==INTUITICKS )
	{
	if( Gadget18.Flags&SELECTED ) move_list(-1 );
	else if( Gadget19.Flags&SELECTED ) move_list( 1 );
	else if( Gadget20.Flags&SELECTED ) get_slider();
	else do_date();
	}
else
	{
	ModifyIDCMP( win, CLOSEWINDOW );
	switch( class )
		{
		case GADGETUP:
			ok=do_gadget();
			break;
		case VANILLAKEY:
			ok=do_keys();
			break;
		default:
			break;
		}
	ModifyIDCMP( win, GADGETUP|VANILLAKEY|INTUITICKS );

	}

if( !ok ) 
    switch ( rtEZRequest( "Quit, Are You Sure?","Yep!|No Way!",NULL,NULL) )
    	{
    	case TRUE:
    		rtEZRequest("See you again soon.","Okay",NULL,NULL);
    		break;
    	case FALSE:
    		ok=TRUE;
    		break;
    	default:
    		break;
    	}
return ok;
}

	/* ****************************************************** */
	/* 		Initialise Proportional Gadget		  */
	/* ****************************************************** */

void set_slider( void )
{
if( num_lines>NUM_LINES*2 )
	NewModifyProp( &Gadget20, win, NULL,AUTOKNOB|FREEVERT|PROPBORDERLESS,
		       NULL, ((MAXBODY*(top_line>>1))/((num_lines-2*NUM_LINES)>>1)), MAXBODY,
		       ((MAXBODY*NUM_LINES*2)/(num_lines-NUM_LINES*2)), 1L);
else
	NewModifyProp( &Gadget20, win, NULL,AUTOKNOB|FREEVERT|PROPBORDERLESS,
		       NULL, NULL, MAXBODY, MAXBODY, 1L);

RefreshGList( &Gadget20, win, NULL, 1L );
DisplayIt();
}

	/* ****************************************************** */
	/* 		Deal With Moving Slider 		  */
	/* ****************************************************** */

void get_slider( void )
{
struct PropInfo *prop;

prop=(struct PropInfo *)Gadget20.SpecialInfo;
top_line=((prop->VertPot*(num_lines - NUM_LINES*2))/MAXBODY)>>1;
top_line <<=1;
DisplayIt();
}

	/* ****************************************************** */
	/* 		Handle Gadget Selections		  */
	/* ****************************************************** */

BOOL do_gadget( void )
{
struct Node *this_node;
USHORT gadg_id;
LONG gadg_data, count, i;
char action, *fname, same[34];
BOOL ok=TRUE;

gadg=(struct Gadget *)msg->IAddress;
gadg_id=gadg->GadgetID;
gadg_data=(LONG)gadg->UserData;

switch( gadg_id )
    {
    case 0:
        count=top_line+2*gadg_data+1;
        if( count<=num_lines )
            {
            this_node=LineList->lh_Head;
            for(i=0; i<count; i++ ) this_node=this_node->ln_Succ;
            fname=this_node->ln_Name;
            action=*fname++;
            switch( action )
                {
                case 'R':
                    ShowFile( fname );
                    break;
                case 'P':
                    PlayFile( fname );
                    break;
                case 'p':
                    StopPlaying();
                    break;
                case 'V':
                    ViewILBM( fname );
                    break;
                case 'Q':
                    ok=FALSE;
                    break;
                case 'E':
                    Execute( fname, 0L, 0L );
                    break;
                case 'M':
                    strcpy( filename, fname );
                    if( ok=GetControl() )
                        {
                        WinText.IText=same;
			fix_string( "", same, 33 );
                        for( count=0; count<NUM_LINES; count++ )
                            PrintIText( win->RPort, &WinText, 0, count*9 );
                        set_slider();
                        }
		    break;
		case 'C':
			rtPaletteRequest( "Change Colours", NULL, TAG_END );
                default:
                    break;
                }
            }
        break;
    case 20:
        get_slider();
        DisplayIt();
	break;
    case 21:
	rtEZRequestTags("      Menu programmed by M.Meany.       \n"
		    "   IFF-ILBM loader by Steve Marshall.   \n"
		    "  Interrupt handler by Steve Marshall.  \n"
		    "NoiseTracker Replay by Mahoney & Kaktus.\n"
		    "This program also calls upon two system \n"
		    "libraries written by & © Nico François: \n"
		    "powerpacker.library & reqtools.library."
		   ,"Okay",NULL,NULL,RT_ReqPos,REQPOS_CENTERSCR,TAG_END);
	break;
    case 22:
	if ( !strcmp( filename, "s:acc0" ) )
	    rtEZRequest("Your looking at the main menu!","Okay",NULL,NULL);
	else
	    {
	    strcpy( filename, "s:acc0" );
	    if( GetControl() )
		set_slider();
	    else
		{
		ok=FALSE;
		rtEZRequestTags("Cannot load 's:acc0'\n"
				"Aborting .... Sorry! \n"
				,"Never Mind",NULL,NULL,
				RT_ReqPos,REQPOS_CENTERSCR,TAG_END);
		}
	    }
	break;
    case 23:
	load_text();
	break;
    case 24:
	load_sounds();
	break;
    case 25:
	load_ilbm();
	break;
    case 26:
	rtPaletteRequest( "Change Colours", NULL, TAG_END );
	break;
    case 27:
	launch();
	break;
    case 28:
	StopPlaying();
	break;
    case 29:
	ok=FALSE;
	break;
    default:
        ok=TRUE;
    }
return ok;
}

	/* ****************************************************** */
	/* 		   Handle Keycodes 			  */
	/* ****************************************************** */

BOOL do_keys( void )
{
BOOL ok=TRUE;

if( msg_code == 0x0071 || msg_code == 0x0051 ) ok=FALSE;

if( msg_code == 0x0063 || msg_code == 0x0043 )
	rtPaletteRequest( "Change Colours", NULL, TAG_END );

return ok;
}

	/* ****************************************************** */
	/* 		Scroll On-Screen Selections		  */
	/* ****************************************************** */

void move_list( int dirn )
{
if( dirn>0 && top_line<num_lines-2*NUM_LINES )
	{
	top_line+=2;
	set_slider();
	}
if( dirn<0 && top_line )
	{
	top_line-=2;
	set_slider();
	}
}

	/* ****************************************************** */
	/* 	    	Display file entries in window		  */
	/* ****************************************************** */

void DisplayIt( void )
{
struct Node *this_node;
register LONG count;
char same[34], *text;
UBYTE colour;

if( num_lines )
	{
	WinText.IText=same;	
	this_node=LineList->lh_Head;
	for(count=0; count<top_line; count++) this_node=this_node->ln_Succ;
	if( num_lines>>1 >= NUM_LINES )
		{
		for( count=0; count<NUM_LINES; count++ )
			{
			text=this_node->ln_Name;
			colour=(UBYTE)*text++;
			colour -= '0';
			if( colour>3 ) colour=1;
			WinText.FrontPen=colour;
			fix_string( text, same, 33 );
			PrintIText( win->RPort, &WinText, 0, count*9 );
			this_node=this_node->ln_Succ->ln_Succ;
			} 
		}
	else
		{
		for( count=0; count<num_lines>>1; count++ )
			{
			text=this_node->ln_Name;
			colour=(UBYTE)*text++;
			colour -= '0';
			if( colour>3 ) colour=1;
			WinText.FrontPen=colour;
			fix_string( text, same, 33 );
			PrintIText( win->RPort, &WinText, 0, count*9 );
			this_node=this_node->ln_Succ->ln_Succ;
			} 
		}
	}
}

	/* ****************************************************** */
	/* 	  Expand or clip a string to a fixed length	  */
	/* ****************************************************** */

/* Copies a string, either clipping it or expanding it to a defined width

Entry	*from	source string
	*to	dest string
	length	desired length of destination string

*/

void fix_string( char *from, char *to, int length)
{
int loop, plus;
register int i;

loop=strlen( from );

if( loop > length )
	{
	loop=length;
	plus=0;
	}
else
	plus=length-loop;

for( i=0; i<loop; i++ )	*to++ = *from++;

if( plus )
	for( i=0; i<plus; i++ ) *to++ = ' ';

*to = '\0';

}

	/* ****************************************************** */
	/*   Load a control file and build a linked list for it   */
	/* ****************************************************** */

BOOL GetControl( void )
{

register BOOL ok=FALSE;				/* return value */

if( buffer_size )
	{
	FreeMem( text_buffer, buffer_size );	/* free current list */
	buffer_size=0;
	}
if( LineList )
	{
	free_list();
	LineList=NULL;
	}

num_lines=0;
top_line=0;

if( LoadFile( filename ) )
	if( build_list() )
		ok=TRUE;
	else
		{
		FreeMem( text_buffer, buffer_size );
		buffer_size=0;
		num_lines=0;
		}

return ok;
}

	/* ****************************************************** */
	/* 	   Load a file from disk into a buffer	 	  */
	/* ****************************************************** */

BOOL LoadFile( char *name )
{
BOOL ok=FALSE;			/* return code, TRUE if file loaded */
struct FileHandle *handle;

if ( handle = ( struct FileHandle *) Open( name, MODE_OLDFILE) )
	{
	Seek( (BPTR)handle, 0, OFFSET_END );
	buffer_size=Seek((BPTR)handle, 0, OFFSET_BEGINNING );

	if ( text_buffer=(char *)AllocMem( buffer_size, MEMF_CLEAR ) )
		{
		Read( (BPTR)handle, text_buffer, buffer_size );
		ok=TRUE;
		}
	else
    		{
		rtEZRequest("No Memory\n  Aborting!","Okay",NULL,NULL);
		buffer_size=0;
		}

	Close( (BPTR)handle );
	}
else
	rtEZRequest("Cannot Open Control File.\n      Aborting!","Okay",NULL,NULL);

return ok;
}

	/* ****************************************************** */
	/* 	    Build a linked list of line pointers	  */
	/* ****************************************************** */

BOOL build_list( void )
{
UBYTE *pos;
register LONG count;
register BOOL ok=FALSE;

if( LineList=(struct List *)AllocMem( buffer_size, MEMF_CLEAR ) )
	{
	NewList( LineList );
	ok=TRUE;
	pos=text_buffer;
	add_line( pos );
	for( count=0; count<buffer_size; count++ )
		{
		if( *pos==0x0a )
			{
			*pos++=0x00;
			add_line( pos );
			}
		else
			*pos++;
		}
	}
RemTail( LineList );
num_lines--;
num_lines &= 0xfffffffe;			/* always even!!! */
return ok;
}

	/* ****************************************************** */
	/* 	    	Add Node To Line List			  */
	/* ****************************************************** */

void add_line( UBYTE *line )
{
struct Node *new_node;

if( new_node=(struct Node *)AllocMem( sizeof( struct Node ), MEMF_CLEAR ) )
	{
	new_node->ln_Name=line;
	new_node->ln_Type=MY_NODE_ID;
	new_node->ln_Pri=0;
	AddTail( LineList, new_node );
	num_lines++;
	}
}	

	/* ****************************************************** */
	/* 	    	Free a list of line pointers		  */
	/* ****************************************************** */

void free_list( void )
{
struct Node *this_node;
struct Node *next_node;

this_node=(struct Node *)(LineList->lh_Head);

while( next_node=( struct Node *)( this_node->ln_Succ ) )
	{
	FreeMem( this_node, sizeof( struct Node ) );
	this_node=next_node;
	}
FreeMem( LineList, sizeof( struct List ) );
}

	/* ****************************************************** */
	/*		    Display Date & Time			  */
	/* ****************************************************** */

void do_date( void )
{

struct tm *the_time;
struct Library *lib;
time_t compact_time;
char *days[]={ "Sun","Mon","Tue","Wed","Thur","Fri",
	      "Sat" };
char *months[]={ "January","February","March","April","May","June","July",
		 "August","September","October","November","December" };
char result[50];


lib=(struct Library *)DOSBase;

DataText.IText=result;

compact_time=time( NULL );
the_time=localtime( &compact_time );

strcpy( result, "** Information **");

PrintIText( win->RPort, &DataText, 400, 135 );

sprintf( result, "Time %02d:%02d:%02d", the_time->tm_hour, the_time->tm_min,
	the_time->tm_sec );

PrintIText( win->RPort, &DataText, 368, 150 );

sprintf( result, "Date %s %2d-%s-%4d", days[the_time->tm_wday], the_time->tm_mday,
	months[the_time->tm_mon], 1900+the_time->tm_year );

PrintIText( win->RPort, &DataText, 368, 165 );

sprintf( result, "%ldK free CHIP memory",AvailMem( MEMF_CHIP )>>10 );

PrintIText( win->RPort, &DataText, 368, 180 );

sprintf( result, "%ldK free FAST memory",AvailMem( MEMF_FAST )>>10 );

PrintIText( win->RPort, &DataText, 368, 195 );

sprintf( result, "%ldK total free memory",AvailMem( 0L )>>10 );

PrintIText( win->RPort, &DataText, 368, 210 );

sprintf( result, "DOS version %d, revision %d", lib->lib_Version,
	lib->lib_Revision);

PrintIText( win->RPort, &DataText, 368, 225 );

}

	/* ****************************************************** */
	/* Attempt to open graphics.library and intuition.library */
	/* ****************************************************** */

BOOL open_libs( void )
{

BOOL ok=FALSE;

if ( IntuitionBase = (struct IntuitionBase *)
		     OpenLibrary ( "intuition.library",0) )
	
    if ( GfxBase = (struct GfxBase *)
	       OpenLibrary( "graphics.library",0) )

	    if ( ReqToolsBase = (struct ReqToolsBase *)
		       OpenLibrary( REQTOOLSNAME, REQTOOLSVERSION ) )

		    if ( PPBase = (struct PPBase *)
			       OpenLibrary( "powerpacker.library", 0L ) )

			ok=TRUE;
return ok;
}

	/* ****************************************************** */
	/* 	Close graphics.library and intuition.library	  */
	/* ****************************************************** */

void close_libs( void )
{
if ( IntuitionBase ) CloseLibrary( (struct Library *)IntuitionBase );
if ( GfxBase ) CloseLibrary( (struct Library *)GfxBase );
if ( ReqToolsBase ) CloseLibrary( (struct Library *)ReqToolsBase );
if ( PPBase ) CloseLibrary( (struct Library *)PPBase );
}

	/* ****************************************************** */
	/* 		Load & Display A Text File		  */
	/* ****************************************************** */

void load_text( void )
{
struct FileLock *lock, *old_lock;

if( file_request=(struct rtFileRequester *)rtAllocRequestA(RT_FILEREQ, NULL))
    {
    loadname[0]=0;
    if( rtFileRequest(file_request,loadname,"Select text file",TAG_END))
	if( lock=(struct FileLock *)Lock( file_request->Dir, ACCESS_READ) )
	    {
	    old_lock=(struct FileLock *)CurrentDir( (BPTR)lock );
	    ShowFile( loadname );
	    CurrentDir( (BPTR)old_lock );
	    UnLock( (BPTR)lock );
	    }
	else
	    rtEZRequest("Could not Lock directory.","Okay",NULL,NULL);
    rtFreeRequest( (APTR)file_request );
    }
else
    rtEZRequest("Low Memory Warning\n   Aborted!","Okay",NULL,NULL);
}

	/* ****************************************************** */
	/* 	    Load & Play A NoiseTracker Module		  */
	/* ****************************************************** */

void load_sounds( void )
{
struct FileLock *lock, *old_lock;

if( file_request=(struct rtFileRequester *)rtAllocRequestA(RT_FILEREQ, NULL))
    {
    loadname[0]=0;
    if( rtFileRequest(file_request,loadname,"Select NoiseTracker Module",
		      TAG_END))
	if( lock=(struct FileLock *)Lock( file_request->Dir, ACCESS_READ) )
	    {
	    old_lock=(struct FileLock *)CurrentDir( (BPTR)lock );
	    PlayFile( loadname );
	    CurrentDir( (BPTR)old_lock );
	    UnLock( (BPTR)lock );
	    }
	else
	    rtEZRequest("Could not Lock directory.","Okay",NULL,NULL);
    rtFreeRequest( (APTR)file_request );
    }
else
    rtEZRequest("Low Memory Warning\n   Aborted!","Okay",NULL,NULL);
}

	/* ****************************************************** */
	/* 		Load & Display An IFF File		  */
	/* ****************************************************** */

void load_ilbm( void )
{
struct FileLock *lock, *old_lock;

if( file_request=(struct rtFileRequester *)rtAllocRequestA(RT_FILEREQ, NULL))
    {
    loadname[0]=0;
    if( rtFileRequest(file_request,loadname,"Select IFF-ILBM file",TAG_END))
	if( lock=(struct FileLock *)Lock( file_request->Dir, ACCESS_READ) )
	    {
	    old_lock=(struct FileLock *)CurrentDir( (BPTR)lock );
	    ViewILBM( loadname );
	    CurrentDir( (BPTR)old_lock );
	    UnLock( (BPTR)lock );
	    }
	else
	    rtEZRequest("Could not Lock directory.","Okay",NULL,NULL);
    rtFreeRequest( (APTR)file_request );
    }
else
    rtEZRequest("Low Memory Warning\n   Aborted!","Okay",NULL,NULL);
}

	/* ****************************************************** */
	/* 		  Run An Executable File		  */
	/* ****************************************************** */

/* this routine allows the user to launch a command file with a parameter
   list, as if invoked from the CLI. A console is opened for any output
   from the window. The console is not closed until a requester is 
   satisfied. */

void launch( void )
{
struct FileLock *lock, *old_lock;
char param[205];
char command[260];
struct FileHandle *handle;

if( file_request=(struct rtFileRequester *)rtAllocRequestA(RT_FILEREQ, NULL))
    {
    loadname[0]=0;
    if( rtFileRequest(file_request,loadname,"Select Program",TAG_END))
	if( lock=(struct FileLock *)Lock( file_request->Dir, ACCESS_READ) )
	    {
	    old_lock=(struct FileLock *)CurrentDir( (BPTR)lock );
	    rtGetString( param, 200, "CLI parameter list", NULL, TAG_END );
	    strcpy( command, loadname );
	    strcat( command, " ");
	    strcat( command,param);
	    handle=(struct FileHandle *)Open( "con:0/100/640/155/ACC",
					      MODE_NEWFILE);
	    Execute( command, 0L,(BPTR)handle );
	    rtEZRequest("Close console.","Close",NULL,NULL);
	    if( handle ) Close( (BPTR)handle );
	    CurrentDir( (BPTR)old_lock );
	    UnLock( (BPTR)lock );
	    }
	else
	    rtEZRequest("Could not Lock directory.","Okay",NULL,NULL);
    rtFreeRequest( (APTR)file_request );
    }
else
    rtEZRequest("Low Memory Warning\n   Aborted!","Okay",NULL,NULL);
}

