
/* dummy def for compilers that require struct def */
struct modDescriptor { int dummy; };

extern struct modDescriptor *_OBJCBIND_objcrt();
extern struct modDescriptor *_OBJCBIND_ordcltn();
extern struct modDescriptor *_OBJCBIND_postlink();
extern struct modDescriptor *_OBJCBIND_unknownt();
extern struct modDescriptor *_OBJCBIND_set();
extern struct modDescriptor *_OBJCBIND_cltn();
extern struct modDescriptor *_OBJCBIND_outofbnd();
extern struct modDescriptor *_OBJCBIND_badvers();
extern struct modDescriptor *_OBJCBIND_Exceptn();
extern struct modDescriptor *_OBJCBIND_Message();
extern struct modDescriptor *_OBJCBIND_cltnseq();
extern struct modDescriptor *_OBJCBIND_notfound();
extern struct modDescriptor *_OBJCBIND_setseq();
extern struct modDescriptor *_OBJCBIND_Object();
extern struct modDescriptor *_OBJCBIND_typeinc();
extern struct modDescriptor *_OBJCBIND_ocstring();
extern struct modDescriptor *_OBJCBIND_OutOfMem();
extern struct modDescriptor *_OBJCBIND_sequence();
extern struct modDescriptor *_OBJCBIND_Block();
extern struct modDescriptor *_OBJCBIND_ascfiler();
extern struct modDescriptor *_OBJCBIND_array();

/* this must match objcrt.m datatype */
static struct modEntry {
	struct modDescriptor *(*modLink)();
	struct modDescriptor *modInfo;
} _msgControl[] = {
	{_OBJCBIND_objcrt,0},
	{_OBJCBIND_ordcltn,0},
	{_OBJCBIND_postlink,0},
	{_OBJCBIND_unknownt,0},
	{_OBJCBIND_set,0},
	{_OBJCBIND_cltn,0},
	{_OBJCBIND_outofbnd,0},
	{_OBJCBIND_badvers,0},
	{_OBJCBIND_Exceptn,0},
	{_OBJCBIND_Message,0},
	{_OBJCBIND_cltnseq,0},
	{_OBJCBIND_notfound,0},
	{_OBJCBIND_setseq,0},
	{_OBJCBIND_Object,0},
	{_OBJCBIND_typeinc,0},
	{_OBJCBIND_ocstring,0},
	{_OBJCBIND_OutOfMem,0},
	{_OBJCBIND_sequence,0},
	{_OBJCBIND_Block,0},
	{_OBJCBIND_ascfiler,0},
	{_OBJCBIND_array,0},
	{0,0}
};

/* non-NULL _objcModules disables auto-init */
struct modEntry *_objcModules = _msgControl;

