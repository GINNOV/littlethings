#ifndef ELF_UTIL_
#define ELF_UTIL_

#include <stdio.h>

typedef struct StrTab StrTab;
StrTab *strtab_new(void);
void strtab_destroy(StrTab *tab);
int strtab_append(StrTab *tab, char *str);
int strtab_write(StrTab *tab, FILE *fp);
unsigned strtab_get_size(StrTab *tab);
int strtab_get_offset(StrTab *tab, char *str);
char *strtab_get_string(StrTab *tab, int offs);
void strtab_copy(StrTab *tab, char *dest);

unsigned long elf_hash(const unsigned char *name);
unsigned elf_get_nbucket(unsigned nsym);

#endif
