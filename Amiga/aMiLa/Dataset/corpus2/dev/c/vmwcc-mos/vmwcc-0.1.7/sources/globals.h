extern Block root_block;
extern Block current_phi_block;
extern Block current_block;
extern Node globscope;
extern int current_path;
extern int current_level;
extern int current_depth;
extern int block_num;
extern Node GP,FP;
extern Node current_instruction,first_instruction;
extern Type CSGintType,CSGlongType, CSGboolType, CSGshortType, CSGcharType, CSGvoidType;
extern int entrypc;
extern unsigned int vmwVal;
extern char vmwId[vmwIdlen];
extern char vmwString[BUFSIZ];

#define O_EXECUTABLE  1
#define O_OBJECT      2
#define O_ASSEMBLY    4
#define O_SSAFINAL    8
#define O_SSAINITIAL 16
#define O_DOMTREE    32

#define D_ERRORS      0
#define D_WARNINGS    1
#define D_DEBUG       2

extern struct cpu_info_type cpu_info;
extern int optimize_level;
extern int output_options;
extern int debug_level;

