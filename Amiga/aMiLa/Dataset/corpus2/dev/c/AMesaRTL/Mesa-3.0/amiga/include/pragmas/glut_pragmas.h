/*
 * AmigaMesaRTL graphics library
 * Version:  2.0
 * Copyright (C) 1998  Jarno van der Linden
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/*
 * Version 2.0  16 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 */


/* "glut.library" */
#pragma libcall glutBase glutInit 1e 9802
#pragma libcall glutBase glutInitDisplayMode 24 001
#pragma libcall glutBase glutInitWindowPosition 2a 1002
#pragma libcall glutBase glutInitWindowSize 30 1002
#pragma libcall glutBase glutMainLoop 36 00
#pragma libcall glutBase glutCreateWindow 3c 801
#pragma libcall glutBase glutDestroyWindow 42 001
#pragma libcall glutBase glutPostRedisplay 48 00
#pragma libcall glutBase glutSwapBuffers 4e 00
#pragma libcall glutBase glutGetWindow 54 00
#pragma libcall glutBase glutSetWindow 5a 001
#pragma libcall glutBase glutSetWindowTitle 60 801
#pragma libcall glutBase glutPositionWindow 66 1002
#pragma libcall glutBase glutReshapeWindow 6c 1002
#pragma libcall glutBase glutCreateMenu 72 801
#pragma libcall glutBase glutDestroyMenu 78 001
#pragma libcall glutBase glutGetMenu 7e 00
#pragma libcall glutBase glutSetMenu 84 001
#pragma libcall glutBase glutAddMenuEntry 8a 0802
#pragma libcall glutBase glutAddSubMenu 90 0802
#pragma libcall glutBase glutChangeToMenuEntry 96 18003
#pragma libcall glutBase glutChangeToSubMenu 9c 18003
#pragma libcall glutBase glutRemoveMenuItem a2 001
#pragma libcall glutBase glutAttachMenu a8 001
#pragma libcall glutBase glutDetachMenu ae 001
#pragma libcall glutBase glutDisplayFunc b4 801
#pragma libcall glutBase glutReshapeFunc ba 801
#pragma libcall glutBase glutKeyboardFunc c0 801
#pragma libcall glutBase glutMouseFunc c6 801
#pragma libcall glutBase glutMotionFunc cc 801
#pragma libcall glutBase glutPassiveMotionFunc d2 801
#pragma libcall glutBase glutVisibilityFunc d8 801
#pragma libcall glutBase glutIdleFunc de 801
#pragma libcall glutBase glutSpecialFunc e4 801
#pragma libcall glutBase glutMenuStatusFunc ea 801
#pragma flibcall glutBase glutSetColor f0 121110000004
#pragma libcall glutBase glutGetColor f6 1002
#pragma libcall glutBase glutGet fc 001
#pragma libcall glutBase glutExtensionSupported 102 801
#pragma libcall glutBase glutGetModifiers 108 00
#pragma flibcall glutBase glutWireSphere 10e 0100100003
#pragma flibcall glutBase glutSolidSphere 114 0100100003
#pragma flibcall glutBase glutWireCone 11a 010011100004
#pragma flibcall glutBase glutSolidCone 120 010011100004
#pragma flibcall glutBase glutWireCube 126 100001
#pragma flibcall glutBase glutSolidCube 12c 100001
#pragma flibcall glutBase glutWireTorus 132 010011100004
#pragma flibcall glutBase glutSolidTorus 138 010011100004
#pragma libcall glutBase glutWireDodecahedron 13e 00
#pragma libcall glutBase glutSolidDodecahedron 144 00
#pragma flibcall glutBase glutWireTeapot 14a 100001
#pragma flibcall glutBase glutSolidTeapot 150 100001
#pragma libcall glutBase glutWireOctahedron 156 00
#pragma libcall glutBase glutSolidOctahedron 15c 00
#pragma libcall glutBase glutWireTetrahedron 162 00
#pragma libcall glutBase glutSolidTetrahedron 168 00
#pragma libcall glutBase glutWireIcosahedron 16e 00
#pragma libcall glutBase glutSolidIcosahedron 174 00
#pragma libcall glutBase glutAssociateGL 17a 9802
