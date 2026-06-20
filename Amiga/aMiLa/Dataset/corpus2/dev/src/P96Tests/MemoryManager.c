
#include <proto/exec.h>

#include <exec/memory.h>

#include <stdio.h>

struct GfxMemChunk {
	struct MinNode Node;
	char *Ptr;
	ULONG Size;
	APTR bme;
	BOOL Used;
};

LONG MemorySize = 0x200000;
LONG MaxMemorySize;
LONG MaxChunkSize;
APTR PoolMem;

struct MinList MemList;

struct GfxMemChunk *ReleaseCardMem(struct GfxMemChunk *mem)
{
	struct GfxMemChunk *tmem;

	printf("Release: %lx size %ld",mem->Ptr,mem->Size);

	MaxMemorySize += mem->Size;
	mem->Used = FALSE;

	// merge with Predecessor
	tmem=(struct GfxMemChunk *)mem->Node.mln_Pred;
	if((tmem->Node.mln_Pred) && (!tmem->Used)){
		mem->Ptr=tmem->Ptr;
		mem->Size += tmem->Size;
		Remove((struct Node *)tmem);
		FreePooled(PoolMem, tmem, sizeof(struct GfxMemChunk));
	}

	// merge with Successor
	tmem=(struct GfxMemChunk *)mem->Node.mln_Succ;
	if(tmem->Node.mln_Succ){
		mem->Size += tmem->Size;
		Remove((struct Node *)tmem);
		FreePooled(PoolMem, tmem, sizeof(struct GfxMemChunk));
	}

	// calculate new MaxChunkSize
	if(mem->Size > MaxChunkSize){
		MaxChunkSize = mem->Size;
	}

	printf("  MaxChunkSize: %ld  MaxMemorySize: %ld\n",MaxChunkSize,MaxMemorySize);
	return(mem);
}

struct GfxMemChunk *ObtainCardMem(ULONG size)
{
	ULONG bestsize=(ULONG)-1;
	struct GfxMemChunk *mem, *best=NULL;

	// is there enough memory at all?	
	if(size > MemorySize){
		return(NULL);
	}

	if(size > MaxChunkSize){

		// free as many mem chunks as necessary
		do{
			for(mem=(struct GfxMemChunk *)MemList.mlh_TailPred;mem->Node.mln_Pred;mem=(struct GfxMemChunk *)mem->Node.mln_Pred){
				if(mem->Used){
//					Purge(mem->bme);
					mem=ReleaseCardMem(mem);
					break;
				}
			}
		}while(size > MaxChunkSize);
		best=mem;
	}else{

		// find best fit
		for(mem=(struct GfxMemChunk *)MemList.mlh_Head;mem->Node.mln_Succ;mem=(struct GfxMemChunk *)mem->Node.mln_Succ){
			if((!mem->Used) && (mem->Size >= size) && (mem->Size < bestsize)){
				bestsize=mem->Size;
				best=mem;
			}
		}
	}

	if(best){
		mem=AllocPooled(PoolMem, sizeof(struct GfxMemChunk));
		best->Used = TRUE;
		if(mem){
			mem->Size = best->Size - size;
			mem->Ptr = best->Ptr + size;
			mem->Used = FALSE;
			best->Size = size;
			Insert((struct List *)&MemList, (struct Node *)mem, (struct Node *)best);
			MaxMemorySize -= size;
			MaxChunkSize = 0;
			for(mem=(struct GfxMemChunk *)MemList.mlh_Head;mem->Node.mln_Succ;mem=(struct GfxMemChunk *)mem->Node.mln_Succ){
				if((!mem->Used) && (mem->Size > MaxChunkSize)){
					MaxChunkSize = mem->Size;
				}
			}
		}
	}
	return(best);
}

int main(void)
{
	MaxChunkSize = MaxMemorySize = MemorySize;
	NewList((struct List *)&MemList);
	PoolMem = CreatePool(MEMF_ANY,4000,4000);
	
	if(PoolMem){
		struct GfxMemChunk *mem;
		mem=AllocPooled(PoolMem, sizeof(struct GfxMemChunk));
		if(mem){
			mem->Size=MaxMemorySize;
			mem->Ptr=NULL;
			mem->Used=FALSE;
			AddHead((struct List *)&MemList, (struct Node *)mem);
			
			mem=ObtainCardMem(3000000);
			if(mem)
				printf("mem: %lx size: %ld   MaxChunkSize: %ld  MaxMemorySize: %ld\n",mem->Ptr,mem->Size,MaxChunkSize,MaxMemorySize);
			else
				printf("no Mem!\n");
			mem=ObtainCardMem(640*480*8/8);
			if(mem)
				printf("mem: %lx size: %ld   MaxChunkSize: %ld  MaxMemorySize: %ld\n",mem->Ptr,mem->Size,MaxChunkSize,MaxMemorySize);
			else
				printf("no Mem!\n");
			mem=ObtainCardMem(1024*768*4/8);
			if(mem)
				printf("mem: %lx size: %ld   MaxChunkSize: %ld  MaxMemorySize: %ld\n",mem->Ptr,mem->Size,MaxChunkSize,MaxMemorySize);
			else
				printf("no Mem!\n");
			mem=ObtainCardMem(640*480*24/8);
			if(mem)
				printf("mem: %lx size: %ld   MaxChunkSize: %ld  MaxMemorySize: %ld\n",mem->Ptr,mem->Size,MaxChunkSize,MaxMemorySize);
			else
				printf("no Mem!\n");
			mem=ObtainCardMem(640*480*8/8);
			if(mem)
				printf("mem: %lx size: %ld   MaxChunkSize: %ld  MaxMemorySize: %ld\n",mem->Ptr,mem->Size,MaxChunkSize,MaxMemorySize);
			else
				printf("no Mem!\n");
			mem=ObtainCardMem(640*480*8/8);
			if(mem)
				printf("mem: %lx size: %ld   MaxChunkSize: %ld  MaxMemorySize: %ld\n",mem->Ptr,mem->Size,MaxChunkSize,MaxMemorySize);
			else
				printf("no Mem!\n");
			mem=ObtainCardMem(1280*1024*8/8);
			if(mem)
				printf("mem: %lx size: %ld   MaxChunkSize: %ld  MaxMemorySize: %ld\n",mem->Ptr,mem->Size,MaxChunkSize,MaxMemorySize);
			else
				printf("no Mem!\n");
		}
		DeletePool(PoolMem);
	}
	return(0);
}
