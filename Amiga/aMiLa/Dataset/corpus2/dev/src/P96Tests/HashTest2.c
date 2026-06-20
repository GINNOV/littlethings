#include <exec/types.h>

#include <proto/exec.h>
#include <proto/rtg.h>
#include <proto/timer.h>

#include <stdio.h>
#define NUMENTRIES 200

int main(int argc, char **argv)
{
	struct RTGBase *RTGBase;
	struct Library *TimerBase;
	struct BoardInfo bi;
	struct timeval t1,t2;

	TimerBase=(struct Library *)FindName(&SysBase->DeviceList,"timer.device");
	GetSysTime(&t1);
	NewList((struct List *)&bi.BitMapList);
	if(RTGBase=(struct RTGBase *)OpenLibrary(RTGNAME,40)){
		int count;
		for(count=0;count<300;count++){
			int i;
			struct BitMapExtra *bme[NUMENTRIES],*tbme;
	
			for(i=0;i<NUMENTRIES;i++){
				bme[i]=rtgGetBitMapExtra();
				if(bme[i]){
					bme[i]->BitMap=(struct BitMap *)i;
					bme[i]->BoardInfo=&bi;
					rtgAddBitMapExtra(bme[i]);
	//				printf("BitMap %d added\n",i);
				}
			}
			for(i=0;i<NUMENTRIES;i++){
				tbme=rtgLookUpBitMapExtra((struct BitMap *)i);
	//			printf("BitMap %d %sfound\tBitMap %d\n",i,(tbme==bme[i])? "" : "not ",tbme->BitMap);
			}
			for(i=0;i<8;i++){
				int count=0;
				struct MinNode *node;
				for(node=RTGBase->BitMapExtraHashArray[i]->mlh_Head;node->mln_Succ;node=node->mln_Succ){
					count++;
				}
	//			printf("List %d contains %d members\n",i,count);
			}
			for(i=0;i<NUMENTRIES;i++){
				rtgRemoveBitMapExtra(bme[i]);
	//			printf("BitMap %d removed\n",i);
			}
		}
		CloseLibrary((struct Library *)RTGBase);
	}
	GetSysTime(&t2);
	SubTime(&t2,&t1);
	printf("Zeit: %ld.%06ld s\n",t2.tv_secs,t2.tv_micro);
}
