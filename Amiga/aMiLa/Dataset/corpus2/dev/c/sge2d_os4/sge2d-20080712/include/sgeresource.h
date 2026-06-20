#ifndef _SGERESOURCE_H
#define _SGERESOURCE_H

typedef struct {
	FILE *f;
	int numberOfFiles;
	char *archname;
	char **fileName;
	Uint32 *position;
	Uint32 *fileSize;
	char *encryptionkey;
} SGEFILE;

SGEFILE *sgeOpenFile(const char *filename, const char *encryptionkey);
void sgeCloseFile(SGEFILE *f);
void sgeEncryptBuffer(void *buffer, Uint32 length, const char *encryptionkey);
#define sgeDecryptBuffer sgeEncryptBuffer
void sgeCreateFile(const char *filename, char *filenames[], Uint32 numberOfFiles, const char *encryptionkey);
int sgeGetFileIndex(SGEFILE *f, const char *filename);
Uint32 sgeGetFileSize(SGEFILE *f, const char *filename);
void *sgeReadFile(SGEFILE *f, const char *filename);
SDL_Surface *sgeReadImage(SGEFILE *f, const char *filename);
SDL_Surface *sgeReadImageMemory(SGEFILE *f, const char *filename);
Mix_Chunk *sgeReadSound(SGEFILE *f, const char *filename);

#endif
