/*
 * Example of the list and dictionary component
 *
 * 2021 - Steffest 
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "list.h"

struct list myList;
struct dictionary myDictionary;

int main(){
     int i;

     list_add(&myList,"item 1");
     list_add(&myList,"item 2");

     dictionary_add(&myDictionary,"yellow","my true love's hair");
     dictionary_add(&myDictionary,"green","the sparkling corn");
     dictionary_add(&myDictionary,"blue","the sky");

     printf("My list has %d items:\n",myList.length);
     for(i = 0; i < myList.length; i++) {
		  printf("  -%s\n",myList.item[i]);
	 } 

     printf("Green is the colour of %s.\n",dictionary_find(&myDictionary,"green"));

     list_free(&myList);
     dictionary_free(&myDictionary);


     return 0;
}
    