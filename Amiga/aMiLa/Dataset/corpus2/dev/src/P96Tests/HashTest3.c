#include <exec/types.h>

#include <proto/exec.h>
#include <proto/rtg.h>
#include <proto/timer.h>

#include <stdio.h>
#define NUMENTRIES 200

int main(int argc, char **argv)
{
	struct RTGBase *RTGBase;

	if(RTGBase=(struct RTGBase *)OpenLibrary(RTGNAME,40)){
		int i;
		
		printf("HashArray @%08lx\n", &RTGBase->DisplayIDHashArray[0]);

		for(i=0;i<16;i++){
			int count=0;
			struct LibResolution *res;
			for(res=RTGBase->DisplayIDHashArray[i];res;res = res->HashChain){
				count++;
				printf("DisplayID %08lx of %s @%08lx\n", res->DisplayID, res->BoardInfo->BoardName, res);
			}
			printf("List %d contains %d members\n",i,count);
		}
		CloseLibrary((struct Library *)RTGBase);
	}
}
