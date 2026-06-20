#ifndef STDLIST_H
#define STDLIST_H 1

typedef struct _node
{
struct _node *prev, *next;
} _node;


typedef struct
{
_node *first, *last;
long length;
} _list;

#ifndef ANSIC
_node *inst_node();
void put_head();
void *add_head();
void put_tail();
void *add_tail();
void *remv_head();
void *remv_tail();
void remv_list();
void *r_node();
void *remv_node();
#else
_node *inst_node(long);
void put_head(_list *,_node *);
void *add_head(_list *,long);
void put_tail(_list *,_node *);
void *add_tail(_list *,long);
void *remv_head(_list *, void **);
void *remv_tail(_list *, void **);
void remv_list(_list *);
void *r_node(_list *,_node *,void **);
void *remv_node(_list *,void *);
#endif

#endif





