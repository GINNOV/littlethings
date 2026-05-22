/*1:*/
#line 57 "common.w"

#line 232 "common.ch"
/*5:*/
#line 101 "common.w"

#include <ctype.h>

/*:5*//*8:*/
#line 164 "common.w"

#include <stdio.h>

/*:8*//*22:*/
#line 498 "common.ch"

#include <stdlib.h> 
#include <stddef.h> 
#include <signal.h> 

#ifdef SEPARATORS
char separators[]= SEPARATORS;
#else
char separators[]= "://";
#endif

#define PATH_SEPARATOR   separators[0]
#define DIR_SEPARATOR    separators[1]
#define DEVICE_SEPARATOR separators[2]
#line 471 "common.w"

/*:22*//*81:*/
#line 1485 "common.ch"

#include <string.h>

/*:81*//*87:*/
#line 1570 "common.ch"

#ifdef __TURBOC__
#include <alloc.h> 
#include <io.h> 
#endif


/*:87*//*93:*/
#line 1629 "common.ch"

#ifdef _AMIGA
#include <proto/exec.h>
#include <proto/locale.h>

struct Library*LocaleBase= NULL;
struct Catalog*catalog= NULL;
int i;
#else 
typedef long int LONG;
typedef char*STRPTR;
#define EXEC_TYPES_H 1 
#endif

#define STRINGARRAY 1 
#define get_string(n) AppStrings[n].as_Str 

#include "cweb.h"

/*:93*//*96:*/
#line 1684 "common.ch"

#ifdef _AMIGA
#include <proto/dos.h>
#include <proto/rexxsyslib.h>
#endif

/*:96*/
#line 232 "common.ch"

/*88:*/
#line 1577 "common.ch"

#ifdef __TURBOC__
#define HUGE huge
#else
#define HUGE
#endif


/*:88*/
#line 233 "common.ch"

#line 59 "common.w"
#define ctangle 0
#define cweave 1 \

#define and_and 04
#define lt_lt 020
#define gt_gt 021
#define plus_plus 013
#define minus_minus 01
#define minus_gt 031
#define not_eq 032
#define lt_eq 034
#define gt_eq 035
#define eq_eq 036
#define or_or 037
#define dot_dot_dot 016
#define colon_colon 06
#define period_ast 026
#define minus_gt_ast 027 \

#define buf_size 100
#define longest_name 1000
#define long_buf_size (buf_size+longest_name) 
#define xisspace(c) (isspace(c) &&((unsigned char) c<0200) ) 
#define xisupper(c) (isupper(c) &&((unsigned char) c<0200) )  \

#define max_include_depth 10 \

#define max_file_name_length 256
#define cur_file file[include_depth]
#define cur_file_name file_name[include_depth]
#define cur_line line[include_depth]
#define web_file file[0]
#define web_file_name file_name[0] \

#define lines_dont_match (change_limit-change_buffer!=limit-buffer|| \
strncmp(buffer,change_buffer,(size_t) (limit-buffer) ) )  \

#define if_section_start_make_pending(b) {*limit= '!'; \
for(loc= buffer;xisspace(*loc) ;loc++) ; \
*limit= ' '; \
if(*loc=='@'&&(xisspace(*(loc+1) ) ||*(loc+1) =='*') ) change_pending= b; \
} \

#define max_sections 2000 \
 \

#define too_long() {include_depth--; \
err_print(get_string(MSG_ERROR_CO22) ) ;goto restart;} \

#define max_bytes 90000 \

#define max_names 4000 \
 \

#define length(c) (size_t) ((c+1) ->byte_start-(c) ->byte_start) 
#define print_id(c) term_write((c) ->byte_start,length((c) ) )  \

#define alloc_object(object,size,type)  \
if(!(object= (type*) malloc((size) *sizeof(type) ) ) )  \
fatal("",get_string(MSG_FATAL_CO85) ) ; \

#define hash_size 353 \

#define llink link
#define rlink dummy.Rlink
#define root name_dir->rlink \
 \

#define first_chunk(p) ((p) ->byte_start+2) 
#define prefix_length(p) (int) ((unsigned char) *((p) ->byte_start) *256+ \
(unsigned char) *((p) ->byte_start+1) ) 
#define set_prefix_length(p,m) (*((p) ->byte_start) = (m) /256, \
*((p) ->byte_start+1) = (m) %256)  \

#define less 0
#define equal 1
#define greater 2
#define prefix 3
#define extension 4 \

#define bad_extension 5 \

#define spotless 0
#define harmless_message 1
#define error_message 2
#define fatal_message 3
#define mark_harmless {if(history==spotless) history= harmless_message;}
#define mark_error history= error_message \

#define RETURN_OK 0
#define RETURN_WARN 5
#define RETURN_ERROR 10
#define RETURN_FAIL 20 \

#define confusion(s) fatal(get_string(MSG_FATAL_CO66) ,s)  \
 \

#define show_banner flags['b']
#define show_progress flags['p']
#define show_stats flags['s']
#define show_happiness flags['h']
#define indent_param_decl flags['i']
#define send_error_messages flags['m']
#define order_decl_stmt flags['o'] \

#define update_terminal fflush(stdout)  \

#define new_line putchar('\n') 
#define putxchar putchar
#define term_write(a,b) fflush(stdout) ,fwrite(a,sizeof(char) ,b,stdout) 
#define C_printf(c,a) fprintf(C_file,c,a) 
#define C_putc(c) putc(c,C_file)  \

#define max_path_length 4094 \


#line 59 "common.w"

/*2:*/
#line 72 "common.w"

typedef short boolean;
boolean program;

/*:2*//*7:*/
#line 158 "common.w"

#line 265 "common.ch"
char*buffer;
char*buffer_end;
char*limit;
char*loc;
#line 163 "common.w"

/*:7*//*10:*/
#line 213 "common.w"

int include_depth;
#line 304 "common.ch"
FILE**file;
FILE*change_file;
char**file_name;
char*change_file_name;
char*alt_web_file_name;
int*line;
#line 222 "common.w"
int change_line;
int change_depth;
boolean input_has_ended;
boolean changing;
boolean web_file_open= 0;

/*:10*//*20:*/
#line 417 "common.w"

#line 430 "common.ch"
typedef unsigned char eight_bits;
typedef unsigned short sixteen_bits;
#line 419 "common.w"
sixteen_bits section_count;
#line 438 "common.ch"
boolean*changed_section;
#line 421 "common.w"
boolean change_pending;

boolean print_where= 0;

/*:20*//*27:*/
#line 587 "common.w"

typedef struct name_info{
#line 616 "common.ch"
char HUGE*byte_start;
#line 590 "common.w"
/*31:*/
#line 624 "common.w"

#line 689 "common.ch"
struct name_info HUGE*link;
#line 626 "common.w"

/*:31*//*40:*/
#line 723 "common.w"

union{
#line 769 "common.ch"
struct name_info HUGE*Rlink;

#line 727 "common.w"
char Ilk;
}dummy;

/*:40*//*55:*/
#line 1047 "common.ch"

void HUGE*equiv_or_xref;
#line 1057 "common.w"

/*:55*/
#line 590 "common.w"

}name_info;
#line 627 "common.ch"
typedef name_info HUGE*name_pointer;
name_pointer name_dir;
name_pointer name_dir_end;
char HUGE*byte_mem;
char HUGE*byte_mem_end;
#line 597 "common.w"

/*:27*//*29:*/
#line 610 "common.w"

name_pointer name_ptr;
#line 645 "common.ch"
char HUGE*byte_ptr;
#line 613 "common.w"

#line 653 "common.ch"
/*:29*//*32:*/
#line 637 "common.w"

typedef name_pointer*hash_pointer;
#line 697 "common.ch"
hash_pointer hash;
hash_pointer hash_end;
#line 641 "common.w"
hash_pointer h;

#line 706 "common.ch"
/*:32*//*56:*/
#line 1075 "common.w"

int history= spotless;

/*:56*//*67:*/
#line 1213 "common.w"

int argc;
char**argv;
#line 1289 "common.ch"
char*C_file_name;
char*tex_file_name;
char*idx_file_name;
char*scn_file_name;
char*check_file_name;
char*use_language;
boolean flags[256];
#line 1221 "common.w"

/*:67*//*77:*/
#line 1367 "common.w"

FILE*C_file;
FILE*tex_file;
FILE*idx_file;
#line 1429 "common.ch"
FILE*scn_file;
FILE*check_file;
#line 1372 "common.w"
FILE*active_file;

#line 1447 "common.ch"
/*:77*/
#line 60 "common.w"

/*3:*/
#line 82 "common.w"
int phase;

/*:3*//*11:*/
#line 239 "common.w"

#line 325 "common.ch"
char*change_buffer;
#line 241 "common.w"
char*change_limit;

/*:11*//*83:*/
#line 1523 "common.ch"

char*include_path;
char*p,*path_prefix,*next_path_prefix;

/*:83*//*97:*/
#line 1695 "common.ch"

#ifdef _AMIGA
long result= RETURN_FAIL;
char msg_string[BUFSIZ];
char pth_buffer[BUFSIZ];
char cur_buffer[BUFSIZ];

struct RexxMsg*rm;
struct MsgPort*rp;

#define MSGPORT  "SC_SCMSG"
#define PORTNAME "CWEBPORT"
#define RXEXTENS "rexx"
#endif

/*:97*/
#line 61 "common.w"

/*33:*/
#line 706 "common.ch"

extern int names_match(name_pointer,char*,int,eight_bits);
#line 645 "common.w"

/*:33*//*38:*/
#line 752 "common.ch"

extern void init_p(name_pointer,eight_bits);
#line 698 "common.w"

/*:38*//*46:*/
#line 864 "common.ch"

extern void init_node(name_pointer);
#line 847 "common.w"

/*:46*//*53:*/
#line 999 "common.ch"

static int section_name_cmp(char**,int,name_pointer);
#line 1012 "common.w"

/*:53*//*57:*/
#line 1085 "common.w"

#line 1060 "common.ch"
extern void err_print(char*);

/*:57*//*60:*/
#line 1091 "common.ch"

extern int wrap_up(void);
extern void print_stats(void);
#line 1136 "common.w"

#line 1114 "common.ch"
/*:60*//*63:*/
#line 1192 "common.ch"

extern void fatal(char*,char*);
extern void overflow(char*);
#line 1168 "common.w"

/*:63*//*69:*/
#line 1324 "common.ch"

static void scan_args(void);
#line 1246 "common.w"

/*:69*//*85:*/
#line 1552 "common.ch"

#ifdef __TURBOC__
void far*allocsafe(unsigned long,unsigned long);
#endif


/*:85*//*91:*/
#line 1608 "common.ch"

void catch_break(int);

/*:91*//*100:*/
#line 1802 "common.ch"

#ifdef _AMIGA
static int PutRexxMsg(struct MsgPort*,long,STRPTR,struct RexxMsg*);
int __stdargs call_rexx(char*,long*);
#endif

/*:100*//*106:*/
#line 1929 "common.ch"

int get_line(void);
name_pointer add_section_name(name_pointer,int,char*,char*,int);
name_pointer id_lookup(char*,char*,char);
name_pointer section_lookup(char*,char*,int);
void check_complete(void);
void common_init(void);
void extend_section_name(name_pointer,char*,char*,int);
void print_prefix_name(name_pointer);
void print_section_name(name_pointer);
void reset_input(void);
void sprint_section_name(char*,name_pointer);

/*:106*//*107:*/
#line 1944 "common.ch"

static boolean set_path(char*,char*);
static int input_ln(FILE*);
static int web_strcmp(char HUGE*,int,char HUGE*,int);
static void check_change(void);
static void prime_the_change_buffer(void);

/*:107*/
#line 62 "common.w"


/*:1*//*4:*/
#line 88 "common.w"

#line 246 "common.ch"
void common_init(void)
{
/*89:*/
#line 1593 "common.ch"

if(signal(SIGINT,&catch_break)==SIG_ERR)
exit(EXIT_FAILURE);

/*:89*/
#line 248 "common.ch"
;
/*30:*/
#line 659 "common.ch"

alloc_object(buffer,long_buf_size,char);
buffer_end= buffer+buf_size-2;
limit= loc= buffer;
alloc_object(file,max_include_depth,FILE*);
alloc_object(file_name,max_include_depth,char*);
for(phase= 0;phase<max_include_depth;phase++)
alloc_object(file_name[phase],max_file_name_length,char);
alloc_object(change_file_name,max_file_name_length,char);
alloc_object(alt_web_file_name,max_file_name_length,char);
alloc_object(line,max_include_depth,int);
alloc_object(change_buffer,buf_size,char);
alloc_object(changed_section,max_sections,boolean);
#ifdef __TURBOC__
byte_mem= (char HUGE*)allocsafe(max_bytes,sizeof(*byte_mem));
name_dir= (name_pointer)allocsafe(max_names,sizeof(*name_dir));
#else
alloc_object(byte_mem,max_bytes,char);
alloc_object(name_dir,max_names,name_info);
#endif
byte_mem_end= byte_mem+max_bytes-1;
name_dir_end= name_dir+max_names-1;
name_dir->byte_start= byte_ptr= byte_mem;

#line 616 "common.w"
name_ptr= name_dir+1;
name_ptr->byte_start= byte_mem;

/*:30*//*34:*/
#line 715 "common.ch"

alloc_object(hash,hash_size,name_pointer);
hash_end= hash+hash_size-1;
for(h= hash;h<=hash_end;*h++= NULL);
alloc_object(C_file_name,max_file_name_length,char);
alloc_object(tex_file_name,max_file_name_length,char);
alloc_object(idx_file_name,max_file_name_length,char);
alloc_object(scn_file_name,max_file_name_length,char);
alloc_object(check_file_name,L_tmpnam,char);
#line 650 "common.w"

/*:34*//*41:*/
#line 730 "common.w"

root= NULL;

/*:41*//*84:*/
#line 1527 "common.ch"

alloc_object(include_path,max_path_length+2,char);
#ifdef CWEBINPUTS
strcpy(include_path,CWEBINPUTS);
#endif

/*:84*/
#line 249 "common.ch"
;
#ifdef _AMIGA
/*94:*/
#line 1652 "common.ch"

if(LocaleBase= (struct Library*)OpenLibrary(
(unsigned char*)"locale.library",38L)){
if(catalog= OpenCatalog(NULL,"cweb.catalog",
OC_BuiltInLanguage,"english",TAG_DONE)){
for(i= MSG_ERROR_CO9;i<=MSG_STATS_CW248_6;++i)
AppStrings[i].as_Str= GetCatalogStr(catalog,i,AppStrings[i].as_Str);
}
}

/*:94*/
#line 251 "common.ch"
;
#endif
/*68:*/
#line 1303 "common.ch"

show_banner= show_happiness= show_progress= indent_param_decl= order_decl_stmt= 1;
use_language= "";

#line 1228 "common.w"

/*:68*/
#line 253 "common.ch"
;
/*78:*/
#line 1447 "common.ch"

scan_args();
tmpnam(check_file_name);
if(strrchr(check_file_name,DEVICE_SEPARATOR))
check_file_name= strrchr(check_file_name,DEVICE_SEPARATOR)+1;
if(program==ctangle){
if((C_file= fopen(check_file_name,"w"))==NULL)
fatal(get_string(MSG_FATAL_CO78),check_file_name);

}
else{
if((tex_file= fopen(check_file_name,"w"))==NULL)
fatal(get_string(MSG_FATAL_CO78),check_file_name);
}
#line 1385 "common.w"

/*:78*/
#line 254 "common.ch"
;
}
#line 96 "common.w"

/*:4*//*9:*/
#line 171 "common.w"

#line 276 "common.ch"
static int input_ln(
FILE*fp)
#line 174 "common.w"
{
register int c= EOF;
register char*k;
if(feof(fp))return(0);
limit= k= buffer;
while(k<=buffer_end&&(c= getc(fp))!=EOF&&c!='\n')
if((*(k++)= c)!=' ')limit= k;
if(k>buffer_end)
if((c= getc(fp))!=EOF&&c!='\n'){
#line 284 "common.ch"
ungetc(c,fp);loc= buffer;err_print(get_string(MSG_ERROR_CO9));
#line 184 "common.w"

}
if(c==EOF&&limit==buffer)return(0);

return(1);
}

/*:9*//*12:*/
#line 250 "common.w"

#line 333 "common.ch"
static void prime_the_change_buffer(void)
#line 253 "common.w"
{
change_limit= change_buffer;
/*13:*/
#line 264 "common.w"

while(1){
change_line++;
if(!input_ln(change_file))return;
if(limit<buffer+2)continue;
if(buffer[0]!='@')continue;
if(xisupper(buffer[1]))buffer[1]= tolower(buffer[1]);
if(buffer[1]=='x')break;
if(buffer[1]=='y'||buffer[1]=='z'||buffer[1]=='i'){
loc= buffer+2;
#line 340 "common.ch"
err_print(get_string(MSG_ERROR_CO13));
#line 275 "common.w"

}
}

/*:13*/
#line 255 "common.w"
;
/*14:*/
#line 281 "common.w"

do{
change_line++;
if(!input_ln(change_file)){
#line 347 "common.ch"
err_print(get_string(MSG_ERROR_CO14));
#line 286 "common.w"

return;
}
}while(limit==buffer);

/*:14*/
#line 256 "common.w"
;
/*15:*/
#line 291 "common.w"

{
#line 355 "common.ch"
change_limit= change_buffer+(ptrdiff_t)(limit-buffer);
strncpy(change_buffer,buffer,(size_t)(limit-buffer+1));
#line 295 "common.w"
}

/*:15*/
#line 257 "common.w"
;
}

/*:12*//*16:*/
#line 319 "common.w"

#line 364 "common.ch"
static void check_change(void)
#line 322 "common.w"
{
int n= 0;
if(lines_dont_match)return;
change_pending= 0;
if(!changed_section[section_count]){
if_section_start_make_pending(1);
if(!change_pending)changed_section[section_count]= 1;
}
while(1){
changing= 1;print_where= 1;change_line++;
if(!input_ln(change_file)){
#line 371 "common.ch"
err_print(get_string(MSG_ERROR_CO16_1));
#line 334 "common.w"

change_limit= change_buffer;changing= 0;
return;
}
if(limit>buffer+1&&buffer[0]=='@'){
if(xisupper(buffer[1]))buffer[1]= tolower(buffer[1]);
/*17:*/
#line 357 "common.w"

if(buffer[1]=='x'||buffer[1]=='z'){
#line 385 "common.ch"
loc= buffer+2;err_print(get_string(MSG_ERROR_CO17_1));
#line 360 "common.w"

}
else if(buffer[1]=='y'){
if(n>0){
loc= buffer+2;
printf("\n! Hmm... %d ",n);
#line 392 "common.ch"
err_print(get_string(MSG_ERROR_CO17_2));
#line 367 "common.w"

}
change_depth= include_depth;
return;
}

/*:17*/
#line 341 "common.w"
;
}
/*15:*/
#line 291 "common.w"

{
#line 355 "common.ch"
change_limit= change_buffer+(ptrdiff_t)(limit-buffer);
strncpy(change_buffer,buffer,(size_t)(limit-buffer+1));
#line 295 "common.w"
}

/*:15*/
#line 343 "common.w"
;
changing= 0;cur_line++;
while(!input_ln(cur_file)){
if(include_depth==0){
#line 378 "common.ch"
err_print(get_string(MSG_ERROR_CO16_2));
#line 348 "common.w"

input_has_ended= 1;return;
}
include_depth--;cur_line++;
}
if(lines_dont_match)n++;
}
}

/*:16*//*18:*/
#line 377 "common.w"

#line 400 "common.ch"
void reset_input(void)
#line 380 "common.w"
{
limit= buffer;loc= buffer+1;buffer[0]= ' ';
/*19:*/
#line 392 "common.w"

if((web_file= fopen(web_file_name,"r"))==NULL){
strcpy(web_file_name,alt_web_file_name);
if((web_file= fopen(web_file_name,"r"))==NULL)
#line 407 "common.ch"
fatal(get_string(MSG_FATAL_CO19_1),web_file_name);
#line 397 "common.w"
}


web_file_open= 1;
#line 419 "common.ch"
#ifdef _AMIGA
/*101:*/
#line 1823 "common.ch"

if(send_error_messages){
Forbid();
if((rp= FindPort((unsigned char*)MSGPORT))!=NULL);

Permit();

if(!rp){
strcpy(msg_string,"run <nil: >nil: scmsg ");
strcat(msg_string,getenv("SCMSGOPT"));
system(msg_string);
}

if(GetCurrentDirName(cur_buffer,BUFSIZ)&&
AddPart(cur_buffer,web_file_name,BUFSIZ)){
sprintf(msg_string,"newbld \"%s\"",cur_buffer);
call_rexx(msg_string,&result);
}
}

/*:101*/
#line 420 "common.ch"
;
#endif
if((change_file= fopen(change_file_name,"r"))==NULL)
fatal(get_string(MSG_FATAL_CO19_2),change_file_name);
#line 403 "common.w"

/*:19*/
#line 382 "common.w"
;
include_depth= 0;cur_line= 0;change_line= 0;
change_depth= include_depth;
changing= 1;prime_the_change_buffer();changing= !changing;
limit= buffer;loc= buffer+1;buffer[0]= ' ';input_has_ended= 0;
}

/*:18*//*21:*/
#line 425 "common.w"

#line 445 "common.ch"
int get_line(void)
#line 427 "common.w"
{
restart:
if(changing&&include_depth==change_depth)
/*25:*/
#line 530 "common.w"
{
change_line++;
if(!input_ln(change_file)){
#line 581 "common.ch"
err_print(get_string(MSG_ERROR_CO25_1));
#line 534 "common.w"

buffer[0]= '@';buffer[1]= 'z';limit= buffer+2;
}
if(limit>buffer){
if(change_pending){
if_section_start_make_pending(0);
if(change_pending){
changed_section[section_count]= 1;change_pending= 0;
}
}
*limit= ' ';
if(buffer[0]=='@'){
if(xisupper(buffer[1]))buffer[1]= tolower(buffer[1]);
if(buffer[1]=='x'||buffer[1]=='y'){
loc= buffer+2;
#line 588 "common.ch"
err_print(get_string(MSG_ERROR_CO25_2));
#line 550 "common.w"

}
else if(buffer[1]=='z'){
prime_the_change_buffer();changing= !changing;print_where= 1;
}
}
}
}

/*:25*/
#line 430 "common.w"
;
if(!changing||include_depth>change_depth){
/*24:*/
#line 513 "common.w"
{
cur_line++;
while(!input_ln(cur_file)){
print_where= 1;
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

/*:24*/
#line 432 "common.w"
;
if(changing&&include_depth==change_depth)goto restart;
}
loc= buffer;*limit= ' ';
if(*buffer=='@'&&(*(buffer+1)=='i'||*(buffer+1)=='I')){
loc= buffer+2;
while(loc<=limit&&(*loc==' '||*loc=='\t'||*loc=='"'))loc++;
if(loc>=limit){
#line 452 "common.ch"
err_print(get_string(MSG_ERROR_CO21_1));
#line 441 "common.w"

goto restart;
}
if(include_depth>=max_include_depth-1){
#line 459 "common.ch"
err_print(get_string(MSG_ERROR_CO21_2));
#line 446 "common.w"

goto restart;
}
include_depth++;
/*23:*/
#line 472 "common.w"
{
char temp_file_name[max_file_name_length];
char*cur_file_name_end= cur_file_name+max_file_name_length-1;
char*k= cur_file_name,*kk;
int l;

while(*loc!=' '&&*loc!='\t'&&*loc!='"'&&k<=cur_file_name_end)*k++= *loc++;
if(k>cur_file_name_end)too_long();

*k= '\0';
if((cur_file= fopen(cur_file_name,"r"))!=NULL){
cur_line= 0;print_where= 1;
goto restart;
}
#line 547 "common.ch"
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
cur_line= 0;print_where= 1;goto restart;
}
if(next_path_prefix= strchr(path_prefix,PATH_SEPARATOR))
path_prefix= next_path_prefix+1;
else break;
}
#line 574 "common.ch"
include_depth--;err_print(get_string(MSG_ERROR_CO23));goto restart;
#line 511 "common.w"
}

/*:23*/
#line 450 "common.w"
;
}
return(!input_has_ended);
}

#line 482 "common.ch"
/*:21*//*26:*/
#line 562 "common.w"

#line 599 "common.ch"
void check_complete(void){
if(change_limit!=change_buffer){
strncpy(buffer,change_buffer,(size_t)(change_limit-change_buffer+1));
limit= buffer+(ptrdiff_t)(change_limit-change_buffer);
#line 568 "common.w"
changing= 1;change_depth= include_depth;loc= buffer;
#line 609 "common.ch"
err_print(get_string(MSG_ERROR_CO26));
#line 570 "common.w"

}
}

/*:26*//*35:*/
#line 653 "common.w"

#line 734 "common.ch"
name_pointer id_lookup(
char*first,
char*last,
char t)
#line 659 "common.w"
{
char*i= first;
int h;
int l;
name_pointer p;
if(last==NULL)for(last= first;*last!='\0';last++);
#line 744 "common.ch"
l= (int)(last-first);
#line 666 "common.w"
/*36:*/
#line 676 "common.w"

h= (unsigned char)*i;
while(++i<last)h= (h+h+(int)((unsigned char)*i))%hash_size;


/*:36*/
#line 666 "common.w"
;
/*37:*/
#line 684 "common.w"

p= hash[h];
while(p&&!names_match(p,first,l,t))p= p->link;
if(p==NULL){
p= name_ptr;
p->link= hash[h];hash[h]= p;
}

/*:37*/
#line 667 "common.w"
;
if(p==name_ptr)/*39:*/
#line 699 "common.w"
{
#line 761 "common.ch"
if(byte_ptr+l>byte_mem_end)overflow(get_string(MSG_OVERFLOW_CO39_1));
if(name_ptr>=name_dir_end)overflow(get_string(MSG_OVERFLOW_CO39_2));
#line 702 "common.w"
strncpy(byte_ptr,first,l);
(++name_ptr)->byte_start= byte_ptr+= l;
if(program==cweave)init_p(p,t);
}

/*:39*/
#line 668 "common.w"
;
return(p);
}

/*:35*//*42:*/
#line 757 "common.w"

#line 778 "common.ch"
void print_section_name(name_pointer p)
#line 761 "common.w"
{
#line 785 "common.ch"
char HUGE*ss;
char HUGE*s= first_chunk(p);
#line 763 "common.w"
name_pointer q= p+1;
while(p!=name_dir){
ss= (p+1)->byte_start-1;
if(*ss==' '&&ss>=s){
#line 795 "common.ch"
term_write(s,(size_t)(ss-s));p= q->link;q= p;
}else{
term_write(s,(size_t)(ss+1-s));p= name_dir;q= NULL;
#line 770 "common.w"
}
s= p->byte_start;
}
if(q)term_write("...",3);
}

/*:42*//*43:*/
#line 776 "common.w"

#line 807 "common.ch"
void sprint_section_name(char*dest,name_pointer p)
#line 781 "common.w"
{
#line 814 "common.ch"
char HUGE*ss;
char HUGE*s= first_chunk(p);
#line 783 "common.w"
name_pointer q= p+1;
while(p!=name_dir){
ss= (p+1)->byte_start-1;
if(*ss==' '&&ss>=s){
p= q->link;q= p;
}else{
ss++;p= name_dir;
}
#line 822 "common.ch"
strncpy(dest,s,(size_t)(ss-s)),dest+= ss-s;
#line 792 "common.w"
s= p->byte_start;
}
*dest= '\0';
}

/*:43*//*44:*/
#line 797 "common.w"

#line 831 "common.ch"
void print_prefix_name(name_pointer p)
#line 801 "common.w"
{
#line 838 "common.ch"
char HUGE*s= first_chunk(p);
#line 803 "common.w"
int l= prefix_length(p);
term_write(s,l);
if(s+l<(p+1)->byte_start)term_write("...",3);
}

/*:44*//*45:*/
#line 818 "common.w"

#line 849 "common.ch"
static int web_strcmp(
char HUGE*j,
int j_len,
char HUGE*k,
int k_len)
{
char HUGE*j1= j+j_len;
char HUGE*k1= k+k_len;
#line 824 "common.w"
while(k<k1&&j<j1&&*j==*k)k++,j++;
if(k==k1)if(j==j1)return equal;
else return extension;
else if(j==j1)return prefix;
else if(*j<*k)return less;
else return greater;
}

/*:45*//*47:*/
#line 848 "common.w"

#line 878 "common.ch"
name_pointer add_section_name(
name_pointer par,
int c,
char*first,
char*last,
int ispref)
#line 856 "common.w"
{
name_pointer p= name_ptr;
#line 893 "common.ch"
char HUGE*s= first_chunk(p);
int name_len= (int)(last-first)+ispref;
if(s+name_len>byte_mem_end)overflow(get_string(MSG_OVERFLOW_CO39_1));
if(name_ptr+1>=name_dir_end)overflow(get_string(MSG_OVERFLOW_CO39_2));
#line 862 "common.w"
(++name_ptr)->byte_start= byte_ptr= s+name_len;
if(ispref){
*(byte_ptr-1)= ' ';
name_len--;
name_ptr->link= name_dir;
(++name_ptr)->byte_start= byte_ptr;
}
set_prefix_length(p,name_len);
strncpy(s,first,name_len);
p->llink= NULL;
p->rlink= NULL;
init_node(p);
return par==NULL?(root= p):c==less?(par->llink= p):(par->rlink= p);
}

/*:47*//*48:*/
#line 877 "common.w"

#line 908 "common.ch"
void extend_section_name(
name_pointer p,
char*first,
char*last,
int ispref)
#line 884 "common.w"
{
#line 922 "common.ch"
char HUGE*s;
name_pointer q= p+1;
int name_len= (int)(last-first)+ispref;
if(name_ptr>=name_dir_end)overflow(get_string(MSG_OVERFLOW_CO39_2));
#line 889 "common.w"
while(q->link!=name_dir)q= q->link;
q->link= name_ptr;
s= name_ptr->byte_start;
name_ptr->link= name_dir;
#line 932 "common.ch"
if(s+name_len>byte_mem_end)overflow(get_string(MSG_OVERFLOW_CO39_1));
#line 894 "common.w"
(++name_ptr)->byte_start= byte_ptr= s+name_len;
strncpy(s,first,name_len);
if(ispref)*(byte_ptr-1)= ' ';
}

/*:48*//*49:*/
#line 905 "common.w"

#line 942 "common.ch"
name_pointer section_lookup(
char*first,char*last,
int ispref)
#line 910 "common.w"
{
int c= 0;
name_pointer p= root;
name_pointer q= NULL;
name_pointer r= NULL;
name_pointer par= NULL;

#line 951 "common.ch"
int name_len= (int)(last-first)+1;
#line 918 "common.w"
/*50:*/
#line 929 "common.w"

while(p){
c= web_strcmp(first,name_len,first_chunk(p),prefix_length(p));
if(c==less||c==greater){
if(r==NULL)
par= p;
p= (c==less?p->llink:p->rlink);
}else{
if(r!=NULL){
#line 961 "common.ch"
printf(get_string(MSG_ERROR_CO50_1));

print_prefix_name(p);
printf(get_string(MSG_ERROR_CO50_2));
#line 942 "common.w"
print_prefix_name(r);
err_print(">");
return name_dir;
}
r= p;
p= p->llink;
q= r->rlink;
}
if(p==NULL)
p= q,q= NULL;
}

/*:50*/
#line 919 "common.w"
;
/*51:*/
#line 954 "common.w"

if(r==NULL)
return add_section_name(par,c,first,last+1,ispref);

/*:51*/
#line 920 "common.w"
;
/*52:*/
#line 962 "common.w"

switch(section_name_cmp(&first,name_len,r)){

case prefix:
if(!ispref){
#line 971 "common.ch"
printf(get_string(MSG_ERROR_CO52_1));
#line 968 "common.w"

print_section_name(r);
err_print(">");
}
else if(name_len<prefix_length(r))set_prefix_length(r,name_len);

case equal:return r;
case extension:if(!ispref||first<=last)
extend_section_name(r,first,last+1,ispref);
return r;
case bad_extension:
#line 978 "common.ch"
printf(get_string(MSG_ERROR_CO52_2));
#line 980 "common.w"

print_section_name(r);
err_print(">");
return r;
default:
#line 988 "common.ch"
printf(get_string(MSG_ERROR_CO52_3));

print_prefix_name(r);
printf(get_string(MSG_ERROR_CO52_4));
#line 989 "common.w"
print_section_name(r);
err_print(">");
return r;
}

/*:52*/
#line 921 "common.w"
;
}

/*:49*//*54:*/
#line 1013 "common.w"

#line 1010 "common.ch"
static int section_name_cmp(
char**pfirst,
int len,
name_pointer r)
#line 1018 "common.w"
{
char*first= *pfirst;
name_pointer q= r+1;
#line 1020 "common.ch"
char HUGE*ss;
char HUGE*s= first_chunk(r);
#line 1022 "common.w"
int c;
int ispref;
while(1){
ss= (r+1)->byte_start-1;
if(*ss==' '&&ss>=r->byte_start)ispref= 1,q= q->link;
else ispref= 0,ss++,q= name_dir;
switch(c= web_strcmp(first,len,s,ss-s)){
case equal:if(q==name_dir)
if(ispref){
#line 1028 "common.ch"
*pfirst= first+(ptrdiff_t)(ss-s);
#line 1032 "common.w"
return extension;
}else return equal;
else return(q->byte_start==(q+1)->byte_start)?equal:prefix;
case extension:
if(!ispref)return bad_extension;
first+= ss-s;
#line 1035 "common.ch"
if(q!=name_dir){len-= (int)(ss-s);s= q->byte_start;r= q;continue;}
#line 1039 "common.w"
*pfirst= first;return extension;
default:return c;
}
}
}

/*:54*//*58:*/
#line 1062 "common.ch"

void err_print(char*s)
#line 1092 "common.w"
{
char*k,*l;
printf(*s=='!'?"\n%s":"%s",s);
if(web_file_open)/*59:*/
#line 1108 "common.w"

#line 1073 "common.ch"
{if(changing&&include_depth==change_depth)
/*102:*/
#line 1853 "common.ch"
{
printf(get_string(MSG_ERROR_CO59_1),change_line);
#ifdef _AMIGA
if(send_error_messages){

if(GetCurrentDirName(cur_buffer,BUFSIZ)&&
AddPart(cur_buffer,web_file_name,BUFSIZ)&&

GetCurrentDirName(pth_buffer,BUFSIZ)&&
AddPart(pth_buffer,change_file_name,BUFSIZ))

sprintf(msg_string,"newmsg \"%s\" \"%s\" %d 0 \"\" 0 Error 997 %s",
cur_buffer,pth_buffer,change_line,s);

else strcpy(msg_string,"\0");
}
#endif
}

/*:102*/
#line 1074 "common.ch"

else if(include_depth==0)
/*103:*/
#line 1876 "common.ch"
{
printf(get_string(MSG_ERROR_CO59_2),cur_line);
#ifdef _AMIGA
if(send_error_messages){

if(GetCurrentDirName(cur_buffer,BUFSIZ)&&
AddPart(cur_buffer,cur_file_name,BUFSIZ))

sprintf(msg_string,"newmsg \"%s\" \"%s\" %d 0 \"\" 0 Error 998 %s",
cur_buffer,cur_buffer,cur_line,s);

else strcpy(msg_string,"\0");
}
#endif
}

/*:103*/
#line 1076 "common.ch"

else
/*104:*/
#line 1897 "common.ch"
{
printf(get_string(MSG_ERROR_CO59_3),cur_line,cur_file_name);
#ifdef _AMIGA
if(send_error_messages){

if(GetCurrentDirName(cur_buffer,BUFSIZ)&&
AddPart(cur_buffer,cur_file_name,BUFSIZ)&&

GetCurrentDirName(pth_buffer,BUFSIZ)&&
AddPart(pth_buffer,web_file_name,BUFSIZ))

sprintf(msg_string,"newmsg \"%s\" \"%s\" %d 0 \"\" 0 Error 999 %s",
pth_buffer,cur_buffer,cur_line,s);

else strcpy(msg_string,"\0");
}
#endif
}

/*:104*/
#line 1078 "common.ch"


#ifdef _AMIGA
/*105:*/
#line 1921 "common.ch"

if(send_error_messages&&msg_string)
call_rexx(msg_string,&result);

/*:105*/
#line 1081 "common.ch"

#endif
#line 1113 "common.w"
 l= (loc>=limit?limit:loc);
if(l>buffer){
for(k= buffer;k<l;k++)
if(*k=='\t')putchar(' ');
else putchar(*k);
putchar('\n');
for(k= buffer;k<l;k++)putchar(' ');
}
for(k= l;k<limit;k++)putchar(*k);
if(*limit=='|')putchar('|');
putchar(' ');
}

/*:59*/
#line 1095 "common.w"
;
update_terminal;mark_error;
}

/*:58*//*61:*/
#line 1132 "common.ch"

#ifdef __TURBOC__
int wrap_up(void){
int return_val;

putchar('\n');
if(show_stats)print_stats();
/*62:*/
#line 1153 "common.w"

switch(history){
#line 1177 "common.ch"
case spotless:
if(show_happiness)printf(get_string(MSG_HAPPINESS_CO62));break;
case harmless_message:
printf(get_string(MSG_WARNING_CO62));break;
case error_message:
printf(get_string(MSG_ERROR_CO62));break;
case fatal_message:
printf(get_string(MSG_FATAL_CO62));
#line 1161 "common.w"
}

/*:62*/
#line 1139 "common.ch"
;
/*92:*/
#line 1611 "common.ch"

if(C_file)fclose(C_file);
if(tex_file)fclose(tex_file);
if(check_file)fclose(check_file);
if(check_file_name)
remove(check_file_name);

/*:92*/
#line 1140 "common.ch"

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
if(show_stats)print_stats();
/*62:*/
#line 1153 "common.w"

switch(history){
#line 1177 "common.ch"
case spotless:
if(show_happiness)printf(get_string(MSG_HAPPINESS_CO62));break;
case harmless_message:
printf(get_string(MSG_WARNING_CO62));break;
case error_message:
printf(get_string(MSG_ERROR_CO62));break;
case fatal_message:
printf(get_string(MSG_FATAL_CO62));
#line 1161 "common.w"
}

/*:62*/
#line 1153 "common.ch"
;
#ifdef _AMIGA
/*95:*/
#line 1666 "common.ch"

if(LocaleBase){
CloseCatalog(catalog);
CloseLibrary(LocaleBase);
}

/*:95*/
#line 1155 "common.ch"
;
#endif
/*92:*/
#line 1611 "common.ch"

if(C_file)fclose(C_file);
if(tex_file)fclose(tex_file);
if(check_file)fclose(check_file);
if(check_file_name)
remove(check_file_name);

/*:92*/
#line 1157 "common.ch"

switch(history){
case harmless_message:return(RETURN_WARN);break;
case error_message:return(RETURN_ERROR);break;
case fatal_message:return(RETURN_FAIL);break;
default:return(RETURN_OK);
}
}
#endif
#line 1152 "common.w"

/*:61*//*64:*/
#line 1203 "common.ch"
void fatal(char*s,char*t)
#line 1175 "common.w"
{
if(*s)printf(s);
err_print(t);
history= fatal_message;exit(wrap_up());
}

/*:64*//*65:*/
#line 1212 "common.ch"
void overflow(char*t)
#line 1186 "common.w"
{
#line 1219 "common.ch"
printf(get_string(MSG_FATAL_CO65),t);fatal("","");
#line 1188 "common.w"
}


/*:65*//*70:*/
#line 1247 "common.w"

#line 1333 "common.ch"
static void scan_args(void)
#line 1250 "common.w"
{
char*dot_pos;
char*name_pos;
register char*s;
boolean found_web= 0,found_change= 0,found_out= 0;

boolean flag_change;

while(--argc>0){
if((**(++argv)=='-'||**argv=='+')&&*(*argv+1))/*74:*/
#line 1341 "common.w"

{
if(**argv=='-')flag_change= 0;
else flag_change= 1;
#line 1377 "common.ch"
for(dot_pos= *argv+1;*dot_pos>'\0';dot_pos++)
if(*dot_pos=='l'){
use_language= ++dot_pos;
break;
}
else
flags[*dot_pos]= flag_change;

#line 1347 "common.w"
}

#line 1402 "common.ch"
/*:74*/
#line 1259 "common.w"

else{
s= name_pos= *argv;dot_pos= NULL;
#line 1344 "common.ch"
while(*s){
if(*s=='.')dot_pos= s++;
else if(*s==DIR_SEPARATOR||*s==DEVICE_SEPARATOR||*s=='/')
dot_pos= NULL,name_pos= ++s;
else s++;
}

#line 1267 "common.w"
if(!found_web)/*71:*/
#line 1285 "common.w"

{
if(s-*argv>max_file_name_length-5)
/*76:*/
#line 1422 "common.ch"
fatal(get_string(MSG_FATAL_CO76),*argv);
#line 1362 "common.w"


/*:76*/
#line 1288 "common.w"
;
if(dot_pos==NULL)
sprintf(web_file_name,"%s.w",*argv);
else{
strcpy(web_file_name,*argv);
*dot_pos= 0;
}
sprintf(alt_web_file_name,"%s.web",*argv);
sprintf(tex_file_name,"%s.tex",name_pos);
sprintf(idx_file_name,"%s.idx",name_pos);
sprintf(scn_file_name,"%s.scn",name_pos);
sprintf(C_file_name,"%s.c",name_pos);
found_web= 1;
}

/*:71*/
#line 1268 "common.w"

else if(!found_change)/*72:*/
#line 1303 "common.w"

{
if(strcmp(*argv,"-")==0)found_change= -1;
else{
if(s-*argv>max_file_name_length-4)
/*76:*/
#line 1422 "common.ch"
fatal(get_string(MSG_FATAL_CO76),*argv);
#line 1362 "common.w"


/*:76*/
#line 1308 "common.w"
;
if(dot_pos==NULL)
sprintf(change_file_name,"%s.ch",*argv);
else strcpy(change_file_name,*argv);
found_change= 1;
}
}

/*:72*/
#line 1269 "common.w"

else if(!found_out)/*73:*/
#line 1316 "common.w"

{
if(s-*argv>max_file_name_length-5)
/*76:*/
#line 1422 "common.ch"
fatal(get_string(MSG_FATAL_CO76),*argv);
#line 1362 "common.w"


/*:76*/
#line 1319 "common.w"
;
if(dot_pos==NULL){
sprintf(tex_file_name,"%s.tex",*argv);
sprintf(idx_file_name,"%s.idx",*argv);
sprintf(scn_file_name,"%s.scn",*argv);
sprintf(C_file_name,"%s.c",*argv);
}else{
strcpy(tex_file_name,*argv);
if(flags['x']){
if(program==cweave&&strcmp(*argv+strlen(*argv)-4,".tex")!=0)
#line 1369 "common.ch"
fatal(get_string(MSG_FATAL_CO73),*argv);
#line 1330 "common.w"

strcpy(idx_file_name,*argv);
strcpy(idx_file_name+strlen(*argv)-4,".idx");
strcpy(scn_file_name,*argv);
strcpy(scn_file_name+strlen(*argv)-4,".scn");
}
strcpy(C_file_name,*argv);
}
found_out= 1;
}

/*:73*/
#line 1270 "common.w"

else/*75:*/
#line 1402 "common.ch"

{
#ifdef _AMIGA
if(program==ctangle)
fatal(get_string(MSG_FATAL_CO75_1),"");
else fatal(get_string(MSG_FATAL_CO75_3),"");
#else
if(program==ctangle)
fatal(get_string(MSG_FATAL_CO75_2),"");
else fatal(get_string(MSG_FATAL_CO75_4),"");
#endif
}


#line 1360 "common.w"

#line 1422 "common.ch"
/*:75*/
#line 1271 "common.w"
;
}
}
if(!found_web)/*75:*/
#line 1402 "common.ch"

{
#ifdef _AMIGA
if(program==ctangle)
fatal(get_string(MSG_FATAL_CO75_1),"");
else fatal(get_string(MSG_FATAL_CO75_3),"");
#else
if(program==ctangle)
fatal(get_string(MSG_FATAL_CO75_2),"");
else fatal(get_string(MSG_FATAL_CO75_4),"");
#endif
}


#line 1360 "common.w"

#line 1422 "common.ch"
/*:75*/
#line 1274 "common.w"
;
#line 1357 "common.ch"
#ifdef _DEV_NULL
if(found_change<=0)strcpy(change_file_name,_DEV_NULL);
#else
if(found_change<=0)strcpy(change_file_name,"/dev/null");
#endif

#line 1276 "common.w"
}

/*:70*//*82:*/
#line 1497 "common.ch"

static boolean set_path(char*default_path,char*environment)
{
char string[max_path_length+2];

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

/*:82*//*86:*/
#line 1558 "common.ch"

#ifdef __TURBOC__
void far*allocsafe(unsigned long nunits,unsigned long unitsz)
{
void far*p= farcalloc(nunits,unitsz);
if(p==NULL)fatal("",get_string(MSG_FATAL_CO85));

return p;
}
#endif


/*:86*//*90:*/
#line 1601 "common.ch"

void catch_break(int dummy)
{
history= fatal_message;
exit(wrap_up());
}

/*:90*//*98:*/
#line 1714 "common.ch"

#ifdef _AMIGA
static int PutRexxMsg(struct MsgPort*mp,long action,
STRPTR arg0,struct RexxMsg*arg1)
{
if((rm= CreateRexxMsg(mp,(unsigned char*)RXEXTENS,
(unsigned char*)mp->mp_Node.ln_Name))!=NULL){
rm->rm_Action= action;
rm->rm_Args[0]= arg0;
rm->rm_Args[1]= (STRPTR)arg1;

Forbid();
if((rp= FindPort((unsigned char*)MSGPORT))!=NULL)
PutMsg(rp,(struct Message*)rm);
Permit();

if(rp==NULL)
DeleteRexxMsg(rm);
}
return(rm!=NULL&&rp!=NULL);
}
#endif

/*:98*//*99:*/
#line 1742 "common.ch"

#ifdef _AMIGA
int __stdargs call_rexx(char*str,long*result)
{
char*arg;
struct MsgPort*mp;
struct RexxMsg*rm,*rm2;
int ret= FALSE;
int pend;

if(!(RexxSysBase= OpenLibrary((unsigned char*)RXSNAME,0L)))
return(ret);

Forbid();
if(FindPort((unsigned char*)PORTNAME)==NULL)
mp= CreatePort(PORTNAME,0L);
Permit();

if(mp!=NULL){
if((arg= (char*)CreateArgstring(
(unsigned char*)str,strlen(str)))!=NULL){
if(PutRexxMsg(mp,RXCOMM|RXFF_STRING,arg,NULL)){
for(pend= 1;pend!=0;)
if(WaitPort(mp)!=NULL)
while((rm= (struct RexxMsg*)GetMsg(mp))!=NULL)
if(rm->rm_Node.mn_Node.ln_Type==NT_REPLYMSG){
ret= TRUE;
*result= rm->rm_Result1;
if((rm2= (struct RexxMsg*)rm->rm_Args[1])!=NULL){
rm2->rm_Result1= rm->rm_Result1;
rm2->rm_Result2= 0;
ReplyMsg((struct Message*)rm2);
}
DeleteRexxMsg(rm);
pend--;
}
else{
rm->rm_Result2= 0;
if(PutRexxMsg(mp,rm->rm_Action,rm->rm_Args[0],rm))
pend++;
else{
rm->rm_Result1= RETURN_FAIL;
ReplyMsg((struct Message*)rm);
}
}
}
DeleteArgstring((unsigned char*)arg);
}
DeletePort(mp);
}

CloseLibrary((struct Library*)RexxSysBase);

return(ret);
}
#endif

/*:99*/
