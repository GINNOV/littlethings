#include <sge.h>

#define SGEIMAGE_VIDEO 0
#define SGEIMAGE_MEMORY 1

static Uint32 sgeReadEncryptedUint32(FILE *f, const char *encryptionkey) {
	Uint32 ret;
	fread(&ret,1,sizeof(Uint32),f);
        sgeDecryptBuffer(&ret, sizeof(Uint32), encryptionkey);
	ret=sgeByteSwap32(ret);
	return ret;
}

static void sgeWriteEncryptedUint32(FILE *f, Uint32 value, const char *encryptionkey) {
	Uint32 tmp;
	tmp=sgeByteSwap32(value);
	sgeEncryptBuffer(&tmp, sizeof(Uint32), encryptionkey);
	fwrite(&tmp, 1, sizeof(Uint32), f);
}

SGEFILE *sgeOpenFile(const char *filename, const char *encryptionkey) {
	int i;
	SGEFILE *ret;
	Uint32 *namelens;
	Uint32 *namepos;
	char *namebuf=NULL;

	sgeNew(ret,SGEFILE);
	ret->f=fopen(filename,"rb");
	if (!ret->f) sgeBailOut("could not open file: %s\n",filename);

	ret->encryptionkey=strdup(encryptionkey);
	ret->archname=strdup(filename);

	fseek(ret->f, -sizeof(Uint32), SEEK_END);
	ret->numberOfFiles=sgeReadEncryptedUint32(ret->f, encryptionkey);

	sgeMalloc(namelens, Uint32, ret->numberOfFiles);
	sgeMalloc(namepos, Uint32, ret->numberOfFiles);

	sgeMalloc(ret->fileName,char *,ret->numberOfFiles);
	sgeMalloc(ret->position,Uint32,ret->numberOfFiles);
	sgeMalloc(ret->fileSize,Uint32,ret->numberOfFiles);

	fseek(ret->f, -(ret->numberOfFiles*sizeof(Uint32)*4+sizeof(Uint32)), SEEK_END);

	for (i=0;i<ret->numberOfFiles;i++) {
		namepos[i]=sgeReadEncryptedUint32(ret->f, encryptionkey);
		namelens[i]=sgeReadEncryptedUint32(ret->f, encryptionkey);
		ret->position[i]=sgeReadEncryptedUint32(ret->f, encryptionkey);
		ret->fileSize[i]=sgeReadEncryptedUint32(ret->f, encryptionkey);
	}

	for (i=0;i<ret->numberOfFiles;i++) {
		fseek(ret->f, namepos[i], SEEK_SET);
		if (namebuf!=NULL) sgeFree(namebuf);
		sgeMalloc(namebuf, char, namelens[i]+1);
		fread(namebuf, 1, namelens[i], ret->f);
		sgeDecryptBuffer(namebuf, namelens[i], encryptionkey);
		ret->fileName[i]=strdup(namebuf);
	}
	if (namebuf!=NULL) sgeFree(namebuf);

	sgeFree(namelens);
	sgeFree(namepos);
	rewind(ret->f);

	return ret;
}

void sgeCloseFile(SGEFILE *f) {
	int i;

	fclose(f->f);

	for (i=0;i<f->numberOfFiles;i++) {
		sgeFree(f->fileName[i]);
	}
	sgeFree(f->archname);
	sgeFree(f->fileName);
	sgeFree(f->position);
	sgeFree(f->fileSize);
	sgeFree(f->encryptionkey);

	sgeFree(f);
}

void sgeEncryptBuffer(void *buffer, Uint32 length, const char *encryptionkey) {
	int j;
	unsigned char *buf=buffer;
	Uint32 keylen=strlen(encryptionkey);
	for (j=0;j<length;j++) {
		buf[j]^=encryptionkey[j%(keylen+1)];
		j++;
	}
}

void sgeCreateFile(const char *filename, char *filenames[], Uint32 numberOfFiles, const char *encryptionkey) {
	int i;
	FILE *f,*d;
	struct stat st;
	Uint32 *fileSizes;
	Uint32 *filePositions;
	Uint32 *namePositions;
	char *buf=NULL;
	char *namebuf=NULL;

	f=fopen(filename,"wb");
	if (!f) sgeBailOut("cannot create %s\n", filename);

	sgeMalloc(fileSizes,Uint32,numberOfFiles);
	sgeMalloc(filePositions,Uint32,numberOfFiles);
	sgeMalloc(namePositions,Uint32,numberOfFiles);

	for (i=0;i<numberOfFiles;i++) {
		stat(filenames[i],&st);
		namePositions[i]=ftell(f);
		fileSizes[i]=st.st_size;

		if (namebuf==NULL) sgeFree(namebuf);
		sgeMalloc(namebuf,char,strlen(filenames[i])+1);
		namebuf=strdup(filenames[i]);
		sgeEncryptBuffer(namebuf, strlen(filenames[i]), encryptionkey);
		fwrite(namebuf, 1, strlen(filenames[i]), f);
		
		filePositions[i]=ftell(f);
		d=fopen(filenames[i],"rb");
		if (!d) sgeBailOut("cannot open %s\n", filenames[i]);

		sgeMalloc(buf,char,fileSizes[i]);
		fread(buf,1,fileSizes[i],d);
		sgeEncryptBuffer(buf, fileSizes[i], encryptionkey);
		fwrite(buf,1,fileSizes[i],f);
		sgeFree(buf);

		fclose(d);
	}
	if (namebuf==NULL) sgeFree(namebuf);

	for (i=0;i<numberOfFiles;i++) {
		sgeWriteEncryptedUint32(f, namePositions[i], encryptionkey);
		sgeWriteEncryptedUint32(f, strlen(filenames[i]), encryptionkey);
		sgeWriteEncryptedUint32(f, filePositions[i], encryptionkey);
		sgeWriteEncryptedUint32(f, fileSizes[i], encryptionkey);
	}
	sgeWriteEncryptedUint32(f, numberOfFiles, encryptionkey);
	fflush(f);
	fclose(f);

	sgeFree(fileSizes);
	sgeFree(filePositions);
	sgeFree(namePositions);
}

int sgeGetFileIndex(SGEFILE *f, const char *filename) {
	int i;
	for (i=0;i<f->numberOfFiles;i++) {
		if (strcmp(filename, f->fileName[i])==0) {
			return i;
		}
	}
	sgeBailOut("file not found: %s\n", filename);
}

Uint32 sgeGetFileSize(SGEFILE *f, const char *filename) {
	int i=sgeGetFileIndex(f, filename);
	return f->fileSize[i];
}

void *sgeReadFile(SGEFILE *f, const char *filename) {
	int i=sgeGetFileIndex(f, filename);
	unsigned char *ret;
	sgeMalloc(ret, unsigned char, f->fileSize[i]+1);
	fseek(f->f,f->position[i],SEEK_SET);
	if (fread(ret,1,f->fileSize[i],f->f)==0) {
		sgeBailOut("error reading %s from archive\n",filename);
	}
	sgeDecryptBuffer(ret, f->fileSize[i], f->encryptionkey);
	return (void *)ret;
}

static SDL_Surface *sgeReadImageHelper(SGEFILE *f, const char *filename, int type) {
	SDL_RWops  *rw;
	char *d=sgeReadFile(f,filename);
	SDL_Surface *s, *ret;

	rw=SDL_RWFromMem(d, sgeGetFileSize(f, filename));
	s=IMG_Load_RW(rw,0);
	if (s==NULL) sgeBailOut("reading image '%s' failed\n",filename);
	SDL_FreeRW(rw);
	sgeFree(d);

	if (type==SGEIMAGE_MEMORY) {
		return s;
	}

	ret=SDL_DisplayFormatAlpha(s);
	if (ret!=NULL) {
		SDL_FreeSurface(s);
		return ret;
	}

	return s;
}

SDL_Surface *sgeReadImage(SGEFILE *f, const char *filename) {
	return sgeReadImageHelper(f, filename, SGEIMAGE_VIDEO);
}

SDL_Surface *sgeReadImageMemory(SGEFILE *f, const char *filename) {
	return sgeReadImageHelper(f, filename, SGEIMAGE_MEMORY);
}

Mix_Chunk *sgeReadSound(SGEFILE *f, const char *filename) {
	SDL_RWops  *rw;
	char *d=sgeReadFile(f,filename);
	Mix_Chunk *s;

	rw=SDL_RWFromMem(d, sgeGetFileSize(f, filename));
	s=Mix_LoadWAV_RW(rw,0);
	if (s==NULL) sgeBailOut("reading sound '%s' failed\n",filename);
	SDL_FreeRW(rw);
	sgeFree(d);
	return s;
}
