#ifndef _INCLUDE_PRAGMA_AML_LIB_H
#define _INCLUDE_PRAGMA_AML_LIB_H

#ifndef CLIB_AML_PROTOS_H
#include <clib/aml_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/aml.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(AmlBase,0x01E,RexxDispatcher(a0))
#pragma amicall(AmlBase,0x024,CreateServerA(a0))
#pragma amicall(AmlBase,0x02A,DisposeServer(a0))
#pragma amicall(AmlBase,0x030,SetServerAttrsA(a0,a1))
#pragma amicall(AmlBase,0x036,GetServerAttrsA(a0,a1))
#pragma amicall(AmlBase,0x03C,GetServerHeaders(a0,d0))
#pragma amicall(AmlBase,0x042,GetServerArticles(a0,a1,a2,d0))
#pragma amicall(AmlBase,0x048,CreateFolderA(a0,a1))
#pragma amicall(AmlBase,0x04E,DisposeFolder(a0))
#pragma amicall(AmlBase,0x054,OpenFolderA(a0,a1))
#pragma amicall(AmlBase,0x05A,SaveFolder(a0))
#pragma amicall(AmlBase,0x060,RemFolder(a0))
#pragma amicall(AmlBase,0x066,SetFolderAttrsA(a0,a1))
#pragma amicall(AmlBase,0x06C,GetFolderAttrsA(a0,a1))
#pragma amicall(AmlBase,0x072,AddFolderArticle(a0,d0,a1))
#pragma amicall(AmlBase,0x078,RemFolderArticle(a0,a1))
#pragma amicall(AmlBase,0x07E,ReadFolderSpool(a0,a1,d0))
#pragma amicall(AmlBase,0x084,WriteFolderSpool(a0,a1,d0))
#pragma amicall(AmlBase,0x08A,ScanFolderIndex(a0,a1,d0))
#pragma amicall(AmlBase,0x090,ExpungeFolder(a0,a1,a2))
#pragma amicall(AmlBase,0x096,CreateFolderIndex(a0))
#pragma amicall(AmlBase,0x09C,SortFolderIndex(a0,d0))
#pragma amicall(AmlBase,0x0A2,CreateArticleA(a0,a1))
#pragma amicall(AmlBase,0x0A8,DisposeArticle(a0))
#pragma amicall(AmlBase,0x0AE,OpenArticle(a0,a1,d0,d1))
#pragma amicall(AmlBase,0x0B4,CopyArticle(a0,a1))
#pragma amicall(AmlBase,0x0BA,SetArticleAttrsA(a0,a1))
#pragma amicall(AmlBase,0x0C0,GetArticleAttrsA(a0,a1))
#pragma amicall(AmlBase,0x0C6,SendArticle(a0,a1,a2))
#pragma amicall(AmlBase,0x0CC,AddArticlePartA(a0,a1,a2))
#pragma amicall(AmlBase,0x0D2,RemArticlePart(a0,d0))
#pragma amicall(AmlBase,0x0D8,GetArticlePart(a0,d0))
#pragma amicall(AmlBase,0x0DE,GetArticlePartAttrsA(a0,a1))
#pragma amicall(AmlBase,0x0E4,SetArticlePartAttrsA(a0,a1))
#pragma amicall(AmlBase,0x0EA,CreateArticlePartA(a0,a1))
#pragma amicall(AmlBase,0x0F0,DisposeArticlePart(a0))
#pragma amicall(AmlBase,0x0F6,GetArticlePartDataA(a0,a1,a2))
#pragma amicall(AmlBase,0x0FC,SetArticlePartDataA(a0,a1))
#pragma amicall(AmlBase,0x102,CreateAddressEntryA(a0))
#pragma amicall(AmlBase,0x108,DisposeAddressEntry(a0))
#pragma amicall(AmlBase,0x10E,OpenAddressEntry(a0,d0))
#pragma amicall(AmlBase,0x114,SaveAddressEntry(a0,a1))
#pragma amicall(AmlBase,0x11A,RemAddressEntry(a0,a1))
#pragma amicall(AmlBase,0x120,GetAddressEntryAttrsA(a0,a1))
#pragma amicall(AmlBase,0x126,SetAddressEntryAttrsA(a0,a1))
#pragma amicall(AmlBase,0x12C,MatchAddressA(a0,a1))
#pragma amicall(AmlBase,0x132,FindAddressEntryA(a0,a1))
#pragma amicall(AmlBase,0x138,HuntAddressEntryA(a0,a1))
#pragma amicall(AmlBase,0x13E,ScanAddressIndex(a0,a1,d0,d1))
#pragma amicall(AmlBase,0x144,AddCustomField(a0,a1,a2))
#pragma amicall(AmlBase,0x14A,RemCustomField(a0,a1))
#pragma amicall(AmlBase,0x150,GetCustomFieldData(a0,a1))
#pragma amicall(AmlBase,0x156,CreateDecoderA(a0))
#pragma amicall(AmlBase,0x15C,DisposeDecoder(a0))
#pragma amicall(AmlBase,0x162,GetDecoderAttrsA(a0,a1))
#pragma amicall(AmlBase,0x168,SetDecoderAttrsA(a0,a1))
#pragma amicall(AmlBase,0x16E,Decode(a0,d0))
#pragma amicall(AmlBase,0x174,Encode(a0,d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall AmlBase RexxDispatcher       01E 801
#pragma  libcall AmlBase CreateServerA        024 801
#pragma  libcall AmlBase DisposeServer        02A 801
#pragma  libcall AmlBase SetServerAttrsA      030 9802
#pragma  libcall AmlBase GetServerAttrsA      036 9802
#pragma  libcall AmlBase GetServerHeaders     03C 0802
#pragma  libcall AmlBase GetServerArticles    042 0A9804
#pragma  libcall AmlBase CreateFolderA        048 9802
#pragma  libcall AmlBase DisposeFolder        04E 801
#pragma  libcall AmlBase OpenFolderA          054 9802
#pragma  libcall AmlBase SaveFolder           05A 801
#pragma  libcall AmlBase RemFolder            060 801
#pragma  libcall AmlBase SetFolderAttrsA      066 9802
#pragma  libcall AmlBase GetFolderAttrsA      06C 9802
#pragma  libcall AmlBase AddFolderArticle     072 90803
#pragma  libcall AmlBase RemFolderArticle     078 9802
#pragma  libcall AmlBase ReadFolderSpool      07E 09803
#pragma  libcall AmlBase WriteFolderSpool     084 09803
#pragma  libcall AmlBase ScanFolderIndex      08A 09803
#pragma  libcall AmlBase ExpungeFolder        090 A9803
#pragma  libcall AmlBase CreateFolderIndex    096 801
#pragma  libcall AmlBase SortFolderIndex      09C 0802
#pragma  libcall AmlBase CreateArticleA       0A2 9802
#pragma  libcall AmlBase DisposeArticle       0A8 801
#pragma  libcall AmlBase OpenArticle          0AE 109804
#pragma  libcall AmlBase CopyArticle          0B4 9802
#pragma  libcall AmlBase SetArticleAttrsA     0BA 9802
#pragma  libcall AmlBase GetArticleAttrsA     0C0 9802
#pragma  libcall AmlBase SendArticle          0C6 A9803
#pragma  libcall AmlBase AddArticlePartA      0CC A9803
#pragma  libcall AmlBase RemArticlePart       0D2 0802
#pragma  libcall AmlBase GetArticlePart       0D8 0802
#pragma  libcall AmlBase GetArticlePartAttrsA 0DE 9802
#pragma  libcall AmlBase SetArticlePartAttrsA 0E4 9802
#pragma  libcall AmlBase CreateArticlePartA   0EA 9802
#pragma  libcall AmlBase DisposeArticlePart   0F0 801
#pragma  libcall AmlBase GetArticlePartDataA  0F6 A9803
#pragma  libcall AmlBase SetArticlePartDataA  0FC 9802
#pragma  libcall AmlBase CreateAddressEntryA  102 801
#pragma  libcall AmlBase DisposeAddressEntry  108 801
#pragma  libcall AmlBase OpenAddressEntry     10E 0802
#pragma  libcall AmlBase SaveAddressEntry     114 9802
#pragma  libcall AmlBase RemAddressEntry      11A 9802
#pragma  libcall AmlBase GetAddressEntryAttrsA 120 9802
#pragma  libcall AmlBase SetAddressEntryAttrsA 126 9802
#pragma  libcall AmlBase MatchAddressA        12C 9802
#pragma  libcall AmlBase FindAddressEntryA    132 9802
#pragma  libcall AmlBase HuntAddressEntryA    138 9802
#pragma  libcall AmlBase ScanAddressIndex     13E 109804
#pragma  libcall AmlBase AddCustomField       144 A9803
#pragma  libcall AmlBase RemCustomField       14A 9802
#pragma  libcall AmlBase GetCustomFieldData   150 9802
#pragma  libcall AmlBase CreateDecoderA       156 801
#pragma  libcall AmlBase DisposeDecoder       15C 801
#pragma  libcall AmlBase GetDecoderAttrsA     162 9802
#pragma  libcall AmlBase SetDecoderAttrsA     168 9802
#pragma  libcall AmlBase Decode               16E 0802
#pragma  libcall AmlBase Encode               174 0802
#endif
#ifdef __STORM__
#pragma tagcall(AmlBase,0x024,CreateServer(a0))
#pragma tagcall(AmlBase,0x030,SetServerAttrs(a0,a1))
#pragma tagcall(AmlBase,0x036,GetServerAttrs(a0,a1))
#pragma tagcall(AmlBase,0x048,CreateFolder(a0,a1))
#pragma tagcall(AmlBase,0x054,OpenFolder(a0,a1))
#pragma tagcall(AmlBase,0x066,SetFolderAttrs(a0,a1))
#pragma tagcall(AmlBase,0x06C,GetFolderAttrs(a0,a1))
#pragma tagcall(AmlBase,0x0A2,CreateArticle(a0,a1))
#pragma tagcall(AmlBase,0x0BA,SetArticleAttrs(a0,a1))
#pragma tagcall(AmlBase,0x0C0,GetArticleAttrs(a0,a1))
#pragma tagcall(AmlBase,0x0CC,AddArticlePart(a0,a1,a2))
#pragma tagcall(AmlBase,0x0DE,GetArticlePartAttrs(a0,a1))
#pragma tagcall(AmlBase,0x0E4,SetArticlePartAttrs(a0,a1))
#pragma tagcall(AmlBase,0x0EA,CreateArticlePart(a0,a1))
#pragma tagcall(AmlBase,0x0F6,GetArticlePartData(a0,a1,a2))
#pragma tagcall(AmlBase,0x0FC,SetArticlePartData(a0,a1))
#pragma tagcall(AmlBase,0x102,CreateAddressEntry(a0))
#pragma tagcall(AmlBase,0x120,GetAddressEntryAttrs(a0,a1))
#pragma tagcall(AmlBase,0x126,SetAddressEntryAttrs(a0,a1))
#pragma tagcall(AmlBase,0x12C,MatchAddress(a0,a1))
#pragma tagcall(AmlBase,0x132,FindAddressEntry(a0,a1))
#pragma tagcall(AmlBase,0x138,HuntAddressEntry(a0,a1))
#pragma tagcall(AmlBase,0x156,CreateDecoder(a0))
#pragma tagcall(AmlBase,0x162,GetDecoderAttrs(a0,a1))
#pragma tagcall(AmlBase,0x168,SetDecoderAttrs(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall AmlBase CreateServer         024 801
#pragma  tagcall AmlBase SetServerAttrs       030 9802
#pragma  tagcall AmlBase GetServerAttrs       036 9802
#pragma  tagcall AmlBase CreateFolder         048 9802
#pragma  tagcall AmlBase OpenFolder           054 9802
#pragma  tagcall AmlBase SetFolderAttrs       066 9802
#pragma  tagcall AmlBase GetFolderAttrs       06C 9802
#pragma  tagcall AmlBase CreateArticle        0A2 9802
#pragma  tagcall AmlBase SetArticleAttrs      0BA 9802
#pragma  tagcall AmlBase GetArticleAttrs      0C0 9802
#pragma  tagcall AmlBase AddArticlePart       0CC A9803
#pragma  tagcall AmlBase GetArticlePartAttrs  0DE 9802
#pragma  tagcall AmlBase SetArticlePartAttrs  0E4 9802
#pragma  tagcall AmlBase CreateArticlePart    0EA 9802
#pragma  tagcall AmlBase GetArticlePartData   0F6 A9803
#pragma  tagcall AmlBase SetArticlePartData   0FC 9802
#pragma  tagcall AmlBase CreateAddressEntry   102 801
#pragma  tagcall AmlBase GetAddressEntryAttrs 120 9802
#pragma  tagcall AmlBase SetAddressEntryAttrs 126 9802
#pragma  tagcall AmlBase MatchAddress         12C 9802
#pragma  tagcall AmlBase FindAddressEntry     132 9802
#pragma  tagcall AmlBase HuntAddressEntry     138 9802
#pragma  tagcall AmlBase CreateDecoder        156 801
#pragma  tagcall AmlBase GetDecoderAttrs      162 9802
#pragma  tagcall AmlBase SetDecoderAttrs      168 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_AML_LIB_H  */
