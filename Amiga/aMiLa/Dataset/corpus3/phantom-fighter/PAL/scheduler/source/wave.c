/*
 * Wave routine shit.
 *
 * Designed and coded by Billy Newport
 *
 */

extern void FreeAlien();
extern void MoveWave();
extern void KillTheAlien();

#asm
		include	"header:wave.i"
                include "header:displist.i"
                include "header:scheduler.i"
		include	"header:iff.i"
                
		public	_AllocAlien
		public	_FreeAlien
		public	_MoveWave

                XREF	_FreeAlienList,_ActiveAlienList,_AliensAvailable
		XREF	_DisplayBob,_PurgeEvent,_CopyDownDLE
		XREF	_StartAlienExplosion,_EnqueueEvent,_Translate_Shape
		XREF	_StartAlienMissile

_MoveWave:
	movem.l	MoveWaveRegs,-(sp)
	move.l	12(sp),a0
	move.l	WPRM_dle(a0),a2		;  DLE=param->DLE;
	move.l	a2,-(sp)
        jsr	_CopyDownDLE

	move.l	(sp)+,a2
        move.l	12(sp),a0
	move.l	WPRM_curanim(a0),a3	;  ANM=param->CurAnim;

	move.l	WPRM_wve(a0),a1		;  DLE->NewClass=param->WVE->Image->Class
	move.l	WBLK_image(a1),a0
	move.b	SPRI_class(a0),DLE_newclass(a2)

        move.l	DLE_flags(a2),d0	;  if(DLE->flags&DLE_collision) {
        andi.l	#DLE_Fcollision,d0
	beq.s	5$

	move.l	12(sp),-(sp)		;    StartAlienExplosion(param)
	jsr	_StartAlienExplosion

	add.w	#4,sp

999$:
	movem.l	(sp)+,MoveWaveRegs	;    return;
	rts
5$:
	move.l	12(sp),a0		;  if(!(--param->Count))
	sub.b	#1,WPRM_count(a0)
	bne	10$
	add.l	#ANM_SIZE,a3		;    ANM++
	move.b	ANM_count(a3),d0
	bne.s	7$
	move.l	a0,-(sp)		;      KillTheAlien(param)
	jsr	_KillTheAlien
	add.w	#4,sp
	bra	999$			;      return;

7$:
	move.b	d0,WPRM_count(a0);    if(!(param->Count=ANM->Count))

;    DLE->NewImage=param->FrameList->Frames[Translate_Shape[ANM-;>FrameNo]]
20$:
	moveq.l	#0,d0
	move.b	ANM_frameno(a3),d0
;	lea	_Translate_Shape,a0
	move.l	d0,d1		;Clear top 24 bits quick
;	move.b	(a0,d0.l),d1	;Get frameno
	asl.l	#2,d1
	move.l	d1,a0		;Get Frame
	move.l	12(sp),a1
	add.l	WPRM_framelist(a1),a0
	move.l	2(a0),DLE_newimage(a2)
	move.l	DLE_newimage(a2),-(sp)
        pea	DLE_hitbox(a2)
	jsr	_SetUpHitBox
	lea.l	8(sp),sp
;;
;;  OK, add offsets to move him, and display him
;; 
10$:	move.w	ANM_xoffset(a3),d0	;  DLE->NewX+=ANM->Xoffset
	add.w	d0,DLE_newx(a2)
	move.w	ANM_yoffset(a3),d0	;  DLE->NewY+=ANM->Yoffset;
	add.w	d0,DLE_newy(a2)
	move.l	a2,-(sp)
	move.l	DLE_param(a2),-(sp)
        jsr	_StartAlienMissile	;Start(param)

	lea.l	4(sp),sp

	jsr	_DisplayBob	;Enq(DLE)
	add.w	#4,sp

	move.l	12(sp),a0		;  param->CurAnim=ANM
	move.l	a3,WPRM_curanim(a0)

	move.l	16(sp),a0		;  EnqueueEvent(EQE,EQE->period)
	move.l	_sys_time,d0
        add.l	EQE_period(a0),d0
        move.l	d0,EQE_expire(a0)
	bra	999$
MoveWaveRegs	reg	a2/a3
                
_AllocAlien:	movea.l	_FreeAlienList,a0
		move.l	WBLK_flink(a0),-(sp)
                jsr	_RemQue			;Take alien from free list
		movea.l	d0,a0
                move.b	#CLS_Bob,WPRM_class(a0)	;Alien alive
		move.l	d0,(sp)			;Put alien on stack
                move.l	_ActiveAlienList,-(sp)	;Put in Active List
                jsr	_InsQue
                addq.l	#4,sp
                move.l	(sp)+,d0		;Return address
                rts

_FreeAlien:	movea.l	4(sp),a0
		move.b	#CLS_none,WPRM_class(a0);Alien dead
		move.l	a0,-(sp)
                jsr	_RemQue
		move.l	d0,(sp)
                move.l	_FreeAlienList,-(sp)
                jsr	_InsQue
                addq.w	#4,sp
                movea.l	(sp)+,a0
                movea.l	WPRM_dle(a0),a0
                rts

#endasm

#include <exec/memory.h>
#include "displist.h" 
#include "scheduler.h"
#include "wave.h"
#include "game.h"
#include <hardware/custom.h>
#include "debug.h"
#include "GameParam.h"

extern WVE_PPARAM AllocAlien();

extern struct SpriteImage AlienShip[NUMALIENSHAPES];

WVE_PBLK FreeWaveList=NULL;
WVE_PPARAM FreeAlienList=NULL;
WVE_PPARAM LockedAlienList=NULL;
WVE_PPARAM ActiveAlienList=NULL;

BYTE lastpattern=0;
BYTE TheLastPattern=101;
BYTE TheLast12Pattern=0;
BYTE OKToDoWave;
BYTE lastship=0;
BYTE AliensAvailable;
BYTE AlienBulletsAvailable;

extern ANM_PELEM PatternTable[MAXPATTERNS];
extern ANM_PELEM Pattern12[];

extern void *RemQue();
extern void *AllocMem();
  
/*
 * This routine handles animating an alien in a pattern once he is under way
 *
 * Written and designed by BN
 */

static void KillTheAlien(param)
WVE_PPARAM param;
{
   register WVE_PPARAM Alien=param;
   register DSP_PDLE DLE=Alien->DLE;
   register WVE_PBLK WVE=Alien->WVE;
   
   DLE->flags&=~DLE_collision;
   DLE->NewClass=CLS_none;
   
   StopCollisionCheckingOn(DLE);
   DisplayBob(DLE);	/* CopyDown already done in movewave */
   FreeAlien(Alien);		/* Free from Active queue */
   if(!--WVE->Count) {
      InsQue(FreeWaveList,WVE);	/* Dealloc Wave block */
      AliensAvailable+=WVE->SizeWave;
   }
   PURGEEQE(Alien->EQE);	/* Take out of scheduler */
}

/**************************************************
 * Start an Explosion for an Alien who was killed *
 *************************************************/

static void StartAlienExplosion(Alien)
WVE_PPARAM Alien;
{
  int x,y;
  register struct GraphObject *g;
  register DSP_PDLE DLE;
  register WVE_PPARAM param=Alien;
  register ANM_PELEM  ANM=param->CurAnim;
  
  DLE=param->DLE;
  g=(struct GraphObject *)DLE->NewImage;
  x=DLE->NewX+g->HotX;
  y=DLE->NewY+g->HotY;


  if(!--param->WVE->AliensDead) {
     OurShip.Score+=200;
     if(DoTokenNextWave) {		/* Start token where alien died */
        StartToken(DLE->OldX,DLE->OldY);
        DoTokenNextWave=0;
     } else
        DoBonusScore(BONUS_200,DLE->NewX,DLE->NewY);
  } else
     OurShip.Score+=20;

  MakeExplosion(NULL,NULL,x,y,ANM->Xoffset,ANM->Yoffset);

  KillTheAlien(param);
}   


/****************************************************
 * Kill All aliens onscreen			    *
 ****************************************************/

void KillAllAliens()
{
   register WVE_PPARAM a;
   a=ActiveAlienList;
   while((a=a->flink)!=ActiveAlienList)
      a->DLE->flags|=DLE_collision;
   a=LockedAlienList;
   while((a=a->flink)!=LockedAlienList)
      a->DLE->flags|=DLE_collision;
}


static BYTE Translate_Shape[8]={0,7,6,5,4,3,2,1};

/*
 * This routine is the first routine executed for each ship
 *
 */
 

static void BeginWave(param,EQE)
struct AlienParam *param;
SCH_PEQE EQE;
{
  /* Object is to put alien on screen and then pass to MoveWave */
  
  register DSP_PDLE DLE;
  register ANM_PELEM ANM;
  register struct GraphObject *Ob;
  register struct AlienParam *Alien=param;

  ANM=Alien->WVE->pattern;		/* pattern for this wave */
  DLE=Alien->DLE;
  Alien->NumHitsLeft=Alien->WVE->NumHitsToKill;

  Alien->FrameList=Alien->WVE->Image;
  
  DLE->OldClass=CLS_none;		/* Dont erase an old image */
  EQE->period=ANM->Count;
  DLE->NewX=ANM->Xoffset;
  DLE->NewY=ANM->Yoffset;
  DLE->NewClass=Alien->WVE->Image->Class;	/* Initial image */
  Ob=(struct GraphObject *)(DLE->NewImage=
          Alien->FrameList->Frames[Translate_Shape[ANM->FrameNo]]);

  SetUpHitBox(&DLE->HitBox,Ob);

  Alien->CurAnim=++ANM;
  Alien->Count=Alien->CurAnim->Count+1;
  DoCollisionCheckingOn(DLE);
  DisplayBob(DLE);		/* Put on display list */

  InsQue(ActiveAlienList,Alien);	/* Make active now !!! */
/* Next time pass control to MoveWave */

  EQE->function=MoveWave;
  ENQUEUEEVENT(EQE,EQE->period);

}

extern ULONG sys_time;

/*
 * Routine to grab and start off a wave on the screen
 *
 * Written and designed by Billy Newport
 *
 */

void StartOffAWave(param,myEQE)
char *param;
SCH_PEQE myEQE;
{ /* StartOffAWave */
  int Count;
  register WVE_PBLK WVE;
  register SCH_PEQE EQE;
  register WVE_PPARAM MyAlien;
  register int i;
  if(!OKToDoWave) {			/* Scheduler dead */
     PURGEEQE(myEQE);
     FREEEQE(myEQE);
     return;
  }

  if(CurrentLevel->flags&LB_HoldScroll) {
     ENQUEUEEVENT(myEQE,myEQE->period);
     return;
  }

  if(AliensAvailable) { /* If AliensAvailable */
    Count=sys_time&15;		/* Random number 0 and 15 */
    if(Count<CurrentLevel->MinAliens)
      Count=CurrentLevel->MinAliens;
    if(Count>CurrentLevel->MaxAliens)
      Count=CurrentLevel->MaxAliens;
     if((Count<=AliensAvailable)&&
        (FreeWaveList->flink!=FreeWaveList)) {
          AliensAvailable-=Count;		/* Book aliens */
          WVE=RemQue(FreeWaveList->flink);	/* Get WVE block */
          WVE->SizeWave=Count;
          WVE->AliensDead=Count;		/* All alive and well */
          WVE->Count=Count;			/* Set no of aliens */
          WVE->Score=50;
          WVE->flags=DLE_DoCollision|DLE_AlienParam|DLE_Deadly;
          WVE->Image=&AlienShip[(lastship=(lastship+1)%NUMALIENSHAPES)];
          WVE->NumHitsToKill=1;
          
          if(WVE->Image->Count==12)
             WVE->pattern=
                Pattern12[TheLast12Pattern=++TheLast12Pattern%NUM12PAT];
          else {
             i=rnd(201)%MAXPATTERNS;
             if(i==TheLastPattern)i=(i+1)%MAXPATTERNS;
             TheLastPattern=i;
             WVE->pattern=PatternTable[i];
          }
          for(i=0;i<Count;i++) {
            MyAlien=AllocAlien();
	    (void)RemQue(MyAlien);	/* Not active yet !!! */
            MyAlien->DLE->flags=WVE->flags;
  
            EQE=MyAlien->EQE;
            EQE->function=BeginWave;
            MyAlien->WVE=WVE;
            EQE->period=1;
            if(EQE->flags&EQE_pending)DoAlert("EQE flags corrupt");
            EQE->name="An alien";
            EnqueueEvent(EQE,10*i+(i&1));	/* n ticks apart are 
            					   the aliens */
           }
        }
     }
  ENQUEUEEVENT(myEQE,myEQE->period);
#ifdef DEEP_DEBUG
  Clear_Debug();
#endif
}

void AllocateWVEBLK()
{
  if(!(FreeWaveList=AllocMem(MAXWAVES*sizeof(struct WVE_DEF),MEMF_CLEAR)))
    DoAnAlert("AllocateWVEBLK-F: No memory for WVEDEFs, decrease MAXWAVES");
}

void FreeWVEBLK()
{
  if(FreeWaveList)FreeMem(FreeWaveList,MAXWAVES*sizeof(struct WVE_DEF));
}

static void EmptyFreeWaveList()
{
  int j;
  WVE_PBLK t;
  t=FreeWaveList->flink=FreeWaveList->blink=FreeWaveList;
  for(j=1;j<MAXWAVES;j++)
    InsQue(FreeWaveList,++t);
}

void AllocateWVEPARAM()
{
  if(!(FreeAlienList=AllocMem(MAXALIENS*sizeof(WVE_PARAM),
  			      MEMF_CLEAR)))
    DoAnAlert("AllocateAlienList-F: No memory for WVEPARAMs, decrease MAXALIENS");
}

void FreeWVEPARAM()
{
  if(FreeAlienList)FreeMem(FreeAlienList,MAXALIENS*sizeof(WVE_PARAM));
}

static void EmptyFreeAlienList()
{
  int j;
  WVE_PPARAM t;
  t=FreeAlienList->flink=FreeAlienList->blink=FreeAlienList;
  for(j=1;j<MAXALIENS;j++)
    InsQue(FreeAlienList,++t);

  ActiveAlienList=(WVE_PPARAM)RemQue(FreeAlienList->flink);
  ActiveAlienList->flink=ActiveAlienList->blink=ActiveAlienList;

  LockedAlienList=(WVE_PPARAM)RemQue(FreeAlienList->flink);
  LockedAlienList->flink=LockedAlienList->blink=LockedAlienList;
}

void InitialiseWaves()
{
  register WVE_PPARAM t;
  AliensAvailable=CurrentLevel->NumAliens;
  OKToDoWave=1;				/* 8 aliens on screen max */
  AlienBulletsAvailable=CurrentLevel->NumAlienBullets;
  EmptyFreeWaveList();
  EmptyFreeAlienList();
  t=FreeAlienList->flink;
  while(t!=FreeAlienList) {
    t->EQE=ALLOCEQE;
    t->EQE->flags=0;
    t->EQE->name="An alien";
    t->EQE->param=(char *)t;
    t->DLE=AllocDLE();
    t->DLE->param=(char *)t;
    t->Class=CLS_none;
    t=t->flink;
  }

  CreateEvent(StartOffAWave,NULL,10,"StartWave");

}

