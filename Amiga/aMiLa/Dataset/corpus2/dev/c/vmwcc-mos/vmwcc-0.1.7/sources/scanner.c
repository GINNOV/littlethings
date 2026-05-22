/* vmwcc Scanner by Vince Weaver                  */
/* Originally based off of:                       */
/*  C Subset Scanner  9-17-03  Martin Burtscher   */
/*  As far as I know completely rewritten by vmw5 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "scanner.h"

#include "node.h"
#include "type.h"
#include "block.h"

#include "enums.h"
#include "globals.h"

static int ch;
static int line=0;
static FILE *source;
static int done_scanning=0;

char vmwString[BUFSIZ];

    /* Print out an error and exit */
    /* If still scanning/parsing, try to print context for the error */
void vmwError(char *message) {

   int temp_line=1;
   int chars_until_error=0,count=0;
   long position1,position2;
   int temp_char;
   
   if ((done_scanning) || (line==0)) {
      printf("ERROR! %s\n",message);
   }
   
   else {
     printf("ERROR! %s at line %i\n",message,line);
      
     position1=ftell(source);
      
     rewind(source);
     
     while(temp_line<line) {
	 while(fgetc(source)!='\n') /*intentionaly left blank*/;
         temp_line++;
     }
       
     while( (temp_char=fgetc(source)) !='\n') {
        if (temp_char!='\t') putchar(temp_char);
	else putchar(' ');
	
	position2=ftell(source);
        if (position1==position2) chars_until_error=count-1;
	count++;
     }
     printf("\n");
     for(count=0;count<chars_until_error;count++) putchar('-');
     printf("^\n");
   }   
   exit(1);
}

    /* Grab an identifier */
static void grabIdentifier(void) {
   
    int i=0;
   
       /* Indentifiers can be alphabetic, numerical, or with underscores */
    while ( ((ch>='A') && (ch<='Z')) ||
	    ((ch>='a') && (ch<='z')) ||
            ((ch>='0') && (ch<='9')) ||
	    (ch=='_') ) { 
       
       if (i <vmwIdlen) vmwId[i]=ch;
       i++;
       ch=getc(source);
    }
    if (i>=vmwIdlen) vmwError("Identifier too long!");
       /* Null-terminate the identifier */
    vmwId[i]=0;
}


   /* Grab a number                       */
   /* Leading 0 means octal, 0x means hex */
static void grabNumber(void) {
   
    int radix=0;
    int old_value=0;
   
    vmwVal=0;
   
    if (ch=='0') {
       ch=getc(source);
       if (ch=='x') {
	  radix=16;
	  ch=getc(source);
       }
       
       else radix=8;
    }
    else {
       radix=10;
    }
   
    while ( ((ch>='0') && (ch<='9')) ||  (ch=='.') ||
	    (( (ch|0x20)>='a') && ( (ch|0x20)<='z')) ) {
       
       if (ch=='.') {
	  vmwError("Floating point constants not supported.\n");
       }
       
       if (radix==8) {
	  if (ch>'7') vmwError("Invalid Octal Constant!");
	  vmwVal=vmwVal*8+(ch-'0');
       }
       
       if (radix==10) {
	  if (ch>'9') vmwError("Invalid Decimal Constant!");
	  vmwVal=vmwVal*10+(ch-'0');
       }
       
       if (radix==16) {
          if (ch>'9') {
	     /* Make lowercase */
	     ch|=0x20;
	     vmwVal=vmwVal*16+10+(ch-'a');
	  }
	  else {
	     vmwVal=vmwVal*16+(ch-'0');
	  }
       }
       if (vmwVal<old_value) {
	  vmwError("Constant too big!");
       }	    
       old_value=vmwVal;
       ch=getc(source);
    }
}

   /* Grab a String */
static void grabString(void) {
   int offset=0;
  
   while(ch=='\"') {
   ch=getc(source);
   while ((ch!='\"') && (ch!=EOF)) {
      vmwString[offset]=ch;
      offset++;
      if (offset>BUFSIZ) vmwError("String too long");
      ch=getc(source);
   }
   ch=getc(source);
   }
}


   /* Skip a standard C  / * ... * / comment */
static void skipComment(void) {
   
    ch=getc(source);
  
    do {
          /* Keep moving from the chars until a * or EOF */
       while( (ch!='*') && (ch!=EOF) ) {
	     /* If we hit a line, add it toward the count */
          if (ch=='\n') line++;
          ch=getc(source);
       }
       ch=getc(source);
    } while ( (ch!='/') && (ch!=EOF));
    
    ch=getc(source);
}

   /* Skip until end of line (useful for // type comments */
static void skipTillEndOfLine(void) {

    while ((ch!='\n') && (ch!=EOF)) {
       ch = getc(source);
    }
}


int vmwGetChar(void) {
   
   int old_ch;
   
   old_ch=ch;
   
   ch=getc(source);
   
   return old_ch;
}

   

   /* get a token from the source file */
int vmwGetToken(void) {
   
    int sym=-1;

       /* Skip whitespace                                   */
       /* The "<=' '" hack is a burtscher hack to treat all */
       /* lower ascii as whitespace                         */
    while( (ch!=EOF) && (ch<=' ') ) {
       if (ch=='\n') line++;
       ch=getc(source);
    }
   
    switch (ch) {
    
          /* End of File */
       case EOF: sym=vmwTeof; done_scanning=1; break;
       
          /* Unambiguous Math Routines */
       case '+': sym=vmwTplus;  
                 ch=getc(source);
                 if (ch=='+') { sym=vmwTplusplus; ch=getc(source);}
                 else if (ch=='=') { sym=vmwTplusequal; ch=getc(source);}
                 break;
       case '-': sym=vmwTminus; 
                 ch=getc(source); 
                 if (ch=='-') { sym=vmwTminusminus; ch=getc(source);}
                 else if (ch=='=') { sym=vmwTminusequal; ch=getc(source);}
                 else if (ch=='>') { sym=vmwTarrow; ch=getc(source);}
                 break;       
       case '*': sym=vmwTtimes; 
                 ch=getc(source); 
                 if (ch=='=') { sym=vmwTtimesequal; ch=getc(source);}
                 break;
       case '%': sym=vmwTmod;   
                 ch=getc(source); 
                 if (ch=='=') { sym=vmwTmodequal; ch=getc(source);}
                 break;
    
          /* '/' can be divide _or_ part of a comment */
       case '/': sym=vmwTdiv;
                 ch=getc(source);
                 if (ch=='/') {
                    skipTillEndOfLine();
                    sym=vmwGetToken();
                 } else if (ch=='*') {
                    skipComment();
                    sym=vmwGetToken();
                 }
                 else if (ch=='=') {
	            sym=vmwTdivequal;
	            ch=getc(source);
	         }
                 break;
         
          /* Assignment or equality test */
       case '=': sym=vmwTbecomes;
                 ch=getc(source);
                 if (ch=='=') {
                    sym=vmwTeql;
                    ch=getc(source);
                 }
                 break;

          /* Boolean Routines */
       case '&': sym=vmwTbitand;  
                 ch=getc(source);
                 if (ch=='&') { sym=vmwTbooland; ch=getc(source);}
                 else if (ch=='=') { sym=vmwTbitandequal; ch=getc(source);}
                 break;
       case '|': sym=vmwTbitor;  
                 ch=getc(source);
                 if (ch=='|') { sym=vmwTboolor; ch=getc(source);}
                 else if (ch=='=') { sym=vmwTbitorequal; ch=getc(source);}
                 break;       
       
       case '^': sym=vmwTbitxor;  
                 ch=getc(source);
                 if (ch=='=') { sym=vmwTbitxorequal; ch=getc(source);}
                 break;
       
       case '~': sym=vmwTbitnot;  
                 ch=getc(source);
                 if (ch=='=') { sym=vmwTbitnotequal; ch=getc(source);}
                 break;       
       
       
	  /* We don't have a preprocessor so treat these as comments */
       case '#': skipTillEndOfLine(); sym = vmwGetToken(); break;
       
          /* Punctuation */
       case '.': sym=vmwTperiod; 
                 ch=getc(source); 
                 break;
       case ',': sym=vmwTcomma; 
                 ch=getc(source); 
                 break;
       case ';': sym=vmwTsemicolon; 
                 ch=getc(source); 
                 break;
       case '!': sym=vmwTboolnot;
                 ch=getc(source);
                 if (ch=='=') { sym=vmwTneq; ch=getc(source); }
                 break;
       case '(': sym=vmwTlparen; ch=getc(source); break;
       case '[': sym=vmwTlbrak;  ch=getc(source); break;
       case '{': sym=vmwTlbrace; ch=getc(source); break;
       case ')': sym=vmwTrparen; ch=getc(source); break;
       case ']': sym=vmwTrbrak;  ch=getc(source); break;
       case '}': sym=vmwTrbrace; ch=getc(source); break;
       case '?': sym=vmwTquestion; ch=getc(source); break;       
       case '\'' : sym=vmwTsinglequote; ch=getc(source); break;
       case '\"' : sym=vmwTstring; 
                   grabString();
                   break;

          /* Line continuation Character */
       case '\\' : ch=getc(source);
                   if (ch!='\n') vmwError("Backslash must be followed by newline!");
                   ch=getc(source);
                   break;
       
       
          /* Inequalities */
       case '<': sym=vmwTlss;
                 ch=getc(source);
                 if (ch=='=') { sym=vmwTleq; ch=getc(source); }
                 if (ch=='<') {
		    sym=vmwTlshift;
		    ch=getc(source);
		    if (ch=='=') {
		       sym=vmwTlshiftequal;
		       ch=getc(source);
		    }
		 }	    
                 break;
       case '>': sym=vmwTgtr;
                 ch=getc(source);
                 if (ch=='=') { sym=vmwTgeq; ch=getc(source); }
                 if (ch=='>') {
		    sym=vmwTrshift;
		    ch=getc(source);
		    if (ch=='=') {
		       sym=vmwTrshiftequal;
		       ch=getc(source);
		    }
		 }	    
                 break;

          /* Handle a number */
       case '0': case '1': case '2': case '3': case '4':
       case '5': case '6': case '7': case '8': case '9':
                 sym = vmwTnumber;
                 grabNumber();
                 break;

       case 'c': sym=vmwTident; 
                 grabIdentifier(); 
                 if (!strncmp(vmwId,"case",vmwIdlen)) sym=vmwTcase;
                 if (!strncmp(vmwId,"char",vmwIdlen)) sym=vmwTchar;
                 if (!strncmp(vmwId,"const",vmwIdlen)) sym=vmwTconst; 
                 break;
       case 'd': sym=vmwTident; 
                 grabIdentifier(); 
                 if (!strncmp(vmwId,"default",vmwIdlen)) sym=vmwTdefault;
                 if (!strncmp(vmwId,"double",vmwIdlen)) sym=vmwTdouble;
                 if (!strncmp(vmwId,"do",vmwIdlen)) sym=vmwTdo;
                 break;       
       case 'e': sym=vmwTident; 
                 grabIdentifier(); 
                 if (!strncmp(vmwId,"else",vmwIdlen)) sym=vmwTelse; 
                 if (!strncmp(vmwId,"enum",vmwIdlen)) sym=vmwTenum; 
                 break;
       case 'f': sym=vmwTident; 
                 grabIdentifier(); 
                 if (!strncmp(vmwId,"float",vmwIdlen)) sym=vmwTfloat;
                 if (!strncmp(vmwId,"for",vmwIdlen)) sym=vmwTfor; 
                 break;
       case 'g': sym=vmwTident; 
                 grabIdentifier(); 
                 if (!strncmp(vmwId,"goto",vmwIdlen)) sym=vmwTgoto; 
                 break;       
       case 'i': sym=vmwTident; 
                 grabIdentifier(); 
                 if (!strncmp(vmwId,"if",vmwIdlen)) sym=vmwTif; 
                 if (!strncmp(vmwId,"int",vmwIdlen)) sym=vmwTint;
                 break;
       case 'l': sym=vmwTident; 
                 grabIdentifier(); 
                 if (!strncmp(vmwId,"long",vmwIdlen)) sym=vmwTlong;
                 break;       
       case 'r': sym=vmwTident; 
                 grabIdentifier(); 
                 if (!strncmp(vmwId,"register",vmwIdlen)) sym=vmwTregister; 
                 if (!strncmp(vmwId,"return",vmwIdlen)) sym=vmwTreturn;
                 break;       
       case 's': sym=vmwTident; 
                 grabIdentifier(); 
                 if (!strncmp(vmwId,"short",vmwIdlen)) sym=vmwTshort; 
                 if (!strncmp(vmwId,"sizeof",vmwIdlen)) sym=vmwTsizeof;        
                 if (!strncmp(vmwId,"struct",vmwIdlen)) sym=vmwTstruct; 
                 if (!strncmp(vmwId,"switch",vmwIdlen)) sym=vmwTswitch; 
                 break;
       case 'u': sym=vmwTident; 
                 grabIdentifier(); 
                 if (!strncmp(vmwId,"unsigned",vmwIdlen)) sym=vmwTunsigned; 
                 break;
       case 'v': sym=vmwTident; 
                 grabIdentifier(); 
                 if (!strncmp(vmwId,"void",vmwIdlen)) sym=vmwTvoid; 
                 break;
       case 'w': sym=vmwTident; 
                 grabIdentifier(); 
                 if (!strncmp(vmwId,"while",vmwIdlen)) sym=vmwTwhile; 
                 break;

           /* If starts with these letters, definitely an identifier */
       case 'a': case 'b': case 'h': case 'j':
       case 'k': case 'm': case 'n': case 'o': case 'p': case 'q':
       case 't': case 'x': case 'y': case 'z': case '_':
       case 'A': case 'B': case 'C': case 'D': case 'E': case 'F': case 'G':
       case 'H': case 'I': case 'J': case 'K': case 'L': case 'M': case 'N':
       case 'O': case 'P': case 'Q': case 'R': case 'S': case 'T': case 'U':
       case 'V': case 'W': case 'X': case 'Y': case 'Z':
                 sym = vmwTident;
                 grabIdentifier();
                 break;
       default: vmwError("Invalid symbol encountered");
    }
  
    return sym;
}


   /* Open the source file */
void vmwScannerInit(char *filename) {
   
    source=fopen(filename,"r");
    if (source==NULL) {
       printf("Could not open file %s! ",filename);
       vmwError("Problem opening file!");
    }
   
    line=1;
    ch=getc(source);
}
