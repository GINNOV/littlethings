#define banner "\nThis is c2cweb Version 1.4  (c) 1994 by Werner Lemberg\n\n" \

#define FALSE 0
#define TRUE 1
#define DONE 2
#define WAIT 3 \

#define DIR_LENGTH 80
#define TITLE_LENGTH 100
#define PATH_SEPARATOR '/' \

#define FILE_NAME_LENGTH 80 \

#define BUFFER_LENGTH 500 \

#define xisspace(c) (isspace(c) &&((unsigned char) c<0200) )  \

/*4:*/
#line 114 "c2cweb.w"

/*5:*/
#line 194 "c2cweb.w"

#include <ctype.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/*:5*/
#line 115 "c2cweb.w"
;
/*9:*/
#line 326 "c2cweb.w"

void open_files(char*);

/*:9*//*12:*/
#line 413 "c2cweb.w"

void handle_input(void);

/*:12*//*27:*/
#line 1056 "c2cweb.w"

void usage(void);

/*:27*//*29:*/
#line 1080 "c2cweb.w"

void modify_filename(char*);

/*:29*//*32:*/
#line 1117 "c2cweb.w"

char*get_line(void);

/*:32*//*35:*/
#line 1153 "c2cweb.w"

char*protect_underlines(char*);

/*:35*//*37:*/
#line 1177 "c2cweb.w"

#ifndef __EMX__
char*_getname(char*);
#endif

/*:37*/
#line 116 "c2cweb.w"
;
/*6:*/
#line 229 "c2cweb.w"

int tab_length= 4;
int verbatim= FALSE;
int user_linefeed= FALSE;
int one_side= FALSE;
char outdir[DIR_LENGTH+1];
char title[TITLE_LENGTH+1];

#ifdef __EMX__
char optchar[]= "-/";
char pathsepchar[]= "\\/";
#else
char optchar[]= "-";
char pathsepchar[]= "/";
#endif

/*:6*//*8:*/
#line 322 "c2cweb.w"

FILE*in,*out;

/*:8*//*13:*/
#line 419 "c2cweb.w"

char buffer[BUFFER_LENGTH+1];

/*:13*//*31:*/
#line 1112 "c2cweb.w"

int line_number= 0;
int column;

/*:31*//*34:*/
#line 1149 "c2cweb.w"

char tempbuf[2*FILE_NAME_LENGTH+1];

/*:34*/
#line 117 "c2cweb.w"
;

void main(argc,argv)
int argc;
char*argv[];

{int i;
char buffer[DIR_LENGTH+FILE_NAME_LENGTH+1];
char*p,*q;


printf(banner);

#ifdef __EMX__
_response(&argc,&argv);
_wildcard(&argc,&argv);
#endif

/*7:*/
#line 246 "c2cweb.w"

{char c;
int i;


outdir[0]= '\0';
#ifdef __EMX__
optswchar= optchar;
#endif

strcpy(title,"c2cweb output");

while((c= getopt(argc,argv,"b:lo:t:v1"))!=EOF)
{switch(c)
{case'b':
if(strchr(optchar,optarg[0]))

usage();

if(strlen(optarg)>=TITLE_LENGTH)
fprintf(stderr,
"\nTitle too long. Will use \"c2cweb output\".\n");
else
strcpy(title,optarg);
break;
case'l':
user_linefeed= TRUE;
break;
case'o':
if(strchr(optchar,optarg[0]))
usage();

if((i= strlen(optarg))>=DIR_LENGTH)
fprintf(stderr,
"\nOutput directory name too long. Will be ignored.\n");
else
{strcpy(outdir,optarg);
if(!strchr(pathsepchar,outdir[i-1]))

{outdir[i]= PATH_SEPARATOR;
outdir[i+1]= '\0';
}
}
break;
case't':
if(strchr(optchar,optarg[0]))
usage();

tab_length= atoi(optarg);
if(tab_length==0||tab_length>8)
tab_length= 4;
break;
case'v':
verbatim= TRUE;
break;
case'1':
one_side= TRUE;
break;
default:
usage();
break;
}
}
}

/*:7*/
#line 135 "c2cweb.w"
;

if(optind==argc)
usage();

for(i= optind;i<argc-1;i++)
{printf("  processing %s\n",argv[i]);

open_files(argv[i]);
q= protect_underlines(_getname(argv[i]));
if((p= strrchr(q,'.'))!=NULL)


fprintf(out,
"@*{%s\\ZZZ{\\setbox0=\\hbox{%s}\\hskip-\\wd0}}.\n"
"\\ind=2\n\n",q,p);
else
fprintf(out,"@*{%s}.\n"
"\\ind=2\n\n",q);

handle_input();
fclose(in);
fclose(out);
}

printf("  processing %s\n",argv[i]);

open_files(argv[i]);
/*11:*/
#line 373 "c2cweb.w"

fprintf(out,
"\\font\\symb=cmsy10\n"
"\\font\\math=cmmi10\n"
"\\def\\ob"
"{\\parskip=0pt\\parindent=0pt%%\n"
"\\let\\\\=\\BS\\let\\{=\\LB\\let\\}=\\RB\\let\\~=\\TL%%\n"
"\\let\\ =\\SP\\let\\_=\\UL\\let\\&=\\AM\\let\\^=\\CF%%\n"
"\\obeyspaces\\frenchspacing\\tt}\n"
"\n"
"\\def\\e{\\hfill\\break\\hbox{}}\n"
"\\def\\{{\\relax\\ifmmode\\lbrace\\else$\\lbrace$\\fi}\n"
"\\def\\}{\\relax\\ifmmode\\rbrace\\else$\\rbrace$\\fi}\n"
"\\def\\takenone#1{\\hskip-0.1em}\n"
"\\let\\ZZZ=\\relax\n"
"\n"
"%s"
"\n"
"\\pageno=\\contentspagenumber \\advance\\pageno by 1\n"
"\\let\\maybe=\\iftrue\n"
"\n"
"\\def\\title{%s}\n"
"\n"
"@i compiler.w\n"
"\n",one_side?"\\let\\lheader=\\rheader\n":"",title);

for(i= optind;i<argc-1;i++)
{strcpy(buffer,argv[i]);
modify_filename(buffer);

fprintf(out,"@i %s\n",_getname(buffer));
}

fputc('\n',out);


/*:11*/
#line 163 "c2cweb.w"
;
q= protect_underlines(_getname(argv[i]));
if((p= strrchr(q,'.'))!=NULL)
fprintf(out,
"@*{%s\\ZZZ{\\setbox0=\\hbox{%s}\\hskip-\\wd0}}.\n"
"\\ind=2\n\n",q,p);
else
fprintf(out,"@*{%s}.\n"
"\\ind=2\n\n",q);

handle_input();
/*26:*/
#line 1049 "c2cweb.w"

fprintf(out,
"\n"
"@*Index.\n"
"\\let\\ZZZ=\\takenone\n");

/*:26*/
#line 174 "c2cweb.w"
;

strcpy(buffer,argv[argc-1]);
modify_filename(buffer);

printf(
"\n You must now call CWEAVE with %s%s\n"
" as the argument to get a TeX output",outdir,_getname(buffer));
if(optind<argc-1)
printf(" of all processed files");
printf("\n");

fclose(in);
fclose(out);
}

/*:4*//*10:*/
#line 330 "c2cweb.w"

void open_files(filename)
char*filename;
{char buffer[DIR_LENGTH+FILE_NAME_LENGTH+1];


if(strlen(filename)>FILE_NAME_LENGTH-2)
{fprintf(stderr,"\n  File name too long.\n");
exit(-1);
}

if((in= fopen(filename,"rt"))==NULL)
{fprintf(stderr,"\n  Can't open input file %s\n",filename);
exit(-1);
}

strcpy(buffer,outdir);
strcat(buffer,filename);
modify_filename(buffer);

if((out= fopen(buffer,"wt"))==NULL)
{fprintf(stderr,"\n  Can't open output file %s\n",buffer);
exit(-1);
}
}


/*:10*//*14:*/
#line 425 "c2cweb.w"

void handle_input(void)
{char*buf_p;
char ch;

int any_input= FALSE;

int brace_count= 0;
int blank_count= 0;

int in_comment= FALSE;
int in_C= FALSE;
int in_string= FALSE;
int short_comment= FALSE;
int leading_blanks= TRUE;
int double_linefeed= FALSE;
int linefeed_comment= FALSE;

int comment_slash= FALSE;
int comment_star= FALSE;
int escape_state= FALSE;

int before_TeX_text= FALSE;

int function_blocks= FALSE;


line_number= 0;

while(get_line())
{buf_p= buffer;

do
{ch= *buf_p;

/*15:*/
#line 539 "c2cweb.w"

if(buf_p==buffer)
{if(!(in_comment||in_string))
{if(!strncmp(buf_p,"/""*@@*""/",6))
{in_C= FALSE;
before_TeX_text= TRUE;
function_blocks= WAIT;
brace_count= 0;

if(any_input)
fputs("\n@\n"
"\\ind=2\n\n",out);

any_input= FALSE;
*(buf_p--)= '\n';

goto end;
}
else if(!strncmp(buf_p,"/""*@*""/",5))
{in_C= FALSE;
before_TeX_text= TRUE;
function_blocks= FALSE;

if(any_input)
fputs("\n@\n"
"\\ind=2\n\n",out);

any_input= FALSE;
*(buf_p--)= '\n';
goto end;
}
else if(!strncmp(buf_p,"/""*{*""/",5))
{brace_count++;
fputs("@{\n",out);

ch= '\n';
goto end;
}
else if(!strncmp(buf_p,"/""*}*""/",5))
{brace_count--;
fputs("@}\n",out);

if(!brace_count&&function_blocks)

{in_C= FALSE;
before_TeX_text= TRUE;

break;
}

ch= '\n';
goto end;
}
}
}

if(double_linefeed&&ch=='/')
linefeed_comment= TRUE;

if(double_linefeed&&(ch==' '||ch=='\t'))
leading_blanks= TRUE;

if(ch!='\n')
double_linefeed= FALSE;

if(!xisspace(ch))
{any_input= TRUE;

if(before_TeX_text&&function_blocks)
{before_TeX_text= FALSE;

if(function_blocks==WAIT)
function_blocks= TRUE;

else
{fputs("@\n"
"\\ind=2\n\n",out);

if(leading_blanks)
{leading_blanks= FALSE;

while(blank_count--)
fputc(' ',out);
blank_count= 0;
}
}
}

if(in_comment&&leading_blanks)
{leading_blanks= FALSE;

while(blank_count--)
fputc(' ',out);
blank_count= 0;
}
}

if(!(ch=='/'||xisspace(ch)))

{if(!(in_comment||in_C||comment_slash))
{in_C= TRUE;

fputs("@c\n",out);

if(leading_blanks)
{leading_blanks= FALSE;

while(blank_count--)
fputc(' ',out);
blank_count= 0;
}
}

if(!(in_comment||comment_slash)&&leading_blanks)
{leading_blanks= FALSE;

while(blank_count--)
fputc(' ',out);
blank_count= 0;
}
}

if(comment_slash&&!(ch=='*'||ch=='/'))

{comment_slash= FALSE;
if(!in_comment)
linefeed_comment= FALSE;

fputc('/',out);
}

if(comment_star&&ch!='/')
{comment_star= FALSE;

fputc('*',out);
}

if(escape_state&&!(ch=='\"'||ch=='\n'||ch=='\\'))

escape_state= FALSE;

/*:15*/
#line 460 "c2cweb.w"
;

switch(ch)
{case' ':
if(leading_blanks)
{blank_count++;
goto end;
}
break;

case'\t':
{int i= tab_length-(column%tab_length);

column+= i-1;

if(leading_blanks)
{blank_count+= i;
goto end;
}

while(i--)
fputc(' ',out);
goto end;
}
break;

case'{':
/*16:*/
#line 681 "c2cweb.w"

if(in_comment)
fputc('\\',out);
else if(in_string)
break;
else if(function_blocks)
{brace_count++;
in_C= TRUE;
}

/*:16*/
#line 487 "c2cweb.w"
;
break;

case'}':
/*21:*/
#line 727 "c2cweb.w"

if(in_comment)
fputc('\\',out);
else if(in_string)
break;
else if(function_blocks)
{brace_count--;
if(!brace_count)
{in_C= FALSE;

before_TeX_text= TRUE;
break;
}
}

/*:21*/
#line 491 "c2cweb.w"
;
break;

case'/':
/*22:*/
#line 743 "c2cweb.w"

if(comment_star)
{comment_star= FALSE;
leading_blanks= FALSE;

if(!short_comment)
{in_comment= FALSE;

if(!in_C)
{linefeed_comment= FALSE;

if(verbatim)
fputs("*""/}",out);

if(*(buf_p+1)=='\n')
fputs("\\e{}%",out);

goto end;
}

if(in_C&&verbatim)
{if(linefeed_comment)
{linefeed_comment= FALSE;

fputs("*""/@>",out);
if(*(buf_p+1)=='\n'&&!user_linefeed)
fputs("@/",out);
goto end;
}
else
fputc('}',out);
}

linefeed_comment= FALSE;

if(in_C||verbatim)
fputc('*',out);
else
goto end;
}
else
fputc('*',out);
}
else if(comment_slash)
{comment_slash= FALSE;

if(!short_comment)
{in_comment= TRUE;
short_comment= TRUE;

if(!in_C&&verbatim)
{fputs("{\\ob{}",out);
if(leading_blanks)
{leading_blanks= FALSE;

while(blank_count--)
fputc(' ',out);
blank_count= 0;
}
fputs("//",out);

goto end;
}

if(in_C&&verbatim)
{if(leading_blanks||linefeed_comment)
{linefeed_comment= TRUE;

if(!user_linefeed)
fputs("@/",out);
fputs("@t}\\8{\\ob{}",out);


if(leading_blanks)
{leading_blanks= FALSE;

while(blank_count--)
fputc(' ',out);
blank_count= 0;
}
fputs("//",out);
}
else
fputs("//{\\ob{}",out);

goto end;
}

if(in_C||verbatim)
fputc('/',out);
else
goto end;
}
else
fputc('/',out);
}
else
{comment_slash= TRUE;

goto end;
}

/*:22*/
#line 495 "c2cweb.w"
;
break;

case'*':
/*23:*/
#line 846 "c2cweb.w"

if(comment_slash)
{comment_slash= FALSE;

if(in_comment&&!short_comment)







{fprintf(stderr,
"    Error line %d: Nested comments not supported\n",
line_number);
exit(-1);
}

if(!short_comment)
{in_comment= TRUE;

if(!in_C&&verbatim)
{fputs("{\\ob{}",out);
if(leading_blanks)
{leading_blanks= FALSE;

while(blank_count--)
fputc(' ',out);
blank_count= 0;
}
fputs("/""*",out);

goto end;
}

if(in_C&&verbatim)
{if(leading_blanks||linefeed_comment)
{linefeed_comment= TRUE;

if(!user_linefeed)
fputs("@/",out);
fputs("@t}\\8{\\ob{}",out);
if(leading_blanks)
{leading_blanks= FALSE;

while(blank_count--)
fputc(' ',out);
blank_count= 0;
}
fputs("/""*",out);
}
else
fputs("/""*{\\ob{}",out);

goto end;
}

if(in_C||verbatim)
fputc('/',out);
else
{fputs("  ",out);

goto end;
}
}
else
fputc('/',out);
}
else
{comment_star= TRUE;

goto end;
}

/*:23*/
#line 499 "c2cweb.w"
;
break;

case'\n':
/*24:*/
#line 921 "c2cweb.w"

blank_count= 0;

if(!in_comment&&in_C)
{if(double_linefeed==FALSE)
{double_linefeed= TRUE;
if(escape_state)
{escape_state= FALSE;

leading_blanks= TRUE;

if(in_string)
fputc('\n',out);
else
fputs("\n@/",out);
goto end;
}

if(!leading_blanks&&user_linefeed)
fputs("@/",out);
}
else if(double_linefeed==TRUE)
{double_linefeed= DONE;


fputs("@#",out);
}
}

leading_blanks= TRUE;

if(short_comment)
{short_comment= FALSE;
in_comment= FALSE;
double_linefeed= TRUE;

if(verbatim)
{if(linefeed_comment&&in_C)
fputs("@>",out);
else
fputc('}',out);
}

if(!in_C)
fputs("\\e{}%",out);
else if(linefeed_comment&&verbatim)
fputs("@/",out);

linefeed_comment= FALSE;
}

if(in_comment&&in_C&&verbatim&&linefeed_comment)
{fputs("@>@/\n@t}\\8{\\ob{}",out);

goto end;
}

if(in_comment&&verbatim)



{fputs("\n\\e{}",out);
goto end;
}

/*:24*/
#line 503 "c2cweb.w"
;
break;

case'@':
/*17:*/
#line 692 "c2cweb.w"

if(in_comment)
{fputs("{\\char64}",out);
goto end;
}
else
fputc('@',out);

/*:17*/
#line 507 "c2cweb.w"
;
break;

case'\'':
/*18:*/
#line 701 "c2cweb.w"

if(!in_comment)
{if(*(buf_p+1)=='\"'&&*(buf_p+2)=='\'')
escape_state= TRUE;
}

/*:18*/
#line 511 "c2cweb.w"
;
break;

case'\"':
/*19:*/
#line 708 "c2cweb.w"

if(!in_comment)
{if(escape_state)
escape_state= FALSE;
else
in_string= TRUE-in_string;
}

/*:19*/
#line 515 "c2cweb.w"
;
break;

case'\\':
/*20:*/
#line 717 "c2cweb.w"

if(in_comment)
{fputs("{\\symb\\char110}",out);
goto end;
}
else
escape_state= TRUE-escape_state;


/*:20*/
#line 519 "c2cweb.w"
;
break;

default:
/*25:*/
#line 990 "c2cweb.w"

if(in_comment)
{switch(ch)
{case'#':
fputs("{\\#}",out);
break;

case'$':
fputs("{\\$}",out);
break;

case'%':
fputs("{\\%}",out);
break;

case'&':
fputs("{\\AM}",out);
break;

case'_':
fputs("{\\_}",out);
break;

case'^':
fputs("{\\^{}}",out);
break;

case'\\':
fputs("{\\symb\\char110}",out);
break;

case'~':
fputs("{\\~{}}",out);
break;

case'|':
fputs("{\\symb\\char106}",out);
break;

case'<':
fputs("{\\math\\char60}",out);
break;

case'>':
fputs("{\\math\\char62}",out);
break;

default:
fputc(ch,out);
break;
}

goto end;
}

/*:25*/
#line 523 "c2cweb.w"
;
break;
}

fputc(ch,out);

end:
buf_p++;
column++;
}while(ch!='\n');
}
}

/*:14*//*28:*/
#line 1060 "c2cweb.w"

void usage(void)
{fprintf(stderr,
"Usage: c2cweb [switches] csourcefile(s) | @responsefile(s)"
"\n"
"\n  possible switches:"
"\n"
"\n    -b \"title\"    set title"
"\n    -l            use input linefeeds"
"\n    -o dirname    set output directory (must already exist)"
"\n    -t tablength  set tabulator length (default 4)"
"\n    -v            verbatim mode"
"\n    -1            one-sided output"
"\n"
"\n");

exit(-1);
}

/*:28*//*30:*/
#line 1088 "c2cweb.w"

void modify_filename(name)
char*name;
{char*p;


if((p= strrchr(name,'.'))!=NULL)
{p++;
if(*p&&*p!=' ')
p++;
if(*p&&*p!=' ')
p++;
if(*p!='w')
*p= 'w';
else
*p= 'x';
p++;
*p= '\0';
}
else
strcat(name,".w");
}

/*:30*//*33:*/
#line 1123 "c2cweb.w"

char*get_line(void)
{char*p;
int i= BUFFER_LENGTH;


if((p= fgets(buffer,BUFFER_LENGTH+1,in))!=NULL)
{while(i--)
{if(*(p++)=='\n')
break;
}

p--;
p--;
while((*p==' '||*p=='\t')&&p>=buffer)
p--;
*(p+1)= '\n';
*(p+2)= '\0';

line_number++;
column= 0;
}
return(p);
}

/*:33*//*36:*/
#line 1159 "c2cweb.w"

char*protect_underlines(p)
char*p;
{char*q;


q= tempbuf;

do
{if(*p=='_')
*(q++)= '\\';
*(q++)= *p;
}while(*(p++));

return tempbuf;
}

/*:36*//*38:*/
#line 1186 "c2cweb.w"

#ifndef __EMX__
char*_getname(char*path)
{char*p;

p= strrchr(path,'/');
return p==NULL?path:(p+1);
}
#endif


/*:38*/
