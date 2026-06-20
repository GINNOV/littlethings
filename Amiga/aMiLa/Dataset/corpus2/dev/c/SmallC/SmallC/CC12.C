/*      >>>>> start cc1 <<<<<<          */

/* 3/3/88 */

/*                                      */
/*      Compiler begins execution here  */
/*                                      */
main()
{
        mainmode=
        litlab=1;
        hello();        /* greet user */
        see();          /* determine options */
        openin();       /* first file to process */
        while (input!=0)        /* process user files till he quits */
                {
                extptr=startextrn;      /* clear external symbols */
                glbptr=startglb;        /* clear global symbols */
                locptr=startloc;        /* clear local symbols */
                wqptr=wq;               /* clear while queue */
                macptr=         /* clear the macro pool */
                litptr=         /* clear literal pool */
                Zsp =           /* stack ptr (relative) */
                errcnt=         /* no errors */
                eof=            /* not end-of-file yet */
                input2=         /* no include file */
                saveout=        /* no diverted output */
                ncmp=           /* no open compound states */
                lastst=         /* no last statement yet */
                cextern=        /* no externs yet */
                fnstart=        /* current "function" started at line 0 gtf 7/2/80 */
                lineno=         /* no lines read from file              gtf 7/2/80 */
                infunc=         /* not in function now                  gtf 7/2/80 */
                quote[1]=
                0;              /*  ...all set to zero.... */
                quote[0]='"';           /* fake a quote literal */
                currfn=NULL;    /* no function yet                      gtf 7/2/80 */
                cmode=nxtlab=1; /* enable preprocessing and reset label numbers */
                openout();
                header();
                parse();
                if (ncmp) error("missing closing bracket");
                extdump();
                dumpglbs();
                dumplits();
                trailer();
                closeout();
                errorsummary();
                mainmode=0;
                openin();
                }
}

/*                                      */
/*      Abort compilation               */
/*              gtf 7/17/80             */
abort()
{
        if(input2)
                endinclude();
        if(input)
                fclose(input);
        closeout();
        toconsole();
        pl("Compilation aborted.");  nl();
        exit();
}

/*                                      */
/*      Process all input text          */
/*                                      */
/* At this level, only static declarations, */
/*      defines, includes, and function */
/*      definitions are legal...        */
parse()
        {
        while (eof==0)          /* do until no more input */
                {
                if(amatch("extern",6)) {
                        cextern=1;
                        if(amatch("char",4)) {declglb(cchar);ns();}
                        else if(amatch("int",3)) {declglb(cint);ns();}
                        else {declglb(cint);ns();}
                        cextern=0;
                        }
                else if(amatch("char",4)){declglb(cchar);ns();}
                else if(amatch("int",3)){declglb(cint);ns();}
                else if(match("#asm"))doasm();
                else if(match("#include"))doinclude();
                else if(match("#define"))addmac();
                else newfunc();
                blanks();       /* force eof if pending */
                }
        }

extdump()
        {
        char *ptrext;
        ptrext=startextrn;
        while(ptrext<extptr)
                {
                if((cptr=findglb(ptrext))!=0)
                        {if(cptr[ident]==function)
                                if(cptr[offset]!=function) outextrn(ptrext);
                        }
                else outextrn(ptrext);
                ptrext=ptrext+strlen(ptrext)+2;
                }
        }

outextrn(ptr)
        char *ptr;
        {
        char *functype;
        functype=ptr+strlen(ptr)+1;
        if(*functype==statref) return;
        ot("XREF ");
        if(*functype==rtsfunc) outasm(ptr);
        else outname(ptr);
        nl();
        }

/*                                      */
/*      Dump the literal pool           */
/*                                      */
dumplits()
        {int j,k;
        if (litptr==0) return;  /* if nothing there, exit...*/
        ol("SECTION TWO,DATA");
        printlabel(litlab); /* print literal label */
        k=0;                    /* init an index... */
        while (k<litptr)        /*      to loop with */
                {defbyte();     /* pseudo-op to define byte */
                j=10;           /* max bytes per line */
                while(j--)
                        {outdec((litq[k++]&127));
                        if ((j==0) | (k>=litptr))
                                {nl();          /* need <cr> */
                                break;
                                }
                        outbyte(',');   /* separate bytes */
                        }
                }
        }

/*                                      */
/*      Dump all static variables       */
/*                                      */
dumpglbs()
        {
        int j;
        if(mainmode)
                ol("SECTION THREE,BSS");
        cptr=startglb;
        while (cptr<glbptr)
                {
                if(cptr[ident]!=function)
                        /* do if anything but function */
                        {
                        if(findext(cptr+name))
                                {
                                ot("XREF ");
                                outname(cptr);
                                nl();
                                }
                        else
                                {
                                if(mainmode)
                                        ot("XDEF ");
                                else ot("XREF ");
                                outname(cptr);
                                nl();
                                if(mainmode)
                                        {
                                        outname(cptr);  /* output name as label... */
                                        if(cptr[ident]==pointer)
                                                defstorptr();
                                        else if(cptr[type]==cint)
                                                defstorint();
                                        else defstorchr();
                                        j=((cptr[offset]&255)
                                                + ((cptr[offset+1]&255)<<8));
                                        outdec(j);
                                        nl();
                                        }
                                }
                        }
                cptr=cptr+symsiz;
                }
        }

/*                                      */
/*      Report errors for user          */
/*                                      */
errorsummary()
        {
        nl();
        outstr("There were ");
        outdec(errcnt); /* total # errors */
        outstr(" errors in compilation.");
        nl();
        }

/*      Greet User      */
hello()
        {
        clrscreen();    /* clear screen function */
        nl();nl();              /* print banner */
        pl(BANNER);
        nl();
        pl(AUTHOR);
        nl();nl();
        pl(VERSION);
        nl();
        nl();
} /* end of hello */

see()
        {
        kill();
        /* see if user wants to be sure to see all errors */
        pl("Should I pause after an error (y,N)? ");
        gets(line);
        errstop=0;
        if((ch()=='Y')|(ch()=='y'))
                errstop=1;
        kill();
        pl("Do you want the Small-C text to appear (y,N)? ");
        gets(line);
        ctext=0;
        if((ch()=='Y')|(ch()=='y')) ctext=1;
        if(mainmode)
                {
                kill();
                pl("Compiling 'main()' (Y,n)? ");
                gets(line);
                if((ch()=='N')|(ch()=='n')) mainmode=0;
                }
        }

/*                                      */
/*      Get output filename             */
/*                                      */
openout()
        {
        output=0;               /* start with none */
        while(output==0)
                {
                kill();
                pl("Output filename? "); /* ask...*/
                gets(line);     /* get a filename */
                if(ch()==0)break;       /* none given... */
                if((output=fopen(line,"w"))==NULL) /* if given, open */
                        {output=0;      /* can't open */
                        error("Open failure!");
                        }
                }
        kill();                 /* erase line */
        }

/*                                      */
/*      Get (next) input file           */
/*                                      */
openin()
{
        input=0;                /* none to start with */
        while(input==0){        /* any above 1 allowed */
                kill();         /* clear line */
                pl("Input filename? ");
                gets(line);     /* get a name */
                if(ch()==0) break;
                if((input=fopen(line,"r"))!=NULL)
                        newfile();                      /* gtf 7/16/80 */
                else {  input=0;        /* can't open it */
                        pl("Open failure");
                        }
                }
        kill();         /* erase line */
        }

/*                                      */
/*      Reset line count, etc.          */
/*                      gtf 7/16/80     */
newfile()
        {
        lineno  = 0;    /* no lines read */
        fnstart = 0;    /* no fn. start yet. */
        currfn  = NULL; /* because no fn. yet */
        infunc  = 0;    /* therefore not in fn. */
        }

/*                                      */
/*      Open an include file            */
/*                                      */
doinclude()
        {
        blanks();       /* skip over to name */
        toconsole();                                    /* gtf 7/16/80 */
        outstr("#include "); outstr(line+lptr); nl();
        tofile();
        if(input2)                                      /* gtf 7/16/80 */
                error("Cannot nest include files");
        else if((input2=fopen(line+lptr,"r"))==NULL)
                {input2=0;
                error("Open failure on include file");
                }
        else {  saveline = lineno;
                savecurr = currfn;
                saveinfn = infunc;
                savestart= fnstart;
                newfile();
                }
        kill();         /* clear rest of line */
                        /* so next read will come from */
                        /* new file (if open */
        }

/*                                      */
/*      Close an include file           */
/*                      gtf 7/16/80     */
endinclude()
        {
        toconsole();
        outstr("#end include"); nl();
        tofile();
        input2  = 0;
        lineno  = saveline;
        currfn  = savecurr;
        infunc  = saveinfn;
        fnstart = savestart;
        }

/*                                      */
/*      Close the output file           */
/*                                      */
closeout()
        {
        tofile();       /* if diverted, return to file */
        if(output)fclose(output); /* if open, close it */
        output=0;               /* mark as closed */
        }

/*                                      */
/*      Declare a static variable       */
/*        (i.e. define for use)         */
/*                                      */
/* makes an entry in the symbol table so subsequent */
/*  references can call symbol by name  */
declglb(typ)            /* typ is cchar or cint */
        int typ;
        {
        int k, j;
        char sname[namesize];
        while(1)
                {
                while(1)
                        {
                        if(endst())
                                return; /* do line */
                        k=1;            /* assume 1 element */
                        if(match("*"))  /* pointer ? */
                                j=pointer;      /* yes */
                        else j=variable; /* no */
                        if (symname(sname)==0) /* name ok? */
                                illname(); /* no... */
                        if(findglb(sname)) /* already there? */
                                multidef(sname);
                        if (match("["))         /* array? */
                                {k=needsub();   /* get size */
                                if(k)j=array;   /* !0=array */
                                else j=pointer; /* 0=ptr */
                                }
                        addglb(sname,j,typ,k); /* add symbol */
                        if(cextern) addext(sname,statref);
                        break;
                        }
                if (match(",")==0) return; /* more? */
                }
        }

/*                                      */
/*      Declare local variables         */
/*      (i.e. define for use)           */
/*                                      */
/* works just like "declglb" but modifies machine stack */
/*      and adds symbol table entry with appropriate */
/*      stack offset to find it again                   */
declloc(typ)            /* typ is cchar or cint */
        int typ;
        {
        int idclass, size;
        char sname[namesize];
        while(1)
                {
                while(1)
                        {
                        if(endst())
                                return;
                        if(match("*"))
                                idclass=pointer;
                        else idclass=variable;
                        if(symname(sname)==0)
                                illname();
                        if(findloc(sname))
                                multidef(sname);
                        if(match("["))
                                {
                                size=needsub();
                                if(size)
                                        {
                                        idclass=array;
                                        if(typ==cint)
                                                size=size<<2;   /* multiply by 4 */
                                        else if(size&1)
                                                size++;
                                        }
                                else
                                        {idclass=pointer;
                                        size=4;
                                        }
                                }
                        else
                                if((typ==cchar) & (idclass!=pointer))
                                        size=2; /* 68000 stack address can't be odd */
                                else size=4;
                        /* change machine stack */
                        Zsp=modstk(Zsp-size);
                        addloc(sname,idclass,typ,Zsp);
                        break;
                        }
                if (match(",")==0) return;
                }
        }

/*      >>>>>> start of cc2 <<<<<<<<    */

/*                                      */
/*      Get required array size         */
/*                                      */
/* invoked when declared variable is followed by "[" */
/*      this routine makes subscript the absolute */
/*      size of the array. */
needsub()
        {
        int num[1];
        if(match("]"))return 0; /* null size */
        if (number(num)==0)     /* go after a number */
                {error("must be constant");     /* it isn't */
                num[0]=1;               /* so force one */
                }
        if (num[0]<0)
                {error("negative size illegal");
                num[0]=(-num[0]);
                }
        needbrack("]");         /* force single dimension */
        return num[0];          /* and return size */
        }

/*                                      */
/*      Begin a function                */
/*                                      */
/* Called from "parse" this routine tries to make a function */
/*      out of what follows.    */
newfunc()
        {
        char n[namesize]; /* ptr => currfn,  gtf 7/16/80 */
        if (symname(n)==0)
                {
                if(eof==0) error("illegal function or declaration");
                kill(); /* invalidate line */
                return;
                }
        fnstart=lineno;         /* remember where fn began      gtf 7/2/80 */
        infunc=1;               /* note, in function now.       gtf 7/16/80 */
        if(currfn=findglb(n))   /* already in symbol table ? */
                {if(currfn[ident]!=function)multidef(n);
                        /* already variable by that name */
                else if(currfn[offset]==function)multidef(n);
                        /* already function by that name */
                else currfn[offset]=function;
                        /* otherwise we have what was earlier*/
                        /*  assumed to be a function */
                }
        /* if not in table, define as a function now */
        else currfn=addglb(n,function,cint,function);
        toconsole();                                    /* gtf 7/16/80 */
        outstr("====== "); outstr(currfn+name); outstr("()"); nl();
        tofile();
        /* we had better see open paren for args... */
        if(match("(")==0)error("missing open paren");
        ot("XDEF ");outname(n);nl();
        outname(n);col();nl();  /* print function name */
        argstk=0;               /* init arg count */
        while(match(")")==0)    /* then count args */
                /* any legal name bumps arg count */
                {if(symname(n))argstk=argstk+4;
                else{error("illegal argument name");junk();}
                blanks();
                /* if not closing paren, should be comma */
                if(streq(line+lptr,")")==0)
                        {if(match(",")==0)
                        error("expected comma");
                        }
                if(endst())break;
                }
        locptr=startloc;        /* "clear" local symbol table*/
        Zsp=0;                  /* preset stack ptr */
        while(argstk)
                /* now let user declare what types of things */
                /*      those arguments were */
                {if(amatch("char",4)){getarg(cchar);ns();}
                else if(amatch("int",3)){getarg(cint);ns();}
                else{error("wrong number args");break;}
                }
        if(statement()!=streturn) /* do a statement, but if */
                                /* it's a return, skip */
                                /* cleaning up the stack */
                {modstk(0);
                zret();
                }
        Zsp=0;                  /* reset stack ptr again */
        locptr=startloc;        /* deallocate all locals */
        infunc=0;               /* not in fn. any more          gtf 7/2/80 */
        }

/*                                      */
/*      Declare argument types          */
/*                                      */
/* called from "newfunc" this routine adds an entry in the */
/*      local symbol table for each named argument */
getarg(idtype)          /* idtype = cchar or cint */
        int idtype;
        {
        char idname[namesize];
        int idclass;
        while(1)
                {if(argstk==0)return;   /* no more args */
                if(match("*"))idclass=pointer;
                        else idclass=argument;
                if(symname(idname)==0) illname();
                if(findloc(idname))multidef(idname);
                if(match("["))  /* pointer ? */
                /* it is a pointer, so skip all */
                /* stuff between "[]" */
                        {while(inbyte()!=']')
                                if(endst())break;
                        idclass=pointer;
                        /* add entry as pointer */
                        }
                addloc(idname,idclass,idtype,argstk);
                argstk=argstk-4;        /* cnt down */
                if(endst())return;
                if(match(",")==0)error("expected comma");
                }
        }

/*      Statement parser                */
/*                                      */
/* called whenever syntax requires      */
/*      a statement.                     */
/*  this routine performs that statement */
/*  and returns a number telling which one */
statement()
{
/* comment out ctrl-C check since ctrl-break will work on PC */
/*      if(cpm(11,0) & 1) */    /* check for ctrl-C             gtf 7/17/80 */
        /*      if(getchar()==3) */
                /*      abort(); */
        if ((ch()==0) & (eof)) return;
        else if(amatch("char",4))
                {declloc(cchar);ns();}
        else if(amatch("int",3))
                {declloc(cint);ns();}
        else if(match("{"))compound();
        else if(amatch("if",2))
                {doif();lastst=stif;}
        else if(amatch("while",5))
                {dowhile();lastst=stwhile;}
        else if(amatch("return",6))
                {doreturn();ns();lastst=streturn;}
        else if(amatch("break",5))
                {dobreak();ns();lastst=stbreak;}
        else if(amatch("continue",8))
                {docont();ns();lastst=stcont;}
        else if(match(";"));
        else if(match("#asm"))
                {doasm();lastst=stasm;}
        /* if nothing else, assume it's an expression */
        else{expression();ns();lastst=stexp;}
        return lastst;
}

/*                                      */
/*      Semicolon enforcer              */
/*                                      */
/* called whenever syntax requires a semicolon */
ns()    {if(match(";")==0)error("missing semicolon");}

/*                                      */
/*      Compound statement              */
/*                                      */
/* allow any number of statements to fall between "{}" */
compound()
        {
        ++ncmp;         /* new level open */
        while (match("}")==0) statement(); /* do one */
        --ncmp;         /* close current level */
        }

/*                                      */
/*              "if" statement          */
/*                                      */
doif()
        {
        int flev,fsp,flab1,flab2;
        flev=locptr;    /* record current local level */
        fsp=Zsp;                /* record current stk ptr */
        flab1=getlabel(); /* get label for false branch */
        test(flab1);    /* get expression, and branch false */
        statement();    /* if true, do a statement */
        Zsp=modstk(fsp);        /* then clean up the stack */
        locptr=flev;    /* and deallocate any locals */
        if (amatch("else",4)==0)        /* if...else ? */
                /* simple "if"...print false label */
                {printlabel(flab1);col();nl();
                return;         /* and exit */
                }
        /* an "if...else" statement. */
        jump(flab2=getlabel()); /* jump around false code */
        printlabel(flab1);col();nl();   /* print false label */
        statement();            /* and do "else" clause */
        Zsp=modstk(fsp);                /* then clean up stk ptr */
        locptr=flev;            /* and deallocate locals */
        printlabel(flab2);col();nl();   /* print true label */
        }

/*                                      */
/*      "while" statement               */
/*                                      */
dowhile()
        {
        int wq[4];              /* allocate local queue */
        wq[wqsym]=locptr;       /* record local level */
        wq[wqsp]=Zsp;           /* and stk ptr */
        wq[wqloop]=getlabel();  /* and looping label */
        wq[wqlab]=getlabel();   /* and exit label */
        addwhile(wq);           /* add entry to queue */
                                /* (for "break" statement) */
        printlabel(wq[wqloop]);col();nl(); /* loop label */
        test(wq[wqlab]);        /* see if true */
        statement();            /* if so, do a statement */
        Zsp = modstk(wq[wqsp]); /* zap local vars: 9/25/80 gtf */
        jump(wq[wqloop]);       /* loop to label */
        printlabel(wq[wqlab]);col();nl(); /* exit label */
        locptr=wq[wqsym];       /* deallocate locals */
        delwhile();             /* delete queue entry */
        }

/*                                      */
/*                                      */
/*      "return" statement              */
/*                                      */
doreturn()
        {
        /* if not end of statement, get an expression */
        if(endst()==0)expression();
        modstk(0);      /* clean up stk */
        zret();         /* and exit function */
        }

/*                                      */
/*      "break" statement               */
/*                                      */
dobreak()
        {
        int *ptr;
        /* see if any "whiles" are open */
        if ((ptr=readwhile())==0) return;       /* no */
        modstk((ptr[wqsp]));    /* else clean up stk ptr */
        jump(ptr[wqlab]);       /* jump to exit label */
        }

/*                                      */
/*      "continue" statement            */
/*                                      */
docont()
        {
        int *ptr;
        /* see if any "whiles" are open */
        if ((ptr=readwhile())==0) return;       /* no */
        modstk((ptr[wqsp]));    /* else clean up stk ptr */
        jump(ptr[wqloop]);      /* jump to loop label */
        }

/*                                      */
/*      "asm" pseudo-statement          */
/*                                      */
/* enters mode where assembly language statement are */
/*      passed intact through parser    */
doasm()
        {
        cmode=0;                /* mark mode as "asm" */
        while (1)
                {inline();      /* get and print lines */
                if (match("#endasm")) break;    /* until... */
                if(eof)break;
                outstr(line);
                nl();
                }
        kill();         /* invalidate line */
        cmode=1;                /* then back to parse level */
        }
