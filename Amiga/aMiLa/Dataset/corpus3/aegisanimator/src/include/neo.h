struct neo_head
{
	unsigned int type;
	unsigned int Resolution;
	unsigned int colormap[16];
	unsigned char FileName[12];
	unsigned int AnimLimit;
	unsigned int AnimSpeedDir;
	unsigned int Steps;
	unsigned int xoff;
	unsigned int yoff;
	unsigned int width;
	unsigned int height;
	unsigned int Reserved[ 33 ];
};
