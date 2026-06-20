/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: stack.c -- EGS stack language           */
/*    |< |      created: Feb. 26, 1995                        */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/

#include <exec/types.h>
#include <exec/memory.h>


#include <egs/egsintuigfx.h>

#include "common.h"
#include "layers.h"


extern void *GarpBase;


void op_spolygon( struct context *glob );

struct operation {
  void (*vector)();
  int  argc;
};

/* third level of function look-up tables */
struct operation program_ctrl[]={
  0,       0,
  op_jmp,  1,
  op_rts,  0,
  op_jsr,  1,
  op_call, 0
  };

struct operation stack_frame[]={
  0,         0,
  op_pop,    1,
  op_dup,    1,
  op_swap,   2,
  op_rot3,   3,
  op_rotn,   1,
  op_val,    1,
  op_adr,    1,
  op_get1,   2,
  op_get2,   3,
  op_getn,   1,
  op_popn,   1,
  op_dupn,   1,
  op_getf,   1,
  op_putf,   1,
  op_stkadr, 0
  };

struct operation pokes[]={
  0,         0,
  0,         0,
  0,         0,
  op_pokeb,  2,
  op_pokew,  2,
  op_poke,   2
  };

struct operation math_boolean[]={
  0,         0,
  op_add,    2,
  op_neg,    1,
  op_sub,    2,
  op_mul,    2,
  op_seq,    2,
  op_sne,    2,
  op_sgt,    2,
  op_slt,    2,
  op_sge,    2,
  op_sle,    2,
  op_snot,   1,
  op_sand,   2,
  op_sor,    2,
  op_idiv,   2,
  op_imod,    2
  };

struct operation query[]={
  0,           0,
  op_getposx,  0,
  op_getpoxy,  0,
  op_getcolor, 0,
  op_getback,  0
  };

struct operation graphics[]={
  0,           0,
  op_color,    1,
  op_back,     1,
  op_modea,    0,
  op_modeab,   0,
  op_image,    0,
  op_move,     2,
  op_draw,     2,
  op_write,    2,
  op_box,      2,
  op_locate,   2,
  op_locate00, 0,
  op_packed,   0,
  op_font,     1,
  op_drawabs,  2,
  op_text,     2
  };

struct operation colors[]={
  op_clight,     0,
  op_cnormal,    0,
  op_cdark,      0,
  op_cselect,    0,
  op_cback,      0,
  op_ctxtfront,  0,
  op_ctxtback,   0
  };
struct operation loops[]={
  0,          0,
  op_while,   0,
  op_do,      1,
  op_if,      1,
  op_else,    0,
  op_end,     0,
  op_repeat,  0,
  op_until,   1
  };

struct operation debug[]={
  op_debug,   0
  };

struct operation scale_global[]={
  op_setscale,  2,
  op_setratio,  2
  };

struct operation scale_relative[]={
  0,             0,
  op_smove,      2,
  op_slocate,    2,
  op_sdraw,      2,
  op_sdrawabs,   2,
  op_scurve,     4,
  op_scurveabs,  4,
  op_sellipse,   4,
  op_sbox,       2,
  op_sbox2d,     2,
  op_spolygon,   1
  };

struct operation scale_absolute[]={
  0,             0,
  op_samove,     2,
  op_salocate,   2,
  op_sadraw,     2,
  op_sadrawabs,  2,
  op_sacurve,    2,
  op_sacurveabs, 2,
  op_saellipse,  4
  };

struct operation scale_misc[]={
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,
  op_saend, 0
  };

struct operation gfx_exten[]={
  0,          0,
  0,          0,
  0,          0,
  op_box2d,   2
  };

struct operation gfx_coor[]={
  op_DUP2,    2,
  op_ADD2,    2,
  op_SUB2,    2,
  0,          0
  };

/* second level of function look-up tables */
struct operation *oper0[]={
  program_ctrl,
  stack_frame,
  math_boolean,
  query,
  graphics,
  colors
  };

struct operation *oper1[]={
  loops,
  pokes
  };

struct operation *oper2[]={
  debug
  };

struct operation *oper3[]={
  scale_global,
  scale_relative,
  scale_absolute,
  scale_misc
  };

struct operation *oper4[]={
  gfx_exten,
  gfx_coor
  };

struct operation global_query[]={
  op_getwidth,    0,
  op_getheight,   0,
  op_getframe,    0,
  op_expandframe, 0
  };

struct operation font_support[]={
  op_getfontbaseline,  0,
  op_getfontwidth,     0,
  op_getfontheight,    0,
  op_getnstringwidth,  1,
  op_getcstringwidth,  2,
  op_centernstring,    1,
  op_centercstring,    2,
  op_home,             0
  };

struct operation gstate_mods[]={
  op_setlinewidth,    1,
  op_setround,        1,
  op_setclip,         2,
  op_clearclip,       0
  };

struct operation more_junk[]={
  op_greater,    2,
  op_lesser,     2
  };

struct operation postscript[]={
  op_newpath,     0,
  op_closepath,   0,
  op_lineto,      2,
  op_moveto,      2,
  op_rlineto,     2,
  op_rmoveto,     2,
  op_stroke,      0,
  op_fill,        0,
  0,              0
  };

struct operation *oper5[]={
  global_query,
  font_support,
  gstate_mods,
  more_junk,
  postscript,
  0
  };


/* first level of function look-up tables. */
struct operation **operators[]={
  oper0,
  oper1,
  oper2,
  oper3,
  oper4,
  oper5
  };

/* immediate operand function look-up table */
struct operation immediate[]={
  0,          0,
  op_const,   0,
  op_getfi,   0,
  op_putfi,   0,
  op_getsi,   0,
  op_frame,   0,
  op_rtf,     0,
  op_addi,    1,
  op_dupi,    0,
  op_const24, 0,
  op_popi,    0,
  0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0,
  op_justifyntext,  1,
  op_justifyctext,  2,
  op_nudgecursor,   0
  };


#define COLOR_LIGHT    0
#define COLOR_NORMAL   1
#define COLOR_DARK     2
#define COLOR_SELECT   3
#define COLOR_BACK     4
#define COLOR_TXTFRONT 5
#define COLOR_TXTBACK  6

ulong global_colors[]={ 7, 7, 0, 7, 0, 7, 0 };





void error( int num )
{
  Alert(0x86670000|num);
}

extern struct TagItem nil_tag;

struct stack_program *newstack( ULONG *source, struct TagItem *tags )
{
  struct stack_program *stack;

  if(!tags)tags=&nil_tag;

  if(stack=(struct stack *)allocobject(GT_Stack,sizeof(struct stack_program)))
    {
      stack->usecount = 1;
      /*
       * In the future, I'll figure out how
       * to implement semaphores on just
       * a pointer.  Part of roo.library.
       */
      GetTagData(SA_SEMAPHORE,NULL,tags);
  
      InitSemaphore(&stack->lock);
      stack->source = source;
      stack->stacksize = GetTagData(SA_STACKSIZE,STACK_DEFAULTSIZE,tags);
      stack->framesize = GetTagData(SA_FRAMESIZE,STACK_DEFAULTFRAME,tags);
      stack->frame_org = (struct G_DataTag *)GetTagData(SA_DATATAGS,NULL,tags);
      stack->initial_frame = (unsigned long)GetTagData(SA_DATAPTR,NULL,tags);
      stack->colors =  (ulong *) GetTagData(SA_COLORS,NULL,tags);
      stack->font =   (struct font *)GetTagData(SA_FONT,NULL,tags);

      return stack;
    }
  return NULL;
}

void disposestack( struct stack_program *stack )
{
  if(!(--stack->usecount))
    {
      freeobject(stack);
    }
  return;
}

struct stack_program *usestack( struct stack_program *stack )
{
  stack->usecount++;
  return stack;
}

void execute( struct context *glob, ulong *prog )
{
  int nest;

  union {
    unsigned char bytes[4];
    unsigned short words[4];
    unsigned long value;
  }current;

  glob->pc=prog;

  nest=++glob->enest;

  while(glob->enest==nest)
    {
      current.value=*glob->pc++;

      if(current.bytes[0]&0x80)
	if(current.bytes[0]==0x80)
	  {
	    if(glob->stackcnt>=operators[current.bytes[2]][current.bytes[3]>>4][current.bytes[3]&0xf].argc)
	      (*operators[current.bytes[2]][current.bytes[3]>>4][current.bytes[3]&0xf].vector)(glob);
	    else error(G_SERROR_STACK_UNDERFLOW);
	  }
	else
	  {
	    if(glob->stackcnt>=immediate[current.bytes[0]&0x7f].argc)
	      (*immediate[current.bytes[0]&0x7f].vector)(glob,current.value);
	    else error(G_SERROR_STACK_UNDERFLOW);
	  }
      else
	{ /* just a long number to be used. */
	  (--glob->stackp)->uval=current.value;
	  glob->stackcnt++;
	}
    }
  return;
}

void beginstack( struct layer *layer, struct stack_program *prog, int argc, ulong *argv )
{
  int i;
  int size;
  struct context glob;

  glob.gstate.layer    = layer;
  glob.gstate.font     = prog->font;

  glob.stack    = (union operand *)allocm(4*prog->stacksize);
  glob.stackp   = glob.stack+prog->stacksize-argc;
  for(i=0;i<argc;i++)glob.stackp[i].uval=argv[i];
  glob.stackcnt = argc;

  glob.colors[0] = prog->colors[0];
  glob.colors[1] = prog->colors[1];
  glob.colors[2] = prog->colors[2];
  glob.colors[3] = prog->colors[3];
  glob.colors[4] = prog->colors[4];
  glob.colors[5] = prog->colors[5];
  glob.colors[6] = prog->colors[6];
  glob.gstate.gc.FgPen      = glob.colors[COLOR_NORMAL];
  glob.gstate.gc.BgPen      = glob.colors[COLOR_BACK];
  glob.gstate.gc.DrawMode  = GC_JAM2;
  glob.gstate.gc.Round     = 0;
  glob.gstate.gc.LineWidth = 0; 
  glob.gstate.gc.Area      = NULL;
  glob.gstate.cursor.xy = glob.gstate.origin.xy = 0;

  glob.frame      = (union operand *)allocm(4*prog->framesize);
  glob.framep     = &glob.frame[prog->framesize];
  glob.frame_size = 0;

  if(isSUPER(layer))
    {
      glob.gstate.scale.coor.x = rectwidth(layer->refresh.super.bounds);
      glob.gstate.scale.coor.y = rectheight(layer->refresh.super.bounds);
    }
  else
    {
      glob.gstate.scale.coor.x = rectwidth(layer->bounds);
      glob.gstate.scale.coor.y = rectheight(layer->bounds);
    }

  if(prog->initial_frame)
    {
      while(prog->frame_org[glob.frame_size].Type)
	glob.frame_size++;

      glob.framep -= glob.frame_size;
      
      for(i=0;i<glob.frame_size;i++)
	{
	  switch(prog->frame_org[i].Type&G_DATA_MASK)
	    {
	    case G_DATA_BYTE:
	      glob.framep[i].ival=*((char *)(prog->initial_frame+prog->frame_org[i].Offset));
	      break;
	    case G_DATA_UBYTE:
	      glob.framep[i].uval=*((unsigned char *)(prog->initial_frame+prog->frame_org[i].Offset));
	      break;
	    case G_DATA_WORD:
	      glob.framep[i].ival=*((short *)(prog->initial_frame+prog->frame_org[i].Offset));
	      break;
	    case G_DATA_UWORD:
	      glob.framep[i].uval=*((unsigned short *)(prog->initial_frame+prog->frame_org[i].Offset));
	      break;
	    case G_DATA_LONG:
	      glob.framep[i].ival=*((long *)(prog->initial_frame+prog->frame_org[i].Offset));
	      break;
	    case G_DATA_ULONG:
	      glob.framep[i].uval=*((unsigned long *)(prog->initial_frame+prog->frame_org[i].Offset));
	      break;
	    default:
	      error(G_SERROR_FRAME_INITIALIZATION);
	      break;
	    }
	}
    }
  /*
   * Save here and check at the
   * end.
   */
  size = glob.frame_size;

  glob.mode = NULL;
  glob.loopnest = 0;
  glob.ifnest   = 0;
  glob.enest    = 1;
  execute(&glob,prog->source);

  /*
   * If the frame is not the same size
   * then don't risk copying values 
   * back into data.
   */
  if(size!=glob.frame_size)error(0xdead);
  

  /* now copy the frame back. */
  if(prog->initial_frame)
    for(i=0;i<glob.frame_size;i++)
      {
	switch(prog->frame_org[i].Type)
	  {	    
	  case G_DATA_BYTE|G_DATA_COPYBACK:
	    *((char *)(prog->initial_frame+prog->frame_org[i].Offset))=glob.framep[i].ival;
	    break;
	  case G_DATA_UBYTE|G_DATA_COPYBACK:
	    *((unsigned char *)(prog->initial_frame+prog->frame_org[i].Offset))=glob.framep[i].uval;
	    break;
	  case G_DATA_WORD|G_DATA_COPYBACK:
	    *((short *)(prog->initial_frame+prog->frame_org[i].Offset))=glob.framep[i].ival;
	    break;
	  case G_DATA_UWORD|G_DATA_COPYBACK:
	    *((ushort *)(prog->initial_frame+prog->frame_org[i].Offset))=(ushort)glob.framep[i].uval;
	    break;
	  case G_DATA_LONG|G_DATA_COPYBACK:
	    *((long *)(prog->initial_frame+prog->frame_org[i].Offset))=(long)glob.framep[i].ival;
	    break;
	  case G_DATA_ULONG|G_DATA_COPYBACK:
	    *((ulong *)(prog->initial_frame+prog->frame_org[i].Offset))=(ulong)glob.framep[i].uval;
	    break;
	  }
      }

  freem(glob.stack);
  freem(glob.frame);
  return;
}



  
void op_jmp(  struct context *glob )
/* jumps to the address sp[0]. */
{
  glob->pc = (unsigned long *)glob->stackp[0].addr;

  glob->stackcnt--;
  glob->stackp++;

  /* jmp will exit from any loops. */
  glob->enest -= glob->loopnest;

  return;
}

void op_rts( struct context *glob )
/* return from a subroutine without frame deallocation. */
{
  /* exits all loops and conditional segments, then one level more. */
if(glob->loopnest)Alert(0xdeadcabb);
if(glob->enest!=2)Alert(0xdeaddead);
  glob->enest -= glob->loopnest+1;

  return;
}

void op_jsr( struct context *glob )
/* calls a subroutine at the specified location. */
{
  ulong *pc;
  ulong temp[3];
  struct gstate old;

  /* Save the current graphics state. */
  old = glob->gstate;

  /* save the the current execution state. */
  pc = glob->pc;
  temp[0] = glob->mode;
  temp[1] = glob->loopnest;
  temp[2] = glob->ifnest;

  glob->mode     = NULL;
  glob->loopnest = 0;
  glob->ifnest   = 0;

  glob->stackp++;
  glob->stackcnt--;
  execute(glob,glob->stackp[-1].addr);

  glob->pc       = pc;
  glob->mode     = temp[0];
  glob->loopnest = temp[1];
  glob->ifnest   = temp[2];

  return;
}

void op_call( struct context *glob )
/* undefine use. */
{
  error(G_SERROR_NOTIMPLEMENTED);
  return;
}

void op_pop( struct context *glob )
/* removes the topmost stack element. */
{
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_dup( struct context *glob )
/* duplicates the topmost stack element. */
{
  glob->stackp[-1] = *glob->stackp;
  glob->stackp--;
  glob->stackcnt++;

  return;
}

void op_swap( struct context *glob )
/* swaps the two topmost stack elements. */
{
  union operand temp;

  temp            = glob->stackp[0];
  glob->stackp[0] = glob->stackp[1];
  glob->stackp[1] = temp;

  return;
}

void op_rot3( struct context *glob )
/* rotates the topmost three elements. */
{
  union operand temp;

  temp            = glob->stackp[0];
  glob->stackp[0] = glob->stackp[2];
  glob->stackp[2] = glob->stackp[1];
  glob->stackp[1] = temp;

  return;
}

void op_rotn( struct context *glob )
/* rotates as many elements as specified by sp[0]. */
{
  int i,n;
  union operand temp;

  n = (glob->stackp++)->ival;
  glob->stackcnt--;

  if(glob->stackcnt<n)error(G_SERROR_STACK_UNDERFLOW);

  temp = glob->stackp[n-1];
  for(i=n-1;i;i--)glob->stackp[i]=glob->stackp[i-1];
  *glob->stackp = temp;

  return;
}

void op_val( struct context *glob )
/* reads a word from the memory address SP^. */
{

  glob->stackp->ival = *((int *)(glob->stackp->addr));

  return;
}

void op_adr( struct context *glob )
/* reads a long word from the memory address SP^. */
{

  glob->stackp->uval = *((unsigned long *)(glob->stackp->addr));

  return;
}

void op_get1( struct context *glob )
/* gets the second stack element. */
{
  glob->stackp[-1] = glob->stackp[1];
  glob->stackp--;
  glob->stackcnt++;

  return;
}

void op_get2( struct context *glob )
/* gets the third stack element */
{
  glob->stackp[-1] = glob->stackp[2];
  glob->stackp--;
  glob->stackcnt++;

  return;
}

void op_getn( struct context *glob )
/* gets the sp[0]'th stack element */
{
  if(glob->stackcnt<glob->stackp[0].uval+1)error(G_SERROR_STACK_UNDERFLOW);

  glob->stackp[0] = glob->stackp[glob->stackp[0].uval+1];

  return;
}

void op_popn( struct context *glob )
/* removes the number of stack elements as specified by sp[0]. */
{
  if(glob->stackcnt<glob->stackp[0].uval+1)error(G_SERROR_STACK_UNDERFLOW);

  glob->stackcnt -= glob->stackp[0].uval+1;
  glob->stackp   += glob->stackp[0].uval+1;

  return;
}

void op_dupn( struct context *glob )
/* duplicates as many elements as secified by sp[0]. */
{
  int i,n;

  if(glob->stackcnt<glob->stackp[0].ival+1)error(G_SERROR_STACK_UNDERFLOW);

  n = (glob->stackp++)->ival;
  for(i=1;i<=n;i++)glob->stackp[-i]=glob->stackp[n-i];
  glob->stackp   -= n;
  glob->stackcnt += n-1;

  return;
}

void op_getf( struct context *glob )
/* gets the sp[0]'th frame element. */
{
  if(glob->frame_size<glob->stackp[0].uval)error(G_SERROR_FRAME_BOUNDS);
  
  glob->stackp[-1] = glob->framep[glob->stackp[0].uval];
  glob->stackp--;
  glob->stackcnt++;

  return;
}

void op_putf( struct context *glob )
/* writes sp[1] to the frame element specified by sp[0]. */
{
  if(glob->frame_size<glob->stackp[0].uval)error(G_SERROR_FRAME_BOUNDS);

  glob->framep[glob->stackp[0].uval] = glob->stackp[1];
  glob->stackp   += 2;
  glob->stackcnt -= 2;

  return;
}

void op_stkadr( struct context *glob )
/* pushes the actual value fo the stackpointer onto the stack. */
{
  glob->stackp[-1].addr = (void *)glob->stackp;
  glob->stackp--;
  glob->stackcnt++;

  return;
}

void op_pokeb( struct context *glob )
/* writes byte value to memory address. */
{
  *((unsigned char *)glob->stackp[1].addr)=(unsigned char)glob->stackp[0].uval;
  glob->stackp   += 2;
  glob->stackcnt -= 2;
  return;
}

void op_pokew( struct context *glob )
/* writes word value to memory address */
{
  *((unsigned short *)glob->stackp[1].addr)=(unsigned short)glob->stackp[0].uval;
  glob->stackp   += 2;
  glob->stackcnt -= 2;

  return;
}

void op_poke( struct context *glob )
{
  *((unsigned long *)glob->stackp[1].addr)=glob->stackp[0].uval;
  glob->stackp   += 2;
  glob->stackcnt -= 2;

  return;
}

void op_add( struct context *glob )
/* adds the two topmost stack elements. */
{
  glob->stackp[1].ival += glob->stackp[0].ival;
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_neg( struct context *glob )
/* negates the topmost stack element */
{
  glob->stackp[0].ival = -glob->stackp[0].ival;

  return;
}

void op_sub( struct context *glob )
/* subtracts the first stack element from the second. */
{
  glob->stackp[1].ival -= glob->stackp[0].ival;
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_mul( struct context *glob )
/* multiplies the two topmost stack elements */
{
  glob->stackp[1].ival *= glob->stackp[0].ival;
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_seq( struct context *glob )
{
  glob->stackp[1].uval=(glob->stackp[0].ival==glob->stackp[1].ival?TRUE:FALSE);
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_sne( struct context *glob )
{
  glob->stackp[1].uval=(glob->stackp[0].ival!=glob->stackp[1].ival?TRUE:FALSE);
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_sgt( struct context *glob )
{
  glob->stackp[1].uval=(glob->stackp[1].ival>glob->stackp[0].ival?TRUE:FALSE);
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_slt( struct context *glob )
{
  glob->stackp[1].uval=(glob->stackp[1].ival<glob->stackp[0].ival?TRUE:FALSE);
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_sge( struct context *glob )
{
  glob->stackp[1].uval=(glob->stackp[1].ival>=glob->stackp[0].ival?TRUE:FALSE);
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_sle( struct context *glob )
{
  glob->stackp[1].uval=(glob->stackp[1].ival<=glob->stackp[0].ival?TRUE:FALSE);
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_snot( struct context *glob )
{
  glob->stackp[0].uval=!glob->stackp[0].uval;

  return;
}

void op_sand( struct context *glob )
{
  glob->stackp[1].uval=glob->stackp[1].uval&&glob->stackp[0].uval;
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_sor( struct context *glob )
{
  glob->stackp[1].uval=glob->stackp[1].uval||glob->stackp[0].uval;
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_idiv( struct context *glob )
/* divides the second stack element by the first. */
{
  if(!glob->stackp[0].ival)error(G_SERROR_DIVIDE_BY_ZERO);

  glob->stackp[1].ival/=glob->stackp[0].ival;
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_imod( struct context *glob )
/* divides the second stack element by the first and yields the
   modulus of the operation. */
{
  if(!glob->stackp[0].ival)error(G_SERROR_DIVIDE_BY_ZERO);

  glob->stackp[1].ival %= glob->stackp[0].ival;
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_getposx( struct context *glob )
/* gets the current cursor x coordinate */
{
  (--glob->stackp)->ival = glob->gstate.cursor.coor.x-glob->gstate.origin.coor.x;
  glob->stackcnt++;

  return;
}

void op_getpoxy( struct context *glob )
/* gets the current cursor y coordinate */
{
  (--glob->stackp)->ival = glob->gstate.cursor.coor.y-glob->gstate.cursor.coor.y;
  glob->stackcnt++;

  return;
}

void op_getcolor( struct context *glob )
/* gets the current drawing color. */
{
  (--glob->stackp)->uval = glob->gstate.gc.FgPen;
  glob->stackcnt++;

  return;
}

void op_getback( struct context *glob )
/* gets the current background pen. */
{
  (--glob->stackp)->uval = glob->gstate.gc.BgPen;
  glob->stackcnt++;

  return;
}

void op_color( struct context *glob )
/* sets the current color to the value in sp[0]. */
{
  glob->gstate.gc.FgPen = (glob->stackp++)->uval;
  glob->stackcnt--;

  return;
}

void op_back( struct context *glob )
/* sets the background color to the value in sp[0]. */
{
  glob->gstate.gc.BgPen = (glob->stackp++)->uval;
  glob->stackcnt--;

  return;
}

void op_modea( struct context *glob )
/* sets drawing mode "drawAPen" */
{
  glob->gstate.gc.DrawMode = (glob->gstate.gc.DrawMode&(~GC_DRWMDMASK))|GC_JAM1;

  return;
}

void op_modeab( struct context *glob )
/* sets drawing mode "drawABPen" */
{
  glob->gstate.gc.DrawMode = (glob->gstate.gc.DrawMode&(~GC_DRWMDMASK))|GC_JAM2;

  return;
}

void op_image( struct context *glob )
/* copies the contents of a BitMap specified by sp[0] to the
   current cursor position. */
{
/*  lcopybitmap(glob->gstate.layer,&glob->gstate.gc,glob->gstate.cursor.coor.x,
	                                          glob->gstate.cursor.coor.y,
	                                          glob->stackp[0].map->Width,
	                                          glob->stackp[0].map->Height,
	                                          glob->stackp[0].map,0,0); */
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_move( struct context *glob )
/* moves the graphics cursor by the distance in {sp[1],sp[0]}. */
{
  glob->gstate.cursor.coor.x += glob->stackp[1].ival;
  glob->gstate.cursor.coor.y += glob->stackp[0].ival;

  glob->stackp   += 2;
  glob->stackcnt -= 2;

  return;
}

void op_draw( struct context *glob )
/* draws a line by {sp[1],sp[0]} relative from the cursor position. */
{
  lline(glob->gstate.layer,&glob->gstate.gc,glob->gstate.cursor.coor.x,
	                                      glob->gstate.cursor.coor.y,
	glob->gstate.cursor.coor.x+glob->stackp[1].ival,
	glob->gstate.cursor.coor.y+glob->stackp[0].ival);

  glob->stackp+=2;
  glob->stackcnt-=2;

  return;
}

void op_write( struct context *glob )
/* writes text to the current cursor position. sp[0] is the string
 * pointer.  the first byte contains the string length, followed
 * by the string characters. */
{
  ltext(glob->gstate.font,glob->gstate.layer,&glob->gstate.gc,
	glob->gstate.cursor.coor.x,
	glob->gstate.cursor.coor.y,
	glob->stackp[0].string+1,
	*glob->stackp[0].string);

  glob->stackp   += 2;
  glob->stackcnt -= 2;

  return;
}

void op_box( struct context *glob )
/* draws a filled rectangle with width sp[1] and height sp[0] */
{
  lrectanglefill(glob->gstate.layer,&glob->gstate.gc,glob->gstate.cursor.coor.x,
		                                       glob->gstate.cursor.coor.y,
		                                       glob->stackp[1].uval,
		                                       glob->stackp[0].uval);
  glob->stackp   += 2;
  glob->stackcnt -= 2;

  return;
}

void op_locate( struct context *glob )
/* sets the cursor to the position {sp[1],sp[0]}. */
{
  glob->gstate.cursor.coor.x = glob->stackp[1].ival+glob->gstate.origin.coor.x;
  glob->gstate.cursor.coor.y = glob->stackp[0].ival+glob->gstate.origin.coor.y;
  glob->stackp   += 2;
  glob->stackcnt -= 2;

  return;
}

void op_locate00( struct context *glob )
/* resets the cursor to the origin */
{
  glob->gstate.cursor.xy = glob->gstate.origin.xy;

  return;
}

void op_packed( struct context *glob )
/* unpacks an image from bit plane form and copies it to the
   current cursor position. */
{
  glob->stackp+=2;
  glob->stackcnt-=2;

  return;
}

void op_font( struct context *glob )
/* sets a font given to sp[0]. */
{
  if(!checkobject(glob->stackp[0].addr,GT_Font))error(G_SERROR_BAD_FONT);

  glob->gstate.font = glob->stackp[0].addr;
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_drawabs( struct context *glob )
/* draws a line from the cursor to the point {sp[1],sp[0]}. */
{
  lline(glob->gstate.layer,&glob->gstate.gc,glob->gstate.cursor.coor.x,
	glob->gstate.cursor.coor.y,
	glob->stackp[1].ival+glob->gstate.origin.coor.x,
	glob->stackp[0].ival+glob->gstate.origin.coor.y);

  glob->stackp   += 2;
  glob->stackcnt -= 2;

  return;
}

void op_box2d( struct context *glob )
/* draws a rectangular border with width sp[1] and height sp[0]. */
{
  lrectangle(glob->gstate.layer,&glob->gstate.gc,glob->gstate.cursor.coor.x,
	                                         glob->gstate.cursor.coor.y,
	                                         glob->stackp[1].uval,
	                                         glob->stackp[0].uval);
  glob->stackp   += 2;
  glob->stackcnt -= 2;

  return;
}

void op_text( struct context *glob )
/* writes text to the current cursor position aus.  sp[0] is the
   string pointer to a null-terminated string.  this procedure
   should be used by C programmers. */
{
  ltext(glob->gstate.font,glob->gstate.layer,&glob->gstate.gc,
	glob->gstate.cursor.coor.x,glob->gstate.cursor.coor.y,
	glob->stackp[0].string,
	strlen(glob->stackp[0].string));

  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_clight( struct context *glob )
/* gets the light window color. */
{
  (--glob->stackp)->uval = global_colors[COLOR_LIGHT];
  glob->stackcnt++;

  return;
}

void op_cnormal( struct context *glob )
/* gets the normal window border color. */
{
  (--glob->stackp)->uval = global_colors[COLOR_NORMAL];
  glob->stackcnt++;

  return;
}

void op_cdark( struct context *glob )
/* gets the dark window color. */
{
  (--glob->stackp)->uval = global_colors[COLOR_DARK];
  glob->stackcnt++;

  return;
}

void op_cselect( struct context *glob )
/* gets the 'selected' window color. */
{
  (--glob->stackp)->uval = glob->colors[COLOR_SELECT];
  glob->stackcnt++;

  return;
}

void op_cback( struct context *glob )
/* gets the window background color. */
{
  (--glob->stackp)->uval = glob->colors[COLOR_BACK];
  glob->stackcnt++;

  return;
}

void op_ctxtfront( struct context *glob )
/* gets the recommended window text front color. */
{
  (--glob->stackp)->uval = glob->colors[COLOR_TXTFRONT];
  glob->stackcnt++;

  return;
}

void op_ctxtback( struct context *glob )
/* gets the recommended window text background color. */
{
  (--glob->stackp)->uval = glob->colors[COLOR_TXTBACK];
  glob->stackcnt++;

  return;
}

void op_while( struct context *glob )
{
  ulong temp;
  ulong *temp2;

  temp  = glob->mode;
  temp2 = glob->loop;

  glob->loop = glob->pc;
  glob->mode = IG_While;
  glob->loopnest++;
  execute(glob,glob->pc+1);

  glob->mode = temp;
  glob->loop = temp2;

  return;
}

void op_do( struct context *glob )
{
  if(!glob->stackp[0].uval)
    { /* skip loop. */
      for(;*glob->pc!=IG_End;glob->pc++);
      glob->pc++;

      glob->stackp++;
      glob->stackcnt--;

      glob->loopnest--;
      glob->enest--;
    }
	
  return;
}

void op_if( struct context *glob )
{
  ulong temp;

  temp = glob->mode;

  if(!glob->stackp[0].uval)
    {
      glob->stackp++;
      glob->stackcnt--;
      
      for(;(*glob->pc!=IG_End);glob->pc++)
	if(*glob->pc==IG_Else)
	  {
	    glob->pc++;

	    glob->ifnest++;
	    glob->mode = IG_Else;
	    execute(glob,glob->pc);
	    glob->mode = temp;
	    return;
	  }
      glob->pc++;
    }
  else
    {
      glob->stackp++;
      glob->stackcnt--;

      glob->mode = IG_If;
      glob->ifnest++;
      execute(glob,glob->pc);
      glob->mode = temp;
    }

  return;
}

void op_else( struct context *glob )
{
  if(glob->mode!=IG_If)error(G_SERROR_IMPROPER_ELSE);

  for(;*glob->pc!=IG_End;glob->pc++);
  glob->pc++;

  glob->ifnest--;
  glob->enest--;

  return;
}

void op_end( struct context *glob )
{
  switch(glob->mode)
    {
    case IG_While:
      glob->pc = glob->loop;
      break;

    case IG_If:
    case IG_Else:
      glob->enest--;
      glob->ifnest--;
      break;

    default:
      error(G_SERROR_IMPROPER_ELSE);
      break;
    }

  return;
}

void op_repeat( struct context *glob )
{
  ulong temp,*temp2;

  temp  = glob->mode;
  temp2 = glob->loop;

  glob->mode = IG_Repeat;
  glob->loop = glob->pc;
  glob->loopnest++;
  execute(glob,glob->loop);
  
  glob->mode = temp;
  glob->loop = temp2;

  return;
}

void op_until( struct context *glob )
{
  if(glob->mode!=IG_Do)error(G_SERROR_IMPROPER_LOOP);

  if(glob->stackp[0].uval)
    {
      glob->pc = glob->loop;
    }
  else
    {
      glob->stackp++;
      glob->stackcnt--;

      glob->loopnest--;
      glob->enest--;
    }

  return;
}

void op_debug( struct context *glob )
{
  return;
}

void op_const( struct context *glob, unsigned long value )
/* pushes a constant onto the stack. */
{
  int x;

  x=(value&0x7fff)|(value&0x4000?0xffff8000:0);
  (--glob->stackp)->ival=x;
  glob->stackcnt++;

  return;
}

void op_getfi( struct context *glob, unsigned long value )
/* get the frame element specified by GETFI */
{
  int i;

  i=value&0xffff;
  if(glob->frame_size<(i-1))error(G_SERROR_FRAME_BOUNDS);

  *(--glob->stackp) = glob->framep[i];
  glob->stackcnt++;

  return;
}

void op_putfi( struct context *glob, unsigned long value )
/* writes sp[0] to the frame element specified by PUTFI. */
{
  int i;

  i=value&0xffff;
  if(glob->frame_size<i)error(G_SERROR_FRAME_BOUNDS);

  glob->framep[i] = glob->stackp[0];
  glob->stackp++;
  glob->stackcnt--;

  return;
}

void op_getsi( struct context *glob, unsigned long value )
/* gets the stack element specified by GETSI. */
{
  if(glob->stackcnt<=value&0xffff)error(G_SERROR_STACK_UNDERFLOW);

  (--glob->stackp)->uval = glob->stackp[value&0xffff].uval;
  glob->stackcnt++;

  return;
}

void op_frame( struct context *glob, unsigned long value )
/* makes space for size value on the frame.?? */
{
  glob->frame_size += value&0xffff;
  glob->framep     -= value&0xffff;

  return;
}

void op_rtf( struct context *glob, unsigned long value )
/* return from a subroutine with frame deallocation. */
{
  if(glob->frame_size < value&0xffff)error(G_SERROR_FRAME_UNDERFLOW);
  
  glob->framep     += value&0xffff;
  glob->frame_size -= value&0xffff;
  glob->enest--;

  return;
}

void op_addi( struct context *glob, unsigned long value )
/* adds the ADDI constant to sp[0]. */
{
  int x;

  x = (value&0x7fff)|(value&0x4000?0xffff8000:0);
  glob->stackp[0].ival += x;

  return;
}

void op_dupi( struct context *glob, unsigned long value )
/* duplicates as many elements as specified by DUPI. */
{
  int i,n;

  n = value&0xffff;
  if(glob->stackcnt<n)error(G_SERROR_STACK_UNDERFLOW);

  for(i=1;i<=n;i++)glob->stackp[-i]=glob->stackp[n-i];
  glob->stackp   -= n;
  glob->stackcnt += n-1;

  return;
}

void op_const24( struct context *glob, unsigned long value )
/* pushes the constant in Const24 shifted left by eight bits onto
   the stack (for 24 bit colors). */
{
  (--glob->stackp)->uval = value<<8;
  glob->stackcnt++;

  return;
}

void op_popi( struct context *glob, unsigned long value )
/* removes the topmost elements. */
{
  if(glob->stackcnt<value&0xffff)error(G_SERROR_STACK_UNDERFLOW);

  glob->stackp   += value&0xffff;
  glob->stackcnt -= value&0xffff;

  return;
}

void op_justifyntext( struct context *glob, unsigned long value )
{
  union point xy;

  if(glob->stackcnt<3)error(IG_justifyntext+glob->stackcnt);

  xy.xy=justifytext(glob->gstate.font,glob->stackp[2].string,strlen(glob->stackp[2].string),glob->stackp[1].uval,glob->stackp[0].uval,value&0xffff);

  glob->stackp++;
  glob->stackcnt--;
  glob->stackp[1].ival=xy.coor.x;
  glob->stackp[0].ival=xy.coor.y;

  return;
}

void op_justifyctext( struct context *glob, unsigned long value )
{
  union point xy;

  if(glob->stackcnt<3)error(G_SERROR_STACK_UNDERFLOW);

  xy.xy=justifytext(glob->gstate.font,glob->stackp[2].string+1,*(glob->stackp[2].string),glob->stackp[1].uval,glob->stackp[0].uval,value&0xffff);
  glob->stackp++;
  glob->stackcnt--;
  glob->stackp[1].ival=xy.coor.x;
  glob->stackp[0].ival=xy.coor.y;

  return;
}

void op_setscale( struct context *glob )
{
  if(glob->stackcnt<2)error(G_SERROR_STACK_UNDERFLOW);

  glob->gstate.scale.coor.x=glob->stackp[1].uval-1;
  glob->gstate.scale.coor.y=glob->stackp[0].uval-1;
  glob->stackp+=2;
  glob->stackcnt-=2;
  return;
}

void op_setratio( struct context *glob )
{
  return;
}

#define scale_value(v,s) (((v)*(((s)<<1)+1))>>13)

void op_smove( struct context *glob )
{
  if(glob->stackcnt<2)error(G_SERROR_STACK_UNDERFLOW);

  glob->gstate.cursor.coor.x += scale_value(glob->stackp[1].ival,glob->gstate.scale.coor.x-1)+glob->gstate.origin.coor.x;
  glob->gstate.cursor.coor.y += scale_value(glob->stackp[0].ival,glob->gstate.scale.coor.y-1)+glob->gstate.origin.coor.y;

  glob->stackp+=2;
  glob->stackcnt-=2;
  return;
}

void op_slocate( struct context *glob )
{
  if(glob->stackcnt<2)error(G_SERROR_STACK_UNDERFLOW);

  glob->gstate.cursor.coor.x = scale_value(glob->stackp[1].ival,glob->gstate.scale.coor.x-1)+glob->gstate.origin.coor.x;
  glob->gstate.cursor.coor.y = scale_value(glob->stackp[0].ival,glob->gstate.scale.coor.y-1)+glob->gstate.origin.coor.y;

  glob->stackp+=2;
  glob->stackcnt-=2;
  return;
}

void op_sdraw( struct context *glob )
{
  union point xy0;

  if(glob->stackcnt<2)error(G_SERROR_STACK_UNDERFLOW);


  xy0 = glob->gstate.cursor;
  glob->gstate.cursor.coor.x += scale_value(glob->stackp[1].ival,glob->gstate.scale.coor.x-1)+glob->gstate.origin.coor.x;
  glob->gstate.cursor.coor.y += scale_value(glob->stackp[0].ival,glob->gstate.scale.coor.y-1)+glob->gstate.origin.coor.y;

  lline(glob->gstate.layer,&glob->gstate,xy0.coor.x,xy0.coor.y,glob->gstate.cursor.coor.x,glob->gstate.cursor.coor.y);

  glob->stackp+=2;
  glob->stackcnt-=2;
  return;
}

void op_sdrawabs( struct context *glob )
{
  union point xy0;

  if(glob->stackcnt<2)error(G_SERROR_STACK_UNDERFLOW);


  xy0 = glob->gstate.cursor;
  glob->gstate.cursor.coor.x = scale_value(glob->stackp[1].ival,glob->gstate.scale.coor.x-1)+glob->gstate.origin.coor.x;
  glob->gstate.cursor.coor.y = scale_value(glob->stackp[0].ival,glob->gstate.scale.coor.y-1)+glob->gstate.origin.coor.y;

  lline(glob->gstate.layer,&glob->gstate,xy0.coor.x,xy0.coor.y,glob->gstate.cursor.coor.x,glob->gstate.cursor.coor.y);

  glob->stackp+=2;
  glob->stackcnt-=2;
  return;
}

void op_scurve( struct context *glob )
{
  return;
}
void op_scurveabs( struct context *glob )
{
  return;
}
void op_sellipse( struct context *glob )
{
  return;
}

void op_sbox( struct context *glob )
{
  if(glob->stackcnt<2)error(G_SERROR_STACK_UNDERFLOW);

  lrectanglefill(glob->gstate.layer,&glob->gstate,glob->gstate.cursor.coor.x,glob->gstate.cursor.coor.y,
		   (glob->stackp[1].uval*glob->gstate.scale.coor.x)/4906+glob->gstate.origin.coor.x,
		   (glob->stackp[0].uval*glob->gstate.scale.coor.y)/4096+glob->gstate.origin.coor.y);
  glob->stackcnt -=2;
  glob->stackp+=2;
  return;
}

void op_sbox2d( struct context *glob )
{
  if(glob->stackcnt<2)error(G_SERROR_STACK_UNDERFLOW);

  lrectangle(glob->gstate.layer,&glob->gstate,glob->gstate.cursor.coor.x,glob->gstate.cursor.coor.y,
	     (glob->stackp[1].uval*glob->gstate.scale.coor.x)/4906+glob->gstate.origin.coor.x,
	     (glob->stackp[0].uval*glob->gstate.scale.coor.y)/4096+glob->gstate.origin.coor.y);
  glob->stackcnt -=2;
  glob->stackp+=2;
  return;
}

void op_spolygon( struct context *glob )
{
  int i,count;
  union point *xy;

  count = glob->stackp[0].ival;
  glob->stackp++;
  glob->stackcnt--;

  if(count>glob->stackcnt)error(G_SERROR_STACK_UNDERFLOW);

  xy=(union point *)glob->stackp;

  for(i=0;i<count;i++)
    {
      xy[i].coor.y = scale_value(glob->stackp[2*i].ival,glob->gstate.scale.coor.y-1)+glob->gstate.origin.coor.y;
      xy[i].coor.x = scale_value(glob->stackp[2*i+1].ival,glob->gstate.scale.coor.x-1)+glob->gstate.origin.coor.x;
    }
  lpolygon(glob->gstate.layer,&glob->gstate,xy,count);

  glob->stackp   += count;
  glob->stackcnt -= count;

  return;
}

void op_samove( struct context *glob )
{
  return;
}
void op_salocate( struct context *glob )
{
  return;
}
void op_sadraw( struct context *glob )
{
  return;
}
void op_sadrawabs( struct context *glob )
{
  return;
}
void op_sacurve( struct context *glob )
{
  return;
}
void op_sacurveabs( struct context *glob )
{
  return;
}
void op_saellipse( struct context *glob )
{
  return;
} 
void op_saend( struct context *glob )
{
  return;
}

/* my extensions to the stack language. */

void op_nudgecursor( struct context *glob, unsigned long value )
{
  static char mvx[]={ 0,1,1,1,0,-1,-1,-1 };
  static char mvy[]={ -1,-1,0,1,1,1,0,-1 };

  glob->gstate.cursor.coor.x += mvx[value&7];
  glob->gstate.cursor.coor.y += mvy[value&7];

  return;
}

void op_getwidth( struct context *glob )
{
  (--glob->stackp)->uval=rectwidth(glob->gstate.layer->bounds);
  glob->stackcnt++;
  return;
}
void op_getheight( struct context *glob )
{
  (--glob->stackp)->uval=rectheight(glob->gstate.layer->bounds);
  glob->stackcnt++;
  return;
}

void op_getframe( struct context *glob )
{
  struct layer *view;

  if(glob->stackcnt<1)error(G_SERROR_STACK_UNDERFLOW);

  view=(struct layer *)glob->stackp[0].uval;

  checkobject(view,GT_Layer);
  glob->stackp   -= 3;
  glob->stackcnt += 3;

  if(view->parent)
    {
      glob->stackp[0].ival=view->bounds.min.coor.y-view->parent->bounds.min.coor.y;
      glob->stackp[1].ival=view->bounds.min.coor.x-view->parent->bounds.min.coor.x;
    }
  else
    {
      glob->stackp[0].ival=view->bounds.min.coor.y;
      glob->stackp[1].ival=view->bounds.min.coor.x;
    }
  glob->stackp[2].uval=rectheight(view->bounds);
  glob->stackp[3].uval=rectwidth(view->bounds);

  return;
}

void op_expandframe( struct context *glob )
{
  if(glob->stackcnt<4)error(G_SERROR_STACK_UNDERFLOW);

  glob->stackp[0].ival--;
  glob->stackp[1].ival--;
  glob->stackp[2].ival+=2;
  glob->stackp[3].ival+=2;

  return;
}

void op_getfontbaseline( struct context *glob )
{
  (--glob->stackp)->uval=glob->gstate.font->baseline;
  glob->stackcnt++;
  return;
}
void op_getfontwidth( struct context *glob )
{
  (--glob->stackp)->uval=glob->gstate.font->width;
  glob->stackcnt++;
  return;
}
void op_getfontheight( struct context *glob )
{
  (--glob->stackp)->uval=glob->gstate.font->height;
  glob->stackcnt++;
  return;
}
void op_getnstringwidth( struct context *glob )
{
  glob->stackp[0].uval=textlength(glob->gstate.font,&glob->gstate,glob->stackp[0].string,strlen(glob->stackp[0].string));
  return;
}
void op_getcstringwidth( struct context *glob )
{
  glob->stackp[0].uval=textlength(glob->gstate.font,&glob->gstate,glob->stackp[0].string+1,*(glob->stackp[0].string));
  return;
}

void op_centernstring( struct context *glob )
{
  if(glob->stackcnt<2)error(G_SERROR_STACK_UNDERFLOW);

  glob->stackp[1].ival=(glob->stackp[0].ival-textlength(glob->gstate.font,&glob->gstate,glob->stackp[1].string,strlen(glob->stackp[1].string)))/2;
  glob->stackp++;
  glob->stackcnt--;
  return;
}

void op_centercstring( struct context *glob )
{
  if(glob->stackcnt<2)error(G_SERROR_STACK_UNDERFLOW);

  glob->stackp[1].ival=(glob->stackp[0].ival-textlength(glob->gstate.font,&glob->gstate,glob->stackp[1].string+1,glob->stackp[1].string[0]))/2;
  glob->stackp++;
  glob->stackcnt--;
  return;
}

void op_home( struct context *glob )
{
  glob->gstate.cursor.coor.x=0;
  glob->gstate.cursor.coor.y=glob->gstate.font->baseline;
  return;
}

void op_setlinewidth( struct context *glob )
{
  if(!glob->stackcnt)error(G_SERROR_STACK_UNDERFLOW);

  glob->gstate.gc.LineWidth=glob->stackp[0].uval;
  glob->stackp++;
  glob->stackcnt--;
  return;
}

void op_setround( struct context *glob )
{
  if(!glob->stackcnt)error(G_SERROR_STACK_UNDERFLOW);
  
  glob->gstate.gc.Round=glob->stackp[0].uval;
  glob->stackp++;
  glob->stackcnt--;
  return;
}

void op_setclip( struct context *glob )
{
  if(glob->stackp[1].ival<glob->gstate.cursor.coor.x-glob->gstate.origin.coor.x)
    { glob->gstate.clip.min.coor.x = glob->stackp[1].ival+glob->gstate.origin.coor.x;
      glob->gstate.clip.max.coor.x = glob->gstate.cursor.coor.x;
    }
  else
    { glob->gstate.clip.min.coor.x = glob->gstate.cursor.coor.x;
      glob->gstate.clip.max.coor.x = glob->stackp[1].ival+glob->gstate.origin.coor.x;
    }

  if(glob->stackp[0].ival<glob->gstate.cursor.coor.y-glob->gstate.cursor.coor.y)
    { glob->gstate.clip.min.coor.y = glob->stackp[0].ival+glob->gstate.origin.coor.y;
      glob->gstate.clip.max.coor.y = glob->gstate.cursor.coor.y;
    }
  else
    { glob->gstate.clip.min.coor.y = glob->gstate.cursor.coor.y;
      glob->gstate.clip.max.coor.y = glob->stackp[0].ival+glob->gstate.origin.coor.y;
    }

  glob->gstate.gc.Area = &glob->gstate.clip;

  glob->stackcnt -= 2;
  glob->stackp   += 2;

  return;
}

void op_clearclip( struct context *glob )
{
  glob->gstate.gc.Area = NULL;

  return;
}

void op_greater( struct context *glob )
{
  if(glob->stackp[0].ival>glob->stackp[1].ival)
    glob->stackp[1].ival=glob->stackp[0].ival;
  glob->stackp++;
  glob->stackcnt--;
  return;
}

void op_lesser( struct context *glob )
{
  if(glob->stackp[0].ival<glob->stackp[1].ival)
    glob->stackp[1].ival=glob->stackp[0].ival;
  glob->stackp++;
  glob->stackcnt--;
  return;
}

/* coordinate pair functions */

void op_DUP2( struct context *glob )
/* duplicates the two top stack values */
{
  glob->stackp[-1]=glob->stackp[+1];
  glob->stackp[-2]=glob->stackp[0];
  glob->stackp-=2;
  glob->stackcnt+=2;

  return;
}

void op_ADD2( struct context *glob )
{
  glob->stackp[3].ival += glob->stackp[1].ival;
  glob->stackp[2].ival += glob->stackp[0].ival;
  glob->stackp    += 2;
  glob->stackcnt  -= 2;

  return;
}

void op_SUB2( struct context *glob )
{
  glob->stackp[3].ival -= glob->stackp[1].ival;
  glob->stackp[2].ival -= glob->stackp[0].ival;
  glob->stackp    += 2;
  glob->stackcnt  -= 2;

  return;
}


void op_newpath( struct context *glob )
{
/*  glob->pathp=glob->path;
  glob->pathp->xy=0;
  glob->path_cnt=0; */

  return;
}

void op_closepath( struct context *glob )
{
/*  if(glob->path_cnt)
    {
      glob->pathp->coor.x=glob->path_cnt;
      glob->pathp->coor.y=1;
      glob->pathp+=1+glob->path_cnt;
  
      glob->path_cnt=0;
    } */
  return;
}

void op_lineto( struct context *glob )
{
/*  if(!glob->path_cnt)
    {
      glob->pathp[1].coor.x=glob->gstate.cursor.coor.x;
      glob->pathp[1].coor.y=glob->gstate.cursor.coor.y;
      glob->path_cnt=1;
    }
  glob->path_cnt++;

  glob->gstate.cursor.coor.x=glob->gstate.scale.coor.x*glob->stackp[1].uval/4096+glob->gstate.origin.coor.x;
  glob->gstate.cursor.coor.y=glob->gstate.scale.coor.y*glob->stackp[0].uval/4096+glob->gstate.origin.coor.y;
  glob->pathp[glob->path_cnt].coor.x=glob->gstate.cursor.coor.x;
  glob->pathp[glob->path_cnt].coor.y=glob->gstate.cursor.coor.y;
*/
  return;
}

void op_moveto( struct context *glob )
{
/*  if(glob->path_cnt)
    {
      glob->pathp->coor.x=glob->path_cnt;
      glob->pathp=glob->path+1+glob->path_cnt;
      glob->path_cnt=0;
    }

  glob->gstate.cursor.coor.x=glob->gstate.scale.coor.x*glob->stackp[1].uval/4096+glob->gstate.origin.coor.x;
  glob->gstate.cursor.coor.y=glob->gstate.scale.coor.y*glob->stackp[0].uval/4096+glob->gstate.origin.coor.y;
*/
  return;
}

void op_rlineto( struct context *glob )
{
/*  if(!glob->path_cnt)
    {
      glob->pathp[1].coor.x=glob->gstate.cursor.coor.x;
      glob->pathp[1].coor.y=glob->gstate.cursor.coor.y;
      glob->path_cnt=1;
    }
  glob->path_cnt++;

  glob->gstate.cursor.coor.x+=glob->gstate.scale.coor.x*glob->stackp[1].uval/4096+glob->gstate.origin.coor.x;
  glob->gstate.cursor.coor.y+=glob->gstate.scale.coor.y*glob->stackp[0].uval/4096+glob->gstate.origin.coor.y;
  glob->pathp[glob->path_cnt].coor.x=glob->gstate.cursor.coor.x;
  glob->pathp[glob->path_cnt].coor.y=glob->gstate.cursor.coor.y;
*/
  return;
}

void op_rmoveto( struct context *glob )
{
/*
  if(glob->path_cnt)
    {
      glob->pathp=glob->path+1+glob->path_cnt;
      glob->path_cnt=0;
    }

  glob->gstate.cursor.coor.x+=glob->gstate.scale.coor.x*glob->stackp[1].uval/4096+glob->gstate.origin.coor.x;
  glob->gstate.cursor.coor.y+=glob->gstate.scale.coor.y*glob->stackp[0].uval/4096+glob->gstate.origin.coor.y;
*/
  return;
}

void op_stroke( struct context *glob )
{
  int i;
  union point *path;

/*
  if(glob->path_cnt)
    { (glob->pathp+1+glob->path_cnt)->coor.x=0;
      glob->pathp->coor.x=glob->path_cnt;
    }
  else glob->pathp->coor.x=0;

  for(path=glob->path;path->coor.x;path+=(1+path->coor.x))
    {
      for(i=1;i<path->coor.x;i++)
	lline(glob->gstate.layer,&glob->gstate,path[i].coor.x,
	                               path[i].coor.y,
	                               path[i+1].coor.x,
	                               path[i+1].coor.y);
      if(path->coor.y)
	lline(glob->gstate.layer,&glob->gstate,path[i].coor.x,
	                               path[i].coor.y,
	                               path[1].coor.x,
	                               path[1].coor.y);

    }

      glob->pathp=glob->path;
      glob->pathp->xy=0;
      glob->path_cnt=0;

*/
      return;
}

	     
void op_fill( struct context *glob )
{
  union point *path;

/*
  if(glob->path_cnt)
    {
      glob->pathp->coor.x=glob->path_cnt;
      (glob->pathp+1+glob->path_cnt)->coor.x=0;
    }
  else glob->pathp->coor.x=0;

  for(path=glob->path;path->coor.x;path+=(1+path->coor.x))
    lpolygon(glob->gstate.layer,&glob->gstate,path+1,path->coor.x);

  glob->pathp=glob->path;
  glob->pathp->xy=0;
  glob->path_cnt=0;
*/
  return;
}

/* stack.c */

