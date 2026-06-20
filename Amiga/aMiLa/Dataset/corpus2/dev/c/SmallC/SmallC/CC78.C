/* Start of G68KCC78.C */

/* 2/27/88 */

test(label)
        int label;
        {
        needbrack("(");
        expression();
        needbrack(")");
        testjump(label);
        }

constant(val)
        int val[];
        {
        if(number(val))
                immval(val[0]);
        else if(pstr(val))
                immval(val[0]);
        else if(qstr(val))
                {
                ot("MOVE.L #");
                printlabel(litlab);
                outbyte('+');
                outdec(val[0]);
                outasm(",BX");
                nl();
                }
        else return 0;
        return 1;
        }

number(val)
        int val[];
        {
        int k, minus;
        char c;
        k=minus=1;
        while(k)
                {
                k=0;
                if(match("+"))
                        k=1;
                if(match("-"))
                        {
                        minus=(-minus);
                        k=1;
                        }
                }
        if(numeric(ch())==0)
                return 0;
        while (numeric(ch()))
                {
                c=inbyte();
                k=k*10+(c-'0');
                }
        if(minus<0)
                k=(-k);
        val[0]=k;
        return 1;
        }

pstr(val)
        int val[];
        {
        int k;
        char c;
        k=0;
        if(match("'")==0)
                return 0;
        while ((c=gch())!=39)
                k=(k&255)*256 + (c&127);
        val[0]=k;
        return 1;
        }

qstr(val)
        int val[];
        {
        char c;
        if(match(quote)==0)
                return 0;
        val[0]=litptr;
        while (ch()!='"')
                {
                if(ch()==0) break;
                if(litptr>=litmax)
                        {
                        error("string space exhausted");
                        while (match(quote)==0)
                                if(gch()==0) break;
                        return 1;
                        }
                litq[litptr++]=gch();
                }
        gch();
        litq[litptr++]=0;
        return 1;
        }

/*      >>>>>> start of cc8 <<<<<<<     */

/* Begin a comment line for the assembler */
comment()
        {
        outbyte(';');
        }

/* Put out assembler info before any code is generated */
header()
        {
        comment();
        outstr(BANNER);
        nl();
        comment();
        outstr(VERSION);
        nl();
        comment();
        outstr(AUTHOR);
        nl();
        comment();
        nl();
        outasm("BX EQUR D0"); nl();
        outasm("DX EQUR D1"); nl();
        ol("SECTION ONE");
        if(mainmode)
                {
                ol("XREF CCINIT");
                ol("XREF CCWRAP");
                ol("JSR CCINIT");
                ol("BSR QZMAIN");
                ol("JSR CCWRAP");
                ol("RTS");
                }
        }

/* Print any assembler stuff needed after all code */
trailer()
        {
        nl();                   /* 6 May 80 rj errorsummary() now goes to console */
        comment();
        outstr(" --- End of Compilation ---");
        nl();
        ol("END");
        }

/* Print out a name such that it won't annoy the assembler */
/*      (by matching anything reserved, like opcodes.) */
/*      gtf 4/7/80 */
outname(sname)
        char *sname;
        {
        int len, i, j;
        outasm("QZ");
        len = strlen(sname);
        if(len>(asmpref+asmsuff))
                {
                i = asmpref;
                len = len-asmpref-asmsuff;
                while(i-- > 0)
                        outbyte(raise(*sname++));
                while(len-- > 0)
                        sname++;
                while(*sname)
                        outbyte(raise(*sname++));
                }
        else outasm(sname);
        }

mem2pri(size,sym)
        char size, *sym;
        {
        ot("MOVE.");
        outbyte(size);
        outbyte(' ');
        outname(sym);
        outasm(",BX");
        nl();
        }

extend()
        {
        ol("EXT.W BX");
        ol("EXT.L BX");
        }

/* Fetch a static memory cell into the primary register */
getmem(sym)
        char *sym;
        {
        if((sym[ident]!=pointer) & (sym[type]==cchar))
                {
                mem2pri('B',sym);
                extend();
                }
        else mem2pri('L',sym);
        }

/* Fetch the address of the specified symbol */
/*      into the primary register */
getloc(sym)
        char *sym;
        {
        ol("MOVE.L SP,BX");
        ot("ADDI.L #");
        outdec(((sym[offset]&255) | ((sym[offset+1])<<8)) - Zsp);
        outasm(",BX");
        nl();
        }

/* Store the primary register into the specified */
/*      static memory cell */
putmem(sym)
        char *sym;
        {
        ot("MOVE.");
        if((sym[ident]!=pointer) & (sym[type]==cchar))
                outbyte('B');
        else outbyte('L');
        outasm(" BX,");
        outname(sym/*+name*/);   /* remove comment if optimize is working */
        nl();
        }

/* Store the specified object type in the primary register */
/*      at the address on the top of the stack */
putstk(typeobj)
        char typeobj;
        {
        ol("MOVE.L (SP)+,A0");
        Zsp=Zsp+4;
        ot("MOVE.");
        if((typeobj==cint) | (typeobj==cchararg))
                outbyte('L');
        else outbyte('B');
        outasm(" BX,(A0)");
        nl();
        }

ind2pri(size)
        char size;
        {
        ot("MOVE.");
        outbyte(size);
        outasm(" (A0),BX");
        nl();
        }

/* Fetch the specified object type indirect through the */
/*      primary register into the primary register */
indirect(typeobj)
        char typeobj;
        {
        ol("MOVE.L BX,A0");
        if(typeobj==cchar)
                {
                ind2pri('B');
                extend();
                }
        else ind2pri('L');
        }

/* Swap the primary and secondary registers */
swap()
        {
        ol("EXG BX,DX");
        }

/* Load literal value into primary register */
immval(val)
        int val;
        {
        ot("MOVE.L #");
        outdec(val);
        outasm(",BX");
        nl();
        }

/* Load address of static cell into primary register */
immlabel(ptr)
        char *ptr;
        {
        ot("MOVE.L #");
        outname(ptr);
        outasm(",BX");
        nl();
        }

/* Push the primary register onto the stack */
zpush()
        {
        ol("MOVE.L BX,-(SP)");
        Zsp=Zsp-4;
        }

/* Pop the top of the stack into the secondary register */
zpop()
        {
        ol("MOVE.L (SP)+,DX");
        Zsp=Zsp+4;
        }

/* Swap the primary register and the top of the stack */
swapstk()
        {
        ol("MOVE.L (SP),A0");
        ol("EXG BX,A0");
        ol("MOVE.L A0,(SP)");
        }

/* Call the specified subroutine name */
zcall(sname)
        char *sname;
        {
        ot("JSR ");
        outname(sname);
        nl();
        addext(sname,userfunc);
        }

/* Call a run-time library routine */
callrts(sname)
        char *sname;
        {
        ot("JSR ");
        outasm(sname);
        nl();
        addext(sname,rtsfunc);
        }

/* Return from subroutine */
zret()
        {
        ol("RTS");
        }

/* Perform subroutine call to value on top of stack */
callstk()
        {
        ol("MOVE.L #*+20,A0");
        ol("MOVE.L (SP),*+10");
        OL("MOVE.L A0,(SP)");
        ol("JMP *");
        Zsp=Zsp+4;
        }

/* Jump to specified internal label number */
jump(label)
        int label;
        {
        ot("BRA ");
        printlabel(label);
        nl();
        }

/* Test the primary register and jump if false to label */
testjump(label)
        int label;
        {
        ol("TST.L BX");
        ot("BEQ ");
        printlabel(label);
        nl();
        }

/* Print pseudo-op to define a literal byte */
defbyte()
{       ot("DC.B ");
}

/* Print pseudo-op to define storage for a character */
defstorchr()
        {
        ot("DS.B ");
        }

/* Print pseudo-op to define storage for an integer */
defstorint()
        {
        ot("DS.L ");
        }

/* Print pseudo-op to define storage for a pointer */
defstorptr()
        {
        ot("DS.L ");
        }

/* Modify the stack pointer to the new value indicated */
modstk(newsp)
        int newsp;
        {
        int k;
        k=newsp-Zsp;
        if(k==0)return newsp;
        if(k>0)
                {
                ot("ADD");
                if(k>8)
                        outbyte('A');
                else outbyte('Q');
                outasm(" #");
                outdec(k);
                outasm(",SP");
                nl();
                }
        else
                {
                ot("SUB");
                if(k>-9)
                        outbyte('Q');
                else outbyte('A');
                outasm(" #");
                outdec(-k);
                outasm(",SP");
                nl();
                }
        return newsp;
}

/* Quadruple the primary register */
doublereg()
        {
        ol("ASL.L #2,BX");
        }

/* Add the primary and secondary registers */
/*      (results in primary) */
zadd()
        {
        ol("ADD.L DX,BX");
        }

/* Subtract the primary register from the secondary */
/*      (results in primary) */
zsub()
        {
        ol("SUB.L DX,BX");
        ol("NEG.L BX");
        }

/* Multiply the primary and secondary registers */
/*      (results in primary */
mult()
        {
        ol("MULS DX,BX");
        }

/* Divide the secondary register by the primary */
/*      (quotient in primary, remainder in secondary) */
div()
        {
        callrts("ccdiv");
        }

/* Compute remainder (mod) of secondary register divided */
/*      by the primary */
/*      (remainder in primary, quotient in secondary) */
zmod()
        {
        div();
        swap();
        }

/* Inclusive 'or' the primary and the secondary registers */
/*      (results in primary) */
zor()
        {
        ol("OR.L DX,BX");
        }

/* Exclusive 'or' the primary and seconday registers */
/*      (results in primary) */
zxor()
        {
        ol("EOR.L DX,BX");
        }

/* 'And' the primary and secondary registers */
/*      (results in primary) */
zand()
        {
        ol("AND.L DX,BX");
        }

/* Arithmetic shift right the secondary register number of */
/*      times in primary (results in primary) */
asr()
        {
        ol("ASR.L BX,DX");
        ol("MOVE.L DX,BX");
        }

/* Arithmetic left shift the secondary register number of */
/*      times in primary (results in primary) */
asl()
        {
        ol("ASL.L BX,DX");
        ol("MOVE.L DX,BX");
        }

/* Form two's complement of primary register */
neg()
        {
        ol("NEG.L BX");
        }

/* Form one's complement of primary register */
com()
        {
        ol("NOT.L BX");
        }

/* Increment the primary register by one */
inc()
        {
        ol("ADDQ #1,BX");
        }

/* Increment the primary register by three */
add3()
        {
        ol("ADDQ #3,BX");
        }

/* Decrement the primary register by one */
dec()
        {
        ol("SUBQ #1,BX");
        }

/* Decrement the primary register by three */
sub3()
        {
        ol("SUBQ #3,BX");
        }

/* Following are the conditional operators */
/* They compare the secondary register against the primary */
/* and put a literal 1 in the primary if the condition is */
/* true, otherwise they clear the primary register */

scomp()
        {
        ol("CMP.L BX,DX");
        }

ucomp()
        {
        ol("MOVE.L DX,A0");
        ol("CMPA.L BX,A0");
        }

/*  This didn't work
saftc(ptr)
        char *ptr;
        {
        ot();
        outbyte('S');
        outasm(ptr);
        outasm(" BX");
        nl();
        extend();
*/

/* Test for equal */
zeq()
        {
        scomp();
/*      saftc("EQ");*/
        ol("SEQ BX");
        extend();
        }

/* Test for not equal */
zne()
        {
        scomp();
/*      saftc("NE");*/
        ol("SNE BX");
        extend();
        }

/* Test for less than (signed) */
zlt()
        {
        scomp();
/*      saftc("LT");*/
        ol("SLT BX");
        extend();
        }

/* Test for less than or equal to (signed) */
zle()
        {
        scomp();
/*      saftc("LE");*/
        ol("SLE BX");
        extend();
        }

/* Test for greater than (signed) */
zgt()
        {
        scomp();
/*      saftc("GT");*/
        ol("SGT BX");
        extend();
        }

/* Test for greater than or equal to (signed) */
zge()
        {
        scomp();
/*      saftc("GE");*/
        ol("SGE BX");
        extend();
        }

/* Test for less than (unsigned) */
ult()
        {
        ucomp();
/*      saftc("LT");*/
        ol("SLT BX");
        extend();
        }

/* Test for less than or equal to (unsigned) */
ule()
        {
        ucomp();
/*      saftc("LE");*/
        ol("SLE BX");
        extend();
        }

/* Test for greater than (unsigned) */
ugt()
        {
        ucomp();
/*      saftc("GT");*/
        ol("SGT BX");
        extend();
        }

/* Test for greater than or equal to (unsigned) */
uge()
        {
        ucomp();
/*      saftc("GE");*/
        ol("SGE BX");
        extend();
        }

/*      <<<<<  End of Small-C compiler  >>>>>   */
