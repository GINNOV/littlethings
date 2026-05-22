#include <sge.h>

int run(int argc, char *argv[]) {
	char **files;
	int i;
	int nfiles=0;
	struct stat st;

	if (argc<4) {
		printf("usage: sga [encryptionkey] [target] [files] ...\n");
		exit(0);
	}

	if (stat(argv[2],&st)==0) {
		printf("file %s already exists\n\n", argv[2]);
		printf("to prevent accidently removement of important data files\nthough wrong parameter usage, this tool\nrefuses to overwrite archives. remove it first\n");
		exit(-1);
	}

	sgeInit(NOAUDIO, NOJOYSTICK);
	for (i=3;i<argc;i++) {
		if (strcmp(argv[i],argv[2])!=0) nfiles++;
	}
	sgeMalloc(files,char*,nfiles);
	for (i=3;i<argc;i++) {
		if (strcmp(argv[i],argv[2])!=0) files[i-3]=argv[i];
	}
	sgeCreateFile(argv[2], files,nfiles,argv[1]);
	sgeFree(files);
	return 0;
}
