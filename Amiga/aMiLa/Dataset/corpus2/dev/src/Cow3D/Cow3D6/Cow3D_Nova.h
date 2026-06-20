void WarpBmFmtToName(UBYTE *name, ULONG WarpBmFmt);
ULONG SetBlendMode();
ULONG BmToWarpBmFmt(ULONG BmFmt);
void CheckBlendModes(void);
void FreeData(void);

/*==================================================================*/
struct Shader3D{
W3DN_Shader *vertShader;
W3DN_Shader *fragShader;
W3DN_ShaderPipeline *shaderPipeline;
};
/*==================================================================*/
struct Field3D{		
ULONG id;
ULONG attrib;
ULONG size;
ULONG offset;
ULONG count;
ULONG format;	
UBYTE name[40];
};
/*==================================================================*/
// GL_REPLACE	rgbCol = texel.rgb;												a = texel.a;
// GL_MODULATE	rgbCol = texel.rgb * Colour.rgb;								a = texel.a * Colour.a;
// GL_BLEND		rgbCol = Colour.rgb*(1.0-texel.rgb) + EnvColor.rgb*texel.rgb;	a = Colour.a * texel.a;
// GL_DECAL		rgbCol = Colour.rgb*(1.0-texel.a)   + texel.rgb*texel.a;		a = Colour.a;
/*==================================================================*/
struct Shader3D myshader2dR;
struct Shader3D myshader3dR;
struct Shader3D myshader2dM;
struct Shader3D myshader3dM;
struct Shader3D myshader2dB;
struct Shader3D myshader3dB;
struct Shader3D myshader2dD;
struct Shader3D myshader3dD;
/*==================================================================*/
static const char *pixFmtNames[] = {
		"W3DNPF_DEPTH",
		"W3DNPF_DEPTH_STENCIL",
		"W3DNPF_RED",
		"W3DNPF_RG",
		"W3DNPF_RGB",
		"W3DNPF_RGBA",
		"W3DNPF_SRGB8",
		"W3DNPF_SRGB8_A8"
	};
/*==================================================================*/
static const char *elementFmtNames[] = {
		"W3DNEF_UINT8",
		"W3DNEF_SINT8",
		"W3DNEF_UINT16",
		"W3DNEF_SINT16",
		"W3DNEF_UINT32",
		"W3DNEF_SINT32",
		"W3DNEF_FLOAT",
		"W3DNEF_UINT8_3_3_2",
		"W3DNEF_UINT8_2_3_3_REV",
		"W3DNEF_UINT16_5_6_5",
		"W3DNEF_UINT16_4_4_4_4",
		"W3DNEF_UINT16_5_5_5_1",
		"W3DNEF_UINT16_1_5_5_5_REV",
		"W3DNEF_UINT32_10_10_10_2",
		"W3DNEF_UINT32_2_10_10_10_REV"
	};
/*==================================================================*/
static const char *pixFNames[] = {
		"PIXF_NONE",
		"PIXF_CLUT",
		"PIXF_R8G8B8",
		"PIXF_B8G8R8",
		"PIXF_R5G6B5PC",
		"PIXF_R5G5B5PC",
		"PIXF_A8R8G8B8",
		"PIXF_A8B8G8R8",
		"PIXF_R8G8B8A8",
		"PIXF_B8G8R8A8",
		"PIXF_R5G6B5",
		"PIXF_R5G5B5",
		"PIXF_B5G6R5PC",
		"PIXF_B5G5R5PC",
		"PIXF_YUV422CGX",
		"PIXF_YUV411",
		"PIXF_YUV422PA",
		"PIXF_YUV422",
		"PIXF_YUV422PC",
		"PIXF_YUV420P",
		"PIXF_YUV410P",
		"PIXF_ALPHA8",
	};	
/*==================================================================*/
ULONG NovaBlend(ULONG op)
{

	if(op==W3D_CONSTANT_ALPHA)				{op=W3DN_CONSTANT_ALPHA;return(op);}
	if(op==W3D_CONSTANT_COLOR)				{op=W3DN_CONSTANT_COLOUR;return(op);}
	if(op==W3D_DST_ALPHA)					{op=W3DN_DST_ALPHA;return(op);}
	if(op==W3D_DST_COLOR)					{op=W3DN_DST_COLOUR;return(op);}
	if(op==W3D_ONE)							{op=W3DN_ONE;return(op);}
	if(op==W3D_ONE_MINUS_CONSTANT_ALPHA)	{op=W3DN_ONE_MINUS_CONSTANT_ALPHA;return(op);}
	if(op==W3D_ONE_MINUS_CONSTANT_COLOR)	{op=W3DN_ONE_MINUS_CONSTANT_COLOUR;return(op);}
	if(op==W3D_ONE_MINUS_DST_ALPHA)			{op=W3DN_ONE_MINUS_DST_ALPHA;return(op);}
	if(op==W3D_ONE_MINUS_DST_COLOR)			{op=W3DN_ONE_MINUS_DST_COLOUR;return(op);}
	if(op==W3D_ONE_MINUS_SRC_ALPHA)			{op=W3DN_ONE_MINUS_SRC_ALPHA;return(op);}
	if(op==W3D_ONE_MINUS_SRC_COLOR)			{op=W3DN_ONE_MINUS_SRC_COLOUR;return(op);}
	if(op==W3D_SRC_ALPHA)					{op=W3DN_SRC_ALPHA;return(op);}
	if(op==W3D_SRC_ALPHA_SATURATE)			{op=W3DN_SRC_ALPHA_SATURATE;return(op);}
	if(op==W3D_SRC_COLOR)					{op=W3DN_SRC_COLOUR;return(op);}
	if(op==W3D_ZERO) 						{op=W3DN_ZERO;return(op);}

	return(0);	
}	
/*==================================================================*/
#define NCHECK(ret,func) { if(!ret) {printf(#func " error:%ld %s\n",C.error,W3DN_GetErrorString(C.error)); goto panic;} else { if(debug) printf(#func " " #ret ":OK\n");}}
#define NERROR(func) { if(C.error!=0) {printf(#func " error:%ld %s\n",C.error,W3DN_GetErrorString(C.error)); goto panic;} else { if(debug) printf(#func " err:OK\n");}}
#define NCHECKLOG 	{ if(C.shaderLog) {if(C.alwaysShowLog) printf("Log:\n%s\n", C.shaderLog); C.ncontext->DestroyShaderLog(C.shaderLog); C.shaderLog=NULL;} else { if(debug) printf("shaderLog OK\n");}}
/*==================================================================*/
BOOL ObjectToVboNova(struct object3D *O)
{
	ULONG Anb=3+1;
	ULONG Asize = O->Pnb * sizeof(NOVAPOINT) + O->PInb * sizeof(ULONG);

	O->vbo = C.ncontext->CreateVertexBufferObject(&C.error, Asize, W3DN_STATIC_DRAW, Anb, TAG_DONE);
	NCHECK(O->vbo,CreateVertexBufferObject);
	NERROR(CreateVertexBufferObject)
	
	// Set the VBO's layout
	NOVAPOINT *point = NULL;
	O->Vid  = 0;
	O->Nid  = 1;
	O->UVid = 2;
//	O->Cid  = 3;

	O->PIid = 3;
//	O->PIid = 4;

	uint32 Vcount		= sizeof(point->position)	/ sizeof(point->position.x);
	uint32 Ncount 		= sizeof(point->normal)		/ sizeof(point->normal.x);
	uint32 UVcount		= sizeof(point->texCoord)	/ sizeof(point->texCoord.x);
//	uint32 Ccount		= sizeof(point->color)		/ sizeof(point->color.x);

	uint32 Voffset 		= offsetof(NOVAPOINT, position);
	uint32 Noffset		= offsetof(NOVAPOINT, normal);
	uint32 UVoffset		= offsetof(NOVAPOINT, texCoord);	
//	uint32 Coffset		= offsetof(NOVAPOINT, color);	

	uint32 Psize		= sizeof(NOVAPOINT);
	uint32 PIsize		= sizeof(ULONG);
	uint32 PIoffset		= O->Pnb * Psize;

	strcpy(O->Vname ,"vertPosition");
	strcpy(O->Nname ,"vertNormal");
	strcpy(O->UVname,"vertTexCoord");
//	strcpy(O->Cname ,"vertColor");

	C.ncontext->VBOSetArray(O->vbo, O->Vid, W3DNEF_FLOAT, FALSE, Vcount, Psize, Voffset, O->Pnb);
	C.ncontext->VBOSetArray(O->vbo, O->Nid,	W3DNEF_FLOAT, FALSE, Ncount, Psize, Noffset, O->Pnb);
	C.ncontext->VBOSetArray(O->vbo, O->UVid,W3DNEF_FLOAT, FALSE, UVcount,Psize, UVoffset,O->Pnb);
//	C.ncontext->VBOSetArray(O->vbo, O->Cid ,W3DNEF_FLOAT, FALSE, Ccount,Psize,  Coffset, O->Pnb);

	C.ncontext->VBOSetArray(O->vbo, O->PIid,W3DNEF_UINT32, FALSE, 1, PIsize, PIoffset, O->PInb);

	/* not known yet */
	O->Vattrib=0;
	O->Nattrib=0;
	O->UVattrib=0;
	O->Cattrib=0;

	// Generate the vertices
	W3DN_BufferLock *bufferLock = C.ncontext->VBOLock(&C.error, O->vbo, 0, 0);
	NCHECK(bufferLock,VBOLock);
	NERROR(VBOLock)

 	APTR NP  = (NOVAPOINT*)bufferLock->buffer;
	memcpy(NP,O->P,O->Pnb*sizeof(NOVAPOINT));
	
 	APTR NPI = (uint32*)((uint8*)bufferLock->buffer + PIoffset);
	memcpy(NPI,O->PI,O->PInb*sizeof(ULONG));

	C.ncontext->BufferUnlock(bufferLock, 0, bufferLock->size);
	
	return(TRUE);
panic:
	REM(panic!!!)
	return(FALSE);
}
/*======================================================================*/
BOOL DoViewNova(void)
{
VertexShaderData *shaderData;
kmVec3 rotAxis  = {0.0f, 1.0f, 0.0};
kmMat4 rotMatrix;
kmMat4 mvMatrix;
kmMat4 tempMatrix; // Needed for intermediate results
float rot=0;
ULONG i;

// - Animate the cube -
	rot=C.RotY;
	rot=2*3.1416*rot/360.0;
	
// Now rotate the cube
	kmMat4RotationAxisAngle(&rotMatrix, &rotAxis,  rot);
	kmMat4Multiply(&C.modelMatrix, &rotMatrix, &C.modelMatrix);
	
// Build the MVP matrix
	kmMat4Multiply(&mvMatrix, &C.viewMatrix, &C.modelMatrix);
	kmMat4Multiply(&C.View.mvpMatrix, &C.projectionMatrix, &mvMatrix);
	
// Calc. the normal matrix (the inverse transpose of the Model-View (MV) matrix
	kmMat4Inverse(&tempMatrix, &mvMatrix);
	kmMat4Transpose(&C.View.normalMatrix, &tempMatrix); 
	
// Writing matrices & light data to the DBO
	W3DN_BufferLock *bufferLock = C.ncontext->DBOLock(&C.error, C.dbo, 0, 0);
	NCHECK(bufferLock,DBOLock);
	NERROR(DBOLock)

	shaderData = (VertexShaderData*)bufferLock->buffer;
	shaderData->mvpMatrix		= C.View.mvpMatrix;
	shaderData->normalMatrix	= C.View.normalMatrix;
	shaderData->lightPos 		= C.View.lightPos;

	// NOTE: all is modified
	C.ncontext->BufferUnlock(bufferLock, 0, bufferLock->size);;

	return(TRUE);
panic:
	REM(panic!!!)
	return(FALSE);
}
/*==================================================================*/
BOOL DrawEleNova(void* vbo,ULONG PIid,ULONG PInb,ULONG primitive,W3DN_Texture *ntexture)
{
ULONG submitID;

REM(DrawEleNova)
	C.ncontext->DrawElements(NULL,primitive, 0, PInb, vbo, PIid);	/* for primitive Warp3D = Nova */
	REM(DrawElements)
VAR(primitive)
VAR(PInb)
VAR(vbo)
VAR(PIid)		
	submitID=C.ncontext->Submit(&C.error);
	NCHECK(submitID,Submit);
	NERROR(Submit)
	
	return(TRUE);
panic:
	REM(panic!!!)
	return(FALSE);
}
/*==================================================================*/
BOOL DrawPoiNova(void* vbo,ULONG PIid,ULONG PInb,W3DN_Texture *ntexture)
{
ULONG submitID;
	
	C.ncontext->DrawElements(NULL,W3D_PRIMITIVE_POINTS, 0, PInb, vbo, PIid);	/* for primitive Warp3D = Nova */
	REM(DrawElements)
		
	submitID=C.ncontext->Submit(&C.error);
	NCHECK(submitID,Submit);
	NERROR(Submit)
	
	return(TRUE);
panic:
	REM(panic!!!)
	return(FALSE);
}
/*==================================================================*/
BOOL DrawObjectNova(struct object3D *O)
{
ULONG n,nb,rest;
APTR vertshader;
	
REM(DrawObjectNova)
	
	
	if(C.Use2D)
		vertshader=myshader2dR.vertShader;
	else
		vertshader=myshader3dR.vertShader;	

	if(O->Vattrib==0)
	if(O->Nattrib==0)
	if(O->UVattrib==0)
	{		
	O->Vattrib = C.ncontext->ShaderGetOffset(&C.error, vertshader, W3DNSOT_INPUT, O->Vname);	
	O->Nattrib = C.ncontext->ShaderGetOffset(&C.error, vertshader, W3DNSOT_INPUT, O->Nname);	
	O->UVattrib= C.ncontext->ShaderGetOffset(&C.error, vertshader, W3DNSOT_INPUT, O->UVname);	
//	O->Cattrib = C.ncontext->ShaderGetOffset(&C.error, vertshader, W3DNSOT_INPUT, O->Cname);	
	}
	
	C.ncontext->BindVertexAttribArray(NULL, O->Vid, O->vbo, O->Vattrib);
	C.ncontext->BindVertexAttribArray(NULL, O->Nid, O->vbo, O->Nattrib);
	C.ncontext->BindVertexAttribArray(NULL, O->UVid,O->vbo, O->UVattrib);
//	C.ncontext->BindVertexAttribArray(NULL, O->Cid, O->vbo, O->Cattrib);

	C.error = C.ncontext->BindTexture(NULL, 0, O->ntexture, C.texSampler);
	NERROR(BindTexture);

	if(C.drawmode=='t')
		{DrawEleNova(O->vbo,O->PIid,O->PInb,W3D_PRIMITIVE_TRIANGLES,O->ntexture);return(TRUE);}
	if(C.drawmode=='p')
		{DrawPoiNova(O->vbo,O->PIid,O->PInb,O->ntexture);return(TRUE);}
	if(C.drawmode=='l')
		{return;}
	if(C.drawmode=='e')
		{DrawEleNova(O->vbo,O->PIid,O->PInb,W3D_PRIMITIVE_TRIANGLES,O->ntexture);return(TRUE);}
	
	return(TRUE);
panic:
	REM(panic!!!)
	return(FALSE);
}
/*=================================================================*/
void ReadIncludedObjectNova(struct object3D *O,float *V,ULONG *i,float resize)
{
NOVAPOINT *NP = NULL;
ULONG n;
float x,y,z,u,v;


	NLOOP(O->PInb)
		O->PI[n]=i[n];

	NP=O->P;
	NLOOP(O->Pnb)
	{
	u=V[0]; v=V[1]; x=V[2]; y=V[3]; z=V[4]; 
	NP->position.x		=resize*x;
	if(resize==1.0) 
		y=-y; 
	else 
		z=-z;
	NP->position.y		=resize*y;
	NP->position.z		=resize*z;
//	NP->normal.x		=nx;
//	NP->normal.y		=ny;
//	NP->normal.z		=nz;
	NP->texCoord.x	=u;
	NP->texCoord.y	=v;
	NP++; 
	V=V+5;
	}

}
/*=================================================================*/
BOOL DoTextureNova(struct object3D *O,APTR pixels,UWORD texw,UWORD texh,UWORD bits)
{
ULONG bytesPerRow = texw * 32/8;

VAR(	texw)
VAR(	texh)
VAR(bits)
VAR(pixels)
VAR(O)

	O->ntexture = C.ncontext->CreateTexture(&C.error, W3DN_TEXTURE_2D,W3DNPF_RGBA, W3DNEF_UINT8,texw,texh,1,FALSE,W3DN_STATIC_DRAW);
	NCHECK(O->ntexture,CreateTexture);
	NERROR(CreateTexture)

	C.error = C.ncontext->TexUpdateImage(O->ntexture, pixels, 0, 0, bytesPerRow, 0);
	NERROR(TexUpdateImage);
		
	C.ncontext->TexSetParametersTags(O->ntexture, 
			W3DN_TEXTURE_SWIZZLE_R, W3DN_SWIZZLE_RED,
			W3DN_TEXTURE_SWIZZLE_G, W3DN_SWIZZLE_GREEN,
			W3DN_TEXTURE_SWIZZLE_B, W3DN_SWIZZLE_BLUE,
			W3DN_TEXTURE_SWIZZLE_A, W3DN_SWIZZLE_ALPHA, TAG_DONE);
		
	C.texSampler = C.ncontext->CreateTexSampler(&C.error);
	NCHECK(C.texSampler,CreateTexSampler);
	NERROR(CreateTexSampler);

	C.error = C.ncontext->TSSetParametersTags(C.texSampler, 
		W3DN_TEXTURE_WRAP_S, 	W3DN_REPEAT,
		W3DN_TEXTURE_WRAP_T, 	W3DN_REPEAT,
		W3DN_TEXTURE_MIN_FILTER,W3DN_LINEAR,
		W3DN_TEXTURE_MAG_FILTER,W3DN_LINEAR,
		TAG_DONE);
	NERROR(TSSetParametersTags);
	
	C.error = C.ncontext->BindTexture(NULL, 0, O->ntexture, C.texSampler);
	NERROR(BindTexture);

	return(TRUE);
panic:
	REM(panic!!!)
	return(FALSE);
}
/*=================================================================*/
void SwitchDisplayNova(void)
{
ULONG n;

/* Wait for the VBlank period is a quick-n'-dirty way of limiting the frame-rate to monitor's rate */

	NLOOP(C.FrameLimit)
		WaitBOVP(&(C.window->WScreen->ViewPort));

	BltBitMapRastPort(C.bufferbm,0,0,C.window->RPort,0,0,C.DisplayW,C.DisplayH,0xC0);	/* copy the "back buffer" to the window */

	// Clear the screen
	C.ncontext->Clear(NULL, C.opaqueBlack, &C.clearDepth, NULL);	
}
/*==================================================================*/
void QueryDriverNova(ULONG query)
{
#define NQUERY(query,txt) 	printf(txt ":%ld\n", (ULONG)W3DN_Query(C.gpu,query));

 
	NQUERY(W3DN_Q_ANISOTROPICFILTER,"anisotropic filtering supported")	   
	NQUERY(W3DN_Q_BITMAPASTEXTURE,"bitmap-as-texture supported ")	   
	NQUERY(W3DN_Q_DEPTHTEXTURE,"depth-textures supported")	   
	NQUERY(W3DN_Q_MAXANISOTROPY,"max. level of anisotropy supported")	   
	NQUERY(W3DN_Q_MAXCOLOURBUFFERS,"max. number of colour buffers that can be rendered to at once")	   
	NQUERY(W3DN_Q_MAXRENDERHEIGHT,"max. bitmap height that can be rendered to")	   
	NQUERY(W3DN_Q_MAXRENDERWIDTH,"max. bitmap width  that can be rendered to")	   
	NQUERY(W3DN_Q_MAXTEXDEPTH,"max. texture depth if support 3d texture")	   
	NQUERY(W3DN_Q_MAXTEXHEIGHT,"max. texture height")	   
	NQUERY(W3DN_Q_MAXTEXUNITS,"max. number of texture units")	   
	NQUERY(W3DN_Q_MAXTEXWIDTH,"max. texture width")	   
	NQUERY(W3DN_Q_MAXVERTEXATTRIBS,"max. number of vertex attribute arrays that can be used")	   
	NQUERY(W3DN_Q_MIPMAPGENERATION,"mipmap generation supported")	   
	NQUERY(W3DN_Q_MIPMAPPING,"mipmapping supported")	   
	NQUERY(W3DN_Q_NPOT_MIPMAPPING,"textures with Non-Power-Of-Two")	   
	NQUERY(W3DN_Q_RENDERTOTEXTURE,"render-to-texture supported")	   
	NQUERY(W3DN_Q_STENCIL,"stencil buffering supported")	   
	NQUERY(W3DN_Q_TEXTURE_1D,"1D textures supported")	   
	NQUERY(W3DN_Q_TEXTURE_3D,"3D textures supported")	   
	NQUERY(W3DN_Q_TEXTURE_CUBEMAP,"cube-map textures supported")	   
	NQUERY(W3DN_Q_VERTEX_TEXTUREFETCH,"vertex shaders access textures")		
	
}
/*==================================================================*/
void QueryStateNova(ULONG state)
{
UBYTE statename[50];

	statename[0]=0;
	if(state==W3DN_DEPTHTEST)		strcpy(statename,"W3DN_DEPTHTEST");
	if(state==W3DN_DEPTHWRITE)		strcpy(statename,"W3DN_DEPTHWRITE");
	if(state==W3DN_STENCILTEST)		strcpy(statename,"W3DN_STENCILTEST");
	if(state==W3DN_CULLFRONT)		strcpy(statename,"W3DN_CULLFRONT");
	if(state==W3DN_CULLBACK)		strcpy(statename,"W3DN_CULLBACK");
	if(state==W3DN_BLEND)			strcpy(statename,"W3DN_BLEND");

	if(statename[0]==0) return;
	C.result=C.ncontext->GetState(NULL,state);
	REM(GetState)
	if(C.result == W3DN_ENABLED) printf(" [x]"); else printf(" [ ]");
	printf(" %s\n",&statename[5]);
}
/*==================================================================*/
ULONG BmToNovaPixF(ULONG BmFmt)
{
ULONG PixFmt=0;

	if(BmFmt==PIXFMT_LUT8)		PixFmt=PIXF_CLUT;
	if(BmFmt==PIXFMT_RGB15)		PixFmt=PIXF_R5G5B5;
//	if(BmFmt==PIXFMT_BGR15)		PixFmt=PIXF_B5G5R5;
	if(BmFmt==PIXFMT_RGB15PC)	PixFmt=PIXF_R5G5B5PC;
	if(BmFmt==PIXFMT_BGR15PC)	PixFmt=PIXF_B5G5R5PC;
	if(BmFmt==PIXFMT_RGB16)		PixFmt=PIXF_R5G6B5;
//	if(BmFmt==PIXFMT_BGR16)		PixFmt=PIXF_B5G6R5;
	if(BmFmt==PIXFMT_RGB16PC)	PixFmt=PIXF_R5G6B5PC;
	if(BmFmt==PIXFMT_BGR16PC)	PixFmt=PIXF_B5G6R5PC;
	if(BmFmt==PIXFMT_RGB24)		PixFmt=PIXF_R8G8B8;
	if(BmFmt==PIXFMT_BGR24)		PixFmt=PIXF_B8G8R8;
	if(BmFmt==PIXFMT_ARGB32)	PixFmt=PIXF_A8R8G8B8;
	if(BmFmt==PIXFMT_BGRA32)	PixFmt=PIXF_B8G8R8A8;
	if(BmFmt==PIXFMT_RGBA32)	PixFmt=PIXF_R8G8B8A8;
	return(PixFmt);
}
/*==================================================================*/
void QueryTexNova(ULONG PixFmt,ULONG EleFmt)
{
UBYTE name[256];
BOOL usable;
ULONG size;	

#define  NQUERYTEX(query) {strcpy(name,#query);C.error=W3DN_GetTexFmtInfoTags(C.gpu,PixFmt,EleFmt,query,&usable,TAG_DONE); if(C.error == W3DNEC_SUCCESS) printf("%s:[%ld], ",&name[11],usable); else printf("%s:[_], ",&name[11]);}

#define  NSIZETEX(query) {strcpy(name,#query);C.error=W3DN_GetTexFmtInfoTags(C.gpu,PixFmt,EleFmt,query,&size,TAG_DONE); if(C.error == W3DNEC_SUCCESS) printf("%s:[%ld pixels], ",&name[11],size); else printf("%s:[_], ",&name[11]);}
	
	printf("Tex format %s/%s(%ld/%ld):\t\t", pixFmtNames[PixFmt], elementFmtNames[EleFmt],PixFmt,EleFmt);
	NQUERYTEX(W3DNFmtTag_CanBeTexture)	   
	NQUERYTEX(W3DNFmtTag_NativeTexture )	   
	NQUERYTEX(W3DNFmtTag_CanBeRenderTarget)	   
	NSIZETEX(W3DNFmtTag_MaxTexHeight)	   
	NSIZETEX(W3DNFmtTag_MaxTexWidth)      
	printf("\n");
}
/*==================================================================*/
void QueryBmNova(ULONG PixF)
{
UBYTE name[256];
BOOL usable;
ULONG size;	

#define  NQUERYBM(query) {strcpy(name,#query);C.error=W3DN_GetBMFmtInfoTags(C.gpu,PixF,query,&usable,TAG_DONE); if(C.error == W3DNEC_SUCCESS) printf("%s:[%ld], ",&name[11],usable); else printf("%s:[_], ",&name[11]);}

#define  NSIZEBM(query) {strcpy(name,#query);C.error=W3DN_GetBMFmtInfoTags(C.gpu,PixF,query,&size,TAG_DONE); if(C.error == W3DNEC_SUCCESS) printf("%s:[%ld pixels], ",&name[11],size); else printf("%s:[_], ",&name[11]);}
	
	printf("Bm format %s(%ld):\t\t", pixFNames[PixF],PixF);
	NQUERYBM(W3DNFmtTag_CanBeTexture)	   
	NQUERYBM(W3DNFmtTag_NativeTexture )	   
	NQUERYBM(W3DNFmtTag_CanBeRenderTarget)	   
	NSIZEBM(W3DNFmtTag_MaxRenderHeight)	   
	NSIZEBM(W3DNFmtTag_MaxRenderWidth)	      
	printf("\n");
}	
/*==================================================================*/
ULONG SetBlendModeNova(void)
{

	if(C.SrcFunc==0)
	if(C.DstFunc==0)
		return(W3D_ILLEGALINPUT);

	if((C.SrcFunc==W3D_ZERO) && (C.DstFunc==W3D_ZERO))	/* skip this special value that is used in Wazp3D */
		{
//		W3D_SetState(C.wcontext, W3D_TEXMAPPING,W3D_DISABLE);
		return(W3D_SUCCESS);
		}
	
	C.error=C.ncontext->SetBlendMode(NULL,0,NovaBlend(C.SrcFunc),NovaBlend(C.DstFunc));

	if(C.error==0)
		return(W3D_SUCCESS);
	else
		return(W3D_ILLEGALINPUT);
}
/*==================================================================*/
BOOL CheckNova(void)
{
ULONG TexFmt,BmFmt,state,query,m,n,DriversNb;
UBYTE BmName[50];
ULONG CurrentBmFmt;
ULONG CurrentTexFmt;
W3DN_ElementFormat EleFmt;
W3DN_PixelFormat PixF;
APTR gpus;


	printf("CheckNova:\n");
	printf("============================================================\n");

/* recover current bitmap's BmFmt */
	CurrentBmFmt=GetCyberMapAttr(C.bufferbm,CYBRMATTR_PIXFMT);
	PixF=BmToNovaPixF(CurrentBmFmt);
	
	printf("Current bitmap's destformat is %s (BmFmt:%ld PixF:%ld)\n",pixFNames[PixF],CurrentBmFmt,PixF);
	printf("============================================================\n");

	gpus = W3DN_GetGPUsList(&C.error, TAG_DONE);
	NCHECK(gpus,W3DN_GetGPUsList)
	NERROR(W3DN_GetGPUsList)
	C.gpu=gpus;
	DriversNb=0;
	printf("============================================================\n");
	while (C.gpu)
	{
	printf("GPU%ld: %s (%s)\n", (ULONG)C.gpu->boardNum, C.gpu->name, C.gpu->libName);
	DriversNb++;
	C.gpu = C.gpu->next;	
	}
	printf("%d Driver(s) installed\n",DriversNb);
	printf("============================================================\n");
	if(DriversNb>1) printf("WARNING: You have %d Nova drivers installed !!!\n",DriversNb);

	C.gpu=gpus;
	printf("============================================================\n");
	while (C.gpu)
	{
	printf("GPU%ld: %s (%s)\n", (ULONG)C.gpu->boardNum, C.gpu->name, C.gpu->libName);	
	QueryDriverNova(n);
	printf("============================================================\n");
	printf("Query all for all bitmaps destformat\n");
	MLOOP(21)
		{
		PixF=m+1;	
		QueryBmNova(PixF);
		}

	printf("============================================================\n");
	PixF=BmToNovaPixF(CurrentBmFmt);
	printf("Query all for the current bitmap's destformat is %s (BmFmt:%ld PixF:%ld)\n",pixFNames[PixF],CurrentBmFmt,PixF);
	QueryBmNova(PixF);
	
		
	printf("============================================================\n");
	printf("Query all for all Textures formats: \n");
	NLOOP(15)
	MLOOP(8)
		{
		PixF  =m;
		EleFmt=n;	
		QueryTexNova(PixF,EleFmt);
		}
		
	C.gpu = C.gpu->next;		
	printf("============================================================\n");
	}
	
/* Values for currently selected  driver */
	C.gpu=gpus;
	printf("============================================================\n");
	printf("Values for this gpu \n");
	printf("State default values:\n");
	NLOOP(6)
		{
		state=n;	
		QueryStateNova(state);
		}

	CheckBlendModes();

	return(TRUE);
panic: 
	REM(panic!!!)
	return(FALSE);
}
/*=================================================================*/
void SetStatesNova(struct object3D *O)
{
float w,h;

REM(SetStatesNova)	
	if(C.Use2D)
		{
		C.ncontext->SetViewport(NULL, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0);			/* disabling clipping and using the special 2D mode */
		if(C.TexEnvMode==W3D_REPLACE)	C.ncontext->SetShaderPipeline(NULL, myshader2dR.shaderPipeline);
		if(C.TexEnvMode==W3D_DECAL)		C.ncontext->SetShaderPipeline(NULL, myshader2dD.shaderPipeline);
		if(C.TexEnvMode==W3D_MODULATE)	C.ncontext->SetShaderPipeline(NULL, myshader2dM.shaderPipeline);
		if(C.TexEnvMode==W3D_BLEND)		C.ncontext->SetShaderPipeline(NULL, myshader2dB.shaderPipeline);			
		}	
	else
		{
		w=C.DisplayW; h=C.DisplayH;
		C.ncontext->SetViewport(NULL, 0.0, h, w, -h, 0.0, 1.0);
		if(C.TexEnvMode==W3D_REPLACE)	C.ncontext->SetShaderPipeline(NULL, myshader3dR.shaderPipeline);
		if(C.TexEnvMode==W3D_DECAL)		C.ncontext->SetShaderPipeline(NULL, myshader3dD.shaderPipeline);
		if(C.TexEnvMode==W3D_MODULATE)	C.ncontext->SetShaderPipeline(NULL, myshader3dM.shaderPipeline);
		if(C.TexEnvMode==W3D_BLEND)		C.ncontext->SetShaderPipeline(NULL, myshader3dB.shaderPipeline);
		}
		
	C.ncontext->SetDepthCompareFunc(NULL, C.Zmode);			/* for Zmode Warp3D = Nova */
	C.ncontext->SetFrontFace(NULL, W3DN_FACE_CCW);

	C.ncontext->SetState(NULL, W3DN_BLEND,   	C.IsBlended);
	C.ncontext->SetState(NULL, W3DN_CULLBACK,   C.HideFace);
	C.ncontext->SetState(NULL, W3DN_DEPTHTEST,  C.Zbuffer);
	C.ncontext->SetState(NULL, W3DN_DEPTHWRITE, C.zupdate);
	
	SetBlendModeNova();
//	W3D_SetTexEnv(C.wcontext,O->ntexture,C.texenvmode,&envcolor1);
	
	C.error = C.ncontext->BindTexture(NULL, 0, O->ntexture, C.texSampler);
	NERROR(BindTexture);
	
	return;
panic:
	REM(SetStatesNova:fail)		
}
/*==========================================================================*/
BOOL DoShaderNova(struct Shader3D *S,UBYTE* vertname,UBYTE* fragname)
{
	// Create the shaders
	C.alwaysShowLog = FALSE;
	
	S->vertShader = C.ncontext->CompileShaderTags(&C.error,W3DNTag_FileName,vertname,W3DNTag_Log, &C.shaderLog, W3DNTag_LogLevel,W3DNLL_DEBUG, TAG_DONE);
	NCHECK(S->vertShader,CompileShaderTags);
	NCHECKLOG
	NERROR(CompileShaderTags)

	S->fragShader = C.ncontext->CompileShaderTags(&C.error,W3DNTag_FileName,fragname,W3DNTag_Log, &C.shaderLog, W3DNTag_LogLevel,W3DNLL_DEBUG, TAG_DONE);
	NCHECK(S->fragShader,CompileShaderTags);
	NCHECKLOG
	NERROR(CompileShaderTags)	
	
	// Create the shader pipelines
	S->shaderPipeline = C.ncontext->CreateShaderPipelineTags(&C.error,W3DNTag_Shader, S->vertShader, W3DNTag_Shader, S->fragShader, TAG_DONE);
	NCHECK(S->shaderPipeline,CreateShaderPipelineTags);
	NERROR(CreateShaderPipelineTags)	

	// Bind it as the shader to use
	C.ncontext->SetShaderPipeline(NULL, S->shaderPipeline);
	REM(SetShaderPipeline)
	
	return(TRUE);
panic: 
	REM(panic!!!)
	return(FALSE);
}
/*==========================================================================*/
void DeleteShaderNova(struct Shader3D *S)
{
	if(S->fragShader) 		{C.ncontext->DestroyShader(S->fragShader);REM(DestroyShader) S->fragShader=NULL;}
	if(S->vertShader) 		{C.ncontext->DestroyShader(S->vertShader);REM(DestroyShader) S->vertShader=NULL;}
	if(S->shaderPipeline)	{C.ncontext->DestroyShaderPipeline(S->shaderPipeline);REM(DestroyShaderPipeline) S->shaderPipeline=NULL;}
}
/*==========================================================================*/
BOOL OpenDisplayNova(void)
{
uint64 size,nsize;
float s,w,h;

	
REM(OpenDisplayNova)
	C.gpu = W3DN_GetGPUsList(&C.error, TAG_DONE);
	NCHECK(C.gpu,W3DN_GetGPUsList)
	NERROR(W3DN_GetGPUsList)

	C.ncontext = W3DN_CreateContextTags(&C.error, W3DNTag_Screen, NULL, TAG_DONE);
	NCHECK(C.ncontext,W3DN_CreateContextTags);
	NERROR(W3DN_CreateContextTags)
	
	C.ncontext->FBBindBufferTags(NULL, W3DN_FB_COLOUR_BUFFER_0, W3DNTag_BitMap,C.bufferbm, TAG_DONE);
	REM(FBBindBufferTags)
	C.ncontext->FBBindBufferTags(NULL, W3DN_FB_DEPTH_STENCIL, W3DNTag_AllocDepthStencil, W3DNPF_DEPTH);
	REM(FBBindBufferTags)
	
	// Clear the C.screen
	C.ncontext->Clear(NULL, C.opaqueBlack, &C.clearDepth, NULL);
	REM(Clear)
	C.ncontext->Submit(&C.error);
	NERROR(Submit)
		
	DoShaderNova(&myshader3dR,"shaders/GL_FLAT.vert.spv","shaders/GL_REPLACE.frag.spv");
	DoShaderNova(&myshader2dR,"shaders/GL_UNTRANSFORMED.vert.spv","shaders/GL_REPLACE.frag.spv");
	
	DoShaderNova(&myshader3dB,"shaders/GL_FLAT.vert.spv","shaders/GL_BLEND.frag.spv");
	DoShaderNova(&myshader2dB,"shaders/GL_UNTRANSFORMED.vert.spv","shaders/GL_BLEND.frag.spv");
	
	DoShaderNova(&myshader3dD,"shaders/GL_FLAT.vert.spv","shaders/GL_DECAL.frag.spv");
	DoShaderNova(&myshader2dD,"shaders/GL_UNTRANSFORMED.vert.spv","shaders/GL_DECAL.frag.spv");
	
	DoShaderNova(&myshader3dM,"shaders/GL_FLAT.vert.spv","shaders/GL_MODULATE.frag.spv");
	DoShaderNova(&myshader2dM,"shaders/GL_UNTRANSFORMED.vert.spv","shaders/GL_MODULATE.frag.spv");	



	/** Performing a quick safety check to make sure that the uniform variables in
	 * the vertex shader haven't been changed without also updating the
	 * VertexShaderData structure.
	 */
	size  = sizeof(VertexShaderData);
	nsize = C.ncontext->ShaderGetTotalStorage(myshader3dR.vertShader);
	REM(ShaderGetTotalStorage)
	if(size != nsize) 
	{
		printf("ERROR: VertexShaderData size was %ld bytes but is %ld",(ULONG)size,(ULONG)nsize);
		goto panic;
	}
	if(debug) printf("OK: size == nsize %ld == %ld ",(ULONG)size,(ULONG)nsize);
	
// Data Buffer Object (DBO) contains the vertex shader's constant data (here View)
// NOTE: Using W3DN_STREAM_DRAW, because it update the matrices every time
	C.dbo = C.ncontext->CreateDataBufferObjectTags(&C.error,sizeof(VertexShaderData), W3DN_STREAM_DRAW, 1, TAG_DONE);
	NCHECK(C.dbo,CreateDataBufferObjectTags);
	NERROR(CreateDataBufferObjectTags)

// Let the driver know what kind of data we're storing
// IMPORTANT: Do this *BEFORE* writing any data to the DBO
	C.ncontext->DBOSetBufferTags(C.dbo, 0, 0, sizeof(VertexShaderData),myshader3dR.vertShader, TAG_DONE);
	REM(DBOSetBufferTags)
	C.ncontext->DBOSetBufferTags(C.dbo, 0, 0, sizeof(VertexShaderData),myshader2dR.vertShader, TAG_DONE);
	REM(DBOSetBufferTags)
	C.ncontext->DBOSetBufferTags(C.dbo, 0, 0, sizeof(VertexShaderData),myshader3dB.vertShader, TAG_DONE);
	REM(DBOSetBufferTags)
	C.ncontext->DBOSetBufferTags(C.dbo, 0, 0, sizeof(VertexShaderData),myshader2dB.vertShader, TAG_DONE);
	REM(DBOSetBufferTags)
	C.ncontext->DBOSetBufferTags(C.dbo, 0, 0, sizeof(VertexShaderData),myshader3dM.vertShader, TAG_DONE);
	REM(DBOSetBufferTags)
	C.ncontext->DBOSetBufferTags(C.dbo, 0, 0, sizeof(VertexShaderData),myshader2dM.vertShader, TAG_DONE);
	REM(DBOSetBufferTags)
	C.ncontext->DBOSetBufferTags(C.dbo, 0, 0, sizeof(VertexShaderData),myshader3dD.vertShader, TAG_DONE);
	REM(DBOSetBufferTags)
	C.ncontext->DBOSetBufferTags(C.dbo, 0, 0, sizeof(VertexShaderData),myshader2dD.vertShader, TAG_DONE);
	REM(DBOSetBufferTags)
	
// Writing the view basic data to the DBO
	W3DN_BufferLock *bufferLock = C.ncontext->DBOLock(&C.error, C.dbo, 0, 0);
	NCHECK(bufferLock,DBOLock);
	NERROR(DBOLock)

// feed the VBO withs the View data
	VertexShaderData *shaderData = (VertexShaderData*)bufferLock->buffer;
 	memcpy(shaderData,&C.View,sizeof(VertexShaderData));	

	C.ncontext->BufferUnlock(bufferLock, 0, bufferLock->size);
	REM(BufferUnlock)
	
// Binding the DBO
	C.ncontext->BindShaderDataBuffer(NULL, W3DNST_VERTEX, C.dbo, 0);
	REM(BindShaderDataBuffer)	

	// Enable depth testing
	C.ncontext->SetState(NULL, W3DN_DEPTHTEST, W3DN_ENABLE);
	C.ncontext->SetState(NULL, W3DN_DEPTHWRITE, W3DN_ENABLE);
	C.ncontext->SetDepthCompareFunc(NULL, W3DN_LESS);
	
	// Enable backface culling
	C.ncontext->SetFrontFace(NULL, W3DN_FACE_CCW);
	C.ncontext->SetState(NULL, W3DN_CULLBACK, W3DN_ENABLE);

	// Light position 
	C.View.lightPos.x =  5.0;
	C.View.lightPos.y =  5.0;
	C.View.lightPos.z = 10.0;
	C.View.lightPos.w =  1.0;
	
	// Camera position 
	C.initCamPos.x =    0.0;
	C.initCamPos.y =    0.0;
	C.initCamPos.z = -200.0;	
	
	// Setting the initial view
	kmMat4Translation(&C.viewMatrix, C.initCamPos.x, C.initCamPos.y, C.initCamPos.z);
	s=COWSIZE; w=C.DisplayW; h=C.DisplayH;
	if(C.UsePespective)
		kmMat4PerspectiveProjection(&C.projectionMatrix, 60.0, w / (float)h, 1.0, 1024.0);
	else
		kmMat4OrthographicProjection(&C.projectionMatrix,-s,s,-s,s,    -500.0, 500.0);

	// Setting the initial model matrix
	kmMat4Identity(&C.modelMatrix);

	// Clear the screen
	C.ncontext->Clear(NULL, C.opaqueBlack, &C.clearDepth, NULL);
	C.ncontext->Submit(&C.error);	
	NERROR(Submit)
	
	// Blit to the C.window
	// NOTE: GPU operations occur in order so, assuming that ClipBlit() is HW accelerated, 
	// we don't need to perform a WaitIdle()/WaitDone() here
	BltBitMapRastPort(C.bufferbm,0,0,C.window->RPort,0,0,C.DisplayW,C.DisplayH,0xC0);	/* copy the "back buffer" to the window */
	
	return(TRUE);
panic: 
	REM(panic!!!)
	return(FALSE);
}
/*=================================================================*/
void CloseNova(void)
{
REM(CloseNova)	
	C.ncontext->Submit(&C.error);		/* flush all before exiting*/
	NERROR(Submit)
REM(freeing.....)	
panic:
	REM(panic!!!)
	FreeData();

	if(C.gpu) 				{W3DN_FreeGPUsList(C.gpu);REM(W3DN_FreeGPUsList) C.gpu=NULL;}	
	if(C.dbo) 				{C.ncontext->DestroyDataBufferObject(C.dbo);REM(DestroyDataBufferObject) C.dbo=NULL;}
	if(C.texSampler)		{C.ncontext->DestroyTexSampler(C.texSampler);REM(DestroyTexSampler) C.texSampler=NULL;}

	DeleteShaderNova(&myshader3dR);
	DeleteShaderNova(&myshader2dR);
	DeleteShaderNova(&myshader3dB);
	DeleteShaderNova(&myshader2dB);
	DeleteShaderNova(&myshader3dM);
	DeleteShaderNova(&myshader2dM);
	DeleteShaderNova(&myshader3dD);
	DeleteShaderNova(&myshader2dD);
	
	if(C.ncontext) 			{C.ncontext->Destroy();REM(Destroy) C.ncontext=NULL;}

}
/*==================================================================*/

