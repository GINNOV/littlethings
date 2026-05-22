
/*	load & save TGA file
 *
 *		written by Alexander Zaprjagaev
 *      modified for MiniGL by Hans-Joerg Frieden.
 */

#include <stdio.h>
#include <malloc.h>

unsigned char *load_tga(char *name,int *width,int *height, int *bpp) {
	unsigned char rep,*data,*buf,*ptr,info[18];
	int i,j,k,l,w,h,components,size;
	FILE *file = fopen(name,"rb");
	if(!file) return NULL;
	fread(&info,1,18,file);
	w = info[12] + info[13] * 256;
	h = info[14] + info[15] * 256;
	switch(info[16]) {
		case 32: components = 4; break;
		case 24: components = 3; break;
		default: fclose(file); return NULL;
	}
	size = w * h * components;
	buf = malloc(size);
	data = malloc(w * h * 4);
	if(!data || !buf) {
		fclose(file);
		return NULL;
	}
	fseek(file,info[0],SEEK_CUR);
	switch(info[2]) {
		case 2: fread(buf,1,size,file); break;
        case 10:
			i = 0;
			ptr = buf;
			while(i < size) {
				fread(&rep,1,1,file);
				if(rep & 0x80) {
					rep ^= 0x80;
					fread(ptr,1,components,file);
					ptr += components;
					for(j = 0; j < rep * components; j++) {
						*ptr = *(ptr - components);
						ptr ++;
					}
					i += components * (rep + 1);
				} else {
					k = components * (rep + 1);
					fread(ptr,1,k,file);
					ptr += k;
					i += k;
				}
			}
			break;
		default:
			fclose(file);
			free(buf);
			free(data);
			return NULL;
	}
	for(i = 0, j = 0; i < size; i += components, j += 4) {
		data[j] = buf[i + 2];
		data[j + 1] = buf[i + 1];
		data[j + 2] = buf[i];
		if(components == 4) data[j + 3] = buf[i + 3];
		else data[j + 3] = 255;
	}
	if(!(info[17] & 0x20))
		for(j = 0, k = w * 4; j < h / 2; j ++)
			for(i = 0; i < w * 4; i ++) {
				l = data[j * k + i];
				data[j * k + i] = data[(h - j - 1) * k + i];
				data[(h - j - 1) * k + i] = l;
			}
	fclose(file);
	free(buf);
	*width = w;
	*height = h;
	*bpp = components;
	return data;
}

int save_tga(char *name,unsigned char *data,int width,int height) {
	int i,j;
	unsigned char *buf;
	FILE *file = fopen(name,"wb");
	if(!file) return -1;
	buf = malloc(18 + width * height * 4);
	memset(buf,0,18);
	buf[2] = 2;
	buf[12] = width % 256;
	buf[13] = width / 256;
	buf[14] = height % 256;
	buf[15] = height / 256;
	buf[16] = 32;
	buf[17] = 0x28;
	memcpy(buf + 18,data,width * height * 4);
	for(i = 18; i < 18 + width * height * 4; i += 4) {
		j = buf[i];
		buf[i] = buf[i + 2];
		buf[i + 2] = j;
	}
	fwrite(buf,1,18 + width * height * 4,file);
	fclose(file);
	free(buf);
	return 0;
}

int gen_texture(char *name, int internalformat)
{
	int texnum;
	unsigned char *data;
	int w, h;
	int bpp;
	
	glGenTextures(1, &texnum);
	
	if (glGetError() != GL_NO_ERROR) return 0;
	if (texnum == 0) return 0;
	
	glBindTexture(GL_TEXTURE_2D, texnum);
	
	data = load_tga(name, &w, &h, &bpp);
	if (!data) 
	{
		glDeleteTextures(1, &texnum);
		return 0;
	}
	
	if (internalformat == 0)
	{
		if (bpp == 3) internalformat = GL_RGB;
		else          internalformat = GL_RGBA;
	}
	
	glTexImage2D(GL_TEXTURE_2D, 0, internalformat,
		w, h, 0, 
		bpp == 3 ? GL_RGB : GL_RBGA,
		GL_UNSIGNED_BYTE,
		data);
	free(data);
	
	if (glGetError() != GL_NO_ERROR) return 0;
	
	return texnum;
}