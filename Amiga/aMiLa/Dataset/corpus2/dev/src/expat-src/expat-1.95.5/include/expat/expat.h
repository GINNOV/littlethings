/*
**      $VER: expat.h 1.2 (1.95.5) (9/9/02)
**
**      main include file for expat.library
**
*/

#ifndef EXPAT_EXPAT_H
#define EXPAT_EXPAT_H


#ifndef XMLPARSEAPI
#if defined(_MSC_EXTENSIONS) && !defined(__BEOS__) && !defined(__CYGWIN__)
#ifdef _STATIC
#define XMLPARSEAPI(type) type __cdecl
#else
#define XMLPARSEAPI(type) __declspec(dllimport) type __cdecl
#endif
#else
#define XMLPARSEAPI(type) type
#endif
#endif  /* not defined XMLPARSEAPI */

#ifdef __cplusplus
extern "C" {
#endif
  
#ifdef XML_UNICODE_WCHAR_T 
#define XML_UNICODE
#endif

struct XML_ParserStruct;
typedef struct XML_ParserStruct *XML_Parser;

#ifdef XML_UNICODE     /* Information is UTF-16 encoded. */
#ifdef XML_UNICODE_WCHAR_T
typedef wchar_t XML_Char;
typedef wchar_t XML_LChar;
#else
typedef unsigned short XML_Char;
typedef char XML_LChar;
#endif /* XML_UNICODE_WCHAR_T */
#else                  /* Information is UTF-8 encoded. */
typedef char XML_Char;
typedef char XML_LChar;
#endif /* XML_UNICODE */

/* Should this be defined using stdbool.h when C99 is available? */
typedef unsigned char XML_Bool;
#define XML_TRUE   ((XML_Bool) 1)
#define XML_FALSE  ((XML_Bool) 0)

enum XML_Error {
  XML_ERROR_NONE,
  XML_ERROR_NO_MEMORY,
  XML_ERROR_SYNTAX,
  XML_ERROR_NO_ELEMENTS,
  XML_ERROR_INVALID_TOKEN,
  XML_ERROR_UNCLOSED_TOKEN,
  XML_ERROR_PARTIAL_CHAR,
  XML_ERROR_TAG_MISMATCH,
  XML_ERROR_DUPLICATE_ATTRIBUTE,
  XML_ERROR_JUNK_AFTER_DOC_ELEMENT,
  XML_ERROR_PARAM_ENTITY_REF,
  XML_ERROR_UNDEFINED_ENTITY,
  XML_ERROR_RECURSIVE_ENTITY_REF,
  XML_ERROR_ASYNC_ENTITY,
  XML_ERROR_BAD_CHAR_REF,
  XML_ERROR_BINARY_ENTITY_REF,
  XML_ERROR_ATTRIBUTE_EXTERNAL_ENTITY_REF,
  XML_ERROR_MISPLACED_XML_PI,
  XML_ERROR_UNKNOWN_ENCODING,
  XML_ERROR_INCORRECT_ENCODING,
  XML_ERROR_UNCLOSED_CDATA_SECTION,
  XML_ERROR_EXTERNAL_ENTITY_HANDLING,
  XML_ERROR_NOT_STANDALONE,
  XML_ERROR_UNEXPECTED_STATE,
  XML_ERROR_ENTITY_DECLARED_IN_PE,
  XML_ERROR_FEATURE_REQUIRES_XML_DTD,
  XML_ERROR_CANT_CHANGE_FEATURE_ONCE_PARSING
};

enum XML_Content_Type {
  XML_CTYPE_EMPTY = 1,
  XML_CTYPE_ANY,
  XML_CTYPE_MIXED,
  XML_CTYPE_NAME,
  XML_CTYPE_CHOICE,
  XML_CTYPE_SEQ
};

enum XML_Content_Quant {
  XML_CQUANT_NONE,
  XML_CQUANT_OPT,
  XML_CQUANT_REP,
  XML_CQUANT_PLUS
};

typedef struct XML_cp XML_Content;

struct XML_cp {
  enum XML_Content_Type        type;
  enum XML_Content_Quant    quant;
  XML_Char *            name;
  unsigned int            numchildren;
  XML_Content *            children;
};

typedef void (*XML_ElementDeclHandler) (void *userData,
                                        const XML_Char *name,
                                        XML_Content *model);

typedef void (*XML_AttlistDeclHandler) (void           *userData,
                                        const XML_Char *elname,
                                        const XML_Char *attname,
                                        const XML_Char *att_type,
                                        const XML_Char *dflt,
                                        int        isrequired);
typedef void (*XML_XmlDeclHandler) (void        *userData,
                                    const XML_Char    *version,
                                    const XML_Char    *encoding,
                                    int              standalone);


typedef struct {
  void *(*malloc_fcn)(size_t size);
  void *(*realloc_fcn)(void *ptr, size_t size);
  void (*free_fcn)(void *ptr);
} XML_Memory_Handling_Suite;


typedef void (*XML_StartElementHandler)(void *userData,
                                        const XML_Char *name,
                                        const XML_Char **atts);

typedef void (*XML_EndElementHandler)(void *userData,
                                      const XML_Char *name);

/* s is not 0 terminated. */
typedef void (*XML_CharacterDataHandler)(void *userData,
                                         const XML_Char *s,
                                         int len);

/* target and data are 0 terminated */
typedef void (*XML_ProcessingInstructionHandler)(void *userData,
                                                 const XML_Char *target,
                                                 const XML_Char *data);

/* data is 0 terminated */
typedef void (*XML_CommentHandler)(void *userData, const XML_Char *data);

typedef void (*XML_StartCdataSectionHandler)(void *userData);
typedef void (*XML_EndCdataSectionHandler)(void *userData);

typedef void (*XML_DefaultHandler)(void *userData,
                                   const XML_Char *s,
                                   int len);

/* This is called for the start of the DOCTYPE declaration, before
   any DTD or internal subset is parsed. */

typedef void (*XML_StartDoctypeDeclHandler)(void *userData,
                                            const XML_Char *doctypeName,
                                            const XML_Char *sysid,
                                            const XML_Char *pubid,
                                            int has_internal_subset);

typedef void (*XML_EndDoctypeDeclHandler)(void *userData);

typedef void (*XML_EntityDeclHandler) (void *userData,
                                       const XML_Char *entityName,
                                       int is_parameter_entity,
                                       const XML_Char *value,
                                       int value_length,
                                       const XML_Char *base,
                                       const XML_Char *systemId,
                                       const XML_Char *publicId,
                                       const XML_Char *notationName);

typedef void (*XML_UnparsedEntityDeclHandler)(void *userData,
                                              const XML_Char *entityName,
                                              const XML_Char *base,
                                              const XML_Char *systemId,
                                              const XML_Char *publicId,
                                              const XML_Char *notationName);

typedef void (*XML_NotationDeclHandler)(void *userData,
                                        const XML_Char *notationName,
                                        const XML_Char *base,
                                        const XML_Char *systemId,
                                        const XML_Char *publicId);

typedef void (*XML_StartNamespaceDeclHandler)(void *userData,
                                              const XML_Char *prefix,
                                              const XML_Char *uri);

typedef void (*XML_EndNamespaceDeclHandler)(void *userData,
                                            const XML_Char *prefix);

typedef int (*XML_NotStandaloneHandler)(void *userData);

typedef int (*XML_ExternalEntityRefHandler)(XML_Parser parser,
                                            const XML_Char *context,
                                            const XML_Char *base,
                                            const XML_Char *systemId,
                                            const XML_Char *publicId);

typedef void (*XML_SkippedEntityHandler)(void *userData,
                                         const XML_Char *entityName,
                                         int is_parameter_entity);

typedef struct {
  int map[256];
  void *data;
  int (*convert)(void *data, const char *s);
  void (*release)(void *data);
} XML_Encoding;

typedef int (*XML_UnknownEncodingHandler)(void *encodingHandlerData,
                                          const XML_Char *name,
                                          XML_Encoding *info);

enum XML_Status {                                                          
   XML_STATUS_ERROR = 0,
#define XML_STATUS_ERROR XML_STATUS_ERROR
   XML_STATUS_OK = 1
#define XML_STATUS_OK XML_STATUS_OK
};

enum XML_ParamEntityParsing {
  XML_PARAM_ENTITY_PARSING_NEVER,
  XML_PARAM_ENTITY_PARSING_UNLESS_STANDALONE,
  XML_PARAM_ENTITY_PARSING_ALWAYS
};

/* For backwards compatibility with previous versions. */
#define XML_GetErrorLineNumber   XML_GetCurrentLineNumber
#define XML_GetErrorColumnNumber XML_GetCurrentColumnNumber
#define XML_GetErrorByteIndex    XML_GetCurrentByteIndex

typedef struct {
  int major;
  int minor;
  int micro;
} XML_Expat_Version;

/* Added in Expat 1.95.5. */
enum XML_FeatureEnum {
  XML_FEATURE_END = 0,
  XML_FEATURE_UNICODE,
  XML_FEATURE_UNICODE_WCHAR_T,
  XML_FEATURE_DTD,
  XML_FEATURE_CONTEXT_BYTES,
  XML_FEATURE_MIN_SIZE,
  XML_FEATURE_SIZEOF_XML_CHAR,
  XML_FEATURE_SIZEOF_XML_LCHAR
  /* Additional features must be added to the end of this enum. */
};

typedef struct {
  enum XML_FeatureEnum  feature;
  XML_LChar            *name;
  long int              value;
} XML_Feature;

/* Expat follows the GNU/Linux convention of odd number minor version for
   beta/development releases and even number minor version for stable
   releases. Micro is bumped with each release, and set to 0 with each
   change to major or minor version.
*/
#define XML_MAJOR_VERSION 1
#define XML_MINOR_VERSION 95
#define XML_MICRO_VERSION 5

#define XML_GetUserData(parser) (*(void **)(parser))

#ifdef __cplusplus
}
#endif

#endif /* EXPAT_EXPAT_H */
