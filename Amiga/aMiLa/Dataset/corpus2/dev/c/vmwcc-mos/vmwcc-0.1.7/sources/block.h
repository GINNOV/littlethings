#ifndef NODE_H
typedef struct BlockDesc *Block;
#endif

typedef struct BlockDesc {
   char kind;  // eg while header
   Block fail,branch; // jump targets
   Block rdom,dsc,next; 
   Node first,last;  // instrs in BB
   Block link,prev;  // linked list of abb BB's
   int num;
   Node phi_functions;
   Node vars;
   int entry;
   int offset;
   int framesize;
   int level;
   int regs_used;
   int prototype;
} BlockDesc;

void vmwConnectBlocks();
Block InsertBlock( Block *root, char kind,int level);
Block find_last_block( Block first, Block last);
   
   
