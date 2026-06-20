#ifndef _INCLUDE_PRAGMA_GRAPHICS_LIB_H
#define _INCLUDE_PRAGMA_GRAPHICS_LIB_H

#ifndef CLIB_GRAPHICS_PROTOS_H
#include <clib/graphics_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/graphics.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(GfxBase,0x01E,BltBitMap(a0,d0,d1,a1,d2,d3,d4,d5,d6,d7,a2))
#pragma amicall(GfxBase,0x024,BltTemplate(a0,d0,d1,a1,d2,d3,d4,d5))
#pragma amicall(GfxBase,0x02A,ClearEOL(a1))
#pragma amicall(GfxBase,0x030,ClearScreen(a1))
#pragma amicall(GfxBase,0x036,TextLength(a1,a0,d0))
#pragma amicall(GfxBase,0x03C,Text(a1,a0,d0))
#pragma amicall(GfxBase,0x042,SetFont(a1,a0))
#pragma amicall(GfxBase,0x048,OpenFont(a0))
#pragma amicall(GfxBase,0x04E,CloseFont(a1))
#pragma amicall(GfxBase,0x054,AskSoftStyle(a1))
#pragma amicall(GfxBase,0x05A,SetSoftStyle(a1,d0,d1))
#pragma amicall(GfxBase,0x060,AddBob(a0,a1))
#pragma amicall(GfxBase,0x066,AddVSprite(a0,a1))
#pragma amicall(GfxBase,0x06C,DoCollision(a1))
#pragma amicall(GfxBase,0x072,DrawGList(a1,a0))
#pragma amicall(GfxBase,0x078,InitGels(a0,a1,a2))
#pragma amicall(GfxBase,0x07E,InitMasks(a0))
#pragma amicall(GfxBase,0x084,RemIBob(a0,a1,a2))
#pragma amicall(GfxBase,0x08A,RemVSprite(a0))
#pragma amicall(GfxBase,0x090,SetCollision(d0,a0,a1))
#pragma amicall(GfxBase,0x096,SortGList(a1))
#pragma amicall(GfxBase,0x09C,AddAnimOb(a0,a1,a2))
#pragma amicall(GfxBase,0x0A2,Animate(a0,a1))
#pragma amicall(GfxBase,0x0A8,GetGBuffers(a0,a1,d0))
#pragma amicall(GfxBase,0x0AE,InitGMasks(a0))
#pragma amicall(GfxBase,0x0B4,DrawEllipse(a1,d0,d1,d2,d3))
#pragma amicall(GfxBase,0x0BA,AreaEllipse(a1,d0,d1,d2,d3))
#pragma amicall(GfxBase,0x0C0,LoadRGB4(a0,a1,d0))
#pragma amicall(GfxBase,0x0C6,InitRastPort(a1))
#pragma amicall(GfxBase,0x0CC,InitVPort(a0))
#pragma amicall(GfxBase,0x0D2,MrgCop(a1))
#pragma amicall(GfxBase,0x0D8,MakeVPort(a0,a1))
#pragma amicall(GfxBase,0x0DE,LoadView(a1))
#pragma amicall(GfxBase,0x0E4,WaitBlit())
#pragma amicall(GfxBase,0x0EA,SetRast(a1,d0))
#pragma amicall(GfxBase,0x0F0,Move(a1,d0,d1))
#pragma amicall(GfxBase,0x0F6,Draw(a1,d0,d1))
#pragma amicall(GfxBase,0x0FC,AreaMove(a1,d0,d1))
#pragma amicall(GfxBase,0x102,AreaDraw(a1,d0,d1))
#pragma amicall(GfxBase,0x108,AreaEnd(a1))
#pragma amicall(GfxBase,0x10E,WaitTOF())
#pragma amicall(GfxBase,0x114,QBlit(a1))
#pragma amicall(GfxBase,0x11A,InitArea(a0,a1,d0))
#pragma amicall(GfxBase,0x120,SetRGB4(a0,d0,d1,d2,d3))
#pragma amicall(GfxBase,0x126,QBSBlit(a1))
#pragma amicall(GfxBase,0x12C,BltClear(a1,d0,d1))
#pragma amicall(GfxBase,0x132,RectFill(a1,d0,d1,d2,d3))
#pragma amicall(GfxBase,0x138,BltPattern(a1,a0,d0,d1,d2,d3,d4))
#pragma amicall(GfxBase,0x13E,ReadPixel(a1,d0,d1))
#pragma amicall(GfxBase,0x144,WritePixel(a1,d0,d1))
#pragma amicall(GfxBase,0x14A,Flood(a1,d2,d0,d1))
#pragma amicall(GfxBase,0x150,PolyDraw(a1,d0,a0))
#pragma amicall(GfxBase,0x156,SetAPen(a1,d0))
#pragma amicall(GfxBase,0x15C,SetBPen(a1,d0))
#pragma amicall(GfxBase,0x162,SetDrMd(a1,d0))
#pragma amicall(GfxBase,0x168,InitView(a1))
#pragma amicall(GfxBase,0x16E,CBump(a1))
#pragma amicall(GfxBase,0x174,CMove(a1,d0,d1))
#pragma amicall(GfxBase,0x17A,CWait(a1,d0,d1))
#pragma amicall(GfxBase,0x180,VBeamPos())
#pragma amicall(GfxBase,0x186,InitBitMap(a0,d0,d1,d2))
#pragma amicall(GfxBase,0x18C,ScrollRaster(a1,d0,d1,d2,d3,d4,d5))
#pragma amicall(GfxBase,0x192,WaitBOVP(a0))
#pragma amicall(GfxBase,0x198,GetSprite(a0,d0))
#pragma amicall(GfxBase,0x19E,FreeSprite(d0))
#pragma amicall(GfxBase,0x1A4,ChangeSprite(a0,a1,a2))
#pragma amicall(GfxBase,0x1AA,MoveSprite(a0,a1,d0,d1))
#pragma amicall(GfxBase,0x1B0,LockLayerRom(a5))
#pragma amicall(GfxBase,0x1B6,UnlockLayerRom(a5))
#pragma amicall(GfxBase,0x1BC,SyncSBitMap(a0))
#pragma amicall(GfxBase,0x1C2,CopySBitMap(a0))
#pragma amicall(GfxBase,0x1C8,OwnBlitter())
#pragma amicall(GfxBase,0x1CE,DisownBlitter())
#pragma amicall(GfxBase,0x1D4,InitTmpRas(a0,a1,d0))
#pragma amicall(GfxBase,0x1DA,AskFont(a1,a0))
#pragma amicall(GfxBase,0x1E0,AddFont(a1))
#pragma amicall(GfxBase,0x1E6,RemFont(a1))
#pragma amicall(GfxBase,0x1EC,AllocRaster(d0,d1))
#pragma amicall(GfxBase,0x1F2,FreeRaster(a0,d0,d1))
#pragma amicall(GfxBase,0x1F8,AndRectRegion(a0,a1))
#pragma amicall(GfxBase,0x1FE,OrRectRegion(a0,a1))
#pragma amicall(GfxBase,0x204,NewRegion())
#pragma amicall(GfxBase,0x20A,ClearRectRegion(a0,a1))
#pragma amicall(GfxBase,0x210,ClearRegion(a0))
#pragma amicall(GfxBase,0x216,DisposeRegion(a0))
#pragma amicall(GfxBase,0x21C,FreeVPortCopLists(a0))
#pragma amicall(GfxBase,0x222,FreeCopList(a0))
#pragma amicall(GfxBase,0x228,ClipBlit(a0,d0,d1,a1,d2,d3,d4,d5,d6))
#pragma amicall(GfxBase,0x22E,XorRectRegion(a0,a1))
#pragma amicall(GfxBase,0x234,FreeCprList(a0))
#pragma amicall(GfxBase,0x23A,GetColorMap(d0))
#pragma amicall(GfxBase,0x240,FreeColorMap(a0))
#pragma amicall(GfxBase,0x246,GetRGB4(a0,d0))
#pragma amicall(GfxBase,0x24C,ScrollVPort(a0))
#pragma amicall(GfxBase,0x252,UCopperListInit(a0,d0))
#pragma amicall(GfxBase,0x258,FreeGBuffers(a0,a1,d0))
#pragma amicall(GfxBase,0x25E,BltBitMapRastPort(a0,d0,d1,a1,d2,d3,d4,d5,d6))
#pragma amicall(GfxBase,0x264,OrRegionRegion(a0,a1))
#pragma amicall(GfxBase,0x26A,XorRegionRegion(a0,a1))
#pragma amicall(GfxBase,0x270,AndRegionRegion(a0,a1))
#pragma amicall(GfxBase,0x276,SetRGB4CM(a0,d0,d1,d2,d3))
#pragma amicall(GfxBase,0x27C,BltMaskBitMapRastPort(a0,d0,d1,a1,d2,d3,d4,d5,d6,a2))
#pragma amicall(GfxBase,0x28E,AttemptLockLayerRom(a5))
#pragma amicall(GfxBase,0x294,GfxNew(d0))
#pragma amicall(GfxBase,0x29A,GfxFree(a0))
#pragma amicall(GfxBase,0x2A0,GfxAssociate(a0,a1))
#pragma amicall(GfxBase,0x2A6,BitMapScale(a0))
#pragma amicall(GfxBase,0x2AC,ScalerDiv(d0,d1,d2))
#pragma amicall(GfxBase,0x2B2,TextExtent(a1,a0,d0,a2))
#pragma amicall(GfxBase,0x2B8,TextFit(a1,a0,d0,a2,a3,d1,d2,d3))
#pragma amicall(GfxBase,0x2BE,GfxLookUp(a0))
#pragma amicall(GfxBase,0x2C4,VideoControl(a0,a1))
#pragma amicall(GfxBase,0x2CA,OpenMonitor(a1,d0))
#pragma amicall(GfxBase,0x2D0,CloseMonitor(a0))
#pragma amicall(GfxBase,0x2D6,FindDisplayInfo(d0))
#pragma amicall(GfxBase,0x2DC,NextDisplayInfo(d0))
#pragma amicall(GfxBase,0x2F4,GetDisplayInfoData(a0,a1,d0,d1,d2))
#pragma amicall(GfxBase,0x2FA,FontExtent(a0,a1))
#pragma amicall(GfxBase,0x300,ReadPixelLine8(a0,d0,d1,d2,a2,a1))
#pragma amicall(GfxBase,0x306,WritePixelLine8(a0,d0,d1,d2,a2,a1))
#pragma amicall(GfxBase,0x30C,ReadPixelArray8(a0,d0,d1,d2,d3,a2,a1))
#pragma amicall(GfxBase,0x312,WritePixelArray8(a0,d0,d1,d2,d3,a2,a1))
#pragma amicall(GfxBase,0x318,GetVPModeID(a0))
#pragma amicall(GfxBase,0x31E,ModeNotAvailable(d0))
#pragma amicall(GfxBase,0x32A,EraseRect(a1,d0,d1,d2,d3))
#pragma amicall(GfxBase,0x330,ExtendFont(a0,a1))
#pragma amicall(GfxBase,0x336,StripFont(a0))
#pragma amicall(GfxBase,0x33C,CalcIVG(a0,a1))
#pragma amicall(GfxBase,0x342,AttachPalExtra(a0,a1))
#pragma amicall(GfxBase,0x348,ObtainBestPenA(a0,d1,d2,d3,a1))
#pragma amicall(GfxBase,0x354,SetRGB32(a0,d0,d1,d2,d3))
#pragma amicall(GfxBase,0x35A,GetAPen(a0))
#pragma amicall(GfxBase,0x360,GetBPen(a0))
#pragma amicall(GfxBase,0x366,GetDrMd(a0))
#pragma amicall(GfxBase,0x36C,GetOutlinePen(a0))
#pragma amicall(GfxBase,0x372,LoadRGB32(a0,a1))
#pragma amicall(GfxBase,0x378,SetChipRev(d0))
#pragma amicall(GfxBase,0x37E,SetABPenDrMd(a1,d0,d1,d2))
#pragma amicall(GfxBase,0x384,GetRGB32(a0,d0,d1,a1))
#pragma amicall(GfxBase,0x396,AllocBitMap(d0,d1,d2,d3,a0))
#pragma amicall(GfxBase,0x39C,FreeBitMap(a0))
#pragma amicall(GfxBase,0x3A2,GetExtSpriteA(a2,a1))
#pragma amicall(GfxBase,0x3A8,CoerceMode(a0,d0,d1))
#pragma amicall(GfxBase,0x3AE,ChangeVPBitMap(a0,a1,a2))
#pragma amicall(GfxBase,0x3B4,ReleasePen(a0,d0))
#pragma amicall(GfxBase,0x3BA,ObtainPen(a0,d0,d1,d2,d3,d4))
#pragma amicall(GfxBase,0x3C0,GetBitMapAttr(a0,d1))
#pragma amicall(GfxBase,0x3C6,AllocDBufInfo(a0))
#pragma amicall(GfxBase,0x3CC,FreeDBufInfo(a1))
#pragma amicall(GfxBase,0x3D2,SetOutlinePen(a0,d0))
#pragma amicall(GfxBase,0x3D8,SetWriteMask(a0,d0))
#pragma amicall(GfxBase,0x3DE,SetMaxPen(a0,d0))
#pragma amicall(GfxBase,0x3E4,SetRGB32CM(a0,d0,d1,d2,d3))
#pragma amicall(GfxBase,0x3EA,ScrollRasterBF(a1,d0,d1,d2,d3,d4,d5))
#pragma amicall(GfxBase,0x3F0,FindColor(a3,d1,d2,d3,d4))
#pragma amicall(GfxBase,0x3FC,AllocSpriteDataA(a2,a1))
#pragma amicall(GfxBase,0x402,ChangeExtSpriteA(a0,a1,a2,a3))
#pragma amicall(GfxBase,0x408,FreeSpriteData(a2))
#pragma amicall(GfxBase,0x40E,SetRPAttrsA(a0,a1))
#pragma amicall(GfxBase,0x414,GetRPAttrsA(a0,a1))
#pragma amicall(GfxBase,0x41A,BestModeIDA(a0))
#pragma amicall(GfxBase,0x420,WriteChunkyPixels(a0,d0,d1,d2,d3,a2,d4))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall GfxBase BltBitMap            01E A76543291080B
#pragma  libcall GfxBase BltTemplate          024 5432910808
#pragma  libcall GfxBase ClearEOL             02A 901
#pragma  libcall GfxBase ClearScreen          030 901
#pragma  libcall GfxBase TextLength           036 08903
#pragma  libcall GfxBase Text                 03C 08903
#pragma  libcall GfxBase SetFont              042 8902
#pragma  libcall GfxBase OpenFont             048 801
#pragma  libcall GfxBase CloseFont            04E 901
#pragma  libcall GfxBase AskSoftStyle         054 901
#pragma  libcall GfxBase SetSoftStyle         05A 10903
#pragma  libcall GfxBase AddBob               060 9802
#pragma  libcall GfxBase AddVSprite           066 9802
#pragma  libcall GfxBase DoCollision          06C 901
#pragma  libcall GfxBase DrawGList            072 8902
#pragma  libcall GfxBase InitGels             078 A9803
#pragma  libcall GfxBase InitMasks            07E 801
#pragma  libcall GfxBase RemIBob              084 A9803
#pragma  libcall GfxBase RemVSprite           08A 801
#pragma  libcall GfxBase SetCollision         090 98003
#pragma  libcall GfxBase SortGList            096 901
#pragma  libcall GfxBase AddAnimOb            09C A9803
#pragma  libcall GfxBase Animate              0A2 9802
#pragma  libcall GfxBase GetGBuffers          0A8 09803
#pragma  libcall GfxBase InitGMasks           0AE 801
#pragma  libcall GfxBase DrawEllipse          0B4 3210905
#pragma  libcall GfxBase AreaEllipse          0BA 3210905
#pragma  libcall GfxBase LoadRGB4             0C0 09803
#pragma  libcall GfxBase InitRastPort         0C6 901
#pragma  libcall GfxBase InitVPort            0CC 801
#pragma  libcall GfxBase MrgCop               0D2 901
#pragma  libcall GfxBase MakeVPort            0D8 9802
#pragma  libcall GfxBase LoadView             0DE 901
#pragma  libcall GfxBase WaitBlit             0E4 00
#pragma  libcall GfxBase SetRast              0EA 0902
#pragma  libcall GfxBase Move                 0F0 10903
#pragma  libcall GfxBase Draw                 0F6 10903
#pragma  libcall GfxBase AreaMove             0FC 10903
#pragma  libcall GfxBase AreaDraw             102 10903
#pragma  libcall GfxBase AreaEnd              108 901
#pragma  libcall GfxBase WaitTOF              10E 00
#pragma  libcall GfxBase QBlit                114 901
#pragma  libcall GfxBase InitArea             11A 09803
#pragma  libcall GfxBase SetRGB4              120 3210805
#pragma  libcall GfxBase QBSBlit              126 901
#pragma  libcall GfxBase BltClear             12C 10903
#pragma  libcall GfxBase RectFill             132 3210905
#pragma  libcall GfxBase BltPattern           138 432108907
#pragma  libcall GfxBase ReadPixel            13E 10903
#pragma  libcall GfxBase WritePixel           144 10903
#pragma  libcall GfxBase Flood                14A 102904
#pragma  libcall GfxBase PolyDraw             150 80903
#pragma  libcall GfxBase SetAPen              156 0902
#pragma  libcall GfxBase SetBPen              15C 0902
#pragma  libcall GfxBase SetDrMd              162 0902
#pragma  libcall GfxBase InitView             168 901
#pragma  libcall GfxBase CBump                16E 901
#pragma  libcall GfxBase CMove                174 10903
#pragma  libcall GfxBase CWait                17A 10903
#pragma  libcall GfxBase VBeamPos             180 00
#pragma  libcall GfxBase InitBitMap           186 210804
#pragma  libcall GfxBase ScrollRaster         18C 543210907
#pragma  libcall GfxBase WaitBOVP             192 801
#pragma  libcall GfxBase GetSprite            198 0802
#pragma  libcall GfxBase FreeSprite           19E 001
#pragma  libcall GfxBase ChangeSprite         1A4 A9803
#pragma  libcall GfxBase MoveSprite           1AA 109804
#pragma  libcall GfxBase LockLayerRom         1B0 D01
#pragma  libcall GfxBase UnlockLayerRom       1B6 D01
#pragma  libcall GfxBase SyncSBitMap          1BC 801
#pragma  libcall GfxBase CopySBitMap          1C2 801
#pragma  libcall GfxBase OwnBlitter           1C8 00
#pragma  libcall GfxBase DisownBlitter        1CE 00
#pragma  libcall GfxBase InitTmpRas           1D4 09803
#pragma  libcall GfxBase AskFont              1DA 8902
#pragma  libcall GfxBase AddFont              1E0 901
#pragma  libcall GfxBase RemFont              1E6 901
#pragma  libcall GfxBase AllocRaster          1EC 1002
#pragma  libcall GfxBase FreeRaster           1F2 10803
#pragma  libcall GfxBase AndRectRegion        1F8 9802
#pragma  libcall GfxBase OrRectRegion         1FE 9802
#pragma  libcall GfxBase NewRegion            204 00
#pragma  libcall GfxBase ClearRectRegion      20A 9802
#pragma  libcall GfxBase ClearRegion          210 801
#pragma  libcall GfxBase DisposeRegion        216 801
#pragma  libcall GfxBase FreeVPortCopLists    21C 801
#pragma  libcall GfxBase FreeCopList          222 801
#pragma  libcall GfxBase ClipBlit             228 65432910809
#pragma  libcall GfxBase XorRectRegion        22E 9802
#pragma  libcall GfxBase FreeCprList          234 801
#pragma  libcall GfxBase GetColorMap          23A 001
#pragma  libcall GfxBase FreeColorMap         240 801
#pragma  libcall GfxBase GetRGB4              246 0802
#pragma  libcall GfxBase ScrollVPort          24C 801
#pragma  libcall GfxBase UCopperListInit      252 0802
#pragma  libcall GfxBase FreeGBuffers         258 09803
#pragma  libcall GfxBase BltBitMapRastPort    25E 65432910809
#pragma  libcall GfxBase OrRegionRegion       264 9802
#pragma  libcall GfxBase XorRegionRegion      26A 9802
#pragma  libcall GfxBase AndRegionRegion      270 9802
#pragma  libcall GfxBase SetRGB4CM            276 3210805
#pragma  libcall GfxBase BltMaskBitMapRastPort 27C A6543291080A
#pragma  libcall GfxBase AttemptLockLayerRom  28E D01
#pragma  libcall GfxBase GfxNew               294 001
#pragma  libcall GfxBase GfxFree              29A 801
#pragma  libcall GfxBase GfxAssociate         2A0 9802
#pragma  libcall GfxBase BitMapScale          2A6 801
#pragma  libcall GfxBase ScalerDiv            2AC 21003
#pragma  libcall GfxBase TextExtent           2B2 A08904
#pragma  libcall GfxBase TextFit              2B8 321BA08908
#pragma  libcall GfxBase GfxLookUp            2BE 801
#pragma  libcall GfxBase VideoControl         2C4 9802
#pragma  libcall GfxBase OpenMonitor          2CA 0902
#pragma  libcall GfxBase CloseMonitor         2D0 801
#pragma  libcall GfxBase FindDisplayInfo      2D6 001
#pragma  libcall GfxBase NextDisplayInfo      2DC 001
#pragma  libcall GfxBase GetDisplayInfoData   2F4 2109805
#pragma  libcall GfxBase FontExtent           2FA 9802
#pragma  libcall GfxBase ReadPixelLine8       300 9A210806
#pragma  libcall GfxBase WritePixelLine8      306 9A210806
#pragma  libcall GfxBase ReadPixelArray8      30C 9A3210807
#pragma  libcall GfxBase WritePixelArray8     312 9A3210807
#pragma  libcall GfxBase GetVPModeID          318 801
#pragma  libcall GfxBase ModeNotAvailable     31E 001
#pragma  libcall GfxBase EraseRect            32A 3210905
#pragma  libcall GfxBase ExtendFont           330 9802
#pragma  libcall GfxBase StripFont            336 801
#pragma  libcall GfxBase CalcIVG              33C 9802
#pragma  libcall GfxBase AttachPalExtra       342 9802
#pragma  libcall GfxBase ObtainBestPenA       348 9321805
#pragma  libcall GfxBase SetRGB32             354 3210805
#pragma  libcall GfxBase GetAPen              35A 801
#pragma  libcall GfxBase GetBPen              360 801
#pragma  libcall GfxBase GetDrMd              366 801
#pragma  libcall GfxBase GetOutlinePen        36C 801
#pragma  libcall GfxBase LoadRGB32            372 9802
#pragma  libcall GfxBase SetChipRev           378 001
#pragma  libcall GfxBase SetABPenDrMd         37E 210904
#pragma  libcall GfxBase GetRGB32             384 910804
#pragma  libcall GfxBase AllocBitMap          396 8321005
#pragma  libcall GfxBase FreeBitMap           39C 801
#pragma  libcall GfxBase GetExtSpriteA        3A2 9A02
#pragma  libcall GfxBase CoerceMode           3A8 10803
#pragma  libcall GfxBase ChangeVPBitMap       3AE A9803
#pragma  libcall GfxBase ReleasePen           3B4 0802
#pragma  libcall GfxBase ObtainPen            3BA 43210806
#pragma  libcall GfxBase GetBitMapAttr        3C0 1802
#pragma  libcall GfxBase AllocDBufInfo        3C6 801
#pragma  libcall GfxBase FreeDBufInfo         3CC 901
#pragma  libcall GfxBase SetOutlinePen        3D2 0802
#pragma  libcall GfxBase SetWriteMask         3D8 0802
#pragma  libcall GfxBase SetMaxPen            3DE 0802
#pragma  libcall GfxBase SetRGB32CM           3E4 3210805
#pragma  libcall GfxBase ScrollRasterBF       3EA 543210907
#pragma  libcall GfxBase FindColor            3F0 4321B05
#pragma  libcall GfxBase AllocSpriteDataA     3FC 9A02
#pragma  libcall GfxBase ChangeExtSpriteA     402 BA9804
#pragma  libcall GfxBase FreeSpriteData       408 A01
#pragma  libcall GfxBase SetRPAttrsA          40E 9802
#pragma  libcall GfxBase GetRPAttrsA          414 9802
#pragma  libcall GfxBase BestModeIDA          41A 801
#pragma  libcall GfxBase WriteChunkyPixels    420 4A3210807
#endif
#ifdef __STORM__
#pragma tagcall(GfxBase,0x348,ObtainBestPen(a0,d1,d2,d3,a1))
#pragma tagcall(GfxBase,0x3A2,GetExtSprite(a2,a1))
#pragma tagcall(GfxBase,0x3FC,AllocSpriteData(a2,a1))
#pragma tagcall(GfxBase,0x402,ChangeExtSprite(a0,a1,a2,a3))
#pragma tagcall(GfxBase,0x40E,SetRPAttrs(a0,a1))
#pragma tagcall(GfxBase,0x414,GetRPAttrs(a0,a1))
#pragma tagcall(GfxBase,0x41A,BestModeID(a0))
#endif
#ifdef __SASC_60
#pragma  tagcall GfxBase ObtainBestPen        348 9321805
#pragma  tagcall GfxBase GetExtSprite         3A2 9A02
#pragma  tagcall GfxBase AllocSpriteData      3FC 9A02
#pragma  tagcall GfxBase ChangeExtSprite      402 BA9804
#pragma  tagcall GfxBase SetRPAttrs           40E 9802
#pragma  tagcall GfxBase GetRPAttrs           414 9802
#pragma  tagcall GfxBase BestModeID           41A 801
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_GRAPHICS_LIB_H  */
