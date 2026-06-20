#include <sge.h>
#include <string.h>

/**
 * first we define our custom structure
 */
typedef struct {
	int x;
	int y;
	char *name;
} element;

/**
 * a little helper function for creating a element
 */
element *createElement(int x, int y, char *name) {
	element *ret;
	sgeNew(ret, element);
	ret->x=x;
	ret->y=y;
	/* physically copy the string, so it has to
	 * be freed explicitly
	 **/
	ret->name=strdup(name);
	return ret;
}

/**
 * a little helper function for use with sgeArrayForEach to
 * print the arrays content
 **/

void printElement(Uint32 offset, void *data) {
	element *e=(element *)data;
	printf("%d: %s, x=%d, y=%d\n", (int)offset, e->name, e->x, e->y);
}

/**
 * now lets define out free function for use with the autoarray.
 * when using autoarrays, this function is called every time
 * a element is removed from the array
 */
void freeElement(Uint32 offset, void *data) {
	element *e=(element *)data;
	printf("...auto freeing %s\n", e->name);
	sgeFree(e->name);
	sgeFree(e);
}

int run(int argc, char *argv[]) {
	SGEARRAY *array, *autoarray;
	element *e;

	/* when using the default array, you'll have to manage
	 * freeing of the element on your own
	 **/
	array=sgeArrayNew();

	/* when using autoarray, you'll give it the function
	 * to free the elements
	 **/
	autoarray=sgeAutoArrayNew(&freeElement);

	/* lets add a few elements to both arrays
	 * we use createElement for every array, so every
	 * array receives its own copy of the data
	 **/
	e=createElement(0,0,"Element 1");
	sgeArrayAdd(array,e);
	e=createElement(0,0,"Element 1");
	sgeArrayAdd(autoarray,e);

	e=createElement(-1,1,"Element 2");
	sgeArrayAdd(array,e);
	e=createElement(-1,1,"Element 2");
	sgeArrayAdd(autoarray,e);

	/* lets insert one at the beginning of the array */
	e=createElement(2,3,"Element 3");
	sgeArrayInsert(array,0,e);
	e=createElement(2,3,"Element 3");
	sgeArrayInsert(autoarray,0,e);

	/* now use sgeArrayForEach function to display our array */
	sgeArrayForEach(array, &printElement);

	printf("...removing middle element\n");

	/* on our normal array, we have to free the data by ourself */
	e=sgeArrayGet(array,1);
	sgeFree(e->name);
	sgeFree(e);
	sgeArrayRemove(array,1);

	/* on out autoarray, our free function is called automatically */
	sgeArrayRemove(autoarray, 1);

	/* print content again */
	sgeArrayForEach(array, &printElement);

	/**
	 * free our normal array (we have to free data by ourself).
	 * Ofcourse we could have used sgeArrayForEach and define a 
	 * helper function for freeing, but this way it looks more
	 * complex ;)
	 **/
	while (array->numberOfElements>0) {
		/* always remove element 0 because array gets smaller while removing */
		e=sgeArrayGet(array,0);
		sgeFree(e->name);
		sgeFree(e);
		sgeArrayRemove(array,0);
	}
	/* free the array itself */
	sgeArrayDestroy(array);

	/* free our autoarray, including all remaining elements */
	sgeArrayDestroy(autoarray);

	return 0;
}
