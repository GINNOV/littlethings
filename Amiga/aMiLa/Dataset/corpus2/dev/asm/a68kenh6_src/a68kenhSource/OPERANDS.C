/*------------------------------------------------------------------*/
/*								    */
/*			MC68000 Cross Assembler			    */
/*								    */
/*                Copyright 1985 by Brian R. Anderson		    */
/*								    */
/*                Operand processor - April 16, 1991		    */
/*								    */
/*   This program may be copied for personal, non-commercial use    */
/*   only, provided that the above copyright notice is included	    */
/*   on all copies of the source code.  Copying for any other use   */
/*   without the consent of the author is prohibited.		    */
/*								    */
/*------------------------------------------------------------------*/
/*								    */
/*		Originally published (in Modula-2) in		    */
/*	    Dr. Dobb's Journal, April, May, and June 1986.	    */
/*								    */
/*	 AmigaDOS conversion copyright 1991 by Charlie Gibbs.	    */
/*								    */
/*------------------------------------------------------------------*/

#include "A68kdef.h"
#include "A68kglb.h"



int GetArgs (name) char *name;
/* Gets macro arguments and adds them to FNStack after adding "name".
    Returns the number of arguments added to the stack.
    Note that this might not be the full number of arguments
    provided if the stack overflowed.				*/
{
    register char *s, *t;
    int narg, instring;
    char currarg[MAXLINE];		/* Current argument */

    narg = strlen (name) + 1;
    Heap2Space (narg);			/* Find space for name. */
    strcpy (NextFNS, name);		/* Add name to stack. */
    NextFNS += narg;			/* Bump pointer. */
    if (NextFNS > High2)
	High2 = NextFNS;		/* Update the high-water mark. */

    narg = 0;				/* Argument counter */

    s = Line + SrcLoc;			/* Now scan Line. */
    while (!isspace(*s) && (*s != ';') && (*s != '\0')) {
	t = currarg;
	if (instring = (*s == '<'))	/* String delimiter */
	    s++;
	while (1) {
	    if (*s == '\0')
		break;			/* End of line */
	    if (instring) {
		if (*s == '>') {
		    s++;
		    break;		/* End of string */
		}
	    } else {
		if ((*s == ',')		/* End of operand */
		|| isspace(*s)		/* End of all operands */
		|| (*s == ';'))		/* Start of comments */
		    break;
	    }
	    *t++ = *s++;		/* Get a character. */
	}
	*t++ = '\0';
	Heap2Space (t - currarg);	/* Check for space. */
	strcpy (NextFNS, currarg);	/* Store argument. */
	NextFNS += t - currarg;		/* Next available space */
	if (NextFNS > High2)
	    High2 = NextFNS;		/* High-water mark */
	narg++;				/* Count arguments. */
	if (*s == ',')
	    s++;			/* Skip over separator. */
    }
    return (narg);			/* Successful completion */
}



void EffAdr (EA, Bad) register struct OpConfig *EA; int Bad;
/* Adds effective address field to Op (BITSET representing opcode). */
{
    if ((1 << (EA->Mode - 1)) IN Bad) {
	Error (EA->Loc, ModeErr);	/* Invalid mode */
	return;
    } else if (EA->Mode > Imm)		/* Special modes */
	return;
    else if (EA->Mode < AbsW)		/* Register direct or indirect */
	Op |= ((EA->Mode - 1) << 3) | EA->Rn;
    else
	Op |= 0x0038 | (EA->Mode - AbsW);	/* Absolute modes */
    OperExt (EA);
}



void OperExt (EA) register struct OpConfig *EA;
/* Calculate operand Extension word, and check range of operands. */
{
    switch (EA->Mode) {
	case AbsL:
	    break;	/* No range checking is needed. */
	case AbsW:
	case ARDisp:
	case PCDisp:
	    if ((EA->Value < -32768) || (EA->Value > 32767))
		Error (EA->Loc, SizeErr);
	    break;
	case ARDisX:
	case PCDisX:
	    if ((EA->Value < -128) || (EA->Value > 127))
		Error (EA->Loc, SizeErr);
	    EA->Value &= 0x00FF;			/* Displacement */
	    EA->Value |= EA->Xn << 12;			/* Index reg. */
	    if (EA->X == Areg)     EA->Value |= 0x8000;	/* Addr. Reg. */
	    if (EA->Xsize == Long) EA->Value |= 0x0800;	/* Long reg.  */
	    if (EA->Xscale != 0)   EA->Value |= EA->Xscale << 9;
	    break;
	case Imm:
	    if (Size == Word) {
		if ((EA->Value < -32768) || (EA->Value > 65535L))
		    Error (EA->Loc, SizeErr);
	    } else if (Size == Byte)
		if ((EA->Value < -128) || (EA->Value > 255))
		    Error (EA->Loc, SizeErr);
	    break;
    }
}

int bfEncode (bfDef) char *bfDef;
{
    int v;
    char *bfEnd;

    bfEnd = bfDef;
    while (*bfEnd)
      bfEnd++;
    v = IsRegister(bfDef, bfEnd - bfDef);
    if (v >= 0) {	/* offset or width in data register */
/* *** old ***
	if (v > 7) {
	    Error (0, OperErr);
	    return (0);
	}
*/
        if (v > 7)
            return (-1);
	else return ((1 << 5) + v);
    }
    else {		/* offset or width is immediate value */
	v = GetValue (bfDef, 0);
/* *** old ***
	if ((v < 0) || (v > 31)) {
	    Error (0, OperErr);
	    return (0);
	}
*/
	if ((v < 0) || (v > 31))
            return (-1);
	else return (v);
    }
}

void GetOperand (oper, op, pcconv)
char *oper; register struct OpConfig *op; int pcconv;
/* Finds mode and value for source or destination operand.
    If PC-relative addressing is permitted, "pcconv" gives the
    offset to the displacement word; otherwise "pcconv" is zero. */
{
    register char *s, *t;
    register int  i;
    char *opend;
    char UCoper[MAXLINE], tempop[MAXLINE];
    int  rloc;
    long templong;
    int bf1, bf2;

    op->Value  = op->Defn = op->Xscale = 0;
    op->Mode   = Null;
    op->X      = X0;
    op->Hunk   = ABSHUNK;
    op->bfCode = 0;
    op->Single = FALSE;

    if (*oper == '\0')
	return;				/* There is nothing to process. */

    s = oper;
    t = UCoper;
    while (*s) {
	*t++ = toupper (*s);		/* Upper-case version */
	s++;
    }
    *t = '\0';
    opend = s - 1;			/* Last character of operand */

    if (*oper == '#') {			/* Immediate */
	s = oper + 1;			/* The value starts here. */
	if (*s == '~')
	    s++;			/* Skip over unary NOT. */
	op->Value  = GetValue (s, (op->Loc)+1);
	op->Mode   = Imm;
	op->Hunk   = Hunk2;
	op->Defn   = DefLine2;
	op->Single = SingleFlag;
	if (*(oper+1) == '~') {		/* Unary NOT of entire value */
	    if (Hunk2 != ABSHUNK) {
		Error (op->Loc + 2, RelErr);
		op->Hunk = ABSHUNK;	/* Must be absolute! */
	    }
	    op->Value = ~(op->Value);	/* Flip all bits. */
	    if (Size == Byte)
		op->Value &= 0xFFL;	/* Trim to 8 bits. */
	    else if (Size == Word)
		op->Value &= 0xFFFFL;	/* Trim to 16 bits. */
	}
	return;
    }

/* begin bit field definition check */
    s = opend;
    if (*s == '}') {
	while (*(--s) != '{')
	    if (s <= oper)
		break;
	if (s <= oper)
/* *** new ***    following was (0, */
	    Error (op->Loc, OperErr);
	else {
	    t = opend - 1;
	    while (*(--t) != ':')
		if (t <= s)
		    break;
	    if (t <= s)
/* *** new ***    following was (0, */
		Error (op->Loc, OperErr);
	    else {
		*s = '\0';		/* Remove bit field def. from oper */
		*opend = '\0';		/* Null terminate width field */
		opend = s - 1;
		*t = '\0';		/* Null terminate offset field */
/*
		op->bfCode = ((bfEncode(++s)) << 6) + bfEncode(++t);
*/
                bf1 = bfEncode(++s);
                bf2 = bfEncode(++t);
                if ((bf1 == -1) || (bf2 == -1))
                    Error (op->Loc, OperErr);
		op->bfCode = (bf1 << 6) + bf2;
	    }

	}
    }
    else op->bfCode = -1;
/* end bit field definition check */

    for (s = oper; s < opend + 1; s++)
	{
	if (*s == ':') {
	    if ((*oper == '(') && (*(s - 1) == ')')
	       && (*(s + 1) == '(') && (*opend == ')')) {
		op->Rn = IsRegister(oper + 1, s - oper - 2);
		op->Rn2 = IsRegister(s + 2, opend - s - 2);
		if ((op->Rn >= 0) && (op->Rn2 >= 0))
		    op->Mode = RPairI;
		else Error (op->Loc, OperErr);
		return;
	    }
	    else {
		i = IsRegister(oper, s - oper);
		if ((i >= 0) && (i <= 7))
		    {
		    op->Rn2 = i;
		    i = IsRegister(s + 1, opend - s);
		    if ((i >= 0) && (i <= 7))
			{
			op->Mode = DPair;
			op->Rn = i;
			}
		    else Error (op->Loc, OperErr);
		    }
		else Error (op->Loc, OperErr);
		return;
		}
	    }
	}

    i = IsRegister (oper, opend-oper+1);
    if (i >= 0) {
	op->Mode = (i & 8) ? ARDir : DReg;	/* Register type */
	op->Rn = i & 7;				/* Register number */
	return;
    } else if (i == -2) {
	op->Mode = MultiM;			/* Equated register list */
	op->Value = Sym->Val;
	return;
    } else if ((*oper == '(') && (*opend == ')')) {
	i = IsRegister (oper+1, opend-oper-1);
	if (i >= 8 && i <= 15) {
	    op->Mode = ARInd;		/* Address Register indirect */
	    op->Rn = i - 8;
	    return;
	} else if (i != -1) {
	    Error (op->Loc, AddrErr);	/* Data register is invalid! */
	    return;
	}	/* else may be parenthesized expression */
    } else if ((*oper == '(')		/* Post-increment */
    && (*opend == '+')
    && (*(opend-1) == ')')) {
	op->Mode = ARPost;
	op->Rn = GetAReg (oper+1, opend-oper-2, op->Loc + 1);
	return;
    } else if ((*oper == '-')		/* Pre-decrement */
    && (*opend == ')')
    && (*(oper+1) == '(')) {
	i = IsRegister (oper+2, opend-oper-2);
	if (i >= 8 && i <= 15) {
	    op->Mode = ARPre;
	    op->Rn = i - 8;
	    return;
	} else if (i > 0) {
	    Error (op->Loc, AddrErr);	/* Data register is invalid! */
	    return;
	}	/* else parenthesized expression with leading minus? */
    } else if (strcmp (UCoper, "SR") == 0) {
	op->Mode = SR;			/* Status Register */
	return;
    } else if (strcmp (UCoper, "CCR") == 0) {
	op->Mode = CCR;			/* Condition Code Register */
	return;
    } else if (strcmp (UCoper, "USP") == 0) {
	op->Mode = USP;			/* User Stack Pointer */
	return;
    } else if (strcmp (UCoper, "CAAR") == 0) {
	op->Mode = CAAR;		/* Cache Address Register */
	return;
    } else if (strcmp (UCoper, "CACR") == 0) {
	op->Mode = CACR;		/* Cache Control Register */
	return;
    } else if (strcmp (UCoper, "DFC") == 0) {
	op->Mode = DFC;			/* Destination Function Code */
	return;
    } else if (strcmp (UCoper, "DTT0") == 0) {
	op->Mode = DTT0;		/* Data Transparent Translation R0 */
	return;
    } else if (strcmp (UCoper, "DTT1") == 0) {
	op->Mode = DTT1;		/* Data Transparent Translation R1 */
	return;
    } else if (strcmp (UCoper, "ISP") == 0) {
	op->Mode = ISP;			/* Interrupt Stack Pointer */
	return;
    } else if (strcmp (UCoper, "ITT0") == 0) {
	op->Mode = ITT0;		/* Inst. Transparent Translation R0 */
	return;
    } else if (strcmp (UCoper, "ITT1") == 0) {
	op->Mode = ITT1;		/* Inst. Transparent Translation R1 */
	return;
    } else if (strcmp (UCoper, "MMUSR") == 0) {
	op->Mode = MMUSR;		/* MMU Status Register */
	return;
    } else if (strcmp (UCoper, "MSP") == 0) {
	op->Mode = MSP;			/* Master Stack Pointer */
	return;
    } else if (strcmp (UCoper, "SFC") == 0) {
	op->Mode = SFC;			/* Source Function Code */
	return;
    } else if (strcmp (UCoper, "SRP") == 0) {
	op->Mode = SRP;			/* Supervisor Root Pointer */
	return;
    } else if (strcmp (UCoper, "TC") == 0) {
	op->Mode = TC;			/* MMU Translation Control Register */
	return;
    } else if (strcmp (UCoper, "URP") == 0) {
	op->Mode = URP;			/* User Root Pointer */
	return;
    } else if (strcmp (UCoper, "VBR") == 0) {
	op->Mode = VBR;			/* Vector Base Register */
	return;
    }

    /* Try to split off displacement (if present).
	We'll assume we have a register expression if the operand
	ends with a parenthesized expression not preceded by an
	operator.  I know this code is a real kludge, but that's
	the result of the bloody syntax.  Thanks, Motorola.	*/

    s = opend;				/* Last character */
    if (i = (*s == ')'))		/* Trailing parenthesis? */
	while (*(--s) != '(')		/* Find left parenthesis. */
	    if (s <= oper)
		break;
    if (s <= oper)			/* Must not be at beginning. */
	i = FALSE;
    if (i) {
	if (s == (oper+1)) {
	    if (*oper == '-')
		i = FALSE;		/* Leading minus sign */
	} else {
	    t = s - 1;
	    if (*t == '*') {		/* Location counter? */
		t--;
		if (!IsOperator (t) || (*t == ')'))
		    i = FALSE;		/* No, it's multiplication. */
	    } else if (IsOperator (t) && (*t != ')')) {
		i = FALSE;		/* Preceded by an operator */
	    }
	}
    }

    if (i) {		/* Looks like a displacement mode */
	*s = '\0';
	op->Value = GetValue (oper, op->Loc);	/* Displacement */
	op->Hunk  = Hunk2;			/* Hunk number */
	op->Defn  = DefLine2;			/* Line where defined */
	*s++ = '(';				/* Restore parenthesis. */

	rloc = op->Loc + s - oper;	/* The register starts here. */
	s = GetField (s, tempop);	/* Get address register. */
	if (*s == '\0')			/* If there's no index register, */
	    tempop[strlen(tempop)-1] = '\0';	/* chop off parenthesis. */

	if ((tempop[2] == '\0')
	&& (toupper (tempop[0]) == 'P')
	&& (toupper (tempop[1]) == 'C')) {
	    op->Mode = PCDisp;			/* Program Counter */
/*
	    if (op->Hunk == CurrHunk) {
*/
/* Major kludge */
	    if ((op->Hunk == CurrHunk) || (ROrgFlag)) {
		op->Value -= (AddrCnt+pcconv);	/* Adjust displacement. */
		op->Hunk = ABSHUNK;
	    }
	} else {
	    if ((op->Value == 0)	/* If displacement is zero   */
	    && (op->Hunk == ABSHUNK)	/*  and is absolute          */
	    && (op->Defn < LineCount)	/*  and is already defined   */
	    && !(OpM68R IN AdrModeA)	/*  and isn't for a MOVEP    */
	    && !NoOpt)			/*  and we can optimize      */
		op->Mode = ARInd;	/*  forget the displacement. */
	    else
		op->Mode = ARDisp;	/* Address reg. w/displacement */
	    op->Rn = GetAReg (tempop, strlen (tempop), rloc);
	}
	if (*s != '\0') {		/* Index register is present. */
	    if (op->Mode == PCDisp)
		op->Mode = PCDisX;	/* Program Counter indexed */
	    else
		op->Mode = ARDisX;	/* Address Register indexed */
	    if (*s != ',')
		Error (op->Loc, AddrErr);	/* Bad separator */
	    s++;				/* Skip separator. */
	    rloc = op->Loc + s - oper;		/* Start of index */
	    s = GetField (s, tempop);		/* Get index register. */
	    t = tempop + strlen(tempop);
	    if (*s == '\0')
		*(--t) = '\0';			/* Chop parenthesis. */
	    else
		Error (rloc, AddrErr);		/* It better be there. */

	    t -= 2;
	    if ((t < tempop) || ((*t != '.') && (*t != '*'))) {
		op->Xsize = Word;	/* Size defaults to 16 bits. */
		op->Xscale = 0;
		t += 3;
	    } else {
		if (*t == '*')
		    switch (*(t+1))
			{
			case '1':
			    op->Xscale = 0;
			    t -= 2;
			    break;
			case '2':
			    op->Xscale = 1;
			    t -= 2;
			    break;
			case '4':
			    op->Xscale = 2;
			    t -= 2;
			    break;
			case '8':
			    op->Xscale = 3;
			    t -= 2;
			    break;
			}
		*t++ = '\0';			/* Chop off size code. */
		switch (toupper (*t)) {
		case 'W':			/* Word */
		    op->Xsize = Word;
		    break;
		case 'L':			/* Long */
		    op->Xsize = Long;
		    break;
		default:
		    Error (op->Loc+s-1-oper, SizeErr);	/* Invalid size */
		    op->Xsize = Word;		/* Make it word for now. */
		    op->Xscale = 0;
		}
	    }

	    i = IsRegister (tempop,t-tempop-1);	/* Get register. */
	    op->Xn = i & 7;			/* Index register number */
	    if ((i >= 0) && (i <= 7))
		op->X = Dreg;			/* Data Register */
	    else if ((i >= 8) && (i <= 15))
		op->X = Areg;			/* Address Register */
	    else
		Error (rloc, AddrErr);		/* Invalid register */
	}

	if ((op->Hunk >= 0) && (op->Hunk != ABSHUNK))
	    Error (op->Loc, RelErr);	/*  Relocatable displacement */
	return;
    }

    if ((i = GetMultReg (oper, op->Loc)) != 0) {
	op->Value = (long) i;
	op->Mode = MultiM;		/* Register list for MOVEM */
	return;
    }

    if ((*oper == '(')		/* Operands of the form (xxxx).W or (xxxx).L */
    && (*(opend-2) == ')')
    && (*(opend-1) == '.')
    && ((toupper(*opend) == 'W') || (toupper(*opend) == 'L'))) {
	*(opend-1) = '\0';	/* Temporarily cut off length specifier. */
	op->Value  = GetValue (oper, op->Loc);	/* Get operand value. */
	op->Hunk   = Hunk2;
	op->Defn   = DefLine2;
	op->Single = SingleFlag;
	if (toupper(*opend) == 'W')
	    op->Mode = AbsW;	/* Absolute word */
	else
	    op->Mode = AbsL;	/* Absolute long */
	*(opend-1) = '.';	/* Restore original operand. */
	return;
    }

    op->Value  = GetValue (oper, op->Loc);	/* Plain old expression */
    op->Hunk   = Hunk2;
    op->Defn   = DefLine2;
    op->Single = SingleFlag;
    op->Mode   = AbsL;		/* Assume absolute long addressing. */

    if (NoOpt)
	return;			/* Do no optimizing. */

    if (DefLine2 < LineCount) {		/* Backward reference */

	if (Hunk2 < 0) {
	    return;		/* External - leave as absolute long. */

	} else if (Hunk2 == CurrHunk) {	/* Reference to current hunk */
	    if (pcconv) {
		templong = op->Value-(AddrCnt+pcconv);	/* PC disp. */
		if ((templong >= -32768) && (templong <= 32767)) {
		    op->Mode = PCDisp;	/* Convert to PC relative mode. */
		    op->Value=templong;	/* Adjust displacement. */
		    op->Hunk = ABSHUNK;
		}
	    }

	} else if (Hunk2 == ABSHUNK) {	/* Absolute value */
	    if ((op->Value >= -32768) && (op->Value <= 32767))
		op->Mode = AbsW;	/* Absolute word */

	} else if ((SmallData != -1)
	&& (op->Value>=0) && (op->Value<=65535L)) {
	    op->Mode = ARDisp;		/* Make it a data reference     */
	    op->Rn = SmallData;		/*  through specified register. */
	    op->Value -= DataOffset;	/* Adjust displacement. */
	    op->Hunk = ABSHUNK;
	}
	return;			/* Could default to absolute long. */

    } else if (SmallData==-1) {	/* Fwd. reference - if not small data, */
	return;			/*  leave as absolute long addressing. */

    } else if (Brnch IN AdrModeA) {
	return;			/* Branches are handled elsewhere. */

    } else if (!Pass2) {	/* Forward reference, pass 1 */
	op->Mode = ARDisp;	/* Assume displacement       */
	op->Rn = SmallData;	/*  from specified register. */
	op->Hunk = ABSHUNK;
	return;

    } else {			/* On pass 2 we know what it is. */

	if (Hunk2 < 0) {
	    Error (op->Loc,FwdRef);	/* External - must be 32 bits. */
	    op->Mode = AbsW;		/* Force absolute word anyway. */

	} else if (Hunk2 == CurrHunk) {	/* It's in the current hunk. */
	    op->Mode = PCDisp;		/* Convert to PC relative mode. */
	    op->Value -= AddrCnt + pcconv;	/* Adjust displacement. */
	    op->Hunk = ABSHUNK;
	    if (!pcconv || (op->Value < -32768) || (op->Value > 32767))
		Error (op->Loc,FwdRef);	/* It doesn't fit! */

	} else if (Hunk2 == ABSHUNK) {	/* It's absolute. */
	    op->Mode = AbsW;		/* It has to fit in a word. */
	    if ((op->Value < -32768) || (op->Value > 32767))
		Error (op->Loc,FwdRef);	/* It doesn't fit! */

	} else {
	    op->Mode = ARDisp;		/* Assume data reference        */
	    op->Rn = SmallData;		/*  through specified register. */
	    op->Value -= DataOffset;	/* Adjust displacement. */
	    op->Hunk = ABSHUNK;         /* Ensure no HUNK_REL16 generated */
	    if ((op->Value < -32768) || (op->Value > 32767))
		Error (op->Loc,FwdRef);	/* It doesn't fit! */
	}
    }
}



int GetMultReg (oper, loc) char *oper; int loc;
/* Builds a register mask for the MOVEM instruction.
    Returns the mask in the low-order portion of its value if
    "oper" is a valid multiple-register list; otherwise returns 0. */
{
    register char *s, *t;
    register int  j;
    int t1, t2;		/* Temporary variables for registers */
    int range;		/* We're processing a range of registers. */
    int multext;	/* The result is built here. */

    multext = 0;
    range = FALSE;
    s = oper;
    if (IsOperator (s))
	return (0);			/* Starts with an operator! */

    while (1) {
	for (t = s; *t; t++) {
	    if ((*t == '-') || (*t == '/')) {
		break;
	    }
	}
	if ((multext == 0) && (*t == '\0'))
	    return (0);			/* Reject single term. */
	if ((t2 = IsRegister (s, (int)(t-s))) < 0)
	    return (0);			/* Not a recognizable register */

	if (!range) {
	    multext |= (1 << t2);	/* Single register */
	    t1 = t2;			/* Save number in case it's a range. */
	} else {			/* Range of registers */
	    range = FALSE;
	    if (t1 > t2) {
		j = t1;			/* Swap registers if backwards. */
		t1 = t2;
		t2 = j;
	    }
	    for (j = t1; j <= t2; j++)
		multext |= (1 << j);	/* Mark all registers in range. */
	    if (*t == '-')
		return (0);		/* Invalid range */
	}
	if (*t == '\0')
	    break;			/* Normal end of operand */
	if (*t++ == '-')
	    range = TRUE;		/* Range indicator */
	if (*t == '\0')
	    return (0);			/* Premature end of operand */
	s = t;
    }
    return (multext);
}



int GetAReg (op, len, loc) char *op; int len, loc;
/* Validate an address register specification.
    Valid specifications are A0 through A7, SP, or an EQUR label.
    The address register number will be returned if it is valid.
    Otherwise, Error will be called, using "loc" for the error
    location (this is its only use), and zero (A0) will be returned. */
{
    register int i;

    i = IsRegister (op, len);		/* Get register number. */
    if ((i >= 8) && (i <= 15))
	return (i - 8);			/* Valid address register */
    else {
	Error (loc, AddrErr);		/* Not an address register */
	return (0);			/* Set to A0. */
    }
}



int IsRegister (op, len) char *op; int len;
/* Check whether the current operand is an address or data register.
    Valid specifications are D0 through D7, A0 through A7, SP,
    or any symbol equated to a register with the EQUR directive.
    Return values:
	0 through 7 - data registers 0 through 7 respectively
	8 through 15 - address registers 0 through 7 respectively
	-1 - not a recognizable register
	-2 - Equated register list for MOVEM instruction (REG) */
{
    char tempop[MAXLINE];
    register char *s;
    register int  i;

    if (len == 2) {		/* Two-character specification */
	i = toupper (*op);
	s = op + 1;
	if ((i == 'S') && (toupper (*s) == 'P')) {
	    return (15);		/* Stack Pointer */
	} else if ((*s >= '0') && (*s <= '7')) {
	    if (i == 'A') {
		return (*s - '0' + 8);	/* Address Register */
	    } else if (i == 'D') {
		return (*s - '0');	/* Data Register */
	    }
	}
    }
    if (!GotEqur)			/* If we have no EQURs to check */
	return (-1);			/*  don't waste any time here.  */
    for (i = 0, s = op; i < len; i++) {
	if (IsOperator (s))
	    return (-1);		/* It sure isn't a label. */
	tempop[i] = *s++;
    }
    tempop[i] = '\0';
    if (ReadSymTab (tempop)) {
	if (Sym->Flags & 0x60) {
	    AddRef (LineCount);		/* Found a register or list. */
	    return ((Sym->Flags & 0x20) ? (int) Sym->Val : -2);
	}
    }
    return (-1);			/* Not a recognizable register */
}
