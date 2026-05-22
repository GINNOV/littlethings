/* 
 * List & Dictionary
 *
 * Something like a dynamic array of strings 
 * Loosly based on code by David Tritscher found in http://www.emeraldmines.net/?emeraldx11 
 *  
 * Expanded a bit towards an associative-array (dictionary key-value store)
 * 
 * Steffest - 2021
 * 
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "list.h"

void list_add(struct list *target, char *str){
	if(target->length >= target->alloc) {
		char **ptr = target->item;
		int size = 10;
		while(target->length >= size) size = size * 8 / 5;
		if(ptr = realloc(ptr, size * sizeof(*ptr)), ptr == 0) return;
		target->item = ptr;
		target->alloc = size;
	}
	if(str = strdup(str), str == 0) return;
	target->item[target->length++] = str;
}

void list_free(struct list *target){
	char *str;
	if(target->item) {
		while(target->length) {
			str = target->item[--target->length];
			free(str);
		}
		free(target->item);
	}
	memset(target, 0, sizeof(*target));
}

void dictionary_add(struct dictionary *target, char *strkey, char *strvalue){
	int len;
	if(target->length >= target->alloc) {
		char **ptr = target->key;
		char **ptr2 = target->value;
		int size = 10;
		while(target->length >= size) size = size * 8 / 5;
		if(ptr = realloc(ptr, size * sizeof(*ptr)), ptr == 0) return;
		if(ptr2 = realloc(ptr2, size * sizeof(*ptr2)), ptr2 == 0) return;
		target->key = ptr;
		target->value = ptr2;
		target->alloc = size;
	}
	if(strkey = strdup(strkey), strkey == 0) return;
	if(strvalue = strdup(strvalue), strvalue == 0) return;
	len = target->length++;
	target->key[len] = strkey;
	target->value[len] = strvalue;
}

char *dictionary_find(struct dictionary *target, char *strkey){
	int i;
	for (i = 0; i < target->length; i++) {
  		if(strcmp(strkey,target->key[i]) == 0) return target->value[i];
	}
	return "";
}

void dictionary_free(struct dictionary *target){
	char *str;
	int len;
	if(target->key) {
		while(target->length) {
			len = --target->length;
			str = target->key[len];
			free(str);
			str = target->value[len];
			free(str);
		}
		free(target->key);
		free(target->value);
	}
	memset(target, 0, sizeof(*target));
}