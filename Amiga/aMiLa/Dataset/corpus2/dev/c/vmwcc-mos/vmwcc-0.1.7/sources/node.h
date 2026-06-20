#define NODE_H 1

#define vmwIdlen 32


typedef struct NodeDesc *Node;
typedef struct TypeDesc *Type;
typedef struct BlockDesc *Block;


    /* The ever expanding Node structure */
typedef struct NodeDesc {

    signed char mode;  
    signed char lev;       /* Global or Local */
    Type type;          /* Type */
   
    Node next;
    Node prev;
   
    Node dsc;
    Node master;

    char name[vmwIdlen];   /* Name  */
    int val;               /* Value */
    
    void *initial_data;
   
                      
    signed char op;        /* Opcode   */
    Node x,y;              /* Operands */
    signed char xtype,ytype;
   
    Block block;           /* Basic block it belongs to */
    Block jump_target;     /* Jump target, if a jump    */
    Node use,xLastUse, yLastUse;  /* Crazy stuff we might not use */
    Node current;          /* Point to the current last use of the instruction */

    Node op_list;
   
    Node var_list; 

    int reg,ind;  /* register allocation */
   
    int deleted;
   
    int line_number;
    int used;        
    int parameter;
    int bss_offset;
    int target_size;
    int pointer;
   
} NodeDesc;

Node AddToList(Node *root, char *id);
Node FindNode(const Node  *root, char *id); 
void InitObj(const Node obj,const long class,const Node dsc,const Type type,const long val);
Node InsertNode( Node *root, const int class, const Type type,
		                  char *name, const int val);
void vmwReplaceNode(Node replacement_node, Node deleted_node);
   
   
