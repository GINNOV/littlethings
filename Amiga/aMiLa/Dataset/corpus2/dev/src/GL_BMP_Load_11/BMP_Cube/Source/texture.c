
texture_t *LoadTextureFile(char *filename)
{
	BITMAPINFOHEADER texInfo;
	texture_t *thisTexture;

	// allocate memory for the texture structure
	thisTexture = (texture_t*)malloc(sizeof(texture_t));
	if (thisTexture == NULL)
		return NULL;

	// load the texture data and check validity
	thisTexture->data = LoadBitmapFile(filename, &texInfo);
	if (thisTexture->data == NULL)
	{
		free(thisTexture);
		return NULL;
	}

	// set width and height info for this texture
	thisTexture->width = texInfo.biWidth;
	thisTexture->height = texInfo.biHeight;

	// generate the texture object for this texture
	glGenTextures(1, &thisTexture->texID);

	return thisTexture;
}
