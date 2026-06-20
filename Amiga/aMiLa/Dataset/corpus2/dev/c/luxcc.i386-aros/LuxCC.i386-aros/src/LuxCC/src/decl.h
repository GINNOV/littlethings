#ifndef DECL_H_
#define DECL_H_

#include "parser.h"

typedef struct StructMember StructMember;
typedef struct StructDescriptor StructDescriptor;
typedef struct Symbol Symbol;
typedef struct TypeTag TypeTag;
typedef struct ExternId ExternId;

typedef enum { /* ExternId.status */
    DEFINED,            /* int x = 0; or void foo(void){...} */
    REFERENCED,         /* extern int x; or void foo(void); */
    TENTATIVELY_DEFINED /* int x; */
} ExtIdStatus;

struct ExternId {
    TypeExp *decl_specs;
    TypeExp *declarator;
    ExtIdStatus status;
    char *enclosing_function; /* used with static local variables */
    ExternId *next;
};

struct StructMember {
    char *id;
    unsigned size, offset;
    Declaration type;
    StructMember *next;
};

struct StructDescriptor {
    char *tag;
    unsigned size, alignment; /* overall size and member's most restrictive alignment */
    StructMember *members;
    StructDescriptor *next;
};

struct Symbol {
    TypeExp *decl_specs;
    TypeExp *declarator;
    short is_param, nesting_level;
    int scope;
    Symbol *next;
};

struct TypeTag {
    TypeExp *type;
    TypeTag *next;
};

void analyze_translation_unit(void);
void analyze_init_declarator(TypeExp *decl_specs, TypeExp *declarator, int is_func_def);
void analyze_declarator(TypeExp *decl_specs, TypeExp *declarator, int inst_sym);
void analyze_decl_specs(TypeExp *d);
void analyze_enumerator(TypeExp *e);
void analyze_parameter_declaration(Declaration *d);
void analyze_function_definition(Declaration *f);
void analyze_struct_declarator(TypeExp *sql, TypeExp *declarator);
void analyze_type_name(Declaration *tn);

void push_scope(void);
void pop_scope(void);
void restore_scope(void);
Symbol *lookup_ordinary_id(char *id, int all);
void install_tag(TypeExp *ty);
TypeTag *lookup_tag(char *id, int all);
int is_typedef_name(char *id);
int get_curr_scope_id(void);

ExternId *lookup_external_id(char *id);
ExternId *new_extern_id_node(void);

void decl_init(void);
void reset_enum_val(void);
char *stringify_type_exp(Declaration *d, int show_decayed);
int are_compatible(TypeExp *ds1, TypeExp *dct1, TypeExp *ds2, TypeExp *dct2, int qualified, int compose);
int is_complete(char *tag);
int is_struct_union_enum(Token t);
int is_external_id(char *id);
void set_attributes(ExecNode *e, Symbol *sym);

TypeExp *get_sto_class_spec(TypeExp *d);
TypeExp *get_type_spec(TypeExp *d);
TypeExp *get_type_qual(TypeExp *d);
TypeExp *dup_declarator(TypeExp *d);
TypeExp *dup_decl_specs(TypeExp *ds);

void push_struct_descriptor(TypeExp *ty);
void pop_struct_descriptor(void);
StructDescriptor *lookup_struct_descriptor(char *tag);
StructMember *get_member_descriptor(TypeExp *ty, char *id);

ExternId *get_external_declarations(void);

#endif
