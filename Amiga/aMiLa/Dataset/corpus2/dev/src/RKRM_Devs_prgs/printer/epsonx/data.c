/*
 * Copyright (c) 1992 Commodore-Amiga, Inc.
 * 
 * This example is provided in electronic form by Commodore-Amiga, Inc. for 
 * use with the "Amiga ROM Kernel Reference Manual: Devices", 3rd Edition, 
 * published by Addison-Wesley (ISBN 0-201-56775-X).
 * 
 * The "Amiga ROM Kernel Reference Manual: Devices" contains additional 
 * information on the correct usage of the techniques and operating system 
 * functions presented in these examples.  The source and executable code 
 * of these examples may only be distributed in free electronic form, via 
 * bulletin board or as part of a fully non-commercial and freely 
 * redistributable diskette.  Both the source and executable code (including 
 * comments) must be included, without modification, in any copy.  This 
 * example may not be published in printed form or distributed with any
 * commercial product.  However, the programming techniques and support
 * routines set forth in these examples may be used in the development
 * of original executable software products for Commodore Amiga computers.
 * 
 * All other rights reserved.
 * 
 * This example is provided "as-is" and is subject to change; no
 * warranties are made.  All use is at your own risk. No liability or
 * responsibility is assumed.
 *
 *****************************************************************************
 *
 *
 *       Data.c table for EpsonX driver.
 */

char *CommandTable[] ={
        "\375\033@\375",/* 00 aRIS reset                        */
        "\377",         /* 01 aRIN initialize                   */
        "\012",         /* 02 aIND linefeed                     */
        "\015\012",     /* 03 aNEL CRLF                         */
        "\377",         /* 04 aRI reverse LF                    */

                        /* 05 aSGR0 normal char set             */
        "\0335\033-\376\033F",
        "\0334",        /* 06 aSGR3 italics on                  */
        "\0335",        /* 07 aSGR23 italics off                */
        "\033-\001",    /* 08 aSGR4 underline on                */
        "\033-\376",    /* 09 aSGR24 underline off              */
        "\033E",        /* 10 aSGR1 boldface on                 */
        "\033F",        /* 11 aSGR22 boldface off               */
        "\377",         /* 12 aSFC set foreground color         */
        "\377",         /* 13 aSBC set background color         */

                        /* 14 aSHORP0 normal pitch              */
        "\033P\022\033W\376",
                        /* 15 aSHORP2 elite on                  */
        "\033M\022\033W\376",
        "\033P",        /* 16 aSHORP1 elite off                 */
                        /* 17 aSHORP4 condensed fine on         */
        "\017\033P\033W\376",
        "\022",         /* 18 aSHORP3 condensed fine off        */
        "\033W\001",    /* 19 aSHORP6 enlarge on                */
        "\033W\376",    /* 20 aSHORP5 enlarge off               */

        "\377",         /* 21 aDEN6 shadow print on             */
        "\377",         /* 22 aDEN5 shadow print off            */
        "\033G",        /* 23 aDEN4 double strike on            */
        "\033H",        /* 24 aDEN3 double strike off           */
        "\033x\001",    /* 25 aDEN2 NLQ on                      */
        "\033x\376",    /* 26 aDEN1 NLQ off                     */

        "\033S\376",    /* 27 aSUS2 superscript on              */
        "\033T",        /* 28 aSUS1 superscript off             */
        "\033S\001",    /* 29 aSUS4 subscript on                */
        "\033T",        /* 30 aSUS3 subscript off               */
        "\033T",        /* 31 aSUS0 normalize the line          */
        "\377",         /* 32 aPLU partial line up              */
        "\377",         /* 33 aPLD partial line down            */

        "\033R\376",    /* 34 aFNT0 Typeface 0                  */
        "\033R\001",    /* 35 aFNT1 Typeface 1                  */
        "\033R\002",    /* 36 aFNT2 Typeface 2                  */
        "\033R\003",    /* 37 aFNT3 Typeface 3                  */
        "\033R\004",    /* 38 aFNT4 Typeface 4                  */
        "\033R\005",    /* 39 aFNT5 Typeface 5                  */
        "\033R\006",    /* 40 aFNT6 Typeface 6                  */
        "\033R\007",    /* 41 aFNT7 Typeface 7                  */
        "\033R\010",    /* 42 aFNT8 Typeface 8                  */
        "\033R\011",    /* 43 aFNT9 Typeface 9                  */
        "\033R\012",    /* 44 aFNT10 Typeface 10                */

        "\033p1",       /* 45 aPROP2 proportional on            */
        "\033p0",       /* 46 aPROP1 proportional off           */
        "\377",         /* 47 aPROP0 proportional clear         */
        "\377",         /* 48 aTSS set proportional offset      */
        "\377",         /* 49 aJFY5 auto left justify           */
        "\377",         /* 50 aJFY7 auto right justify          */
        "\377",         /* 51 aJFY6 auto full jusitfy           */
        "\377",         /* 52 aJFY0 auto jusity off             */
        "\377",         /* 53 aJFY3 letter space                */
        "\377",         /* 54 aJFY1 word fill                   */

        "\0330",        /* 55 aVERP0 1/8" line spacing          */
        "\0332",        /* 56 aVERP1 1/6" line spacing          */
        "\033C",        /* 57 aSLPP set form length             */
        "\033N",        /* 58 aPERF perf skip n (n > 0)         */
        "\033O",        /* 59 aPERF0 perf skip off              */

        "\377",         /* 60 aLMS set left margin              */
        "\377",         /* 61 aRMS set right margin             */
        "\377",         /* 62 aTMS set top margin               */
        "\377",         /* 63 aBMS set bottom margin            */
        "\377",         /* 64 aSTBM set T&B margins             */
        "\377",         /* 65 aSLRM set L&R margins             */
        "\377",         /* 66 aCAM clear margins                */

        "\377",         /* 67 aHTS set horiz tab                */
        "\377",         /* 68 aVTS set vert tab                 */
        "\377",         /* 69 aTBC0 clear horiz tab             */
        "\033D\376",    /* 70 aTBC3 clear all horiz tabs        */
        "\377",         /* 71 aTBC1 clear vert tab              */
        "\033B\376",    /* 72 aTBC4 clear all vert tabs         */
                        /* 73 aTBCALL clear all h & v tabs      */
        "\033D\376\033B\376",
                        /* 74 aTBSALL set default tabs          */
        "\033D\010\020\030\040\050\060\070\100\110\120\130\376",

        "\377",         /* 75 aEXTEND extended commands         */
        "\377"          /* 76 aRAW next 'n' chars are raw       */
};

/*
   For each character from character 160 to character 255, there is
   an entry in this table, which is used to print (or simulate printing of)
   the full Amiga character set. (see AmigaDos Developer's Manual, pp A-3)
   This table is used only if there is a valid pointer to this table
   in the PEDData table in the printertag.asm file, and the VERSION is
   33 or greater.  Otherwise, a default table is used instead.
   To place non-printable characters in this table, you can either enter
   them as in C strings (ie \011, where 011 is an octal number, or as
   \\000 where 000 is any decimal number, from 1 to 3 digits.  This is
   usually used  to enter a NUL into the array (C has problems with it
   otherwise.), or if you forgot your octal calculator.  On retrospect,
   was a poor choice for this function, as you must say \\\\ to enter a
   backslash as a backslash.  Live and learn...
*/
char *ExtendedCharTable[] = {
        " ",                                    /* NBSP*/
        "\033R\007[\033R\\0",                   /* i */
        "c\010|",                               /* c| */
        "\033R\003#\033R\\0",                   /* L- */
        "\033R\005$\033R\\0",                   /* o */
        "\033R\010\\\\\033R\\0",                /* Y- */
        "|",                                    /* | */
        "\033R\002@\033R\\0",                   /* SS */

        "\033R\001~\033R\\0",                   /* " */
        "c",                                    /* copyright */
        "\033S\\0a\010_\033T",                  /* a_ */
        "<",                                    /* << */
        "~",                                    /* - */
        "-",                                    /* SHY */
        "r",                                    /* registered trademark */
        "-",                                    /* - */

        "\033R\001[\033R\\0",                   /* degrees */
        "+\010_",                               /* +_ */
        "\033S\\0002\033T",                     /* 2 */
        "\033S\\0003\033T",                     /* 3 */
        "'",                                    /* ' */
        "u",                                    /* u */
        "P",                                    /* reverse P */
        "\033S\\000.\033T",                     /* . */

        ",",                                    /* , */
        "\033S\\0001\033T",                     /* 1 */
        "\033R\001[\033R\\0\010-",              /* o_ */
        ">",                                    /* >> */
        "\033S\\0001\033T\010-\010\033S\0014\033T",     /* 1/4 */
        "\033S\\0001\033T\010-\010\033S\0012\033T",     /* 1/2 */
        "\033S\\0003\033T\010-\010\033S\0014\033T",     /* 3/4 */
        "\033R\007]\033R\\0",                   /* upside down ? */

        "A\010`",                               /* `A */
        "A\010'",                               /* 'A */
        "A\010^",                               /* ^A */
        "A\010~",                               /* ~A */
        "\033R\002[\033R\\0",                   /* "A */
        "\033R\004]\033R\\0",                   /* oA */
        "\033R\004[\033R\\0",                   /* AE */
        "C\010,",                               /* C, */

        "E\010`",                               /* `E */
        "\033R\011@\033R\\0",                   /* 'E */
        "E\010^",                               /* ^E */
        "E\010\033R\001~\033R\\0",              /* "E */
        "I\010`",                               /* `I */
        "I\010`",                               /* 'I */
        "I\010^",                               /* ^I */
        "I\010\033R\001~\033R\\0",              /* "I */

        "D\010-",                               /* -D */
        "\033R\007\\\\\033R\\0",                /* ~N */
        "O\010`",                               /* `O */
        "O\010'",                               /* 'O */
        "O\010^",                               /* ^O */
        "O\010~",                               /* ~O */
        "\033R\002\\\\\033R\\0",                /* "O */
        "x",                                    /* x */

        "\033R\004\\\\\033R\\0",                /* 0 */
        "U\010`",                               /* `U */
        "U\010'",                               /* 'U */
        "U\010^",                               /* ^U */
        "\033R\002]\033R\\0",                   /* "U */
        "Y\010'",                               /* 'Y */
        "T",                                    /* Thorn */
        "\033R\002~\033R\\0",                   /* B */

        "\033R\001@\033R\\0",                   /* `a */
        "a\010'",                               /* 'a */
        "a\010^",                               /* ^a */
        "a\010~",                               /* ~a */
        "\033R\002{\033R\\0",                   /* "a */
        "\033R\004}\033R\\0",                   /* oa */
        "\033R\004{\033R\\0",                   /* ae */
        "\033R\001\\\\\033R\\0",                /* c, */

        "\033R\001}\033R\\0",                   /* `e */
        "\033R\001{\033R\\0",                   /* 'e */
        "e\010^",                               /* ^e */
        "e\010\033R\001~\033R\\0",              /* "e */
        "\033R\006~\033R\\0",                   /* `i */
        "i\010'",                               /* 'i */
        "i\010^",                               /* ^i */
        "i\010\033R\001~\033R\\0",              /* "i */

        "d",                                    /* d */
        "\033R\007|\033R\\0",                   /* ~n */
        "\033R\006|\033R\\0",                   /* `o */
        "o\010'",                               /* 'o */
        "o\010^",                               /* ^o */
        "o\010~",                               /* ~o */
        "\033R\002|\033R\\0",                   /* "o */
        ":\010-"                                /* :- */

        "\033R\004|\033R\\0",                   /* o/ */
        "\033R\001|\033R\\0",                   /* `u */
        "u\010'",                               /* 'u */
        "u\010^",                               /* ^u */
        "\033R\002}\033R\\0",                   /* "u */
        "y\010'",                               /* 'y */
        "t",                                    /* thorn */
        "y\010\033R\001~\033R\\0"               /* "y */
};
