/*
 * Iff2Src - Convert 8svx samples to include files
 *
 * Written in 1993 by Michael Bauer (bauermichael@student.uni-tuebingen.de)
 *
 * This stuff is FreeWare. Use it as your own risk.
 *
 * Compile: dcc -3.0 -// -v -f iff2src.c -o iff2src
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <stdio.h>

/// "structures, ..."
struct HEADER {
    UBYTE   Form[4];
    long    length;
    UBYTE   Type[4];
} Header;

struct Voice8Header {
    ULONG   oneShotHiSamples;
    ULONG   repeatHiSamples;
    ULONG   samplesPerHiCycle;
    UWORD   samplesPerSec;
    UBYTE   ctOctave;
    UBYTE   sCompression;
    LONG    volume;
} SampleHeader;

struct SoundInfo {
    BYTE    *SoundBuffer;
    UWORD   RecordRate;
    ULONG   FileLength;
    UBYTE   channel_bit;
} info;

BPTR    file;
UBYTE   chunk[4];
ULONG   pos;
BYTE    *SoundBuffer;
BYTE    *pointer;

UBYTE version_tag[] = "\0$VER: IFF2Src V1.0 (5.8.94)";
///
/// "main"
main(int argc, char *argv[]) {

    STRPTR name, infile;

    if (argc != 3) {
        puts ("Usage: iff2src infile arrayname > outfile");
        exit (0);
    }

    strcpy(infile, argv[1]);
    strcpy(name, argv[2]);

    file = Open(infile,MODE_OLDFILE);
    if (!file)
        return (FALSE);

    /*
     * Read the Header of the file
     */
    Seek(file,0,OFFSET_BEGINNING);
    Read(file, &Header, sizeof(Header));

    /*
     * Take a look at the header to figure out if it really is an 8SVX file
     */
    if (strcmp(Header.Type,"8SVX") != 0) {
        puts("Sorry, that's no 8SVX Sample !");
        Close(file);
        exit(0);
    }

    /*
     * Rewind the file, search for the VHDR chunk, jump to the beginning
     * of the header and read the sample data
     */
    Seek(file,0,OFFSET_BEGINNING);
    FindChunk(file,"VHDR");
    Read(file, &chunk, sizeof(chunk));
    Read(file, &SampleHeader, sizeof(SampleHeader));

    /*
     * Determine the length of the sample plus the record rate
     */
    info.FileLength=SampleHeader.oneShotHiSamples + SampleHeader.repeatHiSamples;
    info.RecordRate=SampleHeader.samplesPerSec;

    /*
     * The old FutureSound files are stored in KHz and have RecordRates
     * < 100.
     */
    if (info.RecordRate < 100) {
        info.RecordRate *= 1000;
    }

    /*
     * Allocate Memory for the soundbuffer
     */
    info.SoundBuffer = (BYTE *) AllocMem(info.FileLength,MEMF_CHIP | MEMF_CLEAR);
    if (!(info.SoundBuffer)) {
        puts("Can't allocate memory.");
        Close(file);
        exit(0);
    }

    /*
     * Rewind the file, search for the BODY chunk, move to the end of the
     * Data block and read the complete sample data
     */
    Seek(file,0,OFFSET_BEGINNING);
    FindChunk(file,"BODY");
    Read(file, &chunk, sizeof(chunk));
    Read(file, info.SoundBuffer, info.FileLength);

    Close(file);

    pointer = info.SoundBuffer;

    /*
     * Print the array to a file or to stdout.
     */
    printf ("#ifndef EASYSOUND_H\n");
    printf ("#include \"easysound.h\"\n");
    printf ("#endif\n\n");
    printf ("__chip BYTE %s_data[] = {\n", name);

    for (pos=0; pos<info.FileLength; pos++) {
        if (pos % 10 == 0) {
            printf("\n    ");
        }
        printf("%d%s", pointer[pos],pos<info.FileLength-1 ? ",  " : " ");
    }
    printf("\n};\n\n");
    
    printf ("struct SoundInfo %s = {\n", name);
    printf ("    %s_data,", name);
    printf ("    %8d,", info.RecordRate);
    printf ("    %8d\n};\n\n", info.FileLength);

    FreeMem(info.SoundBuffer,info.FileLength);
}
///
/// "FindChunk"
FindChunk(BPTR *file, char *searchchunk) {
    while (strcmp(chunk,searchchunk) != 0) {
        Read(file, &chunk, sizeof(chunk));
    }
}
///

