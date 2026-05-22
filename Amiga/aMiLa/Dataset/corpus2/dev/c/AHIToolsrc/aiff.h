typedef struct {
	unsigned short	exponent;	// Exponent, bit #15 is sign bit for mantissa
	unsigned long	mantissa[2];	// 64 bit mantissa
} extended;

struct FileData {			// My private struct to store file header 
	char *name;
	int  mode;
	int  filefreq;
	int  codecfreq;
	int  stereo;
};

struct COMMch {		
	WORD channels;
	ULONG frames;
	WORD bits;
	extended rate;
	ULONG compr;
};