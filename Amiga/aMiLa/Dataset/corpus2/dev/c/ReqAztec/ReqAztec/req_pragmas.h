#ifndef	REQ_PRAGMAS_H
#define	REQ_PRAGMAS_H

#pragma amicall(ReqBase, 0x1e, Center(a0,d0,d1))

#pragma amicall(ReqBase, 0x24, SetSize(d0,d1))
#pragma amicall(ReqBase, 0x2a, SetLocation(d0,d1,d2))
#pragma amicall(ReqBase, 0x30, ReadLocation(d0,d1,d2))

/* #pragma amicall(ReqBase, 0x36, Format())				variable number of args */
#pragma amicall(ReqBase, 0x54, FileRequester(a0))
#pragma amicall(ReqBase, 0x5a, ColorRequester(d0))
#pragma amicall(ReqBase, 0x60, DrawBox(a1,d0,d1,d2,d3))
#pragma amicall(ReqBase, 0x66, MakeButton(a0,a1,a2,d0,d1,d2))
#pragma amicall(ReqBase, 0x6c, MakeScrollBar(a0,d0,d1,d2,d3))
#pragma amicall(ReqBase, 0x72, PurgeFiles(a0))

/* #pragma amicall(ReqBase, 0x78, GetFontHeightAndWidth()) too many args */

#pragma amicall(ReqBase, 0x7e, MakeGadget(a0,a1,d0,d1))
#pragma amicall(ReqBase, 0x84, MakeString(a0,a1,a2,d0,d1,d2,d3))
#pragma amicall(ReqBase, 0x8a, MakeProp(a0,d0,d1,d2))

#pragma amicall(ReqBase, 0x90, LinkGadget(a0,a1,a3,d0,d1))
/*
#pragma amicall(ReqBase, 0x96, LinkStringGadget(a0,a1,a2,a3,d0,d1,d2,d3))
#pragma amicall(ReqBase, 0x9c, LinkPropGadget(a0,a3,d0,d1,d2,d3,d4))
*/

#pragma amicall(ReqBase, 0xa2, GetString(a0,a1,a2,d0,d1))
#pragma amicall(ReqBase, 0xa8, RealTimeScroll(a0))

#pragma amicall(ReqBase, 0xae, TextRequest(a0))
#pragma amicall(ReqBase, 0xb4, GetLong(a0))
#pragma amicall(ReqBase, 0xba, RawKeyToAscii(d0,d1,a0))
#pragma amicall(ReqBase, 0xc0, ExtendedColorRequester(a0))
#pragma amicall(ReqBase, 0xc6, NewGetString(a0))

/***********************************************************************/
/* LinkString and LinkProp have been omitted, as they require too many */
/* parameters for pragging. However, new versions of these functions   */
/* are planned, to take care of this. Stay tuned.                      */
/*                                                        C.W. Fox     */
/***********************************************************************/


/**************************************************************************/
/* Also, GetFontHeightAndWidth has been left out, as it returns values in */
/* two registers, which is difficult to manage from C.                    */
/*                                                        C.W. Fox        */
/**************************************************************************/

#endif