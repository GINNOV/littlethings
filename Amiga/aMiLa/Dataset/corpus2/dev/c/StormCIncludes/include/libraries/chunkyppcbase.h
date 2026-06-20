#ifndef CHUNKYPPCBASE_H

typedef struct {
   struct Library         lib_node;
   APTR                   seg_list;
   struct ExecBase       *sys_base;
} ChunkyPPC;

#endif
