/*
** ANSI standart includes
*/
#include <stdio.h>

/*
** Amiga includes
*/

/*
** Amiga libraries includes
*/

/*
** Project includes
*/
#include "td.h"

/************************** test main *******************************/
void main(void) {
	ULONG i,j;
	STRPTR name;
	TDenum *sup;

	if(!initTDLibrary()) {

		printf("Number of 3d extensions : %ld\n",tdXNofGet(TD_3X));
		printf("Number of 3d loaders    : %ld\n",tdXNofGet(TD_3XLOAD));
		printf("Number of 3d savers     : %ld\n",tdXNofGet(TD_3XSAVE));

		printf("\nAll\n");
		for(i=0;i<tdXNofGet(TD_3X);i++) {
			name=tdXNameGet(TD_3X,i);
			printf("Name      : %s\n",name);
			printf("Extension : %s\n",tdXExtGet(TD_3X,name));
		}

		printf("\nLoaders\n");
		for(i=0;i<tdXNofGet(TD_3X);i++) {
			name=tdXNameGet(TD_3XLOAD,i);
			if(name!=NULL) {
				printf(" Library    : %s\n",tdXLibGet(TD_3XLOAD,name));
				printf("  Name      : %s\n",name);
				sup=tdXSupportedGet(TD_3XLOAD,name);
				j=0;
				while(sup!=NULL && sup[j]!=TD_NOTHING) {
					printf("   Supports    : %s\n",tdXDescGet(sup[j]));
					j++;
				}
			}
		}

		printf("\nSavers\n");
		for(i=0;i<tdXNofGet(TD_3X);i++) {
			name=tdXNameGet(TD_3XSAVE,i);
			if(name!=NULL) {
				printf(" Library    : %s\n",tdXLibGet(TD_3XSAVE,name));
				printf("  Name      : %s\n",name);
				sup=tdXSupportedGet(TD_3XSAVE,name);
				j=0;
				while(sup!=NULL && sup[j]!=TD_NOTHING) {
					printf("   Supports    : %s\n",tdXDescGet(sup[j]));
					j++;
				}
			}
		}

		freeTDLibrary();

	} else {
		printf("initTDLibrary failed\n");
	}
}  