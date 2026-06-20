/*
    Mklib 1.0 - a source file generator for Amiga shared libraries
    Compiled with Manx v3.6a small code model/16 bit int. (see makefile)

    copyright 1988 Edwin Hoogerbeets

    This software and the files it produces are freely redistributable
    as long there is no charge beyond reasonable copy fees and as long
    as this notice stays intact.

    Thanks to Jimm Mackraz for Elib on Fish 87, from which much of this
    program is lifted. Also thanks to Neil Katin for his mylib.asm upon
    which elib is based.
*/
#include <stdio.h>
#include <ctype.h>
#include <edlib.h>
#include "mklib.h"

void error(msg)
char *msg;
{
    fprintf(stderr,"Error: %s\n",msg);
    exit(1);
}

void writeto(file,header)
FILE *file;
char *header[];
{
    int index = 0;

    while ( header[index] != NULL  )
        fprintf(file,"%s\n",header[index++]);
}

/* init opens and initializes all the output files */
void init()
{
    /* open file with startup code */
    if ( (startup = fopen("startup.asm","w")) == NULL )
        error("Could not open startup code file");

    /* write the header and the body to the file */
    writeto(startup,asmheader);
    writeto(startup,startupcode);

    /* we are finished with the startup code file */
    fclose(startup);

    /* open romtag file */
    if ( (romtag = fopen("rtag.asm","w")) == NULL )
        error("Could not open romtag file");

    /* write the header and the romtag info */
    writeto(romtag,asmheader);
    writeto(romtag,rtag);

    /* we are finished with this one too */
    fclose(romtag);


    /* open library include file */
    if ( (inc = fopen("lib.h","w")) == NULL )
        error("Could not open library include file");

    /* write the header and the info */
    writeto(inc,cheader);
    writeto(inc,incbody);

    /* we are finished with this one too */
    fclose(inc);

    /* open the interface, link and make file for processing and add in
       the appropriate header info */

    /* open library file */
    if ( (lib = fopen("lib.c","w")) == NULL )
        error("Could not open library main file");

    /* write the header */
    writeto(lib,cheader);

    /* open link header file */
    if ( (linkh = fopen("link.h","w")) == NULL )
        error("Could not open link header main file");

    /* write the header */
    writeto(linkh,cheader);

    /* open library interface file */
    if ( (interface = fopen("interface.asm","w")) == NULL )
        error("Could not open library interface file");

    /* write the header */
    writeto(interface,asmheader);
    writeto(interface,faceheader);

    /* open library linker file */
    if ( (link = fopen("link.asm","w")) == NULL )
        error("Could not open library linker file");

    /* write the header */
    writeto(link,asmheader);
    writeto(link,linkhead);

    /* open makefile */
    if ( (makefile = fopen("makefile","w")) == NULL )
        error("Could not open makefile");

    /* write the header */
    writeto(makefile,makeheader);

    return();
}


/* rudimentary scanner for picking up tokens to be parsed for function
   declarations */
int getoken(file)
char *file;
{
    char c;
    short cont = 1, eoc = 0;    /* continue loop and end of comment flags */

    while ( isspace(c = getc(file)) );

    if ( c == EOF )
        return(NOTHING);

    /* if the character is escaped, then ignore it */
    if ( c == '\\' ) {
        getc(file);
        return(OTHER);
    }

    /* if the character is '/' and is followed by a '*', then you have
       a comment which you can throw out until the end of comment
       characters come along, example here ->*/

    if ( c == '/' ) {
        if ( (c = getc(file)) == '*' ) {
            /* get a comment */
            while ( (c = getc(file)) != EOF && cont ) {
                if ( c == '/' && eoc ) {
                    cont = 0;
                } else {
                    eoc = 0;
                }
                if ( c == '*' )
                    eoc = 1;
            }
            if ( c == EOF )
                return(NOTHING);
        }
        ungetc(c,file);
        return(OTHER);
    }


    if ( iscsymf(c)  ) {

        tempc = 0;
        tempfunc[tempc++] = c;

        /* to allow tokens like asdf.library, we must check for '.' too */
        while ( iscsym(c = getc(file)) || c == '.' )
            tempfunc[tempc++] = c;

        tempfunc[tempc] = '\0';
        ungetc(c,file);

        if ( !strcmp("LONG",tempfunc) || !strcmp("ULONG",tempfunc) )
            return(LONGT);

        if ( !strcmp("extern",tempfunc) )
            return(EXT);

        if ( !strcmp("char",tempfunc) )
            return(CHAR);

        if ( !strcmp("myname",tempfunc) )
            return(MYNAME);

        if ( !strcmp("myid",tempfunc) )
            return(MYID);

        return(IDENT);
    }

    switch (c) {
        case ',':
            return(COMMA);
        case ';':
            return(SEMI);
        case '{':
            return(OBRACE);
        case '}':
            return(CBRACE);
        case '(':
            return(OBRACK);
        case ')':
            return(CBRACK);
        case '*':
            return(STAR);
        case '\"':
            return(QUOTE);
        default:
            return(OTHER);
    }
}

void addfunc(name,count)
char *name;
int count;
{
    if ( ftcounter < MAXFUNC ) {
        strcpy(functable[ftcounter].name,name);
        functable[ftcounter++].numofargs = count;
    } else {
        error("Out of function name table space. Recompile with bigger MAXFUNC");
    }
}

/* process reads the input files and generates the proper output in the
   interface, link and makefiles */
void process(file)
char *file;
{
    FILE *in;               /* pointer to input file */
    int leftcount = 0;      /* counter for number of { } to tell when a
                               function starts */
    int token, argcount;
    char tempname[MAXLEN], str[MAXLEN];

    if ( (in = fopen(file,"r")) == NULL ) {
        fprintf(stderr,"Could not open input file %s\n",file);
        return();
    }

    /* fill the function name table with the names of the functions in
       the given file */
    while ( (token = getoken(in)) != NOTHING ) {

        switch ( token ) {
            /* extern definition... throw out everything to end of statement
               which is denoted by a ; */
            case EXT:
                while ( (token = getoken(in)) != SEMI && token != NOTHING ) ;
                break;

            /* (maybe) a definition of a function */
            case LONGT:
                if ( !leftcount ) {
                    if ( (token = getoken(in)) == IDENT ) {
                        if ( (token = getoken(in)) == OBRACK ) {

                            argcount = 0;

                            /* save the function name from further
                               thrashing by the scanner */

                            strcpy(tempname,tempfunc);

                            token = getoken(in);

                            while ( token != CBRACK ) {

                                if ( token == IDENT ) {
                                    ++argcount;
                                } else if ( token != COMMA ) {
                                    sprintf(str,"Bad declaration syntax in\
 file %s, function %s\n",file,tempname);
                                    error(str);
                                }
                                token = getoken(in);
                            }

                            /* if a semicolon follows then this is only a
                               forward declaration and should not be added
                               to the functions list. If anything else,
                               then this is a definition. */
                            if ( (token = getoken(in)) != SEMI ) {
                                addfunc(tempname,argcount);
                            }

                        }
                    }
                }
                break;

            /* entering a block */
            case OBRACE:
                ++leftcount;
                break;

            /* exiting a block */
            case CBRACE:
                if ( leftcount )
                    --leftcount;
                break;

            case CHAR:
                /* possibly myname is defined */
                if ( !leftcount ) {

                    /* might be declared as char *myname = "foo.library" */
                    if ( (token = getoken(in)) == STAR ) {

                        if ( (token = getoken(in)) == MYNAME &&
                            !mynamedef ) {

                            token = getoken(in);   /* skip the = */

                            if ( (token = getoken(in)) == QUOTE) {
                                /* we have ignition! */

                                if ( (token = getoken(in)) == IDENT ) {
                                    /* we have liftoff! */

                                    strcpy(myname,tempfunc);
                                    mynamedef = 1;

                                }
                            }
                        } else if ( token == MYID && !myiddef ) {

                            token = getoken(in);   /* skip the = */

                            if ( (token = getoken(in)) == QUOTE) {
                                /* we have ignition! */

                                if ( (token = getoken(in)) == IDENT ) {
                                    /* we have liftoff! */

                                    strcpy(myid,tempfunc);
                                    myiddef = 1;

                                }
                            }
                        }

                    /* else declared as char myname[] = "foo.library" */
                    } else if ( token == MYNAME && !mynamedef ) {

                        /* now skip the [, ] and = */
                        token = getoken(in);
                        token = getoken(in);
                        token = getoken(in);

                        if ( (token = getoken(in)) == QUOTE) {
                            /* we have ignition! */

                            if ( (token = getoken(in)) == IDENT ) {
                                /* we have liftoff! */

                                strcpy(myname,tempfunc);
                                mynamedef = 1;

                            }
                        }
                    } else if ( token == MYID && !myiddef ) {

                        /* now skip the [, ] and = */
                        token = getoken(in);
                        token = getoken(in);
                        token = getoken(in);

                        if ( (token = getoken(in)) == QUOTE) {
                            /* we have ignition! */

                            if ( (token = getoken(in)) == IDENT ) {
                                /* we have liftoff! */

                                strcpy(myid,tempfunc);
                                myiddef = 1;

                            }
                        }
                    }
                }
                break;

            default:
                break;
        }
    }

    fclose(in);
}

/* converts a file name from a .c to a .o file */
void to_dot_o(out,in)
char *out,*in;
{
    int index = strrpos(in,'.');

    strcpy(out,in);

    /* if there is no '.' in the file name or if the letter after the '.'
       is not 'c', then concatenate a ".o" to the end of the file name,
       or else just change the 'c' to an 'o' */

    if ( index == -1 || in[index+1] != 'c' ) {
        strcat(out,".o");
    } else {
        out[index+1] = 'o';
    }

    return();
}

/* shutdown cleans up and closes the output files */
void shutdown(argc,argv)
int argc;
char **argv;
{
    int index, num;
    char temp[MAXLEN];

    if ( !mynamedef ) {
        strcpy(myname,"mylib.library");
        printf("Myname variable not defined: using \"mylib.library\"\n");
        fprintf(lib,"char myname[] = \"mylib.library\";\n");
    }

    if ( !myiddef ) {
        printf("Myid variable not defined: using \"mylib version 1.0\"\n");
        fprintf(lib,"char myid[] = \"mylib version 1.0\";\n");
    }

    fprintf(lib,"\n");
    writeto(lib,mandatory);

    fprintf(linkh,"APTR libbase;\n\n");

    puts("The following LONG functions were found in your source:");
    puts("#  : args name");
    for ( index = 0 ; index < ftcounter ; index++  ) {
        printf("%-3d: %d    %-30s\n",index,functable[index].numofargs,
               functable[index].name);
        fprintf(interface,"        dc.l    X%s\n",functable[index].name);
        fprintf(link,"        LIBDEF _LVO%s\n",functable[index].name);
        fprintf(linkh,"extern LONG %s();\n",functable[index].name);
    }

    writeto(link,link2);

    writeto(interface,face2);

    for ( index = 0 ; index < ftcounter ; index++  ) {
        fprintf(link,"        public _%s\n",functable[index].name);
        fprintf(interface,"        public  _%s\n",functable[index].name);
    }

    writeto(interface,facemid);
    fprintf(link,"\n");

    for ( index = 0 ; index < ftcounter ; index++  ) {
        fprintf(link,"_%s:\n",functable[index].name);

        /* check here for arguments and which registers to put them in */
        if ( functable[index].numofargs > 4 )
            fprintf(link,"        store\n");

        for ( num = 0 ; num < functable[index].numofargs ; num++ )
            fprintf(link,"        move.l  %d(sp),%s\n",num*4+4,regs[num]);

        fprintf(link,"        move.l  _libbase,a6\n");

        if ( functable[index].numofargs > 4 ) {
            fprintf(link,"        jsr     _LVO%s(a6)\n",functable[index].name);
            fprintf(link,"        retrieve\n");
            fprintf(link,"        rts\n\n");
        } else {
            fprintf(link,"        jmp     _LVO%s(a6)\n\n",functable[index].name);
        }

        fprintf(interface,"X%s:\n",functable[index].name);
        fprintf(interface,"        setup\n");

        /* check here for arguments and how to put them on the stack */
        for ( num = functable[index].numofargs - 1 ; num >= 0 ; num-- )
            fprintf(interface,"        push %s\n",regs[num]);

        fprintf(interface,"        jsr _%s\n",functable[index].name);
        fprintf(interface,"        restore ");
        if ( functable[index].numofargs )
            fprintf(interface,"%d",functable[index].numofargs*4);
        fprintf(interface,"\n\n");
    }

    fprintf(interface,"        end\n");

    fprintf(makefile,"OBJS=startup.o rtag.o interface.o lib.o ");
    for ( index = 1 ; index < argc ; index++ ) {
        to_dot_o(temp,argv[index]);
        fprintf(makefile,"%s ",temp);
    }

    fprintf(makefile,"\n\n%s: $(OBJS)\n",myname);

    writeto(makefile,makefooter);

    /* clean up the open files */
    fclose(linkh);
    fclose(lib);
    fclose(interface);
    fclose(link);
    fclose(makefile);

    return();
}

main(argc,argv)
int argc;
char **argv;
{
    int index = 1;

    /* check for correct usage */
    if ( argc < 2  ) {
        printf("Usage: %s library_source_file ...\n",argv[0]);
        exit(1);
    }

    /* open files and write out initial info */
    init();

    /* search through each source file for routines and add each routine
       to the appropriate spot */
    while ( index < argc  )
        process(argv[index++]);

    /* write out final info and close files */
    shutdown(argc,argv);

    exit(0);
}

