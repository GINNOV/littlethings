#include <dos/dos.h>
#include <clib/dos_protos.h>
#include <stdio.h>

#include <string.h>
extern FILE *   fhopen(BPTR, char *);
extern int      fhclose(FILE *fp);

#define NAME    "T:test"
#define MSG     "hello world"

main()
{
    BPTR fh;
    FILE *fp;
    char buf[256] = {0};
    int r;

    if( fh = Open(NAME, MODE_READWRITE) ) {
        Write(fh, MSG, strlen(MSG));

        if( fp = fhopen(fh, "r+") ) {
            fseek(fp, 0, SEEK_SET);
            r = fread(buf, 1, 256, fp);
            printf("stdio: <<%s>> len %d\n", buf, r);
            fhclose(fp);
            Seek(fh, 0, OFFSET_BEGINNING);
            r = Read(fh, buf, 256);
            printf("DOS  : <<%s>> len %d\n", buf, r);
        }
        if( fp = fhopen(fh, "w+") ) {
            fseek(fp, 6, SEEK_SET);
            fputs("universe", fp);
            fseek(fp, 0, SEEK_SET);
            r = fread(buf, 1, 256, fp);
            printf("stdio: <<%s>> len %d\n", buf, r);
            fhclose(fp);
            Seek(fh, 0, OFFSET_BEGINNING);
            r = Read(fh, buf, 256);
            printf("DOS  : <<%s>> len %d\n", buf, r);
        }

        Seek(fh, 4, OFFSET_BEGINNING);

        if( fp = fhopen(fh, "a") ) {
            fputs(" full of wonders", fp);
            fhclose(fp);
        }

        if( fp = fhopen(fh, "r+") ) {
            fseek(fp, 0, SEEK_SET);
            r = fread(buf, 1, 256, fp);
            printf("stdio: <<%s>> len %d\n", buf, r);
            fhclose(fp);
            Seek(fh, 0, OFFSET_BEGINNING);
            r = Read(fh, buf, 256);
            printf("DOS  : <<%s>> len %d\n", buf, r);
        }
        Close(fh);
        remove(NAME);
    }
    return 0;
}

