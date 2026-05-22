#include <exec/types.h>

extern struct Language *curLang;
extern struct srcInfo {
    
    UBYTE *cur;
    UBYTE *space;
    
    UBYTE *base;
    UBYTE *end;
    
} src;


int is_lowlevel(UBYTE *);

void free_accent_stack(void);
void clear_lowlevel_refs(void);

int push_accent(int push_src);
int change_accent(STRPTR name);
int pop_accent(void);

int current_accent(UBYTE *src);
