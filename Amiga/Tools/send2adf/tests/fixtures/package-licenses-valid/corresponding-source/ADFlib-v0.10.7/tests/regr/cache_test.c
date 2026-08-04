/*
 * cache_test.c
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include"adflib.h"


void MyVer(char *msg)
{
    fprintf(stderr,"Verbose [%s]\n",msg);
}


/*
 *
 *
 */
int main(int argc, char *argv[])
{
    struct AdfDevice *hd;
    struct AdfVolume *vol;
    struct AdfFile *file;
    unsigned char buf[600];
    long n;
    FILE *in;
    long len;

    adfLibInit();

//	adfEndSetFct(0,0,MyVer,0);

    /* mount existing device : FFS */
    hd = adfMountDev ( "testffs.bak", ADF_ACCESS_MODE_READWRITE );
    if (!hd) {
        fprintf(stderr, "can't mount device\n");
        adfLibCleanUp(); exit(1);
    }

    vol = adfVolMount ( hd, 0, ADF_ACCESS_MODE_READWRITE );
    if (!vol) {
        adfUnMountDev(hd);
        adfCloseDev(hd);
        fprintf(stderr, "can't mount volume\n");
        adfLibCleanUp(); exit(1);
    }

    showVolInfo( vol );

    showDirEntries( vol, vol->curDirPtr );

//    adfCreateDir(vol,vol->curDirPtr,"dir_1a");
    adfCreateDir(vol,vol->curDirPtr,"dir_1b");



    file = adfOpenFile(vol, "newfile","w");
    adfCloseFile(file);

    file = adfOpenFile(vol, "moon_gif","w");
    if (!file) return 1;
    in = fopen("Check/MOON.GIF","rb");
    if (!in) return 1;
    
    len = 600;
    n = fread(buf,sizeof(unsigned char),len,in);
    while(!feof(in)) {
        adfWriteFile(file, n, buf);
        n = fread(buf,sizeof(unsigned char),len,in);
    }
    if (n>0)
        adfWriteFile(file, n, buf);

//    adfFlushFile(file);

    adfCloseFile(file);
    fclose(in);

    adfRemoveEntry(vol,vol->curDirPtr, "dir_1b");

    showDirEntries( vol, vol->curDirPtr );

    adfVolUnMount(vol);
    adfUnMountDev(hd);
    adfCloseDev(hd);

    adfLibCleanUp();

    return 0;
}
