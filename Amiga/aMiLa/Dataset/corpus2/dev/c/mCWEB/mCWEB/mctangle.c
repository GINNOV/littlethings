/*1:*/
#line 65 "mctangle.w"

/*8:*/
#line 36 "mcommon.h"

#include <stdio.h>

/*:8*//*52:*/
#line 729 "mctangle.w"

#include <sys/types.h>
#include <sys/stat.h>
#line 18 "mctangle-Amiga.ch"
#include <dos/dos.h>
#line 733 "mctangle.w"


/*:52*//*69:*/
#line 1062 "mctangle.w"

#include <stddef.h>

/*:69*//*86:*/
#line 1333 "mctangle.w"

#include <ctype.h> 
#include <stdlib.h> 

/*:86*//*224:*/
#line 4182 "mctangle.w"

#include <sys/stat.h>

/*:224*/
#line 66 "mctangle.w"

#define mctangle_c
#define banner "This is mCTANGLE (Version 1.1)\n" \

#define max_bytes 90000 \

#define max_toks 270000
#define max_names 10000 \

#define max_texts 2500
#define hash_size 353
#define longest_name 1000
#define stack_size 50
#define buf_size 256 \

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

#define xisalpha(c) (isalpha(c) &&((eight_bits) c<0200) ) 
#define xisdigit(c) (isdigit(c) &&((eight_bits) c<0200) ) 
#define xisspace(c) (isspace(c) &&((eight_bits) c<0200) ) 
#define xislower(c) (islower(c) &&((eight_bits) c<0200) ) 
#define xisupper(c) (isupper(c) &&((eight_bits) c<0200) ) 
#define xisxdigit(c) (isxdigit(c) &&((eight_bits) c<0200) )  \

#define length(c) (c+1) ->byte_start-(c) ->byte_start
#define print_id(c) term_write((c) ->byte_start,length((c) ) ) 
#define llink link
#define rlink dummy.Rlink
#define root name_dir->rlink \

#define chunk_marker 0 \

#define spotless 0
#define harmless_message 1
#define error_message 2
#define fatal_message 3
#define mark_harmless {if(history==spotless) history= harmless_message;}
#define mark_error history= error_message
#define confusion(s) fatal("! This can't happen: ",s)  \

#define max_file_name_length 128
#define cur_file file[include_depth]
#define cur_file_name file_name[include_depth]
#define web_file_name file_name[0]
#define cur_line line[include_depth] \

#define show_banner flags['b']
#define show_progress flags['p']
#define show_happiness flags['h'] \

#define update_terminal fflush(stdout) 
#define new_line putchar('\n') 
#define putxchar putchar
#define term_write(a,b) fflush(stdout) ,fwrite(a,sizeof(char) ,b,stdout) 
#define C_printf(c,a) fprintf(C_file,c,a) 
#define C_putc(c) putc(c,C_file)  \

#define equiv equiv_or_xref \

#define Number(x) (sizeof(x) /sizeof(*(x) ) ) 
#define section_flag max_texts \

#define string 02
#define join 0177
#define output_defs_flag (2*024000-1)  \

#define cur_end cur_state.end_field
#define cur_byte cur_state.byte_field
#define cur_name cur_state.name_field
#define cur_repl cur_state.repl_field
#define cur_section cur_state.section_field \

#define section_number 0201
#define identifier 0202 \

#define normal 0
#define num_or_id 1
#define post_slash 2
#define unbreakable 3
#define verbatim 4 \

#define max_files 256
#define translit_length 10 \

#define ignore 0
#define special_command 0301
#define ord 0302
#define control_text 0303
#define translit_code 0304
#define output_defs_code 0305
#define format_code 0306
#define definition 0307
#define begin_C 0310
#define section_name 0311
#define new_section 0312 \

#define constant 03 \

#define isxalpha(c) ((c) =='_') 
#define ishigh(c) ((unsigned char) (c) >0177)  \
 \

#define compress(c) if(loc++<=limit) return(c)  \

#define macro 0
#define app_repl(c) {if(tok_ptr==tok_mem_end) overflow("token") ;*tok_ptr++= c;} \

#define exp_global 1
#define exp_export 2
#define exp_shared 4
#define max_exports 64
#define forward_types 0
#define types 1
#define declarations 2
#define num_export_sections 3
#define clear_export_sections(s) memset((void*) s,0,sizeof(glb_sec) ) 
#define nobreak 
#define x_new_text_ptr(sec,type) { \
if(also_to_exp_sec) new_text_ptr(exp_sec,type) ; \
new_text_ptr(sec,type) ; \
insert_section_comment() ; \
}
#define max_args 32
#define dep_import_chapter 1
#define dep_from_program_import 2
#define dep_from_library_import 3
#define dep_book_chapter 4
#define dep_import_program 5
#define dep_import_library 6 \

#define max_imports 64
#define max_quoted_name 60
#define longest_name 1000
#define long_buf_size (buf_size+longest_name) 
#define max_include_depth 10
#define no_book 0
#define book_program 1
#define book_library 2
#define max_chapters 64
#define file_name_separator '/'
#define file_name_sep_str "/"
#define max_col 78
#define QUOTE '\"' \


#line 67 "mctangle.w"

/*7:*/
#line 30 "mcommon.h"

typedef short boolean;
typedef char unsigned eight_bits;
extern boolean program;
extern int phase;

/*:7*//*9:*/
#line 58 "mcommon.h"

char section_text[longest_name+1];
char*section_text_end= section_text+longest_name;
char*id_first;
char*id_loc;

/*:9*//*10:*/
#line 73 "mcommon.h"

extern char buffer[];
extern char*buffer_end;
extern char*loc;
extern char*limit;

/*:10*//*11:*/
#line 88 "mcommon.h"

typedef struct name_info{
char*byte_start;
struct name_info*link;
union{
struct name_info*Rlink;

char Ilk;
}dummy;
char*equiv_or_xref;
}name_info;
typedef name_info*name_pointer;
typedef name_pointer*hash_pointer;
extern char byte_mem[];
extern char*byte_mem_end;
extern name_info name_dir[];
extern name_pointer name_dir_end;
extern name_pointer name_ptr;
extern char*byte_ptr;
extern name_pointer hash[];
extern hash_pointer hash_end;
extern hash_pointer h;
extern name_pointer id_lookup();
extern name_pointer section_lookup();
extern void print_section_name(),sprint_section_name();

/*:11*//*12:*/
#line 123 "mcommon.h"

extern history;
extern err_print();
extern wrap_up();
extern void fatal();
extern void overflow();

/*:12*//*13:*/
#line 138 "mcommon.h"

extern include_depth;
extern FILE*file[];
extern FILE*change_file;
extern char C_file_name[];
extern char tex_file_name[];
extern char idx_file_name[];
extern char scn_file_name[];
extern char file_name[][max_file_name_length];

extern char change_file_name[];
extern line[];
extern change_line;
extern boolean input_has_ended;
extern boolean changing;
extern boolean web_file_open;
extern reset_input();
extern get_line();
extern check_complete();

/*:13*//*14:*/
#line 159 "mcommon.h"

typedef unsigned short sixteen_bits;
extern sixteen_bits section_count;
extern boolean changed_section[];
extern boolean change_pending;
extern boolean print_where;

/*:14*//*15:*/
#line 171 "mcommon.h"

extern int argc;
extern char**argv;
extern boolean flags[];

/*:15*//*16:*/
#line 183 "mcommon.h"

extern FILE*C_file;
extern FILE*tex_file;
extern FILE*idx_file;
extern FILE*scn_file;
extern FILE*active_file;

/*:16*//*17:*/
#line 192 "mcommon.h"

extern void common_init();
#line 155 "mctangle.w"

/*:17*/
#line 68 "mctangle.w"

/*18:*/
#line 179 "mctangle.w"

typedef struct{
eight_bits*tok_start;
sixteen_bits text_link;
}text;
typedef text*text_pointer;

#line 10 "mctangle-Amiga.ch"
/*:18*//*31:*/
#line 352 "mctangle.w"

typedef struct{
eight_bits*end_field;
eight_bits*byte_field;
name_pointer name_field;
text_pointer repl_field;
sixteen_bits section_field;
}output_state;
typedef output_state*stack_pointer;

/*:31*//*130:*/
#line 2152 "mctangle.w"

typedef struct{
text_pointer first_text;
text_pointer last_text;
}export_section;

/*:130*//*181:*/
#line 3361 "mctangle.w"

struct make_dep{
struct make_dep*next;
char name[2];
};

/*:181*//*184:*/
#line 3396 "mctangle.w"

struct book_node{
struct book_node*next;
int type;
char name[2];
};

/*:184*/
#line 69 "mctangle.w"

/*19:*/
#line 10 "mctangle-Amiga.ch"

char*version_tag= "\0$VER: mCTANGLE 1.1 (4.10.98)";
text text_info[max_texts];
#line 188 "mctangle.w"
text_pointer text_info_end= text_info+max_texts-1;
text_pointer text_ptr;
eight_bits tok_mem[max_toks];
eight_bits*tok_mem_end= tok_mem+max_toks-1;
eight_bits*tok_ptr;

/*:19*//*25:*/
#line 239 "mctangle.w"

enum{
id_global= 1,id_export,id_shared,
id_chapter,id_transitively,id_import,id_from,id_program,id_library,
id_enum,id_union,id_class,id_struct,id_typedef,id_inline,
id_extern,id_void,id_int,id_static,
id_ifndef,id_endif,id_operator,id_mark,id_copy,id_paste
};
char*predefined_name[]= {
"global","export","shared",
"chapter","transitively","import","from","program","library",
"enum","union","class","struct","typedef","inline",
"extern","void","int","static",
"ifndef","endif","operator","mark","copy","paste"
};

/*:25*//*27:*/
#line 283 "mctangle.w"

text_pointer last_unnamed;

/*:27*//*32:*/
#line 368 "mctangle.w"

output_state cur_state;

output_state stack[stack_size+1];
stack_pointer stack_ptr;
stack_pointer stack_end= stack+stack_size;

/*:32*//*38:*/
#line 464 "mctangle.w"

int cur_val;

/*:38*//*42:*/
#line 553 "mctangle.w"

eight_bits out_state;
boolean protect;

/*:42*//*44:*/
#line 582 "mctangle.w"

name_pointer output_files[max_files];
name_pointer*cur_out_file,*end_output_files,*an_output_file;
char cur_section_name_char;
char output_file_name[longest_name];

/*:44*//*49:*/
#line 657 "mctangle.w"

char Exp_file_name[max_file_name_length];
char Shr_file_name[max_file_name_length];
FILE*Exp_file;
FILE*Shr_file;
FILE*Code_file;

/*:49*//*57:*/
#line 849 "mctangle.w"

boolean output_defs_seen= 0;
int exp_last_def_section_comment;
int shr_last_def_section_comment;

/*:57*//*66:*/
#line 1023 "mctangle.w"

char file_name_constant[max_file_name_length];
sixteen_bits id_file_name_constant;

/*:66*//*74:*/
#line 1152 "mctangle.w"

char translit[128][translit_length];

/*:74*//*79:*/
#line 1229 "mctangle.w"

eight_bits ccode[256];

/*:79*//*82:*/
#line 1286 "mctangle.w"

boolean comment_continues= 0;

/*:82*//*85:*/
#line 1329 "mctangle.w"

name_pointer cur_section_name;
int no_where;

/*:85*//*99:*/
#line 1643 "mctangle.w"

text_pointer cur_text;
eight_bits next_control;

/*:99*//*107:*/
#line 1828 "mctangle.w"

extern sixteen_bits section_count;

/*:107*//*124:*/
#line 2084 "mctangle.w"

sixteen_bits used_exports;

/*:124*//*126:*/
#line 2102 "mctangle.w"

eight_bits*export_ref[max_exports];
eight_bits export_type[max_exports];
int export_line[max_exports];
char*export_file_name[max_exports];
sixteen_bits export_idx;

/*:126*//*131:*/
#line 2159 "mctangle.w"

export_section glb_sec[num_export_sections];
export_section exp_sec[num_export_sections];
export_section shr_sec[num_export_sections];
export_section var_sec;

/*:131*//*144:*/
#line 2635 "mctangle.w"

boolean also_to_exp_sec;
boolean modify_original_token_list;

/*:144*//*167:*/
#line 3151 "mctangle.w"

char dep_dir[max_file_name_length];

/*:167*//*169:*/
#line 3175 "mctangle.w"

struct dependency_node*dep_head;

/*:169*//*175:*/
#line 3269 "mctangle.w"

FILE*book_dep_file;
char dep_file_name[max_file_name_length];

/*:175*//*182:*/
#line 3368 "mctangle.w"

struct make_dep*ch_make_dep[max_chapters];

/*:182*//*185:*/
#line 3404 "mctangle.w"

struct book_node*books_head;

/*:185*//*191:*/
#line 3605 "mctangle.w"

eight_bits*import_ref[max_imports];
sixteen_bits import_idx;

/*:191*//*204:*/
#line 3820 "mctangle.w"

char book_file_name[max_file_name_length];
char book_name[max_file_name_length];
char chapter_name[max_file_name_length];
extern char change_file_name[max_file_name_length];
char out_file_name[max_file_name_length];
char makefile_name[max_file_name_length];
char book_dir[max_file_name_length];

/*:204*//*205:*/
#line 3833 "mctangle.w"

int chapter_no;
struct dependency_node*chapter_dep_head[max_chapters];
char*ch_C_name[max_chapters];

/*:205*//*209:*/
#line 3932 "mctangle.w"

char*ch_web_name[max_chapters];
char*ch_change_name[max_chapters];
char*ch_out_name[max_chapters];
int n_chapters_remembered;

/*:209*//*225:*/
#line 4186 "mctangle.w"

extern FILE*rep_file;
char rep_file_name[max_file_name_length];

/*:225*//*231:*/
#line 4313 "mctangle.w"

FILE*book_exp_file;
char book_exp_file_name[max_file_name_length];
char a_file_name[max_file_name_length];

/*:231*//*237:*/
#line 4385 "mctangle.w"

FILE*make_file,*tmp_makefile;
int make_col;

/*:237*/
#line 70 "mctangle.w"

/*2:*/
#line 78 "mctangle.w"

extern int strlen();
extern int strcmp();
extern char*strcpy();
extern int strncmp();
extern char*strncpy();
extern char*strrchr();
extern char*strchr();

/*:2*//*4:*/
#line 114 "mctangle.w"

int tangle_file();

/*:4*//*34:*/
#line 386 "mctangle.w"

void set_cur_end();

/*:34*//*47:*/
#line 613 "mctangle.w"

void phase_two();

/*:47*//*53:*/
#line 736 "mctangle.w"

boolean keep_exp_file_if_changed();

/*:53*//*59:*/
#line 860 "mctangle.w"

void output_defs();

/*:59*//*64:*/
#line 984 "mctangle.w"

void write_def();

/*:64*//*71:*/
#line 1089 "mctangle.w"

static void out_char();

/*:71*//*116:*/
#line 1976 "mctangle.w"

void phase_one();

/*:116*//*118:*/
#line 1994 "mctangle.w"

void skip_limbo();

/*:118*//*128:*/
#line 2114 "mctangle.w"

void remember_export();

/*:128*//*133:*/
#line 2174 "mctangle.w"

void
push_export_section();

/*:133*//*137:*/
#line 2229 "mctangle.w"

void process_exports();

/*:137*//*162:*/
#line 3059 "mctangle.w"

void remember_export_line();

/*:162*//*165:*/
#line 3094 "mctangle.w"

void output_export_section();

/*:165*//*168:*/
#line 3166 "mctangle.w"

struct dependency_node{
struct dependency_node*next;
sixteen_bits dep_type;
boolean exported;
eight_bits name[2];
};

/*:168*//*171:*/
#line 3183 "mctangle.w"

static void directly_depending_on();

/*:171*//*180:*/
#line 3352 "mctangle.w"

void create_dependencies();
void add_transitive_deps();
void add_chapter_to_dep();
void add_book_to_dep();

/*:180*//*193:*/
#line 3614 "mctangle.w"

void remember_import();

/*:193*//*195:*/
#line 3628 "mctangle.w"

void process_imports();

/*:195*//*197:*/
#line 3659 "mctangle.w"

static eight_bits*get_quoted_name();

/*:197*//*203:*/
#line 3810 "mctangle.w"

extern char buffer[long_buf_size];
extern char file_name[max_include_depth][max_file_name_length];
extern char alt_web_file_name[max_file_name_length];
extern char**argv_web,**argv_change,**argv_out;

/*:203*//*213:*/
#line 4007 "mctangle.w"

char*strmem();

/*:213*//*217:*/
#line 4037 "mctangle.w"

char*file_name_ext();
char*file_name_part();
void to_parent();

/*:217*//*221:*/
#line 4079 "mctangle.w"

char*get_name();

/*:221*//*229:*/
#line 4281 "mctangle.w"

char*exp_file_name_of();

/*:229*//*234:*/
#line 4353 "mctangle.w"

void chapter_to_book_exp();

/*:234*//*238:*/
#line 4390 "mctangle.w"

void mf_print();

/*:238*/
#line 71 "mctangle.w"


/*:1*//*3:*/
#line 95 "mctangle.w"

int main(ac,av)
int ac;
char**av;
{
argc= ac;argv= av;
program= ctangle;

show_banner= show_happiness= show_progress= 1;
scan_args();
if(show_banner)printf(banner);
argc= ac;argv= av;

/*206:*/
#line 3849 "mctangle.w"

{
int ret_val= 0,len,ch;
char*e,*cp;

e= getenv("DEPDIR");
if(e){
strcpy(dep_dir,e);
strcat(dep_dir,file_name_sep_str);
}
else fatal("! Environment variable not set:","DEPDIR");


/*207:*/
#line 3898 "mctangle.w"

{
char*cp;
FILE*f;
strcpy(a_file_name,*argv_web);
if(!file_name_ext(a_file_name)){
cp= a_file_name+strlen(a_file_name);
strcpy(cp,".prg");
if((f= fopen(a_file_name,"r"))!=NULL){
fclose(f);
strcpy(file_name[0],a_file_name);
}
}
}

/*:207*/
#line 3862 "mctangle.w"
;
len= strlen(file_name[0]);
if(!strcmp(file_name[0]+len-4,".prg")||flags['m']){
change_file= NULL;
reset_input();
strcpy(book_file_name,file_name[0]);
/*215:*/
#line 4023 "mctangle.w"

strcpy(book_dir,book_file_name);
cp= file_name_part(book_dir);
*cp= 0;

/*:215*/
#line 3868 "mctangle.w"
;
/*216:*/
#line 4030 "mctangle.w"

cp= file_name_part(file_name[0]);
strcpy(book_name,cp);
cp= file_name_ext(book_name);
if(cp)*cp= 0;

/*:216*/
#line 3869 "mctangle.w"
;
/*232:*/
#line 4322 "mctangle.w"

{
char*cp;

cp= exp_file_name_of(book_exp_file_name,book_file_name,"._ex");
strcpy(a_file_name,book_exp_file_name);
to_parent(a_file_name);
#line 58 "mctangle-Amiga.ch"
if(!mkdir(a_file_name))
#line 4330 "mctangle.w"
printf("New dependency directory created: %s\n",a_file_name);

book_exp_file= fopen(book_exp_file_name,"w");
if(!book_exp_file)
fatal("! Cannot create export file for book:",book_exp_file_name);

strcpy(a_file_name,cp);
cp= file_name_ext(a_file_name);
if(cp)strcpy(cp,".exp");
for(cp= a_file_name;*cp;cp++)
if(!xisalpha(*cp))*cp++= '_';
fprintf(book_exp_file,"#ifndef %s\n#define %s\n",a_file_name,a_file_name);
}

/*:232*/
#line 3870 "mctangle.w"
;
/*176:*/
#line 3275 "mctangle.w"

{
exp_file_name_of(dep_file_name,file_name[0],".dep");
book_dep_file= fopen(dep_file_name,"w");
if(!book_dep_file)
fatal("! Cannot create dependency file for book:",dep_file_name);

}

/*:176*/
#line 3871 "mctangle.w"
;
if(show_progress)printf("Book '%s'\n",book_name);
/*208:*/
#line 3915 "mctangle.w"

while(get_line()){
while(loc<limit){
if(*loc++=='@'){
switch(*loc++){
case'@':break;
case'c':/*210:*/
#line 3940 "mctangle.w"

{
char*cp;
if(n_chapters_remembered>=max_chapters)
overflow("chapters");
*limit= 0;
cp= get_name(loc,a_file_name);
if(cp){
loc= cp;
ch_web_name[n_chapters_remembered]= strmem(a_file_name);
ch_change_name[n_chapters_remembered]= NULL;
ch_out_name[n_chapters_remembered]= NULL;
cp= get_name(loc,a_file_name);
if(cp){
loc= cp;
ch_change_name[n_chapters_remembered]= strmem(a_file_name);
cp= get_name(loc,a_file_name);
if(cp){
loc= cp;
ch_out_name[n_chapters_remembered]= strmem(a_file_name);
}
}
n_chapters_remembered++;
}
else err_print("! Chapter name expected");

}

/*:210*/
#line 3921 "mctangle.w"
;break;
case'm':/*212:*/
#line 3991 "mctangle.w"

{
*limit= 0;
if(!get_name(loc,makefile_name))
strcpy(makefile_name,"Makefile");
tmp_makefile= tmpfile();
if(!tmp_makefile)fatal("! Cannot create temporary file ","for makefile");

while(get_line()){
*limit= 0;
fprintf(tmp_makefile,"%s\n",buffer);
}
rewind(tmp_makefile);
}

/*:212*/
#line 3922 "mctangle.w"
;break;
default:err_print("! Illegal @ command in book");

}
}
}
}

/*:208*/
#line 3873 "mctangle.w"
;
fclose(file[0]);
if(change_file){
fclose(change_file);
change_file= NULL;
}
/*211:*/
#line 3970 "mctangle.w"

{
char*change_exists,*out_exists;
for(chapter_no= 0;chapter_no<n_chapters_remembered;chapter_no++){
if(show_progress)printf("\nChapter %d:",chapter_no+1);
strcpy(chapter_name,book_dir);
strcat(chapter_name,ch_web_name[chapter_no]);
change_exists= ch_change_name[chapter_no];
if(change_exists)strcpy(change_file_name,change_exists);
out_exists= ch_out_name[chapter_no];
if(out_exists)strcpy(out_file_name,out_exists);
if(show_progress)printf("%s\n",chapter_name);
/*223:*/
#line 4121 "mctangle.w"

{
int i;
char**new_argv,**argv_ptr,*cp;
boolean retranslate;
boolean has_exp_file= 0;

argc= ac;
new_argv= argv= (char**)malloc((argc+3)*sizeof(char*));
if(!argv)fatal("! No memory, cannot tangle ",chapter_name);
for(i= 0;i<argc;i++)argv[i]= av[i];

argv_ptr= argv+(argv_web-av);
*argv_ptr= chapter_name;
if(argv_change)*argv_change= "-";
cp= file_name_part(chapter_name);
if(argv_out)*argv_out= cp;
ch_C_name[chapter_no]= malloc(strlen(cp)+1);
if(!ch_C_name[chapter_no])fatal("! No memory"," for C file name");

strcpy(ch_C_name[chapter_no],cp);
if(change_exists){
if(argv_change)argv_ptr= argv+(argv_change-av);
else argv_ptr= &argv[argc++];
*argv_ptr= change_file_name;
if(out_exists){
if(argv_out)argv_ptr= argv+(argv_out-av);
else argv_ptr= &argv[argc++];
*argv_ptr= out_file_name;
ch_C_name[chapter_no]= realloc(ch_C_name[chapter_no],strlen(out_file_name)+1);
if(!ch_C_name[chapter_no])fatal("! No memory"," for C file name");
strcpy(ch_C_name[chapter_no],out_file_name);
}
}

fprintf(book_dep_file,"%s\n",chapter_name);

/*226:*/
#line 4205 "mctangle.w"

{
char*cp;
struct stat s_C,s;

retranslate= 0;
strcpy(buffer,ch_C_name[chapter_no]);
cp= file_name_ext(buffer);
if(!cp)strcat(buffer,".c");
if(stat(buffer,&s_C))retranslate= 1;
strcpy(buffer,chapter_name);
cp= file_name_ext(buffer);
if(!cp){
cp= buffer+strlen(buffer);
strcat(buffer,".w");
}
if(stat(buffer,&s)){
sprintf(buffer,"%s.web",chapter_name);
if(stat(buffer,&s))
fatal("! Cannot find chapter: %s\n",chapter_name);

}
if(s_C.st_mtime<s.st_mtime)retranslate= 1;
if(cp)*cp= 0;
strcat(buffer,".rep");
cp= file_name_part(buffer);
strcpy(rep_file_name,cp);
rep_file= fopen(rep_file_name,"r");
if(rep_file){
fgets(buffer,sizeof(buffer),rep_file);
cp= strrchr(buffer,'\n');
if(cp)*cp= 0;
if(strcmp(buffer,change_file_name))
retranslate= 1;
#line 52 "mctangle-Amiga.ch"
if(*buffer&&strcmp(buffer,"-")&&strcmp(buffer,"nil:")){
#line 4240 "mctangle.w"

if(stat(buffer,&s))retranslate= 1;
if(s_C.st_mtime<s.st_mtime)retranslate= 1;
}
while(fgets(buffer,sizeof(buffer),rep_file)){
cp= strrchr(buffer,'\n');
if(cp)*cp= 0;
if(!strcmp(buffer,"*")){
has_exp_file= 1;
continue;
}
if(stat(buffer,&s))retranslate= 1;
if(s_C.st_mtime<s.st_mtime)retranslate= 1;
}
fclose(rep_file);
}
else retranslate= 1;
}

/*:226*/
#line 4158 "mctangle.w"
;

history= 0;
if(retranslate){
/*227:*/
#line 4263 "mctangle.w"

{
rep_file= fopen(rep_file_name,"w");
if(!rep_file)fatal("! Cannot open representation file: ",rep_file_name);

fprintf(rep_file,"%s\n",change_file_name);
}

/*:227*/
#line 4162 "mctangle.w"

ret_val|= tangle_file();
/*228:*/
#line 4272 "mctangle.w"

if(rep_file){
if(used_exports&exp_export)
fprintf(rep_file,"*\n");
fclose(rep_file);
rep_file= NULL;
}

/*:228*/
#line 4164 "mctangle.w"
;
}
else{
if(has_exp_file){
char*cp= exp_file_name_of(a_file_name,chapter_name,".exp");
fprintf(book_exp_file,"#include \"%s\"\n",cp);
}
rep_file= NULL;
printf("(Skipped.)\n");
/*178:*/
#line 3315 "mctangle.w"

{
FILE*chapter_dep_file;
int type;
char*cp,exp;

dep_head= NULL;
exp_file_name_of(dep_file_name,chapter_name,".dep");
chapter_dep_file= fopen(dep_file_name,"r");
if(!chapter_dep_file)
err_print("! No dependency file\n");

else{
while(fgets(buffer,sizeof(buffer),chapter_dep_file)){
cp= strchr(buffer,'\n');
if(cp)*cp= 0;
sscanf(buffer,"%c%d",&exp,&type);
cp= strchr(buffer+1,' ');
if(!cp)continue;
cp++;
directly_depending_on(cp,type,exp!=' ');
}
fclose(chapter_dep_file);
}
}

/*:178*/
#line 4173 "mctangle.w"
;
}

/*177:*/
#line 3293 "mctangle.w"

{
FILE*chapter_dep_file;
struct dependency_node*d_node;

exp_file_name_of(dep_file_name,chapter_name,".dep");
chapter_dep_file= fopen(dep_file_name,"w");
if(!chapter_dep_file)
fatal("! Cannot create dependency file for chapter:",dep_file_name);


for(d_node= dep_head;d_node;d_node= d_node->next)
fprintf(chapter_dep_file,"%c%d %s\n",d_node->exported?'*':' ',
d_node->dep_type,d_node->name);

fclose(chapter_dep_file);
chapter_dep_head[chapter_no]= dep_head;
}

/*:177*/
#line 4176 "mctangle.w"
;

free(new_argv);
}

/*:223*/
#line 3982 "mctangle.w"
;
}
}

/*:211*/
#line 3879 "mctangle.w"
;
if(*makefile_name){
if(show_progress)printf("\nMakefile:%s\n",makefile_name);
for(ch= 0;ch<chapter_no;ch++)
create_dependencies(ch);
/*240:*/
#line 4426 "mctangle.w"

{
int i;

make_col= 0;
make_file= fopen(makefile_name,"w");
if(!make_file)fatal("! Cannot create makefile ",makefile_name);

/*241:*/
#line 4445 "mctangle.w"

{
mf_print(NULL,"CHAPTERS=",NULL);
for(i= 0;i<chapter_no;i++)
mf_print(" ",ch_C_name[i],".o");
fprintf(make_file,"\n");
make_col= 0;
}

/*:241*/
#line 4434 "mctangle.w"
;
if(books_head)
/*242:*/
#line 4455 "mctangle.w"

{
struct book_node*bn;
char*cp;

mf_print(NULL,"LIBRARIES=",NULL);
for(bn= books_head;bn;bn= bn->next)
if(bn->type==book_library){
cp= file_name_part(bn->name);
mf_print(" $(LIBPREFIX)",cp,"");
}
fprintf(make_file,"\n");
make_col= 0;
}

/*:242*/
#line 4436 "mctangle.w"
;
/*243:*/
#line 4473 "mctangle.w"

{
struct make_dep*md;
char*cp;

for(i= 0;i<chapter_no;i++){
strcpy(buffer,ch_web_name[i]);
for(cp= buffer;*cp;cp++)
if(!isalnum(*cp))*cp= '_';
else if(islower(*cp))*cp= toupper(*cp);
mf_print(buffer,"=",NULL);
if(strchr(ch_C_name[i],'.'))mf_print(NULL,ch_C_name[i],NULL);
else mf_print(NULL,ch_C_name[i],".c");
for(md= ch_make_dep[i];md;md= md->next)
mf_print(" ",md->name,NULL);
fprintf(make_file,"\n");
make_col= 0;
}
}

/*:243*/
#line 4437 "mctangle.w"
;
while(fgets(buffer,sizeof(buffer),tmp_makefile))
fprintf(make_file,"%s",buffer);
fclose(make_file);
fclose(tmp_makefile);
}

/*:240*/
#line 3884 "mctangle.w"
;
}
if(history>harmless_message)ret_val|= 1;
fclose(book_dep_file);
/*233:*/
#line 4345 "mctangle.w"

{
fprintf(book_exp_file,"#endif\n");
fclose(book_exp_file);
keep_exp_file_if_changed(".exp",book_exp_file_name);
}

/*:233*/
#line 3888 "mctangle.w"
;
if(ret_val)printf("\n(Book not successfully translated.)\n");
else if(show_happiness)printf("\n(Book successfully translated.)\n");
return ret_val;
}
}

/*:206*/
#line 108 "mctangle.w"
;

return tangle_file();
}

/*:3*//*5:*/
#line 120 "mctangle.w"

int
tangle_file()
{
/*20:*/
#line 194 "mctangle.w"

text_info->tok_start= tok_ptr= tok_mem;
text_ptr= text_info+1;text_ptr->tok_start= tok_mem;


/*:20*//*22:*/
#line 204 "mctangle.w"

name_dir->equiv= (char*)text_info;

/*:22*//*28:*/
#line 286 "mctangle.w"
last_unnamed= text_info;text_info->text_link= 0;

/*:28*//*45:*/
#line 592 "mctangle.w"

cur_out_file= end_output_files= output_files+max_files;

/*:45*//*58:*/
#line 855 "mctangle.w"

output_defs_seen= 0;
exp_last_def_section_comment= 0;
shr_last_def_section_comment= 0;

/*:58*//*75:*/
#line 1155 "mctangle.w"

{
int i;
for(i= 0;i<128;i++)sprintf(translit[i],"X%02X",(unsigned)(128+i));
}

/*:75*//*80:*/
#line 1232 "mctangle.w"
{
int c;
for(c= 0;c<256;c++)ccode[c]= ignore;
ccode[' ']= ccode['\t']= ccode['\n']= ccode['\v']= ccode['\r']= ccode['\f']
= ccode['*']= new_section;
ccode['@']= '@';ccode['=']= string;
ccode['d']= ccode['D']= definition;
ccode['f']= ccode['F']= ccode['s']= ccode['S']= format_code;
ccode['c']= ccode['C']= ccode['p']= ccode['P']= begin_C;
ccode['^']= ccode[':']= ccode['.']= ccode['t']= ccode['T']= 
ccode['q']= ccode['Q']= control_text;
ccode['h']= ccode['H']= output_defs_code;
ccode['l']= ccode['L']= translit_code;
ccode['&']= join;
ccode['<']= ccode['(']= section_name;
ccode['\'']= ord;
ccode['_']= special_command;
}

/*:80*//*83:*/
#line 1290 "mctangle.w"

comment_continues= 0;

/*:83*//*95:*/
#line 1564 "mctangle.w"
section_text[0]= ' ';

/*:95*//*125:*/
#line 2088 "mctangle.w"

used_exports= 0;

/*:125*//*127:*/
#line 2110 "mctangle.w"

export_idx= 0;

/*:127*//*132:*/
#line 2167 "mctangle.w"

clear_export_sections(glb_sec);
clear_export_sections(exp_sec);
clear_export_sections(shr_sec);
memset((void*)&var_sec,0,sizeof(var_sec));

/*:132*//*170:*/
#line 3179 "mctangle.w"

dep_head= NULL;

/*:170*//*192:*/
#line 3610 "mctangle.w"

import_idx= 0;

/*:192*/
#line 124 "mctangle.w"
;
common_init();
/*26:*/
#line 257 "mctangle.w"

{
int i;
for(i= 0;i<Number(predefined_name);i++)
id_lookup(predefined_name[i],predefined_name[i]+strlen(predefined_name[i]),0);
}

/*:26*/
#line 126 "mctangle.w"
;
/*67:*/
#line 1040 "mctangle.w"

{
char*cp,*fn;

cp= C_file_name;
fn= file_name_constant;
do{
if(isalnum(*cp))*fn= *cp;
else*fn= '_';
cp++;
fn++;
}while(*cp);
*fn= '\0';
id_file_name_constant= id_lookup(file_name_constant,fn,0)-name_dir;
}

/*:67*/
#line 127 "mctangle.w"
;
phase_one();
phase_two();
return wrap_up();
}

/*:5*//*23:*/
#line 210 "mctangle.w"

int names_match(p,first,l)
name_pointer p;
char*first;
int l;
{
if(length(p)!=l)return 0;
return!strncmp(first,p->byte_start,l);
}

/*:23*//*24:*/
#line 225 "mctangle.w"

void
init_node(node)
name_pointer node;
{
node->equiv= (char*)text_info;
}
void
init_p(){}

/*:24*//*30:*/
#line 316 "mctangle.w"

void
store_two_bytes(x)
sixteen_bits x;
{
if(tok_ptr+2>tok_mem_end)overflow("token");
*tok_ptr++= x>>8;
*tok_ptr++= x&0377;
}

/*:30*//*35:*/
#line 395 "mctangle.w"

void
set_cur_end()
{
text_pointer tp;
for(tp= cur_repl;++tp<=text_ptr;){
if(cur_repl->tok_start!=tp->tok_start){
cur_end= tp->tok_start;
return;
}
}
cur_end= (cur_repl+1)->tok_start;
}

/*:35*//*36:*/
#line 416 "mctangle.w"

void
push_level(p)
name_pointer p;
{
if(stack_ptr==stack_end)overflow("stack");
*stack_ptr= cur_state;
stack_ptr++;
if(p!=NULL){
cur_name= p;cur_repl= (text_pointer)p->equiv;
cur_byte= cur_repl->tok_start;set_cur_end();
cur_section= 0;
}
}

/*:36*//*37:*/
#line 435 "mctangle.w"

void
pop_level(flag)
int flag;
{
if(flag&&cur_repl->text_link<section_flag){
cur_repl= cur_repl->text_link+text_info;
cur_byte= cur_repl->tok_start;set_cur_end();
return;
}
stack_ptr--;
if(stack_ptr>stack)cur_state= *stack_ptr;
}

/*:37*//*39:*/
#line 471 "mctangle.w"

void
get_output()
{
sixteen_bits a;
restart:if(stack_ptr==stack)return;
if(cur_byte==cur_end){
cur_val= -((int)cur_section);
pop_level(1);
if(cur_val==0)goto restart;
out_char(section_number);return;
}
a= *cur_byte++;
if(out_state==verbatim&&a!=string&&a!=constant&&a!='\n')
C_putc(a);
else if(a<0200)out_char(a);
else{
a= (a-0200)*0400+*cur_byte++;
switch(a/024000){
case 0:cur_val= a;out_char(identifier);break;
case 1:if(a==output_defs_flag)output_defs();
else/*40:*/
#line 503 "mctangle.w"

{
a-= 024000;
if((a+name_dir)->equiv!=(char*)text_info)push_level(a+name_dir);
else if(a!=0){
printf("\n! Not present: <");
print_section_name(a+name_dir);err_print(">");

}
goto restart;
}

/*:40*/
#line 492 "mctangle.w"
;
break;
default:cur_val= a-050000;if(cur_val>0)cur_section= cur_val;
out_char(section_number);
}
}
}

/*:39*//*43:*/
#line 561 "mctangle.w"

void
flush_buffer()
{
C_putc('\n');
if(cur_line%100==0&&show_progress){
printf(".");
if(cur_line%500==0)printf("%d",cur_line);
update_terminal;
}
cur_line++;
}

/*:43*//*48:*/
#line 617 "mctangle.w"

void
phase_two(){
web_file_open= 0;
cur_line= 1;
/*33:*/
#line 381 "mctangle.w"

stack_ptr= stack+1;cur_name= name_dir;cur_repl= text_info->text_link+text_info;
cur_byte= cur_repl->tok_start;set_cur_end();cur_section= 0;

/*:33*/
#line 622 "mctangle.w"
;
/*50:*/
#line 670 "mctangle.w"

{
char*cp,*pt,defname[max_file_name_length];
if(used_exports&exp_export){
cp= exp_file_name_of(Exp_file_name,file_name[0],"._ex");
if((Exp_file= fopen(Exp_file_name,"w"))==NULL)
fatal("! Cannot open temporary output file for exports ",Exp_file_name);
fprintf(Exp_file,"/* Book:\"%s\", Chapter %d */\n",book_name,chapter_no+1);
strcpy(defname,cp);
cp= file_name_ext(defname);
if(cp)strcpy(cp,".exp");
for(cp= defname;*cp;cp++)if(!isalnum(*cp))*cp= '_';
fprintf(Exp_file,"#ifndef %s\n#define %s\n",defname,defname);
chapter_to_book_exp();
}
else{
exp_file_name_of(Exp_file_name,file_name[0],".exp");
remove(Exp_file_name);
}
strcpy(Shr_file_name,file_name[0]);
pt= file_name_ext(Shr_file_name);
if(pt)*pt= 0;
if(used_exports&exp_shared){
strcpy(pt,"._sh");
if((Shr_file= fopen(Shr_file_name,"w"))==NULL)
fatal("! Cannot open temporary output file for shared data ",Shr_file_name);

fprintf(Shr_file,"/* Book:\"%s\", Chapter %d */\n",book_name,chapter_no+1);
strcpy(defname,Shr_file_name);
cp= file_name_ext(defname);
if(cp)strcpy(cp,".shr");
for(cp= defname;*cp;cp++)if(!isalnum(*cp))*cp= '_';
fprintf(Shr_file,"#ifndef %s\n#define %s\n",defname,defname);
}
else{
strcpy(pt,".shr");
remove(Shr_file_name);
}
Code_file= C_file;
}

/*:50*/
#line 623 "mctangle.w"
;
/*56:*/
#line 837 "mctangle.w"

if(!output_defs_seen)
output_defs();

/*:56*/
#line 624 "mctangle.w"
;
if(text_info->text_link==0&&cur_out_file==end_output_files){
printf("\n! No program text was specified.");mark_harmless;

}
else{
if(cur_out_file==end_output_files){
if(show_progress)
printf("\nWriting the output file (%s):",C_file_name);
}
else{
if(show_progress){
printf("\nWriting the output files:");

printf(" (%s)",C_file_name);
update_terminal;
}
if(text_info->text_link==0)goto writeloop;
}
while(stack_ptr>stack)get_output();
flush_buffer();
writeloop:/*55:*/
#line 814 "mctangle.w"

for(an_output_file= end_output_files;an_output_file>cur_out_file;){
an_output_file--;
sprint_section_name(output_file_name,*an_output_file);
fclose(C_file);
C_file= fopen(output_file_name,"w");
if(C_file==0)fatal("! Cannot open output file:",output_file_name);

printf("\n(%s)",output_file_name);update_terminal;
cur_line= 1;
stack_ptr= stack+1;
cur_name= (*an_output_file);
cur_repl= (text_pointer)cur_name->equiv;
cur_byte= cur_repl->tok_start;
set_cur_end();
while(stack_ptr>stack)get_output();
flush_buffer();
}

/*:55*/
#line 645 "mctangle.w"
;
/*164:*/
#line 3089 "mctangle.w"

output_export_section(exp_sec,Exp_file,"export");
output_export_section(shr_sec,Shr_file,"shared");

/*:164*/
#line 646 "mctangle.w"
;
if(show_happiness)printf("\nDone.");
}
/*51:*/
#line 714 "mctangle.w"

if(Shr_file){
fprintf(Shr_file,"#endif\n");
fclose(Shr_file);
Shr_file= NULL;
keep_exp_file_if_changed(".shr",Shr_file_name);
}
if(Exp_file){
fprintf(Exp_file,"#endif\n");
fclose(Exp_file);
Exp_file= NULL;
keep_exp_file_if_changed(".exp",Exp_file_name);
}

/*:51*/
#line 649 "mctangle.w"
;
}

/*:48*//*54:*/
#line 763 "mctangle.w"

boolean
keep_exp_file_if_changed(suffix,tmpname)
char*suffix;
char*tmpname;
{
char expname[max_file_name_length],*cp;
FILE*fp,*tmp;
char*c1,*c2;
char buffer[2][128];
#line 25 "mctangle-Amiga.ch"
BPTR lock;
__aligned struct FileInfoBlock fib;
BOOL success;
#line 775 "mctangle.w"

strcpy(expname,tmpname);
cp= file_name_ext(expname);
if(cp)*cp= 0;
strcat(expname,suffix);
buffer[0][sizeof(buffer[0])-1]= buffer[1][sizeof(buffer[0])-1]= '\0';
if((fp= fopen(expname,"r"))!=NULL){
if((tmp= fopen(tmpname,"r"))==NULL)fatal("! Cannot reopen output file for input:",tmpname);

do{
c1= fgets(buffer[0],sizeof(buffer[0])-1,tmp);
c2= fgets(buffer[1],sizeof(buffer[1])-1,fp);
if(c1==NULL||c2==NULL)break;
}while(strcmp(buffer[0],buffer[1])==0||
(strncmp(buffer[0],"#line",5)==0&&strncmp(buffer[1],"#line",5)==0)||
(strncmp(buffer[0],"/*",2)==0&&strncmp(buffer[1],"/*",2)==0));
fclose(tmp);
fclose(fp);
if(c1==NULL&&c2==NULL){
#line 38 "mctangle-Amiga.ch"
if(lock= Lock(expname,ACCESS_READ)){
success= Examine(lock,&fib);
UnLock(lock);
remove(expname);
rename(tmpname,expname);
if(success){
SetFileDate(expname,&fib.fib_Date);
}
}
#line 800 "mctangle.w"
return 0;
}
remove(expname);
}
rename(tmpname,expname);
printf("\nExport file written: %s",expname);

return 1;
}

/*:54*//*60:*/
#line 871 "mctangle.w"

void
output_defs()
{
sixteen_bits where,a;
int line_no;
eight_bits*cp;
char comment[20],*com;

/*68:*/
#line 1057 "mctangle.w"

{
C_printf("#define %s",file_name_constant);flush_buffer();
}

/*:68*/
#line 880 "mctangle.w"
;

push_level(NULL);
for(cur_text= text_info+1;cur_text<text_ptr;cur_text++)
if(cur_text->text_link==0){
cp= cur_text->tok_start;
*comment= 0;
if(!strncmp(cp,"\03/*",3)){
com= comment;
while(*++cp!=constant)*com++= *cp;
*com= 0;
++cp;
}
where= 0;
while(*cp==special_command){
if(*++cp>=0200){
a= ((*cp-0200)<<8)+cp[1];
switch(a){
case id_global:
where|= exp_global;
break;
case id_export:
where|= exp_export;
break;
case id_shared:
where|= exp_shared;
break;
}
cp+= 2;
}
}
if(where&exp_export){
/*61:*/
#line 932 "mctangle.w"

{
line_no= cur_line;
C_file= Exp_file;
if(*comment){
int sec_no;
sscanf(comment+10,"%d",&sec_no);
if(sec_no>exp_last_def_section_comment){
C_printf("%s",comment);
flush_buffer();
exp_last_def_section_comment= sec_no;
}
}
write_def(cp);
cur_line= line_no;
}

/*:61*/
#line 912 "mctangle.w"
;
}
if(where&exp_shared){
/*62:*/
#line 950 "mctangle.w"

{
C_file= Shr_file;
if(*comment){
int sec_no;
sscanf(comment+10,"%d",&sec_no);
if(sec_no>shr_last_def_section_comment){
C_printf("%s",comment);
flush_buffer();
shr_last_def_section_comment= sec_no;
}
}
write_def(cp);
}

/*:62*/
#line 915 "mctangle.w"
;
}
else{
C_file= Code_file;
write_def(cp);
}
C_file= Code_file;
}
/*174:*/
#line 3248 "mctangle.w"

{
struct dependency_node*d_node;

if(dep_head){
C_printf("%s","/* direct import includes */");
flush_buffer();
}
for(d_node= dep_head;d_node;d_node= d_node->next)
if(d_node->dep_type!=dep_from_program_import&&d_node->dep_type!=dep_from_library_import)
if(d_node->exported==0||(used_exports&exp_shared)==0){
C_printf("#include \"%s",d_node->name);
C_printf(".%s\"",d_node->dep_type==dep_import_chapter?"shr":"exp");
flush_buffer();
}
}

/*:174*/
#line 923 "mctangle.w"
;
/*63:*/
#line 968 "mctangle.w"

{
char expname[max_file_name_length];
char*dot;

if(used_exports&exp_shared){
strcpy(expname,Shr_file_name);
dot= file_name_ext(expname);
if(dot)*dot= 0;
strcat(expname,".shr");
C_printf("#include \"%s\"",expname);
flush_buffer();
}
pop_level(0);
}

/*:63*/
#line 924 "mctangle.w"
;
/*70:*/
#line 1075 "mctangle.w"

{
int i;
push_export_section(&var_sec);
var_sec.first_text= var_sec.last_text= NULL;
for(i= num_export_sections-1;i>=0;i--)
push_export_section(&glb_sec[i]);
}

/*:70*/
#line 925 "mctangle.w"
;
}

/*:60*//*65:*/
#line 989 "mctangle.w"

void write_def(tok)
eight_bits*tok;
{
sixteen_bits a;
cur_byte= tok;
cur_end= (cur_text+1)->tok_start;
C_printf("%s","#define ");
out_state= normal;
protect= 1;
while(cur_byte<cur_end){
a= *cur_byte++;
if(cur_byte==cur_end&&a=='\n')break;
if(out_state==verbatim&&a!=string&&a!=constant&&a!='\n')
C_putc(a);

else if(a<0200)out_char(a);
else{
a= (a-0200)*0400+*cur_byte++;
if(a<024000){
cur_val= a;out_char(identifier);
}
else if(a<050000){confusion("macro defs have strange char");}
else{
cur_val= a-050000;cur_section= cur_val;out_char(section_number);
}

}
}
protect= 0;
flush_buffer();
}

/*:65*//*72:*/
#line 1093 "mctangle.w"

static void
out_char(cur_char)
eight_bits cur_char;
{
char*j,*k;
restart:
switch(cur_char){
case'\n':if(protect)C_putc(' ');
if(protect||out_state==verbatim)C_putc('\\');
flush_buffer();if(out_state!=verbatim)out_state= normal;break;
/*76:*/
#line 1161 "mctangle.w"

case identifier:
if(out_state==num_or_id)C_putc(' ');
j= (cur_val+name_dir)->byte_start;
k= (cur_val+name_dir+1)->byte_start;
while(j<k){
if((unsigned char)(*j)<0200)C_putc(*j);

else C_printf("%s",translit[(unsigned char)(*j)-0200]);
j++;
}
out_state= num_or_id;break;

/*:76*/
#line 1104 "mctangle.w"
;
/*77:*/
#line 1174 "mctangle.w"

case section_number:
if(cur_val>0)C_printf("/*%d:*/",cur_val);
else if(cur_val<0)C_printf("/*:%d*/",-cur_val);
else if(protect){
cur_byte+= 4;
cur_char= '\n';
goto restart;
}else{
sixteen_bits a;
a= 0400**cur_byte++;
a+= *cur_byte++;
C_printf("\n#line %d \"",a);

cur_val= *cur_byte++;
cur_val= 0400*(cur_val-0200)+*cur_byte++;
for(j= (cur_val+name_dir)->byte_start,k= (cur_val+name_dir+1)->byte_start;
j<k;j++)C_putc(*j);
C_printf("%s","\"\n");
}
break;

/*:77*/
#line 1105 "mctangle.w"
;
/*73:*/
#line 1123 "mctangle.w"

case plus_plus:C_putc('+');C_putc('+');out_state= normal;break;
case minus_minus:C_putc('-');C_putc('-');out_state= normal;break;
case minus_gt:C_putc('-');C_putc('>');out_state= normal;break;
case gt_gt:C_putc('>');C_putc('>');out_state= normal;break;
case eq_eq:C_putc('=');C_putc('=');out_state= normal;break;
case lt_lt:C_putc('<');C_putc('<');out_state= normal;break;
case gt_eq:C_putc('>');C_putc('=');out_state= normal;break;
case lt_eq:C_putc('<');C_putc('=');out_state= normal;break;
case not_eq:C_putc('!');C_putc('=');out_state= normal;break;
case and_and:C_putc('&');C_putc('&');out_state= normal;break;
case or_or:C_putc('|');C_putc('|');out_state= normal;break;
case dot_dot_dot:C_putc('.');C_putc('.');C_putc('.');out_state= normal;
break;
case colon_colon:C_putc(':');C_putc(':');out_state= normal;break;
case period_ast:C_putc('.');C_putc('*');out_state= normal;break;
case minus_gt_ast:C_putc('-');C_putc('>');C_putc('*');out_state= normal;
break;

/*:73*/
#line 1106 "mctangle.w"
;
case'=':C_putc('=');C_putc(' ');out_state= normal;break;
case join:out_state= unbreakable;break;
case constant:if(out_state==verbatim){
out_state= num_or_id;break;
}
if(out_state==num_or_id)C_putc(' ');out_state= verbatim;break;
case string:if(out_state==verbatim)out_state= normal;
else out_state= verbatim;break;
case ignore:break;
case'/':C_putc('/');out_state= post_slash;break;
case'*':if(out_state==post_slash)C_putc(' ');

default:C_putc(cur_char);out_state= normal;break;
}
}

/*:72*//*81:*/
#line 1254 "mctangle.w"

eight_bits
skip_ahead()
{
eight_bits c;
while(1){
if(loc>limit&&(get_line()==0))return(new_section);
*(limit+1)= '@';
while(*loc!='@')loc++;
if(loc<=limit){
loc++;c= ccode[(eight_bits)*loc];loc++;
if(c!=ignore||*(loc-1)=='>')return(c);
}
}
}

/*:81*//*84:*/
#line 1293 "mctangle.w"

int skip_comment(is_long_comment)
boolean is_long_comment;
{
char c;
while(1){
if(loc>limit){
if(is_long_comment){
if(get_line())return(comment_continues= 1);
else{
err_print("! Input ended in mid-comment");

return(comment_continues= 0);
}
}
else return(comment_continues= 0);
}
c= *(loc++);
if(is_long_comment&&c=='*'&&*loc=='/'){
loc++;return(comment_continues= 0);
}
if(c=='@'){
if(ccode[(eight_bits)*loc]==new_section){
err_print("! Section name ended in mid-comment");loc--;

return(comment_continues= 0);
}
else loc++;
}
}
}

/*:84*//*87:*/
#line 1344 "mctangle.w"

eight_bits
get_next()
{
static int preprocessing= 0;
eight_bits c;
while(1){
if(loc>limit){
if(preprocessing&&*(limit-1)!='\\')preprocessing= 0;
if(get_line()==0)return(new_section);
else if(print_where&&!no_where){
print_where= 0;
/*101:*/
#line 1674 "mctangle.w"

store_two_bytes(0150000);
if(changing)id_first= change_file_name;
else id_first= cur_file_name;
id_loc= id_first+strlen(id_first);
if(changing)store_two_bytes((sixteen_bits)change_line);
else store_two_bytes((sixteen_bits)cur_line);
{int a= id_lookup(id_first,id_loc,0)-name_dir;app_repl((a/0400)+0200);
app_repl(a%0400);}

/*:101*/
#line 1356 "mctangle.w"
;
}
else return('\n');
}
c= *loc;
if(comment_continues||(c=='/'&&(*(loc+1)=='*'||*(loc+1)=='/'))){
skip_comment(comment_continues||*(loc+1)=='*');

if(comment_continues)return('\n');
else continue;
}
loc++;
if(xisdigit(c)||c=='\\'||c=='.')/*90:*/
#line 1422 "mctangle.w"
{
id_first= loc-1;
if(*id_first=='.'&&!xisdigit(*loc))goto mistake;
if(*id_first=='\\')while(xisdigit(*loc))loc++;
else{
if(*id_first=='0'){
if(*loc=='x'||*loc=='X'){
loc++;while(xisxdigit(*loc))loc++;goto found;
}
}
while(xisdigit(*loc))loc++;
if(*loc=='.'){
loc++;
while(xisdigit(*loc))loc++;
}
if(*loc=='e'||*loc=='E'){
if(*++loc=='+'||*loc=='-')loc++;
while(xisdigit(*loc))loc++;
}
}
found:while(*loc=='u'||*loc=='U'||*loc=='l'||*loc=='L'
||*loc=='f'||*loc=='F')loc++;
id_loc= loc;
return(constant);
}

/*:90*/
#line 1368 "mctangle.w"

else if(c=='\''||c=='"'||(c=='L'&&(*loc=='\''||*loc=='"')))
/*91:*/
#line 1453 "mctangle.w"
{
char delim= c;
id_first= section_text+1;
id_loc= section_text;*++id_loc= delim;
if(delim=='L'){
delim= *loc++;*++id_loc= delim;
}
while(1){
if(loc>=limit){
if(*(limit-1)!='\\'){
err_print("! String didn't end");loc= limit;break;

}
if(get_line()==0){
err_print("! Input ended in middle of string");loc= buffer;break;

}
else if(++id_loc<=section_text_end)*id_loc= '\n';

}
if((c= *loc++)==delim){
if(++id_loc<=section_text_end)*id_loc= c;
break;
}
if(c=='\\'){
if(loc>=limit)continue;
if(++id_loc<=section_text_end)*id_loc= '\\';
c= *loc++;
}
if(++id_loc<=section_text_end)*id_loc= c;
}
if(id_loc>=section_text_end){
printf("\n! String too long: ");

term_write(section_text+1,25);
err_print("...");
}
id_loc++;
return(string);
}

/*:91*/
#line 1370 "mctangle.w"

else if(isalpha(c)||isxalpha(c)||ishigh(c))
/*89:*/
#line 1416 "mctangle.w"
{
id_first= --loc;
while(isalpha(*++loc)||isdigit(*loc)||isxalpha(*loc)||ishigh(*loc));
id_loc= loc;return(identifier);
}

/*:89*/
#line 1372 "mctangle.w"

else if(c=='@')/*92:*/
#line 1497 "mctangle.w"
{
c= ccode[(eight_bits)*loc++];
switch(c){
case ignore:continue;
case output_defs_code:output_defs_seen= 1;return(c);
case translit_code:err_print("! Use @l in limbo only");continue;

case control_text:while((c= skip_ahead())=='@');

if(*(loc-1)!='>')
err_print("! Double @ should be used in control text");

continue;
case section_name:
cur_section_name_char= *(loc-1);
/*94:*/
#line 1546 "mctangle.w"
{
char*k;
/*96:*/
#line 1566 "mctangle.w"

k= section_text;
while(1){
if(loc>limit&&get_line()==0){
err_print("! Input ended in section name");

loc= buffer+1;break;
}
c= *loc;
/*97:*/
#line 1590 "mctangle.w"

if(c=='@'){
c= *(loc+1);
if(c=='>'){
loc+= 2;break;
}
if(ccode[(eight_bits)c]==new_section){
err_print("! Section name didn't end");break;

}
if(ccode[(eight_bits)c]==section_name){
err_print("! Nesting of section names not allowed");break;

}
*(++k)= '@';loc++;
}

/*:97*/
#line 1575 "mctangle.w"
;
loc++;if(k<section_text_end)k++;
if(xisspace(c)){
c= ' ';if(*(k-1)==' ')k--;
}
*k= c;
}
if(k>=section_text_end){
printf("\n! Section name too long: ");

term_write(section_text+1,25);
printf("...");mark_harmless;
}
if(*k==' '&&k>section_text)k--;

/*:96*/
#line 1548 "mctangle.w"
;
if(k-section_text>3&&strncmp(k-2,"...",3)==0)
cur_section_name= section_lookup(section_text+1,k-3,1);
else cur_section_name= section_lookup(section_text+1,k,0);
if(cur_section_name_char=='(')
/*46:*/
#line 596 "mctangle.w"

{
for(an_output_file= cur_out_file;
an_output_file<end_output_files;an_output_file++)
if(*an_output_file==cur_section_name)break;
if(an_output_file==end_output_files){
if(cur_out_file>output_files)
*--cur_out_file= cur_section_name;
else{
overflow("output files");
}
}
}

/*:46*/
#line 1554 "mctangle.w"
;
return(section_name);
}

/*:94*/
#line 1512 "mctangle.w"
;
case string:/*98:*/
#line 1612 "mctangle.w"
{
id_first= loc++;*(limit+1)= '@';*(limit+2)= '>';
while(*loc!='@'||*(loc+1)!='>')loc++;
if(loc>=limit)err_print("! Verbatim string didn't end");

id_loc= loc;loc+= 2;
return(string);
}

/*:98*/
#line 1513 "mctangle.w"
;
case ord:/*93:*/
#line 1525 "mctangle.w"

id_first= loc;
if(*loc=='\\'){
if(*++loc=='\'')loc++;
}
while(*loc!='\''){
if(*loc=='@'){
if(*(loc+1)!='@')
err_print("! Double @ should be used in ASCII constant");

else loc++;
}
loc++;
if(loc>limit){
err_print("! String didn't end");loc= limit-1;break;

}
}
loc++;
return(ord);

/*:93*/
#line 1514 "mctangle.w"
;
default:return(c);
}
}

/*:92*/
#line 1373 "mctangle.w"

else if(xisspace(c)){
if(!preprocessing||loc>limit)continue;

else return(' ');
}
else if(c=='#'&&loc==buffer+1)preprocessing= 1;
mistake:/*88:*/
#line 1394 "mctangle.w"

switch(c){
case'+':if(*loc=='+')compress(plus_plus);break;
case'-':if(*loc=='-'){compress(minus_minus);}
else if(*loc=='>')if(*(loc+1)=='*'){loc++;compress(minus_gt_ast);}
else compress(minus_gt);break;
case'.':if(*loc=='*'){compress(period_ast);}
else if(*loc=='.'&&*(loc+1)=='.'){
loc++;compress(dot_dot_dot);
}
break;
case':':if(*loc==':')compress(colon_colon);break;
case'=':if(*loc=='=')compress(eq_eq);break;
case'>':if(*loc=='='){compress(gt_eq);}
else if(*loc=='>')compress(gt_gt);break;
case'<':if(*loc=='='){compress(lt_eq);}
else if(*loc=='<')compress(lt_lt);break;
case'&':if(*loc=='&')compress(and_and);break;
case'|':if(*loc=='|')compress(or_or);break;
case'!':if(*loc=='=')compress(not_eq);break;
}

/*:88*/
#line 1380 "mctangle.w"

return(c);
}
}

/*:87*//*100:*/
#line 1647 "mctangle.w"

void
scan_repl(t)
eight_bits t;
{
sixteen_bits a;
if(t==section_name){/*101:*/
#line 1674 "mctangle.w"

store_two_bytes(0150000);
if(changing)id_first= change_file_name;
else id_first= cur_file_name;
id_loc= id_first+strlen(id_first);
if(changing)store_two_bytes((sixteen_bits)change_line);
else store_two_bytes((sixteen_bits)cur_line);
{int a= id_lookup(id_first,id_loc,0)-name_dir;app_repl((a/0400)+0200);
app_repl(a%0400);}

/*:101*/
#line 1653 "mctangle.w"
;}
while(1)switch(a= get_next()){
got_next_one:
/*102:*/
#line 1684 "mctangle.w"

case special_command:
a= get_next();
/*103:*/
#line 1723 "mctangle.w"

{
if(a==identifier){
a= id_lookup(id_first,id_loc,0)-name_dir;
if(id_global<=a&&a<=id_shared){
remember_export(a);
break;
}
else if(id_import==a||a==id_from){
remember_import();
app_repl((a/0400)+0200);
app_repl(a%0400);
break;
}
else if(id_mark==a||id_paste==a){
a= get_next();
if(a==string)break;
}
if(id_copy==a)break;
}
err_print("! Illegal special command");
}

/*:103*/
#line 1687 "mctangle.w"
;
goto got_next_one;
case identifier:a= id_lookup(id_first,id_loc,0)-name_dir;
app_repl((a/0400)+0200);
app_repl(a%0400);
break;
case section_name:if(t!=section_name)goto done;
else{
/*104:*/
#line 1746 "mctangle.w"
{
char*try_loc= loc;
while(*try_loc==' '&&try_loc<limit)try_loc++;
if(*try_loc=='+'&&try_loc<limit)try_loc++;
while(*try_loc==' '&&try_loc<limit)try_loc++;
if(*try_loc=='=')err_print("! Missing `@ ' before a named section");



}

/*:104*/
#line 1695 "mctangle.w"
;
a= cur_section_name-name_dir;
app_repl((a/0400)+0250);
app_repl(a%0400);
/*101:*/
#line 1674 "mctangle.w"

store_two_bytes(0150000);
if(changing)id_first= change_file_name;
else id_first= cur_file_name;
id_loc= id_first+strlen(id_first);
if(changing)store_two_bytes((sixteen_bits)change_line);
else store_two_bytes((sixteen_bits)cur_line);
{int a= id_lookup(id_first,id_loc,0)-name_dir;app_repl((a/0400)+0200);
app_repl(a%0400);}

/*:101*/
#line 1699 "mctangle.w"
;break;
}
case output_defs_code:
a= output_defs_flag;
app_repl((a/0400)+0200);
app_repl(a%0400);
/*101:*/
#line 1674 "mctangle.w"

store_two_bytes(0150000);
if(changing)id_first= change_file_name;
else id_first= cur_file_name;
id_loc= id_first+strlen(id_first);
if(changing)store_two_bytes((sixteen_bits)change_line);
else store_two_bytes((sixteen_bits)cur_line);
{int a= id_lookup(id_first,id_loc,0)-name_dir;app_repl((a/0400)+0200);
app_repl(a%0400);}

/*:101*/
#line 1705 "mctangle.w"
;break;
case constant:case string:
/*105:*/
#line 1757 "mctangle.w"

app_repl(a);
while(id_first<id_loc){
if(*id_first=='@'){
if(*(id_first+1)=='@')id_first++;
else err_print("! Double @ should be used in string");

}
app_repl(*id_first++);
}
app_repl(a);break;

/*:105*/
#line 1707 "mctangle.w"
;
case ord:
/*106:*/
#line 1773 "mctangle.w"
{
int c= (eight_bits)*id_first;
if(c=='\\'){
c= *++id_first;
if(c>='0'&&c<='7'){
c-= '0';
if(*(id_first+1)>='0'&&*(id_first+1)<='7'){
c= 8*c+*(++id_first)-'0';
if(*(id_first+1)>='0'&&*(id_first+1)<='7'&&c<32)
c= 8*c+*(++id_first)-'0';
}
}
else switch(c){
case't':c= '\t';break;
case'n':c= '\n';break;
case'b':c= '\b';break;
case'f':c= '\f';break;
case'v':c= '\v';break;
case'r':c= '\r';break;
case'a':c= '\7';break;
case'?':c= '?';break;
case'x':
if(xisdigit(*(id_first+1)))c= *(++id_first)-'0';
else if(xisxdigit(*(id_first+1))){
++id_first;
c= toupper(*id_first)-'A'+10;
}
if(xisdigit(*(id_first+1)))c= 16*c+*(++id_first)-'0';
else if(xisxdigit(*(id_first+1))){
++id_first;
c= 16*c+toupper(*id_first)-'A'+10;
}
break;
case'\\':c= '\\';break;
case'\'':c= '\'';break;
case QUOTE:c= QUOTE;break;
default:err_print("! Unrecognized escape sequence");

}
}

app_repl(constant);
if(c>=100)app_repl('0'+c/100);
if(c>=10)app_repl('0'+(c/10)%10);
app_repl('0'+c%10);
app_repl(constant);
}
break;

/*:106*/
#line 1709 "mctangle.w"
;
case definition:case format_code:case begin_C:if(t!=section_name)goto done;
else{
err_print("! @d, @f and @c are ignored in C text");continue;

}
case new_section:goto done;

/*:102*/
#line 1659 "mctangle.w"

case')':app_repl(a);
if(t==macro)app_repl(' ');
break;
default:app_repl(a);
}
done:next_control= (eight_bits)a;
if(text_ptr>text_info_end)overflow("text");
cur_text= text_ptr;(++text_ptr)->tok_start= tok_ptr;
}

/*:100*//*108:*/
#line 1835 "mctangle.w"

void
scan_section()
{
name_pointer p;
text_pointer q;
sixteen_bits a;
section_count++;no_where= 1;
if(*(loc-1)=='*'&&show_progress){
printf("*%d",section_count);update_terminal;
}
next_control= 0;
while(1){
/*109:*/
#line 1874 "mctangle.w"

while(next_control<definition)

if((next_control= skip_ahead())==section_name){
loc-= 2;next_control= get_next();
}

/*:109*/
#line 1849 "mctangle.w"
;
if(next_control==definition){
/*110:*/
#line 1881 "mctangle.w"
{
/*111:*/
#line 1908 "mctangle.w"

{
char comment[20],*cp;
while((next_control= get_next())=='\n');
sprintf(comment,"\03/*Section:%d*/\03",section_count);
for(cp= comment;*cp;cp++)app_repl(*cp);
while(next_control==special_command){
next_control= get_next();
if(next_control==identifier){
a= id_lookup(id_first,id_loc,0)-name_dir;
if(id_global<=a&&a<=id_shared){
used_exports|= 1<<a-1;
app_repl(special_command);
app_repl((a>>8)+0200);
app_repl(a&0377);
}
else{
err_print("! Illegal export command");

break;
}
do next_control= get_next();
while(xisspace(next_control));
}
else break;
}
}

/*:111*/
#line 1882 "mctangle.w"
;
if(next_control!=identifier){
err_print("! Definition flushed, must start with identifier");

continue;
}
app_repl(((a= id_lookup(id_first,id_loc,0)-name_dir)/0400)+0200);

app_repl(a%0400);
if(*loc!='('){
app_repl(string);app_repl(' ');app_repl(string);
}
scan_repl(macro);
cur_text->text_link= 0;
}

/*:110*/
#line 1851 "mctangle.w"

continue;
}
if(next_control==begin_C){
p= name_dir;break;
}
if(next_control==section_name){
p= cur_section_name;
/*112:*/
#line 1944 "mctangle.w"

while((next_control= get_next())=='+');
if(next_control!='='&&next_control!=eq_eq)
continue;

/*:112*/
#line 1859 "mctangle.w"
;
break;
}
return;
}
no_where= print_where= 0;
/*113:*/
#line 1950 "mctangle.w"

/*114:*/
#line 1957 "mctangle.w"

store_two_bytes((sixteen_bits)(0150000+section_count));


/*:114*/
#line 1951 "mctangle.w"
;
scan_repl(section_name);
/*115:*/
#line 1961 "mctangle.w"

if(p==name_dir||p==0){
(last_unnamed)->text_link= cur_text-text_info;last_unnamed= cur_text;
}
else if(p->equiv==(char*)text_info)p->equiv= (char*)cur_text;

else{
q= (text_pointer)p->equiv;
while(q->text_link<section_flag)
q= q->text_link+text_info;
q->text_link= cur_text-text_info;
}
cur_text->text_link= section_flag;


/*:115*/
#line 1953 "mctangle.w"
;
process_imports();
process_exports();

/*:113*/
#line 1865 "mctangle.w"
;
}

/*:108*//*117:*/
#line 1979 "mctangle.w"

void
phase_one(){
phase= 1;
section_count= 0;
reset_input();
skip_limbo();
while(!input_has_ended)scan_section();
check_complete();
phase= 2;
}

/*:117*//*119:*/
#line 1997 "mctangle.w"

void
skip_limbo()
{
char c;
while(1){
if(loc>limit&&get_line()==0)return;
*(limit+1)= '@';
while(*loc!='@')loc++;
if(loc++<=limit){
c= *loc++;
if(ccode[(eight_bits)c]==new_section)break;
switch(ccode[(eight_bits)c]){
case translit_code:/*120:*/
#line 2026 "mctangle.w"

while(xisspace(*loc)&&loc<limit)loc++;
loc+= 3;
if(loc>limit||!xisxdigit(*(loc-3))||!xisxdigit(*(loc-2))
||(*(loc-3)>='0'&&*(loc-3)<='7')||!xisspace(*(loc-1)))
err_print("! Improper hex number following @l");

else{
unsigned i;
char*beg;
sscanf(loc-3,"%x",&i);
while(xisspace(*loc)&&loc<limit)loc++;
beg= loc;
while(loc<limit&&(xisalpha(*loc)||xisdigit(*loc)||*loc=='_'))loc++;
if(loc-beg>=translit_length)
err_print("! Replacement string in @l too long");

else{
strncpy(translit[i-0200],beg,loc-beg);
translit[i-0200][loc-beg]= '\0';
}
}

/*:120*/
#line 2010 "mctangle.w"
;break;
case format_code:case'@':break;
case control_text:if(c=='q'||c=='Q'){
while((c= skip_ahead())=='@');
if(*(loc-1)!='>')
err_print("! Double @ should be used in control text");

break;
}
default:err_print("! Double @ should be used in limbo");

}
}
}
}

/*:119*//*121:*/
#line 2052 "mctangle.w"

void
print_stats(){
printf("\nMemory usage statistics:\n");
printf("%ld names (out of %ld)\n",
(long)(name_ptr-name_dir),(long)max_names);
printf("%ld replacement texts (out of %ld)\n",
(long)(text_ptr-text_info),(long)max_texts);
printf("%ld bytes (out of %ld)\n",
(long)(byte_ptr-byte_mem),(long)max_bytes);
printf("%ld tokens (out of %ld)\n",
(long)(tok_ptr-tok_mem),(long)max_toks);
}

/*:121*//*129:*/
#line 2119 "mctangle.w"

void
remember_export(id)
sixteen_bits id;
{
sixteen_bits c;

c= 1<<id-1;
used_exports|= c;
if(export_idx&&export_ref[export_idx-1]==tok_ptr)
export_type[export_idx-1]|= c;
else{
if(export_idx>=max_exports)overflow("exports per section");
export_ref[export_idx]= tok_ptr;
export_type[export_idx]= c;
export_line[export_idx]= changing?change_line:cur_line;
export_file_name[export_idx]= changing?change_file_name:cur_file_name;
export_idx++;
}
}

/*:129*//*134:*/
#line 2180 "mctangle.w"

void
push_export_section(sec)
export_section*sec;
{
static char s[]= "_global";
name_pointer p= id_lookup(s,s+strlen(s),0);
if(sec->first_text){
p->equiv= (char*)sec->first_text;
push_level(p);
}
}

/*:134*//*135:*/
#line 2197 "mctangle.w"

text_pointer
new_text_ptr(sec,type)
export_section*sec;
int type;
{
text_pointer txt;
if(text_ptr>text_info_end)overflow("text");
if(sec[type].last_text==text_ptr-1)return text_ptr-1;
txt= text_ptr++;
text_ptr->tok_start= tok_ptr;
txt->tok_start= tok_ptr;
txt->text_link= section_flag;
if(sec[type].last_text==NULL)sec[type].first_text= txt;
else sec[type].last_text->text_link= txt-text_info;
sec[type].last_text= txt;
return txt;
}

/*:135*//*136:*/
#line 2219 "mctangle.w"

void
insert_section_comment()
{
char comment[20],*cp;
sprintf(comment,"\03/*Section:%d*/\03\n",section_count);
for(cp= comment;*cp;cp++)app_repl(*cp);
}

/*:136*//*138:*/
#line 2243 "mctangle.w"

void
process_exports()
{
eight_bits*tk;
sixteen_bits i;
int parenthesis,braces;
boolean is_declaration;
boolean is_typedef;
boolean is_inline;
boolean func_possible;
eight_bits*aggregate;
int aggregate_id;
eight_bits*aggregate_label;
eight_bits*aggregate_body,*body_end;
eight_bits*aggregate_variable;
boolean is_func_new_style;
boolean is_func_old_style;
boolean is_prototype;
boolean is_preproc;
boolean is_static;
eight_bits*func_arguments;
eight_bits*arg_end;

for(i= 0;i<export_idx;i++){
tk= export_ref[i];
while(xisspace(*tk))tk++;
export_ref[i]= tk;
braces= parenthesis= 0;
is_declaration= 0;
is_typedef= 0;
is_inline= 0;
aggregate= NULL;
is_func_new_style= 0;
is_func_old_style= 0;
is_prototype= 0;
is_preproc= 0;
is_static= 0;
func_arguments= NULL;
/*139:*/
#line 2303 "mctangle.w"

{
sixteen_bits id;
boolean aggregate_body_might_follow= 0;

if(export_type[i]==exp_export){
if(0200<=*tk&&*tk<0250){
id= *tk-0200<<8|tk[1];
if(id_import==id||id==id_from)continue;
}
if(*tk==ignore)continue;
}
func_possible= -1;
while(xisspace(*tk))tk++;
if(*tk=='#')is_preproc= 1;
while(tk<tok_ptr){
switch(*tk++){
case'=':
while(*tk=='\n')tk++;
if(*tk=='{'){
tk++;
braces++;
}
if(parenthesis)break;
nobreak;
case':':
if(*tk!=':')
func_possible= 0;
break;
case string:
case constant:
do tk++;
while(tk<tok_ptr&&*tk!=string&&*tk!=constant);
tk++;
break;
case'(':
if(func_possible<0)func_possible= 1;
parenthesis++;
aggregate_body_might_follow= 0;
break;
case')':
parenthesis--;break;
case'}':
if(braces){
--braces;
break;
}
nobreak;
case';':
if(!braces&&!parenthesis)goto done;
aggregate_body_might_follow= 0;
break;
case'{':
if(!braces)goto done;
braces++;
break;
default:
if(0200<=tk[-1]&&tk[-1]<0250){
id= tk[-1]-0200<<8;
id|= *tk++;
switch(id){
case id_enum:
case id_union:
case id_class:
case id_struct:
if(!aggregate){
aggregate_id= id;
aggregate= tk;
}
aggregate_body_might_follow= 1;
break;
case id_extern:
is_declaration= 1;break;
case id_typedef:
is_typedef= 1;break;
case id_inline:
is_inline= 1;break;
case id_static:
is_static= 1;break;
}
while(*tk=='\n')tk++;
if(*tk=='{'&&aggregate_body_might_follow){
braces++;
tk++;
}
}
else if(tk[-1]==0320&&*tk==0)tk+= 5;
else if(tk[-1]>=0250)tk++;
}
}
done:if(func_possible<0)func_possible= 0;
else/*140:*/
#line 2417 "mctangle.w"

{
eight_bits*tp,c;
int parenthesis= 0;
boolean can_be_new_style;

func_arguments= NULL;
tp= export_ref[i];
while(tp<=tk){
c= *tp++;
if(c>=0200){
if(c==0320&&*tp==0)tp+= 4;
tp++;
if(c<0250){
id= c-0200<<8|tp[-1];
if(id==id_operator){
arg_end= tk-1;
if(*arg_end=='{')arg_end--;
is_func_new_style= 1;
break;
}
if(*tp=='('&&!parenthesis){
func_arguments= tp;
can_be_new_style= 0;
tp++;
parenthesis= 1;
}
else if(func_arguments&&0200<=*tp&&*tp<0250)can_be_new_style= 1;
}
}
else if(c=='('){
parenthesis++;
func_arguments= NULL;
}
else if(c==')'){
--parenthesis;
arg_end= tp-1;
}
else if(func_arguments&&parenthesis){
if(c!=',')can_be_new_style= 1;
}
}
if(func_arguments&&parenthesis==0){
if(arg_end-func_arguments==3&&0200<=func_arguments[1]&&func_arguments[1]<0250){

int a= func_arguments[1]-0200<<8|func_arguments[2];
if(a==id_void)
can_be_new_style= 1;
}
tp= arg_end+1;
while(isspace(*tp))tp++;
if(*tp=='{'){
if(can_be_new_style)
is_func_new_style= 1;
else is_func_old_style= 1;
}
else if(0200<=*tp&&*tp<0250)
is_func_old_style= 1;
else if(*tp==','||*tp==';')is_prototype= 1;
else func_arguments= NULL;
}
}

/*:140*/
#line 2394 "mctangle.w"
;
}

/*:139*/
#line 2282 "mctangle.w"
;
if(aggregate)/*141:*/
#line 2487 "mctangle.w"

{
eight_bits*tp= aggregate;
aggregate_label= NULL;
aggregate_body= NULL;
aggregate_variable= NULL;
while(*tp=='\n')tp++;
if(0200<=*tp&&*tp<0250){
aggregate_label= tp;
tp+= 2;
while(*tp=='\n')tp++;
if(*tp=='{'||*tp==':'&&tp[1]!=':')aggregate_body= tp;
}
else if(*tp=='{')aggregate_body= tp;
if(aggregate_body){
body_end= aggregate_body;
/*142:*/
#line 2519 "mctangle.w"

{
boolean in_verb= 0;
braces= 0;
body_end--;
while(++body_end<tok_ptr){
switch(*body_end){
case'{':if(!in_verb)braces++;
break;
case'}':if(!in_verb&&--braces==0)goto found;
break;
case string:
case constant:
in_verb= !in_verb;
break;
default:
if(*body_end==0320&&body_end[1]==0)body_end+= 5;
else if(*body_end>=0200)body_end++;
}
}
aggregate_body= NULL;
if(braces)
err_print("! Cannot find corresponding } for aggregate");

else
err_print("! Class derivation without { body };");

found:;
}

/*:142*/
#line 2503 "mctangle.w"
;
}
else if(aggregate_label)body_end= aggregate_label+1;
else body_end= NULL;
if(body_end){
tp= body_end+1;
while(*tp=='\n')tp++;
if(*tp!=';')aggregate_variable= tp;
}
aggregate-= 2;
}

/*:141*/
#line 2283 "mctangle.w"
;
/*143:*/
#line 2555 "mctangle.w"

{
sixteen_bits type= export_type[i];
export_section*sec;
eight_bits*tp;

also_to_exp_sec= 0;
if(type==exp_export){
sec= exp_sec;
modify_original_token_list= 0;
}
else{
if(type&exp_export)also_to_exp_sec= 1;
if(type&exp_global)sec= glb_sec;
else if(type&exp_shared)sec= shr_sec;
modify_original_token_list= 1;
}
if(aggregate&&aggregate_id==id_class&&aggregate_label)
/*146:*/
#line 2651 "mctangle.w"

{
x_new_text_ptr(sec,forward_types);
remember_export_line(i);
for(tp= aggregate;tp<aggregate_label+2;tp++)
app_repl(*tp);
app_repl(';');
app_repl('\n');
if(*tp==';'){
if(modify_original_token_list)/*145:*/
#line 2642 "mctangle.w"

{
for(tp= export_ref[i];tp<tk;tp++)if(*tp!='\n')*tp= ignore;
}

/*:145*/
#line 2660 "mctangle.w"
;
goto stored;
}
}

/*:146*/
#line 2573 "mctangle.w"

if(is_preproc){
/*147:*/
#line 2666 "mctangle.w"

{
x_new_text_ptr(sec,types);
remember_export_line(i);
for(tp= export_ref[i];tp<tk;tp++){
app_repl(*tp);
if(*tp=='\n'&&tp[-1]!='\\'){
tk= tp+1;
break;
}
}
if(tp==tk)app_repl('\n');
}

/*:147*/
#line 2575 "mctangle.w"
;
if(modify_original_token_list)/*145:*/
#line 2642 "mctangle.w"

{
for(tp= export_ref[i];tp<tk;tp++)if(*tp!='\n')*tp= ignore;
}

/*:145*/
#line 2576 "mctangle.w"
;
goto stored;
}
if(is_typedef){
/*148:*/
#line 2682 "mctangle.w"

{
x_new_text_ptr(sec,types);
remember_export_line(i);
for(tp= export_ref[i];tp<tk;tp++)app_repl(*tp);
app_repl('\n');
}

/*:148*/
#line 2580 "mctangle.w"
;
if(modify_original_token_list)/*145:*/
#line 2642 "mctangle.w"

{
for(tp= export_ref[i];tp<tk;tp++)if(*tp!='\n')*tp= ignore;
}

/*:145*/
#line 2581 "mctangle.w"
;
goto stored;
}
if(aggregate&&(aggregate_label||aggregate_id==id_enum&&!aggregate_variable)&&
aggregate_body){
/*149:*/
#line 2696 "mctangle.w"

{
x_new_text_ptr(sec,aggregate_id==id_enum?forward_types:types);
remember_export_line(i);
for(tp= aggregate;tp<=body_end;tp++)app_repl(*tp);
app_repl(';');
app_repl('\n');
}

/*:149*/
#line 2586 "mctangle.w"
;
if(modify_original_token_list)/*150:*/
#line 2708 "mctangle.w"

for(tp= aggregate_body;tp<=body_end;tp++)if(*tp!='\n')*tp= ignore;

/*:150*/
#line 2587 "mctangle.w"
;
if(!aggregate_variable){
if(modify_original_token_list)/*145:*/
#line 2642 "mctangle.w"

{
for(tp= export_ref[i];tp<tk;tp++)if(*tp!='\n')*tp= ignore;
}

/*:145*/
#line 2589 "mctangle.w"
;
goto stored;
}
}
if(is_declaration){
/*151:*/
#line 2712 "mctangle.w"

{
x_new_text_ptr(sec,declarations);
remember_export_line(i);
for(tp= export_ref[i];tp<tk;tp++)app_repl(*tp);
app_repl('\n');
}

/*:151*/
#line 2594 "mctangle.w"
;
if(modify_original_token_list)/*145:*/
#line 2642 "mctangle.w"

{
for(tp= export_ref[i];tp<tk;tp++)if(*tp!='\n')*tp= ignore;
}

/*:145*/
#line 2595 "mctangle.w"
;
goto stored;
}
if(is_inline&&tk[-1]=='{'){
/*152:*/
#line 2723 "mctangle.w"

{
int braces;
x_new_text_ptr(sec,declarations);
remember_export_line(i);
braces= 0;
for(tp= tk-1;tp<tok_ptr;tp++){
switch(*tp++){
case string:
case constant:
do{
if(*tp==string||*tp==constant){
tp++;
break;
}
}while(++tp<tok_ptr);
goto have_it;
case'{':
braces++;
break;
case'}':
braces--;
if(!braces)goto have_it;
break;
}
}
have_it:
tk= tp;
for(tp= export_ref[i];tp<tk;tp++)app_repl(*tp);
app_repl('\n');
if(modify_original_token_list)/*145:*/
#line 2642 "mctangle.w"

{
for(tp= export_ref[i];tp<tk;tp++)if(*tp!='\n')*tp= ignore;
}

/*:145*/
#line 2753 "mctangle.w"
;
}

/*:152*/
#line 2599 "mctangle.w"
;
goto stored;
}
if(is_func_old_style){
/*153:*/
#line 2772 "mctangle.w"

{
int num_args,a,j;
eight_bits*cur_type_start;
eight_bits*cur_type_end;
eight_bits*cur_variable_start;
sixteen_bits argument[max_args];
eight_bits*type_start[max_args],*type_end[max_args];
eight_bits*variable_start[max_args];

x_new_text_ptr(sec,declarations);
remember_export_line(i);
/*154:*/
#line 2802 "mctangle.w"

if(flags['k']){
for(tp= export_ref[i];tp<=func_arguments;tp++)app_repl(*tp);
app_repl(')');
app_repl(';');
app_repl('\n');
goto proto_generated;
}

/*:154*/
#line 2784 "mctangle.w"
;
/*155:*/
#line 2814 "mctangle.w"

if(func_arguments==arg_end-1){
for(tp= export_ref[i];tp<=func_arguments;tp++)app_repl(*tp);
app_repl(0200+(id_void/0400));
app_repl(id_void&0377);
for(;tp<=arg_end;tp++)app_repl(*tp);
app_repl(';');
app_repl('\n');
goto proto_generated;
}

/*:155*/
#line 2785 "mctangle.w"
;
/*156:*/
#line 2827 "mctangle.w"

num_args= 0;
for(tp= func_arguments+1;tp<arg_end;tp++){
if(*tp>=0200&&*tp<0250){
if(num_args==max_args)overflow("function arguments");
argument[num_args]= *tp<<8;
argument[num_args]+= *++tp;
num_args++;
++tp;
if(*tp!=',')break;
}
}
if(tp<arg_end){
printf("! Illegal old style function head (file \"%s\", l. %d)\n",
export_file_name[i],export_line[i]);

mark_error;
goto proto_generated;
}

/*:156*/
#line 2786 "mctangle.w"
;
cur_type_start= arg_end+1;
while(xisspace(*cur_type_start))cur_type_start++;
cur_type_end= cur_variable_start= NULL;
for(j= 0;j<num_args;j++){
type_start[j]= NULL;
type_end[j]= NULL;
variable_start[j]= NULL;
}
/*157:*/
#line 2865 "mctangle.w"

{
for(tp= cur_type_start;tp<tok_ptr;tp++){
if(*tp>=0200){
if(*tp<0250){
a= *tp<<8;
a+= *++tp;
if(a>=id_enum&&a<=id_struct){
if(0200<=tp[1]&&tp[1]<0250)tp+= 2;
}
else{
for(j= 0;j<num_args;j++)
if(a==argument[j]){
if(!cur_type_end)
cur_variable_start= cur_type_end= tp-1;
type_start[j]= cur_type_start;
type_end[j]= cur_type_end;
variable_start[j]= cur_variable_start;
}
}
if(tp[1]=='{'){
int braces= 0;
do if(*++tp=='{')braces++;
else if(*tp=='}')braces--;
else if(*tp>=0200)tp++;
while(braces&&tp<tok_ptr);
if(braces){
err_print("! Can't find closing `}' of aggregate body");

goto proto_generated;
}
}
}
else tp++;
}
else if(*tp==';'){
cur_type_start= tp+1;
while(xisspace(*cur_type_start))cur_type_start++;
cur_type_end= NULL;
cur_variable_start= NULL;
}
else if(*tp==',')cur_variable_start= tp+1;
else if(*tp=='{')break;
else if(!cur_type_end&&!isspace(*tp))
cur_type_end= cur_variable_start= tp;
}
}

/*:157*/
#line 2795 "mctangle.w"
;
/*158:*/
#line 2921 "mctangle.w"

{
for(tp= export_ref[i];tp<=func_arguments;tp++)app_repl(*tp);
for(j= 0;j<num_args;j++){
if(!type_start[j]){
app_repl((id_int>>8)+0200);
app_repl(id_int&0377);
}
else{
for(tp= type_start[j];tp<type_end[j];tp++)app_repl(*tp);
for(tp= variable_start[j];*tp!=','&&*tp!=';'&&tp<tok_ptr;tp++){
app_repl(*tp);
if(*tp>=0200){
++tp;
app_repl(*tp);
}
}
}
if(j!=num_args-1)app_repl(',');
}
app_repl(')');
app_repl(';');
app_repl('\n');
}

/*:158*/
#line 2796 "mctangle.w"
;
proto_generated:;
}

/*:153*/
#line 2603 "mctangle.w"
;
goto stored;
}
if(is_func_new_style){
/*159:*/
#line 2948 "mctangle.w"

x_new_text_ptr(sec,declarations);
remember_export_line(i);
for(tp= export_ref[i];tp<=arg_end;tp++)app_repl(*tp);
app_repl(';');
app_repl('\n');

/*:159*/
#line 2607 "mctangle.w"
;
goto stored;
}
if(is_prototype){
/*151:*/
#line 2712 "mctangle.w"

{
x_new_text_ptr(sec,declarations);
remember_export_line(i);
for(tp= export_ref[i];tp<tk;tp++)app_repl(*tp);
app_repl('\n');
}

/*:151*/
#line 2611 "mctangle.w"
;
if(modify_original_token_list)/*145:*/
#line 2642 "mctangle.w"

{
for(tp= export_ref[i];tp<tk;tp++)if(*tp!='\n')*tp= ignore;
}

/*:145*/
#line 2612 "mctangle.w"
;
goto stored;
}
if(!is_static)
/*160:*/
#line 2958 "mctangle.w"

{
boolean copy_on= 1;
eight_bits c;
boolean if_ndef;

x_new_text_ptr(sec,declarations);
remember_export_line(i);

if_ndef= aggregate&&aggregate_body&&aggregate_label==NULL;
if(if_ndef){
app_repl('#');
app_repl((id_ifndef>>8)+0200);
app_repl(id_ifndef&0377);
app_repl((id_file_name_constant>>8)+0200);
app_repl(id_file_name_constant&0377);
app_repl('\n');
}

app_repl((id_extern>>8)+0200);
app_repl(id_extern&0377);
braces= 0;
for(tp= export_ref[i];tp<tk;tp++){
switch(c= *tp){
case ignore:
break;
case'{':
braces++;
break;
case'}':
braces--;
break;
case'=':
copy_on= 0;
break;
case string:
do tp++;
while(*tp!=string&&tp<tk);
break;
case',':
case';':
if(!braces)copy_on= 1;
break;
default:
if(c>=0200){
++tp;
if(copy_on){
app_repl(c);
app_repl(*tp);
}
if(c==0320&&*tp==0){
if(copy_on){
++tp;
app_repl(*tp);
++tp;
app_repl(*tp);
++tp;
app_repl(*tp);
++tp;
app_repl(*tp);
}
else tp+= 4;
}
continue;
}
}
if(copy_on&&c)app_repl(c);
}
app_repl('\n');
if(if_ndef){
app_repl('#');
app_repl((id_endif>>8)+0200);
app_repl(id_endif&0377);
app_repl('\n');
}
}

/*:160*/
#line 2616 "mctangle.w"
;
if(modify_original_token_list)
/*161:*/
#line 3039 "mctangle.w"

{
int j;
sec= &var_sec;
new_text_ptr(sec,0);
remember_export_line(i);
for(tp= export_ref[i];tp<tk;tp++){
if(*tp>=0200){
app_repl(*tp);
if(*tp++==0320&&*tp==0)
for(j= 0;j<4;j++,tp++)app_repl(*tp);
app_repl(*tp);
}
else if(*tp!=ignore)app_repl(*tp);
}
app_repl('\n');
/*145:*/
#line 2642 "mctangle.w"

{
for(tp= export_ref[i];tp<tk;tp++)if(*tp!='\n')*tp= ignore;
}

/*:145*/
#line 3055 "mctangle.w"
;
}

/*:161*/
#line 2618 "mctangle.w"
;
stored:
text_ptr->tok_start= tok_ptr;
}

/*:143*/
#line 2284 "mctangle.w"
;
}
export_idx= 0;
text_ptr->tok_start= tok_ptr;
}

/*:138*//*163:*/
#line 3071 "mctangle.w"

void
remember_export_line(i)
int i;
{
int a;
char*id;
store_two_bytes(0150000);
store_two_bytes(export_line[i]);
id= export_file_name[i];
a= id_lookup(id,id+strlen(id),0)-name_dir;
app_repl((a>>8)+0200);
app_repl(a&0377);
}

/*:163*//*166:*/
#line 3103 "mctangle.w"

void
output_export_section(sec,file,sec_name)
export_section*sec;
FILE*file;
char*sec_name;
{
int i;
name_pointer name;
FILE*old_C_file;
static char*comments[]= {
NULL,
"typedefs & aggregates",
"prototypes & declarations"
};

if(!file)return;
old_C_file= C_file;
C_file= file;
cur_line= 1;
name= id_lookup(sec_name,sec_name+strlen(sec_name),0);
for(i= 0;i<num_export_sections;i++){
if(sec[i].first_text){
name->equiv= (char*)sec[i].first_text;
stack_ptr= stack+1;
cur_name= name;
cur_repl= (text_pointer)cur_name->equiv;
cur_byte= cur_repl->tok_start;
set_cur_end();
cur_section= 0;
if(comments[i]){
C_printf("/*%s*/",comments[i]);
flush_buffer();
}
while(stack_ptr>stack)get_output();
flush_buffer();
}
if(!i)
/*173:*/
#line 3222 "mctangle.w"

{
struct dependency_node*d_node;
char*ext;

if(dep_head){
C_printf("%s","/* transitive import includes */");
flush_buffer();
}
for(d_node= dep_head;d_node;d_node= d_node->next)
if(d_node->exported){
if(d_node->dep_type==dep_from_program_import||
d_node->dep_type==dep_from_library_import)continue;
if(d_node->dep_type==dep_import_chapter){
ext= "shr";
if(file==Exp_file)
continue;
}
else ext= "exp";
C_printf("#include \"%s",d_node->name);
C_printf(".%s\"",ext);
flush_buffer();
}
}

/*:173*/
#line 3141 "mctangle.w"

}
C_file= old_C_file;
}

/*:166*//*172:*/
#line 3190 "mctangle.w"

static void
directly_depending_on(name,type,exported)
char*name;
sixteen_bits type;
boolean exported;
{
struct dependency_node*d_node,*tail;

if(dep_head)
for(tail= dep_head;tail->next;tail= tail->next)
if(type==tail->dep_type&&strcmp(name,tail->name)==0){
tail->exported|= exported;
return;
}
d_node= (struct dependency_node*)malloc(sizeof(struct dependency_node)+strlen(name)-1);
if(!d_node)fatal("! No memory for dependency node:",name);

strcpy(d_node->name,name);
d_node->dep_type= type;
d_node->exported= exported;
d_node->next= NULL;
if(dep_head==NULL)dep_head= d_node;
else tail->next= d_node;
}

/*:172*//*183:*/
#line 3372 "mctangle.w"

struct make_dep*
add_make_dep(ch,name)
char*name;
{
struct make_dep*md,*last_md;
for(md= ch_make_dep[ch];md;md= md->next){
if(!strcmp(md->name,name))return NULL;
last_md= md;
}
md= (struct make_dep*)malloc(sizeof(struct make_dep)+strlen(name)-1);
if(!md)fatal("! No memory"," for make dependency name");

md->next= NULL;
strcpy(md->name,name);
if(ch_make_dep[ch])last_md->next= md;
else ch_make_dep[ch]= md;
return md;
}

/*:183*//*186:*/
#line 3408 "mctangle.w"

struct book_node*
add_book_dep(type,name)
char*name;
{
struct book_node*bn,*last_bn= NULL,*found= NULL,*last_found;
for(bn= books_head;bn;bn= bn->next){
if(!strcmp(bn->name,name)){
found= bn;
last_found= last_bn;
}
last_bn= bn;
}
if(found){
#ifdef MOVE_TO_TAIL
if(found!=last_bn){
if(last_found)last_found->next= found->next;
else books_head= found->next;
last_bn->next= found;
found->next= NULL;
}
#endif
return NULL;
}
bn= (struct book_node*)malloc(sizeof(struct book_node)+strlen(name)-1);
if(!bn)fatal("! No memory"," for book dependency name");

bn->next= NULL;
bn->type= type;
strcpy(bn->name,name);
if(books_head)last_bn->next= bn;
else books_head= bn;
return bn;
}

/*:186*//*187:*/
#line 3446 "mctangle.w"

void
create_dependencies(ch)
{
struct dependency_node*dep;
char*cp;

ch_make_dep[ch]= NULL;
for(dep= chapter_dep_head[ch];dep;dep= dep->next)
if(dep->dep_type==dep_import_chapter){
strcpy(dep_file_name,dep->name);
cp= file_name_ext(dep_file_name);
if(cp)*cp= 0;
strcat(dep_file_name,".shr");
add_make_dep(ch,dep_file_name);
exp_file_name_of(dep_file_name,dep->name,".dep");
add_chapter_to_dep(ch,dep_import_chapter);
}
for(dep= chapter_dep_head[ch];dep;dep= dep->next)
add_transitive_deps(ch,dep->dep_type,dep->name);
}

/*:187*//*188:*/
#line 3472 "mctangle.w"

void
add_transitive_deps(ch,type,name)
char*name;
{
char*cp;

strcpy(dep_file_name,dep_dir);
strcat(dep_file_name,name);
cp= file_name_ext(dep_file_name);
if(cp)*cp= 0;
strcat(dep_file_name,".dep");
switch(type){
case dep_from_program_import:
case dep_from_library_import:
add_book_dep(type==dep_from_program_import?book_program:book_library,name);
break;
case dep_book_chapter:
add_chapter_to_dep(ch,type);
break;
case dep_import_program:
case dep_import_library:
add_book_dep(type==dep_import_program?book_program:book_library,name);
add_book_to_dep(ch);
break;
}
}

/*:188*//*189:*/
#line 3506 "mctangle.w"

void
add_chapter_to_dep(ch,type)
{
FILE*f;
char*cp,exp,*buf,*depname;

if(type==dep_book_chapter){
cp= dep_file_name+strlen(dep_file_name)-3;
strcpy(cp,"exp");
if(!add_make_dep(ch,dep_file_name))
return;
strcpy(cp,"dep");
}
f= fopen(dep_file_name,"r");
if(!f){
printf("\n! Cannot open chapter dependency file %s\n",dep_file_name);

mark_error;
return;
}
while(fgets(buffer,sizeof(buffer),f)){
cp= strrchr(buffer,'\n');
if(cp)*cp= 0;
sscanf(buffer,"%c%d",&exp,&type);
if(exp==' ')continue;
cp= buffer+1;
while(isdigit(*cp))cp++;
while(isspace(*cp))cp++;
buf= strmem(cp);
depname= strmem(dep_file_name);
add_transitive_deps(ch,type,buf);
strcpy(dep_file_name,depname);
free(depname);
free(buf);
}
fclose(f);
}

/*:189*//*190:*/
#line 3547 "mctangle.w"

void
add_book_to_dep(ch)
{
FILE*f;
char*cp;

f= fopen(dep_file_name,"r");
if(!f){
printf("\n! Cannot open book dependency file %s\n",dep_file_name);

mark_error;
return;
}
while(fgets(buffer,sizeof(buffer),f)){
cp= strrchr(buffer,'\n');
if(cp)*cp= 0;
cp= file_name_part(dep_file_name);
strcpy(cp,buffer);
strcat(cp,".dep");
add_chapter_to_dep(ch,dep_book_chapter);
}
fclose(f);
}

/*:190*//*194:*/
#line 3618 "mctangle.w"

void
remember_import()
{
if(import_idx>=max_imports)overflow("imports per section");
import_ref[import_idx]= tok_ptr;
import_idx++;
}

/*:194*//*196:*/
#line 3633 "mctangle.w"

void process_imports()
{
int i,j;
eight_bits*tk;
sixteen_bits a;
boolean exported;
char name[max_quoted_name];

for(i= j= 0;i<import_idx;i++){
tk= import_ref[i];
exported= 0;
if(0200<=*tk&&*tk<0250){
a= (tk[0]-0200)<<8|tk[1];
tk+= 2;
if(a==id_from)
/*199:*/
#line 3692 "mctangle.w"

{
eight_bits*cp= tk-2;
char*ch_name;
int dep_type;

if(0200<=*tk&&*tk<0250){
a= (tk[0]-0200)<<8|tk[1];
tk+= 2;
if(a==id_program||a==id_library){
if(*tk==string){
tk= get_quoted_name(tk,name);
/*200:*/
#line 3743 "mctangle.w"

{
if(!strchr(name,file_name_separator)){
int len= strlen(name);
strcpy(name+len+1,name);
name[len]= file_name_separator;
}
}


/*:200*/
#line 3704 "mctangle.w"
;
dep_type= a==id_program?dep_from_program_import:dep_from_library_import;
ch_name= file_name_part(name);

if(0200<=*tk&&*tk<0250){
a= (tk[0]-0200)<<8|tk[1];
tk+= 2;
if(a==id_import){
if(0200<=*tk&&*tk<0250&&(tk[0]-0200)<<8|tk[1]==id_transitively){
exported= 1;
tk+= 2;
}
directly_depending_on(name,dep_type,exported);
while(*tk==string){
tk= get_quoted_name(tk,ch_name);
directly_depending_on(name,dep_book_chapter,exported);
if(*tk==',')tk++;
}
}
else err_print("! 'import' expected after book name");

}
else err_print("! 'import' expected after book name");
}
else err_print("! Import from where?");

}
else err_print("! Import source must be program or library");

}
else err_print("! Import from where (program or library)?");
do*cp++= ignore;while(cp<tk);
}

/*:199*/
#line 3649 "mctangle.w"

else if(a==id_import)
/*201:*/
#line 3762 "mctangle.w"

{
eight_bits*cp= tk-2;
int type;

if(0200<=*tk&&*tk<0250&&(tk[0]-0200)<<8|tk[1]==id_transitively){
tk+= 2;
exported= 1;
}
if(0200<=*tk&&*tk<0250){
a= (tk[0]-0200)<<8|tk[1];
tk+= 2;
if(a==id_chapter||a==id_program||a==id_library){
if(*tk==string){
while(*tk==string){
tk= get_quoted_name(tk,name);
if(a==id_chapter)
type= dep_import_chapter;
else{
/*200:*/
#line 3743 "mctangle.w"

{
if(!strchr(name,file_name_separator)){
int len= strlen(name);
strcpy(name+len+1,name);
name[len]= file_name_separator;
}
}


/*:200*/
#line 3781 "mctangle.w"
;
if(a==id_program)type= dep_import_program;
else type= dep_import_library;
}
directly_depending_on(name,type,exported);
if(*tk==',')tk++;
}
}
else err_print("! Import what?");

}
else err_print("! Import source must be chapter, program or library");

}
else err_print("! Import from where (chapter, program or library)?");

do*cp++= ignore;while(cp<tk);
}

/*:201*/
#line 3651 "mctangle.w"

}
if(exported)used_exports|= exp_export;
}
import_idx= 0;
}

/*:196*//*198:*/
#line 3665 "mctangle.w"

static eight_bits*
get_quoted_name(tk,buffer)
eight_bits*tk,*buffer;
{
int i= 0;
if(*tk==string)tk+= 2;
do{
if(i>=max_quoted_name-1){
buffer[max_quoted_name-1]= 0;
fatal("! Name too long:",buffer);

}
buffer[i++]= *tk;
}while(*++tk!=string);
buffer[i-1]= 0;
return++tk;
}

/*:198*//*214:*/
#line 4011 "mctangle.w"

char*strmem(s)
char*s;
{
char*cp= malloc(strlen(s)+1);
if(!cp)fatal("! No memory for string ",s);

return strcpy(cp,s);
}

/*:214*//*218:*/
#line 4047 "mctangle.w"

char*
file_name_part(s)
char*s;
{
char*slash_pos;
slash_pos= strrchr(s,file_name_separator);
if(slash_pos)slash_pos++;
else slash_pos= s;
return slash_pos;
}

/*:218*//*219:*/
#line 4060 "mctangle.w"

void to_parent(s)
char*s;
{
char*cp= file_name_part(s);
if(cp==s)*cp= 0;
else cp[-1]= 0;
}

/*:219*//*220:*/
#line 4070 "mctangle.w"

char*
file_name_ext(s)
char*s;
{
return strrchr(file_name_part(s),'.');
}

/*:220*//*222:*/
#line 4084 "mctangle.w"

char*
get_name(cp,buffer)
char*cp,*buffer;
{
int i;

while(isspace(*cp))cp++;
if(*cp==QUOTE){
cp++;
for(i= 0;i<max_file_name_length;i++)
if(*cp==QUOTE){
*buffer= 0;
return++cp;
}
else*buffer++= *cp++;
}
else{
for(i= 0;i<max_file_name_length;i++)
if(!*cp||isspace(*cp)){
*buffer= 0;
if(!i)return 0;
return cp;
}
else*buffer++= *cp++;
}
*buffer= 0;
return 0;
}

/*:222*//*230:*/
#line 4293 "mctangle.w"

char*
exp_file_name_of(expname,basename,suffix)
char*expname,*basename,*suffix;
{
char*dot,*ret,*cp;

strcpy(expname,dep_dir);
ret= expname+strlen(expname);
strcat(expname,book_name);
strcat(expname,file_name_sep_str);
cp= file_name_part(basename);
strcat(expname,cp);
dot= file_name_ext(expname);
if(dot)*dot= 0;
strcat(expname,suffix);
return ret;
}

/*:230*//*235:*/
#line 4359 "mctangle.w"

void
chapter_to_book_exp()
{
char*cp= exp_file_name_of(a_file_name,file_name[0],".exp");
fprintf(book_exp_file,"#include \"%s\"\n",cp);
}

/*:235*//*239:*/
#line 4398 "mctangle.w"

void
mf_print(prefix,s,ext)
char*prefix,*s,*ext;
{
int slen;
char*cp;

if(prefix)strcpy(buffer,prefix);
else*buffer= 0;
strcat(buffer,s);
if(ext){
cp= file_name_ext(buffer);
if(cp)*cp= 0;
strcat(buffer,ext);
}
slen= strlen(buffer);
make_col+= slen;
if(make_col>=max_col){
fprintf(make_file,"\\\n%s",buffer);
make_col= slen;
}
else fprintf(make_file,buffer);
}

/*:239*/
