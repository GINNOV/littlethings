/*
The MIT License (MIT)

Copyright (c) 2020 Carsten Sonne Larsen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#ifdef BUILD
#include <proto/dos.h>
#include <proto/exec.h>
#else
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#endif

#include <dos/dos.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "b64.h"

struct b64args
{
    STRPTR file;
    STRPTR out;
    LONG decode;
    LONG help;
    LONG verbose;
    STRPTR text;
};

const char *vers = "\0$VER: Base64 1.0 (29.04.2020) The MIT License (MIT)";
const char *copy = "Copyright (c) 2014 Joseph Werle\n"
                   "Copyright (c) 2020 Carsten Sonne Larsen";
const char *temp = "I=FILE/K,O=OUT/K,DECODE/S,HELP/S,VERBOSE/S,TEXT/F";
struct b64args args = {NULL, NULL, FALSE, FALSE, FALSE, NULL};

static void ShowSize(const char *message, long int size)
{
    if (args.verbose)
    {
        if (args.decode)
        {
            printf("Encoded %s: %ld\n", message, size);
        }
        else
        {
            printf("Decoded %s: %ld\n", message, size);
        }
    }
}

static void ShowError(const char *message)
{
    printf("%s\n", message);
}

static void ShowDosError(void)
{
    char message[255];
    LONG error = IoErr();
    Fault(error, (STRPTR) "Could not open file", (STRPTR)message, 255);
    ShowError(message);
}

static const unsigned char *ReadInput(LONG *inputSize)
{
    void *str = NULL;
    LONG count, size = 0;

    Seek(Input(), 0, OFFSET_END);
    size = Seek(Input(), 0, OFFSET_BEGINNING);

    *inputSize = size;

    if (size != 0)
    {
        str = AllocMem(size, MEMF_CLEAR);
        if (str)
        {
            count = Read(Input(), str, size);
            if (count != size)
            {
                FreeMem(str, size);
                str = NULL;
                ShowError("Could not read file.");
            }
        }
        else
        {
            ShowError("Could not allocate memory.");
        }
    }

    ShowSize("input size", size);
    return str;
}

static LONG GetFileSize(STRPTR fileName)
{
    BPTR file;
    LONG size = 0;

    file = Open(fileName, MODE_OLDFILE);
    if (file)
    {
        Seek(file, 0, OFFSET_END);
        size = Seek(file, 0, OFFSET_BEGINNING);
        Close(file);
    }
    else
    {
        ShowDosError();
    }

    ShowSize("file size", size);
    return size;
}

static const unsigned char *ReadFile(STRPTR fileName, LONG *fileSize)
{
    void *str = NULL;
    BPTR file;
    LONG count, size;

    *fileSize = 0;

    if ((size = GetFileSize(fileName)))
    {
        *fileSize = size;
        str = AllocMem(size, MEMF_CLEAR);
        if (str)
        {
            if ((file = Open(fileName, MODE_OLDFILE)))
            {
                count = Read(file, str, size);
                if (count != size)
                {
                    FreeMem(str, size);
                    str = NULL;
                    ShowError("Could not read file.");
                }
                Close(file);
            }
            else
            {
                ShowDosError();
            }
        }
        else
        {
            ShowError("Could not allocate memory.");
        }
    }

    return str;
}

static LONG WriteFile(STRPTR fileName, const unsigned char *text, LONG fileSize)
{
    BPTR file;
    LONG count;

    if ((file = Open(fileName, MODE_NEWFILE)))
    {
        count = Write(file, (const APTR)text, fileSize);
        if (count != fileSize)
        {
            ShowError("Could not write file.");
        }
        Close(file);
    }
    else
    {
        ShowDosError();
        return 5;
    }

    return 0;
}

static void Usage()
{
    printf("\33[1mEncode to base64 or decode from base64.\33[0m\n");
    printf("Input from file, command line or standard input.\n");
    printf("Input is decoded with DECODE switch; otherwise encoded.\n");
    printf("Output is written to standard output or to file.\n\n");
    printf("Examples:\n");
    printf("  Base64 This is a test\n");
    printf("  Base64 < encoded_file > decoded_file\n");
    printf("  Base64 I=encoded_file O=decoded_file\n");
}

int main(void)
{
    struct RDArgs *rd;
    const unsigned char *text, *out;
    long textSize;
    int result = 0;

    rd = ReadArgs((CONST_STRPTR)temp, (LONG *)&args, NULL);
    if (!rd)
    {
        printf("%s\n", temp);
        return 1;
    }

    if (args.help)
    {
        Usage();
        return 0;
    }

    if (args.file)
    {
        text = ReadFile(args.file, &textSize);
    }
    else if (args.text)
    {
        textSize = strlen((const char *)args.text) + 1;
        text = AllocMem(textSize, 0L);
        strcpy((char *)text, (const char *)args.text);
        ShowSize("text size", textSize);
    }
    else
    {
        text = ReadInput(&textSize);
    }

    if (text != NULL)
    {
        if (args.decode)
        {
            out = b64_decode((const char *)text, textSize);
        }
        else
        {
            out = (const unsigned char *)b64_encode(text, textSize);
        }

        if (out != NULL)
        {
            args.decode = !args.decode;
            size_t outSize = strlen((const char *)out);

            if (args.out)
            {
                ShowSize("file size", outSize++);
                result = WriteFile(args.out, out, outSize);
            }
            else
            {
                ShowSize("text size", outSize);
                printf("%s\n", out);
            }
            free((void *)out);
        }
        else
        {
            result = 4;
        }

        FreeMem((void *)text, textSize);
    }
    else
    {
        result = 5;
    }

    FreeArgs(rd);
    return result;
}
