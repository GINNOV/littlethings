#include <crbinc/inc.h>
#include <crbinc/memutil.h>

void * AllocMem(size_t size,int MemFlags)
{
void * ret;
if ( size == 0 ) return(NULL);
size = PaddedSize(size);
ret = malloc(size);
if ( ret && (MemFlags&MEMF_CLEAR) )
  MemClearFast(ret,size>>2);
return(ret);
}

void FreeMem(void * mem,int trash)
{
if (mem) free(mem);
}

void MemCpy(void *To,void *Fm,size_t len)
{
register int L;

if ((len&3)==0)
  {
  L = len>>2;
  
  if ( (((ulong)Fm)&3) == 0 && (((ulong)To)&3) == 0 )
    {
    register ulong *FmP,*ToP;
    
    FmP = Fm; ToP = To;
    
    while(L--) *ToP++ = *FmP++;
    }
  else
    {
    register ubyte *FmP,*ToP;
    
    FmP = Fm; ToP = To;
    
    while(L--)
      { *ToP++ = *FmP++; *ToP++ = *FmP++; *ToP++ = *FmP++; *ToP++ = *FmP++; }
    }
  }
else if ((len&1)==0)
  {
  register ubyte *FmP,*ToP;
  FmP = Fm; ToP = To;

  L = len>>1;
  while(L--)
    {
    *ToP++ = *FmP++;
    *ToP++ = *FmP++;
    }
  }
else
  {
  register ubyte *FmP,*ToP;
  FmP = Fm; ToP = To;

  L = len;
  while(L--) *ToP++ = *FmP++;
  }
}

void MemClear(void *P,size_t len)
{
register ubyte *Ptr;
register int L;

Ptr = P;

if ((len&3)==0)
  {
  L = len>>2;
  while(L--)
    {
    *Ptr++ = 0;
    *Ptr++ = 0;
    *Ptr++ = 0;
    *Ptr++ = 0;
    }
  }
else if ((len&1)==0)
  {
  L = len>>1;
  while(L--)
    {
    *Ptr++ = 0;
    *Ptr++ = 0;
    }
  }
else
  {
  L = len;
  while(L--)
    *Ptr++ = 0;
  }
}

void MemClearFast(void *P,size_t len)
{
register int L = len;

if ( (((ulong)P)&3) == 0 )
  {
  register ulong *Ptr = P;

  while(L--) *Ptr++ = 0;
  }
else
  {
  register ubyte *Ptr = P;

  while(L--) { *Ptr++ = 0; *Ptr++ = 0; *Ptr++ = 0; *Ptr++ = 0; }
  }

}

void MemCpyFast(void *To,void *Fm,size_t len)
{
register int L = len;

if ( (((ulong)Fm)&3) == 0 && (((ulong)To)&3) == 0 )
  {
  register ulong *FmP,*ToP;
  
  FmP = Fm; ToP = To;
  
  while(L--) *ToP++ = *FmP++;
  }
else
  {
  register ubyte *FmP,*ToP;
  
  FmP = Fm; ToP = To;
  
  while(L--)
    { *ToP++ = *FmP++; *ToP++ = *FmP++; *ToP++ = *FmP++; *ToP++ = *FmP++; }
  }
}
