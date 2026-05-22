#ifndef NODE_H
typedef struct TypeDesc *Type;
#endif

typedef struct TypeDesc {
  signed char form;  /* integer, array, struct                 */
  Node fields;       /* linked list of the fields in a struct  */
  Type base;         /* base type (array element type)         */
  int size;          /* total size of the type                 */
  int len;           /* number of array elements               */
} TypeDesc;

