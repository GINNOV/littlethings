/****************************************************
 *                KNIGHTBLIT.H
 *
 * Headers for Blitter management software
 *
 * Written by Kel & Billy 9-Apr-88
 *
 */
extern struct BitMap MyBitMaps[2];
extern struct RastPort MyRPorts[2];
extern struct RastPort MyRPort;
extern void InitOurPorts();
extern void FreeOurPorts();
extern void EraseOurBitMaps();
extern void DumpOurBitMaps();
extern void EraseRectangle();
extern void BlitBrick();
extern void DumpRectangle();
