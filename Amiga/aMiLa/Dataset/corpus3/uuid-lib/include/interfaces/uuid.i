#ifndef UUID_INTERFACE_DEF_H
#define UUID_INTERFACE_DEF_H
/*
** This file is machine generated from idltool
** Do not edit
*/ 

#include <exec/types.i>
#include <exec/exec.i>
#include <exec/interfaces.i>

STRUCTURE UuidIFace, InterfaceData_SIZE
	    FPTR IUuid_Obtain
	    FPTR IUuid_Release
	    FPTR IUuid_Expunge
	    FPTR IUuid_Clone
	    FPTR IUuid_UuidA
	    FPTR IUuid_Uuid
	    FPTR IUuid_FreeUuid
	    FPTR IUuid_UuidToText
	LABEL UuidIFace_SIZE

#endif
