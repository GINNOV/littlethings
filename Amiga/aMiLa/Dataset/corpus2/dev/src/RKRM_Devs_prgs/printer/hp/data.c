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
 *        Data.c table for HP_LaserJet (Plus and II compatible) driver.
 */

char *CommandTable[] = {
        "\375\033E\375",/* 00 aRIS reset                        */
        "\377",         /* 01 aRIN initialize                   */
        "\012",         /* 02 aIND linefeed                     */
        "\015\012",     /* 03 aNEL CRLF                         */
        "\033&a-1R",    /* 04 aRI reverse LF                    */

                        /* 05 aSGR0 normal char set             */
        "\033&d@\033(sbS",
        "\033(s1S",     /* 06 aSGR3 italics on                  */
        "\033(sS",      /* 07 aSGR23 italics off                */
        "\033&dD",      /* 08 aSGR4 underline on                */
        "\033&d@",      /* 09 aSGR24 underline off              */
        "\033(s5B",     /* 10 aSGR1 boldface on                 */
        "\033(sB",      /* 11 aSGR22 boldface off               */
        "\377",         /* 12 aSFC set foreground color         */
        "\377",         /* 13 aSBC set background color         */

        "\033(s10h1T",  /* 14 aSHORP0 normal pitch              */
        "\033(s12h2T",  /* 15 aSHORP2 elite on                  */
        "\033(s10h1T",  /* 16 aSHORP1 elite off                 */
        "\033(s15H",    /* 17 aSHORP4 condensed fine on         */
        "\033(s10H",    /* 18 aSHORP3 condensed fine off        */
        "\377",         /* 19 aSHORP6 enlarge on                */
        "\377",         /* 20 aSHORP5 enlarge off               */

        "\033(s7B",     /* 21 aDEN6 shadow print on             */
        "\033(sB",      /* 22 aDEN5 shadow print off            */
        "\033(s3B",     /* 23 aDEN4 double strike on            */
        "\033(sB",      /* 24 aDEN3 double strike off           */
        "\377",         /* 25 aDEN2 NLQ on                      */
        "\377",         /* 26 aDEN1 NLQ off                     */

        "\377",         /* 27 aSUS2 superscript on              */
        "\377",         /* 28 aSUS1 superscript off             */
        "\377",         /* 29 aSUS4 subscript on                */
        "\377",         /* 30 aSUS3 subscript off               */
        "\377",         /* 31 aSUS0 normalize the line          */
        "\033&a-.5R",   /* 32 aPLU partial line up              */
        "\033=",        /* 33 aPLD partial line down            */

        "\033(s3T",     /* 34 aFNT0 Typeface 0                  */
        "\033(s0T",     /* 35 aFNT1 Typeface 1                  */
        "\033(s1T",     /* 36 aFNT2 Typeface 2                  */
        "\033(s2T",     /* 37 aFNT3 Typeface 3                  */
        "\033(s4T",     /* 38 aFNT4 Typeface 4                  */
        "\033(s5T",     /* 39 aFNT5 Typeface 5                  */
        "\033(s6T",     /* 40 aFNT6 Typeface 6                  */
        "\033(s7T",     /* 41 aFNT7 Typeface 7                  */
        "\033(s8T",     /* 42 aFNT8 Typeface 8                  */
        "\033(s9T",     /* 43 aFNT9 Typeface 9                  */
        "\033(s10T",    /* 44 aFNT10 Typeface 10                */

        "\033(s1P",     /* 45 aPROP2 proportional on            */
        "\033(sP",      /* 46 aPROP1 proportional off           */
        "\033(sP",      /* 47 aPROP0 proportional clear         */
        "\377",         /* 48 aTSS set proportional offset      */
        "\377",         /* 49 aJFY5 auto left justify           */
        "\377",         /* 50 aJFY7 auto right justify          */
        "\377",         /* 51 aJFY6 auto full jusitfy           */
        "\377",         /* 52 aJFY0 auto jusity off             */
        "\377",         /* 53 aJFY3 letter space                */
        "\377",         /* 54 aJFY1 word fill                   */

        "\033&l8D",     /* 55 aVERP0 1/8" line spacing          */
        "\033&l6D",     /* 56 aVERP1 1/6" line spacing          */
        "\377",         /* 57 aSLPP set form length             */
        "\033&l1L",     /* 58 aPERF perf skip n (n > 0)         */
        "\033&lL",      /* 59 aPERF0 perf skip off              */

        "\377",         /* 60 aLMS set left margin              */
        "\377",         /* 61 aRMS set right margin             */
        "\377",         /* 62 aTMS set top margin               */
        "\377",         /* 63 aBMS set bottom margin            */
        "\377",         /* 64 aSTBM set T&B margins             */
        "\377",         /* 65 aSLRM set L&R margins             */
        "\0339\015",    /* 66 aCAM clear margins                */

        "\377",         /* 67 aHTS set horiz tab                */
        "\377",         /* 68 aVTS set vert tab                 */
        "\377",         /* 69 aTBC0 clear horiz tab             */
        "\377",         /* 70 aTBC3 clear all horiz tabs        */
        "\377",         /* 71 aTBC1 clear vert tab              */
        "\377",         /* 72 aTBC4 clear all vert tabs         */
        "\377",         /* 73 aTBCALL clear all h & v tabs      */
        "\377",         /* 74 aTBSALL set default tabs          */

        "\377",         /* 75 aEXTEND extended commands         */
        "\377"          /* 76 aRAW next 'n' chars are raw       */
};

char *ExtendedCharTable[] = {
/*
    " ", "!", "c", "L", "o", "Y", "|", "S",

    "\"", "c", "a", "<", "~", "-", "r", "-",

    "*", "+", "2", "3", "'", "u", "P", ".",

    ",", "1", "o", ">", "/", "/", "/", "?",

    "A", "A", "A", "A", "A", "A", "A", "C",

    "E", "E", "E", "E", "I", "I", "I", "I",

    "D", "N", "O", "O", "O", "O", "O", "x",

    "O", "U", "U", "U", "U", "Y", "P", "B",

    "a", "a", "a", "a", "a", "a", "a", "c",

    "e", "e", "e", "e", "i", "i", "i", "i",

    "d", "n", "o", "o", "o", "o", "o", "/",

    "o", "u", "u", "u", "u", "y", "p", "y"
*/

        " ", "\270", "\277", "\273", "\272", "\274", "|", "\275",
        "\253", "c", "\371", "\373", "~", "\366", "r", "\260",
        "\263", "\376", "2", "3", "\250", "\363", "\364", "\362",
        ",", "1", "\372", "\375", "\367", "\370", "\365", "\271",
        "\241", "\340", "\242", "\341", "\330", "\320", "\323", "\264",
        "\243", "\334", "\244", "\245", "\346", "\345", "\246", "\247",
        "\343", "\266", "\350", "\347", "\337", "\351", "\332", "x",
        "\322", "\255", "\355", "\256", "\333", "\261", "\360", "\336",
        "\310", "\304", "\300", "\342", "\314", "\324", "\327", "\265",
        "\311", "\305", "\301", "\315", "\331", "\325", "\321", "\335",
        "\344", "\267", "\312", "\306", "\302", "\352", "\316", "-\010:",
        "\326", "\313", "\307", "\303", "\317", "\262", "\361", "\357"
};
