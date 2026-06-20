/* Prototype definitions for A68k - last modified April 16, 1991 */

#ifndef __NOPROTO
#ifndef __PROTO
#define __PROTO(a) a
#endif
#else
#ifndef __PROTO
#define __PROTO(a) ()
#endif
#endif


/* Prototypes for functions defined in A68kmain.c */

void main __PROTO((int argc,
                   char **argv));
int getfilename __PROTO((char *name,
                         char *arg,
                         char *desc,
                         int needit));
int checkswitch __PROTO((char *sw,
                         char *name));
void defaultfile __PROTO((char *name,
                          char *ext));
int checkdupfile __PROTO((char *name1,
                          char *desc1,
                          char *name2,
                          char *desc2));
void startpass __PROTO((char pchar,
                        long maxheap2));
void quit_cleanup __PROTO((char *s));


/* Prototypes for functions defined in Adirect.c */

int ObjDir __PROTO((int dummy));
void DoSection __PROTO((char *name,
                        int nameloc,
                        char *type,
                        int typeloc,
                        char *flags,
                        int flagloc));


/* Prototypes for functions defined in Codegen.c */

void GetObjectCode __PROTO((int dummy));
void PackFwdBranch __PROTO((int dummy));
int GetInstModeSize __PROTO((register int Mode));


/* Prototypes for functions defined in Opcodes.c */

int Instructions __PROTO((int loc));


/* Prototypes for functions defined in Operands.c */

int GetArgs __PROTO((char *name));
void EffAdr __PROTO((register struct OpConfig *EA,
                    int Bad));
void OperExt __PROTO((register struct OpConfig *EA));
int bfEncode __PROTO((char *bfDef));
void GetOperand __PROTO((char *oper,
                        register struct OpConfig *op,
                        int pcconv));
int GetMultReg __PROTO((char *oper,
                        int loc));
int GetAReg __PROTO((char *op,
                     int len,
                     int loc));
int IsRegister __PROTO((char *op,
                        int len));


/* Prototypes for functions defined in Symtab.c */

int OpenIncl __PROTO((char *name,
                      char *dirlist));
int LineParts __PROTO((int dummy));
void GetMacLine __PROTO((int dummy));
int GetLine __PROTO((int dummy));
void SubArgs __PROTO((int dummy));
void GetParts __PROTO((int dummy));
void ShowFile __PROTO((int newline));
void ShowLine __PROTO((register int i));
char *GetField __PROTO((register char *s,
                                 register char *d));
long GetValue __PROTO((char *operand,
                       int loc));
void CondCalc __PROTO((int newprec));
int IsOperator __PROTO((register char *o));
long CalcValue __PROTO((char *operand,
                        int loc));
void AddSymTab __PROTO((char *label,
                        long value,
                        long hunk,
                        int line,
                        int flags));
char *AddName __PROTO((char *name,
                                int macflag));
int ReadSymTab __PROTO((char *label));
struct SymTab **HashIt __PROTO((register char *label));
struct SymTab *NextSym __PROTO((register struct SymTab *sym));
void AddRef __PROTO((int linenum));
int CountNest __PROTO((register char *s));
void Heap2Space __PROTO((int n));
void ParseSpace __PROTO((int n));


/* Prototypes for functions defined in A68kmisc.c */

long AddrBndW __PROTO((register long v));
long AddrBndL __PROTO((register long v));
void WriteListLine __PROTO((struct fs *f));
void WriteSymTab __PROTO((struct fs *f));
void CheckPage __PROTO((struct fs *f,
                        int xhdr));
void StartSrec __PROTO((struct fs *f,
                        char *idntname));
void WriteSrecLine __PROTO((struct fs *f));
void AppendSdata __PROTO((register long Data,
			  int n/*, ...*/));
void FixOrg __PROTO((int dummy));
void DumpSdata __PROTO((register struct fs *f));
void PutRel __PROTO((long addr,
                     long hunk,
                     int size));
void DumpRel __PROTO((struct fs *f));
void EndSdata __PROTO((struct fs *f,
                       long addr));
void DumpName __PROTO((struct fs *f,
                       char *name,
                       long flags));
void LongPut __PROTO((struct fs *f,
                      long data,
                      int length));
int xopen __PROTO((char *name,
                   struct fs *f,
                   char *desc));
void xputs __PROTO((struct fs *f,
                    register char *s));
void xputl __PROTO((register struct fs *f,
                    register long data));
void xputc __PROTO((char byte,
                    register struct fs *f));
void xclose __PROTO((struct fs *f));
void xwrite __PROTO((struct fs *f));
void Error __PROTO((int pos,
                    int errornum));
void DisplayLine __PROTO((int dummy));


/* Prototypes for functions defined in wb_parse.c */

void _wb_parse __PROTO((void));
