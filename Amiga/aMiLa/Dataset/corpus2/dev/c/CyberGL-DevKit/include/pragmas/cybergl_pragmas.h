/*
**	$VER: cybergl_pragmas.h 1.0 (20.03.1997)
**
**	SAS/C format pragma files.
**
**	Copyright © 1996-1997 by phase5 digital products
**      All Rights reserved.
**
*/


/*-------------gl window related calls-----------------------------*/
#pragma libcall CyberGLBase openGLWindowTagList	        1e	81003
#pragma libcall CyberGLBase closeGLWindow		24	801
#pragma libcall CyberGLBase attachGLWindowTagList	2a	910804
#pragma libcall CyberGLBase disposeGLWindow		30	801
#pragma libcall CyberGLBase resizeGLWindow		36	10803
#pragma libcall CyberGLBase getWindow		        3c	801
#pragma libcall CyberGLBase allocColor		        42	210804
#pragma libcall CyberGLBase allocColorRange		48	6543210808
#pragma libcall CyberGLBase attachGLWndToRPTagList  	4e	A109805

#ifdef __SASC_60
#pragma tagcall CyberGLBase openGLWindowTags	        1e	81003
#pragma tagcall CyberGLBase attachGLWindowTagList	2a	910804
#pragma tagcall CyberGLBase attachGLWndToRPTags  	4e	A109805
#endif

/*----------------------Contexts-----------------------------*/

#pragma libcall CyberGLBase glGetError			66	0
#pragma libcall CyberGLBase glEnable			6c	001
#pragma libcall CyberGLBase glDisable			72	001
#pragma libcall CyberGLBase glIsEnabled			78	001
#pragma libcall CyberGLBase glGetBooleanv		7e	8002
#pragma libcall CyberGLBase glGetIntegerv		84	8002
#pragma libcall CyberGLBase glGetFloatv			8a      8002
#pragma libcall CyberGLBase glGetDoublev		90	8002
#pragma libcall CyberGLBase glGetClipPlane		96	8002
#pragma libcall CyberGLBase glGetLightfv		9c	81003
#pragma libcall CyberGLBase glGetLightiv		a2	81003
#pragma libcall CyberGLBase glGetMaterialfv		a8	81003
#pragma libcall CyberGLBase glGetMaterialiv		ae	81003
#pragma libcall CyberGLBase glGetTexGendv		b4	81003
#pragma libcall CyberGLBase glGetTexGenfv		ba	81003
#pragma libcall CyberGLBase glGetTexGeniv		c0	81003
#pragma libcall CyberGLBase glGetPixelMapfv		c6	8002
#pragma libcall CyberGLBase glGetPixelMapuiv		cc	8002
#pragma libcall CyberGLBase glGetPixelMapusv		d2	8002
#pragma libcall CyberGLBase glGetTexEnvfv		d8	81003
#pragma libcall CyberGLBase glGetTexEnviv		de	81003		
#pragma libcall CyberGLBase glGetTexLevelParameterfv	e4	821004				
#pragma libcall CyberGLBase glGetTexLevelParameteriv	ea	821004
#pragma libcall CyberGLBase glGetTexParameterfv		f0	81003		
#pragma libcall CyberGLBase glGetTexParameteriv		f6	81003
#pragma libcall CyberGLBase glGetTexImage		fc	8321005	
#pragma libcall CyberGLBase glGetString			102	001
#pragma libcall CyberGLBase glPushAttrib		108	001
#pragma libcall CyberGLBase glPopAttrib			10e	0

/*----------------------Primitives---------------------------*/

#pragma libcall CyberGLBase glBegin			114	001
#pragma libcall CyberGLBase glEnd			11a	0
#pragma libcall CyberGLBase glVertex2s			120	1002
#pragma libcall CyberGLBase glVertex2i			126	1002
#pragma flibcall CyberGLBase glVertex2f			12c	11100002
#pragma flibcall CyberGLBase glVertex2d			132	11100002
#pragma libcall CyberGLBase glVertex3s			138	21003
#pragma libcall CyberGLBase glVertex3i			13e	21003
#pragma flibcall CyberGLBase glVertex3f			144	1211100003
#pragma flibcall CyberGLBase glVertex3d			14a	1211100003
#pragma libcall CyberGLBase glVertex4s			150	321004
#pragma libcall CyberGLBase glVertex4i			156	321004
#pragma flibcall CyberGLBase glVertex4f			15c	131211100004
#pragma flibcall CyberGLBase glVertex4d			162	131211100004
#pragma libcall CyberGLBase glVertex2sv			168	801
#pragma libcall CyberGLBase glVertex2iv			16e	801
#pragma libcall CyberGLBase glVertex2fv			174	801
#pragma libcall CyberGLBase glVertex2dv			17a	801
#pragma libcall CyberGLBase glVertex3sv			180	801
#pragma libcall CyberGLBase glVertex3iv			186	801
#pragma libcall CyberGLBase glVertex3fv			18c	801
#pragma libcall CyberGLBase glVertex3dv			192	801
#pragma libcall CyberGLBase glVertex4sv			198	801
#pragma libcall CyberGLBase glVertex4iv			19e	801
#pragma libcall CyberGLBase glVertex4fv			1a4	801
#pragma libcall CyberGLBase glVertex4dv			1aa	801
#pragma libcall CyberGLBase glTexCoord1s		1b0	001
#pragma libcall CyberGLBase glTexCoord1i		1b6	001
#pragma flibcall CyberGLBase glTexCoord1f		1bc	100001
#pragma flibcall CyberGLBase glTexCoord1d		1c2	100001
#pragma libcall CyberGLBase glTexCoord2s		1c8	1002
#pragma libcall CyberGLBase glTexCoord2i		1ce	1002
#pragma flibcall CyberGLBase glTexCoord2f		1d4	11100002
#pragma flibcall CyberGLBase glTexCoord2d		1da	11100002
#pragma libcall CyberGLBase glTexCoord3s		1e0	21003
#pragma libcall CyberGLBase glTexCoord3i		1e6	21003
#pragma flibcall CyberGLBase glTexCoord3f		1ec	1211100003
#pragma flibcall CyberGLBase glTexCoord3d		1f2	1211100003
#pragma libcall CyberGLBase glTexCoord4s		1f8	321004
#pragma libcall CyberGLBase glTexCoord4i		1fe	321004
#pragma flibcall CyberGLBase glTexCoord4f		204	131211100004
#pragma flibcall CyberGLBase glTexCoord4d		20a	131211100004
#pragma libcall CyberGLBase glTexCoord1sv		210	801
#pragma libcall CyberGLBase glTexCoord1iv		216	801
#pragma libcall CyberGLBase glTexCoord1fv		21c	801
#pragma libcall CyberGLBase glTexCoord1dv		222	801
#pragma libcall CyberGLBase glTexCoord2sv		228	801
#pragma libcall CyberGLBase glTexCoord2iv		22e	801
#pragma libcall CyberGLBase glTexCoord2fv		234	801
#pragma libcall CyberGLBase glTexCoord2dv		23a	801
#pragma libcall CyberGLBase glTexCoord3sv		240	801
#pragma libcall CyberGLBase glTexCoord3iv		246	801
#pragma libcall CyberGLBase glTexCoord3fv		24c	801
#pragma libcall CyberGLBase glTexCoord3dv		252	801
#pragma libcall CyberGLBase glTexCoord4sv		258	801
#pragma libcall CyberGLBase glTexCoord4iv		25e	801
#pragma libcall CyberGLBase glTexCoord4fv		264	801
#pragma libcall CyberGLBase glTexCoord4dv		26a	801

#pragma libcall CyberGLBase glNormal3b		270	21003
#pragma libcall CyberGLBase glNormal3s		276	21003
#pragma libcall CyberGLBase glNormal3i		27c	21003
#pragma flibcall CyberGLBase glNormal3f		282	1211100003
#pragma flibcall CyberGLBase glNormal3d		288	1211100003
#pragma libcall CyberGLBase glNormal3bv		28e	801
#pragma libcall CyberGLBase glNormal3sv		294	801
#pragma libcall CyberGLBase glNormal3iv		29a	801
#pragma libcall CyberGLBase glNormal3fv		2a0	801
#pragma libcall CyberGLBase glNormal3dv		2a6	801
#pragma libcall CyberGLBase glColor3b		2ac	21003
#pragma libcall CyberGLBase glColor3s		2b2	21003
#pragma libcall CyberGLBase glColor3i		2b8	21003
#pragma flibcall CyberGLBase glColor3f		2be	1211100003
#pragma flibcall CyberGLBase glColor3d		2c4	1211100003
#pragma libcall CyberGLBase glColor3ub		2ca	21003
#pragma libcall CyberGLBase glColor3us		2d0	21003
#pragma libcall CyberGLBase glColor3ui		2d6	21003
#pragma libcall CyberGLBase glColor4b		2dc	321004
#pragma libcall CyberGLBase glColor4s		2e2	321004
#pragma libcall CyberGLBase glColor4i		2e8	321004
#pragma flibcall CyberGLBase glColor4f		2ee	131211100004
#pragma flibcall CyberGLBase glColor4d		2f4	131211100004
#pragma libcall CyberGLBase glColor4ub		2fa	321004
#pragma libcall CyberGLBase glColor4us		300	321004
#pragma libcall CyberGLBase glColor4ui		306	321004
#pragma libcall CyberGLBase glColor3bv		30c	801
#pragma libcall CyberGLBase glColor3sv		312	801
#pragma libcall CyberGLBase glColor3iv		318	801
#pragma libcall CyberGLBase glColor3fv		31e	801
#pragma libcall CyberGLBase glColor3dv		324	801
#pragma libcall CyberGLBase glColor3ubv		32a	801
#pragma libcall CyberGLBase glColor3usv		330	801
#pragma libcall CyberGLBase glColor3uiv		336	801
#pragma libcall CyberGLBase glColor4bv		33c	801
#pragma libcall CyberGLBase glColor4sv		342	801
#pragma libcall CyberGLBase glColor4iv		348	801
#pragma libcall CyberGLBase glColor4fv		34e	801
#pragma libcall CyberGLBase glColor4dv		354	801
#pragma libcall CyberGLBase glColor4ubv		35a	801
#pragma libcall CyberGLBase glColor4usv		360	801
#pragma libcall CyberGLBase glColor4uiv		366	801
#pragma libcall CyberGLBase glIndexs		36c	001
#pragma libcall CyberGLBase glIndexi		372	001
#pragma flibcall CyberGLBase glIndexf		378	100001
#pragma flibcall CyberGLBase glIndexd		37e	100001
#pragma libcall CyberGLBase glIndexsv		384	801
#pragma libcall CyberGLBase glIndexiv		38a	801
#pragma libcall CyberGLBase glIndexfv		390	801
#pragma libcall CyberGLBase glIndexdv		396	801
#pragma libcall CyberGLBase glRects		39c	321004
#pragma libcall CyberGLBase glRecti		3a2	321004
#pragma flibcall CyberGLBase glRectf		3a8	131211100004
#pragma flibcall CyberGLBase glRectd		3ae	131211100004
#pragma libcall CyberGLBase glRectsv		3b4	9802
#pragma libcall CyberGLBase glRectiv		3ba	9802
#pragma libcall CyberGLBase glRectfv		3c0	9802
#pragma libcall CyberGLBase glRectdv		3c6	9802
#pragma libcall CyberGLBase glEdgeFlag		3cc	001
#pragma libcall CyberGLBase glEdgeFlagv		3d2	801
#pragma libcall CyberGLBase glRasterPos2s	3d8	1002
#pragma libcall CyberGLBase glRasterPos2i	3de	1002
#pragma flibcall CyberGLBase glRasterPos2f	3e4	11100002
#pragma flibcall CyberGLBase glRasterPos2d	3ea	11100002
#pragma libcall CyberGLBase glRasterPos3s	3f0	21003
#pragma libcall CyberGLBase glRasterPos3i	3f6	21003
#pragma flibcall CyberGLBase glRasterPos3f	3fc	1211100003
#pragma flibcall CyberGLBase glRasterPos3d	402	1211100003
#pragma libcall CyberGLBase glRasterPos4s	408	321004
#pragma libcall CyberGLBase glRasterPos4i	40e	321004
#pragma flibcall CyberGLBase glRasterPos4f	414	131211100004
#pragma flibcall CyberGLBase glRasterPos4d	41a	131211100004
#pragma libcall CyberGLBase glRasterPos2sv	420	801
#pragma libcall CyberGLBase glRasterPos2iv	426	801
#pragma libcall CyberGLBase glRasterPos2fv	42c	801
#pragma libcall CyberGLBase glRasterPos2dv	432	801
#pragma libcall CyberGLBase glRasterPos3sv	438	801
#pragma libcall CyberGLBase glRasterPos3iv	43e	801
#pragma libcall CyberGLBase glRasterPos3fv	444	801
#pragma libcall CyberGLBase glRasterPos3dv	44a	801
#pragma libcall CyberGLBase glRasterPos4sv	450	801
#pragma libcall CyberGLBase glRasterPos4iv	456	801
#pragma libcall CyberGLBase glRasterPos4fv	45c	801
#pragma libcall CyberGLBase glRasterPos4dv	462	801

/*----------------------Transforming-------------------------*/

#pragma flibcall CyberGLBase glDepthRange	468	11100002
#pragma libcall CyberGLBase glViewport		46e	321004
#pragma libcall CyberGLBase glMatrixMode	474	001
#pragma libcall CyberGLBase glLoadMatrixf       47a	801
#pragma libcall CyberGLBase glLoadMatrixd	480	801
#pragma libcall CyberGLBase glMultMatrixf	486	801
#pragma libcall CyberGLBase glMultMatrixd	48c	801
#pragma libcall CyberGLBase glLoadIdentity	492	0
#pragma flibcall CyberGLBase glRotatef		498	131211100004
#pragma flibcall CyberGLBase glRotated		49e	131211100004
#pragma flibcall CyberGLBase glTranslatef	4a4	1211100003
#pragma flibcall CyberGLBase glTranslated	4aa	1211100003
#pragma flibcall CyberGLBase glScalef		4b0	1211100003
#pragma flibcall CyberGLBase glScaled		4b6	1211100003
#ifndef GL_APICOMPATIBLE
#pragma libcall CyberGLBase glFrustum		4bc	801
#pragma libcall CyberGLBase glOrtho		4c2	801
#endif
#pragma libcall CyberGLBase glPushMatrix	4c8	0
#pragma libcall CyberGLBase glPopMatrix		4ce	0
#pragma flibcall CyberGLBase glOrtho2D		4d4	131211100004
#pragma flibcall CyberGLBase glProject		4da	1514131211100006
#pragma flibcall CyberGLBase glUnProject	4e0        1514131211100006
#pragma flibcall CyberGLBase glPerspective	4e6	131211100004
#ifndef GL_APICOMPATIBLE
#pragma libcall CyberGLBase glLookAt		4ec	801
#endif
#pragma flibcall CyberGLBase glPickMatrix	4f2	131211100004

/*----------------------Clipping-----------------------------*/

#pragma libcall CyberGLBase glClipPlane		4f8	8002

/*----------------------Drawing--------------------------*/

#pragma libcall CyberGLBase glClear		4fe	001
#pragma flibcall CyberGLBase glClearColor	504	131211100004
#pragma flibcall CyberGLBase glClearIndex	50a	100001
#pragma flibcall CyberGLBase glClearDepth	510	100001
#pragma libcall CyberGLBase glFlush		516	0
#pragma libcall CyberGLBase glFinish		51c	0
#pragma libcall CyberGLBase glHint		522	1002
#pragma libcall CyberGLBase glDrawBuffer	528	001
#pragma flibcall CyberGLBase glFogf		52e	10000002
#pragma libcall CyberGLBase glFogi		534	1002
#pragma libcall CyberGLBase glFogfv		53a	8002
#pragma libcall CyberGLBase glFogiv		540	8002
#pragma libcall CyberGLBase glDepthFunc		546	001
#pragma libcall CyberGLBase glPolygonMode	54c	1002
#pragma libcall CyberGLBase glShadeModel	552	001
#pragma libcall CyberGLBase glCullFace		558	001
#pragma libcall CyberGLBase glFrontFace		55e	001

/*----------------------Selection----------------------------*/

#pragma libcall CyberGLBase glRenderMode	564	001
#pragma libcall CyberGLBase glInitNames		56a	0
#pragma libcall CyberGLBase glLoadName		570	001
#pragma libcall CyberGLBase glPushName		576	001
#pragma libcall CyberGLBase glPopName		57c	0
#pragma libcall CyberGLBase glSelectBuffer	582	8002

/*----------------------Lighting-----------------------------*/

#pragma flibcall CyberGLBase glLightf		588	1001000003
#pragma libcall CyberGLBase glLighti		58e	21003
#pragma libcall CyberGLBase glLightfv		594	81003
#pragma libcall CyberGLBase glLightiv		59a	81003
#pragma flibcall CyberGLBase glLightModelf	5a0	10000002
#pragma libcall CyberGLBase glLightModeli	5a6	1002
#pragma libcall CyberGLBase glLightModelfv	5ac	8002
#pragma libcall CyberGLBase glLightModeliv	5b2	8002
#pragma flibcall CyberGLBase glMaterialf	5b8	1001000003
#pragma libcall CyberGLBase glMateriali		5be	21003
#pragma libcall CyberGLBase glMaterialfv	5c4	81003
#pragma libcall CyberGLBase glMaterialiv	5ca	81003
#pragma libcall CyberGLBase glColorMaterial	5d0	1002

/*----------------------Texturing----------------------------*/

#pragma libcall CyberGLBase glTexGeni		5d6	21003
#pragma flibcall CyberGLBase glTexGenf		5dc	1001000003
#pragma flibcall CyberGLBase glTexGend		5e2	1001000003
#pragma libcall CyberGLBase glTexGeniv		5e8	81003
#pragma libcall CyberGLBase glTexGenfv		5ee	81003
#pragma libcall CyberGLBase glTexGendv		5f4	81003
#pragma flibcall CyberGLBase glTexEnvf		5fa	1001000003
#pragma libcall CyberGLBase glTexEnvi		600	21003
#pragma libcall CyberGLBase glTexEnvfv		606	81003
#pragma libcall CyberGLBase glTexEnviv		60c	81003
#pragma flibcall CyberGLBase glTexParameterf	612	1001000003
#pragma libcall CyberGLBase glTexParameteri	618	21003
#pragma libcall CyberGLBase glTexParameterfv	61e	81003
#pragma libcall CyberGLBase glTexParameteriv	624	81003
#pragma libcall CyberGLBase glTexImage1D	62a	87654321009
#pragma libcall CyberGLBase glTexImage2D	630	87654321009

/*------------------------Images-----------------------------*/

#pragma libcall CyberGLBase glPixelStorei	636	1002
#pragma flibcall CyberGLBase glPixelStoref	63c	10000002
#pragma libcall CyberGLBase glPixelTransferi	642	1002
#pragma libcall CyberGLBase glPixelTransferf	648	10000002
#pragma libcall CyberGLBase glPixelMapuiv	64e	81003
#pragma libcall CyberGLBase glPixelMapusv	654	81003
#pragma libcall CyberGLBase glPixelMapfv	65a	81003
#pragma flibcall CyberGLBase glPixelZoom	660	11100002
#pragma libcall CyberGLBase glDrawPixels	666	8321005
#ifndef GL_APICOMPATIBLE
#pragma libcall CyberGLBase glBitmap		66c	801
#endif
