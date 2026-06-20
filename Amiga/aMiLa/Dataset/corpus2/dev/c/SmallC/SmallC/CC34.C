/*      >>>>> start of cc3 <<<<<<<<<    */

/* 3/3/88 */

/*                                      */
/*      Perform a function call         */
/*                                      */
/* called from heir11, this routine will either call */
/*      the named function, or if the supplied ptr is */
/*      zero, will call the contents of BX              */
callfunction(ptr)
        char *ptr;      /* symbol table entry (or 0) */
{       int nargs;
        nargs=0;
        blanks();       /* already saw open paren */
        if(ptr==0)zpush();      /* calling BX */
        while(streq(line+lptr,")")==0)
                {if(endst())break;
                expression();   /* get an argument */
                if(ptr==0)swapstk(); /* don't push addr */
                zpush();        /* push argument */
                nargs=nargs+4;  /* count args*4 */
                if (match(",")==0) break;
                }
        needbrack(")");
        if(ptr)zcall(ptr);
        else callstk();
        Zsp=modstk(Zsp+nargs);  /* clean up arguments */
}

junk()
{       if(an(inbyte()))
                while(an(ch()))gch();
        else while(an(ch())==0)
                {if(ch()==0)break;
                gch();
                }
        blanks();
}

endst()
{       blanks();
        return ((streq(line+lptr,";")|(ch()==0)));
}

illname()
{       error("illegal symbol name");junk();}

multidef(sname)
        char *sname;
{       error("already defined");
        comment();
        outstr(sname);nl();
}

needbrack(str)
        char *str;
        {
        if(match(str)==0)
                {
                error("missing bracket");
                comment();outstr(str);nl();
                }
        }

needlval()
        {
        error("must be lvalue");
        }

findglb(sname)
        char *sname;
        {
        char *ptr;
        ptr=startglb;
        while(ptr!=glbptr)
                {if(astreq(sname,ptr,namemax))return ptr;
                ptr=ptr+symsiz;
                }
        return 0;
        }

findloc(sname)
        char *sname;
        {
        char *ptr;
        ptr=startloc;
        while(ptr!=locptr)
                {if(astreq(sname,ptr,namemax))return ptr;
                ptr=ptr+symsiz;
                }
        return 0;
        }

addglb(sname, class, typ, value)
        char *sname, class, typ;
        int value;
        {
        char *ptr;
        if(cptr=findglb(sname))
                return cptr;
        if(glbptr>=endglb)
                {
                error("global symbol table overflow");
                return 0;
                }
        cptr=ptr=glbptr;
        while (an(*ptr++ = *sname++));  /* copy name */
        cptr[ident]=class;
        cptr[type]=typ;
        cptr[storage]=statik;
        cptr[offset]=value;
        cptr[offset+1]=value>>8;
        glbptr=glbptr+symsiz;
        return cptr;
        }

addloc(sname, class, typ, value)
        char *sname, class, typ;
        int value;
        {
        char *ptr;
        if(cptr=findloc(sname))
                return cptr;
        if(locptr>=endloc)
                {
                error("local symbol table overflow");
                return 0;
                }
        cptr=ptr=locptr;
        while(an(*ptr++ = *sname++));   /* copy name */
        cptr[ident]=class;
        cptr[type]=typ;
        cptr[storage]=stkloc;
        cptr[offset]=value;
        cptr[offset+1]=value>>8;
        locptr=locptr+symsiz;
        return cptr;
        }

addext(sname, id)
        char *sname, id;
        {
        char *ptr;
        if(cptr=findext(sname)) return cptr;
        if(extptr>=endextrn)
                {error("external symbol table overflow"); return 0;}
        cptr=ptr=extptr;
        while(an(*ptr++=*sname++)); /* copy name */
        /* type stored in byte following zero terminating name */
        *ptr++=id;
        extptr=ptr;
        return cptr;
        }

findext(sname)
        char *sname;
        {
        char *ptr;
        ptr=startextrn;
        while(ptr<extptr)
                {
                if(astreq(sname,ptr,namemax))
                        return ptr;
                ptr=ptr+strlen(ptr)+2;
                }
        return 0;
        }

/* Test if next input string is legal symbol name */
symname(sname)
        char *sname;
        {
        int k; char c;
        blanks();
        if(alpha(ch())==0)
                return 0;
        k=0;
        while (an(ch()))
                sname[k++]=gch();
        sname[k]=0;
        return 1;
        }

/* Return next avail internal label number */
getlabel()
        {
        return(++nxtlab);
        }

/* Print specified number as label */
printlabel(label)
        int label;
        {
        outasm("cc");
        outdec(label);
        }

/* Test if given character is alpha */
alpha(c)
        char c;
        {
        c=c&127;
        return (((c>='a')&(c<='z')) | ((c>='A')&(c<='Z')) | (c=='_'));
        }

/* Test if given character is numeric */
numeric(c)
        char c;
        {
        c=c&127;
        return ((c>='0') & (c<='9'));
        }

/* Test if given character is alphanumeric */
an(c)
        char c;
        {
        return ((alpha(c)) | (numeric(c)));
        }

/* Print a carriage return and a string only to console */
pl(str)
        char *str;
        {
        int k;
        k=0;
        putchar(hosteol);
        while (str[k])
                putchar(str[k++]);
        }

addwhile(ptr)
        int ptr[];
        {
        int k;
        if (wqptr==wqmax)
                {
                error("too many active whiles");
                return;
                }
        k=0;
        while (k<wqsiz)
                {*wqptr++ = ptr[k++];}
        }

delwhile()
        {
        if(readwhile())
                wqptr=wqptr-wqsiz;
        }

readwhile()
        {
        if(wqptr==wq)
                {
                error("no active whiles");
                return 0;
                }
        else return (wqptr-wqsiz);
        }

ch()
        {
        return (line[lptr]&127);
        }

nch()
        {
        if(ch()==0)
                return 0;
        else return(line[lptr+1]&127);
        }

gch()
        {
        if(ch()==0)
                return 0;
        else return(line[lptr++]&127);
        }

kill()
        {
        lptr=0;
        line[lptr]=0;
        }

inbyte()
        {
        while(ch()==0)
                {
                if(eof)
                        return 0;
                inline();
                preprocess();
                }
        return gch();
        }

inchar()
        {
        if(ch()==0)
                inline();
        if(eof)
                return 0;
        return(gch());
        }

inline()
        {
        int k, unit;
        while(1)
                {
                if(input==0)
                        {
                        eof=1;
                        return;
                        }
                if((unit=input2)==0)
                        unit=input;
                kill();
                while ((k=getc(unit))>0)
                        {
                        if((k==hosteol) | (lptr>=linemax))
                                break;
                        line[lptr++]=k;
                        }
                line[lptr]=0;   /* append null */
                lineno++;       /* read one more line           gtf 7/2/80 */
                if(k<=0)
                        {
                        fclose(unit);
                        if(input2)
                                endinclude();           /* gtf 7/16/80 */
                        else input=0;
                        }
                if(lptr)
                        {
                        if((ctext) & (cmode))
                                {
                                comment();
                                outstr(line);
                                nl();
                                }
                lptr=0;
                        return;
                        }
                }
        }

/*      >>>>>> start of cc4 <<<<<<<     */

preprocess()
        {
        int k;
        char c, sname[namesize];
        if(cmode==0)
                return;
        mptr=lptr=0;
        while(ch())
                {
                if((ch()==' ') | (ch()==9))
                        predel();
                else if(ch()=='"')
                        prequote();
                else if(ch()==39)
                        preapos();
                else if((ch()=='/') & (nch()=='*'))
                        precomm();
                else if(alpha(ch()))    /* from an(): 9/22/80 gtf */
                        {
                        k=0;
                        while(an(ch()))
                                {
                                if(k<namemax)
                                        sname[k++]=ch();
                                gch();
                                }
                        sname[k]=0;
                        if(k=findmac(sname))
                                while(c=macq[k++])
                                        keepch(c);
                        else
                                {
                                k=0;
                                while(c=sname[k++])
                                        keepch(c);
                                }
                        }
                else keepch(gch());
                }
        keepch(0);
        if(mptr>=mpmax)
                error("line too long");
        lptr=mptr=0;
        while (line[lptr++]=mline[mptr++]);
        lptr=0;
        }

keepch(c)
        char c;
        {
        mline[mptr]=c;
        if(mptr<mpmax)mptr++;
        return c;
        }

predel()
        {keepch(' ');
        while((ch()==' ')|
                (ch()==9))
                gch();
        }

prequote()
        {keepch(ch());
        gch();
        while(ch()!='"')
                {
                if(ch()==0)
                        {
                        error("missing quote");
                        break;
                        }
                keepch(gch());
                }
        gch();
        keepch('"');
        }

preapos()
        {
        keepch(39);
        gch();
        while(ch()!=39)
                {
                if(ch()==0)
                        {
                        error("missing apostrophe");
                        break;
                        }
                keepch(gch());
                }
        gch();
        keepch(39);
        }

precomm()
        {
        inchar();
        inchar();
        while (((ch()=='*') & (nch()=='/'))==0)
                {
                if(ch()==0)
                        inline();
                else inchar();
                if(eof)
                        break;
                }
        inchar();
        inchar();
        }

addmac()
        {
        char sname[namesize];
        int k;
        if(symname(sname)==0)
                {
                illname();
                kill();
                return;
                }
        k=0;
        while (putmac(sname[k++]));
        while(ch()==' ' | ch()==9)
                gch();
        while (putmac(gch()));
        if(macptr>=macmax)
                error("macro table full");
        }

putmac(c)
        char c;
        {       macq[macptr]=c;
        if(macptr<macmax)macptr++;
        return c;
}

findmac(sname)
        char *sname;
        {
        int k;
        k=0;
        while(k<macptr)
                {
                if(astreq(sname,macq+k,namemax))
                        {
                        while (macq[k++]);
                        return k;
                        }
                while(macq[k++]);
                while(macq[k++]);
                }
        return 0;
        }

/* direct output to console             gtf 7/16/80 */
toconsole()
        {
        saveout = output;
        output = 0;
        }

/* direct output back to file           gtf 7/16/80 */
tofile()
        {
        if(saveout)
                output = saveout;
        saveout = 0;
        }

outbyte(c)
        char c;
        {
        if(c==0)
                return 0;
        if(output)
                {
                if((putc(c,output))<=0)
                        {
                        closeout();
                        error("Output file error");
                        abort();                        /* gtf 7/17/80 */
                        }
                }
        else putchar(c);
        return c;
        }

outstr(ptr)
        char ptr[];
        {
        int k;
        k=0;
        while (outbyte(ptr[k++]));
        }

/* write text destined for the assembler to read */
/* (i.e. stuff not in comments)                 */
/*  gtf  6/26/80 */
outasm(ptr)
        char *ptr;
        {
        while (outbyte(raise(*ptr++)));
        }

nl()
        {
        if(output)
                outbyte(targeol);
        else outbyte(hosteol);
        }

tab()
        {
        outbyte(32);
        }

col()
        {
        outbyte(58);
        }

error(ptr)
        char ptr[];
        {
        int k;
        char junk[81];
        toconsole();
        bell();
        outstr("Line ");
        outdec(lineno);
        outstr(", ");
        if(infunc==0)
                outbyte('(');
        if(currfn==NULL)
                outstr("start of file");
        else outstr(currfn+name);
        if(infunc==0)
                outbyte(')');
        outstr(" + ");
        outdec(lineno-fnstart);
        outstr(": ");
        outstr(ptr);
        nl();
        outstr(line);
        nl();
        k=0;    /* skip to error position */
        while(k<lptr)
                {
                if(line[k++]==9)
                        tab();
                else    outbyte(' ');
                }
        outbyte('^');
        nl();
        ++errcnt;
        if(errstop)
                {
                pl("Continue (Y,n,g) ? ");
                gets(junk);
                k=junk[0];
                if((k=='N') | (k=='n'))
                        abort();
                if((k=='G') | (k=='g'))
                        errstop=0;
                }
        tofile();
        }

ol(ptr)
        char ptr[];
        {
        ot(ptr);
        nl();
        }

ot(ptr)
        char ptr[];
        {
        tab();
        outasm(ptr);
        }

streq(str1,str2)
        char str1[],str2[];
        {
        int k;
        k=0;
        while (str2[k])
                {
                if((str1[k])!=(str2[k]))
                        return 0;
                k++;
                }
        return k;
        }

astreq(str1,str2,len)
        char str1[], str2[];
        int len;
        {
        int k;
        k=0;
        while (k<len)
                {
                if((str1[k])!=(str2[k]))
                        break;
                if(str1[k]==0)
                        break;
                if(str2[k]==0)
                        break;
                k++;
                }
        if(an(str1[k]))
                return 0;
        if(an(str2[k]))
                return 0;
        return k;
        }

match(lit)
        char *lit;
        {
        int k;
        blanks();
        if(k=streq(line+lptr,lit))
                {
                lptr=lptr+k;
                return 1;
                }
        return 0;
        }

amatch(lit, len)
        char *lit;
        int len;
        {
        int k;
        blanks();
        if(k=astreq(line+lptr,lit,len))
                {
                lptr=lptr+k;
                while (an(ch()))
                        inbyte();
                return 1;
                }
        return 0;
        }

blanks()
        {
                while(1)
                {
                        while(ch()==0)
                        {
                        inline();
                        preprocess();
                        if(eof)
                                break;
                        }
                if(ch()==' ')
                        gch();
                else if(ch()==9)
                        gch();
                else return;
                }
        }

outdec(number)
        int number;
        {
        int k, zs;
        char c;
        zs = 0;
        k=10000;
        if(number<0)
                {
                number=(-number);
                outbyte('-');
                }
        while (k>=1)
                {
                c=number/k + '0';
                if ((c!='0') | (k==1) | (zs))
                        {
                        zs=1;
                        outbyte(c);
                        }
                number=number%k;
                k=k/10;
                }
        }

/* return the length of a string */
/* gtf 4/8/80 */
strlen(s)
char *s;
{       
        char *t;
        t = s;
        while(*s)
                s++;
        return (s-t);
        }

/* convert lower case to upper */
/* gtf 6/26/80 */
raise(c)
        char c;
        {
        if((c>='a') & (c<='z'))
                c = c - 'a' + 'A';
        return (c);
        }
