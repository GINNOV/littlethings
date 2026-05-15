struct list { char **item; int length; int alloc; };
struct dictionary { char **key; char **value; int length; int alloc; };
void list_add(struct list *target, char *str);
void list_free(struct list *target);
void dictionary_add(struct dictionary *target, char *strkey, char *strvalue);
void dictionary_free(struct dictionary *target);
char *dictionary_find(struct dictionary *target, char *strkey);