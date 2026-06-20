/* ObjDumpFuncs : Alain THELLIER - Paris - FRANCE - 2014				*/
/* From an ASM file made with ObjDump -d 							*/
/* Generate functions list,calls,branchs,sizes						*/
/* LICENSE: GNU General Public License (GNU GPL) for this file 			*/

/*--------------------------------------------------------------------------------------------------*/
/* If you enjoyed ObjDumpFuncs send me a postcard at: Thellier. 43 Rue Ordener. 75018 PARIS. FRANCE */
/*--------------------------------------------------------------------------------------------------*/
                                                          
/*==========================================================================*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/*==========================================================================*/
struct myfunc{
long  int funcnum;
unsigned char name[256];
unsigned char buttonname[256];
unsigned char offsetname[20];
unsigned char sizename[20];
unsigned char callname[20];
unsigned char calledname[20];
unsigned char branchname[20];
unsigned char stackname[20];
unsigned char stackrname[20];
long int offset;
unsigned char hexoffset[20];
long int size;
long int callnb;
long int callednb;
long int branchnb;
long int stack;
long int stackr;
void* funcsorted;
};
/*==========================================================================*/
struct mycall{
struct myfunc *currentfunc;
unsigned char buttonname[256];
unsigned char name[256];
unsigned char hexoffset[20];
long int offset;
struct myfunc *func;
int IsBranch;		/* call is a branch inside current function else call an other function */
long int callnb;
};
/*==========================================================================*/
struct myprog{
struct myfunc *allfuncs;
struct mycall *allcalls;
long int	funcnb,callnb,funcmax,callmax;
long int	funcsizemax,funcsizemin,functotal,funcaverage,stackmax,stackrmax;
int sorted;
long int funcstart,funcnum,funclistnb,guinb,callstart,calllistnb;
unsigned char currentfuncbuttonname[256];
unsigned char filename[256];
short int order;
unsigned char gui,closed,ShowBranch;
long int command;
};
/*==========================================================================*/
struct myprog P;
#if defined(__amigaos4__)
 #define USEOBJDUMP
#else
 #define USEADIS
#endif	
#if defined(__MORPHOS__)
 #define USEOBJDUMP
#endif	
#include "ObjDumpFuncs_Amiga.h"
/*==========================================================================*/
long int	hex2dec(unsigned char *s)
{
ULONG	nombre=0;
LONG f;
UBYTE c;

	if( *s == '-' )
		s++;
	if( *s == '$' )
		s++;
	
	while( *s != 0 )
		{ 
		c=*s;
		if('0' <=  c )
		if( c  <= '9')
			{f = c - '0';nombre = nombre*16 + f;}

		if('a' <=  c )
		if( c  <= 'f')
			{f = c - 'a' + 10;nombre = nombre*16 + f;}

		if('A' <=  c )
		if( c  <= 'F')
			{f = c - 'A' + 10;nombre = nombre*16 + f;}	
			
		s++;
		}
	return(nombre);
}
/*=================================================================*/
LONG ContainChar(UBYTE *name,UBYTE c)
{
ULONG size,n;

	if(name==NULL)
		return(-1);

	size=strlen(name);
	for(n=0;n<size;n++)
		{
		if(name[n]==c) 
			return(n);
		}
	return(-1);
}
/*=================================================================*/
BOOL StartWithName(UBYTE *text,UBYTE *name)
{
ULONG size,n;

	size=strlen(name);
	for(n=0;n<size;n++)
		{
		if(text[n]!=name[n]) 
			return(FALSE);
		}
	return(TRUE);
}
/*=================================================================*/
BOOL SameName(UBYTE *name1,UBYTE *name2)
{
	if ( (!strcmp(name1,name2)) && (strlen(name1)==strlen(name2)) )
		return(TRUE);
	return(FALSE);
}
/*=================================================================*/
BOOL CallIsBranch(struct mycall *call,struct myfunc *func)
{
	if(func->offset <  call->offset)
	if(call->offset < (func->offset+func->size))
			return(TRUE);
	return(FALSE);
}
/*=================================================================*/
LONG GetStackPPC(UBYTE *name)
{
ULONG size,n,stack;

	if(name==NULL)
		return(0);
	size=strlen(name);
	for(n=0;n<size;n++)
		if(n<=(size-4))
		if(name[n+0]=='(')
		if(name[n+1]=='r')
		if(name[n+2]=='1')
		if(name[n+3]==')')
			{
			name[n+0]=0;
			stack=hex2dec(name);
			return(stack);	
			}
	return(0);		
}
/*=================================================================*/
BOOL IsLabelPPC(UBYTE *name)
{
	return(FALSE);
}
/*=================================================================*/
BOOL IsFuncPPC(UBYTE *line)
{
UBYTE name[256];
UBYTE hexoffset[20];
	
	sscanf(line, "%s %s",hexoffset,name);
	if(name[0]=='<')
		return(TRUE);
	return(FALSE);
}
/*=================================================================*/
BOOL IsCallPPC(UBYTE *line)
{
LONG size;

	size=strlen(line);
	if(line[size-2]=='>')
			return(TRUE);
	return(FALSE);
}
/*=================================================================*/
struct myfunc *AddFunc(UBYTE *hexoffset,UBYTE *name)
{
struct myfunc *func;
	
	func=&P.allfuncs[P.funcnb];
	func->offset=hex2dec(hexoffset);
	strcpy(func->hexoffset,hexoffset);
	strcpy(func->name,name);
	func->callnb=0;
	func->callednb=0;
	func->branchnb=0;
	func->stack=0;
	func->stackr=0;
	func->funcnum=P.funcnb;
	P.funcnb++;
	return(func);
}	
/*=================================================================*/
struct mycall *AddCall(UBYTE *hexoffset,UBYTE *name,struct myfunc *func)
{
struct mycall *call;
	
	call=&P.allcalls[P.callnb];
	call->offset=hex2dec(hexoffset);
	strcpy(call->hexoffset,hexoffset);
	strcpy(call->name,name);
	call->currentfunc=func;		/* call from current function */
	call->callnb=0;
	P.callnb++;	
	return(call);
}
/*=================================================================*/
BOOL AllocFuncs(void)
{
	printf("Found: %ld Functions, %ld Calls\n",P.funcnb,P.callnb);
	P.allfuncs = (void*) malloc(sizeof(struct myfunc) * (P.funcnb+1));
	if(P.allfuncs==NULL)
		return(FALSE);
	P.allcalls = (void*) malloc(sizeof(struct mycall) * (P.callnb));
	if(P.allcalls==NULL)
		return(FALSE);
	P.funcmax=P.funcnb+1;
	P.callmax=P.callnb;
	P.funcnb=0;
	P.callnb=0;
	return(TRUE);
}
/*=================================================================*/
void EndFuncs(UBYTE *hexoffset)
{
struct myfunc *func;

	func=&P.allfuncs[P.funcnb];
	func->offset=4+hex2dec(hexoffset); /* last known offset + 4 */
	strcpy(func->hexoffset,hexoffset);
	strcpy(func->name,"code end");
	
	printf("Readed: %ld Functions, %ld Calls\n",P.funcnb,P.callnb);
}
/*=================================================================*/
BOOL ReadFuncsObjdump(FILE* fp)	/* from objdump */
{
struct myfunc *func;
struct mycall *call;
UBYTE line[512];
UBYTE name[256];
UBYTE name2[256];	
UBYTE hexoffset[40];
UBYTE inst[40];
UBYTE params[40];
UBYTE param1[40];
UBYTE param2[40];
UBYTE tmp[40];	
ULONG stack,size,n;
LONG  v;	

/* count functions & calls */
	P.callnb=P.funcnb=0;
	func=NULL;
	while(fgets(line, sizeof(line),fp))			/* eat one line */
	{
		if(IsCallPPC(line))
			P.callnb++;
		if(IsFuncPPC(line))
			P.funcnb++;
	}

/* alloc functions & calls */
	AllocFuncs();

/* process functions & calls */
	rewind(fp);
	while(fgets(line, sizeof(line),fp))			/* eat one line */
	{
		
		if(!IsFuncPPC(line))
			{sscanf(line, "%s %s %s %s %s %s %s %s",hexoffset,tmp,tmp,tmp,tmp,inst,params,name2);}
		else
			{sscanf(line, "%s %s",hexoffset,name2);strcpy(params,"");strcpy(inst,"");}

		if(IsCallPPC(line))
		{
			size=strlen(name2);
			for(n=0;n<size;n++)
			{
				if(name2[n]=='>') name2[n]=0;		/* beq <main+0x050> */
				if(name2[n]=='+') name2[n]=0;
			}
			strcpy(name,&name2[1]);		/* skip the '<' */

			size=strlen(hexoffset);
			for(n=0;n<size;n++)
			{
				if(hexoffset[n]==':') hexoffset[n]=' ';
			}
			
			call=AddCall(hexoffset,name,func);
		}

		if(IsFuncPPC(line))
		{
			strcpy(name,&name2[1]);
			size=strlen(name);
			name[size-2]=0;
			
			func=AddFunc(hexoffset,name);
		}
		
		v=ContainChar(params,','); 
		if(v > 0) 
			{
				params[v]=0;
				strcpy(param1,params);
				strcpy(param2,&params[v+1]);
				stack=GetStackPPC(param1);
				if(stack > func->stack)	func->stack=stack;
				stack=GetStackPPC(param2);
				if(stack > func->stack)	func->stack=stack;
			}
		
	}

	EndFuncs(hexoffset);
	return(TRUE);
}
/*=================================================================*/
LONG GetStack68k(UBYTE *name)
{
ULONG size,n,stack;

	if(name==NULL)
		return(0);
	size=strlen(name);
	for(n=0;n<size;n++)
		if(n<=(size-4))
		if(name[n+0]=='(')
		if(name[n+1]=='A')
		if(name[n+2]=='5')
		if(name[n+3]==')')
			{
			name[n+0]=0;
			stack=hex2dec(name);
			return(stack);	
			}
	return(0);				
}
/*=================================================================*/
BOOL IsLabel68k(UBYTE *name)
{
	if(name[0]=='_')	/* is a _funcname */
			return(TRUE);
	if(name[0]=='L')	/* is a Lnnnn label */
			return(TRUE);
	return(FALSE);
}
/*=================================================================*/
BOOL IsFunc68k(UBYTE *name)
{
	if(name[0]=='_')	/* is a _funcname */
			return(TRUE);
	return(FALSE);
}
/*=================================================================*/
BOOL IsCall68k(UBYTE *inst,UBYTE *params)
{
LONG n;

/* exclude those "non-branch" commands */
	if( StartWithName(inst,"CLR") )	
		return(FALSE);
	if( StartWithName(inst,"TST") )	
		return(FALSE);	
	if( StartWithName(inst,"LEA") )	
		return(FALSE);
	if( StartWithName(inst,"PEA") )	
		return(FALSE);
	if( StartWithName(inst,"DC.") )	
		return(FALSE);
	
/* only commands with one parameter are calls */
	n=ContainChar(params,','); 
	if(n >= 0)
			return(FALSE);

	if( IsLabel68k(params) )
			return(TRUE);

	return(FALSE);
}
/*=================================================================*/
void GetOffset68k(UBYTE *line,UBYTE *hexoffset)
{
LONG size,n;

	size=strlen(line);
	line[size-1]='0';
	for(n=0;n<size;n++)
		if(line[size-n-1]=='$')
			{strcpy(hexoffset,&line[size-n-1]);return;}
}
/*=================================================================*/
BOOL ReadFuncsAdis(FILE* fp)	/* from ADIS */
{
struct myfunc *func;
struct mycall *call;
UBYTE line[512];
UBYTE name[256];
UBYTE hexoffset[40];
UBYTE inst[40];
UBYTE params[40];
UBYTE param1[40];
UBYTE param2[40];
ULONG stack,size;
LONG  v;	

/* count functions & calls */
	P.callnb=P.funcnb=0;
	func=NULL;
	while(fgets(line, sizeof(line),fp))			/* eat one line */
	{
		size=strlen(line);
		if(size>40)
		{
			strcpy(name,"");
			if(line[0]!=' ')
				sscanf(line, "%s %s %s",name,inst,params);
			else
				sscanf(line, "%s %s",inst,params);
			
			if(IsFunc68k(line) )
			{
				P.funcnb++;
				if(debug) printf("FUNC: %s \n",name);
			}
		
			if(IsCall68k(inst,params))
			{ 
				P.callnb++;
				if(debug) printf("CALL to %s \n",params);
			}
			
		}	
	}

/* alloc functions & calls */
	AllocFuncs();

/* process functions & calls */
	rewind(fp);
	while(fgets(line, sizeof(line),fp))			/* eat one line */
	{
		size=strlen(line);
		if(size>40)
		{
		strcpy(name,"");
		if(line[0]!=' ')
			sscanf(line, "%s %s %s",name,inst,params);
		else
			sscanf(line, "%s %s",inst,params);			
		GetOffset68k(line,hexoffset);
		if(debug) printf("%s | %s | %s | %s\n",name,inst,params,hexoffset);
		
		if(IsFunc68k(line))
			{
			func=AddFunc(hexoffset,name);	
			}
		
		if(IsCall68k(inst,params))
			{
			strcpy(name,params);
	
			call=AddCall(hexoffset,name,func);
			}	

		v=ContainChar(params,','); 
		if(v > 0) 
			{
				params[v]=0;
				strcpy(param1,params);
				strcpy(param2,&params[v+1]);
				stack=GetStack68k(param1);
				if(stack > func->stack)	func->stack=stack;
				stack=GetStack68k(param2);
				if(stack > func->stack)	func->stack=stack;
			}

		}
	}

	EndFuncs(hexoffset);
	return(TRUE);
}
/*=================================================================*/
BOOL ReadFuncs(FILE* fp)
{
struct myfunc *func;
struct myfunc *currentfunc;
struct mycall *call;
struct mycall *firstcall;
ULONG f,c;
BOOL ok;	

	printf("ANALYZING ASSEMBLY CODE, PLEASE WAIT ...\n");
#ifdef USEOBJDUMP
	ok=ReadFuncsObjdump(fp);
#endif
#ifdef USEADIS
	ok=ReadFuncsAdis(fp);
#endif	
	printf("ANALYZING CODE STRUCTURE, PLEASE WAIT ...\n");

	if(!ok)
	{
	if(P.allfuncs) free(P.allfuncs);
	if(P.allcalls) free(P.allcalls);
	return(FALSE);  
	}

/* finish to process functions */
	P.funcsizemax=P.funcsizemin=P.functotal=0;
	for(f=0;f<P.funcnb;f++)
	{
			func=&P.allfuncs[f];
			func->size=func[1].offset - func->offset;
			P.functotal+=func->size;
			if(f==0) P.funcsizemax=P.funcsizemin=func->size;
			if(P.funcsizemax<func->size)
				P.funcsizemax=func->size;
			if(P.funcsizemin>func->size)
				P.funcsizemin=func->size;
			if(P.stackmax<func->stack)
				P.stackmax=func->stack;
			if(P.stackrmax<func->stackr)
				P.stackrmax=func->stackr;			
	}
	P.funcaverage=P.functotal/P.funcnb;	
	
/* finish to process calls */
	for(c=0;c<P.callnb;c++)
	{
		call=&P.allcalls[c];
		currentfunc=call->currentfunc;

		call->func=NULL;
		for(f=0;f<P.funcnb;f++)			/* Find if a different function is called (call->func) from call->name*/
		{
		func=&P.allfuncs[f];
		if(func!=currentfunc)	
		if(SameName(call->name,func->name))							/* branch to funcname+nnn */
			{
			call->func=func; call->func->callednb++; 
			break;
			}
		}
		
		if(call->func==NULL) {call->func=currentfunc;}			/* if dont call a function then call is still inside current func */
		
		call->IsBranch=(call->func==currentfunc);				/* if just a branch inside current func */
		if(call->IsBranch)
			currentfunc->branchnb++;
		else
			currentfunc->callnb++;
		
		firstcall=call;
		while( (call->currentfunc==currentfunc) && (call != &P.allcalls[0]) )	/* rewind to first  "call to this func"  */
		{
		if(!firstcall->IsBranch)
		if(call->func==firstcall->func)
			{ firstcall=call; }

		call--;
		}
		firstcall->callnb++; 							/* "call to this func" count is incremented and stored in first call*/
	}

/* print calls */
	printf("\n<==========CALLS & BRANCHS============>\n");
	for(c=0;c<P.callnb;c++)
	{
		call=&P.allcalls[c];
		currentfunc=call->currentfunc;

		if(P.ShowBranch)
		if(call->IsBranch)
			printf("Branch %ld %s %ld Function %s\n",c,call->hexoffset,call->offset,currentfunc->name);

		if(!call->IsBranch)
			printf("Call %ld %s %ld Function %s to %s (nb calls %ld)\n",c,call->hexoffset,call->offset,currentfunc->name,call->name,call->callnb);

	}

/* print functions */
	printf("\n<==========FUNCS============>\n");
	for(f=0;f<P.funcnb;f++)
	{
		func=&P.allfuncs[f];

		printf("Function %ld %s %ld %s %ld bytes called %ld call %ld branch %ld stack %ld (%ld)\n",f,func->hexoffset,func->offset,func->name,func->size,func->callednb,func->callnb,func->branchnb,func->stackr,func->stackr);
		sprintf(func->buttonname,"%s",func->name);
		ResizeName(func->buttonname,60);
		sprintf(func->offsetname,"[%ld] %s",func->funcnum,func->hexoffset);
		sprintf(func->sizename  ,"%ld",func->size);
		sprintf(func->callname  ,"%ld",func->callnb);
		sprintf(func->calledname,"%ld",func->callednb);
		sprintf(func->branchname,"%ld",func->branchnb);
		sprintf(func->stackname ,"%ld",func->stack);
		sprintf(func->stackrname,"%ld",func->stackr);
	}

/* print stats */
	printf("\n<==========STATS============>\n");
	printf("<Functions:    %ld >\n",	P.funcnb);
	printf("<Average size: %ld >\n",	P.funcaverage);
	printf("<Max     size: %ld >\n",	P.funcsizemax);
	printf("<Min     size: %ld >\n",	P.funcsizemin);
	printf("<Max    stack: %ld >\n",	P.stackmax);
	printf("<Max   stackr: %ld >\n",	P.stackrmax);
	return(TRUE);
}
/*=================================================================*/
BOOL ReadASM(char* filename)
{
FILE* fp;
BOOL ok;
	
	printf("<ObjDumpFuncs: %s >\n", filename);
	fp = fopen(filename, "r");
	if (!fp) 
		{
		printf("Cant open file !!\n");
		return(FALSE);
		}

	ok=ReadFuncs(fp);
	fclose(fp);
	return(ok);	
}
/*=================================================================*/
int main(int argc, char *argv[])
{
	if (argc > 1)
		strcpy(argv[1],P.filename);

	AmigaGui();
	if(P.allfuncs) free(P.allfuncs);
	if(P.allcalls) free(P.allcalls);
}
/*=================================================================*/
/* example dump from objdump PPC */
/* 
foo.library:     fp format elf32-amigaos

Disassembly of section .text:

01000074 <_start>:
 1000074:	94 21 ff f0 	stwu    r1,-16(r1)
 1000078:	93 e1 00 0c 	stw     r31,12(r1)
 100007c:	7c 3f 0b 78 	mr      r31,r1
 1000080:	38 00 00 14 	li      r0,20
 1000084:	7c 03 03 78 	mr      r3,r0
 1000088:	81 61 00 00 	lwz     r11,0(r1)
 100008c:	83 eb ff fc 	lwz     r31,-4(r11)
 1000090:	7d 61 5b 78 	mr      r1,r11
 1000094:	4e 80 00 20 	blr

01000098 <libOpen>:
 1000098:	94 21 ff d0 	stwu    r1,-48(r1)
 100009c:	7c 08 02 a6 	mflr    r0
 10000a0:	93 e1 00 2c 	stw     r31,44(r1)
 10000a4:	90 01 00 34 	stw     r0,52(r1)
 10000a8:	7c 3f 0b 78 	mr      r31,r1
 10000ac:	90 7f 00 18 	stw     r3,24(r31)
 10000b0:	90 9f 00 1c 	stw     r4,28(r31)
 10000b4:	81 3f 00 18 	lwz     r9,24(r31)
 10000b8:	80 09 00 10 	lwz     r0,16(r9)
 10000bc:	90 1f 00 08 	stw     r0,8(r31)
 10000c0:	80 1f 00 1c 	lwz     r0,28(r31)
 10000c4:	2b 80 00 21 	cmplwi  cr7,r0,33
 10000c8:	40 9d 00 10 	ble-    cr7,10000d8 <libOpen+0x40>
[...]
01033b80 <__NewlibCall>:
 1033b80:	3d 60 01 04 	lis     r11,260
 1033b84:	80 0b 03 b0 	lwz     r0,944(r11)
 1033b88:	7d 6c 00 2e 	lwzx    r11,r12,r0
 1033b8c:	7d 69 03 a6 	mtctr   r11
 1033b90:	4e 80 04 20 	bctr

*/
/*=================================================================*/
/* example dump from adis 68k */
/*
                    MACHINE        MC68020
                    MC68881
                    CSEG

                    NEAR


                    FAR
__stext             MOVE.L         A0,___commandline        ; $28
                    MOVE.L         D0,___commandlen         ; $2E
                    MOVE.L         SP,___SaveSP             ; $34
                    NEAR
					[...]
                    DC.W           $4E5D                    ; $45C
                    DC.W           $4E75                    ; $45E
_MyWindowManager    DC.L           $48552A4F                ; $460
                    MOVEM.L        D2-D4/A2-A3/A6,-(SP)     ; $464

                    FAR
                    CLR.B          _command                 ; $468
                    NEAR

                    CLR.L          D3                       ; $46E

                    FAR
L448                MOVEA.L        _window,A0               ; $470
                    MOVEA.L        _GadToolsBase,A6         ; $476
                    NEAR

                    MOVEA.L        $56(A0),A0               ; $47C
                    JSR            -$48(A6)                 ; $480
                    MOVEA.L        D0,A2                    ; $484
                    TST.L          D0                       ; $486
                    BEQ.L          L53E                     ; $488
                    MOVE.L         $14(A2),D0               ; $48C
                    CMPI.L         #$100,D0                 ; $490
                    BEQ.S          L4A8                     ; $496
*/
