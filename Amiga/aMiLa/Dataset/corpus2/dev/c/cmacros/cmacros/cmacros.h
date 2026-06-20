/****h* cmacros/cmacros.h [2.00] *
*
*  NAME
*    cmacros.h
*  COPYRIGHT
*    $VER: cmacros.h 2.00 (07.08.98) © by Stefan Kost 1998-1998
*  FUNCTION
*    Collection of useful C-macros
*  AUTHOR
*    Stefan Kost
*  CREATION DATE
*    07.Aug.1998
*  MODIFICATION HISTORY
*    07.Aug.1998	V 2.00	extended version
*    03.Jul.1995	V 1.00	initial version
*  NOTES
*   Installation :                                                          
*     just copy it to include:                                              
*   Future :                                                                
*     if you know some more macros, you are using often, please mail them to
*     me (kost@imn.htwk-leipzig.de)                                         
*   Comment :                                                               
*     read with tabs=4                                                      
*******
*/

/*-- Bitmanipulation Macros -------------------------------------------------*/
/* n ist the variable to work with                                           */
/* m ist the bitposition to change                                           */
/* BitClr(11,0) => 10 ; this clear the lowest bit in the number 11           */

#define BitSet(n,m)			( n|(1L<<m) )
#define BitClr(n,m)			( n&~(1L<<m) )
#define BitTest(n,m)		( n&(1L<<m)>>m )
#define BitToggle(n,m)		( n^(1L<<m) )

/*-- Variable Swapping ------------------------------------------------------*/
/* swaps the contents of variable a with b and uses c as buffer              */
/* all variables should have the same typ and should be lvalues              */

/*#define Swap(a,b,c)			c=a;a=b;b=c;*/

/*-- Variable Swapping ------------------------------------------------------*/
/* swaps the contents of variable a with b without a buffer - cool hehe ;-)  */
/* both variables should have the same typ and should be lvalues             */

#define Swap(a,b)			do{ a^=b;b^=a;a^=b; } while(0)

/*-- Rangechecking ----------------------------------------------------------*/
/* checks if a is larger than lo and smaller than hi, returns value which    */
/* is within bounds                                                          */
/* RangeX : bounds are excluded, RangeI : bounds are included                */

#define RangeX(a,lo,hi)		( (a>=hi ? (hi-1) : a)<=lo ? (lo-1) : (a>=hi ? (hi-1) : a) )
#define RangeI(a,lo,hi)		( (a>=hi ? hi : a)<=lo ? lo : (a>=hi ? hi : a) )

/*-- Odd/Even-Check ---------------------------------------------------------*/
/* simply check if a given number is odd or even                             */

#define Odd(a)				( a&1L )
#define Even(a)				( !(a&1L) )

/*-- Endianconversion -------------------------------------------------------*/
/* converts between motorola`s and intel`s (buuuh) number format             */

#define LitEnd2BigEnd_16(w)	( (w&0xFF)<<8 | (w&0xFF00)>>8 )
#define LitEnd2BigEnd_32(l)	( (l&0xFF)<<24 | (l&0xFF00)<<8 | (l&0xFF0000)>>8 | (l&0xFF000000)>>24 )

/*-- IFF-Handling -----------------------------------------------------------*/
/* generates chunk-ID`s for iff-files                                        */

#define MakeID(a,b,c,d)		( (LONG)(a)<<24L | (LONG)(b)<<16L | (c)<<8 | (d) )

/*-- Linear Bleanding -------------------------------------------------------*/
/* Blend(0.25,5.0,50.0) returns a value which equates 25 % between 5 and 50  */

#define Blend(s,lo,hi)		( lo+s*(hi-lo) )

/*-- Converts a number which is a #define to a string -----------------------*/
/* Example                                                                   */
/*  #define VERSION 3                                                        */
/*  #define VSTRING "MyProg V "NUM2STR(VERSION)" (C) by myself"              */

#define NUM2STR(a) NUM2STR_SUB(a)
#define NUM2STR_SUB(a) #a

/*-- Generates strings for cpu/fpu settings ---------------------------------*/
/* you can then include the CPU/FPU name in the version-string of your prog. */

#ifdef _CPUNAME
	#undef _CPUNAME
#endif
#ifdef _M68060
	#define _CPUNAME "68060"
#else
	#ifdef _M68040
		#define _CPUNAME "68040"
	#else
		#ifdef _M68030
			#define _CPUNAME "68030"
		#else
			#ifdef _M68020
				#define _CPUNAME "68020"
			#else
				#ifdef _M68010
					#define _CPUNAME "68010"
				#else
					#ifdef _M68000
						#define _CPUNAME "68000"
					#else
						#define _CPUNAME "-----"
					#endif
				#endif
			#endif
		#endif
	#endif
#endif

#ifdef _FPUNAME
	#undef _FPUNAME
#endif
#ifdef _M68881
	/* FPU */
	#define _FPUNAME "FPU"
#else
	#ifdef _FFP
		/* FFP */
		#define _FPUNAME "FFP"
	#else
		#ifdef _IEEE
			/* IEEE */
			#define _FPUNAME "IEEE"
		#else
			/* Std */
			#define _FPUNAME "Std."
		#endif
	#endif
#endif

/*-- Generates a Color32 Tag ------------------------------------------------*/

#define MakeCol32(a) ((a)<<24L | (a)<<16L | (a)<<8L | (a))

/*-- Makes a number to be a multiple of something ---------------------------*/
/* e.g. MultipleOf(val,3) makes val to be a multiple of 3                    */

#define MultipleOf(a,b) (((ULONG)(b/a))*a)

/*-- Ansi-X3.64 ESC-Commandsequences ----------------------------------------*/
/* use these for nicer console-output, e.g.                                  */
/* printf(BOLD_ON"SuperCopy"BOLD_OFF" (C) by "FGCOL(3)"myself"FGCOL(1));     */
/* the compiler will (should) cat the string together automatically          */

#define ANSI_RESET		"c"
#define ANSI_GFXRESET	"[0m"

#define BOLD_ON			"[1m"
#define BOLD_OFF		"[22m"

#define ITALIC_ON		"[3m"
#define ITALIC_OFF		"[23m"

#define UNDELINE_ON		"[4m"
#define UNDERLINE_OFF	"[24m"

#define INVERSE_ON		"[7m"
#define INVERSE_OFF		"[27m"

#define TEXT_BGCOL		"[8m"
#define TEXT_FGCOL		"[28m"

#define FGCOL(n)		"[3"NUM2STR(n)"m"				// n=0...7  (n=9 -> default color=1)
#define BGCOL(n)		"[4"NUM2STR(n)"m"				// n=0...7  (n=9 -> default color=1)

#define CURSOR_TO_BOL	"\001"
#define CURSOR_TO_EOL	"\032"

#define CLR_SCR			"\014"
#define CLR_LINE		"\002"
#define CLR_TO_END		"\013"
#define BACKSPACE		"\010"

#define BEEP			"\007"

#define SET_XRES(n)		"["NUM2STR(n)"u"
#define SET_YRES(n)		"["NUM2STR(n)"t"

#define SET_XPOS(n)		"["NUM2STR(n)"x"
#define SET_YPOS(n)		"["NUM2STR(n)"y"

/*-- Listsupport ------------------------------------------------------------*/
/* checks if a given node is the end of a list, by checking list->lh_Tail,   */
/* which always points to 0l                                                 */

#define EndOfList(list,node) (node==(struct Node *)(&((list)->lh_Tail)))
//#define EndOfList(list,node) (!(ULONG)(*(node)))

/*-- Keyconstants -----------------------------------------------------------*/
/* make your code better readable by using these constants                   */

#define KEY_BACKSPACE	0x08
#define KEY_TAB			0x09
#define KEY_ENTER		0x0A
#define KEY_RETURN		0x0D
#define KEY_ESC			0x1B
#define KEY_SPACE		0x20

#define RKEY_CURSORUP	0x4C
#define RKEY_CURSORDOWN	0x4D
#define RKEY_HELP		0x5F

/*-- Portabillity -----------------------------------------------------------*/
/* using these constants helps you to write more portable code               */
/* please help me with other compilers here (I am using the SAS C/C++)       */
/* with information from                                                     */
/*   Bernardo Innocenti's CompilerSpecific.h 2.3 (26.10.97)                  */

#ifdef _DCC
	#define ALIGNED		__aligned
	#define ASM
	#define CHIP
	#define FAR
	#define	HOOK		__geta4
	#define INLINE
	#define INTERRUPT
	#define	LIBFUNC		__geta4
	#define NEAR
	#define REGARGS
	#define REG(x)		__## x
	#define SAVEDS		__geta4
	#define STACKEXT
	#define STDARGS		__stdargs
#else
#if defined(_GCC) || defined(__GNUC__)
	#define ALIGNED		__attribute__((aligned(4)))
	#define ASM
	#define CHIP
	#define FAR
	#define	HOOK		__attribute__((saveds))
	#define INLINE		inline
	#define INTERRUPT	__attribute__((interrupt))
	#define	LIBFUNC		__attribute__((saveds))
	#define NEAR
	#define REGARGS
	#define REG(x)		__asm(#reg)
	#define SAVEDS 		__attribute__((saveds))
	#define STACKEXT
	#define STDARGS		__attribute__((stkparm))
#else
#ifdef __MAXON__
	#define ALIGNED
	#define ASM
	#define CHIP
	#define FAR
	#define HOOK
	#define INLINE		inline
	#define INTERRUPT
	#define LIBFUNC
	#define NEAR
	#define REG(x)		register __## x
	#define REGARGS
	#define SAVEDS
	#define STACKEXT
	#define STDARGS
#else
#ifdef __STORM__
	#define ALIGNED
	#define ASM
	#define CHIP
	#define FAR
	#define	HOOK		__saveds
	#define INLINE		__inline
	#define INTERRUPT	__interrupt
	#define	LIBFUNC		__saveds
	#define NEAR
	#define REGARGS		register
	#define REG(x)		register __## x
	#define SAVEDS		__saveds
	#define STACKEXT
	#define STDARGS
#else
#ifdef AZTEC_C
	#define ALIGNED		__aligned
	#define ASM
	#define CHIP
	#define FAR
	#define HOOK		__geta4
	#define INLINE
	#define INTERRUPT
	#define LIBFUNC
	#define NEAR
	#define REGARGS
	#define REG(x)		__## x
	#define SAVEDS		__geta4
	#define STACKEXT
	#define STDARGS
#else
#ifdef __SASC
	#define ALIGNED		__aligned
	#define ASM			__asm
	#define	CHIP		__chip
	#define	FAR			__far
	#define	HOOK		__asm __saveds
	#ifndef __cplusplus
		#define	INLINE	__inline
	#else
		#define	INLINE	inline
	#endif
	#define	INTERRUPT	__interrrupt
	#define	LIBFUNC		__asm __saveds
	#define	NEAR		__near
	#define	REGARGS		__regargs
	#define REG(x)		register __## x
	#define SAVEDS		__saveds
	#define	STACKEXT	__stackext
	#define	STDARGS		__stdargs
#else
	#define ALIGNED
	#define ASM
	#define CHIP
	#define FAR
	#define HOOK
	#define INLINE
	#define INTERRUPT
	#define LIBFUNC
	#define NEAR
	#define REGARGS
	#define REG(x)
	#define SAVEDS
	#define STACKEXT
	#define STDARGS
#endif
#endif
#endif
#endif
#endif
#endif

/*-- eof --------------------------------------------------------------------*/
