/*
 * RConfig -- Replacement Library Configuration
 *   Copyright 1991, 1992 by Anthon Pang, Omni Communications Products
 *
 * Source File: stkchker.c
 * Description: Modify Manx cc 5.2a generated assembler (.asm) files, to
 *   support my version of _stkchk() and RConfig code.
 * Comments: formerly stkchk.rexx 1.2 (92.08.30)
 * Usage: stkchker filename.asm
 *    or: stkchker filename.a68
 */

#include <stdio.h>
#include <fcntl.h>
#include <string.h>

static char *verstag = "\0$VER: stkchker 1.3 (30.08.92)";

#define BUFFERSIZE 1024

#define filename    l1
#define oldname     l2
#define stackframesize  tmp

char *l,*l1,*l2;    /* line buffers */

#define exists(f)       (access((char*)f, 0)==0)
#define system(c)       Execute((STRPTR)c, 0L, 0L)
#define swap(x,y)       tmp=x;x=y;y=tmp

static char *STKCHKSTRING = "\x09" "jsr" "\x09" "__stkchk#\n";
static char *MOVEWSTRING = "\x09" "move.w" "\x09";
 
void writeln(FILE *f, char *buffer) {
    fwrite(buffer, strlen(buffer), 1, f);
}

/* appends \n if present */
void readln(FILE *f, char *buffer) {
    char c;
    int l;

    l = 0;
    while ((c=fgetc(f))!=EOF) {
        *buffer++ = c;
        l++;
        if (l == BUFFERSIZE)
            exit(20);
        if (c == '\n')
            break;
    }
    *buffer = '\0';
}

int main(int argc, char *argv[]) {
    int n;
    FILE *infile;
    FILE *outfile;
    char *tmp;

    l = (char*)malloc(BUFFERSIZE);
    l1 = (char*)malloc(BUFFERSIZE);
    l2 = (char*)malloc(BUFFERSIZE);

    if (!l || !l1 || !l2)
        exit(20);

    n = argc;

    if (n == 2) {
        strcpy(filename, argv[1]);

        /* guesses if file doesn't exist...possibly omitted extension? */
        if (!exists(filename)) {
            strcat(filename, ".asm");
        }
        if (!exists(filename)) {
            strcpy(filename, argv[1]);
            strcat(filename, ".a68");
        }

        if (exists(filename)) {

            strcpy(oldname, filename);
            strcat(oldname, "~");

            sprintf(l, "copy %s %s", filename, oldname);
            system(l);            

            if (infile = fopen(oldname, "r")) {
                if (outfile = fopen(filename, "w")) {
                    readln(infile, l);

                    while (!feof(infile)) {
                        if (strncmp(l+1, "link", 4)==0) {
                            swap(l1,l);
                            readln(infile, l);

                            if (strncmp(l+1, "movem.l", 7)==0) {
                                swap(l2,l);
                                readln(infile, l);

                                if (strcmp(l, STKCHKSTRING)==0) {
                                    stackframesize = strrchr(l1, ',')+1;
                                    writeln(outfile, MOVEWSTRING);
                                    fwrite(stackframesize, strlen(stackframesize)-1, 1, outfile); /* ignore \n */
                                    writeln(outfile, ",d0\n");

                                    writeln(outfile, l);
                                    writeln(outfile, l1);
                                    writeln(outfile, l2);
                                } else {
                                    /* hmmm...not a 3 line stkchk, so just copy lines */
                                    writeln(outfile, l1);
                                    writeln(outfile, l2);
                                    writeln(outfile, l);
                                }
                            } else if (strcmp(l, STKCHKSTRING)==0) {
                                stackframesize = strrchr(l1, ',')+1;
                                writeln(outfile, MOVEWSTRING);
                                fwrite(stackframesize, strlen(stackframesize)-1, 1, outfile); /* ignore \n */
                                writeln(outfile, ",d0\n");
                                writeln(outfile, l);
                                writeln(outfile, l1);
                            } else {
                              /* hmmm...not a two line stkchk, so just copy lines */
                              writeln(outfile, l1);
                              writeln(outfile, l);
                            }
                        } else {
                            /* not a local stack frame */
                            if (strcmp(l, STKCHKSTRING)==0) {
                                writeln(outfile, MOVEWSTRING);
                                writeln(outfile, "0,d0\n");
                            }
                            writeln(outfile, l);
                        }
                        readln(infile, l);
                    }
                    fclose(outfile);
                    puts("Done.");
                } else {
                    puts("Unable to write file.");
                }
                fclose(infile);
            } else {
                puts("Unable to read file.");
            }
        } else {
            printf("File: %s doesn't exist.\n", argv[1]);
        }
    } else if (argc) {
        printf("Usage: %s filename.asm\n", argv[0]);
    }

    return 0;
}
