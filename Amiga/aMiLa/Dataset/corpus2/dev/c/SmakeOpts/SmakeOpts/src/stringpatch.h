#ifndef _STRINGPATCH_H
#define _STRINGPATCH_H
/*
**  stringpatch.h
**
**    ©1995 by AMS-Aloha Microsystems
**    ©1995 by Thomas Herold
**
**    Macros and externs for patched stringclass gadgets.
*/

extern struct Hook StringPatchHook;

#define PatchedString(label,contents,maxchars,id)\
	StringObject,\
		LAB_Label,      label,\
		RidgeFrame,\
		STRINGA_TextVal,    contents,\
		STRINGA_MaxChars,   maxchars+1,\
		STRINGA_EditHook,   &StringPatchHook,\
		GA_ID,          id,\
	EndObject

#define PatchedKeyString(label,contents,maxchars,id)\
	StringObject,\
		LAB_Label,      label,\
		LAB_Underscore,         '_',\
		RidgeFrame,\
		STRINGA_TextVal,    contents,\
		STRINGA_MaxChars,   maxchars+1,\
		STRINGA_EditHook,   &StringPatchHook,\
		GA_ID,          id,\
	EndObject

#define PatchedTabString(label,contents,maxchars,id)\
	StringObject,\
		LAB_Label,      label,\
		RidgeFrame,\
		STRINGA_TextVal,    contents,\
		STRINGA_MaxChars,   maxchars+1,\
		STRINGA_EditHook,   &StringPatchHook,\
		GA_ID,          id,\
		GA_TabCycle,        TRUE,\
	EndObject

#define PatchedTabKeyString(label,contents,maxchars,id)\
	StringObject,\
		LAB_Label,      label,\
		LAB_Underscore,         '_',\
		RidgeFrame,\
		STRINGA_TextVal,    contents,\
		STRINGA_MaxChars,   maxchars+1,\
		STRINGA_EditHook,   &StringPatchHook,\
		GA_ID,          id,\
		GA_TabCycle,        TRUE,\
	EndObject

#define PatchedInteger(label,contents,maxchars,id)\
	StringObject,\
		LAB_Label,      label,\
		RidgeFrame,\
		STRINGA_LongVal,    contents,\
		STRINGA_MaxChars,   maxchars+1,\
		STRINGA_EditHook,   &StringPatchHook,\
		GA_ID,          id,\
	EndObject

#define PatchedKeyInteger(label,contents,maxchars,id)\
	StringObject,\
		LAB_Label,      label,\
		LAB_Underscore,         '_',\
		RidgeFrame,\
		STRINGA_LongVal,    contents,\
		STRINGA_MaxChars,   maxchars+1,\
		STRINGA_EditHook,   &StringPatchHook,\
		GA_ID,          id,\
	EndObject

#define PatchedTabInteger(label,contents,maxchars,id)\
	StringObject,\
		LAB_Label,      label,\
		RidgeFrame,\
		STRINGA_LongVal,    contents,\
		STRINGA_MaxChars,   maxchars+1,\
		STRINGA_EditHook,   &StringPatchHook,\
		GA_ID,          id,\
		GA_TabCycle,        TRUE,\
	EndObject

#define PatchedTabKeyInteger(label,contents,maxchars,id)\
	StringObject,\
		LAB_Label,      label,\
		LAB_Underscore,         '_',\
		RidgeFrame,\
		STRINGA_LongVal,    contents,\
		STRINGA_MaxChars,   maxchars+1,\
		STRINGA_EditHook,   &StringPatchHook,\
		GA_ID,          id,\
		GA_TabCycle,        TRUE,\
	EndObject

/*
**    My own little creation ;-)
*/

#define MyPatchedKeyInteger(label,contents,maxchars,minvisible,min,max,id)\
	StringObject,\
		LAB_Label,              label,\
		LAB_Underscore,  '_',\
		RidgeFrame,\
		STRINGA_LongVal,         contents,\
		STRINGA_MaxChars,        maxchars+1,\
		STRINGA_MinCharsVisible, minvisible,\
		STRINGA_IntegerMax,      max,\
		STRINGA_IntegerMin,      min,\
		STRINGA_EditHook,        &StringPatchHook,\
		GA_ID,          id,\
	EndObject

#endif /* _STRINGPATCH_H */
