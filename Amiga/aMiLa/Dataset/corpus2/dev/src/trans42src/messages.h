#ifndef cpp_message_h
#define cpp_message_h

#ifndef _TEXT_ONLY

PRIVATE UBYTE *getmsg(ULONG);

enum {
#define MSG(name, text) MSG_##name,
#include <exec/types.h>

#endif


MSG (NoMemory,          "No memory")
MSG (ErrLine,           "Error at line %ld in \"%s\"\n")
MSG (String,            "%s")
MSG (FileError,         "File error: %s")
MSG (TooLong,           "String too long")
MSG (EOL,               "Unexpected end of line")
MSG (UnexpectedClass,   "Unexpected class")
MSG (NoParen,           "Expected closing ')'")
MSG (ClassUndefined,    "Class \"%s\" not defined")
MSG (UnexpectedDollar,  "Unexpected '$'")
MSG (NoCommand,         "No command specified")
MSG (BadArg,            "Bad argument in directive")
MSG (ClassAlready,      "Class \"%s\" already defined")
MSG (UnknownCommand,    "Unknown command \"%s\"")
MSG (NotLoaded,         "File \"%s\" load failed")
MSG (CorruptList,       "Corrupt language list")
MSG (MaxClasses,        "Maximum of 255 classes")
MSG (EmptyMatch,        "Empty match string")
MSG (OK,                "OK")
MSG (Illegal,           "Illegal phoneme <%s>")
MSG (BadRecurse,        "Recursive rule not terminated")
MSG (Overflow,          "Recursion overflow")

#ifndef _TEXT_ONLY
};
#endif

#endif /* !cpp_message_h */
