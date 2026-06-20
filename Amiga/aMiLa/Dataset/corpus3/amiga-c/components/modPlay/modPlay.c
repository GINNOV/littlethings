/* 
 * Utility wrapper around the (awesome) PHX ASM PTPlayer -> https://aminet.net/package/mus/play/ptplayer
 *
 * Get the file size
 * allocate chip memory
 * load file into chip
 * call ptplayer
 * 
 * 
 * Steffest - 2023
 * 
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <hardware/custom.h>
#include <graphics/gfxbase.h>
#include <stdio.h>

#include "ptplayer/ptplayer.h"

#define WRITE_DEBUG 1

UBYTE *mod_data;
int file_length;
struct GfxBase *GfxBase;
static struct Custom custom;
extern far UBYTE mt_Enable;

void play_mod(char *filename){
    FILE *fp;
    int bytes_read;
    BOOL is_pal;
    UBYTE start_pos = 0;
    void *p_samples = NULL;
   
    if (WRITE_DEBUG) printf("Loading file %s\n",filename);
    fp = fopen(filename, "rb");
    if(fp == NULL) {
        perror("Error opening mod file");
        return;
    }

    // get File length
    fseek(fp,0,2);
    file_length=ftell(fp);
    if (WRITE_DEBUG) printf("file is %d bytes\n", file_length);
    rewind(fp);

    mod_data = AllocMem(file_length, MEMF_CHIP); 
    bytes_read = fread(mod_data, sizeof(UBYTE), file_length, fp);
    fclose(fp);
    if (WRITE_DEBUG) printf("Read %d bytes\n", bytes_read);

    is_pal = (((struct GfxBase *) GfxBase)->DisplayFlags & PAL) == PAL;

    // initialize ptplayer
    mt_install_cia(&custom, NULL, is_pal);
    mt_init(&custom, mod_data, p_samples, start_pos);
    mt_mastervol(&custom, 64);
    mt_Enable = 1;

    if (WRITE_DEBUG) printf("Playing mod\n");
}

void stop_mod(){
    if (WRITE_DEBUG) printf("Cleaning up\n");
    FreeMem(mod_data, file_length);
    mt_mastervol(&custom, 0);
    Delay(10);
    mt_Enable = 0;
    mt_end(&custom);
    mt_remove_cia(&custom);
}