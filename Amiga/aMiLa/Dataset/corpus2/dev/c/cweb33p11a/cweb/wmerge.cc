#define buf_size 1024 \

#define max_include_depth 10 \

#define max_file_name_length 256
#define cur_file file[include_depth]
#define cur_file_name file_name[include_depth]
#define cur_line line[include_depth]
#define web_file file[0]
#define web_file_name file_name[0] \

#define lines_dont_match (change_limit-change_buffer!=limit-buffer|| \
strncmp(buffer,change_buffer,(size_t) (limit-buffer) ) )  \

#define too_long() {include_depth--; \
err_print("! Include file name too long") ;goto restart;} \

#define spotless 0
#define harmless_message 1
#define error_message 2
#define fatal_message 3
#define mark_harmless {if(history==spotless) history= harmless_message;}
#define mark_error history= error_message \

#define fatal(s,t) { \
fprintf(stderr,s) ;err_print(t) ; \
history= fatal_message;exit(wrap_up() ) ; \
} \

#define RETURN_OK 0
#define RETURN_WARN 5
#define RETURN_ERROR 10
#define RETURN_FAIL 20 \

#define show_banner flags['b']
#define show_happiness flags['h'] \

#define update_terminal fflush(stderr)  \

#define max_path_length 4094 \

#define alloc_object(object,size,type)  \
if(!(object= (type*) malloc((size) *sizeof(type) ) ) )  \
fatal("","! Memory allocation failure") ;
#define free_object(object)  \
if(object) { \
free(object) ; \
object= NULL; \
} \

/*1:*/
#line 13 "wmerge.w"

#line 84 "wmerge.ch"
#include <stdio.h>
#include <string.h>
#include <signal.h>

#ifdef SEPARATORS
char separators[]= SEPARATORS;
#else
char separators[]= "://";
#endif

#define PATH_SEPARATOR   separators[0]
#define DIR_SEPARATOR    separators[1]
#define DEVICE_SEPARATOR separators[2]
#line 15 "wmerge.w"
#include <stdlib.h> 
#include <ctype.h> 
/*2:*/
#line 35 "wmerge.w"

typedef short boolean;
typedef unsigned char eight_bits;
typedef char ASCII;

/*:2*//*5:*/
#line 68 "wmerge.w"

#line 138 "wmerge.ch"
ASCII*buffer;
ASCII*buffer_end;
#line 71 "wmerge.w"
ASCII*limit;
ASCII*loc;

/*:5*//*7:*/
#line 134 "wmerge.w"

int include_depth;
#line 166 "wmerge.ch"
FILE**file;
FILE*change_file;
char**file_name;
char*change_file_name;
char*alt_web_file_name;
int*line;
#line 143 "wmerge.w"
int change_line;
int change_depth;
boolean input_has_ended;
boolean changing;
boolean web_file_open= 0;

/*:7*//*8:*/
#line 160 "wmerge.w"

#line 186 "wmerge.ch"
char*change_buffer;
#line 162 "wmerge.w"
char*change_limit;

/*:8*//*23:*/
#line 478 "wmerge.w"

int history= spotless;

/*:23*//*30:*/
#line 575 "wmerge.w"

int argc;
char**argv;
#line 444 "wmerge.ch"
char*out_file_name;
char*check_file_name;
boolean*flags;
#line 580 "wmerge.w"

/*:30*//*40:*/
#line 692 "wmerge.w"

#line 511 "wmerge.ch"
FILE*out_file;
FILE*check_file;
#line 694 "wmerge.w"

/*:40*//*44:*/
#line 571 "wmerge.ch"

char*include_path;
char*p,*path_prefix,*next_path_prefix;

/*:44*//*46:*/
#line 596 "wmerge.ch"

#ifdef __SASC
const char Version[]= "$VER: WMerge 3.3 [p11] ("__DATE__", "__TIME__")\n";
#endif

/*:46*//*51:*/
#line 690 "wmerge.ch"

int i;

/*:51*/
#line 17 "wmerge.w"

/*4:*/
#line 51 "wmerge.w"


/*:4*//*24:*/
#line 361 "wmerge.ch"

void err_print(char*);

/*:24*//*32:*/
#line 468 "wmerge.ch"

void scan_args(void);

/*:32*//*45:*/
#line 578 "wmerge.ch"

int get_line(void);
int input_ln(FILE*);
int main(int,char**);
int wrap_up(void);
void check_change(void);
void check_complete(void);
void err_print(char*);
void prime_the_change_buffer(void);
void put_line(void);
void reset_input(void);
void scan_args(void);
static boolean set_path(char*,char*);

/*:45*//*54:*/
#line 716 "wmerge.ch"

void catch_break(int);

/*:54*/
#line 18 "wmerge.w"

/*6:*/
#line 93 "wmerge.w"

#line 146 "wmerge.ch"
int input_ln(
FILE*fp)
#line 96 "wmerge.w"
{
register int c= EOF;
register char*k;
if(feof(fp))return(0);
limit= k= buffer;
while(k<=buffer_end&&(c= getc(fp))!=EOF&&c!='\n')
if((*(k++)= c)!=' ')limit= k;
if(k>buffer_end)
if((c= getc(fp))!=EOF&&c!='\n'){
ungetc(c,fp);loc= buffer;err_print("! Input line too long");

}
if(c==EOF&&limit==buffer)return(0);

return(1);
}

/*:6*//*9:*/
#line 171 "wmerge.w"

#line 195 "wmerge.ch"
void prime_the_change_buffer(void)
#line 174 "wmerge.w"
{
change_limit= change_buffer;
/*10:*/
#line 185 "wmerge.w"

while(1){
change_line++;
if(!input_ln(change_file))return;
if(limit<buffer+2)continue;
if(buffer[0]!='@')continue;
if(isupper(buffer[1]))buffer[1]= tolower(buffer[1]);
if(buffer[1]=='x')break;
if(buffer[1]=='y'||buffer[1]=='z'||buffer[1]=='i'){
loc= buffer+2;
err_print("! Missing @x in change file");

}
}

/*:10*/
#line 176 "wmerge.w"
;
/*11:*/
#line 202 "wmerge.w"

do{
change_line++;
if(!input_ln(change_file)){
err_print("! Change file ended after @x");

return;
}
}while(limit==buffer);

/*:11*/
#line 177 "wmerge.w"
;
/*12:*/
#line 212 "wmerge.w"

{
change_limit= change_buffer-buffer+limit;
#line 202 "wmerge.ch"
strncpy(change_buffer,buffer,(size_t)(limit-buffer+1));
#line 216 "wmerge.w"
}

/*:12*/
#line 178 "wmerge.w"
;
}

/*:9*//*13:*/
#line 230 "wmerge.w"

#line 210 "wmerge.ch"
void check_change(void)
#line 233 "wmerge.w"
{
int n= 0;
if(lines_dont_match)return;
while(1){
changing= 1;change_line++;
if(!input_ln(change_file)){
err_print("! Change file ended before @y");

change_limit= change_buffer;changing= 0;
return;
}
if(limit>buffer+1&&buffer[0]=='@'){
if(isupper(buffer[1]))buffer[1]= tolower(buffer[1]);
/*14:*/
#line 263 "wmerge.w"

if(buffer[1]=='x'||buffer[1]=='z'){
loc= buffer+2;err_print("! Where is the matching @y?");

}
else if(buffer[1]=='y'){
if(n>0){
loc= buffer+2;
fprintf(stderr,"\n! Hmm... %d ",n);
err_print("of the preceding lines failed to match");

}
change_depth= include_depth;
return;
}

/*:14*/
#line 247 "wmerge.w"
;
}
/*12:*/
#line 212 "wmerge.w"

{
change_limit= change_buffer-buffer+limit;
#line 202 "wmerge.ch"
strncpy(change_buffer,buffer,(size_t)(limit-buffer+1));
#line 216 "wmerge.w"
}

/*:12*/
#line 249 "wmerge.w"
;
changing= 0;cur_line++;
while(!input_ln(cur_file)){
if(include_depth==0){
err_print("! CWEB file ended during a change");

input_has_ended= 1;return;
}
include_depth--;cur_line++;
}
if(lines_dont_match)n++;
}
}

/*:13*//*15:*/
#line 282 "wmerge.w"

#line 218 "wmerge.ch"
void reset_input(void)
#line 285 "wmerge.w"
{
limit= buffer;loc= buffer+1;buffer[0]= ' ';
/*16:*/
#line 297 "wmerge.w"

if((web_file= fopen(web_file_name,"r"))==NULL){
strcpy(web_file_name,alt_web_file_name);
if((web_file= fopen(web_file_name,"r"))==NULL)
fatal("! Cannot open input file ",web_file_name);
}


web_file_open= 1;
if((change_file= fopen(change_file_name,"r"))==NULL)
fatal("! Cannot open change file ",change_file_name);

/*:16*/
#line 287 "wmerge.w"
;
include_depth= 0;cur_line= 0;change_line= 0;
change_depth= include_depth;
changing= 1;prime_the_change_buffer();changing= !changing;
limit= buffer;loc= buffer+1;buffer[0]= ' ';input_has_ended= 0;
}

/*:15*//*17:*/
#line 315 "wmerge.w"

get_line()
{
restart:
if(changing&&include_depth==change_depth)
/*21:*/
#line 423 "wmerge.w"
{
change_line++;
if(!input_ln(change_file)){
err_print("! Change file ended without @z");

buffer[0]= '@';buffer[1]= 'z';limit= buffer+2;
}
if(limit>buffer){
*limit= ' ';
if(buffer[0]=='@'){
if(isupper(buffer[1]))buffer[1]= tolower(buffer[1]);
if(buffer[1]=='x'||buffer[1]=='y'){
loc= buffer+2;
err_print("! Where is the matching @z?");

}
else if(buffer[1]=='z'){
prime_the_change_buffer();changing= !changing;
}
}
}
}

/*:21*/
#line 320 "wmerge.w"
;
if(!changing||include_depth>change_depth){
/*20:*/
#line 407 "wmerge.w"
{
cur_line++;
while(!input_ln(cur_file)){
if(include_depth==0){input_has_ended= 1;break;}
else{
fclose(cur_file);include_depth--;
if(changing&&include_depth==change_depth)break;
cur_line++;
}
}
if(!changing&&!input_has_ended)
if(limit-buffer==change_limit-change_buffer)
if(buffer[0]==change_buffer[0])
if(change_limit>change_buffer)check_change();
}

/*:20*/
#line 322 "wmerge.w"
;
if(changing&&include_depth==change_depth)goto restart;
}
loc= buffer;*limit= ' ';
if(*buffer=='@'&&(*(buffer+1)=='i'||*(buffer+1)=='I')){
loc= buffer+2;
while(loc<=limit&&(*loc==' '||*loc=='\t'||*loc=='"'))loc++;
if(loc>=limit){
err_print("! Include file name not given");

goto restart;
}
if(include_depth>=max_include_depth-1){
err_print("! Too many nested includes");

goto restart;
}
include_depth++;
/*19:*/
#line 366 "wmerge.w"
{
#line 272 "wmerge.ch"
static char*temp_file_name;
#line 368 "wmerge.w"
char*cur_file_name_end= cur_file_name+max_file_name_length-1;
char*k= cur_file_name,*kk;
int l;

#line 278 "wmerge.ch"
alloc_object(temp_file_name,max_file_name_length,char);
while(*loc!=' '&&*loc!='\t'&&*loc!='"'&&k<=cur_file_name_end)*k++= *loc++;
#line 373 "wmerge.w"
if(k>cur_file_name_end)too_long();

*k= '\0';
if((cur_file= fopen(cur_file_name,"r"))!=NULL){
cur_line= 0;
goto restart;
}
#line 312 "wmerge.ch"
if(0==set_path(include_path,getenv("CWEBINPUTS"))){
include_depth--;goto restart;
}
path_prefix= include_path;
while(path_prefix){
for(kk= temp_file_name,p= path_prefix,l= 0;
p&&*p&&*p!=PATH_SEPARATOR;
*kk++= *p++,l++);
if(path_prefix&&*path_prefix&&*path_prefix!=PATH_SEPARATOR&&
*--p!=DEVICE_SEPARATOR&&*p!=DIR_SEPARATOR){
*kk++= DIR_SEPARATOR;l++;
}
if(k+l+2>=cur_file_name_end)too_long();
strcpy(kk,cur_file_name);
if(cur_file= fopen(temp_file_name,"r")){
cur_line= 0;goto restart;
}
if(next_path_prefix= strchr(path_prefix,PATH_SEPARATOR))
path_prefix= next_path_prefix+1;
else break;
}
#line 404 "wmerge.w"
include_depth--;err_print("! Cannot open include file");goto restart;
}

/*:19*/
#line 340 "wmerge.w"
;
}
return(!input_has_ended);
}

#line 233 "wmerge.ch"
void put_line(void)
{
char*ptr= buffer;
while(ptr<limit)
{
putc(*ptr,out_file);
ptr++;
}
putc('\n',out_file);
}
#line 351 "wmerge.w"

#line 257 "wmerge.ch"
/*:17*//*22:*/
#line 449 "wmerge.w"

#line 340 "wmerge.ch"
void check_complete(void){
#line 452 "wmerge.w"
if(change_limit!=change_buffer){
#line 347 "wmerge.ch"
strncpy(buffer,change_buffer,(size_t)(change_limit-change_buffer+1));
#line 454 "wmerge.w"
limit= buffer+(int)(change_limit-change_buffer);
changing= 1;change_depth= include_depth;loc= buffer;
err_print("! Change file entry did not match");

}
}

/*:22*//*25:*/
#line 365 "wmerge.ch"

void err_print(char*s)
#line 498 "wmerge.w"
{
char*k,*l;
fprintf(stderr,*s=='!'?"\n%s":"%s",s);
if(web_file_open)/*26:*/
#line 514 "wmerge.w"

{if(changing&&include_depth==change_depth)
printf(". (l. %d of change file)\n",change_line);
else if(include_depth==0)fprintf(stderr,". (l. %d)\n",cur_line);
else fprintf(stderr,". (l. %d of include file %s)\n",cur_line,cur_file_name);
l= (loc>=limit?limit:loc);
if(l>buffer){
for(k= buffer;k<l;k++)
if(*k=='\t')putc(' ',stderr);
else putc(*k,stderr);
putchar('\n');
for(k= buffer;k<l;k++)putc(' ',stderr);
}
for(k= l;k<limit;k++)putc(*k,stderr);
putc('\n',stderr);
}

/*:26*/
#line 501 "wmerge.w"
;
update_terminal;mark_error;
}

/*:25*//*28:*/
#line 403 "wmerge.ch"

#ifdef __TURBOC__
int wrap_up(void){
int return_val;

putchar('\n');
/*55:*/
#line 719 "wmerge.ch"

if(out_file)
fclose(out_file);
if(check_file)
fclose(check_file);
if(check_file_name)
remove(check_file_name);

/*:55*/
#line 409 "wmerge.ch"

/*29:*/
#line 553 "wmerge.w"

switch(history){
case spotless:if(show_happiness)fprintf(stderr,"(No errors were found.)\n");break;
case harmless_message:
fprintf(stderr,"(Did you see the warning message above?)\n");break;
case error_message:
fprintf(stderr,"(Pardon me, but I think I spotted something wrong.)\n");break;
case fatal_message:fprintf(stderr,"(That was a fatal error, my friend.)\n");
}

/*:29*/
#line 410 "wmerge.ch"
;
switch(history){
case harmless_message:return_val= RETURN_WARN;break;
case error_message:return_val= RETURN_ERROR;break;
case fatal_message:return_val= RETURN_FAIL;break;
default:return_val= RETURN_OK;
}
return(return_val);
}
#else
int wrap_up(void){
putchar('\n');
/*55:*/
#line 719 "wmerge.ch"

if(out_file)
fclose(out_file);
if(check_file)
fclose(check_file);
if(check_file_name)
remove(check_file_name);

/*:55*/
#line 422 "wmerge.ch"

/*29:*/
#line 553 "wmerge.w"

switch(history){
case spotless:if(show_happiness)fprintf(stderr,"(No errors were found.)\n");break;
case harmless_message:
fprintf(stderr,"(Did you see the warning message above?)\n");break;
case error_message:
fprintf(stderr,"(Pardon me, but I think I spotted something wrong.)\n");break;
case fatal_message:fprintf(stderr,"(That was a fatal error, my friend.)\n");
}

/*:29*/
#line 423 "wmerge.ch"
;
switch(history){
case harmless_message:return(RETURN_WARN);break;
case error_message:return(RETURN_ERROR);break;
case fatal_message:return(RETURN_FAIL);break;
default:return(RETURN_OK);
}
}
#endif
#line 552 "wmerge.w"

/*:28*//*33:*/
#line 472 "wmerge.ch"

void scan_args(void)
#line 606 "wmerge.w"
{
char*dot_pos;
#line 609 "wmerge.w"
register char*s;
boolean found_web= 0,found_change= 0,found_out= 0;

boolean flag_change;

while(--argc>0){
if(**(++argv)=='-'||**argv=='+')/*37:*/
#line 674 "wmerge.w"

{
if(**argv=='-')flag_change= 0;
else flag_change= 1;
for(dot_pos= *argv+1;*dot_pos>'\0';dot_pos++)
flags[*dot_pos]= flag_change;
}

/*:37*/
#line 615 "wmerge.w"

else{
#line 489 "wmerge.ch"
s= *argv;dot_pos= NULL;
while(*s){
if(*s=='.')dot_pos= s++;
else if(*s==DIR_SEPARATOR||*s==DEVICE_SEPARATOR||*s=='/')
dot_pos= NULL,++s;
else s++;
}
#line 623 "wmerge.w"
if(!found_web)/*34:*/
#line 640 "wmerge.w"

{
if(s-*argv>max_file_name_length-5)
/*39:*/
#line 687 "wmerge.w"
fatal("! Filename too long\n",*argv);

/*:39*/
#line 643 "wmerge.w"
;
if(dot_pos==NULL)
sprintf(web_file_name,"%s.w",*argv);
else{
strcpy(web_file_name,*argv);
*dot_pos= 0;
}
sprintf(alt_web_file_name,"%s.web",*argv);
*out_file_name= '\0';
found_web= 1;
}

/*:34*/
#line 623 "wmerge.w"

else if(!found_change)/*35:*/
#line 655 "wmerge.w"

{
if(s-*argv>max_file_name_length-4)
/*39:*/
#line 687 "wmerge.w"
fatal("! Filename too long\n",*argv);

/*:39*/
#line 658 "wmerge.w"
;
if(dot_pos==NULL)
sprintf(change_file_name,"%s.ch",*argv);
else strcpy(change_file_name,*argv);
found_change= 1;
}

/*:35*/
#line 624 "wmerge.w"

else if(!found_out)/*36:*/
#line 665 "wmerge.w"

{
if(s-*argv>max_file_name_length-5)
/*39:*/
#line 687 "wmerge.w"
fatal("! Filename too long\n",*argv);

/*:39*/
#line 668 "wmerge.w"
;
if(dot_pos==NULL)sprintf(out_file_name,"%s.out",*argv);
else strcpy(out_file_name,*argv);
found_out= 1;
}

/*:36*/
#line 625 "wmerge.w"

else/*38:*/
#line 682 "wmerge.w"

{
fatal("! Usage: wmerge webfile[.w] [changefile[.ch] [outfile[.out]]]\n","")
}

/*:38*/
#line 626 "wmerge.w"
;
}
}
if(!found_web)/*38:*/
#line 682 "wmerge.w"

{
fatal("! Usage: wmerge webfile[.w] [changefile[.ch] [outfile[.out]]]\n","")
}

/*:38*/
#line 629 "wmerge.w"
;
#line 501 "wmerge.ch"
#ifdef _DEV_NULL
if(!found_change)strcpy(change_file_name,_DEV_NULL);
#else
if(!found_change)strcpy(change_file_name,"/dev/null");
#endif
#line 631 "wmerge.w"
}

/*:33*/
#line 19 "wmerge.w"

#line 104 "wmerge.ch"
int main(int ac,char**av)
#line 22 "wmerge.w"
{
argc= ac;argv= av;
#line 110 "wmerge.ch"
/*52:*/
#line 701 "wmerge.ch"

if(signal(SIGINT,&catch_break)==SIG_ERR)
exit(1);

/*:52*/
#line 110 "wmerge.ch"

/*50:*/
#line 671 "wmerge.ch"

alloc_object(buffer,buf_size,ASCII);
buffer_end= buffer+buf_size-2;
alloc_object(file,max_include_depth,FILE*);
alloc_object(file_name,max_include_depth,char*);
for(i= 0;i<max_include_depth;i++)
alloc_object(file_name[i],max_file_name_length,char);
alloc_object(change_file_name,max_file_name_length,char);
alloc_object(alt_web_file_name,max_file_name_length,char);
alloc_object(line,max_include_depth,int);
alloc_object(change_buffer,buf_size,char);
alloc_object(out_file_name,max_file_name_length,char);
alloc_object(check_file_name,max_file_name_length,char);
alloc_object(flags,256,boolean);
alloc_object(include_path,max_path_length+2,char);
#ifdef CWEBINPUTS
strcpy(include_path,CWEBINPUTS);
#endif

/*:50*/
#line 111 "wmerge.ch"
;
/*31:*/
#line 583 "wmerge.w"

show_banner= show_happiness= 1;

/*:31*/
#line 112 "wmerge.ch"
;
#line 25 "wmerge.w"
/*41:*/
#line 695 "wmerge.w"

#line 522 "wmerge.ch"
scan_args();
tmpnam(check_file_name);
if(strrchr(check_file_name,DEVICE_SEPARATOR))
check_file_name= strrchr(check_file_name,DEVICE_SEPARATOR)+1;
if(out_file_name[0]=='\0')out_file= stdout;
else if(!(out_file= fopen(check_file_name,"w")))
fatal("! Cannot open output file ",check_file_name);

#line 701 "wmerge.w"

/*:41*/
#line 25 "wmerge.w"
;
reset_input();
while(get_line())
put_line();
fflush(out_file);
check_complete();
fflush(out_file);
#line 118 "wmerge.ch"
if(out_file!=stdout){
fclose(out_file);out_file= NULL;
/*47:*/
#line 620 "wmerge.ch"

if(out_file= fopen(out_file_name,"r")){
char*x,*y;
int x_size,y_size;

if(!(check_file= fopen(check_file_name,"r")))
fatal("! Cannot open output file",check_file_name);

alloc_object(x,BUFSIZ,char);
alloc_object(y,BUFSIZ,char);

/*48:*/
#line 648 "wmerge.ch"

do{
x_size= fread(x,1,BUFSIZ,out_file);
y_size= fread(y,1,BUFSIZ,check_file);
}while((x_size==y_size)&&!memcmp(x,y,x_size)&&
!feof(out_file)&&!feof(check_file));

/*:48*/
#line 631 "wmerge.ch"


fclose(out_file);out_file= NULL;
fclose(check_file);check_file= NULL;

/*49:*/
#line 658 "wmerge.ch"

if((x_size!=y_size)||memcmp(x,y,x_size)){
remove(out_file_name);
rename(check_file_name,out_file_name);
}
else
remove(check_file_name);

/*:49*/
#line 636 "wmerge.ch"


free_object(y);
free_object(x);
}
else
rename(check_file_name,out_file_name);

check_file_name= NULL;

/*:47*/
#line 120 "wmerge.ch"

}
return wrap_up();
#line 33 "wmerge.w"
}

/*:1*//*43:*/
#line 544 "wmerge.ch"

static boolean set_path(char*default_path,char*environment)
{
static char*string;

alloc_object(string,max_path_length+2,char);
if(environment){
if(strlen(environment)+strlen(default_path)>=max_path_length){
err_print("! Include path too long");return(0);

}
else{
sprintf(string,"%s%c%s",environment,PATH_SEPARATOR,default_path);
strcpy(default_path,string);
}
}
return(1);
}

/*:43*//*53:*/
#line 709 "wmerge.ch"

void catch_break(int dummy)
{
history= fatal_message;
exit(wrap_up());
}

/*:53*/
