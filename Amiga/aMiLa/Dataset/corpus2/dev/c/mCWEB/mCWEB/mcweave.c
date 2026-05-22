/*1:*/
#line 70 "mcweave.w"
/*7:*/
#line 36 "mcommon.h"

#include <stdio.h>

/*:7*//*41:*/
#line 734 "mcweave.w"

#include <ctype.h> 
#include <stdlib.h> 
#include <sys/stat.h>

/*:41*/
#line 70 "mcweave.w"

#define mcweave_c
#define banner "This is mCWEAVE (Version 1.1)\n" \

#define max_bytes 90000 \

#define max_names 10000 \

#define max_sections 2000
#define hash_size 353
#define buf_size 256
#define longest_name 1000
#define long_buf_size (buf_size+longest_name) 
#define line_length 80 \

#define max_refs 20000
#define max_toks 60000 \

#define max_texts 10000 \

#define max_scraps 40000
#define stack_size 400 \

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

#define ilk dummy.Ilk
#define normal 0
#define roman 1
#define wildcard 2
#define typewriter 3
#define abnormal(a) (a->ilk>typewriter) 
#define custom 4
#define unindexed(a) (a->ilk>custom) 
#define quoted 5
#define else_like 26
#define public_like 40
#define operator_like 41
#define new_like 42
#define catch_like 43
#define for_like 45
#define do_like 46
#define if_like 47
#define raw_rpar 48
#define raw_unorbin 49
#define const_like 50
#define raw_int 51
#define int_like 52
#define case_like 53
#define sizeof_like 54
#define struct_like 55
#define typedef_like 56
#define define_like 57 \

#define own_shared ((struct external_reference*) -1L) 
#define own_export ((struct external_reference*) -2L) 
#define file_flag (3*cite_flag) 
#define def_flag (2*cite_flag) 
#define cite_flag 10240
#define xref equiv_or_xref \

#define append_xref(c) if(xref_ptr==xmem_end) overflow("cross-reference") ; \
else(++xref_ptr) ->num= c;
#define no_xref (flags['x']==0) 
#define make_xrefs flags['x']
#define is_tiny(p) ((p+1) ->byte_start==(p) ->byte_start+1)  \

#define ignore 00
#define verbatim 02
#define begin_short_comment 03
#define begin_comment '\t'
#define underline '\n'
#define noop 0177
#define xref_roman 0203
#define xref_wildcard 0204
#define xref_typewriter 0205
#define TeX_string 0206
#define ord 0207
#define join 0210
#define thin_space 0211
#define math_break 0212
#define line_break 0213
#define big_line_break 0214
#define no_line_break 0215
#define pseudo_semi 0216
#define special_command 0220
#define macro_arg_open 0221
#define macro_arg_close 0222
#define trace 0223
#define translit_code 0224
#define output_defs_code 0225
#define autodoc_code 0226
#define example_code 0227
#define format_code 0230
#define definition 0231
#define begin_C 0232
#define section_name 0233
#define new_section 0234 \

#define constant 0200
#define string 0201
#define identifier 0202 \

#define isxalpha(c) ((c) =='_') 
#define ishigh(c) ((eight_bits) (c) >0177)  \
 \

#define left_preproc ord
#define right_preproc 0217 \

#define compress(c) if(loc++<limit) return(c)  \

#define Cxx flags['+']
#define c_line_write(c) fflush(active_file) ,fwrite(out_buf+1,sizeof(char) ,c,active_file) 
#define tex_putc(c) putc(c,active_file) 
#define tex_new_line putc('\n',active_file) 
#define tex_printf(c) fprintf(active_file,c)  \

#define out(c) {if(out_ptr>=out_buf_end) break_out() ;*(++out_ptr) = c;} \

#define app_tok(c) {if(tok_ptr+2>tok_mem_end) overflow("token") ;*(tok_ptr++) = c;} \

#define exp 1
#define unop 2
#define binop 3
#define unorbinop 4 \

#define cast 5
#define question 6
#define lbrace 7
#define rbrace 8
#define decl_head 9
#define comma 10
#define lpar 11
#define rpar 12
#define prelangle 13
#define prerangle 14
#define langle 15
#define colcol 18
#define base 19
#define decl 20
#define struct_head 21
#define stmt 23
#define function 24
#define fn_decl 25
#define semi 27
#define colon 28
#define tag 29
#define if_head 30
#define else_head 31
#define if_clause 32
#define lproc 35
#define rproc 36
#define insert 37
#define section_scrap 38
#define dead 39
#define begin_arg 58
#define end_arg 59 \

#define math_rel 0206
#define big_cancel 0210
#define cancel 0211
#define indent 0212
#define outdent 0213
#define opt 0214
#define backup 0215
#define break_space 0216
#define force 0217
#define big_force 0220
#define preproc_line 0221 \

#define quoted_char 0222 \

#define end_translation 0223
#define inserted 0224 \

#define trans trans_plus.Trans \

#define id_flag 10240
#define res_flag 2*id_flag
#define section_flag 3*id_flag
#define tok_flag 4*id_flag
#define inner_tok_flag 5*id_flag \

#define no_math 2
#define yes_math 1
#define maybe_math 0
#define big_app2(a) big_app1(a) ;big_app1(a+1) 
#define big_app3(a) big_app2(a) ;big_app1(a+2) 
#define big_app4(a) big_app3(a) ;big_app1(a+3) 
#define app(a) *(tok_ptr++) = a
#define app1(a) *(tok_ptr++) = tok_flag+(int) ((a) ->trans-tok_start)  \

#define cat1 (pp+1) ->cat
#define cat2 (pp+2) ->cat
#define cat3 (pp+3) ->cat
#define lhs_not_simple (pp->cat!=semi&&pp->cat!=raw_int&&pp->cat!=raw_unorbin \
&&pp->cat!=raw_rpar&&pp->cat!=const_like)  \

#define no_ident_found 0 \

#define force_lines flags['f']
#define freeze_text *(++text_ptr) = tok_ptr \

#define safe_tok_incr 20
#define safe_text_incr 10
#define safe_scrap_incr 10 \

#define app_scrap(c,b) { \
(++scrap_ptr) ->cat= (c) ;scrap_ptr->trans= text_ptr; \
scrap_ptr->mathness= 5*(b) ; \
freeze_text; \
} \

#define inner 0
#define outer 1 \

#define cur_end cur_state.end_field
#define cur_tok cur_state.tok_field
#define cur_mode cur_state.mode_field
#define init_stack stack_ptr= stack;cur_mode= outer \

#define res_word 0201
#define section_code 0200 \

#define save_position save_line= out_line;save_place= out_ptr
#define emit_space_if_needed if(save_line!=out_line||save_place!=out_ptr)  \
out_str("\\Y") ; \
space_checked= 1 \
 \

#define depth cat
#define head trans_plus.Head
#define sort_pointer scrap_pointer
#define sort_ptr scrap_ptr
#define max_sorts max_scraps \

#define infinity 255 \

#define file_name_separator '/'
#define file_name_sep_str "/"
#define is_absolute_path(file_name) (strchr(file_name,':') ) 
#define include_dir_separator ','
#define report_include flags['i']
#define max_token_sec_info 300
#define max_section_nest 16
#define longest_name 1000
#define long_buf_size (buf_size+longest_name) 
#define max_include_depth 10
#define no_book 0
#define book_program 1
#define book_library 2
#define max_chapters 64
#define max_ref_per_chapter 128
#define max_desc_size 10240
#define app_adoc(c) {if(desc_ptr>=desc_mem_end) overflow("autodoc description") ; \
if(c) *desc_ptr++= (c) ;}

#line 71 "mcweave.w"

/*6:*/
#line 30 "mcommon.h"

typedef short boolean;
typedef char unsigned eight_bits;
extern boolean program;
extern int phase;

/*:6*//*8:*/
#line 58 "mcommon.h"

char section_text[longest_name+1];
char*section_text_end= section_text+longest_name;
char*id_first;
char*id_loc;

/*:8*//*9:*/
#line 73 "mcommon.h"

extern char buffer[];
extern char*buffer_end;
extern char*loc;
extern char*limit;

/*:9*//*10:*/
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

/*:10*//*11:*/
#line 123 "mcommon.h"

extern history;
extern err_print();
extern wrap_up();
extern void fatal();
extern void overflow();

/*:11*//*12:*/
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

/*:12*//*13:*/
#line 159 "mcommon.h"

typedef unsigned short sixteen_bits;
extern sixteen_bits section_count;
extern boolean changed_section[];
extern boolean change_pending;
extern boolean print_where;

/*:13*//*14:*/
#line 171 "mcommon.h"

extern int argc;
extern char**argv;
extern boolean flags[];

/*:14*//*15:*/
#line 183 "mcommon.h"

extern FILE*C_file;
extern FILE*tex_file;
extern FILE*idx_file;
extern FILE*scn_file;
extern FILE*active_file;

/*:15*//*16:*/
#line 192 "mcommon.h"

extern void common_init();
#line 171 "mcweave.w"

/*:16*/
#line 72 "mcweave.w"

/*19:*/
#line 261 "mcweave.w"

typedef struct xref_info{
sixteen_bits num;
struct xref_info*xlink;
struct external_reference*ext_ref;
}xref_info;
typedef xref_info*xref_pointer;

/*:19*//*25:*/
#line 384 "mcweave.w"

typedef sixteen_bits token;
typedef token*token_pointer;
typedef token_pointer*text_pointer;

/*:25*//*116:*/
#line 2276 "mcweave.w"

typedef struct{
eight_bits cat;
eight_bits mathness;
union{
text_pointer Trans;
/*260:*/
#line 4877 "mcweave.w"

name_pointer Head;

/*:260*/
#line 2282 "mcweave.w"

}trans_plus;
}scrap;
typedef scrap*scrap_pointer;

/*:116*//*212:*/
#line 3981 "mcweave.w"
typedef int mode;
typedef struct{
token_pointer end_field;
token_pointer tok_field;
boolean mode_field;
}output_state;
typedef output_state*stack_pointer;

/*:212*//*297:*/
#line 5409 "mcweave.w"

struct imported_file{
struct imported_file*next_imported_file;
int tangled_file;
char*given_name;
char file_name[2];
};

/*:297*//*306:*/
#line 5593 "mcweave.w"

struct external_reference{
struct external_reference*next_ext_ref;
char*book_name;
int chapter;
};

/*:306*//*366:*/
#line 6633 "mcweave.w"

struct adoc_class{
struct adoc_class*next;
struct adoc*first_adoc;
char class_name[2];
};

/*:366*//*367:*/
#line 6641 "mcweave.w"

struct adoc{
struct adoc*next;
char*description;
char name[2];
};

/*:367*//*384:*/
#line 7007 "mcweave.w"

struct copy_buffer{
struct copy_buffer*next;
char*start;
char*end;
char name[2];
};

/*:384*/
#line 73 "mcweave.w"

/*18:*/
#line 17 "mcweave-Amiga.ch"

char*version_tag= "\0$VER: mCWEAVE 1.1 (4.10.98)";
boolean change_exists;
#line 230 "mcweave.w"

/*:18*//*20:*/
#line 269 "mcweave.w"

xref_info xmem[max_refs];
xref_pointer xmem_end= xmem+max_refs-1;
xref_pointer xref_ptr;
sixteen_bits xref_switch,section_xref_switch;

/*:20*//*26:*/
#line 394 "mcweave.w"

token tok_mem[max_toks];
token_pointer tok_mem_end= tok_mem+max_toks-1;
token_pointer tok_start[max_texts];
token_pointer tok_ptr;
text_pointer text_ptr;
text_pointer tok_start_end= tok_start+max_texts-1;
token_pointer max_tok_ptr;
text_pointer max_text_ptr;

/*:26*//*30:*/
#line 524 "mcweave.w"

name_pointer id_import;
name_pointer id_from;
name_pointer id_chapter;
name_pointer id_program;
name_pointer id_library;
name_pointer id_transitively;
name_pointer id_global;
name_pointer id_shared;
name_pointer id_export;
name_pointer id_mark;
name_pointer id_copy;
name_pointer id_paste;

/*:30*//*34:*/
#line 608 "mcweave.w"

eight_bits ccode[256];

/*:34*//*40:*/
#line 730 "mcweave.w"

name_pointer cur_section;
char cur_section_char;

/*:40*//*44:*/
#line 784 "mcweave.w"

boolean preprocessing= 0;

/*:44*//*46:*/
#line 797 "mcweave.w"

boolean sharp_include_line= 0;

/*:46*//*61:*/
#line 1076 "mcweave.w"

eight_bits next_control;

/*:61*//*67:*/
#line 1187 "mcweave.w"

static int typedefing;

/*:67*//*76:*/
#line 1348 "mcweave.w"

name_pointer lhs,rhs;

/*:76*//*81:*/
#line 1431 "mcweave.w"

xref_pointer cur_xref;
boolean an_output;

/*:81*//*85:*/
#line 1473 "mcweave.w"

char out_buf[line_length+1];
char*out_ptr;
char*out_buf_end= out_buf+line_length;
int out_line;

/*:85*//*91:*/
#line 1582 "mcweave.w"

extern char mcwebmac_prefix[];

/*:91*//*92:*/
#line 1586 "mcweave.w"

char a_file_name[max_file_name_length];

/*:92*//*110:*/
#line 1934 "mcweave.w"

char cat_name[256][12];
eight_bits cat_index;

/*:110*//*117:*/
#line 2289 "mcweave.w"

scrap scrap_info[max_scraps];
scrap_pointer scrap_info_end= scrap_info+max_scraps-1;
scrap_pointer pp;
scrap_pointer scrap_base;
scrap_pointer scrap_ptr;
scrap_pointer lo_ptr;
scrap_pointer hi_ptr;
scrap_pointer max_scr_ptr;

/*:117*//*121:*/
#line 2448 "mcweave.w"

int cur_mathness,init_mathness;

/*:121*//*146:*/
#line 2939 "mcweave.w"

boolean ext_ref_seen,struct_like_seen;

/*:146*//*185:*/
#line 3347 "mcweave.w"

int tracing;

/*:185*//*207:*/
#line 3901 "mcweave.w"

boolean is_example;

/*:207*//*213:*/
#line 3994 "mcweave.w"

output_state cur_state;
output_state stack[stack_size];
stack_pointer stack_ptr;
stack_pointer stack_end= stack+stack_size-1;
stack_pointer max_stack_ptr;

/*:213*//*217:*/
#line 4044 "mcweave.w"

name_pointer cur_name;

/*:217*//*233:*/
#line 4401 "mcweave.w"

int save_line;
char*save_place;
int sec_depth;
boolean space_checked;
boolean format_visible;
boolean doing_format= 0;
boolean group_found= 0;

/*:233*//*244:*/
#line 4628 "mcweave.w"

name_pointer this_section;

/*:244*//*255:*/
#line 4818 "mcweave.w"

sixteen_bits k_section;

/*:255*//*257:*/
#line 4844 "mcweave.w"

name_pointer bucket[256];
name_pointer next_name;
name_pointer blink[max_names];

/*:257*//*261:*/
#line 4887 "mcweave.w"

eight_bits cur_depth;
char*cur_byte;
sixteen_bits cur_val;
sort_pointer max_sort_ptr;

/*:261*//*263:*/
#line 4899 "mcweave.w"

eight_bits collate[102+128];


/*:263*//*274:*/
#line 5066 "mcweave.w"

xref_pointer next_xref,this_xref;


/*:274*//*276:*/
#line 5080 "mcweave.w"

boolean dag_seen,ddag_seen;

/*:276*//*291:*/
#line 5273 "mcweave.w"

char*dep_dir;

/*:291*//*298:*/
#line 5427 "mcweave.w"

struct imported_file*first_imported_file;
struct imported_file*current_imported_file;

/*:298*//*307:*/
#line 5601 "mcweave.w"

struct external_reference*first_ext_ref;

/*:307*//*314:*/
#line 5717 "mcweave.w"

struct token_section{
token_pointer token_ptr;
int section_count;
}token_sec_info[max_token_sec_info];
struct token_section*token_sec_ptr;
extern boolean parsing_exp_file;

/*:314*//*318:*/
#line 5760 "mcweave.w"

static char foreign_book_name[max_file_name_length];
int foreign_chapter;
struct external_reference*ext_ref;

/*:318*//*326:*/
#line 5931 "mcweave.w"

int sec_cnt_stack[max_section_nest];
int sec_cnt_sp;

/*:326*//*335:*/
#line 6031 "mcweave.w"

int book_type;
char book_file_name[max_file_name_length];
char book_name[max_file_name_length];
char chapter_name[max_file_name_length];
char out_file_name[max_file_name_length];
char book_dir[max_file_name_length];

/*:335*//*336:*/
#line 6041 "mcweave.w"

int chapter_no;

/*:336*//*340:*/
#line 6130 "mcweave.w"

char*ch_web_name[max_chapters];
char*ch_change_name[max_chapters];
char*ch_out_name[max_chapters];
int n_chapters_remembered;

/*:340*//*350:*/
#line 6303 "mcweave.w"

char*ch_TeX_name[max_chapters];

/*:350*//*363:*/
#line 6609 "mcweave.w"

boolean keep_only_ext_def= 0;

/*:363*//*368:*/
#line 6649 "mcweave.w"

struct adoc_class*first_adoc_class;

/*:368*//*375:*/
#line 6788 "mcweave.w"

char desc_mem[max_desc_size];
char*desc_mem_end= desc_mem+max_desc_size;
char*desc_ptr;
boolean is_adoc;

/*:375*//*383:*/
#line 7001 "mcweave.w"

extern char*copy_ptr,*copy_end;
extern boolean copy_from_buffer,copy_to_buffer;
extern char*rest_after_paste;

/*:383*//*385:*/
#line 7017 "mcweave.w"

struct copy_buffer*first_copy_buffer;
struct copy_buffer*current_copy_buffer;

/*:385*/
#line 74 "mcweave.w"

/*2:*/
#line 82 "mcweave.w"

extern int strlen();
#line 9 "mcweave-Amiga.ch"
extern int strcmp();
extern int stricmp();
#line 85 "mcweave.w"
extern char*strcpy();
extern int strncmp();
extern char*strncpy();
extern char*strrchr();
extern char*strchr();

/*:2*//*37:*/
#line 652 "mcweave.w"

void skip_limbo();

/*:37*//*42:*/
#line 746 "mcweave.w"

eight_bits get_next();

/*:42*//*58:*/
#line 1029 "mcweave.w"

void skip_restricted();

/*:58*//*62:*/
#line 1082 "mcweave.w"

void phase_one();

/*:62*//*65:*/
#line 1135 "mcweave.w"

void C_xref();

/*:65*//*71:*/
#line 1251 "mcweave.w"

void outer_xref();

/*:71*//*82:*/
#line 1439 "mcweave.w"

void section_check();

/*:82*//*88:*/
#line 1534 "mcweave.w"

void finish_line();

/*:88*//*93:*/
#line 1590 "mcweave.w"

void out_str();

/*:93*//*96:*/
#line 1622 "mcweave.w"

void break_out();

/*:96*//*104:*/
#line 1770 "mcweave.w"

int copy_comment();

/*:104*//*127:*/
#line 2656 "mcweave.w"

void underline_xref();

/*:127*//*147:*/
#line 2943 "mcweave.w"

void reset_ext_refs();
xref_pointer defined_here();

/*:147*//*200:*/
#line 3724 "mcweave.w"

void append_string();

/*:200*//*203:*/
#line 3811 "mcweave.w"

void app_cur_id();

/*:203*//*209:*/
#line 3909 "mcweave.w"

void process_example();

/*:209*//*220:*/
#line 4113 "mcweave.w"

void make_output();

/*:220*//*231:*/
#line 4374 "mcweave.w"

void phase_two();

/*:231*//*240:*/
#line 4531 "mcweave.w"

void finish_C();

/*:240*//*249:*/
#line 4712 "mcweave.w"

void footnote();

/*:249*//*253:*/
#line 4761 "mcweave.w"

void phase_three();

/*:253*//*265:*/
#line 4932 "mcweave.w"

void unbucket();

/*:265*//*270:*/
#line 4993 "mcweave.w"

boolean only_ext_def();

/*:270*//*279:*/
#line 5117 "mcweave.w"

void output_referenced_books();

/*:279*//*281:*/
#line 5161 "mcweave.w"

void section_print();

/*:281*//*287:*/
#line 5229 "mcweave.w"

char*file_name_ext();
char*file_name_part();
void to_parent();

/*:287*//*300:*/
#line 5437 "mcweave.w"

struct imported_file*remember_import_file();
void remember_include_file();

/*:300*//*309:*/
#line 5609 "mcweave.w"

char*strmem();

/*:309*//*312:*/
#line 5671 "mcweave.w"

void process_imported_files();

/*:312*//*315:*/
#line 5726 "mcweave.w"

void new_token_section();

/*:315*//*319:*/
#line 5766 "mcweave.w"

void parse_imported_file();

/*:319*//*321:*/
#line 5828 "mcweave.w"

void translate_and_reset();

/*:321*//*323:*/
#line 5852 "mcweave.w"

void parse_comment();

/*:323*//*327:*/
#line 5936 "mcweave.w"

void push_sec_cnt();
int pop_sec_cnt();

/*:327*//*331:*/
#line 5969 "mcweave.w"

void remember_export_file();

/*:331*//*334:*/
#line 6017 "mcweave.w"

extern char buffer[long_buf_size];
extern char file_name[max_include_depth][max_file_name_length];
extern char alt_web_file_name[max_file_name_length];
extern char**argv_web,**argv_change,**argv_out;
extern char tex_file_name[max_file_name_length];
extern char alt_web_file_name[max_file_name_length];
extern char change_file_name[max_file_name_length];

/*:334*//*347:*/
#line 6229 "mcweave.w"

char*get_name();
extern int input_ln();

/*:347*//*353:*/
#line 6326 "mcweave.w"

void make_xid_file();

/*:353*//*356:*/
#line 6419 "mcweave.w"

void make_iid_file();

/*:356*//*360:*/
#line 6554 "mcweave.w"

void make_book_xref();

/*:360*//*362:*/
#line 6603 "mcweave.w"

void sort_and_output_index();

/*:362*//*372:*/
#line 6722 "mcweave.w"

void process_autodoc();

/*:372*//*378:*/
#line 6883 "mcweave.w"

void output_adocs();

/*:378*//*387:*/
#line 7027 "mcweave.w"

void mark(),copy(),paste();

/*:387*/
#line 75 "mcweave.w"


/*:1*//*3:*/
#line 99 "mcweave.w"

int main(ac,av)
int ac;
char**av;
{
argc= ac;argv= av;
program= cweave;

make_xrefs= force_lines= 1;
show_banner= show_happiness= show_progress= 1;
scan_args();
if(show_banner)printf(banner);
argc= ac;argv= av;

/*369:*/
#line 6653 "mcweave.w"

first_adoc_class= NULL;

/*:369*/
#line 113 "mcweave.w"
;

/*337:*/
#line 6046 "mcweave.w"

{
int ret_val= 0;
int len,c;
char*cp;

/*338:*/
#line 6083 "mcweave.w"

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

/*:338*/
#line 6052 "mcweave.w"
;
len= strlen(file_name[0]);
if(!strcmp(file_name[0]+len-4,".prg")||flags['m']){
book_type= 1;
change_file= NULL;
reset_input();
strcpy(book_file_name,file_name[0]);
/*345:*/
#line 6215 "mcweave.w"

strcpy(book_dir,book_file_name);
cp= file_name_part(book_dir);
*cp= 0;

/*:345*/
#line 6059 "mcweave.w"
;
/*346:*/
#line 6222 "mcweave.w"

cp= file_name_part(file_name[0]);
strcpy(book_name,cp);
cp= file_name_ext(book_name);
if(cp)*cp= 0;

/*:346*/
#line 6060 "mcweave.w"
;
if(show_progress)printf("Book '%s'\n",book_name);
tex_file= fopen(tex_file_name,"w");
if(!tex_file)
fatal("! Cannot open TeX file for book: ",tex_file_name);

/*21:*/
#line 283 "mcweave.w"

memset(xmem,0,sizeof(xmem));
xref_ptr= xmem;name_dir->xref= (char*)xmem;xref_switch= 0;section_xref_switch= 0;
xmem->num= 0;

/*:21*//*27:*/
#line 404 "mcweave.w"

tok_ptr= tok_mem+1;text_ptr= tok_start+1;tok_start[0]= tok_mem+1;
tok_start[1]= tok_mem+1;
max_tok_ptr= tok_mem+1;max_text_ptr= tok_start+1;

/*:27*//*35:*/
#line 611 "mcweave.w"

{int c;for(c= 0;c<256;c++)ccode[c]= 0;}
ccode[' ']= ccode['\t']= ccode['\n']= ccode['\v']= ccode['\r']= ccode['\f']
= ccode['*']= new_section;
ccode['@']= '@';
ccode['=']= verbatim;
ccode['a']= ccode['A']= autodoc_code;
ccode['d']= ccode['D']= definition;
ccode['e']= ccode['E']= example_code;
ccode['f']= ccode['F']= ccode['s']= ccode['S']= format_code;
ccode['c']= ccode['C']= ccode['p']= ccode['P']= begin_C;
ccode['t']= ccode['T']= TeX_string;
ccode['l']= ccode['L']= translit_code;
ccode['q']= ccode['Q']= noop;
ccode['h']= ccode['H']= output_defs_code;
ccode['&']= join;ccode['<']= ccode['(']= section_name;
ccode['!']= underline;ccode['^']= xref_roman;
ccode[':']= xref_wildcard;ccode['.']= xref_typewriter;ccode[',']= thin_space;
ccode['|']= math_break;ccode['/']= line_break;ccode['#']= big_line_break;
ccode['+']= no_line_break;ccode[';']= pseudo_semi;
ccode['[']= macro_arg_open;ccode[']']= macro_arg_close;
ccode['\'']= ord;
ccode['_']= special_command;
/*36:*/
#line 640 "mcweave.w"

ccode['0']= ccode['1']= ccode['2']= trace;

/*:36*/
#line 634 "mcweave.w"


/*:35*//*55:*/
#line 984 "mcweave.w"
section_text[0]= ' ';

/*:55*//*68:*/
#line 1191 "mcweave.w"

typedefing= 0;

/*:68*//*90:*/
#line 1563 "mcweave.w"

out_ptr= out_buf+1;out_line= 1;active_file= tex_file;
if(book_type&&*chapter_name){
char*cp;
strcpy(a_file_name,tex_file_name);
cp= file_name_ext(a_file_name);
if(cp)*cp= 0;
*out_ptr= '}';
tex_printf("\\def\\curjob{");
tex_printf(a_file_name);
}
else{
sprintf(a_file_name,"\\input %smcwebma",mcwebmac_prefix);
*out_ptr= 'c';tex_printf(a_file_name);
}

/*:90*//*95:*/
#line 1615 "mcweave.w"

out_buf[0]= '\\';

/*:95*//*111:*/
#line 1938 "mcweave.w"

for(cat_index= 0;cat_index<255;cat_index++)
strcpy(cat_name[cat_index],"UNKNOWN");
strcpy(cat_name[exp],"exp");
strcpy(cat_name[unop],"unop");
strcpy(cat_name[binop],"binop");
strcpy(cat_name[unorbinop],"unorbinop");
strcpy(cat_name[cast],"cast");
strcpy(cat_name[question],"?");
strcpy(cat_name[lbrace],"{");
strcpy(cat_name[rbrace],"}");
strcpy(cat_name[decl_head],"decl_head");
strcpy(cat_name[comma],",");
strcpy(cat_name[lpar],"(");
strcpy(cat_name[rpar],")");
strcpy(cat_name[prelangle],"<");
strcpy(cat_name[prerangle],">");
strcpy(cat_name[langle],"\\<");
strcpy(cat_name[colcol],"::");
strcpy(cat_name[base],"\\:");
strcpy(cat_name[decl],"decl");
strcpy(cat_name[struct_head],"struct_head");
strcpy(cat_name[stmt],"stmt");
strcpy(cat_name[function],"function");
strcpy(cat_name[fn_decl],"fn_decl");
strcpy(cat_name[else_like],"else_like");
strcpy(cat_name[semi],";");
strcpy(cat_name[colon],":");
strcpy(cat_name[tag],"tag");
strcpy(cat_name[if_head],"if_head");
strcpy(cat_name[else_head],"else_head");
strcpy(cat_name[if_clause],"if()");
strcpy(cat_name[lproc],"#{");
strcpy(cat_name[rproc],"#}");
strcpy(cat_name[insert],"insert");
strcpy(cat_name[section_scrap],"section");
strcpy(cat_name[dead],"@d");
strcpy(cat_name[public_like],"public");
strcpy(cat_name[operator_like],"operator");
strcpy(cat_name[new_like],"new");
strcpy(cat_name[catch_like],"catch");
strcpy(cat_name[for_like],"for");
strcpy(cat_name[do_like],"do");
strcpy(cat_name[if_like],"if");
strcpy(cat_name[raw_rpar],")?");
strcpy(cat_name[raw_unorbin],"unorbinop?");
strcpy(cat_name[const_like],"const");
strcpy(cat_name[raw_int],"raw");
strcpy(cat_name[int_like],"int");
strcpy(cat_name[case_like],"case");
strcpy(cat_name[sizeof_like],"sizeof");
strcpy(cat_name[struct_like],"struct");
strcpy(cat_name[typedef_like],"typedef");
strcpy(cat_name[define_like],"define");
strcpy(cat_name[begin_arg],"@[");
strcpy(cat_name[end_arg],"@]");
strcpy(cat_name[0],"zero");

/*:111*//*118:*/
#line 2299 "mcweave.w"

scrap_base= scrap_info+1;
max_scr_ptr= scrap_ptr= scrap_info;

/*:118*//*208:*/
#line 3905 "mcweave.w"

is_example= 0;

/*:208*//*214:*/
#line 4001 "mcweave.w"

max_stack_ptr= stack;

/*:214*//*234:*/
#line 4411 "mcweave.w"

doing_format= group_found= 0;

/*:234*//*262:*/
#line 4893 "mcweave.w"

max_sort_ptr= scrap_info;

/*:262*//*264:*/
#line 4909 "mcweave.w"

collate[0]= 0;strcpy(collate+1," \1\2\3\4\5\6\7\10\11\12\13\14\15\16\17\
\20\21\22\23\24\25\26\27\30\31\32\33\34\35\36\37\
!\42#$%&'()*+,-./:;<=>?@[\\]^`{|}~_\
abcdefghijklmnopqrstuvwxyz0123456789\
\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\
\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\
\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\
\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\
\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\
\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\
\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\
\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377\
");

/*:264*//*277:*/
#line 5084 "mcweave.w"

dag_seen= ddag_seen= 0;

/*:277*//*292:*/
#line 5277 "mcweave.w"

dep_dir= getenv("DEPDIR");
if(!dep_dir)fatal("! Environment variable not set:","DEPDIR");


/*:292*//*299:*/
#line 5432 "mcweave.w"

first_imported_file= NULL;
current_imported_file= NULL;

/*:299*//*308:*/
#line 5605 "mcweave.w"

first_ext_ref= NULL;

/*:308*//*386:*/
#line 7022 "mcweave.w"

first_copy_buffer= NULL;
rest_after_paste= NULL;

/*:386*/
#line 6066 "mcweave.w"
;
/*339:*/
#line 6105 "mcweave.w"

while(get_line()){
if(loc==limit)out('\n');
finish_line();
while(loc<limit){
c= *loc++;
if(c=='@'){
switch(*loc++){
case'@':out('@');break;
case'c':/*341:*/
#line 6138 "mcweave.w"

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
cp= file_name_ext(a_file_name,'.');
if(cp)strcpy(cp,".tex");
ch_out_name[n_chapters_remembered]= strmem(a_file_name);
}
}
n_chapters_remembered++;
}
else err_print("! Chapter name expected");

}

/*:341*/
#line 6114 "mcweave.w"
;
/*342:*/
#line 6170 "mcweave.w"

{
char*cp;
out_str("\\input ");
if(ch_out_name[n_chapters_remembered-1])
out_str(ch_out_name[n_chapters_remembered-1]);
else{
strcpy(a_file_name,ch_web_name[n_chapters_remembered-1]);
cp= file_name_ext(a_file_name);
if(cp)*cp= 0;
out_str(a_file_name);
}
}

/*:342*/
#line 6115 "mcweave.w"
;break;
case'm':/*344:*/
#line 6207 "mcweave.w"

{
while(!input_has_ended)get_line();
loc= limit;
}

/*:344*/
#line 6116 "mcweave.w"
;break;
default:err_print("! Illegal @ command in book");

}
}
else out(c);
}
}
out_str("\\let\\curjob\\jobname\n");
out_str("\\binx\n\\bfin\n\\con\n");

/*:339*/
#line 6067 "mcweave.w"
;
fclose(file[0]);
if(change_file){
fclose(change_file);
change_file= NULL;
}
finish_line();
fclose(tex_file);
/*343:*/
#line 6186 "mcweave.w"

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
/*349:*/
#line 6268 "mcweave.w"

{
int i;
char**new_argv,**argv_ptr;
argc= ac;
new_argv= argv= (char**)malloc((argc+3)*sizeof(char*));
if(!argv)fatal("! No memory, cannot weave ",chapter_name);

for(i= 0;i<argc;i++)argv[i]= av[i];

argv_ptr= argv+(argv_web-av);
*argv_ptr= chapter_name;
if(argv_change)*argv_change= "-";
if(argv_out)*argv_out= chapter_name;
if(change_exists){
if(argv_change)argv_ptr= argv+(argv_change-av);
else argv_ptr= &argv[argc++];
*argv_ptr= change_file_name;
if(out_exists){
if(argv_out)argv_ptr= argv+(argv_out-av);
else argv_ptr= &argv[argc++];
*argv_ptr= out_file_name;
}
}

history= 0;
ret_val|= weave_file();

/*351:*/
#line 6307 "mcweave.w"

{
int i= chapter_no;
if(i>=max_chapters)overflow("chapters");
ch_TeX_name[i]= strmem(tex_file_name);
}

/*:351*/
#line 6296 "mcweave.w"
;

free(new_argv);
}

/*:349*/
#line 6198 "mcweave.w"
;
}
make_book_xref();
output_adocs();
if(ret_val)printf("\n(Book not successfully translated.)\n");
else if(show_happiness)printf("\n(Book successfully translated.)\n");
}

/*:343*/
#line 6075 "mcweave.w"
;
return ret_val;
}
}

/*:337*/
#line 115 "mcweave.w"
;

return weave_file();
}

/*:3*//*4:*/
#line 129 "mcweave.w"

int
weave_file()
{
common_init();
/*21:*/
#line 283 "mcweave.w"

memset(xmem,0,sizeof(xmem));
xref_ptr= xmem;name_dir->xref= (char*)xmem;xref_switch= 0;section_xref_switch= 0;
xmem->num= 0;

/*:21*//*27:*/
#line 404 "mcweave.w"

tok_ptr= tok_mem+1;text_ptr= tok_start+1;tok_start[0]= tok_mem+1;
tok_start[1]= tok_mem+1;
max_tok_ptr= tok_mem+1;max_text_ptr= tok_start+1;

/*:27*//*35:*/
#line 611 "mcweave.w"

{int c;for(c= 0;c<256;c++)ccode[c]= 0;}
ccode[' ']= ccode['\t']= ccode['\n']= ccode['\v']= ccode['\r']= ccode['\f']
= ccode['*']= new_section;
ccode['@']= '@';
ccode['=']= verbatim;
ccode['a']= ccode['A']= autodoc_code;
ccode['d']= ccode['D']= definition;
ccode['e']= ccode['E']= example_code;
ccode['f']= ccode['F']= ccode['s']= ccode['S']= format_code;
ccode['c']= ccode['C']= ccode['p']= ccode['P']= begin_C;
ccode['t']= ccode['T']= TeX_string;
ccode['l']= ccode['L']= translit_code;
ccode['q']= ccode['Q']= noop;
ccode['h']= ccode['H']= output_defs_code;
ccode['&']= join;ccode['<']= ccode['(']= section_name;
ccode['!']= underline;ccode['^']= xref_roman;
ccode[':']= xref_wildcard;ccode['.']= xref_typewriter;ccode[',']= thin_space;
ccode['|']= math_break;ccode['/']= line_break;ccode['#']= big_line_break;
ccode['+']= no_line_break;ccode[';']= pseudo_semi;
ccode['[']= macro_arg_open;ccode[']']= macro_arg_close;
ccode['\'']= ord;
ccode['_']= special_command;
/*36:*/
#line 640 "mcweave.w"

ccode['0']= ccode['1']= ccode['2']= trace;

/*:36*/
#line 634 "mcweave.w"


/*:35*//*55:*/
#line 984 "mcweave.w"
section_text[0]= ' ';

/*:55*//*68:*/
#line 1191 "mcweave.w"

typedefing= 0;

/*:68*//*90:*/
#line 1563 "mcweave.w"

out_ptr= out_buf+1;out_line= 1;active_file= tex_file;
if(book_type&&*chapter_name){
char*cp;
strcpy(a_file_name,tex_file_name);
cp= file_name_ext(a_file_name);
if(cp)*cp= 0;
*out_ptr= '}';
tex_printf("\\def\\curjob{");
tex_printf(a_file_name);
}
else{
sprintf(a_file_name,"\\input %smcwebma",mcwebmac_prefix);
*out_ptr= 'c';tex_printf(a_file_name);
}

/*:90*//*95:*/
#line 1615 "mcweave.w"

out_buf[0]= '\\';

/*:95*//*111:*/
#line 1938 "mcweave.w"

for(cat_index= 0;cat_index<255;cat_index++)
strcpy(cat_name[cat_index],"UNKNOWN");
strcpy(cat_name[exp],"exp");
strcpy(cat_name[unop],"unop");
strcpy(cat_name[binop],"binop");
strcpy(cat_name[unorbinop],"unorbinop");
strcpy(cat_name[cast],"cast");
strcpy(cat_name[question],"?");
strcpy(cat_name[lbrace],"{");
strcpy(cat_name[rbrace],"}");
strcpy(cat_name[decl_head],"decl_head");
strcpy(cat_name[comma],",");
strcpy(cat_name[lpar],"(");
strcpy(cat_name[rpar],")");
strcpy(cat_name[prelangle],"<");
strcpy(cat_name[prerangle],">");
strcpy(cat_name[langle],"\\<");
strcpy(cat_name[colcol],"::");
strcpy(cat_name[base],"\\:");
strcpy(cat_name[decl],"decl");
strcpy(cat_name[struct_head],"struct_head");
strcpy(cat_name[stmt],"stmt");
strcpy(cat_name[function],"function");
strcpy(cat_name[fn_decl],"fn_decl");
strcpy(cat_name[else_like],"else_like");
strcpy(cat_name[semi],";");
strcpy(cat_name[colon],":");
strcpy(cat_name[tag],"tag");
strcpy(cat_name[if_head],"if_head");
strcpy(cat_name[else_head],"else_head");
strcpy(cat_name[if_clause],"if()");
strcpy(cat_name[lproc],"#{");
strcpy(cat_name[rproc],"#}");
strcpy(cat_name[insert],"insert");
strcpy(cat_name[section_scrap],"section");
strcpy(cat_name[dead],"@d");
strcpy(cat_name[public_like],"public");
strcpy(cat_name[operator_like],"operator");
strcpy(cat_name[new_like],"new");
strcpy(cat_name[catch_like],"catch");
strcpy(cat_name[for_like],"for");
strcpy(cat_name[do_like],"do");
strcpy(cat_name[if_like],"if");
strcpy(cat_name[raw_rpar],")?");
strcpy(cat_name[raw_unorbin],"unorbinop?");
strcpy(cat_name[const_like],"const");
strcpy(cat_name[raw_int],"raw");
strcpy(cat_name[int_like],"int");
strcpy(cat_name[case_like],"case");
strcpy(cat_name[sizeof_like],"sizeof");
strcpy(cat_name[struct_like],"struct");
strcpy(cat_name[typedef_like],"typedef");
strcpy(cat_name[define_like],"define");
strcpy(cat_name[begin_arg],"@[");
strcpy(cat_name[end_arg],"@]");
strcpy(cat_name[0],"zero");

/*:111*//*118:*/
#line 2299 "mcweave.w"

scrap_base= scrap_info+1;
max_scr_ptr= scrap_ptr= scrap_info;

/*:118*//*208:*/
#line 3905 "mcweave.w"

is_example= 0;

/*:208*//*214:*/
#line 4001 "mcweave.w"

max_stack_ptr= stack;

/*:214*//*234:*/
#line 4411 "mcweave.w"

doing_format= group_found= 0;

/*:234*//*262:*/
#line 4893 "mcweave.w"

max_sort_ptr= scrap_info;

/*:262*//*264:*/
#line 4909 "mcweave.w"

collate[0]= 0;strcpy(collate+1," \1\2\3\4\5\6\7\10\11\12\13\14\15\16\17\
\20\21\22\23\24\25\26\27\30\31\32\33\34\35\36\37\
!\42#$%&'()*+,-./:;<=>?@[\\]^`{|}~_\
abcdefghijklmnopqrstuvwxyz0123456789\
\200\201\202\203\204\205\206\207\210\211\212\213\214\215\216\217\
\220\221\222\223\224\225\226\227\230\231\232\233\234\235\236\237\
\240\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257\
\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277\
\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\
\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337\
\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357\
\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377\
");

/*:264*//*277:*/
#line 5084 "mcweave.w"

dag_seen= ddag_seen= 0;

/*:277*//*292:*/
#line 5277 "mcweave.w"

dep_dir= getenv("DEPDIR");
if(!dep_dir)fatal("! Environment variable not set:","DEPDIR");


/*:292*//*299:*/
#line 5432 "mcweave.w"

first_imported_file= NULL;
current_imported_file= NULL;

/*:299*//*308:*/
#line 5605 "mcweave.w"

first_ext_ref= NULL;

/*:308*//*386:*/
#line 7022 "mcweave.w"

first_copy_buffer= NULL;
rest_after_paste= NULL;

/*:386*/
#line 134 "mcweave.w"
;
/*29:*/
#line 444 "mcweave.w"

id_lookup("asm",NULL,sizeof_like);
id_lookup("auto",NULL,int_like);
id_lookup("break",NULL,case_like);
id_lookup("case",NULL,case_like);
id_lookup("catch",NULL,catch_like);
id_lookup("char",NULL,raw_int);
if(Cxx)id_lookup("class",NULL,struct_like);
id_lookup("clock_t",NULL,raw_int);
id_lookup("const",NULL,const_like);
id_lookup("continue",NULL,case_like);
id_lookup("default",NULL,case_like);
id_lookup("define",NULL,define_like);
id_lookup("defined",NULL,sizeof_like);
id_lookup("delete",NULL,sizeof_like);
id_lookup("div_t",NULL,raw_int);
id_lookup("do",NULL,do_like);
id_lookup("double",NULL,raw_int);
id_lookup("elif",NULL,if_like);
id_lookup("else",NULL,else_like);
id_lookup("endif",NULL,if_like);
id_lookup("enum",NULL,struct_like);
id_lookup("error",NULL,if_like);
id_lookup("extern",NULL,int_like);
id_lookup("FILE",NULL,raw_int);
id_lookup("float",NULL,raw_int);
id_lookup("for",NULL,for_like);
id_lookup("fpos_t",NULL,raw_int);
if(Cxx)id_lookup("friend",NULL,int_like);
id_lookup("goto",NULL,case_like);
id_lookup("if",NULL,if_like);
id_lookup("ifdef",NULL,if_like);
id_lookup("ifndef",NULL,if_like);
id_lookup("include",NULL,if_like);
id_lookup("inline",NULL,int_like);
id_lookup("int",NULL,raw_int);
id_lookup("jmp_buf",NULL,raw_int);
id_lookup("ldiv_t",NULL,raw_int);
id_lookup("line",NULL,if_like);
id_lookup("long",NULL,raw_int);
id_lookup("new",NULL,new_like);
id_lookup("NULL",NULL,quoted);
id_lookup("offsetof",NULL,sizeof_like);
if(Cxx)id_lookup("operator",NULL,operator_like);
id_lookup("pragma",NULL,if_like);
if(Cxx)id_lookup("private",NULL,public_like);
id_lookup("protected",NULL,public_like);
id_lookup("ptrdiff_t",NULL,raw_int);
if(Cxx)id_lookup("public",NULL,public_like);
id_lookup("register",NULL,int_like);
id_lookup("return",NULL,case_like);
id_lookup("short",NULL,raw_int);
id_lookup("sig_atomic_t",NULL,raw_int);
id_lookup("signed",NULL,raw_int);
id_lookup("size_t",NULL,raw_int);
id_lookup("sizeof",NULL,sizeof_like);
id_lookup("static",NULL,int_like);
id_lookup("struct",NULL,struct_like);
id_lookup("switch",NULL,for_like);
if(Cxx)id_lookup("template",NULL,int_like);
id_lookup("TeX",NULL,custom);
if(Cxx)id_lookup("this",NULL,quoted);
if(Cxx)id_lookup("throw",NULL,case_like);
id_lookup("time_t",NULL,raw_int);
if(Cxx)id_lookup("try",NULL,else_like);
id_lookup("typedef",NULL,typedef_like);
id_lookup("undef",NULL,if_like);
id_lookup("union",NULL,struct_like);
id_lookup("unsigned",NULL,raw_int);
id_lookup("va_dcl",NULL,decl);
id_lookup("va_list",NULL,raw_int);
if(Cxx)id_lookup("virtual",NULL,int_like);
id_lookup("void",NULL,raw_int);
id_lookup("volatile",NULL,const_like);
id_lookup("wchar_t",NULL,raw_int);
id_lookup("while",NULL,for_like);
/*31:*/
#line 539 "mcweave.w"

id_import= id_lookup("import",NULL,normal);
id_from= id_lookup("from",NULL,normal);
id_chapter= id_lookup("chapter",NULL,normal);
id_program= id_lookup("program",NULL,normal);
id_library= id_lookup("library",NULL,normal);
id_transitively= id_lookup("transitively",NULL,normal);
id_global= id_lookup("global",NULL,normal);
id_shared= id_lookup("shared",NULL,normal);
id_export= id_lookup("export",NULL,normal);
id_mark= id_lookup("mark",NULL,normal);
id_copy= id_lookup("copy",NULL,normal);
id_paste= id_lookup("paste",NULL,normal);

/*:31*/
#line 520 "mcweave.w"
;

/*:29*/
#line 135 "mcweave.w"
;
phase_one();
phase_two();
phase_three();
return wrap_up();
}

/*:4*//*22:*/
#line 303 "mcweave.w"

void
new_xref(p)
name_pointer p;
{
xref_pointer q;
sixteen_bits m,n;
if(no_xref||section_count==0||is_adoc)return;
if((unindexed(p)||is_tiny(p))&&xref_switch==0)return;
m= section_count+xref_switch;xref_switch= 0;q= (xref_pointer)p->xref;
if(q!=xmem){
n= q->num;
if(q->ext_ref==ext_ref||
q->ext_ref==NULL&&(ext_ref==own_shared||ext_ref==own_export)||
ext_ref==NULL&&(q->ext_ref==own_shared||q->ext_ref==own_export)){

if(n==m||n==m+def_flag){
if(!q->ext_ref)q->ext_ref= ext_ref;
return;
}
else if(m==n+def_flag){
if(!q->ext_ref)q->ext_ref= ext_ref;
q->num= m;return;
}
}
}
append_xref(m);xref_ptr->xlink= q;p->xref= (char*)xref_ptr;
xref_ptr->ext_ref= ext_ref;
return;
}

/*:22*//*23:*/
#line 345 "mcweave.w"

void
new_section_xref(p)
name_pointer p;
{
xref_pointer q,r;
q= (xref_pointer)p->xref;r= xmem;
if(q>xmem)
while(q->num>section_xref_switch){r= q;q= q->xlink;}
if(r->num==section_count+section_xref_switch)
return;
append_xref(section_count+section_xref_switch);
xref_ptr->xlink= q;section_xref_switch= 0;
if(r==xmem)p->xref= (char*)xref_ptr;
else r->xlink= xref_ptr;
}

/*:23*//*24:*/
#line 365 "mcweave.w"

void
set_file_flag(p)
name_pointer p;
{
xref_pointer q;
q= (xref_pointer)p->xref;
if(q->num==file_flag)return;
append_xref(file_flag);
xref_ptr->xlink= q;
p->xref= (char*)xref_ptr;
}

/*:24*//*28:*/
#line 410 "mcweave.w"

int names_match(p,first,l,t)
name_pointer p;
char*first;
int l;
eight_bits t;
{
if(length(p)!=l)return 0;
if(p->ilk!=t&&!(t==normal&&abnormal(p)))return 0;
return!strncmp(first,p->byte_start,l);
}

void
init_p(p,t)
name_pointer p;
eight_bits t;
{
p->ilk= t;p->xref= (char*)xmem;
}

void
init_node(p)
name_pointer p;
{
p->xref= (char*)xmem;
}

/*:28*//*38:*/
#line 655 "mcweave.w"

void
skip_limbo(){
while(1){
if(loc>limit&&get_line()==0)return;
*(limit+1)= '@';
while(*loc!='@')loc++;
if(loc++<=limit){int c= ccode[(eight_bits)*loc++];
if(c==new_section)return;
if(c==noop)skip_restricted();
else if(c==format_code)/*79:*/
#line 1392 "mcweave.w"

{
if(get_next()!=identifier)
err_print("! Missing left identifier of @s");

else{
lhs= id_lookup(id_first,id_loc,normal);
if(get_next()!=identifier)
err_print("! Missing right identifier of @s");

else{
rhs= id_lookup(id_first,id_loc,normal);
lhs->ilk= rhs->ilk;
}
}
}

/*:79*/
#line 665 "mcweave.w"
;
}
}
}

/*:38*//*39:*/
#line 677 "mcweave.w"

unsigned
skip_TeX()
{
while(1){
if(loc>limit&&get_line()==0)return(new_section);
*(limit+1)= '@';
while(*loc!='@'&&*loc!='|')loc++;
if(*loc++=='|')return('|');
if(loc<=limit)return(ccode[(eight_bits)*(loc++)]);
}
}

/*:39*//*43:*/
#line 749 "mcweave.w"

eight_bits
get_next()
{eight_bits c;
while(1){
/*48:*/
#line 808 "mcweave.w"

while(loc==limit-1&&preprocessing&&*loc=='\\')
if(get_line()==0)return(new_section);
if(loc>=limit&&preprocessing){
preprocessing= sharp_include_line= 0;
return(right_preproc);
}

/*:48*/
#line 754 "mcweave.w"
;
if(loc>limit&&get_line()==0)return(new_section);
c= *(loc++);
if(xisdigit(c)||c=='\\'||c=='.')/*51:*/
#line 867 "mcweave.w"
{
id_first= id_loc= section_text+1;
if(*(loc-1)=='\\'){*id_loc++= '~';
while(xisdigit(*loc))*id_loc++= *loc++;}
else if(*(loc-1)=='0'){
if(*loc=='x'||*loc=='X'){*id_loc++= '^';loc++;
while(xisxdigit(*loc))*id_loc++= *loc++;}
else if(xisdigit(*loc)){*id_loc++= '~';
while(xisdigit(*loc))*id_loc++= *loc++;}
else goto dec;
}
else{
if(*(loc-1)=='.'&&!xisdigit(*loc))goto mistake;
dec:*id_loc++= *(loc-1);
while(xisdigit(*loc)||*loc=='.')*id_loc++= *loc++;
if(*loc=='e'||*loc=='E'){
*id_loc++= '_';loc++;
if(*loc=='+'||*loc=='-')*id_loc++= *loc++;
while(xisdigit(*loc))*id_loc++= *loc++;
}
}
while(*loc=='u'||*loc=='U'||*loc=='l'||*loc=='L'
||*loc=='f'||*loc=='F'){
*id_loc++= '$';*id_loc++= toupper(*loc);loc++;
}
return(constant);
}

/*:51*/
#line 757 "mcweave.w"

else if(c=='\''||c=='"'||(c=='L'&&(*loc=='\''||*loc=='"'))
||(c=='<'&&sharp_include_line==1))
/*52:*/
#line 900 "mcweave.w"
{
char delim= c;
id_first= section_text+1;
id_loc= section_text;
if(delim=='\''&&*(loc-2)=='@'){*++id_loc= '@';*++id_loc= '@';}
*++id_loc= delim;
if(delim=='L'){
delim= *loc++;*++id_loc= delim;
}
if(delim=='<')delim= '>';
while(1){
if(loc>=limit){
if(*(limit-1)!='\\'){
err_print("! String didn't end");loc= limit;break;

}
if(get_line()==0){
err_print("! Input ended in middle of string");loc= buffer;break;

}
}
if((c= *loc++)==delim){
if(++id_loc<=section_text_end)*id_loc= c;
break;
}
if(c=='\\')if(loc>=limit)continue;
else if(++id_loc<=section_text_end){
*id_loc= '\\';c= *loc++;
}
if(++id_loc<=section_text_end)*id_loc= c;
}
if(id_loc>=section_text_end){
printf("\n! String too long: ");

term_write(section_text+1,25);
printf("...");mark_error;
}
id_loc++;
if(sharp_include_line&&(phase==1||parsing_exp_file))
remember_include_file();
return(string);
}

/*:52*/
#line 760 "mcweave.w"

else if(xisalpha(c)||isxalpha(c)||ishigh(c))
/*50:*/
#line 850 "mcweave.w"
{
id_first= --loc;
while(isalpha(*++loc)||isdigit(*loc)||isxalpha(*loc)||ishigh(*loc));
id_loc= loc;return(identifier);
}

/*:50*/
#line 762 "mcweave.w"

else if(c=='@')/*53:*/
#line 946 "mcweave.w"
{
if(parsing_exp_file)
return'@';
c= *loc++;
switch(ccode[(eight_bits)c]){
case translit_code:err_print("! Use @l in limbo only");continue;

case underline:xref_switch= def_flag;continue;
case trace:tracing= c-'0';continue;
case xref_roman:case xref_wildcard:case xref_typewriter:
case noop:case TeX_string:c= ccode[c];skip_restricted();return(c);
case section_name:
/*54:*/
#line 968 "mcweave.w"
{
char*k;
cur_section_char= *(loc-1);
/*56:*/
#line 986 "mcweave.w"

k= section_text;
while(1){
if(loc>limit&&get_line()==0){
err_print("! Input ended in section name");

loc= buffer+1;break;
}
c= *loc;
/*57:*/
#line 1010 "mcweave.w"

if(c=='@'){
c= *(loc+1);
if(c=='>'){
loc+= 2;break;
}
if(ccode[(eight_bits)c]==new_section){
err_print("! Section name didn't end");break;

}
if(c!='@'){
err_print("! Control codes are forbidden in section name");break;

}
*(++k)= '@';loc++;
}

/*:57*/
#line 995 "mcweave.w"
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

/*:56*/
#line 971 "mcweave.w"
;
if(k-section_text>3&&strncmp(k-2,"...",3)==0)
cur_section= section_lookup(section_text+1,k-3,1);
else cur_section= section_lookup(section_text+1,k,0);
xref_switch= 0;return(section_name);
}

/*:54*/
#line 958 "mcweave.w"
;
case verbatim:/*60:*/
#line 1057 "mcweave.w"
{
id_first= loc++;*(limit+1)= '@';*(limit+2)= '>';
while(*loc!='@'||*(loc+1)!='>')loc++;
if(loc>=limit)err_print("! Verbatim string didn't end");

id_loc= loc;loc+= 2;
return(verbatim);
}

/*:60*/
#line 959 "mcweave.w"
;
case ord:/*52:*/
#line 900 "mcweave.w"
{
char delim= c;
id_first= section_text+1;
id_loc= section_text;
if(delim=='\''&&*(loc-2)=='@'){*++id_loc= '@';*++id_loc= '@';}
*++id_loc= delim;
if(delim=='L'){
delim= *loc++;*++id_loc= delim;
}
if(delim=='<')delim= '>';
while(1){
if(loc>=limit){
if(*(limit-1)!='\\'){
err_print("! String didn't end");loc= limit;break;

}
if(get_line()==0){
err_print("! Input ended in middle of string");loc= buffer;break;

}
}
if((c= *loc++)==delim){
if(++id_loc<=section_text_end)*id_loc= c;
break;
}
if(c=='\\')if(loc>=limit)continue;
else if(++id_loc<=section_text_end){
*id_loc= '\\';c= *loc++;
}
if(++id_loc<=section_text_end)*id_loc= c;
}
if(id_loc>=section_text_end){
printf("\n! String too long: ");

term_write(section_text+1,25);
printf("...");mark_error;
}
id_loc++;
if(sharp_include_line&&(phase==1||parsing_exp_file))
remember_include_file();
return(string);
}

/*:52*/
#line 960 "mcweave.w"
;
default:return(ccode[(eight_bits)c]);
}
}

/*:53*/
#line 763 "mcweave.w"

else if(xisspace(c))continue;
if(c=='#'&&loc==buffer+1)/*45:*/
#line 787 "mcweave.w"
{
preprocessing= 1;
/*47:*/
#line 800 "mcweave.w"

while(loc<=buffer_end-7&&xisspace(*loc))loc++;
if(loc<=buffer_end-6&&strncmp(loc,"include",7)==0)sharp_include_line= 1;

/*:47*/
#line 789 "mcweave.w"
;
return(left_preproc);
}

/*:45*/
#line 765 "mcweave.w"
;
mistake:/*49:*/
#line 826 "mcweave.w"

switch(c){
case'/':if(*loc=='*'){compress(begin_comment);}
else if(*loc=='/')compress(begin_short_comment);break;
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

/*:49*/
#line 766 "mcweave.w"

return(c);
}
}

/*:43*//*59:*/
#line 1032 "mcweave.w"

void
skip_restricted()
{
id_first= loc;*(limit+1)= '@';
false_alarm:
while(*loc!='@')loc++;
id_loc= loc;
if(loc++>limit){
err_print("! Control text didn't end");loc= limit;

}
else{
if(*loc=='@'&&loc<=limit){loc++;goto false_alarm;}
if(*loc++!='>')
err_print("! Control codes are forbidden in control text");

}
}

/*:59*//*63:*/
#line 1085 "mcweave.w"

void
phase_one(){
phase= 1;reset_input();section_count= 0;
skip_limbo();change_exists= 0;
while(!input_has_ended)
/*64:*/
#line 1100 "mcweave.w"

{
if(++section_count==max_sections)overflow("section number");
changed_section[section_count]= changing;

if(*(loc-1)=='*'&&show_progress){
printf("*%d",section_count);
update_terminal;
}
/*73:*/
#line 1279 "mcweave.w"

is_example= 0;
while(1){
switch(next_control= skip_TeX()){
case translit_code:err_print("! Use @l in limbo only");continue;

case underline:xref_switch= def_flag;continue;
case trace:tracing= *(loc-1)-'0';continue;
case'|':typedefing= 0;C_xref(section_name);break;
case xref_roman:case xref_wildcard:case xref_typewriter:
case noop:case section_name:
loc-= 2;next_control= get_next();
if(next_control>=xref_roman&&next_control<=xref_typewriter){
/*74:*/
#line 1305 "mcweave.w"

{
char*src= id_first,*dst= id_first;
while(src<id_loc){
if(*src=='@')src++;
*dst++= *src++;
}
id_loc= dst;
while(dst<src)*dst++= ' ';
}

/*:74*/
#line 1292 "mcweave.w"

new_xref(id_lookup(id_first,id_loc,next_control-identifier));
}
break;
case special_command:/*75:*/
#line 1318 "mcweave.w"

{
next_control= get_next();
if(next_control==identifier){
name_pointer p= id_lookup(id_first,id_loc,normal);
if(p==id_mark){
next_control= get_next();
if(next_control==string){
*id_loc= 0;
mark(id_first);
}
else err_print("! Name of copy buffer expected");

}
else if(p==id_copy)copy();
}
}

/*:75*/
#line 1296 "mcweave.w"
;
break;
case example_code:is_example= !is_example;break;
case autodoc_code:/*382:*/
#line 6967 "mcweave.w"

{
int braces_opened= 0;
int braces_closed= 0;
do{
if(loc>limit&&get_line()==0)break;
switch(*loc++){
case'{':braces_opened++;break;
case'}':
if(--braces_opened<=0){
braces_closed++;
braces_opened= 0;
}
break;
case'@':
loc--;
next_control= get_next();
if(next_control>=format_code&&!is_example)braces_closed= 3;
else if(next_control==special_command){
/*75:*/
#line 1318 "mcweave.w"

{
next_control= get_next();
if(next_control==identifier){
name_pointer p= id_lookup(id_first,id_loc,normal);
if(p==id_mark){
next_control= get_next();
if(next_control==string){
*id_loc= 0;
mark(id_first);
}
else err_print("! Name of copy buffer expected");

}
else if(p==id_copy)copy();
}
}

/*:75*/
#line 6986 "mcweave.w"
;
}
else if(next_control==example_code)is_example= !is_example;
break;
}
}while(braces_closed<3);
}


/*:382*/
#line 1299 "mcweave.w"
;break;
}
if(next_control==definition&&is_example)continue;
if(next_control>=format_code)break;
}

/*:73*/
#line 1109 "mcweave.w"
;
/*77:*/
#line 1353 "mcweave.w"

while(next_control<=definition){
if(next_control==definition){
xref_switch= def_flag;
next_control= get_next();
}else/*78:*/
#line 1367 "mcweave.w"
{
next_control= get_next();
if(next_control==identifier){
lhs= id_lookup(id_first,id_loc,normal);lhs->ilk= normal;
if(xref_switch)new_xref(lhs);
next_control= get_next();
if(next_control==identifier){
rhs= id_lookup(id_first,id_loc,normal);
lhs->ilk= rhs->ilk;
if(unindexed(lhs)){
xref_pointer q,r= NULL;
for(q= (xref_pointer)lhs->xref;q>xmem;q= q->xlink)
if(q->num<def_flag)
if(r)r->xlink= q->xlink;
else lhs->xref= (char*)q->xlink;
else r= q;
}
next_control= get_next();
}
}
}

/*:78*/
#line 1358 "mcweave.w"
;
outer_xref();
}

/*:77*/
#line 1110 "mcweave.w"
;
/*80:*/
#line 1412 "mcweave.w"

if(next_control<=section_name){
if(next_control==begin_C)section_xref_switch= 0;
else{
section_xref_switch= def_flag;
if(cur_section_char=='('&&cur_section!=name_dir)
set_file_flag(cur_section);
}
do{
if(next_control==section_name&&cur_section!=name_dir)
new_section_xref(cur_section);
next_control= get_next();outer_xref();
}while(next_control<=section_name);
}

/*:80*/
#line 1111 "mcweave.w"
;
if(changed_section[section_count])change_exists= 1;
}

/*:64*/
#line 1091 "mcweave.w"
;
changed_section[section_count]= change_exists;

phase= 2;
/*84:*/
#line 1465 "mcweave.w"
section_check(root)

/*:84*/
#line 1095 "mcweave.w"
;
remember_export_file();
process_imported_files();
}

/*:63*//*66:*/
#line 1138 "mcweave.w"

void
C_xref(spec_ctrl)
eight_bits spec_ctrl;
{
static int bal= 0,par= 0;
static name_pointer typedef_name;
name_pointer p;
while(next_control<format_code||next_control==spec_ctrl){
if(next_control>=identifier&&next_control<=xref_typewriter){
if(next_control>identifier){
/*74:*/
#line 1305 "mcweave.w"

{
char*src= id_first,*dst= id_first;
while(src<id_loc){
if(*src=='@')src++;
*dst++= *src++;
}
id_loc= dst;
while(dst<src)*dst++= ' ';
}

/*:74*/
#line 1149 "mcweave.w"

p= id_lookup(id_first,id_loc,next_control-identifier);new_xref(p);
}
else{
p= id_lookup(id_first,id_loc,next_control-identifier);new_xref(p);
/*69:*/
#line 1212 "mcweave.w"

{
int label_ilk;
if(typedefing&&!bal&&!preprocessing){
if(par){
typedefing= 0;
p->ilk= raw_int;
}
else typedef_name= p;
}
if(p->ilk==struct_like){
next_control= get_next();
if(next_control==identifier){
if(Cxx)label_ilk= raw_int;
else label_ilk= normal;
p= id_lookup(id_first,id_loc,label_ilk);
}
goto got_next_one;
}
else if(p->ilk==typedef_like&&spec_ctrl==ignore){
typedefing= 1;
par= bal= 0;
typedef_name= NULL;
}
}

/*:69*/
#line 1154 "mcweave.w"
;
}
}
else if(next_control==special_command){
next_control= get_next();
if(next_control==identifier){
if(spec_ctrl==ignore){
/*293:*/
#line 5287 "mcweave.w"

{
name_pointer p;
int len;
char name[max_file_name_length];

p= id_lookup(id_first,id_loc,normal);
if(p==id_from){
/*294:*/
#line 5317 "mcweave.w"

{
char*ch_name;
next_control= get_next();
if(next_control==identifier){
p= id_lookup(id_first,id_loc,normal);
if(p==id_program||p==id_library){
next_control= get_next();
if(next_control==string){
len= id_loc-id_first-2;
strncpy(name,id_first+1,len);
name[len]= 0;
/*295:*/
#line 5363 "mcweave.w"

{
if(!strchr(name,file_name_separator)){
strcpy(name+len+1,name);
name[len]= file_name_separator;
len= len*2+1;
}
}

/*:295*/
#line 5329 "mcweave.w"
;
ch_name= file_name_part(name);
next_control= get_next();
if(next_control==identifier){
p= id_lookup(id_first,id_loc,normal);
if(p==id_import){
next_control= get_next();
if(next_control==identifier){
p= id_lookup(id_first,id_loc,normal);
if(p!=id_transitively)goto got_next_one;
next_control= get_next();
}
while(next_control==string){
len= id_loc-id_first-2;
strncpy(ch_name,id_first+1,len);
strcpy(ch_name+len,".exp");
remember_import_file(name,1,1);
next_control= get_next();
if(next_control==',')next_control= get_next();
}
}
}
}
}
}
goto got_next_one;
}

/*:294*/
#line 5295 "mcweave.w"
;
}
else if(p==id_import){
/*296:*/
#line 5377 "mcweave.w"

{
next_control= get_next();
if(next_control==identifier){
p= id_lookup(id_first,id_loc,normal);
if(p==id_transitively){
next_control= get_next();
if(next_control!=identifier)goto got_next_one;
p= id_lookup(id_first,id_loc,normal);
}
if(p==id_chapter||p==id_program||p==id_library){
next_control= get_next();
while(next_control==string){
len= id_loc-id_first-2;
strncpy(name,id_first+1,len);
name[len]= 0;
if(p!=id_chapter)/*295:*/
#line 5363 "mcweave.w"

{
if(!strchr(name,file_name_separator)){
strcpy(name+len+1,name);
name[len]= file_name_separator;
len= len*2+1;
}
}

/*:295*/
#line 5393 "mcweave.w"
;
strcpy(name+len,p==id_chapter?".shr":".exp");
remember_import_file(name,p!=id_chapter,1);
next_control= get_next();
if(next_control==',')next_control= get_next();
}
}
}
goto got_next_one;
}

/*:296*/
#line 5298 "mcweave.w"
;
}
else if(p==id_mark){
next_control= get_next();
if(next_control==string){
*id_loc= 0;
mark(id_first);
}
else{
err_print("! Name of copy buffer expected");

goto got_next_one;
}
}
else if(p==id_copy)copy();
}

/*:293*/
#line 1161 "mcweave.w"
;
}
}
else goto got_next_one;
}
else if(next_control=='{')bal++;
else if(next_control=='}')bal--;
else if(next_control=='(')par++;
else if(next_control==')')par--;
else if(next_control==';'&&!bal&&typedefing){
/*70:*/
#line 1240 "mcweave.w"

{
if(typedef_name)
typedef_name->ilk= raw_int;
typedefing= 0;
}

/*:70*/
#line 1171 "mcweave.w"
;
}
if(next_control==section_name){
section_xref_switch= cite_flag;
new_section_xref(cur_section);
}
next_control= get_next();
got_next_one:
if(next_control=='|'||next_control==begin_comment||
next_control==begin_short_comment)return;
}
}

/*:66*//*72:*/
#line 1254 "mcweave.w"

void
outer_xref()
{
int bal;
typedefing= 0;
while(next_control<format_code)
if(next_control!=begin_comment&&next_control!=begin_short_comment)
C_xref(ignore);
else{
boolean is_long_comment= (next_control==begin_comment);
bal= copy_comment(is_long_comment,1);next_control= '|';
while(bal>0){
C_xref(section_name);
if(next_control=='|')bal= copy_comment(is_long_comment,bal);
else bal= 0;
}
}
}

/*:72*//*83:*/
#line 1442 "mcweave.w"

void
section_check(p)
name_pointer p;
{
if(p){
section_check(p->llink);
cur_xref= (xref_pointer)p->xref;
if(cur_xref->num==file_flag){an_output= 1;cur_xref= cur_xref->xlink;}
else an_output= 0;
if(cur_xref->num<def_flag){
printf("\n! Never defined: <");print_section_name(p);putchar('>');mark_harmless;

}
while(cur_xref->num>=cite_flag)cur_xref= cur_xref->xlink;
if(cur_xref==xmem&&!an_output){
printf("\n! Never used: <");print_section_name(p);putchar('>');mark_harmless;

}
section_check(p->rlink);
}
}

/*:83*//*86:*/
#line 1495 "mcweave.w"

void
flush_buffer(b,per_cent,carryover)
char*b;
boolean per_cent,carryover;
{
char*j;j= b;
if(!per_cent)
while(j>out_buf&&*j==' ')j--;
if(is_adoc){
/*87:*/
#line 1525 "mcweave.w"

{
int i;
for(i= 1;i<=j-out_buf;i++)app_adoc(out_buf[i]);
if(per_cent)app_adoc('%');
app_adoc('\n');
}

/*:87*/
#line 1505 "mcweave.w"
;
}
else{
c_line_write(j-out_buf);
if(per_cent)tex_putc('%');
tex_new_line;out_line++;
}
if(carryover)
while(j>out_buf)
if(*j--=='%'&&(j==out_buf||*j!='\\')){
*b--= '%';break;
}
if(b<out_ptr)strncpy(out_buf+1,b+1,out_ptr-b);
out_ptr-= b-out_buf;
}

/*:86*//*89:*/
#line 1545 "mcweave.w"

void
finish_line()
{
char*k;
if(out_ptr>out_buf)flush_buffer(out_ptr,0,0);
else{
for(k= buffer;k<=limit;k++)
if(!(xisspace(*k)))return;
flush_buffer(out_buf,0,0);
}
}

/*:89*//*94:*/
#line 1603 "mcweave.w"

void
out_str(s)
char*s;
{
while(*s)out(*s++);
}

/*:94*//*97:*/
#line 1625 "mcweave.w"

void
break_out()
{
char*k= out_ptr;
while(1){
if(k==out_buf)/*98:*/
#line 1646 "mcweave.w"

{
printf("\n! Line had to be broken (output l. %d):\n",out_line);

term_write(out_buf+1,out_ptr-out_buf-1);
new_line;mark_harmless;
flush_buffer(out_ptr-1,1,1);return;
}

/*:98*/
#line 1631 "mcweave.w"
;
if(*k==' '){
flush_buffer(k,0,1);return;
}
if(*(k--)=='\\'&&*k!='\\'){
flush_buffer(k,1,1);return;
}
}
}

/*:97*//*99:*/
#line 1660 "mcweave.w"

void
out_section(n)
sixteen_bits n;
{
char s[6];
sprintf(s,"%d",n);out_str(s);
if(changed_section[n])out_str("\\*");

}

/*:99*//*100:*/
#line 1674 "mcweave.w"

void
out_name(p)
name_pointer p;
{
char*k,*k_end= (p+1)->byte_start;
out('{');
for(k= p->byte_start;k<k_end;k++){
if(isxalpha(*k))out('\\');
out(*k);
}
out('}');
}

/*:100*//*101:*/
#line 1701 "mcweave.w"

void
copy_limbo()
{
char c,*cp;
if(book_type){
strcpy(out_file_name,tex_file_name);
cp= file_name_ext(out_file_name);
if(cp)*cp= 0;
}
while(1){
if(loc>limit&&(finish_line(),get_line()==0))return;
*(limit+1)= '@';
while(*loc!='@')out(*(loc++));
if(loc++<=limit){
c= *loc++;
if(ccode[(eight_bits)c]==new_section)break;
switch(ccode[(eight_bits)c]){
case translit_code:out_str("\\ATL");break;

case'@':out('@');break;
case noop:skip_restricted();break;
case format_code:if(get_next()==identifier)get_next();
if(loc>=limit)get_line();
break;
default:err_print("! Double @ should be used in limbo");

out('@');
}
}
}
}

/*:101*//*103:*/
#line 1741 "mcweave.w"

eight_bits
copy_TeX()
{
char c;
while(1){
if(loc>limit&&(finish_line(),get_line()==0))return(new_section);
*(limit+1)= '@';
while((c= *(loc++))!='|'&&c!='@'){
out(c);
if(out_ptr==out_buf+1&&(xisspace(c)))out_ptr--;
}
if(c=='|')return('|');
if(loc<=limit)return(ccode[(eight_bits)*(loc++)]);
}
}

/*:103*//*105:*/
#line 1773 "mcweave.w"

int copy_comment(is_long_comment,bal)
boolean is_long_comment;
int bal;
{
char c;
while(1){
if(loc>limit){
if(is_long_comment){
if(get_line()==0){
err_print("! Input ended in mid-comment");

loc= buffer+1;goto done;
}
}
else{
if(bal>1)err_print("! Missing } in comment");

goto done;
}
}
c= *(loc++);
if(c=='|')return(bal);
if(is_long_comment)/*106:*/
#line 1814 "mcweave.w"

if(c=='*'&&*loc=='/'){
loc++;
if(bal>1)err_print("! Missing } in comment");

goto done;
}

/*:106*/
#line 1796 "mcweave.w"
;
if(phase==2){
if(ishigh(c))app_tok(quoted_char);
app_tok(c);
}
/*107:*/
#line 1822 "mcweave.w"

if(c=='@'){
if(*(loc++)!='@'){
err_print("! Illegal use of @ in comment");

loc-= 2;if(phase==2)*(tok_ptr-1)= ' ';goto done;
}
}
else if(c=='\\'&&*loc!='@')
if(phase==2)app_tok(*(loc++))else loc++;

/*:107*/
#line 1801 "mcweave.w"
;
if(c=='{')bal++;
else if(c=='}'){
if(bal>1)bal--;
else{err_print("! Extra } in comment");

if(phase==2)tok_ptr--;
}
}
}
done:/*108:*/
#line 1836 "mcweave.w"

if(phase==2)while(bal-->0)app_tok('}');
return(0);

/*:108*/
#line 1811 "mcweave.w"
;
}

/*:105*//*112:*/
#line 1998 "mcweave.w"

void
print_cat(c)
eight_bits c;
{
printf(cat_name[c]);
}

/*:112*//*119:*/
#line 2326 "mcweave.w"

void
print_text(p)
text_pointer p;
{
token_pointer j;
sixteen_bits r;
if(p>=text_ptr)printf("BAD");
else for(j= *p;j<*(p+1);j++){
r= *j%id_flag;
switch(*j/id_flag){
case 1:printf("\\\\{");print_id((name_dir+r));printf("}");
break;
case 2:printf("\\&{");print_id((name_dir+r));printf("}");
break;
case 3:printf("<");print_section_name((name_dir+r));printf(">");
break;
case 4:printf("[[%d]]",r);break;
case 5:printf("|[[%d]]|",r);break;
default:/*120:*/
#line 2351 "mcweave.w"

switch(r){
case math_rel:printf("\\mathrel{");break;
case big_cancel:printf("[ccancel]");break;
case cancel:printf("[cancel]");break;
case indent:printf("[indent]");break;
case outdent:printf("[outdent]");break;
case backup:printf("[backup]");break;
case opt:printf("[opt]");break;
case break_space:printf("[break]");break;
case force:printf("[force]");break;
case big_force:printf("[fforce]");break;
case preproc_line:printf("[preproc]");break;
case quoted_char:j++;printf("[%o]",(unsigned)*j);break;
case end_translation:printf("[quit]");break;
case inserted:printf("[inserted]");break;
default:putxchar(r);
}

/*:120*/
#line 2345 "mcweave.w"
;
}
}
fflush(stdout);
}

/*:119*//*122:*/
#line 2451 "mcweave.w"

void
app_str(s)
char*s;
{
while(*s)app_tok(*(s++));
}

void
big_app(a)
token a;
{
if(a==' '||(a>=big_cancel&&a<=big_force)){
if(cur_mathness==maybe_math)init_mathness= no_math;
else if(cur_mathness==yes_math)app_str("{}$");
cur_mathness= no_math;
}
else{
if(cur_mathness==maybe_math)init_mathness= yes_math;
else if(cur_mathness==no_math)app_str("${}");
cur_mathness= yes_math;
}
app(a);
}

void
big_app1(a)
scrap_pointer a;
{
switch(a->mathness%4){
case(no_math):
if(cur_mathness==maybe_math)init_mathness= no_math;
else if(cur_mathness==yes_math)app_str("{}$");
cur_mathness= a->mathness/4;
break;
case(yes_math):
if(cur_mathness==maybe_math)init_mathness= yes_math;
else if(cur_mathness==no_math)app_str("${}");
cur_mathness= a->mathness/4;
break;
case(maybe_math):break;
}
app(tok_flag+(int)((a)->trans-tok_start));
}

/*:122*//*124:*/
#line 2576 "mcweave.w"

token_pointer
find_first_ident(p)
text_pointer p;
{
token_pointer q;
token_pointer j;
sixteen_bits r;
if(p>=text_ptr)confusion("find_first_ident");
for(j= *p;j<*(p+1);j++){
r= *j%id_flag;
switch(*j/id_flag){
case 1:case 2:
if(j[1]=='\\'&&j[2]=='D'&&j[3]=='C')
break;
return j;
case 4:case 5:
if((q= find_first_ident(tok_start+r))!=no_ident_found)
return q;
default:;
if(*j==inserted)return no_ident_found;
}
}
return no_ident_found;
}

/*:124*//*125:*/
#line 2606 "mcweave.w"

void
make_reserved(p)
scrap_pointer p;
{
sixteen_bits tok_value;
token_pointer tok_loc;
if((tok_loc= find_first_ident(p->trans))==no_ident_found)
return;
tok_value= *tok_loc;
for(;p<=scrap_ptr;p==lo_ptr?p= hi_ptr:p++){
if(p->cat==exp){
if(**(p->trans)==tok_value){
p->cat= raw_int;
**(p->trans)= tok_value%id_flag+res_flag;
}
}
}
(name_dir+(sixteen_bits)(tok_value%id_flag))->ilk= raw_int;
*tok_loc= tok_value%id_flag+res_flag;
}

/*:125*//*126:*/
#line 2637 "mcweave.w"

void
make_underlined(p)

scrap_pointer p;
{
token_pointer tok_loc;
if((tok_loc= find_first_ident(p->trans))==no_ident_found)
return;
if(parsing_exp_file)section_count= section_of_token(tok_loc);
xref_switch= def_flag;
underline_xref(*tok_loc%id_flag+name_dir);
}

/*:126*//*128:*/
#line 2659 "mcweave.w"

void
underline_xref(p)
name_pointer p;
{
xref_pointer q= (xref_pointer)p->xref;
xref_pointer r;
sixteen_bits m;
sixteen_bits n;
if(no_xref||!section_count||is_adoc)return;
m= section_count+xref_switch;
while(q!=xmem){
n= q->num;
if(q->ext_ref==ext_ref||
q->ext_ref==NULL&&(ext_ref==own_shared||ext_ref==own_export)||
ext_ref==NULL&&(q->ext_ref==own_shared||q->ext_ref==own_export)){
if(n==m){
if(!q->ext_ref)q->ext_ref= ext_ref;
return;
}
else if(m==n+def_flag){
if(!q->ext_ref)q->ext_ref= ext_ref;
q->num= m;return;
}
else if(n>=def_flag&&n<m)break;
}
q= q->xlink;
}
/*129:*/
#line 2697 "mcweave.w"

append_xref(0);
xref_ptr->xlink= (xref_pointer)p->xref;r= xref_ptr;
p->xref= (char*)xref_ptr;
while(r->xlink!=q){
r->num= r->xlink->num;
r->ext_ref= r->xlink->ext_ref;
r= r->xlink;
}
r->num= m;
r->ext_ref= ext_ref;

/*:129*/
#line 2687 "mcweave.w"
;
}

/*:128*//*148:*/
#line 2950 "mcweave.w"

void
reset_ext_refs(p)
text_pointer p;
{
token_pointer j;
sixteen_bits r;
xref_pointer xp;
if(p>=text_ptr)confusion("find_first_ident");
for(j= *p;j<*(p+1);j++){
r= *j%id_flag;
switch(*j/id_flag){
case 1:
if(j[1]=='\\'&&j[2]=='D'&&j[3]=='C')
break;
if(struct_like_seen)struct_like_seen= 0;
else if(xp= defined_here(name_dir+r)){
if(ext_ref_seen)xp->ext_ref= NULL;
else ext_ref_seen= 1;
}
break;
case 2:
if(name_dir[r].ilk==struct_like&&j<*(p+1)&&j[1]/id_flag==1)
struct_like_seen= 1;
break;
case 4:case 5:
reset_ext_refs(tok_start+r);
default:;
if(*j==inserted)return;
}
}
}

/*:148*//*149:*/
#line 2986 "mcweave.w"

xref_pointer
defined_here(p)
name_pointer p;
{
xref_pointer xp;
for(xp= (xref_pointer)p->xref;xp!=&xmem[0];xp= xp->xlink){
if(xp->num==section_count+def_flag)return xp;
}
return NULL;
}

/*:149*//*180:*/
#line 3253 "mcweave.w"

void
reduce(j,k,c,d,n)
scrap_pointer j;
eight_bits c;
short k,d,n;
{
scrap_pointer i,i1;
j->cat= c;j->trans= text_ptr;
j->mathness= 4*cur_mathness+init_mathness;
freeze_text;
if(k>1){
for(i= j+k,i1= j+1;i<=lo_ptr;i++,i1++){
i1->cat= i->cat;i1->trans= i->trans;
i1->mathness= i->mathness;
}
lo_ptr= lo_ptr-k+1;
}
/*181:*/
#line 3276 "mcweave.w"

if(pp+d>=scrap_base)pp= pp+d;
else pp= scrap_base;

/*:181*/
#line 3271 "mcweave.w"
;
/*186:*/
#line 3350 "mcweave.w"

{scrap_pointer k;
if(tracing==2){
printf("\n%d:",n);
for(k= scrap_base;k<=lo_ptr;k++){
if(k==pp)putxchar('*');else putxchar(' ');
if(k->mathness%4==yes_math)putchar('+');
else if(k->mathness%4==no_math)putchar('-');
print_cat(k->cat);
if(k->mathness/4==yes_math)putchar('+');
else if(k->mathness/4==no_math)putchar('-');
}
if(hi_ptr<=scrap_ptr)printf("...");
}
}

/*:186*/
#line 3272 "mcweave.w"
;
pp--;
}

/*:180*//*182:*/
#line 3283 "mcweave.w"

void
squash(j,k,c,d,n)
scrap_pointer j;
eight_bits c;
short k,d,n;
{
scrap_pointer i;
if(k==1){
j->cat= c;/*181:*/
#line 3276 "mcweave.w"

if(pp+d>=scrap_base)pp= pp+d;
else pp= scrap_base;

/*:181*/
#line 3292 "mcweave.w"
;
/*186:*/
#line 3350 "mcweave.w"

{scrap_pointer k;
if(tracing==2){
printf("\n%d:",n);
for(k= scrap_base;k<=lo_ptr;k++){
if(k==pp)putxchar('*');else putxchar(' ');
if(k->mathness%4==yes_math)putchar('+');
else if(k->mathness%4==no_math)putchar('-');
print_cat(k->cat);
if(k->mathness/4==yes_math)putchar('+');
else if(k->mathness/4==no_math)putchar('-');
}
if(hi_ptr<=scrap_ptr)printf("...");
}
}

/*:186*/
#line 3293 "mcweave.w"
;
pp--;
return;
}
for(i= j;i<j+k;i++)big_app1(i);
reduce(j,k,c,d,n);
}

/*:182*//*187:*/
#line 3379 "mcweave.w"

text_pointer
translate()
{
scrap_pointer i,
j;
pp= scrap_base;lo_ptr= pp-1;hi_ptr= pp;
/*190:*/
#line 3418 "mcweave.w"

if(tracing==2){
printf("\nTracing after l. %d:\n",cur_line);mark_harmless;

if(loc>buffer+50){
printf("...");
term_write(loc-51,51);
}
else term_write(buffer,loc-buffer);
}

/*:190*/
#line 3386 "mcweave.w"
;
/*183:*/
#line 3314 "mcweave.w"

while(1){
/*184:*/
#line 3333 "mcweave.w"

if(lo_ptr<pp+3){
while(hi_ptr<=scrap_ptr&&lo_ptr!=pp+3){
(++lo_ptr)->cat= hi_ptr->cat;lo_ptr->mathness= (hi_ptr)->mathness;
lo_ptr->trans= (hi_ptr++)->trans;
}
for(i= lo_ptr+1;i<=pp+3;i++)i->cat= 0;
}

/*:184*/
#line 3316 "mcweave.w"
;
if(tok_ptr+safe_tok_incr>tok_mem_end){
if(tok_ptr>max_tok_ptr)max_tok_ptr= tok_ptr;
overflow("token");
}
if(text_ptr+safe_text_incr>tok_start_end){
if(text_ptr>max_text_ptr)max_text_ptr= text_ptr;
overflow("text");
}
if(pp>lo_ptr)break;
init_mathness= cur_mathness= maybe_math;
/*123:*/
#line 2507 "mcweave.w"
{
if(cat1==end_arg&&lhs_not_simple)
if(pp->cat==begin_arg)squash(pp,2,exp,-2,110);
else squash(pp,2,end_arg,-1,111);
else if(cat1==insert)squash(pp,2,pp->cat,-2,0);
else if(cat2==insert)squash(pp+1,2,(pp+1)->cat,-1,0);
else if(cat3==insert)squash(pp+2,2,(pp+2)->cat,0,0);
else
switch(pp->cat){
case exp:/*130:*/
#line 2714 "mcweave.w"

if(cat1==lbrace||cat1==int_like||cat1==decl){
make_underlined(pp);big_app1(pp);big_app(indent);app(indent);
reduce(pp,1,fn_decl,0,1);
}
else if(cat1==unop)squash(pp,2,exp,-2,2);
else if((cat1==binop||cat1==unorbinop)&&cat2==exp)
squash(pp,3,exp,-2,3);
else if(cat1==comma&&cat2==exp){
big_app2(pp);
app(opt);app('9');big_app1(pp+2);reduce(pp,3,exp,-2,4);
}
else if(cat1==exp||cat1==cast)squash(pp,2,exp,-2,5);
else if(cat1==semi)squash(pp,2,stmt,-1,6);
else if(cat1==colon){
make_underlined(pp);squash(pp,2,tag,0,7);
}
else if(cat1==base){
if(cat2==int_like&&cat3==comma){
big_app1(pp+1);big_app(' ');big_app2(pp+2);
app(opt);app('9');reduce(pp+1,3,base,0,8);
}
else if(cat2==int_like&&cat3==lbrace){
big_app1(pp);big_app(' ');big_app1(pp+1);big_app(' ');big_app1(pp+2);
reduce(pp,3,exp,-1,9);
}
}
else if(cat1==rbrace)squash(pp,1,stmt,-1,10);

/*:130*/
#line 2516 "mcweave.w"
;break;
case lpar:/*131:*/
#line 2743 "mcweave.w"

if((cat1==exp||cat1==unorbinop)&&cat2==rpar)squash(pp,3,exp,-2,11);
else if(cat1==rpar){
big_app1(pp);app('\\');app(',');big_app1(pp+1);

reduce(pp,2,exp,-2,12);
}
else if(cat1==decl_head||cat1==int_like||cat1==exp){
if(cat2==rpar)squash(pp,3,cast,-2,13);
else if(cat2==comma){
big_app3(pp);app(opt);app('9');reduce(pp,3,lpar,0,14);
}
}
else if(cat1==stmt||cat1==decl){
big_app2(pp);big_app(' ');reduce(pp,2,lpar,0,15);
}

/*:131*/
#line 2517 "mcweave.w"
;break;
case question:/*132:*/
#line 2760 "mcweave.w"

if(cat1==exp&&cat2==colon)squash(pp,3,binop,-2,16);

/*:132*/
#line 2518 "mcweave.w"
;break;
case unop:/*133:*/
#line 2763 "mcweave.w"

if(cat1==exp||cat1==int_like)squash(pp,2,cat1,-2,17);

/*:133*/
#line 2519 "mcweave.w"
;break;
case unorbinop:/*134:*/
#line 2766 "mcweave.w"

if(cat1==exp||cat1==int_like){
big_app('{');big_app1(pp);big_app('}');big_app1(pp+1);
reduce(pp,2,cat1,-2,18);
}
else if(cat1==binop){
big_app(math_rel);big_app1(pp);big_app('{');big_app1(pp+1);big_app('}');
big_app('}');reduce(pp,2,binop,-1,19);
}

/*:134*/
#line 2520 "mcweave.w"
;break;
case binop:/*135:*/
#line 2776 "mcweave.w"

if(cat1==binop){
big_app(math_rel);big_app('{');big_app1(pp);big_app('}');
big_app('{');big_app1(pp+1);big_app('}');
big_app('}');reduce(pp,2,binop,-1,20);
}

/*:135*/
#line 2521 "mcweave.w"
;break;
case cast:/*136:*/
#line 2783 "mcweave.w"

if(cat1==exp){
big_app1(pp);big_app(' ');big_app1(pp+1);reduce(pp,2,exp,-2,21);
}
else if(cat1==semi)squash(pp,1,exp,-2,22);

/*:136*/
#line 2522 "mcweave.w"
;break;
case sizeof_like:/*137:*/
#line 2789 "mcweave.w"

if(cat1==cast)squash(pp,2,exp,-2,23);
else if(cat1==exp){
big_app1(pp);big_app(' ');big_app1(pp+1);reduce(pp,2,exp,-2,24);
}

/*:137*/
#line 2523 "mcweave.w"
;break;
case int_like:/*138:*/
#line 2795 "mcweave.w"

if(cat1==int_like||cat1==struct_like){
big_app1(pp);big_app(' ');big_app1(pp+1);reduce(pp,2,cat1,-2,25);
}
else if(cat1==exp&&(cat2==raw_int||cat2==struct_like))
squash(pp,2,int_like,-2,26);
else if(cat1==exp||cat1==unorbinop||cat1==semi){
big_app1(pp);
if(cat1!=semi)big_app(' ');
reduce(pp,1,decl_head,-1,27);
}
else if(cat1==colon){
big_app1(pp);big_app(' ');reduce(pp,1,decl_head,0,28);
}
else if(cat1==prelangle)squash(pp+1,1,langle,1,29);
else if(cat1==colcol&&(cat2==exp||cat2==int_like))squash(pp,3,cat2,-2,30);
else if(cat1==cast){
if(cat2==lbrace){
big_app2(pp);big_app(indent);big_app(indent);
reduce(pp,2,fn_decl,1,31);
}
else squash(pp,2,int_like,-2,32);
}
else if(cat1==base&&cat2==int_like&&cat3==lbrace){
big_app1(pp);big_app(' ');big_app1(pp+1);big_app(' ');big_app1(pp+2);
reduce(pp,3,exp,-1,115);
}
else if(cat1==lproc&&cat2==if_like&&cat3==exp){
squash(pp,2,lproc,0,116);
}

/*:138*/
#line 2524 "mcweave.w"
;break;
case decl_head:/*139:*/
#line 2826 "mcweave.w"

if(cat1==comma){
big_app2(pp);big_app(' ');reduce(pp,2,decl_head,-1,33);
}
else if(cat1==unorbinop){
big_app1(pp);big_app('{');big_app1(pp+1);big_app('}');
reduce(pp,2,decl_head,-1,34);
}
else if(cat1==exp&&cat2!=lpar&&cat2!=exp){
make_underlined(pp+1);squash(pp,2,decl_head,-1,35);
}
else if((cat1==binop||cat1==colon)&&cat2==exp&&(cat3==comma||
cat3==semi||cat3==rpar))
squash(pp,3,decl_head,-1,36);
else if(cat1==cast)squash(pp,2,decl_head,-1,37);
else if(cat1==lbrace||(cat1==int_like&&cat2!=colcol)||cat1==decl){
big_app1(pp);big_app(indent);app(indent);reduce(pp,1,fn_decl,0,38);
}
else if(cat1==semi)squash(pp,2,decl,-2,39);

/*:139*/
#line 2525 "mcweave.w"
;break;
case decl:/*140:*/
#line 2846 "mcweave.w"

if(cat1==decl){
big_app1(pp);big_app(force);big_app1(pp+1);
reduce(pp,2,decl,-2,40);
}
else if(cat1==stmt||cat1==function){
big_app1(pp);big_app(big_force);
big_app1(pp+1);reduce(pp,2,cat1,-1,41);
}

/*:140*/
#line 2526 "mcweave.w"
;break;
case typedef_like:/*141:*/
#line 2856 "mcweave.w"

if(cat1==decl_head){
if((cat2==exp&&cat3!=lpar&&cat3!=exp)||cat2==int_like){
make_underlined(pp+2);make_reserved(pp+2);
big_app2(pp+1);reduce(pp+1,2,decl_head,0,42);
}
else if(cat2==semi){
big_app1(pp);big_app(' ');big_app2(pp+1);reduce(pp,3,decl,-2,43);
}
}
else if(cat1==exp&&cat2==cast&&cat3==semi){
big_app1(pp);big_app(' ');big_app3(pp+1);
reduce(pp,4,decl,-2,112);
}
else if(cat1==int_like&&cat2==decl){
big_app1(pp);big_app(' ');big_app2(pp+1);
reduce(pp,3,decl,-2,113);
}
else if(cat1==exp&&cat2==exp&&cat3==lpar){
make_underlined(pp+2);make_reserved(pp+2);
big_app1(pp);big_app(' ');big_app1(pp+1);big_app(' ');
reduce(pp,3,exp,-2,114);
}

/*:141*/
#line 2527 "mcweave.w"
;break;
case struct_like:/*142:*/
#line 2880 "mcweave.w"

if(cat1==lbrace){
big_app1(pp);big_app(' ');big_app1(pp+1);reduce(pp,2,struct_head,0,44);
}
else if(cat1==exp||cat1==int_like){
if(cat2==lbrace||cat2==semi){
if(cat2==lbrace)
make_underlined(pp+1);
if(Cxx)
make_reserved(pp+1);
big_app1(pp);big_app(' ');big_app1(pp+1);
if(cat2==semi)reduce(pp,2,decl_head,0,45);
else{
big_app(' ');big_app1(pp+2);reduce(pp,3,struct_head,0,46);
}
}
else if(cat2==colon)squash(pp+2,1,base,-1,47);
else if(cat2!=base){
big_app1(pp);big_app(' ');big_app1(pp+1);reduce(pp,2,int_like,-2,48);
}
}

/*:142*/
#line 2528 "mcweave.w"
;break;
case struct_head:/*143:*/
#line 2902 "mcweave.w"

if((cat1==decl||cat1==stmt||cat1==function)&&cat2==rbrace){
big_app1(pp);big_app(indent);big_app(force);big_app1(pp+1);
big_app(outdent);big_app(force);big_app1(pp+2);
reduce(pp,3,int_like,-2,49);
}
else if(cat1==rbrace){
big_app1(pp);app_str("\\,");big_app1(pp+1);

reduce(pp,2,int_like,-2,50);
}

/*:143*/
#line 2529 "mcweave.w"
;break;
case fn_decl:/*144:*/
#line 2914 "mcweave.w"

if(cat1==decl){
big_app1(pp);big_app(force);big_app1(pp+1);reduce(pp,2,fn_decl,0,51);
}
else if(cat1==stmt){
/*145:*/
#line 2931 "mcweave.w"

{
ext_ref_seen= 0;
struct_like_seen= 0;
reset_ext_refs(pp->trans);
}

/*:145*/
#line 2919 "mcweave.w"
;
big_app1(pp);app(outdent);app(outdent);big_app(force);
big_app1(pp+1);reduce(pp,2,function,-1,52);
}

/*:144*/
#line 2530 "mcweave.w"
;break;
case function:/*150:*/
#line 2998 "mcweave.w"

if(cat1==function||cat1==decl||cat1==stmt){
int shift= -1;
if(cat1==decl)shift= -2;
big_app1(pp);big_app(big_force);big_app1(pp+1);reduce(pp,2,cat1,shift,53);
}

/*:150*/
#line 2531 "mcweave.w"
;break;
case lbrace:/*151:*/
#line 3005 "mcweave.w"

if(cat1==rbrace){
big_app1(pp);app('\\');app(',');big_app1(pp+1);

reduce(pp,2,stmt,-1,54);
}
else if((cat1==stmt||cat1==decl||cat1==function)&&cat2==rbrace){
big_app(force);big_app1(pp);big_app(indent);big_app(force);
big_app1(pp+1);big_app(force);big_app(backup);big_app1(pp+2);
big_app(outdent);big_app(force);reduce(pp,3,stmt,-1,55);
}
else if(cat1==exp){
if(cat2==rbrace)squash(pp,3,exp,-2,56);
else if(cat2==comma&&cat3==rbrace)squash(pp,4,exp,-2,56);
}

/*:151*/
#line 2532 "mcweave.w"
;break;
case do_like:/*158:*/
#line 3071 "mcweave.w"

if(cat1==stmt&&cat2==else_like&&cat3==semi){
big_app1(pp);big_app(break_space);app(noop);big_app(cancel);
big_app1(pp+1);big_app(cancel);app(noop);big_app(break_space);
big_app2(pp+2);reduce(pp,4,stmt,-1,69);
}

/*:158*/
#line 2533 "mcweave.w"
;break;
case if_like:/*152:*/
#line 3021 "mcweave.w"

if(cat1==exp){
big_app1(pp);big_app(' ');big_app1(pp+1);reduce(pp,2,if_clause,0,57);
}

/*:152*/
#line 2534 "mcweave.w"
;break;
case for_like:/*153:*/
#line 3026 "mcweave.w"

if(cat1==exp){
big_app1(pp);big_app(' ');big_app1(pp+1);reduce(pp,2,else_like,-2,58);
}

/*:153*/
#line 2535 "mcweave.w"
;break;
case else_like:/*154:*/
#line 3031 "mcweave.w"

if(cat1==lbrace)squash(pp,1,else_head,0,59);
else if(cat1==stmt){
big_app(force);big_app1(pp);big_app(indent);big_app(break_space);
big_app1(pp+1);big_app(outdent);big_app(force);
reduce(pp,2,stmt,-1,60);
}

/*:154*/
#line 2536 "mcweave.w"
;break;
case if_clause:/*156:*/
#line 3046 "mcweave.w"

if(cat1==lbrace)squash(pp,1,if_head,0,62);
else if(cat1==stmt){
if(cat2==else_like){
big_app(force);big_app1(pp);big_app(indent);big_app(break_space);
big_app1(pp+1);big_app(outdent);big_app(force);big_app1(pp+2);
if(cat3==if_like){
big_app(' ');big_app1(pp+3);reduce(pp,4,if_like,0,63);
}else reduce(pp,3,else_like,0,64);
}
else squash(pp,1,else_like,0,65);
}

/*:156*/
#line 2537 "mcweave.w"
;break;
case if_head:/*157:*/
#line 3059 "mcweave.w"

if(cat1==stmt||cat1==exp){
if(cat2==else_like){
big_app(force);big_app1(pp);big_app(break_space);app(noop);
big_app(cancel);big_app1(pp+1);big_app(force);big_app1(pp+2);
if(cat3==if_like){
big_app(' ');big_app1(pp+3);reduce(pp,4,if_like,0,66);
}else reduce(pp,3,else_like,0,67);
}
else squash(pp,1,else_head,0,68);
}

/*:157*/
#line 2538 "mcweave.w"
;break;
case else_head:/*155:*/
#line 3039 "mcweave.w"

if(cat1==stmt||cat1==exp){
big_app(force);big_app1(pp);big_app(break_space);app(noop);
big_app(cancel);big_app1(pp+1);big_app(force);
reduce(pp,2,stmt,-1,61);
}

/*:155*/
#line 2539 "mcweave.w"
;break;
case case_like:/*159:*/
#line 3078 "mcweave.w"

if(cat1==semi)squash(pp,2,stmt,-1,70);
else if(cat1==colon)squash(pp,2,tag,-1,71);
else if(cat1==exp){
if(cat2==semi){
big_app1(pp);big_app(' ');big_app1(pp+1);big_app1(pp+2);
reduce(pp,3,stmt,-1,72);
}
else if(cat2==colon){
big_app1(pp);big_app(' ');big_app1(pp+1);big_app1(pp+2);
reduce(pp,3,tag,-1,73);
}
}

/*:159*/
#line 2540 "mcweave.w"
;break;
case stmt:/*161:*/
#line 3107 "mcweave.w"

if(cat1==stmt||cat1==decl||cat1==function){
int shift= -1;
big_app1(pp);
if(cat1==function)big_app(big_force);
else if(cat1==decl){big_app(big_force);shift= -2;}
else if(force_lines)big_app(force);
else big_app(break_space);
big_app1(pp+1);reduce(pp,2,cat1,shift,76);
}

/*:161*/
#line 2541 "mcweave.w"
;break;
case tag:/*160:*/
#line 3092 "mcweave.w"

if(cat1==tag){
big_app1(pp);big_app(break_space);big_app1(pp+1);reduce(pp,2,tag,-1,74);
}
else if(cat1==stmt||cat1==decl||cat1==function){
int shift= -1;
if(cat1==decl)shift= -2;
big_app(force);big_app(backup);big_app1(pp);big_app(break_space);
big_app1(pp+1);reduce(pp,2,cat1,shift,75);
}

/*:160*/
#line 2542 "mcweave.w"
;break;
case semi:/*162:*/
#line 3118 "mcweave.w"

big_app(' ');big_app1(pp);reduce(pp,1,stmt,-1,77);

/*:162*/
#line 2543 "mcweave.w"
;break;
case lproc:/*163:*/
#line 3121 "mcweave.w"

if(cat1==define_like)make_underlined(pp+2);
if(cat1==else_like||cat1==if_like||cat1==define_like)
squash(pp,2,lproc,0,78);
else if(cat1==rproc){
app(inserted);big_app2(pp);reduce(pp,2,insert,-1,79);
}else if(cat1==exp||cat1==function){
if(cat2==rproc){
app(inserted);big_app1(pp);big_app(' ');big_app2(pp+1);
reduce(pp,3,insert,-1,80);
}
else if(cat2==exp&&cat3==rproc&&cat1==exp){
app(inserted);big_app1(pp);big_app(' ');big_app1(pp+1);app_str(" \\5");

big_app2(pp+2);reduce(pp,4,insert,-1,80);
}
}

/*:163*/
#line 2544 "mcweave.w"
;break;
case section_scrap:/*164:*/
#line 3139 "mcweave.w"

if(cat1==semi){
big_app2(pp);big_app(force);reduce(pp,2,stmt,-2,81);
}
else squash(pp,1,exp,-2,82);

/*:164*/
#line 2545 "mcweave.w"
;break;
case insert:/*165:*/
#line 3145 "mcweave.w"

if(cat1)
squash(pp,2,cat1,0,83);

/*:165*/
#line 2546 "mcweave.w"
;break;
case prelangle:/*166:*/
#line 3149 "mcweave.w"

init_mathness= cur_mathness= yes_math;
app('<');reduce(pp,1,binop,-2,84);

/*:166*/
#line 2547 "mcweave.w"
;break;
case prerangle:/*167:*/
#line 3153 "mcweave.w"

init_mathness= cur_mathness= yes_math;
app('>');reduce(pp,1,binop,-2,85);

/*:167*/
#line 2548 "mcweave.w"
;break;
case langle:/*168:*/
#line 3157 "mcweave.w"

if(cat1==exp&&cat2==prerangle)squash(pp,3,cast,-1,86);
else if(cat1==prerangle){
big_app1(pp);app('\\');app(',');big_app1(pp+1);

reduce(pp,2,cast,-1,87);
}
else if(cat1==decl_head||cat1==int_like){
if(cat2==prerangle)squash(pp,3,cast,-1,88);
else if(cat2==comma){
big_app3(pp);app(opt);app('9');reduce(pp,3,langle,0,89);
}
}

/*:168*/
#line 2549 "mcweave.w"
;break;
case public_like:/*169:*/
#line 3171 "mcweave.w"

if(cat1==colon)squash(pp,2,tag,-1,90);
else squash(pp,1,int_like,-2,91);

/*:169*/
#line 2550 "mcweave.w"
;break;
case colcol:/*170:*/
#line 3175 "mcweave.w"

if(cat1==exp||cat1==int_like)squash(pp,2,cat1,-2,92);

/*:170*/
#line 2551 "mcweave.w"
;break;
case new_like:/*171:*/
#line 3178 "mcweave.w"

if(cat1==exp||(cat1==raw_int&&cat2!=prelangle&&cat2!=langle)){
big_app1(pp);big_app(' ');big_app1(pp+1);reduce(pp,2,new_like,0,93);
}
else if(cat1==raw_unorbin||cat1==colcol)
squash(pp,2,new_like,0,94);
else if(cat1==cast)squash(pp,2,exp,-2,95);
else if(cat1!=lpar&&cat1!=raw_int&&cat1!=struct_like)
squash(pp,1,exp,-2,96);

/*:171*/
#line 2552 "mcweave.w"
;break;
case operator_like:/*172:*/
#line 3188 "mcweave.w"

if(cat1==binop||cat1==unop||cat1==unorbinop){
if(cat2==binop)break;
big_app1(pp);big_app('{');big_app1(pp+1);big_app('}');
reduce(pp,2,exp,-2,97);
}
else if(cat1==new_like||cat1==sizeof_like){
big_app1(pp);big_app(' ');big_app1(pp+1);reduce(pp,2,exp,-2,98);
}
else squash(pp,1,new_like,0,99);

/*:172*/
#line 2553 "mcweave.w"
;break;
case catch_like:/*173:*/
#line 3199 "mcweave.w"

if(cat1==cast||cat1==exp){
big_app2(pp);big_app(indent);big_app(indent);
reduce(pp,2,fn_decl,0,100);
}

/*:173*/
#line 2554 "mcweave.w"
;break;
case base:/*174:*/
#line 3205 "mcweave.w"

if(cat1==public_like&&cat2==exp){
if(cat3==comma){
big_app2(pp);big_app(' ');big_app2(pp+2);
reduce(pp,4,base,0,101);
}else{
big_app1(pp+1);big_app(' ');big_app1(pp+2);
reduce(pp+1,2,int_like,-1,102);
}
}

/*:174*/
#line 2555 "mcweave.w"
;break;
case raw_rpar:/*175:*/
#line 3216 "mcweave.w"

if(cat1==const_like&&
(cat2==semi||cat2==lbrace||cat2==comma||cat2==binop
||cat2==const_like)){
big_app1(pp);big_app(' ');
big_app1(pp+1);reduce(pp,2,raw_rpar,0,103);
}else squash(pp,1,rpar,-3,104);

/*:175*/
#line 2556 "mcweave.w"
;break;
case raw_unorbin:/*176:*/
#line 3224 "mcweave.w"

if(cat1==const_like){
big_app2(pp);app_str("\\ ");reduce(pp,2,raw_unorbin,0,105);

}else squash(pp,1,unorbinop,-2,106);

/*:176*/
#line 2557 "mcweave.w"
;break;
case const_like:/*177:*/
#line 3230 "mcweave.w"

squash(pp,1,int_like,-2,107);

/*:177*/
#line 2558 "mcweave.w"
;break;
case raw_int:/*178:*/
#line 3233 "mcweave.w"

if(cat1==lpar)squash(pp,1,exp,-2,108);
else squash(pp,1,int_like,-3,109);

/*:178*/
#line 2559 "mcweave.w"
;break;
}
pp++;
}

/*:123*/
#line 3327 "mcweave.w"
;
}

/*:183*/
#line 3387 "mcweave.w"
;
/*188:*/
#line 3396 "mcweave.w"
{
/*189:*/
#line 3408 "mcweave.w"

if(lo_ptr>scrap_base&&tracing==1){
printf("\nIrreducible scrap sequence in section %d:",section_count);

mark_harmless;
for(j= scrap_base;j<=lo_ptr;j++){
printf(" ");print_cat(j->cat);
}
}

/*:189*/
#line 3397 "mcweave.w"
;
for(j= scrap_base;j<=lo_ptr;j++){
if(j!=scrap_base)app(' ');
if(j->mathness%4==yes_math)app('$');
app1(j);
if(j->mathness/4==yes_math)app('$');
if(tok_ptr+6>tok_mem_end)overflow("token");
}
freeze_text;return(text_ptr-1);
}

/*:188*/
#line 3388 "mcweave.w"
;
}

/*:187*//*191:*/
#line 3444 "mcweave.w"

void
C_parse(spec_ctrl)
eight_bits spec_ctrl;
{
while(next_control<format_code||next_control==spec_ctrl){
/*193:*/
#line 3468 "mcweave.w"

/*194:*/
#line 3546 "mcweave.w"

if(scrap_ptr+safe_scrap_incr>scrap_info_end||
tok_ptr+safe_tok_incr>tok_mem_end||
text_ptr+safe_text_incr>tok_start_end){
if(scrap_ptr>max_scr_ptr)max_scr_ptr= scrap_ptr;
if(tok_ptr>max_tok_ptr)max_tok_ptr= tok_ptr;
if(text_ptr>max_text_ptr)max_text_ptr= text_ptr;
overflow("scrap/token/text");
}

/*:194*/
#line 3469 "mcweave.w"
;
switch(next_control){
case special_command:
next_control= get_next();
/*195:*/
#line 3561 "mcweave.w"

{
if(next_control==identifier){
name_pointer p= id_lookup(id_first,id_loc,normal);
if(p==id_global||p==id_shared||p==id_export){
app(res_flag+(int)(p-name_dir));
app_scrap(raw_int,maybe_math);
break;
}
if(p==id_from)
/*197:*/
#line 3635 "mcweave.w"

{
app(force);app(preproc_line);app_str("\\#");
app(res_flag+(int)(p-name_dir));
next_control= get_next();
if(next_control==identifier){
p= id_lookup(id_first,id_loc,normal);
if(p==id_program||p==id_library){
app(' ');app(res_flag+(int)(p-name_dir));
next_control= get_next();
if(next_control==string){
app(' ');append_string();
next_control= get_next();
if(next_control==identifier){
p= id_lookup(id_first,id_loc,normal);
if(p==id_import){
app(' ');app(opt);app('5');
app(res_flag+(int)(p-name_dir));
next_control= get_next();
if(next_control==identifier){
p= id_lookup(id_first,id_loc,normal);
if(p==id_transitively){
app(' ');app(res_flag+(int)(p-name_dir));
}
else goto got_next_one;
next_control= get_next();
}
if(next_control==string){
while(next_control==string){
app(break_space);append_string();
next_control= get_next();
if(next_control==','){
app(',');next_control= get_next();
}
}
app(force);
}
}
}
}
}
}
}

/*:197*/
#line 3571 "mcweave.w"

else if(p==id_import)
/*198:*/
#line 3681 "mcweave.w"

{
app(force);app(preproc_line);app_str("\\#");
app(res_flag+(int)(p-name_dir));
next_control= get_next();
if(next_control==identifier){
p= id_lookup(id_first,id_loc,normal);
if(p==id_transitively){
app(' ');app(res_flag+(int)(p-name_dir));
next_control= get_next();
if(next_control==identifier)
p= id_lookup(id_first,id_loc,normal);
else goto got_next_one;
}
if(p==id_program||p==id_library||p==id_chapter){
app(' ');app(res_flag+(int)(p-name_dir));
next_control= get_next();
if(next_control==string){
while(next_control==string){
app(break_space);append_string();
next_control= get_next();
if(next_control==','){
app(',');next_control= get_next();
}
}
app(force);
}
}
}
}

/*:198*/
#line 3573 "mcweave.w"

else if(p==id_mark){
next_control= get_next();
if(next_control==string)break;
err_print("! Name of copy buffer expected");

}
else if(p==id_copy)break;
else if(p==id_paste){
next_control= get_next();
if(next_control==string){
*id_loc= 0;
paste(id_first);
break;
}
}
else err_print("! Illegal special command in C text");

}
}

/*:195*/
#line 3473 "mcweave.w"
;
goto got_next_one;
case section_name:
app(section_flag+(int)(cur_section-name_dir));
app_scrap(section_scrap,maybe_math);
app_scrap(exp,yes_math);break;
case string:case constant:case verbatim:/*199:*/
#line 3720 "mcweave.w"

append_string();

/*:199*/
#line 3479 "mcweave.w"
;
break;
case identifier:app_cur_id(1);break;
case TeX_string:/*202:*/
#line 3794 "mcweave.w"

app_str("\\hbox{");

while(id_first<id_loc)
if((eight_bits)(*id_first)>0177){
app_tok(quoted_char);
app_tok((eight_bits)(*id_first++));
}
else{
if(*id_first=='@')id_first++;
app_tok(*id_first++);
}
app('}');

/*:202*/
#line 3482 "mcweave.w"
;break;
case'/':case'.':
app(next_control);app_scrap(binop,yes_math);break;
case'<':app_str("\\langle");app_scrap(prelangle,yes_math);break;

case'>':app_str("\\rangle");app_scrap(prerangle,yes_math);break;

case'=':app_str("\\K");app_scrap(binop,yes_math);break;

case'|':app_str("\\OR");app_scrap(binop,yes_math);break;

case'^':app_str("\\XOR");app_scrap(binop,yes_math);break;

case'%':app_str("\\MOD");app_scrap(binop,yes_math);break;

case'!':app_str("\\R");app_scrap(unop,yes_math);break;

case'~':app_str("\\CM");app_scrap(unop,yes_math);break;

case'+':case'-':app(next_control);app_scrap(unorbinop,yes_math);break;
case'*':app(next_control);app_scrap(raw_unorbin,yes_math);break;
case'&':app_str("\\AND");app_scrap(raw_unorbin,yes_math);break;

case'?':app_str("\\?");app_scrap(question,yes_math);break;

case'#':app_str("\\#");app_scrap(unorbinop,yes_math);break;

case ignore:case xref_roman:case xref_wildcard:
case xref_typewriter:case noop:break;
case'(':case'[':app(next_control);app_scrap(lpar,maybe_math);break;
case')':case']':app(next_control);app_scrap(raw_rpar,maybe_math);break;
case'{':app_str("\\{");app_scrap(lbrace,yes_math);break;

case'}':app_str("\\}");app_scrap(rbrace,yes_math);break;

case',':app(',');app_scrap(comma,yes_math);break;
case';':app(';');app_scrap(semi,maybe_math);break;
case':':app(':');app_scrap(colon,maybe_math);break;
/*196:*/
#line 3598 "mcweave.w"

case not_eq:app_str("\\I");app_scrap(binop,yes_math);break;

case lt_eq:app_str("\\Z");app_scrap(binop,yes_math);break;

case gt_eq:app_str("\\G");app_scrap(binop,yes_math);break;

case eq_eq:app_str("\\E");app_scrap(binop,yes_math);break;

case and_and:app_str("\\W");app_scrap(binop,yes_math);break;

case or_or:app_str("\\V");app_scrap(binop,yes_math);break;

case plus_plus:app_str("\\PP");app_scrap(unop,yes_math);break;

case minus_minus:app_str("\\MM");app_scrap(unop,yes_math);break;

case minus_gt:app_str("\\MG");app_scrap(binop,yes_math);break;

case gt_gt:app_str("\\GG");app_scrap(binop,yes_math);break;

case lt_lt:app_str("\\LL");app_scrap(binop,yes_math);break;

case dot_dot_dot:app_str("\\,\\ldots\\,");app_scrap(exp,yes_math);break;


case colon_colon:app_str("\\DC");app_scrap(colcol,maybe_math);break;

case period_ast:app_str("\\PA");app_scrap(binop,yes_math);break;

case minus_gt_ast:app_str("\\MGA");app_scrap(binop,yes_math);break;


/*:196*/
#line 3520 "mcweave.w"

case thin_space:app_str("\\,");app_scrap(insert,maybe_math);break;

case math_break:app(opt);app_str("0");
app_scrap(insert,maybe_math);break;
case line_break:app(force);app_scrap(insert,no_math);break;
case left_preproc:app(force);app(preproc_line);
app_str("\\#");app_scrap(lproc,no_math);break;

case right_preproc:app(force);app_scrap(rproc,no_math);break;
case big_line_break:app(big_force);app_scrap(insert,no_math);break;
case no_line_break:app(big_cancel);app(noop);app(break_space);
app(noop);app(big_cancel);
app_scrap(insert,no_math);break;
case pseudo_semi:app_scrap(semi,maybe_math);break;
case macro_arg_open:app_scrap(begin_arg,maybe_math);break;
case macro_arg_close:app_scrap(end_arg,maybe_math);break;
case join:app_str("\\J");app_scrap(insert,no_math);break;

case output_defs_code:app(force);app_str("\\ATH");app(force);
app_scrap(insert,no_math);break;

default:app(inserted);app(next_control);
app_scrap(insert,maybe_math);break;
}

/*:193*/
#line 3450 "mcweave.w"
;
next_control= get_next();
got_next_one:
if(next_control=='|'||next_control==begin_comment||
next_control==begin_short_comment)return;
if(next_control==example_code&&is_example)return;
}
}

/*:191*//*201:*/
#line 3728 "mcweave.w"

void
append_string()
{
int count= -1;
if(next_control==constant)app_str("\\T{");

else if(next_control==string){
count= 20;app_str("\\.{");
}

else app_str("\\vb{");

while(id_first<id_loc){
if(count==0){
app_str("}\\)\\.{");count= 20;

}

if((eight_bits)(*id_first)>0177){
app_tok(quoted_char);
app_tok((eight_bits)(*id_first++));
}
else{
switch(*id_first){
case' ':case'\\':case'#':case'%':case'$':case'^':
case'{':case'}':case'~':case'&':case'_':app('\\');break;











case'@':if(*(id_first+1)=='@')id_first++;
else if(!parsing_exp_file)
err_print("! Double @ should be used in strings");

}
app_tok(*id_first++);
}
count--;
}
app('}');
app_scrap(exp,maybe_math);
}

/*:201*//*204:*/
#line 3814 "mcweave.w"

void
app_cur_id(scrapping)
boolean scrapping;
{
name_pointer p= id_lookup(id_first,id_loc,normal);
if(p->ilk<=quoted){
app(id_flag+(int)(p-name_dir));
if(scrapping)app_scrap(exp,p->ilk>=custom?yes_math:maybe_math);

}else{
app(res_flag+(int)(p-name_dir));
if(scrapping)app_scrap(p->ilk,maybe_math);
}
}

/*:204*//*205:*/
#line 3835 "mcweave.w"

text_pointer
C_translate()
{
text_pointer p;
scrap_pointer save_base;
save_base= scrap_base;scrap_base= scrap_ptr+1;
C_parse(section_name);
if(next_control!='|')err_print("! Missing '|' after C text");

app_tok(cancel);app_scrap(insert,maybe_math);

p= translate();
if(scrap_ptr>max_scr_ptr)max_scr_ptr= scrap_ptr;
scrap_ptr= scrap_base-1;scrap_base= save_base;
return(p);
}

/*:205*//*206:*/
#line 3857 "mcweave.w"

void
outer_parse()
{
int bal;
text_pointer p,q;
while(next_control<format_code)
if(next_control!=begin_comment&&next_control!=begin_short_comment){
if(is_example&&next_control==example_code)return;
C_parse(ignore);
}
else{
boolean is_long_comment= (next_control==begin_comment);
/*194:*/
#line 3546 "mcweave.w"

if(scrap_ptr+safe_scrap_incr>scrap_info_end||
tok_ptr+safe_tok_incr>tok_mem_end||
text_ptr+safe_text_incr>tok_start_end){
if(scrap_ptr>max_scr_ptr)max_scr_ptr= scrap_ptr;
if(tok_ptr>max_tok_ptr)max_tok_ptr= tok_ptr;
if(text_ptr>max_text_ptr)max_text_ptr= text_ptr;
overflow("scrap/token/text");
}

/*:194*/
#line 3870 "mcweave.w"
;
app(cancel);app(inserted);
if(is_long_comment)app_str("\\C{");

else app_str("\\SHC{");

bal= copy_comment(is_long_comment,1);next_control= ignore;
while(bal>0){
p= text_ptr;freeze_text;q= C_translate();

app(tok_flag+(int)(p-tok_start));
app_str("\\PB{");app(inner_tok_flag+(int)(q-tok_start));app_tok('}');

if(next_control=='|'){
bal= copy_comment(is_long_comment,bal);
next_control= ignore;
}
else bal= 0;
}
app(force);app_scrap(insert,no_math);

}
}

/*:206*//*210:*/
#line 3915 "mcweave.w"

void
process_example()
{
is_example= 1;
out_str("\\par");init_stack;
next_control= get_next();
if(next_control!=definition){
outer_parse();
finish_C(1);
}
while(next_control==definition){
/*242:*/
#line 4569 "mcweave.w"
{
name_pointer p;
if(save_line!=out_line||save_place!=out_ptr||space_checked)app(backup);
if(!space_checked){emit_space_if_needed;save_position;}
app_str("\\D");

while((next_control= get_next())==special_command){
next_control= get_next();
if(next_control!=identifier)break;
p= id_lookup(id_first,id_loc,normal);
if(p==id_global||p==id_shared||p==id_export){
app(res_flag+(int)(p-name_dir));
app(' ');
}
}
if(next_control!=identifier)
err_print("! Improper macro definition");

else{
app('$');app_cur_id(0);
if(*loc=='(')
reswitch:switch(next_control= get_next()){
case'(':case',':app(next_control);goto reswitch;
case identifier:app_cur_id(0);goto reswitch;
case')':app(next_control);next_control= get_next();break;
default:err_print("! Improper macro definition");break;
}
else next_control= get_next();
app_str("$ ");app(break_space);
app_scrap(dead,no_math);
}
}

/*:242*/
#line 3927 "mcweave.w"
;
outer_parse();
finish_C(1);
}
if(next_control!=example_code)
err_print("! Closing @e of example section expected");

out_str("\\setsec\n");
finish_line();
is_example= 0;
}

/*:210*//*215:*/
#line 4008 "mcweave.w"

void
push_level(p)
text_pointer p;
{
if(stack_ptr==stack_end)overflow("stack");
if(stack_ptr>stack){
stack_ptr->end_field= cur_end;
stack_ptr->tok_field= cur_tok;
stack_ptr->mode_field= cur_mode;
}
stack_ptr++;
if(stack_ptr>max_stack_ptr)max_stack_ptr= stack_ptr;
cur_tok= *p;cur_end= *(p+1);
}

/*:215*//*216:*/
#line 4028 "mcweave.w"

void
pop_level()
{
cur_end= (--stack_ptr)->end_field;
cur_tok= stack_ptr->tok_field;cur_mode= stack_ptr->mode_field;
}

/*:216*//*218:*/
#line 4050 "mcweave.w"

eight_bits
get_output()
{
sixteen_bits a;
restart:while(cur_tok==cur_end)pop_level();
a= *(cur_tok++);
if(a>=0400){
cur_name= a%id_flag+name_dir;
switch(a/id_flag){
case 2:return(res_word);
case 3:return(section_code);
case 4:push_level(a%id_flag+tok_start);goto restart;

case 5:push_level(a%id_flag+tok_start);cur_mode= inner;goto restart;

default:return(identifier);
}
}
#line 25 "mcweave-Amiga.ch"
return((eight_bits)a);
#line 4070 "mcweave.w"
}

/*:218*//*219:*/
#line 4092 "mcweave.w"

void
output_C()
{
token_pointer save_tok_ptr;
text_pointer save_text_ptr;
sixteen_bits save_next_control;
text_pointer p;
save_tok_ptr= tok_ptr;save_text_ptr= text_ptr;
save_next_control= next_control;next_control= ignore;p= C_translate();
app(inner_tok_flag+(int)(p-tok_start));
out_str("\\PB{");make_output();out('}');

if(text_ptr>max_text_ptr)max_text_ptr= text_ptr;
if(tok_ptr>max_tok_ptr)max_tok_ptr= tok_ptr;
text_ptr= save_text_ptr;tok_ptr= save_tok_ptr;
next_control= save_next_control;
}

/*:219*//*221:*/
#line 4116 "mcweave.w"

void
make_output()
{
eight_bits a,
b;
int c;
char scratch[longest_name];
char*k,*k_limit;
char*j;
char*p;
char delim;
char*save_loc,*save_limit;
name_pointer cur_section_name;
boolean save_mode;
app(end_translation);
freeze_text;push_level(text_ptr-1);
while(1){
a= get_output();
reswitch:switch(a){
case end_translation:return;
case identifier:case res_word:/*222:*/
#line 4166 "mcweave.w"

out('\\');
if(a==identifier){
if(cur_name->ilk>=custom&&cur_name->ilk<=quoted&&!doing_format){
for(p= cur_name->byte_start;p<(cur_name+1)->byte_start;p++)
out(isxalpha(*p)?'x':*p);
break;
}else if(is_tiny(cur_name))out('|')

else{delim= '.';
for(p= cur_name->byte_start;p<(cur_name+1)->byte_start;p++)
if(xislower(*p)){
delim= '\\';break;
}
out(delim);
}


}
else out('&')

if(is_tiny(cur_name)){
if(isxalpha((cur_name->byte_start)[0]))
out('\\');
out((cur_name->byte_start)[0]);
}
else out_name(cur_name);

/*:222*/
#line 4137 "mcweave.w"
;break;
case section_code:/*226:*/
#line 4265 "mcweave.w"
{
out_str("\\X");

cur_xref= (xref_pointer)cur_name->xref;
if(cur_xref->num==file_flag){an_output= 1;cur_xref= cur_xref->xlink;}
else an_output= 0;
if(cur_xref->num>=def_flag){
out_section(cur_xref->num-def_flag);
if(phase==3){
cur_xref= cur_xref->xlink;
while(cur_xref->num>=def_flag){
out_str(", ");
out_section(cur_xref->num-def_flag);
cur_xref= cur_xref->xlink;
}
}
}
else out('0');
out(':');
if(an_output)out_str("\\.{");

/*227:*/
#line 4291 "mcweave.w"

sprint_section_name(scratch,cur_name);
k= scratch;
k_limit= scratch+strlen(scratch);
cur_section_name= cur_name;
while(k<k_limit){
b= *(k++);
if(b=='@')/*228:*/
#line 4326 "mcweave.w"

if(*k++!='@'){
printf("\n! Illegal control code in section name: <");

print_section_name(cur_section_name);printf("> ");mark_error;
}

/*:228*/
#line 4298 "mcweave.w"
;
if(an_output)
switch(b){
case' ':case'\\':case'#':case'%':case'$':case'^':
case'{':case'}':case'~':case'&':case'_':
out('\\');











default:out(b);
}
else if(b!='|')out(b)
else{
/*229:*/
#line 4339 "mcweave.w"

j= limit+1;*j= '|';delim= 0;
while(1){
if(k>=k_limit){
printf("\n! C text in section name didn't end: <");

print_section_name(cur_section_name);printf("> ");mark_error;break;
}
b= *(k++);
if(b=='@'||(b=='\\'&&delim!=0))
/*230:*/
#line 4362 "mcweave.w"
{
if(j>buffer+long_buf_size-4)overflow("buffer");
*(++j)= b;*(++j)= *(k++);
}

/*:230*/
#line 4349 "mcweave.w"

else{
if(b=='\''||b=='"')
if(delim==0)delim= b;
else if(delim==b)delim= 0;
if(b!='|'||delim!=0){
if(j>buffer+long_buf_size-3)overflow("buffer");
*(++j)= b;
}
else break;
}
}

/*:229*/
#line 4319 "mcweave.w"
;
save_loc= loc;save_limit= limit;loc= limit+2;limit= j+1;
*limit= '|';output_C();
loc= save_loc;limit= save_limit;
}
}

/*:227*/
#line 4286 "mcweave.w"
;
if(an_output)out_str(" }");
out_str("\\X");
}

/*:226*/
#line 4138 "mcweave.w"
;break;
case math_rel:out_str("\\MRL{");

case noop:case inserted:break;
case cancel:case big_cancel:c= 0;b= a;
while(1){
a= get_output();
if(a==inserted)continue;
if((a<indent&&!(b==big_cancel&&a==' '))||a>big_force)break;
if(a==indent)c++;else if(a==outdent)c--;
else if(a==opt)a= get_output();
}
/*225:*/
#line 4252 "mcweave.w"

for(;c>0;c--)out_str("\\1");

for(;c<0;c++)out_str("\\2");


/*:225*/
#line 4150 "mcweave.w"
;
goto reswitch;
case indent:case outdent:case opt:case backup:case break_space:
case force:case big_force:case preproc_line:/*223:*/
#line 4197 "mcweave.w"

if(a<break_space||a==preproc_line){
if(cur_mode==outer){
out('\\');out(a-cancel+'0');





if(a==opt){
b= get_output();
if(b!='0'||force_lines==0)out(b)
else out_str("{-1}");
}
}else if(a==opt)b= get_output();
}
else/*224:*/
#line 4221 "mcweave.w"
{
b= a;save_mode= cur_mode;c= 0;
while(1){
a= get_output();
if(a==inserted)continue;
if(a==cancel||a==big_cancel){
/*225:*/
#line 4252 "mcweave.w"

for(;c>0;c--)out_str("\\1");

for(;c<0;c++)out_str("\\2");


/*:225*/
#line 4227 "mcweave.w"
;
goto reswitch;
}
if((a!=' '&&a<indent)||a==backup||a>big_force){
if(save_mode==outer){
if(out_ptr>out_buf+3&&(strncmp(out_ptr-3,"\\Y\\B",4)==0||
strncmp(out_ptr-5,"\\par\\B",6)==0))
goto reswitch;
/*225:*/
#line 4252 "mcweave.w"

for(;c>0;c--)out_str("\\1");

for(;c<0;c++)out_str("\\2");


/*:225*/
#line 4235 "mcweave.w"
;
out('\\');out(b-cancel+'0');



if(a!=end_translation)finish_line();
}
else if(a!=end_translation&&cur_mode==inner)out(' ');
goto reswitch;
}
if(a==indent)c++;
else if(a==outdent)c--;
else if(a==opt)a= get_output();
else if(a>b)b= a;
}
}

/*:224*/
#line 4213 "mcweave.w"


/*:223*/
#line 4154 "mcweave.w"
;break;
case quoted_char:out(*(cur_tok++));break;
default:out(a);
}
}
}

/*:221*//*232:*/
#line 4377 "mcweave.w"

void
phase_two(){
reset_input();if(show_progress)printf("\nWriting the output file...");

section_count= 0;format_visible= 1;copy_limbo();
finish_line();flush_buffer(out_buf,0,0);
while(!input_has_ended)/*235:*/
#line 4414 "mcweave.w"
{
section_count++;
/*236:*/
#line 4432 "mcweave.w"

if(*(loc-1)!='*')out_str("\\M");

else{
while(*loc==' ')loc++;
if(*loc=='*'){
sec_depth= -1;
loc++;
}
else{
for(sec_depth= 0;xisdigit(*loc);loc++)
sec_depth= sec_depth*10+(*loc)-'0';
}
while(*loc==' ')loc++;
group_found= 1;
out_str("\\N");

{char s[32];sprintf(s,"{%d}",sec_depth+1);out_str(s);}
if(show_progress)
printf("*%d",section_count);update_terminal;
}
out_str("{");out_section(section_count);out_str("}");

/*:236*/
#line 4416 "mcweave.w"
;
save_position;
/*237:*/
#line 4458 "mcweave.w"
do{
next_control= copy_TeX();
switch(next_control){
case'|':init_stack;output_C();break;
case'@':out('@');break;
case TeX_string:case noop:
case xref_roman:case xref_wildcard:case xref_typewriter:
case section_name:loc-= 2;next_control= get_next();
if(next_control==TeX_string)
err_print("! TeX string should be in C text only");break;

case thin_space:case math_break:case ord:
case line_break:case big_line_break:case no_line_break:case join:
case pseudo_semi:case macro_arg_open:case macro_arg_close:
case output_defs_code:
err_print("! You can't do that in TeX text");break;

case autodoc_code:process_autodoc();break;
case example_code:process_example();break;
case special_command:/*238:*/
#line 4485 "mcweave.w"

{
next_control= get_next();
if(next_control==identifier){
name_pointer p= id_lookup(id_first,id_loc,normal);
if(p==id_paste){
next_control= get_next();
if(next_control==string){
*id_loc= 0;
paste(id_first);
}
else err_print("! Name of copy buffer expected");

}
else if(p==id_mark)next_control= get_next();
else if(p!=id_copy)
err_print("! Illegal special command in TeX text");

}
else err_print("! Name of special command expected");

}

/*:238*/
#line 4477 "mcweave.w"
;break;
}
}while(next_control<format_code);

/*:237*/
#line 4418 "mcweave.w"
;
/*239:*/
#line 4511 "mcweave.w"

space_checked= 0;
while(next_control<=definition){
init_stack;
if(next_control==definition)/*242:*/
#line 4569 "mcweave.w"
{
name_pointer p;
if(save_line!=out_line||save_place!=out_ptr||space_checked)app(backup);
if(!space_checked){emit_space_if_needed;save_position;}
app_str("\\D");

while((next_control= get_next())==special_command){
next_control= get_next();
if(next_control!=identifier)break;
p= id_lookup(id_first,id_loc,normal);
if(p==id_global||p==id_shared||p==id_export){
app(res_flag+(int)(p-name_dir));
app(' ');
}
}
if(next_control!=identifier)
err_print("! Improper macro definition");

else{
app('$');app_cur_id(0);
if(*loc=='(')
reswitch:switch(next_control= get_next()){
case'(':case',':app(next_control);goto reswitch;
case identifier:app_cur_id(0);goto reswitch;
case')':app(next_control);next_control= get_next();break;
default:err_print("! Improper macro definition");break;
}
else next_control= get_next();
app_str("$ ");app(break_space);
app_scrap(dead,no_math);
}
}

/*:242*/
#line 4515 "mcweave.w"

else/*243:*/
#line 4602 "mcweave.w"
{
doing_format= 1;
if(*(loc-1)=='s'||*(loc-1)=='S')format_visible= 0;
if(!space_checked){emit_space_if_needed;save_position;}
app_str("\\F");

next_control= get_next();
if(next_control==identifier){
app(id_flag+(int)(id_lookup(id_first,id_loc,normal)-name_dir));
app(' ');
app(break_space);
next_control= get_next();
if(next_control==identifier){
app(id_flag+(int)(id_lookup(id_first,id_loc,normal)-name_dir));
app_scrap(exp,maybe_math);app_scrap(semi,maybe_math);
next_control= get_next();
}
}
if(scrap_ptr!=scrap_info+2)err_print("! Improper format definition");

}

/*:243*/
#line 4516 "mcweave.w"
;
outer_parse();finish_C(format_visible);format_visible= 1;
doing_format= 0;
}

/*:239*/
#line 4419 "mcweave.w"
;
/*245:*/
#line 4631 "mcweave.w"

this_section= name_dir;
if(next_control<=section_name){
emit_space_if_needed;init_stack;
if(next_control==begin_C)next_control= get_next();
else{
this_section= cur_section;
/*246:*/
#line 4651 "mcweave.w"

do next_control= get_next();
while(next_control=='+');
if(next_control!='='&&next_control!=eq_eq)
err_print("! You need an = sign after the section name");

else next_control= get_next();
if(out_ptr>out_buf+1&&*out_ptr=='Y'&&*(out_ptr-1)=='\\')app(backup);


app(section_flag+(int)(this_section-name_dir));
cur_xref= (xref_pointer)this_section->xref;
if(cur_xref->num==file_flag)cur_xref= cur_xref->xlink;
app_str("${}");
if(cur_xref->num!=section_count+def_flag){
app_str("\\mathrel+");
this_section= name_dir;
}
app_str("\\E");

app_str("{}$");
app(force);app_scrap(dead,no_math);


/*:246*/
#line 4639 "mcweave.w"
;
}
while(next_control<=section_name){
outer_parse();
/*247:*/
#line 4675 "mcweave.w"

if(next_control<section_name){
err_print("! You can't do that in C text");

next_control= get_next();
}
else if(next_control==section_name){
app(section_flag+(int)(cur_section-name_dir));
app_scrap(section_scrap,maybe_math);
next_control= get_next();
}

/*:247*/
#line 4643 "mcweave.w"
;
}
finish_C(1);
}

/*:245*/
#line 4420 "mcweave.w"
;
/*248:*/
#line 4690 "mcweave.w"

if(this_section>name_dir){
cur_xref= (xref_pointer)this_section->xref;
if(cur_xref->num==file_flag){an_output= 1;cur_xref= cur_xref->xlink;}
else an_output= 0;
if(cur_xref->num>def_flag)
cur_xref= cur_xref->xlink;
footnote(def_flag);footnote(cite_flag);footnote(0);
}

/*:248*/
#line 4421 "mcweave.w"
;
/*252:*/
#line 4748 "mcweave.w"

out_str("\\fi");finish_line();

flush_buffer(out_buf,0,0);

/*:252*/
#line 4422 "mcweave.w"
;
}

/*:235*/
#line 4384 "mcweave.w"
;
}

/*:232*//*241:*/
#line 4534 "mcweave.w"

void
finish_C(visible)
boolean visible;
{
text_pointer p;
if(visible){
out_str("\\B");app_tok(force);app_scrap(insert,no_math);
p= translate();

app(tok_flag+(int)(p-tok_start));make_output();
if(out_ptr>out_buf+1)
if(*(out_ptr-1)=='\\')



if(*out_ptr=='6')out_ptr-= 2;
else if(*out_ptr=='7')*out_ptr= 'Y';
out_str("\\par");finish_line();
}
if(text_ptr>max_text_ptr)max_text_ptr= text_ptr;
if(tok_ptr>max_tok_ptr)max_tok_ptr= tok_ptr;
if(scrap_ptr>max_scr_ptr)max_scr_ptr= scrap_ptr;
tok_ptr= tok_mem+1;text_ptr= tok_start+1;scrap_ptr= scrap_info;

}

/*:241*//*250:*/
#line 4715 "mcweave.w"

void
footnote(flag)
sixteen_bits flag;
{
xref_pointer q;
if(cur_xref->num<=flag)return;
finish_line();out('\\');



out(flag==0?'U':flag==cite_flag?'Q':'A');
/*251:*/
#line 4735 "mcweave.w"

q= cur_xref;if(q->xlink->num>flag)out('s');
while(1){
out_section(cur_xref->num-flag);
cur_xref= cur_xref->xlink;
if(cur_xref->num<=flag)break;
if(cur_xref->xlink->num>flag)out_str(", ");
else{out_str("\\ET");

if(cur_xref!=q->xlink)out('s');
}
}

/*:251*/
#line 4727 "mcweave.w"
;
out('.');
}

/*:250*//*254:*/
#line 4764 "mcweave.w"

void
phase_three(){
make_xid_file(".xid",own_export);
make_xid_file(".sid",own_shared);
make_iid_file();
if(no_xref){
finish_line();
if(!book_type)out_str("\\end");

finish_line();
}
else{
phase= 3;if(show_progress)printf("\nWriting the index...");

finish_line();
if((idx_file= fopen(idx_file_name,"w"))==NULL)
fatal("! Cannot open index file ",idx_file_name);

if(change_exists){
/*256:*/
#line 4821 "mcweave.w"
{

k_section= 0;
while(!changed_section[++k_section]);
out_str("\\ch ");

out_section(k_section);
while(k_section<section_count){
while(!changed_section[++k_section]);
out_str(", ");out_section(k_section);
}
out('.');
}

/*:256*/
#line 4784 "mcweave.w"
;finish_line();finish_line();
}
out_str("\\inx");finish_line();

active_file= idx_file;
/*258:*/
#line 4852 "mcweave.w"
{
int c;
for(c= 0;c<=255;c++)bucket[c]= NULL;
for(h= hash;h<=hash_end;h++){
next_name= *h;
while(next_name){
cur_name= next_name;next_name= cur_name->link;
if(cur_name->xref!=(char*)xmem){
c= (eight_bits)((cur_name->byte_start)[0]);
if(xisupper(c))c= tolower(c);
blink[cur_name-name_dir]= bucket[c];bucket[c]= cur_name;
}
}
}
}

/*:258*/
#line 4789 "mcweave.w"
;
/*267:*/
#line 4953 "mcweave.w"

sort_ptr= scrap_info;unbucket(1);
while(sort_ptr>scrap_info){
cur_depth= sort_ptr->depth;
if(blink[sort_ptr->head-name_dir]==0||cur_depth==infinity)
/*269:*/
#line 4978 "mcweave.w"
{
cur_name= sort_ptr->head;
do{
if(keep_only_ext_def||!only_ext_def(cur_name)){
out_str("\\I");

/*272:*/
#line 5017 "mcweave.w"

switch(cur_name->ilk){
case normal:if(is_tiny(cur_name))out_str("\\|");
else{char*j;
for(j= cur_name->byte_start;j<(cur_name+1)->byte_start;j++)
if(xislower(*j))goto lowcase;
out_str("\\.");break;
lowcase:out_str("\\\\");
}
break;



case roman:break;
case wildcard:out_str("\\9");break;

case typewriter:out_str("\\.");break;

case custom:case quoted:{char*j;out_str("$\\");
for(j= cur_name->byte_start;j<(cur_name+1)->byte_start;j++)
out(isxalpha(*j)?'x':*j);
out('$');
goto name_done;
}
default:out_str("\\&");

}
out_name(cur_name);
name_done:

/*:272*/
#line 4984 "mcweave.w"
;
/*273:*/
#line 5050 "mcweave.w"

/*275:*/
#line 5070 "mcweave.w"

this_xref= (xref_pointer)cur_name->xref;cur_xref= xmem;
do{
next_xref= this_xref->xlink;this_xref->xlink= cur_xref;
cur_xref= this_xref;this_xref= next_xref;
}while(this_xref!=xmem);

/*:275*/
#line 5051 "mcweave.w"
;
do{
out_str(", ");cur_val= cur_xref->num;
if(cur_val<def_flag)out_section(cur_val);
else{out_str("\\[");out_section(cur_val-def_flag);out(']');}

if(cur_xref->ext_ref)
/*278:*/
#line 5088 "mcweave.w"

{
struct external_reference*ref;
int i;
char ref_nr[20];

if(cur_xref->ext_ref==own_shared){
if(cur_val>=def_flag){
dag_seen= 1;
sprintf(ref_nr,"${}^{\\dag}$");
out_str(ref_nr);
}
}
else if(cur_xref->ext_ref==own_export){
if(cur_val>=def_flag){
ddag_seen= 1;
sprintf(ref_nr,"${}^{\\ddag}$");
out_str(ref_nr);
}
}
else for(i= 1,ref= first_ext_ref;ref;i++,ref= ref->next_ext_ref)
if(ref==cur_xref->ext_ref){
sprintf(ref_nr,"${}^{%d}$",i);
out_str(ref_nr);
break;
}
}

/*:278*/
#line 5058 "mcweave.w"
;
cur_xref= cur_xref->xlink;
}while(cur_xref!=xmem);
out('.');finish_line();

/*:273*/
#line 4985 "mcweave.w"
;
}
cur_name= blink[cur_name-name_dir];
}while(cur_name);
--sort_ptr;
}

/*:269*/
#line 4958 "mcweave.w"

else/*268:*/
#line 4962 "mcweave.w"
{
eight_bits c;
next_name= sort_ptr->head;
do{
cur_name= next_name;next_name= blink[cur_name-name_dir];
cur_byte= cur_name->byte_start+cur_depth;
if(cur_byte==(cur_name+1)->byte_start)c= 0;
else{
c= (eight_bits)*cur_byte;
if(xisupper(c))c= tolower(c);
}
blink[cur_name-name_dir]= bucket[c];bucket[c]= cur_name;
}while(next_name);
--sort_ptr;unbucket(cur_depth+1);
}

/*:268*/
#line 4959 "mcweave.w"
;
}

/*:267*/
#line 4790 "mcweave.w"
;
output_referenced_books();
finish_line();fclose(active_file);
active_file= tex_file;
out_str("\\fin");finish_line();

if((scn_file= fopen(scn_file_name,"w"))==NULL)
fatal("! Cannot open section file ",scn_file_name);

active_file= scn_file;
/*283:*/
#line 5181 "mcweave.w"
section_print(root)

/*:283*/
#line 4800 "mcweave.w"
;
finish_line();fclose(active_file);
active_file= tex_file;
if(group_found&&!book_type)out_str("\\con");
if(!book_type)out_str("\\end");
else out_str("\\eject");


finish_line();
fclose(active_file);
}
if(show_happiness)printf("\nDone.");
check_complete();
}

/*:254*//*266:*/
#line 4935 "mcweave.w"

void
unbucket(d)
eight_bits d;
{
int c;

for(c= 100+128;c>=0;c--)if(bucket[collate[c]]){

if(sort_ptr>=scrap_info_end)overflow("sorting");
sort_ptr++;
if(sort_ptr>max_sort_ptr)max_sort_ptr= sort_ptr;
if(c==0)sort_ptr->depth= infinity;
else sort_ptr->depth= d;
sort_ptr->head= bucket[collate[c]];bucket[collate[c]]= NULL;
}
}

/*:266*//*271:*/
#line 5001 "mcweave.w"

boolean
only_ext_def(p)
name_pointer p;
{
xref_pointer xref;
xref= (xref_pointer)p->xref;
if(xref==xmem)return 0;
if(!xref->ext_ref||xref->ext_ref==own_shared||xref->ext_ref==own_export)
return 0;
if(xref->num&def_flag)
if(xref->xlink==xmem)
return 1;
return 0;
}

/*:271*//*280:*/
#line 5122 "mcweave.w"

void
output_referenced_books()
{
struct external_reference*ref,*ref2;
char ref_str[128];
int i;

if(dag_seen||ddag_seen){
out_str("\\bigskip");
if(dag_seen)
out_str("\\shared\n");
if(ddag_seen)
out_str("\\exported\n");
}
if(first_ext_ref){
out_str("\\refchaps\n");
for(i= 1,ref= first_ext_ref;ref;i++){
sprintf(ref_str,"\\chapref{%d}{",i);
out_str(ref_str);
#line 31 "mcweave-Amiga.ch"
if(*ref->book_name&&stricmp(ref->book_name,book_name)){
#line 5143 "mcweave.w"
sprintf(ref_str,"{\\tt %s}, ",ref->book_name);
out_str(ref_str);
}
sprintf(ref_str,"\\chaptxt\\ %d}\n",ref->chapter);
out_str(ref_str);
ref2= ref;
ref= ref->next_ext_ref;
free(ref2->book_name);
free(ref2);
}
first_ext_ref= NULL;
}
}

/*:280*//*282:*/
#line 5164 "mcweave.w"

void
section_print(p)
name_pointer p;
{
if(p){
section_print(p->llink);out_str("\\I");

tok_ptr= tok_mem+1;text_ptr= tok_start+1;scrap_ptr= scrap_info;init_stack;
app(p-name_dir+section_flag);make_output();
footnote(cite_flag);
footnote(0);
finish_line();
section_print(p->rlink);
}
}

/*:282*//*284:*/
#line 5186 "mcweave.w"

void
print_stats(){
printf("\nMemory usage statistics:\n");

printf("%ld names (out of %ld)\n",
(long)(name_ptr-name_dir),(long)max_names);
printf("%ld cross-references (out of %ld)\n",
(long)(xref_ptr-xmem),(long)max_refs);
printf("%ld bytes (out of %ld)\n",
(long)(byte_ptr-byte_mem),(long)max_bytes);
printf("Parsing:\n");
printf("%ld scraps (out of %ld)\n",
(long)(max_scr_ptr-scrap_info),(long)max_scraps);
printf("%ld texts (out of %ld)\n",
(long)(max_text_ptr-tok_start),(long)max_texts);
printf("%ld tokens (out of %ld)\n",
(long)(max_tok_ptr-tok_mem),(long)max_toks);
printf("%ld levels (out of %ld)\n",
(long)(max_stack_ptr-stack),(long)stack_size);
printf("Sorting:\n");
printf("%ld levels (out of %ld)\n",
(long)(max_sort_ptr-scrap_info),(long)max_scraps);
}

/*:284*//*288:*/
#line 5239 "mcweave.w"

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

/*:288*//*289:*/
#line 5253 "mcweave.w"

void to_parent(s)
char*s;
{
char*cp= file_name_part(s);
if(cp==s)*cp= 0;
else cp[-1]= 0;
}

/*:289*//*290:*/
#line 5263 "mcweave.w"

char*
file_name_ext(s)
char*s;
{
return strrchr(file_name_part(s),'.');
}

/*:290*//*301:*/
#line 5453 "mcweave.w"

struct imported_file*
remember_import_file(name,exp_file,tangled_file)
char*name;
boolean exp_file;
int tangled_file;
{
struct imported_file*imf,*limf;
char full_name[max_file_name_length];
int len;

if(exp_file&&!is_absolute_path(name)&&dep_dir){
sprintf(full_name,"%s%c%s",dep_dir,file_name_separator,name);
name= full_name;
}
limf= NULL;
for(imf= first_imported_file;imf;imf= imf->next_imported_file){
if(!strcmp(imf->file_name,name))
return NULL;
limf= imf;
}
len= strlen(name);
imf= (struct imported_file*)malloc(sizeof(*imf)+len-1);
if(!imf)fatal("! No memory"," for import file name");

strcpy(imf->file_name,name);
imf->given_name= NULL;
imf->tangled_file= tangled_file;
if(current_imported_file){
imf->next_imported_file= current_imported_file->next_imported_file;
current_imported_file->next_imported_file= imf;
}
else{
imf->next_imported_file= NULL;
if(!limf)first_imported_file= imf;
else limf->next_imported_file= imf;
}
return imf;
}

/*:301*//*302:*/
#line 5504 "mcweave.w"

void
remember_include_file()
{
char*incl_dirs= getenv("INCLUDE");
char*cp,*col;
char full_name[max_file_name_length];
int len,id_len,path_len;
struct stat s;
struct imported_file*imf;

id_len= id_loc-id_first-2;
strncpy(full_name,id_first+1,id_len);
full_name[id_len]= 0;
/*303:*/
#line 5551 "mcweave.w"

{
for(imf= first_imported_file;imf;imf= imf->next_imported_file)
if(imf->given_name&&!strcmp(full_name,imf->given_name))
return;
}

/*:303*/
#line 5518 "mcweave.w"

/*304:*/
#line 5561 "mcweave.w"

{
if(!stat(full_name,&s)){
imf= remember_import_file(full_name,0,0);
if(imf)
imf->given_name= imf->file_name;
return;
}
}

/*:304*/
#line 5519 "mcweave.w"
;
/*305:*/
#line 5573 "mcweave.w"

{
strcpy(full_name,dep_dir);
len= strlen(full_name);
full_name[len++]= file_name_separator;
path_len= len;
strncpy(full_name+len,id_first+1,id_len);
len+= id_len;
full_name[len]= 0;
if(!stat(full_name,&s)){
imf= remember_import_file(full_name,0,1);
if(imf)
imf->given_name= imf->file_name+path_len;
return;
}
}

/*:305*/
#line 5520 "mcweave.w"
;
if(incl_dirs&&*incl_dirs)
do{
cp= col= strchr(incl_dirs,include_dir_separator);
if(!cp)cp= incl_dirs+strlen(incl_dirs);
len= cp-incl_dirs;
strncpy(full_name,incl_dirs,len);
full_name[len++]= file_name_separator;
path_len= len;
strncpy(full_name+len,id_first+1,id_len);
len+= id_len;
full_name[len]= 0;
if(!stat(full_name,&s)){
imf= remember_import_file(full_name,0,!strncmp(full_name,dep_dir,strlen(dep_dir)));
if(imf)
imf->given_name= imf->file_name+path_len;
return;
}
incl_dirs= cp+1;
}while(col);
if(report_include){
printf("\ncannot find include file: ");
term_write(id_first+1,id_len);
printf("\n(environment variable INCLUDE not properly set?)\n");
mark_harmless;
}
}

/*:302*//*310:*/
#line 5613 "mcweave.w"

char*strmem(s)
char*s;
{
char*cp= malloc(strlen(s)+1);
if(!cp)fatal("! No memory for string ",s);

return strcpy(cp,s);
}

/*:310*//*311:*/
#line 5631 "mcweave.w"

struct external_reference*
new_ext_ref(bookname,chapter_no)
char*bookname;
{
struct external_reference*ref,*last_ref= NULL;
boolean must_alloc_book_name= 1;
boolean own_book= !strcmp(bookname,book_name);
int c;

if(own_book)bookname= "";
for(ref= first_ext_ref;ref;ref= ref->next_ext_ref){
c= strcmp(ref->book_name,bookname);
if(!c){
bookname= ref->book_name;
must_alloc_book_name= 0;
if(ref->chapter==chapter_no)return ref;
if(ref->chapter>chapter_no)break;
}
else if(c>0)break;
last_ref= ref;
}
if(must_alloc_book_name)bookname= strmem(bookname);
ref= (struct external_reference*)malloc(sizeof(struct external_reference));
if(!ref)fatal("! No memory for reference to book ",bookname);

if(!last_ref){
ref->next_ext_ref= first_ext_ref;
first_ext_ref= ref;
}
else{
ref->next_ext_ref= last_ref->next_ext_ref;
last_ref->next_ext_ref= ref;
}
ref->chapter= chapter_no;
ref->book_name= strmem(bookname);
return ref;
}

/*:311*//*313:*/
#line 5680 "mcweave.w"

void
process_imported_files()
{
struct imported_file*imf;
boolean file_name_printed= 0;

printf("\nParsing include files...");update_terminal;
for(imf= first_imported_file;imf;imf= imf->next_imported_file){
if(report_include||imf->tangled_file){
if(!file_name_printed){
printf("\nReading imported files: ");
file_name_printed= 1;
}
printf("%s ",imf->file_name);update_terminal;
}
parse_imported_file(imf);
}
}

/*:313*//*316:*/
#line 5732 "mcweave.w"

void
new_token_section()
{
if(token_sec_ptr==token_sec_info+max_token_sec_info)
overflow("token section info");
token_sec_ptr->token_ptr= tok_ptr;
token_sec_ptr->section_count= section_count;
token_sec_ptr++;
}

/*:316*//*317:*/
#line 5745 "mcweave.w"

int
section_of_token(tk)
token_pointer tk;
{
struct token_section*ts;
int sec= 0;
for(ts= token_sec_info;ts<token_sec_ptr;ts++){
if(tk<ts->token_ptr)break;
sec= ts->section_count;
}
return sec;
}

/*:317*//*320:*/
#line 5775 "mcweave.w"

void
parse_imported_file(imf)
struct imported_file*imf;
{
char save_web_file_name[max_file_name_length];
char save_alt_web_file_name[max_file_name_length];
char save_change_file_name[max_file_name_length];
int len;

current_imported_file= imf;
strcpy(save_web_file_name,web_file_name);
strcpy(save_alt_web_file_name,alt_web_file_name);
strcpy(save_change_file_name,change_file_name);
strcpy(web_file_name,imf->file_name);
strcpy(alt_web_file_name,web_file_name);
#line 49 "mcweave-Amiga.ch"
strcpy(change_file_name,"nil:");
#line 5792 "mcweave.w"

parsing_exp_file= 1;
ext_ref= NULL;
token_sec_ptr= token_sec_info;
sec_cnt_sp= 0;
reset_input();section_count= 0;
while(!input_has_ended){
next_control= get_next();
got_next_one:
if(next_control==identifier){
len= id_loc-id_first;
if(!strncmp(id_first,"typedef",len)&&len==7||
!strncmp(id_first,"extern",len)&&len==6)
translate_and_reset();
}
if(next_control==begin_comment)
parse_comment(imf->tangled_file);
else if(next_control==begin_short_comment)
loc= limit;
else if(!preprocessing&&next_control!=right_preproc||section_count){
/*193:*/
#line 3468 "mcweave.w"

/*194:*/
#line 3546 "mcweave.w"

if(scrap_ptr+safe_scrap_incr>scrap_info_end||
tok_ptr+safe_tok_incr>tok_mem_end||
text_ptr+safe_text_incr>tok_start_end){
if(scrap_ptr>max_scr_ptr)max_scr_ptr= scrap_ptr;
if(tok_ptr>max_tok_ptr)max_tok_ptr= tok_ptr;
if(text_ptr>max_text_ptr)max_text_ptr= text_ptr;
overflow("scrap/token/text");
}

/*:194*/
#line 3469 "mcweave.w"
;
switch(next_control){
case special_command:
next_control= get_next();
/*195:*/
#line 3561 "mcweave.w"

{
if(next_control==identifier){
name_pointer p= id_lookup(id_first,id_loc,normal);
if(p==id_global||p==id_shared||p==id_export){
app(res_flag+(int)(p-name_dir));
app_scrap(raw_int,maybe_math);
break;
}
if(p==id_from)
/*197:*/
#line 3635 "mcweave.w"

{
app(force);app(preproc_line);app_str("\\#");
app(res_flag+(int)(p-name_dir));
next_control= get_next();
if(next_control==identifier){
p= id_lookup(id_first,id_loc,normal);
if(p==id_program||p==id_library){
app(' ');app(res_flag+(int)(p-name_dir));
next_control= get_next();
if(next_control==string){
app(' ');append_string();
next_control= get_next();
if(next_control==identifier){
p= id_lookup(id_first,id_loc,normal);
if(p==id_import){
app(' ');app(opt);app('5');
app(res_flag+(int)(p-name_dir));
next_control= get_next();
if(next_control==identifier){
p= id_lookup(id_first,id_loc,normal);
if(p==id_transitively){
app(' ');app(res_flag+(int)(p-name_dir));
}
else goto got_next_one;
next_control= get_next();
}
if(next_control==string){
while(next_control==string){
app(break_space);append_string();
next_control= get_next();
if(next_control==','){
app(',');next_control= get_next();
}
}
app(force);
}
}
}
}
}
}
}

/*:197*/
#line 3571 "mcweave.w"

else if(p==id_import)
/*198:*/
#line 3681 "mcweave.w"

{
app(force);app(preproc_line);app_str("\\#");
app(res_flag+(int)(p-name_dir));
next_control= get_next();
if(next_control==identifier){
p= id_lookup(id_first,id_loc,normal);
if(p==id_transitively){
app(' ');app(res_flag+(int)(p-name_dir));
next_control= get_next();
if(next_control==identifier)
p= id_lookup(id_first,id_loc,normal);
else goto got_next_one;
}
if(p==id_program||p==id_library||p==id_chapter){
app(' ');app(res_flag+(int)(p-name_dir));
next_control= get_next();
if(next_control==string){
while(next_control==string){
app(break_space);append_string();
next_control= get_next();
if(next_control==','){
app(',');next_control= get_next();
}
}
app(force);
}
}
}
}

/*:198*/
#line 3573 "mcweave.w"

else if(p==id_mark){
next_control= get_next();
if(next_control==string)break;
err_print("! Name of copy buffer expected");

}
else if(p==id_copy)break;
else if(p==id_paste){
next_control= get_next();
if(next_control==string){
*id_loc= 0;
paste(id_first);
break;
}
}
else err_print("! Illegal special command in C text");

}
}

/*:195*/
#line 3473 "mcweave.w"
;
goto got_next_one;
case section_name:
app(section_flag+(int)(cur_section-name_dir));
app_scrap(section_scrap,maybe_math);
app_scrap(exp,yes_math);break;
case string:case constant:case verbatim:/*199:*/
#line 3720 "mcweave.w"

append_string();

/*:199*/
#line 3479 "mcweave.w"
;
break;
case identifier:app_cur_id(1);break;
case TeX_string:/*202:*/
#line 3794 "mcweave.w"

app_str("\\hbox{");

while(id_first<id_loc)
if((eight_bits)(*id_first)>0177){
app_tok(quoted_char);
app_tok((eight_bits)(*id_first++));
}
else{
if(*id_first=='@')id_first++;
app_tok(*id_first++);
}
app('}');

/*:202*/
#line 3482 "mcweave.w"
;break;
case'/':case'.':
app(next_control);app_scrap(binop,yes_math);break;
case'<':app_str("\\langle");app_scrap(prelangle,yes_math);break;

case'>':app_str("\\rangle");app_scrap(prerangle,yes_math);break;

case'=':app_str("\\K");app_scrap(binop,yes_math);break;

case'|':app_str("\\OR");app_scrap(binop,yes_math);break;

case'^':app_str("\\XOR");app_scrap(binop,yes_math);break;

case'%':app_str("\\MOD");app_scrap(binop,yes_math);break;

case'!':app_str("\\R");app_scrap(unop,yes_math);break;

case'~':app_str("\\CM");app_scrap(unop,yes_math);break;

case'+':case'-':app(next_control);app_scrap(unorbinop,yes_math);break;
case'*':app(next_control);app_scrap(raw_unorbin,yes_math);break;
case'&':app_str("\\AND");app_scrap(raw_unorbin,yes_math);break;

case'?':app_str("\\?");app_scrap(question,yes_math);break;

case'#':app_str("\\#");app_scrap(unorbinop,yes_math);break;

case ignore:case xref_roman:case xref_wildcard:
case xref_typewriter:case noop:break;
case'(':case'[':app(next_control);app_scrap(lpar,maybe_math);break;
case')':case']':app(next_control);app_scrap(raw_rpar,maybe_math);break;
case'{':app_str("\\{");app_scrap(lbrace,yes_math);break;

case'}':app_str("\\}");app_scrap(rbrace,yes_math);break;

case',':app(',');app_scrap(comma,yes_math);break;
case';':app(';');app_scrap(semi,maybe_math);break;
case':':app(':');app_scrap(colon,maybe_math);break;
/*196:*/
#line 3598 "mcweave.w"

case not_eq:app_str("\\I");app_scrap(binop,yes_math);break;

case lt_eq:app_str("\\Z");app_scrap(binop,yes_math);break;

case gt_eq:app_str("\\G");app_scrap(binop,yes_math);break;

case eq_eq:app_str("\\E");app_scrap(binop,yes_math);break;

case and_and:app_str("\\W");app_scrap(binop,yes_math);break;

case or_or:app_str("\\V");app_scrap(binop,yes_math);break;

case plus_plus:app_str("\\PP");app_scrap(unop,yes_math);break;

case minus_minus:app_str("\\MM");app_scrap(unop,yes_math);break;

case minus_gt:app_str("\\MG");app_scrap(binop,yes_math);break;

case gt_gt:app_str("\\GG");app_scrap(binop,yes_math);break;

case lt_lt:app_str("\\LL");app_scrap(binop,yes_math);break;

case dot_dot_dot:app_str("\\,\\ldots\\,");app_scrap(exp,yes_math);break;


case colon_colon:app_str("\\DC");app_scrap(colcol,maybe_math);break;

case period_ast:app_str("\\PA");app_scrap(binop,yes_math);break;

case minus_gt_ast:app_str("\\MGA");app_scrap(binop,yes_math);break;


/*:196*/
#line 3520 "mcweave.w"

case thin_space:app_str("\\,");app_scrap(insert,maybe_math);break;

case math_break:app(opt);app_str("0");
app_scrap(insert,maybe_math);break;
case line_break:app(force);app_scrap(insert,no_math);break;
case left_preproc:app(force);app(preproc_line);
app_str("\\#");app_scrap(lproc,no_math);break;

case right_preproc:app(force);app_scrap(rproc,no_math);break;
case big_line_break:app(big_force);app_scrap(insert,no_math);break;
case no_line_break:app(big_cancel);app(noop);app(break_space);
app(noop);app(big_cancel);
app_scrap(insert,no_math);break;
case pseudo_semi:app_scrap(semi,maybe_math);break;
case macro_arg_open:app_scrap(begin_arg,maybe_math);break;
case macro_arg_close:app_scrap(end_arg,maybe_math);break;
case join:app_str("\\J");app_scrap(insert,no_math);break;

case output_defs_code:app(force);app_str("\\ATH");app(force);
app_scrap(insert,no_math);break;

default:app(inserted);app(next_control);
app_scrap(insert,maybe_math);break;
}

/*:193*/
#line 5812 "mcweave.w"
;
}
}
translate_and_reset();
ext_ref= NULL;
parsing_exp_file= 0;

fclose(file[0]);
fclose(change_file);

strcpy(web_file_name,save_web_file_name);
strcpy(alt_web_file_name,save_alt_web_file_name);
strcpy(change_file_name,save_change_file_name);
}

/*:320*//*322:*/
#line 5833 "mcweave.w"

void
translate_and_reset()
{
int sec= section_count;
text_pointer p;
if(scrap_ptr>scrap_info)
p= translate();
if(text_ptr>max_text_ptr)max_text_ptr= text_ptr;
if(tok_ptr>max_tok_ptr)max_tok_ptr= tok_ptr;
if(scrap_ptr>max_scr_ptr)max_scr_ptr= scrap_ptr;
tok_ptr= tok_mem+1;text_ptr= tok_start+1;scrap_ptr= scrap_info;

token_sec_ptr= token_sec_info;
section_count= sec;
new_token_section();
}

/*:322*//*324:*/
#line 5868 "mcweave.w"

void
parse_comment(tangled_file)
int tangled_file;
{
char*cp;
int len;
int sec;

if(tangled_file){
if(!strncmp(loc,"Section:",8)){
sscanf(loc+8,"%d",&sec);
section_count= (sixteen_bits)sec;
new_token_section();
}
else if(!strncmp(loc," Book:\"",7)){
cp= strchr(loc+7,'\"');
len= cp-loc-7;
strncpy(foreign_book_name,loc+7,len);
foreign_book_name[len]= 0;
sscanf(loc+7+len+11,"%d",&foreign_chapter);
if(tangled_file==2)ext_ref= own_shared;
else if(tangled_file==3)ext_ref= own_export;
else ext_ref= new_ext_ref(foreign_book_name,foreign_chapter);;
}
else if(isdigit(*loc)){
sscanf(loc,"%d",&sec);
do loc++;while(isdigit(*loc));
if(*loc==':'){
push_sec_cnt();
section_count= sec;
new_token_section();
}
}
else if(*loc==':'&&isdigit(loc[1])){
pop_sec_cnt();
new_token_section();
}
}
/*325:*/
#line 5912 "mcweave.w"

for(;;){
if(loc>limit)
if(get_line()==0){
err_print("! Input ended in mid-comment");

loc= buffer+1;
break;
}
next_control= *loc++;
if(next_control=='*'&&*loc=='/'){
loc++;
break;
}
}


/*:325*/
#line 5907 "mcweave.w"
;
}

/*:324*//*328:*/
#line 5942 "mcweave.w"

void
push_sec_cnt()
{
if(sec_cnt_sp>=max_section_nest)overflow("section nest in imported file");
sec_cnt_stack[sec_cnt_sp++]= section_count;
}

/*:328*//*329:*/
#line 5952 "mcweave.w"

int
pop_sec_cnt()
{
if(sec_cnt_sp)return section_count= sec_cnt_stack[--sec_cnt_sp];
return 0;
}

/*:329*//*332:*/
#line 5974 "mcweave.w"

void
remember_export_file()
{
char name[max_file_name_length];
char*dot;
FILE*fd;
int len;

strcpy(name,file_name[0]);
dot= file_name_ext(name);
if(dot)*dot= 0;
strcat(name,".shr");
if(fd= fopen(name,"r")){
fclose(fd);
remember_import_file(name,0,2);
}
if(book_type){
strcpy(name,dep_dir);
len= strlen(name);
if(len)name[len++]= file_name_separator;
strcpy(name+len,book_name);
len= strlen(name);
name[len++]= file_name_separator;
strcpy(name+len,file_name[0]);
dot= file_name_ext(name+len);
if(dot)*dot= 0;
strcat(name+len,".exp");
if(fd= fopen(name,"r")){
fclose(fd);
remember_import_file(name,1,3);
}
}
}

/*:332*//*348:*/
#line 6235 "mcweave.w"

char*
get_name(cp,buffer)
char*cp,*buffer;
{
int i;

while(isspace(*cp))cp++;
if(*cp=='\"'){
cp++;
for(i= 0;i<max_file_name_length;i++)
if(*cp=='\"'){
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

/*:348*//*354:*/
#line 6333 "mcweave.w"

void
make_xid_file(file_extension,ref)
char*file_extension;
struct external_reference*ref;
{
name_pointer p;
int len,i;
xref_pointer xp;
boolean name_written;
FILE*xid_file= NULL;
char*cp;

strcpy(a_file_name,tex_file_name);
cp= file_name_ext(a_file_name);
if(cp)*cp= 0;
strcat(a_file_name,file_extension);
for(p= name_dir+1;p<name_ptr;p++){
if(p->ilk==normal){
len= p[1].byte_start-p->byte_start;
name_written= 0;
for(xp= (xref_pointer)p->xref;xp!=&xmem[0];xp= xp->xlink){
if(xp->ext_ref==ref){
if(!xid_file){
xid_file= fopen(a_file_name,"w");
if(!xid_file)fatal("! Cannot create xid/sid file: ",a_file_name);
}

if(!name_written){
for(i= 0;i<len;i++)putc(p->byte_start[i],xid_file);
name_written= 1;
}
fprintf(xid_file,"\t%d",xp->num%def_flag);
}
}
if(name_written)putc('\n',xid_file);
}
}
if(xid_file)fclose(xid_file);
else remove(a_file_name);
}

/*:354*//*355:*/
#line 6378 "mcweave.w"

void
read_xid_files(file_extension)
char*file_extension;
{
int ch,sec;
char*cp;
FILE*xid_file;
name_pointer p;

init_common_ptrs();
xref_ptr= xmem;
name_dir->xref= (char*)xmem;

for(ch= chapter_no-1;ch>=0;ch--){
strcpy(a_file_name,ch_TeX_name[ch]);
cp= file_name_ext(a_file_name);
if(cp)*cp= 0;
strcat(a_file_name,file_extension);
xid_file= fopen(a_file_name,"r");
if(xid_file){
ext_ref= new_ext_ref("",ch+1);
while(fscanf(xid_file,"%s",buffer)==1){
p= id_lookup(buffer,NULL,normal);
fgets(buffer,sizeof(buffer),xid_file);
cp= buffer;
do{
while(isspace(*cp))cp++;
sscanf(cp,"%d",&sec);
section_count= (sixteen_bits)sec;
xref_switch= def_flag;
underline_xref(p);
cp= strchr(cp,'\t');
}while(cp);
}
fclose(xid_file);
}
}
}

/*:355*//*357:*/
#line 6442 "mcweave.w"

void
make_iid_file()
{
int len,i;
name_pointer p;
xref_pointer xp;
boolean name_written;
FILE*iid_file= NULL;
char*cp;
struct external_reference*ref;

strcpy(a_file_name,tex_file_name);
cp= file_name_ext(a_file_name);
if(cp)*cp= 0;
strcat(a_file_name,".iid");
for(p= name_dir+1;p<name_ptr;p++){
if(p->ilk==normal){
len= p[1].byte_start-p->byte_start;
name_written= 0;
for(xp= (xref_pointer)p->xref;xp!=&xmem[0];xp= xp->xlink){
if(xp->ext_ref!=own_export&&xp->ext_ref!=own_shared&&xp->ext_ref&&
*xp->ext_ref->book_name){
if(!iid_file)/*358:*/
#line 6486 "mcweave.w"

{
iid_file= fopen(a_file_name,"w");
if(!iid_file)fatal("! Cannot create iid file: ",a_file_name);

for(ref= first_ext_ref;ref;ref= ref->next_ext_ref)
fprintf(iid_file,"*%s\t%d\n",ref->book_name,ref->chapter);
}

/*:358*/
#line 6465 "mcweave.w"
;
if(!name_written){
putc(' ',iid_file);
for(i= 0;i<len;i++)putc(p->byte_start[i],iid_file);
name_written= 1;
}
for(i= 0,ref= first_ext_ref;ref;i++,ref= ref->next_ext_ref)
if(ref==xp->ext_ref)break;
fprintf(iid_file,"\t%d(%d)",xp->num%def_flag,i);
}
}
if(name_written)putc('\n',iid_file);
}
}
if(iid_file)fclose(iid_file);
else remove(a_file_name);
}

/*:357*//*359:*/
#line 6501 "mcweave.w"

void
read_iid_files()
{
int ch,c,sec;
char*cp;
FILE*iid_file;
name_pointer p;
struct external_reference*ch_ext_refs[max_ref_per_chapter];
int n_ch_ext_refs;

init_common_ptrs();
xref_ptr= xmem;
name_dir->xref= (char*)xmem;
for(ch= chapter_no-1;ch>=0;ch--){
strcpy(a_file_name,ch_TeX_name[ch]);
cp= file_name_ext(a_file_name);
if(cp)*cp= 0;
strcat(a_file_name,".iid");
iid_file= fopen(a_file_name,"r");
if(iid_file){
n_ch_ext_refs= 0;
while((c= getc(iid_file))!=EOF){
fgets(buffer,sizeof(buffer),iid_file);
if((cp= strchr(buffer,'\t'))!=NULL){
*cp++= 0;
if(c=='*'){
sscanf(cp,"%d",&c);
if(strcmp(buffer,book_name))
ext_ref= new_ext_ref(buffer,c);
else ext_ref= NULL;
if(n_ch_ext_refs>=max_ref_per_chapter)
overflow("maximum external references per chapter");
ch_ext_refs[n_ch_ext_refs++]= ext_ref;
}
else{
sscanf(cp,"%d(%d)",&sec,&c);
section_count= (sixteen_bits)sec;
ext_ref= ch_ext_refs[c];
if(ext_ref){
p= id_lookup(buffer,NULL,normal);
xref_switch= def_flag;
underline_xref(p);
}
}
}
}
fclose(iid_file);
}
}
}

/*:359*//*361:*/
#line 6560 "mcweave.w"

void
make_book_xref()
{
char*cp;

if(no_xref)return;
dag_seen= ddag_seen= 0;
strcpy(idx_file_name,book_name);
cp= file_name_ext(idx_file_name);
if(cp)*cp= 0;
strcat(idx_file_name,".idx");
idx_file= fopen(idx_file_name,"w");
if(!idx_file)
fatal("! Cannot create index file for book: ",idx_file_name);

active_file= idx_file;
read_xid_files(".sid");
if(xref_ptr!=xmem){
out_str("\\shrnames\n");
sort_and_output_index();
output_referenced_books();
out_str("\\vfill\\eject\n");
}
read_xid_files(".xid");
if(xref_ptr!=xmem){
out_str("\\expnames\n");
sort_and_output_index();
output_referenced_books();
out_str("\\vfill\\eject\n");
}
read_iid_files();
if(xref_ptr!=xmem){
out_str("\\impnames\n");
sort_and_output_index();
output_referenced_books();
out_str("\\vfill\\eject\n");
}
finish_line();
fclose(idx_file);
}

/*:361*//*364:*/
#line 6614 "mcweave.w"

void
sort_and_output_index()
{
keep_only_ext_def= 1;
/*258:*/
#line 4852 "mcweave.w"
{
int c;
for(c= 0;c<=255;c++)bucket[c]= NULL;
for(h= hash;h<=hash_end;h++){
next_name= *h;
while(next_name){
cur_name= next_name;next_name= cur_name->link;
if(cur_name->xref!=(char*)xmem){
c= (eight_bits)((cur_name->byte_start)[0]);
if(xisupper(c))c= tolower(c);
blink[cur_name-name_dir]= bucket[c];bucket[c]= cur_name;
}
}
}
}

/*:258*/
#line 6619 "mcweave.w"
;
/*267:*/
#line 4953 "mcweave.w"

sort_ptr= scrap_info;unbucket(1);
while(sort_ptr>scrap_info){
cur_depth= sort_ptr->depth;
if(blink[sort_ptr->head-name_dir]==0||cur_depth==infinity)
/*269:*/
#line 4978 "mcweave.w"
{
cur_name= sort_ptr->head;
do{
if(keep_only_ext_def||!only_ext_def(cur_name)){
out_str("\\I");

/*272:*/
#line 5017 "mcweave.w"

switch(cur_name->ilk){
case normal:if(is_tiny(cur_name))out_str("\\|");
else{char*j;
for(j= cur_name->byte_start;j<(cur_name+1)->byte_start;j++)
if(xislower(*j))goto lowcase;
out_str("\\.");break;
lowcase:out_str("\\\\");
}
break;



case roman:break;
case wildcard:out_str("\\9");break;

case typewriter:out_str("\\.");break;

case custom:case quoted:{char*j;out_str("$\\");
for(j= cur_name->byte_start;j<(cur_name+1)->byte_start;j++)
out(isxalpha(*j)?'x':*j);
out('$');
goto name_done;
}
default:out_str("\\&");

}
out_name(cur_name);
name_done:

/*:272*/
#line 4984 "mcweave.w"
;
/*273:*/
#line 5050 "mcweave.w"

/*275:*/
#line 5070 "mcweave.w"

this_xref= (xref_pointer)cur_name->xref;cur_xref= xmem;
do{
next_xref= this_xref->xlink;this_xref->xlink= cur_xref;
cur_xref= this_xref;this_xref= next_xref;
}while(this_xref!=xmem);

/*:275*/
#line 5051 "mcweave.w"
;
do{
out_str(", ");cur_val= cur_xref->num;
if(cur_val<def_flag)out_section(cur_val);
else{out_str("\\[");out_section(cur_val-def_flag);out(']');}

if(cur_xref->ext_ref)
/*278:*/
#line 5088 "mcweave.w"

{
struct external_reference*ref;
int i;
char ref_nr[20];

if(cur_xref->ext_ref==own_shared){
if(cur_val>=def_flag){
dag_seen= 1;
sprintf(ref_nr,"${}^{\\dag}$");
out_str(ref_nr);
}
}
else if(cur_xref->ext_ref==own_export){
if(cur_val>=def_flag){
ddag_seen= 1;
sprintf(ref_nr,"${}^{\\ddag}$");
out_str(ref_nr);
}
}
else for(i= 1,ref= first_ext_ref;ref;i++,ref= ref->next_ext_ref)
if(ref==cur_xref->ext_ref){
sprintf(ref_nr,"${}^{%d}$",i);
out_str(ref_nr);
break;
}
}

/*:278*/
#line 5058 "mcweave.w"
;
cur_xref= cur_xref->xlink;
}while(cur_xref!=xmem);
out('.');finish_line();

/*:273*/
#line 4985 "mcweave.w"
;
}
cur_name= blink[cur_name-name_dir];
}while(cur_name);
--sort_ptr;
}

/*:269*/
#line 4958 "mcweave.w"

else/*268:*/
#line 4962 "mcweave.w"
{
eight_bits c;
next_name= sort_ptr->head;
do{
cur_name= next_name;next_name= blink[cur_name-name_dir];
cur_byte= cur_name->byte_start+cur_depth;
if(cur_byte==(cur_name+1)->byte_start)c= 0;
else{
c= (eight_bits)*cur_byte;
if(xisupper(c))c= tolower(c);
}
blink[cur_name-name_dir]= bucket[c];bucket[c]= cur_name;
}while(next_name);
--sort_ptr;unbucket(cur_depth+1);
}

/*:268*/
#line 4959 "mcweave.w"
;
}

/*:267*/
#line 6620 "mcweave.w"
;
keep_only_ext_def= 0;
}

/*:364*//*370:*/
#line 6660 "mcweave.w"

struct adoc_class*
lookup_adoc_class(name_start,name_end)
char*name_start,*name_end;
{
struct adoc_class*ac,*last_ac= NULL;
int len= name_end-name_start;
if(name_start<name_end)
for(ac= first_adoc_class;ac;ac= ac->next){
if(len==strlen(ac->class_name)&&!strncmp(name_start,ac->class_name,len))
return ac;
last_ac= ac;
}
ac= (struct adoc_class*)malloc(sizeof(*ac)+len-1);
if(!ac)fatal("! No memory"," for autodoc class");

strncpy(ac->class_name,name_start,len);
ac->class_name[len]= 0;
if(!last_ac){
ac->next= first_adoc_class;
first_adoc_class= ac;
}
else{
ac->next= last_ac->next;
last_ac->next= ac;
}
ac->first_adoc= NULL;
return ac;
}

/*:370*//*371:*/
#line 6692 "mcweave.w"

struct adoc*
insert_adoc(ac,name_start,name_end)
struct adoc_class*ac;
char*name_start,*name_end;
{
int len= name_end-name_start;
struct adoc*a= (struct adoc*)malloc(sizeof(*a)+len-1),*a2,*a3;
if(!a)fatal("! No memory"," for autodoc entry");

strncpy(a->name,name_start,len);
a->name[len]= 0;
a->description= NULL;
a3= NULL;
for(a2= ac->first_adoc;a2;a2= a2->next){
if(strcmp(a2->name,a->name)>0)break;
a3= a2;
}
if(a3){
a->next= a3->next;
a3->next= a;
}
else{
a->next= ac->first_adoc;
ac->first_adoc= a;
}
return a;
}

/*:371*//*373:*/
#line 6727 "mcweave.w"

void
process_autodoc()
{
int c;
char*cp;
struct adoc_class*ac;
char*name_start,*name_end,*desc;
struct adoc*a;

do c= get_next();while(c=='\n');
if(c!='{'){
err_print("! Autodoc class name enclosed in braces expected");

return;
}
for(cp= loc;;){
if(loc>=limit){
err_print("! '}' for autodoc class missing");

return;
}
c= *loc++;
if(c=='}')break;
}
ac= lookup_adoc_class(cp,loc-1);
/*374:*/
#line 6762 "mcweave.w"

{
do c= get_next();while(c=='\n');
if(c!='{'){
err_print("! '{' for autodoc name expected");

return;
}
for(name_start= loc;;){
if(loc>=limit){
err_print("! '}' for autodoc name missing");

return;
}
c= *loc++;
if(c=='}')break;
}
name_end= loc-1;
}

/*:374*/
#line 6753 "mcweave.w"
;
a= insert_adoc(ac,name_start,name_end);
/*376:*/
#line 6799 "mcweave.w"

{
int braces;

do c= get_next();while(c=='\n');
if(c!='{'){
err_print("! '{' for autodoc description expected");

return;
}
is_adoc= 1;
braces= 1;
desc_ptr= desc_mem;
for(;;){
if(loc>=limit){
if(get_line()==0){
is_adoc= 0;
return;
}
finish_line();
}
next_control= *loc++;
if(next_control=='@'){
next_control= *loc++;
if(next_control=='e'||next_control=='E'){
process_example();
next_control= ignore;
}
else if(next_control=='_'){
/*377:*/
#line 6857 "mcweave.w"

{
c= get_next();
if(c==identifier){
name_pointer p;
p= id_lookup(id_first,id_loc,normal);
if(p==id_paste){
c= get_next();
if(c==string){
*id_loc= 0;
paste(id_first);
c= ignore;
}
else err_print("! Name of copy buffer expected");

}
else if(p==id_mark)c= get_next();
else if(p!=id_copy){
err_print("! Not allowed in autodoc");

return;
}
}
}

/*:377*/
#line 6828 "mcweave.w"
;
next_control= ignore;
}
else if(next_control!='@'){
err_print("! Only @@, @_ or @e allowed in autodoc section");

return;
}
}
else if(next_control=='{')braces++;
else if(next_control=='}'&&--braces==0)break;
else if(next_control=='|'){
*limit= '|';
init_stack;output_C();
next_control= ignore;
}
if(next_control)out(next_control);
}
finish_line();
desc= malloc(desc_ptr-desc_mem+1);
if(!desc)fatal("! No memory"," for autodoc description");

strncpy(desc,desc_mem,desc_ptr-desc_mem);
desc[desc_ptr-desc_mem]= 0;
is_adoc= 0;
}

/*:376*/
#line 6755 "mcweave.w"
;
a->description= desc;
}

/*:373*//*379:*/
#line 6892 "mcweave.w"

void
output_adocs()
{
struct adoc_class*ac;
struct adoc*a;
FILE*adoc_file,*adc_book_file;
if(!first_adoc_class)return;
strcpy(a_file_name,"autodoc.tex");
adc_book_file= fopen(a_file_name,"w");
if(!adc_book_file)fatal("! Cannot create autodoc file:",a_file_name);

fprintf(adc_book_file,"\\def\\adocjob{%s}\n",book_name);
fprintf(adc_book_file,"\\input %smcwebmac\n",mcwebmac_prefix);
fprintf(adc_book_file,"\\adocfile\n");
if(!*first_adoc_class->class_name)
for(a= first_adoc_class->first_adoc;a;a= a->next)
if(a->description)fprintf(adc_book_file,"%s",a->description);
if(show_progress)printf("\nCreating autodoc files: %s",a_file_name);
for(ac= first_adoc_class;ac;ac= ac->next)
if(*ac->class_name){
strcpy(a_file_name,ac->class_name);
if(!file_name_ext(a_file_name))strcat(a_file_name,".adc");
adoc_file= fopen(a_file_name,"w");
if(!adoc_file)fatal("! Cannot create autodoc file:",a_file_name);
fprintf(adc_book_file,"\\input %s\n",a_file_name);
fprintf(adoc_file,"\\def\\curjob{%s}",ac->class_name);
fprintf(adoc_file,"\\def\\chapname{%s}",ac->class_name);
/*381:*/
#line 6957 "mcweave.w"

{
for(a= ac->first_adoc;a;a= a->next)
if(a->description&&*a->name=='*'&&a->name[1]==0)
fprintf(adoc_file,"%s",a->description);
}

/*:381*/
#line 6920 "mcweave.w"
;
fprintf(adoc_file,"\\adocclass\n");
if(show_progress){
printf(" %s",a_file_name);update_terminal;
}
/*380:*/
#line 6935 "mcweave.w"

{
for(a= ac->first_adoc;a;a= a->next)
if(a->description){
if(*a->name=='*'&&a->name[1]==0)continue;
if(!*a->name)fprintf(adoc_file,"%s",a->description);
else{
fprintf(adoc_file,"\\adoc{%s}\n",a->name);
for(;;){
fprintf(adoc_file,"%s",a->description);
if(!a->next||strcmp(a->name,a->next->name))
break;
a= a->next;
}
fprintf(adoc_file,"\\endadoc\n");
}
}
}

/*:380*/
#line 6925 "mcweave.w"
;
fclose(adoc_file);
}
fprintf(adc_book_file,"\\con\n");
fclose(adc_book_file);
}

/*:379*//*388:*/
#line 7039 "mcweave.w"

void
mark(name)
char*name;
{
int len;
if(copy_to_buffer){
err_print("! Still in copy mode, nesting not allowed");

return;
}
copy_ptr= desc_mem;
copy_end= desc_mem_end;
copy_to_buffer= 1;
current_copy_buffer= (struct copy_buffer*)malloc(sizeof(struct copy_buffer)+strlen(name)-1);
if(!current_copy_buffer)fatal("! No memory"," for copy buffer");

strcpy(current_copy_buffer->name,name);
len= limit-loc;
memcpy(copy_ptr,loc,len);
copy_ptr+= len;
*copy_ptr++= 0;
}

/*:388*//*389:*/
#line 7069 "mcweave.w"

void
copy()
{
struct copy_buffer*cb;
int size;
if(copy_to_buffer&&current_copy_buffer){
copy_to_buffer= 0;
cb= current_copy_buffer;
copy_ptr-= limit-loc+1;
copy_ptr-= 6;
*copy_ptr++= 0;
size= copy_ptr-desc_mem;
cb->start= malloc(size);
if(!cb->start)fatal("! No memory"," for copy buffer");

memcpy(cb->start,desc_mem,size);
cb->end= cb->start+size;
if(!first_copy_buffer){
cb->next= NULL;
first_copy_buffer= cb;
}
else{
cb->next= first_copy_buffer;
first_copy_buffer= cb;
}
}
}

/*:389*//*390:*/
#line 7101 "mcweave.w"

struct copy_buffer*
find_copy_buffer(name)
char*name;
{
struct copy_buffer*cb;
for(cb= first_copy_buffer;cb;cb= cb->next)
if(!strcmp(cb->name,name))return cb;
return NULL;
}

/*:390*//*391:*/
#line 7120 "mcweave.w"

void
paste(name)
char*name;
{
struct copy_buffer*cb= find_copy_buffer(name);
int len;
if(!cb){
err_print("! Copy buffer not found");

return;
}
copy_ptr= cb->start;
copy_end= cb->end;
copy_from_buffer= 1;
len= limit-loc;
rest_after_paste= malloc(len+1);
strncpy(rest_after_paste,loc,len);
rest_after_paste[len]= 0;
loc= limit;
}

/*:391*/
