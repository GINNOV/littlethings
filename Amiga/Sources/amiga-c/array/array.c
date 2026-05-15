/* something like a dynamic array of strings */

#include <string.h>

struct hash { char **data; int length; int alloc; };
struct hash myList;

static void hash_add(struct hash *arg, char *str)
{
	if(arg->length >= arg->alloc) {
		char **ptr = arg->data;
		int size = 10;
		while(arg->length >= size) size = size * 8 / 5;
		if(ptr = realloc(ptr, size * sizeof(*ptr)), ptr == 0) return;
		arg->data = ptr;
		arg->alloc = size;
	}
	if(str = strdup(str), str == 0) return;
	arg->data[arg->length++] = str;
}

static void hash_free(struct hash *arg)
{
	char *str;
	if(arg->data) {
		while(arg->length) {
			str = arg->data[--arg->length];
			free(str);
		}
		free(arg->data);
	}
	memset(arg, 0, sizeof(*arg));
}

int main () {
	int i;
	hash_add(&myList,"item 1");
	hash_add(&myList,"Another item");

	for(i = 0; i < myList.length; i++) {
		 puts(myList.data[i]);
	}

	hash_free(&myList);
}