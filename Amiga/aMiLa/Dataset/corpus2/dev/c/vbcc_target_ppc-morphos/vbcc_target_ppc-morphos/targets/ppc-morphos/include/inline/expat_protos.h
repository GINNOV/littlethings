#ifndef _VBCCINLINE_EXPAT_H
#define _VBCCINLINE_EXPAT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

XML_Parser __XML_ParserCreate_M68K(void *, const XML_Char * encodingName) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define XML_ParserCreate_M68K(encodingName) __XML_ParserCreate_M68K(ExpatBase, (encodingName))

XML_Parser __XML_ParserCreateNS_M68K(void *, const XML_Char * encodingName, XML_Char nsSep) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define XML_ParserCreateNS_M68K(encodingName, nsSep) __XML_ParserCreateNS_M68K(ExpatBase, (encodingName), (nsSep))

XML_Parser __XML_ParserCreate_MM_M68K(void *, const XML_Char * encodingName, const XML_Memory_Handling_Suite * memsuite, const XML_Char * nameSep) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define XML_ParserCreate_MM_M68K(encodingName, memsuite, nameSep) __XML_ParserCreate_MM_M68K(ExpatBase, (encodingName), (memsuite), (nameSep))

XML_Parser __XML_ExternalEntityParserCreate(void *, XML_Parser oldParser, const XML_Char * context, const XML_Char * encodingName) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define XML_ExternalEntityParserCreate(oldParser, context, encodingName) __XML_ExternalEntityParserCreate(ExpatBase, (oldParser), (context), (encodingName))

void __XML_ParserFree(void *, XML_Parser parser) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define XML_ParserFree(parser) __XML_ParserFree(ExpatBase, (parser))

int __XML_Parse(void *, XML_Parser parser, const char * s, int len, int isFinal) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define XML_Parse(parser, s, len, isFinal) __XML_Parse(ExpatBase, (parser), (s), (len), (isFinal))

int __XML_ParseBuffer(void *, XML_Parser parser, int len, int isFinal) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define XML_ParseBuffer(parser, len, isFinal) __XML_ParseBuffer(ExpatBase, (parser), (len), (isFinal))

void * __XML_GetBuffer(void *, XML_Parser parser, int len) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define XML_GetBuffer(parser, len) __XML_GetBuffer(ExpatBase, (parser), (len))

void __XML_SetStartElementHandler(void *, XML_Parser parser, XML_StartElementHandler start) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define XML_SetStartElementHandler(parser, start) __XML_SetStartElementHandler(ExpatBase, (parser), (start))

void __XML_SetEndElementHandler(void *, XML_Parser parser, XML_EndElementHandler end) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define XML_SetEndElementHandler(parser, end) __XML_SetEndElementHandler(ExpatBase, (parser), (end))

void __XML_SetElementHandler(void *, XML_Parser parser, XML_StartElementHandler start, XML_EndElementHandler end) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define XML_SetElementHandler(parser, start, end) __XML_SetElementHandler(ExpatBase, (parser), (start), (end))

void __XML_SetCharacterDataHandler(void *, XML_Parser parser, XML_CharacterDataHandler handler) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define XML_SetCharacterDataHandler(parser, handler) __XML_SetCharacterDataHandler(ExpatBase, (parser), (handler))

void __XML_SetProcessingInstructionHandler(void *, XML_Parser parser, XML_ProcessingInstructionHandler handler) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define XML_SetProcessingInstructionHandler(parser, handler) __XML_SetProcessingInstructionHandler(ExpatBase, (parser), (handler))

void __XML_SetCommentHandler(void *, XML_Parser parser, XML_CommentHandler handler) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define XML_SetCommentHandler(parser, handler) __XML_SetCommentHandler(ExpatBase, (parser), (handler))

void __XML_SetStartCdataSectionHandler(void *, XML_Parser parser, XML_StartCdataSectionHandler start) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define XML_SetStartCdataSectionHandler(parser, start) __XML_SetStartCdataSectionHandler(ExpatBase, (parser), (start))

void __XML_SetEndCdataSectionHandler(void *, XML_Parser parser, XML_EndCdataSectionHandler end) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define XML_SetEndCdataSectionHandler(parser, end) __XML_SetEndCdataSectionHandler(ExpatBase, (parser), (end))

void __XML_SetCdataSectionHandler(void *, XML_Parser parser, XML_StartCdataSectionHandler start, XML_EndCdataSectionHandler end) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define XML_SetCdataSectionHandler(parser, start, end) __XML_SetCdataSectionHandler(ExpatBase, (parser), (start), (end))

void __XML_SetDefaultHandler(void *, XML_Parser parser, XML_DefaultHandler handler) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define XML_SetDefaultHandler(parser, handler) __XML_SetDefaultHandler(ExpatBase, (parser), (handler))

void __XML_SetDefaultHandlerExpand(void *, XML_Parser parser, XML_DefaultHandler handler) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define XML_SetDefaultHandlerExpand(parser, handler) __XML_SetDefaultHandlerExpand(ExpatBase, (parser), (handler))

void __XML_SetExternalEntityRefHandler(void *, XML_Parser parser, XML_ExternalEntityRefHandler handler) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define XML_SetExternalEntityRefHandler(parser, handler) __XML_SetExternalEntityRefHandler(ExpatBase, (parser), (handler))

void __XML_SetExternalEntityRefHandlerArg(void *, XML_Parser parser, void * arg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define XML_SetExternalEntityRefHandlerArg(parser, arg) __XML_SetExternalEntityRefHandlerArg(ExpatBase, (parser), (arg))

void __XML_SetUnknownEncodingHandler(void *, XML_Parser parser, XML_UnknownEncodingHandler handler, void * data) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define XML_SetUnknownEncodingHandler(parser, handler, data) __XML_SetUnknownEncodingHandler(ExpatBase, (parser), (handler), (data))

void __XML_SetStartNamespaceDeclHandler(void *, XML_Parser parser, XML_StartNamespaceDeclHandler start) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define XML_SetStartNamespaceDeclHandler(parser, start) __XML_SetStartNamespaceDeclHandler(ExpatBase, (parser), (start))

void __XML_SetEndNamespaceDeclHandler(void *, XML_Parser parser, XML_EndNamespaceDeclHandler end) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define XML_SetEndNamespaceDeclHandler(parser, end) __XML_SetEndNamespaceDeclHandler(ExpatBase, (parser), (end))

void __XML_SetNamespaceDeclHandler(void *, XML_Parser parser, XML_StartNamespaceDeclHandler start, XML_EndNamespaceDeclHandler end) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define XML_SetNamespaceDeclHandler(parser, start, end) __XML_SetNamespaceDeclHandler(ExpatBase, (parser), (start), (end))

void __XML_SetXmlDeclHandler(void *, XML_Parser parser, XML_XmlDeclHandler handler) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define XML_SetXmlDeclHandler(parser, handler) __XML_SetXmlDeclHandler(ExpatBase, (parser), (handler))

void __XML_SetStartDoctypeDeclHandler(void *, XML_Parser parser, XML_StartDoctypeDeclHandler start) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define XML_SetStartDoctypeDeclHandler(parser, start) __XML_SetStartDoctypeDeclHandler(ExpatBase, (parser), (start))

void __XML_SetEndDoctypeDeclHandler(void *, XML_Parser parser, XML_EndDoctypeDeclHandler end) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define XML_SetEndDoctypeDeclHandler(parser, end) __XML_SetEndDoctypeDeclHandler(ExpatBase, (parser), (end))

void __XML_SetDoctypeDeclHandler(void *, XML_Parser parser, XML_StartDoctypeDeclHandler start, XML_EndDoctypeDeclHandler end) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define XML_SetDoctypeDeclHandler(parser, start, end) __XML_SetDoctypeDeclHandler(ExpatBase, (parser), (start), (end))

void __XML_SetElementDeclHandler(void *, XML_Parser parser, XML_ElementDeclHandler eldecl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define XML_SetElementDeclHandler(parser, eldecl) __XML_SetElementDeclHandler(ExpatBase, (parser), (eldecl))

void __XML_SetAttlistDeclHandler(void *, XML_Parser parser, XML_AttlistDeclHandler attdecl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define XML_SetAttlistDeclHandler(parser, attdecl) __XML_SetAttlistDeclHandler(ExpatBase, (parser), (attdecl))

void __XML_SetEntityDeclHandler(void *, XML_Parser parser, XML_EntityDeclHandler handler) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define XML_SetEntityDeclHandler(parser, handler) __XML_SetEntityDeclHandler(ExpatBase, (parser), (handler))

void __XML_SetUnparsedEntityDeclHandler(void *, XML_Parser parser, XML_UnparsedEntityDeclHandler handler) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define XML_SetUnparsedEntityDeclHandler(parser, handler) __XML_SetUnparsedEntityDeclHandler(ExpatBase, (parser), (handler))

void __XML_SetNotationDeclHandler(void *, XML_Parser parser, XML_NotationDeclHandler handler) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define XML_SetNotationDeclHandler(parser, handler) __XML_SetNotationDeclHandler(ExpatBase, (parser), (handler))

void __XML_SetNotStandaloneHandler(void *, XML_Parser parser, XML_NotStandaloneHandler handler) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-234\n"
	"\tbctrl";
#define XML_SetNotStandaloneHandler(parser, handler) __XML_SetNotStandaloneHandler(ExpatBase, (parser), (handler))

int __XML_GetErrorCode(void *, XML_Parser parser) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define XML_GetErrorCode(parser) __XML_GetErrorCode(ExpatBase, (parser))

const XML_LChar * __XML_ErrorString(void *, int code) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define XML_ErrorString(code) __XML_ErrorString(ExpatBase, (code))

long __XML_GetCurrentByteIndex(void *, XML_Parser parser) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define XML_GetCurrentByteIndex(parser) __XML_GetCurrentByteIndex(ExpatBase, (parser))

XML_Size __XML_GetCurrentLineNumber(void *, XML_Parser parser) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define XML_GetCurrentLineNumber(parser) __XML_GetCurrentLineNumber(ExpatBase, (parser))

XML_Size __XML_GetCurrentColumnNumber(void *, XML_Parser parser) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-264\n"
	"\tbctrl";
#define XML_GetCurrentColumnNumber(parser) __XML_GetCurrentColumnNumber(ExpatBase, (parser))

int __XML_GetCurrentByteCount(void *, XML_Parser parser) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-270\n"
	"\tbctrl";
#define XML_GetCurrentByteCount(parser) __XML_GetCurrentByteCount(ExpatBase, (parser))

const char * __XML_GetInputContext(void *, XML_Parser parser, int * offset, int * size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-276\n"
	"\tbctrl";
#define XML_GetInputContext(parser, offset, size) __XML_GetInputContext(ExpatBase, (parser), (offset), (size))

void __XML_SetUserData(void *, XML_Parser parser, void * p) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-282\n"
	"\tbctrl";
#define XML_SetUserData(parser, p) __XML_SetUserData(ExpatBase, (parser), (p))

void __XML_DefaultCurrent(void *, XML_Parser parser) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-288\n"
	"\tbctrl";
#define XML_DefaultCurrent(parser) __XML_DefaultCurrent(ExpatBase, (parser))

void __XML_UseParserAsHandlerArg(void *, XML_Parser parser) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-294\n"
	"\tbctrl";
#define XML_UseParserAsHandlerArg(parser) __XML_UseParserAsHandlerArg(ExpatBase, (parser))

int __XML_SetBase(void *, XML_Parser parser, const XML_Char * p) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-300\n"
	"\tbctrl";
#define XML_SetBase(parser, p) __XML_SetBase(ExpatBase, (parser), (p))

const XML_Char * __XML_GetBase(void *, XML_Parser parser) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-306\n"
	"\tbctrl";
#define XML_GetBase(parser) __XML_GetBase(ExpatBase, (parser))

int __XML_GetSpecifiedAttributeCount(void *, XML_Parser parser) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-312\n"
	"\tbctrl";
#define XML_GetSpecifiedAttributeCount(parser) __XML_GetSpecifiedAttributeCount(ExpatBase, (parser))

int __XML_GetIdAttributeIndex(void *, XML_Parser parser) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-318\n"
	"\tbctrl";
#define XML_GetIdAttributeIndex(parser) __XML_GetIdAttributeIndex(ExpatBase, (parser))

int __XML_SetEncoding(void *, XML_Parser parser, const XML_Char * encodingName) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-324\n"
	"\tbctrl";
#define XML_SetEncoding(parser, encodingName) __XML_SetEncoding(ExpatBase, (parser), (encodingName))

int __XML_SetParamEntityParsing(void *, XML_Parser parser, int peParsing) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-330\n"
	"\tbctrl";
#define XML_SetParamEntityParsing(parser, peParsing) __XML_SetParamEntityParsing(ExpatBase, (parser), (peParsing))

void __XML_SetReturnNSTriplet(void *, XML_Parser parser, int do_nst) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-336\n"
	"\tbctrl";
#define XML_SetReturnNSTriplet(parser, do_nst) __XML_SetReturnNSTriplet(ExpatBase, (parser), (do_nst))

const XML_LChar * __XML_ExpatVersion(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-342\n"
	"\tbctrl";
#define XML_ExpatVersion() __XML_ExpatVersion(ExpatBase)

XML_Expat_Version __XML_ExpatVersionInfo(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-348\n"
	"\tbctrl";
#define XML_ExpatVersionInfo() __XML_ExpatVersionInfo(ExpatBase)

XML_Bool __XML_ParserReset(void *, XML_Parser parser, const XML_Char * encodingName) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-354\n"
	"\tbctrl";
#define XML_ParserReset(parser, encodingName) __XML_ParserReset(ExpatBase, (parser), (encodingName))

void __XML_SetSkippedEntityHandler(void *, XML_Parser parser, XML_SkippedEntityHandler handler) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-360\n"
	"\tbctrl";
#define XML_SetSkippedEntityHandler(parser, handler) __XML_SetSkippedEntityHandler(ExpatBase, (parser), (handler))

int __XML_UseForeignDTD(void *, XML_Parser parser, XML_Bool useDTD) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-366\n"
	"\tbctrl";
#define XML_UseForeignDTD(parser, useDTD) __XML_UseForeignDTD(ExpatBase, (parser), (useDTD))

const XML_Feature * __XML_GetFeatureList(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-372\n"
	"\tbctrl";
#define XML_GetFeatureList() __XML_GetFeatureList(ExpatBase)

int __XML_StopParser(void *, XML_Parser parser, XML_Bool resumable) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-378\n"
	"\tbctrl";
#define XML_StopParser(parser, resumable) __XML_StopParser(ExpatBase, (parser), (resumable))

int __XML_ResumeParser(void *, XML_Parser parser) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-384\n"
	"\tbctrl";
#define XML_ResumeParser(parser) __XML_ResumeParser(ExpatBase, (parser))

void __XML_GetParsingStatus(void *, XML_Parser parser, XML_ParsingStatus * status) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-390\n"
	"\tbctrl";
#define XML_GetParsingStatus(parser, status) __XML_GetParsingStatus(ExpatBase, (parser), (status))

void __XML_FreeContentModel(void *, XML_Parser parser, XML_Content * model) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-396\n"
	"\tbctrl";
#define XML_FreeContentModel(parser, model) __XML_FreeContentModel(ExpatBase, (parser), (model))

void * __XML_MemMalloc(void *, XML_Parser parser, size_t size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-402\n"
	"\tbctrl";
#define XML_MemMalloc(parser, size) __XML_MemMalloc(ExpatBase, (parser), (size))

void * __XML_MemRealloc(void *, XML_Parser parser, void * ptr, size_t size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-408\n"
	"\tbctrl";
#define XML_MemRealloc(parser, ptr, size) __XML_MemRealloc(ExpatBase, (parser), (ptr), (size))

void __XML_MemFree(void *, XML_Parser parser, void * ptr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-414\n"
	"\tbctrl";
#define XML_MemFree(parser, ptr) __XML_MemFree(ExpatBase, (parser), (ptr))

XML_Parser __XML_ParserCreate(const XML_Char * encodingName) =
	"\tlis\t11,ExpatBase@ha\n"
	"\tlwz\t12,ExpatBase@l(11)\n"
	"\tlwz\t0,-514(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define XML_ParserCreate(encodingName) __XML_ParserCreate((encodingName))

XML_Parser __XML_ParserCreateNS(const XML_Char * encodingName, XML_Char nsSep) =
	"\tlis\t11,ExpatBase@ha\n"
	"\tlwz\t12,ExpatBase@l(11)\n"
	"\tlwz\t0,-520(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define XML_ParserCreateNS(encodingName, nsSep) __XML_ParserCreateNS((encodingName), (nsSep))

XML_Parser __XML_ParserCreate_MM(const XML_Char * encodingName, const XML_Memory_Handling_Suite * memsuite, const XML_Char * nameSep) =
	"\tlis\t11,ExpatBase@ha\n"
	"\tlwz\t12,ExpatBase@l(11)\n"
	"\tlwz\t0,-526(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define XML_ParserCreate_MM(encodingName, memsuite, nameSep) __XML_ParserCreate_MM((encodingName), (memsuite), (nameSep))

#endif /*  _VBCCINLINE_EXPAT_H  */
