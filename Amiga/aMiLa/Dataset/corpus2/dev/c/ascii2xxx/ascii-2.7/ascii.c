/*
 * ascii.c -- quick crossreference for ASCII character aliases
 *
 * by Eric S. Raymond <esr@snark.thyrsus.com>, v1.0 March 1990
 *  v1.1 November 1990  -- revised `slang' from the 2.2 pronunciation guide
 *  v1.2 March 1995     -- Fixed a core-dump bug
 *  v1.3 October 1995   -- Fixed a bug that shows up only under ELF.
 *  v2.0 December 1995  -- Interpret ISO-style code table escapes.
 *  v2.1 August 1997    -- merge in changes by Ioannis Tambouras.
 *  v2.2 November 1997  -- merge in more changes by Ioannis Tambouras.
 *      v2.3 November 1997  -- incorporated Colin Plumb's splash-screen idea.
 *  v2.4 December 1998  -- additions by Brian Ginsbach.
 *  v2.5 December 1998  -- -s option by David N. Welton.
 *  v2.6 June 1999      -- bug fixes by M.R. van Schouwen.
 *  v2.7 October 1999   -- minor packaging and option changes.
 *
 * Tries to interpret arguments as names or aliases of ascii characters
 * and dumps out *all* the aliases of each. Accepts literal characters,
 * standard mnemonics, C-style backslash escapes, caret notation for control
 * characters, numbers in hex/decimal/octal/binary, English names.
 *
 * The slang names used are selected from the 2.2 version of the USENET ascii
 * pronunciation guide.  Some additional ones were merged in from the Jargon
 * File.
 *
 * Reproduce, use, and modify this as you like, as long as you don't
 * remove the authorship notice and clearly mark your changes. Send me
 * your improvements, please.
 */


/* -------------------------------------------------------------------- */
/* additions & porting to amigaos by Matthew J Fletcher 1999, for gcc,  */
/* ixemul or amiga stuff, contact   amimjf@connectfree.co.uk   -thanks. */
/*                                                                      */
/* I just a cleaned the source to work with egcs 2.91 and fixed small   */
/* bugs that must have got left in from somewhere.                      */
/* -------------------------------------------------------------------- */


#include <unistd.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>

#define REVISION 2.7

typedef char    *string;

static unsigned char terse = 0;
static unsigned char help = 0;
static unsigned char line = 0;

enum { decimal, hex, octal } mode;

void print_table(unsigned short delivery);

static string cnames[128][15] =
{
    {"NUL",     "Null",         (char *)NULL},
    {"SOH",     "Start Of Heading",     (char *)NULL},
    {"STX",     "Start of Text",    (char *)NULL},
    {"ETX",     "End of Text",      (char *)NULL},
    {"EOT",     "End Of Transmission",  (char *)NULL},
    {"ENQ",     "Enquiry",      (char *)NULL},
    {"ACK",     "Acknowledge",      (char *)NULL},
    {"BEL",     "Bell", "\\a", "Alert", (char *)NULL},
    {"BS",      "Backspace", "\\b", (char *)NULL},
    {"HT",  "TAB",  "Character Tabulation",
                "Horizontal Tab", "\\t", (char *)NULL},
    {"LF",  "NL",   "Line Feed", "\\n", "Newline",  (char *)NULL},
    {"VT",      "Line Tabulation",
                "Vertical Tab", "\\v", (char *)NULL},
    {"FF",      "Form Feed", "\\f",     (char *)NULL},
    {"CR",      "Carriage Return", "\\r",   (char *)NULL},
    {"SO", "LS1",   "Shift Out", "Locking Shift 1", (char *)NULL},
    {"SI", "LS0",   "Shift In", "Locking Shift 0",  (char *)NULL},
    {"DLE",     "Data Link Escape", (char *)NULL},
    {"DC1",     "Device Control 1", (char *)NULL},
    {"DC2",     "Device Control 2", (char *)NULL},
    {"DC3",     "Device Control 3", (char *)NULL},
    {"DC4",     "Device Control 4", (char *)NULL},
    {"NAK",     "Negative Acknowledge", (char *)NULL},
    {"SYN",     "Synchronous Idle", (char *)NULL},
    {"ETB",     "End of Transmission Block",    (char *)NULL},
    {"CAN",     "Cancel",       (char *)NULL},
    {"EM",      "End of Medium",    (char *)NULL},
    {"SUB",     "Substitute",       (char *)NULL},
    {"ESC",     "Escape",       (char *)NULL},
    {"FS",      "File Separator",   (char *)NULL},
    {"GS",      "Group Separator",  (char *)NULL},
    {"RS",      "Record Separator", (char *)NULL},
    {"US",      "Unit Separator",   (char *)NULL},
    {" ", "SP",     "Space", "Blank",   (char *)NULL},
    {"!",       "Exclamation Mark",
                "Bang", "Excl", "Wow", "Factorial", "Shriek",
                "Pling", "Smash", "Cuss", (char *)NULL},
    {"\"",      "Quotation Mark",
                "Double Quote", "Quote", "String Quote",
                "Dirk", "Literal Mark", "Double Glitch",
                "# See ' and ` for matching names.",
                (char *)NULL},
    {"#",       "Number Sign",
                "Pound", "Number", "Sharp", "Crunch", "Mesh",
                "Hex", "Hash", "Flash", "Grid", "Octothorpe",
                (char *)NULL},
    {"$",       "Currency Sign",
                "Dollar", "Buck", "Cash", "Ding",
                (char *)NULL},
    {"%",       "Percent Sign",
                "Mod", (char *)NULL},
    {"&",       "Ampersand",
                "Amper", "And", (char *)NULL},
    {"'",       "Apostrophe",
                "Single Quote", "Close Quote",  "Prime",
                "Tick", "Pop", "Spark", "Glitch",
                "# See ` and \" for matching names.",
                (char *)NULL},
    {"(",       "Left Parenthesis",
                "Open", "Open Paren",
                "Left Paren", "Wane", "Sad",
                "# See `)' for matching names.",
                (char *)NULL},
    {")",       "Right Parenthesis",
                "Close", "Close Paren",
                "Right Paren", "Wax", "Happy",
                "# See `(' for matching names.",
                 (char *)NULL},
    {"*",       "Asterisk",
                "Star", "Splat", "Aster", "Times", "Gear",
                "Dingle", "Bug", "Twinkle", "Glob",  
                (char *)NULL},
    {"+",       "Plus Sign",
                "Add", "Cross", (char *)NULL},
    {",",       "Comma",
                "Tail", (char *)NULL},
    {"-",       "Hyphen",
                "Dash", "Minus", "Worm", (char *)NULL}, 
    {".",       "Full Stop",
                "Dot", "Decimal Point", "Radix Point",
                "Point", "Period", "Spot", (char *)NULL},
    {"/",       "Solidus",
                "Slash", "Stroke", "Slant", "Diagonal",
                "Virgule", "Over", "Slat",
                "# See `\\' for matching names.",
                (char *)NULL},
    {"0",       "Digit Zero", (char *)NULL},
    {"1",       "Digit One", (char *)NULL},
    {"2",       "Digit Two", (char *)NULL},
    {"3",       "Digit Three", (char *)NULL},
    {"4",       "Digit Four", (char *)NULL},
    {"5",       "Digit Five", (char *)NULL},
    {"6",       "Digit Six", (char *)NULL},
    {"7",       "Digit Seven", (char *)NULL},
    {"8",       "Digit Eight", (char *)NULL},
    {"9",       "Digit Nine", (char *)NULL},
    {":",       "Colon",
                "Double-Dot", (char *)NULL},
    {";",       "Semicolon",
                "Semi", "Go-on", (char *)NULL},
    {"<",       "Less-than Sign",
                "Left Angle Bracket", "Read From", "In",
                "From", "Comesfrom", "Left Funnel",
                "Left Broket", "Crunch", "Suck",
                "# See `<' for matching names.",
                 (char *)NULL},
    {"=",       "Equals Sign",
                "Quadrathorp", "Gets", "Becomes", "Half-Mesh",
                (char *)NULL},
    {">",       "Greater-than sign",
                "Right Angle" , "Write To", "Into", "Toward",
                "Out", "To", "Gozinta", "Right Funnel",
                "Right Broket", "Zap", "Blow",
                "# See `>' for matching names.",
                 (char *)NULL},
    {"?",       "Question Mark",
                "Whatmark", "What", "Ques", (char *)NULL},
    {"@",       "Commercial At",
                "At", "Each", "Vortex", "Whorl", "Whirlpool",
                "Cyclone", "Snail", "Rose", (char *)NULL},
    {"A",       "Majuscule A", "Capital A", "Uppercase A",(char*)NULL},
    {"B",       "Majuscule B", "Capital B", "Uppercase B",(char*)NULL},
    {"C",       "Majuscule C", "Capital C", "Uppercase C",(char*)NULL},
    {"D",       "Majuscule D", "Capital D", "Uppercase D",(char*)NULL},
    {"E",       "Majuscule E", "Capital E", "Uppercase E",(char*)NULL},
    {"F",       "Majuscule F", "Capital F", "Uppercase F",(char*)NULL},
    {"G",       "Majuscule G", "Capital G", "Uppercase G",(char*)NULL},
    {"H",       "Majuscule H", "Capital H", "Uppercase H",(char*)NULL},
    {"I",       "Majuscule I", "Capital I", "Uppercase I",(char*)NULL},
    {"J",       "Majuscule J", "Capital J", "Uppercase J",(char*)NULL},
    {"K",       "Majuscule K", "Capital K", "Uppercase K",(char*)NULL},
    {"L",       "Majuscule L", "Capital L", "Uppercase L",(char*)NULL},
    {"M",       "Majuscule M", "Capital M", "Uppercase M",(char*)NULL},
    {"N",       "Majuscule N", "Capital N", "Uppercase N",(char*)NULL},
    {"O",       "Majuscule O", "Capital O", "Uppercase O",(char*)NULL},
    {"P",       "Majuscule P", "Capital P", "Uppercase P",(char*)NULL},
    {"Q",       "Majuscule Q", "Capital Q", "Uppercase Q",(char*)NULL},
    {"R",       "Majuscule R", "Capital R", "Uppercase R",(char*)NULL},
    {"S",       "Majuscule S", "Capital S", "Uppercase S",(char*)NULL},
    {"T",       "Majuscule T", "Capital T", "Uppercase T",(char*)NULL},
    {"U",       "Majuscule U", "Capital U", "Uppercase U",(char*)NULL},
    {"V",       "Majuscule V", "Capital V", "Uppercase V",(char*)NULL},
    {"W",       "Majuscule W", "Capital W", "Uppercase W",(char*)NULL},
    {"X",       "Majuscule X", "Capital X", "Uppercase X",(char*)NULL},
    {"Y",       "Majuscule Y", "Capital Y", "Uppercase Y",(char*)NULL},
    {"Z",       "Majuscule Z", "Capital Z", "Uppercase Z",(char*)NULL},
    {"[",       "Left Square Bracket",
                "Bracket", "Bra", "Square",
                "# See `]' for matching names.",
                 (char *)NULL},
    {"\\",      "Reversed Solidus",
                "Backslash", "Bash", "Backslant", "Backwhack",
                "Backslat", "Literal", "Escape",
                "# See `/' for matching names.",
                 (char *)NULL},
    {"]",       "Right Square Bracket",
                "Unbracket", "Ket", "Unsquare",
                "# See `]' for matching names.",
                 (char *)NULL},
    {"^",       "Circumflex Accent",
                "Circumflex", "Caret", "Uparrow", "Hat",
                "Control", "Boink", "Chevron", "Hiccup",
                "Sharkfin", "Fang", (char*)NULL},
    {"_",       "Low Line",
                "Underscore", "Underline", "Underbar",
                "Under", "Score", "Backarrow", "Flatworm", 
    "# `Backarrow' refers to this character's graphic in 1963 ASCII.",
                (char*)NULL},
    {"`",       "Grave Accent",
                "Grave", "Backquote", "Left Quote",
                "Open Quote", "Backprime", "Unapostrophe",
                "Backspark", "Birk", "Blugle", "Back Tick",
                "Push",
                "# See ' and \" for matching names.",
                (char *)NULL},
    {"a",       "Miniscule a", "Small a", "Lowercase a",(char*)NULL},
    {"b",       "Miniscule b", "Small b", "Lowercase b",(char*)NULL},
    {"c",       "Miniscule c", "Small c", "Lowercase c",(char*)NULL},
    {"d",       "Miniscule d", "Small d", "Lowercase d",(char*)NULL},
    {"e",       "Miniscule e", "Small e", "Lowercase e",(char*)NULL},
    {"f",       "Miniscule f", "Small f", "Lowercase f",(char*)NULL},
    {"g",       "Miniscule g", "Small g", "Lowercase g",(char*)NULL},
    {"h",       "Miniscule h", "Small h", "Lowercase h",(char*)NULL},
    {"i",       "Miniscule i", "Small i", "Lowercase i",(char*)NULL},
    {"j",       "Miniscule j", "Small j", "Lowercase j",(char*)NULL},
    {"k",       "Miniscule k", "Small k", "Lowercase k",(char*)NULL},
    {"l",       "Miniscule l", "Small l", "Lowercase l",(char*)NULL},
    {"m",       "Miniscule m", "Small m", "Lowercase m",(char*)NULL},
    {"n",       "Miniscule n", "Small n", "Lowercase n",(char*)NULL},
    {"o",       "Miniscule o", "Small o", "Lowercase o",(char*)NULL},
    {"p",       "Miniscule p", "Small p", "Lowercase p",(char*)NULL},
    {"q",       "Miniscule q", "Small q", "Lowercase q",(char*)NULL},
    {"r",       "Miniscule r", "Small r", "Lowercase r",(char*)NULL},
    {"s",       "Miniscule s", "Small s", "Lowercase s",(char*)NULL},
    {"t",       "Miniscule t", "Small t", "Lowercase t",(char*)NULL},
    {"u",       "Miniscule u", "Small u", "Lowercase u",(char*)NULL},
    {"v",       "Miniscule v", "Small v", "Lowercase v",(char*)NULL},
    {"w",       "Miniscule w", "Small w", "Lowercase w",(char*)NULL},
    {"x",       "Miniscule x", "Small x", "Lowercase x",(char*)NULL},
    {"y",       "Miniscule y", "Small y", "Lowercase y",(char*)NULL},
    {"z",       "Miniscule z", "Small z", "Lowercase z",(char*)NULL},
    {"{",       "Left Curly Bracket",
                "Left Brace", "Brace", "Open Brace",
                "Curly", "Leftit", "Embrace",
                "# See `}' for matching names.",
                 (char *)NULL},
    {"|",       "Vertical Line",
                "Pipe", "Bar", "Or", "V-Bar", "Spike",
                "Gozinta", "Thru", (char *)NULL},
    {"}",       "Right Curly Bracket",
                "Right Brace", "Unbrace", "Close Brace",
                "Uncurly", "Rytit", "Bracelet",
                "# See `{' for matching names.",
                 (char *)NULL},
    {"~",       "Overline",
                "Tilde", "Swung Dash", "Squiggle", "Approx",
                "Wiggle", "Twiddle", "Enyay", (char *)NULL},
    {"DEL",     "Delete", (char *)NULL},
};
/******************************************************************/
static int atob(str)
/* ASCII-to-binary conversion */
char    *str;
{
    int val;

    for (val = 0; *str; str++)
    {
    val *= 2;

    if (*str == '1')
        val++;
        else if (*str != '0')
        return(-1);
    }
    return(val);
}

/*********************************************************/
void 
showHelp(FILE *out, char *progname) 
{
  fprintf(out,"Usage: %s [-dxohv] [-t] [char-alias...]\n", progname); 
#define P(s)    puts(s);
//#include "splashscreen.h"
#undef P

  exit(0);
}

/*********************************************************/
void 
process_options(int argc, char *argv[], char * opt_string) 
{
    int op;

    while( (op=getopt(argc, argv, opt_string)) != -1) {

    switch (op) {
    case 't':
        terse = 1; 
        break;
    case 's':
        terse=1; 
        line=1; 
        break;
    case 'd':
            print_table(decimal);
            exit(0);
    case 'x':
            print_table(hex);
            exit(0);
    case 'o':
            print_table(octal);
            exit(0);
    case '?':
    case 'h':
        help = 1;
        break;
    case 'v':
        printf("ascii %2.1f\n",REVISION); exit(0) ;
        break;
    default :
        help = 1;
        break;
        } /*switch*/
    }/*while*/
}

/******************************************************************/
static char *btoa(val)
/* binary-to-ASCII conversion */
{
#define BITSPERCHAR 8
    char    *rp;
    static char rep[BITSPERCHAR + 1];

    /* write out external representation at least one char */
    *(rp = rep + BITSPERCHAR) = '\0';
    do {
       *--rp = (val & 1) + '0'; /* Is '1' == '0' + 1 in EBCDIC? */
       val /= 2;
    } while
    (val && rp > rep);

#ifndef SHORT_BINARY_REPRESENTATION
    while (rp > rep)
       *--rp = '0';
#endif
 
    return(rp);
}

/******************************************************************/
static void speak(ch)
/* list all the names for a given character */
int ch;
{
    char    **ptr = &cnames[ch][0];

    if (terse) {
        (void) printf("%d/%d   %d   0x%02X   0o%o   %s\n", 
              ch / 16, ch % 16, ch, ch, ch, btoa(ch));
        return;
    }

    (void) printf(
    "ASCII %d/%d is decimal %03d, hex %02x, octal %03o, bits %s: ",
    ch / 16, ch % 16, ch, ch, ch, btoa(ch));

    /* display high-half characters */
    if (ch & 0x80)
    {
    ch &=~ 0x80;
    if (ch == 0x7f)
        (void) printf("meta-^?\n");
    else if (isprint(ch))
        (void) printf("meta-%c\n", ch);
    else
        (void) printf("meta-^%c\n", '@' + (ch & 0x1f));
    return;
    }

    if (isprint(ch))
    (void) printf("prints as `%s'\n", *ptr++);
    else if (iscntrl(ch) || ch == 0x7F)
    {
    if (ch == 0x7f)
        (void) printf("called ^?");
    else
        (void) printf("called ^%c", '@' + (ch & 0x1f));
    for (; strlen(*ptr) < 4 && isupper(**ptr); ptr++)
        (void) printf(", %s", *ptr);
    (void) putchar('\n');
    }

    (void) printf("Official name: %s\n", *ptr++);

    if (*ptr)
    {
    char    *commentary = (char *)NULL;

    if (**ptr == '\\')
    {
        (void) printf("C escape: '%s'\n", *ptr);
        ptr++;
    }

    (void) printf("Other names: ");
    for (; *ptr; ptr++)
        if (**ptr == '#')
        commentary = *ptr;
        else
        (void) printf("%s%s ", *ptr, 
                  (ptr[1] && *ptr[1] != '#') ? "," : "");
    (void) putchar('\n');
    if (commentary)
        (void) printf("Note: %s\n", commentary+2);
    }

    (void) putchar('\n');
}
/******************************************************************/
static void ascii(str)
char *str;
{
    int ch, hi, lo;
    char **ptr;
    int len = strlen(str);

    /* interpret single characters as themselves */
    if (len == 1)
       { speak(str[0]); return; }

    /* process multiple letters */ 
    if (line == 1) {    
    for (ch = 0; ch < len; ch ++) {
        speak(str[ch]);
    }
    return;
    }

    /* interpret ^-escapes as control-character notation */
    if (strcmp(str, "^?") == 0)
         { speak(0x7F); return; } 
    else if (str[0] == '^' && len == 2)
     { speak(str[1] & 0x1f); return; }

    /* interpret C-style backslash escapes */
    if (*str == '\\' &&  len == 2 && strchr("abfnrtv", str[1]))
    for (ch = 7; ch < 14; ch++)
        for (ptr = &cnames[ch][1]; *ptr; ptr++)
        if (**ptr == '\\' && strcmp(str, *ptr) == 0)
            { speak(ch); return; }

    /* interpret 2 and 3-character ASCII control mnemonics */
    if (len == 2 || len == 3)
    {
    /* first check for standard mnemonics */
    if (stricmp(str, "DEL") == 0)
        { speak(0x7f); return; }
    if (stricmp(str, "BL") == 0)
        { speak(' '); return; }
    else if (isalpha(str[0]))
        for (ch = 0; ch <= 32; ch++)
        if (!stricmp(str,cnames[ch][0]) || !strcmp(str,cnames[ch][1]))
            { speak(ch); return; }
    }

    /* OK, now try to interpret the string as a numeric */
    if (len > 1 && len < 9)
    {
    int hval, dval, oval, bval, spoken = 0;

    dval = oval = hval = bval = -1;

    /* if it's all numeric it could be in one of three bases */
    if (len <= 2 && strspn(str,"0123456789ABCDEFabcdef") == len)
        (void) sscanf(str, "%x", &hval);
    if (len <= 3 && strspn(str, "0123456789") == len)
        (void) sscanf(str, "%d", &dval);
    if (len <= 3 && strspn(str, "01234567") == len)
        (void) sscanf(str, "%o", &oval);
    if (len <= 9 && strspn(str, "01") == len)
        bval = atob(str);

    /* accept 0xnn, \xnn, xnn and nnh forms for hex */
    if (hval == -1)
        if ((str[0]=='0'||str[0]=='\\') && tolower(str[1]) == 'x')
        (void) sscanf(str + 2, "%x", &hval);
        else if (tolower(str[0]) == 'x')
        (void) sscanf(str + 1, "%x", &hval);
        else if ((len >= 2) && (len <= 3) &&
            (strspn(str,"0123456789ABCDEFabcdef") == (len-1)) &&
            (tolower(str[len - 1]) == 'h'))
        (void) sscanf(str, "%x", &hval);

    /* accept 0onn, \onnn, onnn and \nnn forms for octal */
    if (oval == -1)
        if ((str[0]=='0'||str[0]=='\\') && tolower(str[1]) == 'o')
        (void) sscanf(str + 2, "%o", &oval);
        else if (tolower(str[0]) == 'o')
        (void) sscanf(str + 1, "%o", &oval);
        else if (str[0] == '\\' && strspn(str + 1, "0123456789") == len - 1)
        (void) sscanf(str + 1, "%o", &oval);

    /* accept 0dnnn, \dnnn and dnnn forms for decimal */
    if (dval == -1)
        if ((str[0]=='0'||str[0]=='\\') && tolower(str[1]) == 'd')
        (void) sscanf(str + 2, "%d", &dval);
        else if (tolower(str[0]) == 'd')
        (void) sscanf(str + 1, "%d", &dval);

    /* accept 0bnnn, \bnnn and bnnn forms for binary */
    if (bval == -1)
        if ((str[0]=='0'||str[0]=='\\') && tolower(str[1]) == 'b')
        bval = atob(str + 2);
        else if (tolower(str[0]) == 'b')
        bval = atob(str + 1);

    /* OK, now output all values */
    if (hval > -1 && hval < 256)
        speak(hval & 0xff);
    if (dval > -1 && dval < 256)
        speak(dval & 0xff);
    if (oval > -1 && oval < 256)
        speak(oval & 0xff);
    if (bval > -1 && bval < 256)
        speak(bval & 0xff);
    if (!(hval==-1 && dval==-1 && oval==-1 && bval==-1))
    {
        if (hval > -1 || dval > -1 || oval > -1 || bval > -1)
        return;
        if (hval < 256 || dval < 256 || oval < 256 || bval < 256)
        return;
    }
    }

    if (sscanf(str, "%d/%d", &hi, &lo) == 2)    /* code table reference?  */
    { speak(hi*16 + lo); return; }
    else if (len > 1 && isalpha(str[0]))    /* try to match long names */
    {
    char    canbuf[BUFSIZ], *ep;
    int i;

    /* map dashes and other junk to spaces */
    for (i = 0; i <= len; i++)
        if (str[i] == '-' || isspace(str[i]))
        canbuf[i] = ' ';
        else
        canbuf[i] = str[i];

    /* strip `sign' or `Sign' suffix */
    ep = canbuf + strlen(canbuf) - 4;
    if (!strcmp(ep, "sign") || !strcmp(ep, "Sign"))
        *ep = '\0';

    /* remove any trailing whitespace */
    while (canbuf[strlen(canbuf) - 1] == ' ')
        canbuf[strlen(canbuf) - 1] = '\0';

    /* look through all long names for a match */
    for (ch = 0; ch < 128; ch++)
        for (ptr = &cnames[ch][1]; *ptr; ptr++)
        if (!stricmp(*ptr, canbuf))
            speak(ch);
    } /* outer if */
}
/******************************************************************/
void
print_table(unsigned short delivery)
{
   static unsigned short i, j, len;
   char   separator[]= "   "; 
   char   *tail     = separator + 3 ;
   char   *space; 
   char   *name ;

   for (i=0;i<16; i++) {
           for (j=0; j<8; j++) {
                  name= *cnames[i+(j*16)];
                  len = strlen(name);
                  space = tail - (len % 3) ; 
                  switch (delivery) {
                      case decimal:  printf("%5d %1s%1s",i+(j*16),name,space);
                                     break;
                      case octal  :  printf("%5o %1s%1s",i+(j*16),name,space);
                                     break;
                      case hex    :  printf("%5X %1s%1s",i+(j*16),name,space);
                                     break;
                  }
           }
           printf("\n");
   }
       
}
/*----------------------------------------- M A I N --------------*/
int main(argc, argv)
int argc;
char **argv;
{
    char      *optstring="tshvxod" ;


    process_options(argc, argv, optstring) ;

    if (help || argc == optind)
    showHelp(stdout, argv[0]);
    else 
    while (optind < argc)       
        ascii(argv[optind++]);
    exit(0);
}
/******************************************************************/
/* ascii.c ends here */

