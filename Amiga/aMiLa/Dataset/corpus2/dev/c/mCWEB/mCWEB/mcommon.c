/*1:*/
#line 63 "mcommon.w"

/*7:*/
#line 120 "mcommon.w"

#include <ctype.h>

/*:7*//*10:*/
#line 183 "mcommon.w"

#include <stdio.h>

/*:10*//*24:*/
#line 492 "mcommon.w"

#include <stdlib.h> 

/*:24*/
#line 64 "mcommon.w"

#define mcommon_c
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

#define buf_size 256
#define longest_name 1000
#define long_buf_size (buf_size+longest_name) 
#define xisspace(c) (isspace(c) &&((unsigned char) c<0200) ) 
#define xisupper(c) (isupper(c) &&((unsigned char) c<0200) )  \

#define max_include_depth 10 \

#define max_file_name_length 128
#define cur_file file[include_depth]
#define cur_file_name file_name[include_depth]
#define cur_line line[include_depth]
#define web_file file[0]
#define web_file_name file_name[0] \

#define lines_dont_match (change_limit-change_buffer!=limit-buffer|| \
strncmp(buffer,change_buffer,limit-buffer) )  \

#define if_section_start_make_pending(b) {*limit= '!'; \
for(loc= buffer;xisspace(*loc) ;loc++) ; \
*limit= ' '; \
if(*loc=='@'&&(xisspace(*(loc+1) ) ||*(loc+1) =='*') ) change_pending= b; \
} \

#define max_sections 2000 \
 \

#define too_long() {include_depth--; \
err_print("! Include file name too long") ;goto restart;} \

#define max_bytes 90000 \

#define max_names 10000 \
 \

#define length(c) (c+1) ->byte_start-(c) ->byte_start
#define print_id(c) term_write((c) ->byte_start,length((c) ) )  \

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

#define confusion(s) fatal("! This can't happen: ",s)  \
 \

#define show_banner flags['b']
#define show_progress flags['p']
#define show_stats flags['s']
#define show_happiness flags['h'] \

#define update_terminal fflush(stdout)  \

#define new_line putchar('\n') 
#define putxchar putchar
#define term_write(a,b) fflush(stdout) ,fwrite(a,sizeof(char) ,b,stdout) 
#define C_printf(c,a) fprintf(C_file,c,a) 
#define C_putc(c) putc(c,C_file)  \


#line 65 "mcommon.w"

/*2:*/
#line 78 "mcommon.w"

typedef short boolean;
boolean program;

/*:2*//*9:*/
#line 177 "mcommon.w"

char buffer[long_buf_size];
char*buffer_end= buffer+buf_size-2;
char*limit= buffer;
char*loc= buffer;

/*:9*//*12:*/
#line 232 "mcommon.w"

int include_depth;
FILE*file[max_include_depth];
FILE*change_file;
char file_name[max_include_depth][max_file_name_length];

char change_file_name[max_file_name_length];
char alt_web_file_name[max_file_name_length];
int line[max_include_depth];
int change_line;
int change_depth;
boolean input_has_ended;
boolean changing;
boolean web_file_open= 0;
FILE*rep_file;

/*:12*//*22:*/
#line 437 "mcommon.w"

typedef unsigned short sixteen_bits;
sixteen_bits section_count;
boolean changed_section[max_sections];
boolean change_pending;

boolean print_where= 0;

/*:22*//*29:*/
#line 605 "mcommon.w"

char*copy_ptr;
char*copy_end;
boolean copy_from_buffer,copy_to_buffer;
char*rest_after_paste;

/*:29*//*32:*/
#line 668 "mcommon.w"

typedef struct name_info{
char*byte_start;
/*36:*/
#line 705 "mcommon.w"

struct name_info*link;

/*:36*//*45:*/
#line 807 "mcommon.w"

union{
struct name_info*Rlink;

char Ilk;
}dummy;

/*:45*//*60:*/
#line 1142 "mcommon.w"

char*equiv_or_xref;

/*:60*/
#line 671 "mcommon.w"

}name_info;
typedef name_info*name_pointer;
char byte_mem[max_bytes];
char*byte_mem_end= byte_mem+max_bytes-1;
name_info name_dir[max_names];
name_pointer name_dir_end= name_dir+max_names-1;

/*:32*//*34:*/
#line 691 "mcommon.w"

name_pointer name_ptr;
char*byte_ptr;

/*:34*//*37:*/
#line 718 "mcommon.w"

typedef name_pointer*hash_pointer;
name_pointer hash[hash_size];
hash_pointer hash_end= hash+hash_size-1;
hash_pointer h;

/*:37*//*61:*/
#line 1162 "mcommon.w"

int history= spotless;

/*:61*//*63:*/
#line 1176 "mcommon.w"

boolean parsing_exp_file;


/*:63*//*73:*/
#line 1308 "mcommon.w"

int argc;
char**argv;
char C_file_name[max_file_name_length];
char tex_file_name[max_file_name_length];
char idx_file_name[max_file_name_length];
char scn_file_name[max_file_name_length];
boolean flags[128];
char**argv_web,**argv_change,**argv_out;

/*:73*//*81:*/
#line 1461 "mcommon.w"

char mcwebmac_prefix[10];

/*:81*//*85:*/
#line 1488 "mcommon.w"

FILE*C_file;
FILE*tex_file;
FILE*idx_file;
FILE*scn_file;
FILE*active_file;

/*:85*/
#line 66 "mcommon.w"

/*3:*/
#line 10 "mcommon-Amiga.ch"
int phase;
extern int __buffsize= 8192;
#line 89 "mcommon.w"

/*:3*//*13:*/
#line 259 "mcommon.w"

char change_buffer[buf_size];
char*change_limit;

/*:13*/
#line 67 "mcommon.w"

/*5:*/
#line 104 "mcommon.w"

void init_common_ptrs();

/*:5*//*38:*/
#line 724 "mcommon.w"

extern int names_match();

/*:38*//*43:*/
#line 777 "mcommon.w"

void init_p();

/*:43*//*51:*/
#line 929 "mcommon.w"

extern void init_node();

/*:51*//*58:*/
#line 1097 "mcommon.w"

int section_name_cmp();

/*:58*//*62:*/
#line 1172 "mcommon.w"

void err_print();

/*:62*//*66:*/
#line 1228 "mcommon.w"

int wrap_up();
extern void print_stats();

/*:66*//*69:*/
#line 1261 "mcommon.w"

void fatal(),overflow();

/*:69*//*75:*/
#line 1340 "mcommon.w"

void scan_args();

/*:75*//*89:*/
#line 1529 "mcommon.w"

extern int strlen();
extern int strcmp();
extern char*strcpy();
extern int strncmp();
extern char*strncpy();

/*:89*/
#line 68 "mcommon.w"


/*:1*//*4:*/
#line 94 "mcommon.w"

void
common_init()
{
init_common_ptrs();
/*74:*/
#line 1322 "mcommon.w"

show_banner= show_happiness= show_progress= 1;

/*:74*/
#line 99 "mcommon.w"
;
/*86:*/
#line 1495 "mcommon.w"

scan_args();
if(program==ctangle){
if((C_file= fopen(C_file_name,"w"))==NULL)
fatal("! Cannot open output file ",C_file_name);

}
else{
if((tex_file= fopen(tex_file_name,"w"))==NULL)
fatal("! Cannot open output file ",tex_file_name);
}

/*:86*/
#line 100 "mcommon.w"
;
}

/*:4*//*6:*/
#line 109 "mcommon.w"

void
init_common_ptrs()
{
/*35:*/
#line 695 "mcommon.w"

name_dir->byte_start= byte_ptr= byte_mem;
name_ptr= name_dir+1;
name_ptr->byte_start= byte_mem;

/*:35*//*39:*/
#line 729 "mcommon.w"

for(h= hash;h<=hash_end;*h++= NULL);

/*:39*//*46:*/
#line 814 "mcommon.w"

root= NULL;

/*:46*/
#line 113 "mcommon.w"
;
}

/*:6*//*11:*/
#line 190 "mcommon.w"

int input_ln(fp)
FILE*fp;
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

/*:11*//*14:*/
#line 270 "mcommon.w"

void
prime_the_change_buffer()
{
change_limit= change_buffer;
/*15:*/
#line 284 "mcommon.w"

while(1){
change_line++;
if(!input_ln(change_file))return;
if(limit<buffer+2)continue;
if(buffer[0]!='@')continue;
if(xisupper(buffer[1]))buffer[1]= tolower(buffer[1]);
if(buffer[1]=='x')break;
if(buffer[1]=='y'||buffer[1]=='z'||buffer[1]=='i'){
loc= buffer+2;
err_print("! Missing @x in change file");

}
}

/*:15*/
#line 275 "mcommon.w"
;
/*16:*/
#line 301 "mcommon.w"

do{
change_line++;
if(!input_ln(change_file)){
err_print("! Change file ended after @x");

return;
}
}while(limit==buffer);

/*:16*/
#line 276 "mcommon.w"
;
/*17:*/
#line 311 "mcommon.w"

{
change_limit= change_buffer-buffer+limit;
strncpy(change_buffer,buffer,limit-buffer+1);
}

/*:17*/
#line 277 "mcommon.w"
;
}

/*:14*//*18:*/
#line 339 "mcommon.w"

void
check_change()
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
err_print("! Change file ended before @y");

change_limit= change_buffer;changing= 0;
return;
}
if(limit>buffer+1&&buffer[0]=='@'){
if(xisupper(buffer[1]))buffer[1]= tolower(buffer[1]);
/*19:*/
#line 377 "mcommon.w"

if(buffer[1]=='x'||buffer[1]=='z'){
loc= buffer+2;err_print("! Where is the matching @y?");

}
else if(buffer[1]=='y'){
if(n>0){
loc= buffer+2;
printf("\n! Hmm... %d ",n);
err_print("of the preceding lines failed to match");

}
change_depth= include_depth;
return;
}

/*:19*/
#line 361 "mcommon.w"
;
}
/*17:*/
#line 311 "mcommon.w"

{
change_limit= change_buffer-buffer+limit;
strncpy(change_buffer,buffer,limit-buffer+1);
}

/*:17*/
#line 363 "mcommon.w"
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

/*:18*//*20:*/
#line 397 "mcommon.w"

void
reset_input()
{
limit= buffer;loc= buffer+1;buffer[0]= ' ';
/*21:*/
#line 412 "mcommon.w"

if((web_file= fopen(web_file_name,"r"))==NULL){
strcpy(web_file_name,alt_web_file_name);
if((web_file= fopen(web_file_name,"r"))==NULL)
fatal("! Cannot open input file ",web_file_name);
}


web_file_open= 1;
if((change_file= fopen(change_file_name,"r"))==NULL)
fatal("! Cannot open change file ",change_file_name);

/*:21*/
#line 402 "mcommon.w"
;
include_depth= 0;cur_line= 0;change_line= 0;
change_depth= include_depth;
changing= 1;prime_the_change_buffer();changing= !changing;
limit= buffer;loc= buffer+1;buffer[0]= ' ';input_has_ended= 0;
}

/*:20*//*23:*/
#line 445 "mcommon.w"

int get_line()
{
restart:
/*31:*/
#line 633 "mcommon.w"

{
if(copy_from_buffer){
if(copy_ptr>=copy_end)copy_from_buffer= 0;
else{
int len= strlen(copy_ptr);
strcpy(buffer,copy_ptr);
copy_ptr+= len+1;
limit= buffer+len;
if(copy_ptr>=copy_end){
if(rest_after_paste){
strcpy(limit,rest_after_paste);
limit+= strlen(rest_after_paste);
rest_after_paste= NULL;
}
copy_from_buffer= 0;
}
goto got_new_buffer;
}
}
}

/*:31*/
#line 449 "mcommon.w"
;
if(changing&&include_depth==change_depth)
/*27:*/
#line 555 "mcommon.w"
{
change_line++;
if(!input_ln(change_file)){
err_print("! Change file ended without @z");

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
err_print("! Where is the matching @z?");

}
else if(buffer[1]=='z'){
prime_the_change_buffer();changing= !changing;print_where= 1;
}
}
}
}

/*:27*/
#line 451 "mcommon.w"
;
if(!changing||include_depth>change_depth){
/*26:*/
#line 538 "mcommon.w"
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

/*:26*/
#line 453 "mcommon.w"
;
if(changing&&include_depth==change_depth)goto restart;
}
got_new_buffer:
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
/*25:*/
#line 495 "mcommon.w"
{
char temp_file_name[max_file_name_length];
char*cur_file_name_end= cur_file_name+max_file_name_length-1;
char*k= cur_file_name,*kk;
int l;

while(*loc!=' '&&*loc!='\t'&&*loc!='"'&&k<=cur_file_name_end)*k++= *loc++;
if(k>cur_file_name_end)too_long();

*k= '\0';
if((cur_file= fopen(cur_file_name,"r"))!=NULL){
if(rep_file)fprintf(rep_file,"%s\n",cur_file_name);
cur_line= 0;print_where= 1;
goto restart;
}
kk= getenv("CWEBINPUTS");
if(kk!=NULL){
if((l= strlen(kk))>max_file_name_length-2)too_long();
strcpy(temp_file_name,kk);
}
else{
#ifdef CWEBINPUTS
if((l= strlen(CWEBINPUTS))>max_file_name_length-2)too_long();
strcpy(temp_file_name,CWEBINPUTS);
#else
l= 0;
#endif 
}
if(l>0){
if(k+l+2>=cur_file_name_end)too_long();

for(;k>=cur_file_name;k--)*(k+l+1)= *k;
strcpy(cur_file_name,temp_file_name);
cur_file_name[l]= '/';
if((cur_file= fopen(cur_file_name,"r"))!=NULL){
if(rep_file)fprintf(rep_file,"%s\n",cur_file_name);
cur_line= 0;print_where= 1;
goto restart;
}
}
include_depth--;err_print("! Cannot open include file");goto restart;
}

/*:25*/
#line 472 "mcommon.w"
;
}
/*30:*/
#line 615 "mcommon.w"

{
if(copy_to_buffer){
int len= limit-buffer;
if(copy_ptr+len+1>=copy_end)overflow("copy buffer");
memcpy(copy_ptr,buffer,len);
copy_ptr[len++]= 0;
copy_ptr+= len;
}
}

/*:30*/
#line 474 "mcommon.w"
;
return(!input_has_ended);
}

/*:23*//*28:*/
#line 587 "mcommon.w"

void
check_complete(){
if(change_limit!=change_buffer){
strncpy(buffer,change_buffer,change_limit-change_buffer+1);
limit= buffer+(int)(change_limit-change_buffer);
changing= 1;change_depth= include_depth;loc= buffer;
err_print("! Change file entry did not match");

}
}

/*:28*//*40:*/
#line 734 "mcommon.w"

name_pointer
id_lookup(first,last,t)
char*first;
char*last;
char t;
{
char*i= first;
int h;
int l;
name_pointer p;
if(last==NULL)for(last= first;*last!='\0';last++);
l= last-first;
/*41:*/
#line 757 "mcommon.w"

h= (unsigned char)*i;
while(++i<last)h= (h+h+(int)((unsigned char)*i))%hash_size;


/*:41*/
#line 747 "mcommon.w"
;
/*42:*/
#line 765 "mcommon.w"

p= hash[h];
while(p&&!names_match(p,first,l,t))p= p->link;
if(p==NULL){
p= name_ptr;
p->link= hash[h];hash[h]= p;
}

/*:42*/
#line 748 "mcommon.w"
;
if(p==name_ptr)/*44:*/
#line 780 "mcommon.w"
{
if(byte_ptr+l>byte_mem_end)overflow("byte memory");
if(name_ptr>=name_dir_end)overflow("name");
strncpy(byte_ptr,first,l);
(++name_ptr)->byte_start= byte_ptr+= l;
if(program==cweave){
init_p(p,t);
init_p(name_ptr,0);
}
}

/*:44*/
#line 749 "mcommon.w"
;
return(p);
}

/*:40*//*47:*/
#line 841 "mcommon.w"

void
print_section_name(p)
name_pointer p;
{
char*ss,*s= first_chunk(p);
name_pointer q= p+1;
while(p!=name_dir){
ss= (p+1)->byte_start-1;
if(*ss==' '&&ss>=s){
term_write(s,ss-s);p= q->link;q= p;
}else{
term_write(s,ss+1-s);p= name_dir;q= NULL;
}
s= p->byte_start;
}
if(q)term_write("...",3);
}

/*:47*//*48:*/
#line 860 "mcommon.w"

void
sprint_section_name(dest,p)
char*dest;
name_pointer p;
{
char*ss,*s= first_chunk(p);
name_pointer q= p+1;
while(p!=name_dir){
ss= (p+1)->byte_start-1;
if(*ss==' '&&ss>=s){
p= q->link;q= p;
}else{
ss++;p= name_dir;
}
strncpy(dest,s,ss-s),dest+= ss-s;
s= p->byte_start;
}
*dest= '\0';
}

/*:48*//*49:*/
#line 881 "mcommon.w"

void
print_prefix_name(p)
name_pointer p;
{
char*s= first_chunk(p);
int l= prefix_length(p);
term_write(s,l);
if(s+l<(p+1)->byte_start)term_write("...",3);
}

/*:49*//*50:*/
#line 902 "mcommon.w"

int web_strcmp(j,j_len,k,k_len)
char*j,*k;
int j_len,k_len;
{
char*j1= j+j_len,*k1= k+k_len;
while(k<k1&&j<j1&&*j==*k)k++,j++;
if(k==k1)if(j==j1)return equal;
else return extension;
else if(j==j1)return prefix;
else if(*j<*k)return less;
else return greater;
}

/*:50*//*52:*/
#line 932 "mcommon.w"

name_pointer
add_section_name(par,c,first,last,ispref)
name_pointer par;
int c;
char*first;
char*last;
int ispref;
{
name_pointer p= name_ptr;
char*s= first_chunk(p);
int name_len= last-first+ispref;
if(s+name_len>byte_mem_end)overflow("byte memory");
if(name_ptr+1>=name_dir_end)overflow("name");
(++name_ptr)->byte_start= byte_ptr= s+name_len;
if(program==cweave)init_p(name_ptr,0);
if(ispref){
*(byte_ptr-1)= ' ';
name_len--;
name_ptr->link= name_dir;
(++name_ptr)->byte_start= byte_ptr;
if(program==cweave)init_p(name_ptr,0);
}
set_prefix_length(p,name_len);
strncpy(s,first,name_len);
p->llink= NULL;
p->rlink= NULL;
init_node(p);
return par==NULL?(root= p):c==less?(par->llink= p):(par->rlink= p);
}

/*:52*//*53:*/
#line 963 "mcommon.w"

void
extend_section_name(p,first,last,ispref)
name_pointer p;
char*first;
char*last;
int ispref;
{
char*s;
name_pointer q= p+1;
int name_len= last-first+ispref;
if(name_ptr>=name_dir_end)overflow("name");
while(q->link!=name_dir)q= q->link;
q->link= name_ptr;
s= name_ptr->byte_start;
name_ptr->link= name_dir;
if(s+name_len>byte_mem_end)overflow("byte memory");
(++name_ptr)->byte_start= byte_ptr= s+name_len;
if(program==cweave)init_p(name_ptr,0);
strncpy(s,first,name_len);
if(ispref)*(byte_ptr-1)= ' ';
}

/*:53*//*54:*/
#line 992 "mcommon.w"

name_pointer
section_lookup(first,last,ispref)
char*first,*last;
int ispref;
{
int c= 0;
name_pointer p= root;
name_pointer q= NULL;
name_pointer r= NULL;
name_pointer par= NULL;

int name_len= last-first+1;
/*55:*/
#line 1016 "mcommon.w"

while(p){
c= web_strcmp(first,name_len,first_chunk(p),prefix_length(p));
if(c==less||c==greater){
if(r==NULL)
par= p;
p= (c==less?p->llink:p->rlink);
}else{
if(r!=NULL){
printf("\n! Ambiguous prefix: matches <");

print_prefix_name(p);
printf(">\n and <");
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

/*:55*/
#line 1006 "mcommon.w"
;
/*56:*/
#line 1041 "mcommon.w"

if(r==NULL)
return add_section_name(par,c,first,last+1,ispref);

/*:56*/
#line 1007 "mcommon.w"
;
/*57:*/
#line 1049 "mcommon.w"

switch(section_name_cmp(&first,name_len,r)){

case prefix:
if(!ispref){
printf("\n! New name is a prefix of <");

print_section_name(r);
err_print(">");
}
else if(name_len<prefix_length(r))set_prefix_length(r,name_len);

case equal:return r;
case extension:if(!ispref||first<=last)
extend_section_name(r,first,last+1,ispref);
return r;
case bad_extension:
printf("\n! New name extends <");

print_section_name(r);
err_print(">");
return r;
default:
printf("\n! Section name incompatible with <");

print_prefix_name(r);
printf(">,\n which abbreviates <");
print_section_name(r);
err_print(">");
return r;
}

/*:57*/
#line 1008 "mcommon.w"
;
}

/*:54*//*59:*/
#line 1100 "mcommon.w"

int section_name_cmp(pfirst,len,r)
char**pfirst;
int len;
name_pointer r;
{
char*first= *pfirst;
name_pointer q= r+1;
char*ss,*s= first_chunk(r);
int c;
int ispref;
while(1){
ss= (r+1)->byte_start-1;
if(*ss==' '&&ss>=r->byte_start)ispref= 1,q= q->link;
else ispref= 0,ss++,q= name_dir;
switch(c= web_strcmp(first,len,s,ss-s)){
case equal:if(q==name_dir)
if(ispref){
*pfirst= first+(ss-s);
return extension;
}else return equal;
else return(q->byte_start==(q+1)->byte_start)?equal:prefix;
case extension:
if(!ispref)return bad_extension;
first+= ss-s;
if(q!=name_dir){len-= ss-s;s= q->byte_start;r= q;continue;}
*pfirst= first;return extension;
default:return c;
}
}
}

/*:59*//*64:*/
#line 1180 "mcommon.w"

void
err_print(s)
char*s;
{
char*k,*l;
printf(*s=='!'?"\n%s":"%s",s);
if(web_file_open)/*65:*/
#line 1200 "mcommon.w"

{if(changing&&include_depth==change_depth)
printf(". (l. %d of change file)\n",change_line);
else if(include_depth==0){
if(!parsing_exp_file)
printf(". (l. %d)\n",cur_line);
}
else printf(". (l. %d of include file %s)\n",cur_line,cur_file_name);
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

/*:65*/
#line 1187 "mcommon.w"
;
update_terminal;mark_error;
}

/*:64*//*67:*/
#line 1238 "mcommon.w"

int wrap_up(){
putchar('\n');
if(show_stats)
print_stats();
/*68:*/
#line 1248 "mcommon.w"

switch(history){
case spotless:if(show_happiness)printf("(No errors were found.)\n");break;
case harmless_message:
printf("(Did you see the warning message above?)\n");break;
case error_message:
printf("(Pardon me, but I think I spotted something wrong.)\n");break;
case fatal_message:printf("(That was a fatal error, my friend.)\n");
}

/*:68*/
#line 1243 "mcommon.w"
;
if(history>harmless_message)return(1);
else return(0);
}

/*:67*//*70:*/
#line 1267 "mcommon.w"
void
fatal(s,t)
char*s,*t;
{
if(*s)printf(s);
err_print(t);
history= fatal_message;exit(wrap_up());
}

/*:70*//*71:*/
#line 1278 "mcommon.w"
void
overflow(t)
char*t;
{
printf("\n! Sorry, %s capacity exceeded",t);fatal("","");
}


/*:71*//*76:*/
#line 1343 "mcommon.w"

void
scan_args()
{
char*dot_pos;
char*name_pos;
register char*s;
boolean found_web= 0,found_change= 0,found_out= 0;

boolean flag_change,Cxx_seen= 0;

while(--argc>0){
if((**(++argv)=='-'||**argv=='+')&&*(*argv+1))/*80:*/
#line 1443 "mcommon.w"

{
if(**argv=='-')flag_change= 0;
else flag_change= 1;
if(argv[0][1]=='l')/*82:*/
#line 1465 "mcommon.w"

{
strcpy(mcwebmac_prefix,argv[0]+2);
}

/*:82*/
#line 1447 "mcommon.w"

else
for(dot_pos= *argv+1;*dot_pos>'\0';dot_pos++){
if(*dot_pos=='+')Cxx_seen= 1;
flags[*dot_pos]= flag_change;
}
}

/*:80*/
#line 1355 "mcommon.w"

else{
s= name_pos= *argv;dot_pos= NULL;
while(*s){
if(*s=='.')dot_pos= s++;
else if(*s=='/')dot_pos= NULL,name_pos= ++s;
else s++;
}
if(!found_web)/*77:*/
#line 1381 "mcommon.w"

{
if(!argv_web)argv_web= argv;
if(s-*argv>max_file_name_length-5)
/*84:*/
#line 1482 "mcommon.w"
fatal("! Filename too long\n",*argv);


/*:84*/
#line 1385 "mcommon.w"
;
if(dot_pos==NULL)
sprintf(web_file_name,"%s.w",*argv);
else{
if(!Cxx_seen&&(!strcmp(dot_pos,".wpp")||!strcmp(dot_pos,".wxx")))
flags['+']= 1;
strcpy(web_file_name,*argv);
*dot_pos= 0;
}
sprintf(alt_web_file_name,"%s.web",*argv);
sprintf(tex_file_name,"%s.tex",name_pos);
sprintf(idx_file_name,"%s.idx",name_pos);
sprintf(scn_file_name,"%s.scn",name_pos);
sprintf(C_file_name,"%s.c",name_pos);
if(dot_pos)*dot_pos= '.';
found_web= 1;
}

/*:77*/
#line 1364 "mcommon.w"

else if(!found_change)/*78:*/
#line 1403 "mcommon.w"

{
if(!argv_web)argv_change= argv;
if(strcmp(*argv,"-")==0)found_change= -1;
else{
if(s-*argv>max_file_name_length-4)
/*84:*/
#line 1482 "mcommon.w"
fatal("! Filename too long\n",*argv);


/*:84*/
#line 1409 "mcommon.w"
;
if(dot_pos==NULL)
sprintf(change_file_name,"%s.ch",*argv);
else strcpy(change_file_name,*argv);
found_change= 1;
}
}

/*:78*/
#line 1365 "mcommon.w"

else if(!found_out)/*79:*/
#line 1417 "mcommon.w"

{
if(!argv_web)argv_out= argv;
if(s-*argv>max_file_name_length-5)
/*84:*/
#line 1482 "mcommon.w"
fatal("! Filename too long\n",*argv);


/*:84*/
#line 1421 "mcommon.w"
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
fatal("! Output file name should end with .tex\n",*argv);

strcpy(idx_file_name,*argv);
strcpy(idx_file_name+strlen(*argv)-4,".idx");
strcpy(scn_file_name,*argv);
strcpy(scn_file_name+strlen(*argv)-4,".scn");
}
strcpy(C_file_name,*argv);
}
found_out= 1;
}

/*:79*/
#line 1366 "mcommon.w"

else/*83:*/
#line 1470 "mcommon.w"

{
if(program==ctangle)
fatal(
"! Usage: ctangle [options] webfile[.w] [{changefile[.ch]|-} [outfile[.c]]]\n"
,"");

else fatal(
"! Usage: cweave [options] webfile[.w] [{changefile[.ch]|-} [outfile[.tex]]]\n"
,"");
}

/*:83*/
#line 1367 "mcommon.w"
;
}
}
if(!found_web)/*83:*/
#line 1470 "mcommon.w"

{
if(program==ctangle)
fatal(
"! Usage: ctangle [options] webfile[.w] [{changefile[.ch]|-} [outfile[.c]]]\n"
,"");

else fatal(
"! Usage: cweave [options] webfile[.w] [{changefile[.ch]|-} [outfile[.tex]]]\n"
,"");
}

/*:83*/
#line 1370 "mcommon.w"
;
#line 23 "mcommon-Amiga.ch"
if(found_change<=0)strcpy(change_file_name,"nil:");
#line 1372 "mcommon.w"
}

/*:76*/
