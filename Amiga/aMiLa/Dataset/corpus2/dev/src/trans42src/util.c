#include <proto/dos.h>
#include <proto/locale.h>
#include <proto/exec.h>
#include <proto/utility.h>

#include <exec/memory.h>

#include "phonemes.h"

#include <string.h>
#include <ctype.h>

PRIVATE UBYTE *Strdup(const UBYTE *s)
{
    UBYTE *p = AllocVec(strlen(s)+1, MEMF_ANY);
    if (p) strcpy(p,s);
    return p;
}

PRIVATE void uppercase(UBYTE *dest)
{
    while (*dest)
    {
        *dest = ToUpper(*dest);
        dest++;
    }
}



PRIVATE UBYTE *MyFilePart(UBYTE *path)
{
    UBYTE *p;
    
    if (p = strrchr(path, '/')) return p+1;
    if (p = strrchr(path, ':')) return p+1;
    
    return path;
}

PRIVATE int suffix(const char *str, const char *suf)
{
    int pos = strlen(str) - strlen(suf);
    if (pos<0) return 0;
    return !Stricmp((STRPTR)str+pos, (STRPTR)suf);
}


PRIVATE UBYTE *NamePart(UBYTE *path)
{
    int len;
    UBYTE *mem;
    
    path = MyFilePart(path);
    len = strlen(path);
    
    if (suffix(path,speechExt)) len -= strlen(speechExt);
    
    mem = AllocVec(len+1, MEMF_ANY);
    
    if (mem)
    {
        memcpy(mem,path,len);
        mem[len] = 0;
    }
    
    return mem;
}

#ifdef KS13

APTR MyAllocVec(unsigned long byteSize, unsigned long requirements)
{
    ULONG *mem;
    
    byteSize += sizeof(ULONG);
    mem = AllocMem(byteSize, requirements);
    
    if (mem) *mem++ = byteSize;
    return mem;
}

void MyFreeVec(APTR memoryBlock)
{
    ULONG *mem = memoryBlock;
    ULONG size = *(--mem);
    
    FreeMem(mem,size);
}

LONG MyGetVar(STRPTR name, STRPTR buffer, long size, long flags)
{
    UBYTE *buf = AllocVec(strlen(name)+4+1, MEMF_ANY);  /* "ENV:" */
    BPTR fh;
    LONG length = -1;
    
    if (buf)
    {
        strcpy(buf,"ENV:");
        strcat(buf,name);
        
        fh = Open(buf,MODE_OLDFILE);
        
        if (fh)
        {
            length = Read(fh, buffer, size-1);
            
            if (length>=0)
            {
                if ((flags & GVF_DONT_NULL_TERM)==0)
                {
                    UBYTE *p;
                    buffer[length] = 0;
                     
                    if ((flags & GVF_BINARY_VAR)==0 &&
                        (p = strchr(buffer,'\n')))
                    {
                        *p = 0;
                    }
                }
            }
            
            Close(fh);
        }
        
        FreeVec(buf);
    }
    
    return length;
}


BOOL MyAddPart(STRPTR dirname, STRPTR filename, unsigned long size)
{
    STRPTR last;
    
    last = strrchr(dirname,'/');
    if (last) last++; else
    {
        last = strrchr(dirname,':');
        if (last) last++; else last = dirname;
    }
    
    if (size-(last - dirname) < strlen(filename)+1) return 0;
    
    strcpy(last,filename);
    return 1;
}


#endif

