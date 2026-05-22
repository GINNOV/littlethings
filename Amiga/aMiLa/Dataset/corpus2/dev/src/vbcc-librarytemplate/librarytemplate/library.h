#ifndef LIBRARY_H
#define LIBRARY_H

#include <exec/libraries.h>
#include <dos/dos.h>

/**
 * @file library.h
 *
 * Template library initialisation for use with VBCC.
 *
 * Configure your own library as follows using libraryconfig.h:
 *
 * 1) Include your library struct as \n
 *    struct MyBase \n
 *      { \n
 *      struct Library iLibrary; \n
 *      UWORD iPadding; \n
 *      BPTR iSegmentList; \n
 *      struct ExecBase* iSysBase; \n
 *      ..My Data Here.. \n
 *      }; \n
 *
 *    Declare the functions of your library, i.e. \n
 *    LONG MyExampleFunction1( 
 *       __reg("a6") struct MyBase* aMyBase ); \n
 *    LONG MyExampleFunction2( 
 *       __reg("a6") struct MyBase* aMyBase,
 *       __reg("d0") LONG aX ); \n
 *    VOID MyExampleFunction3(
 *       __reg("a6") struct MyBase* aMyBase ); \n
 * 2) Set some steering defines: \n
 *    The name of your library: \n
 *    #define LIBRARY_NAME "my.library" \n
 *    The version string: \n
 *    #define LIBRARY_VERSION_STRING "\0$VER: my 23.42 (dd.mm.yyyy)\r\n" \n
 *    The pointer to the start of "version my.library" output: \n
 *    #define LIBRARY_VERSION_OUTPUT &LIBRARY_VERSION_STRING[7] \n
 *    The version: \n
 *    #define LIBRARY_VERSION 23 \n
 *    The revision: \n
 *    #define LIBRARY_REVISION 42 \n
 *    The base type of your library as you defined it: \n
 *    #define LIBRARY_BASE_TYPE struct MyBase \n
 *    The pointers to the functions provided by your library, \n
 *    casted to APTR: \n
 *    #define LIBRARY_FUNCTIONS ( APTR ) MyExampleFunction1, \ \n
 *                              ( APTR ) MyExampleFunction2, \ \n
 *                              ( APTR ) MyExampleFunction3 \n
 * 3) Define the two functions: \n
 *    a) BOOL CustomLibInit( struct MyBase* aBase ); \n
 *    b) VOID CustomLibCleanup( struct MyBase* aBase ); \n
 *    See below for details. \n
 * 4) Define your functions. \n
 * 5) Do NEVER use global calls like OpenLibrary in your library code,
 *    use something like __OpenLibrary( myBase->iSysBase, ... ) instead. \n
 * 6) Do NOT use amiga.lib or anything else ending with .lib. \n
 * 7) Compile and link everything together. Take care library.o is the
 *    object file linked first. \n
 * 8) Write a matching sfd file and use fd2pragma to create your includes.
 *    Hint: special 38, 70 and 12 are interesting for VBCC.
 */
#include "libraryconfig.h"

/**
 * Initializes the custom part of the library base data structure.
 *
 * The custom part of the structure ("..My Data Here..") should be
 * initialised by this function. If something goes wrong, abort the
 * function and return with TRUE.
 *
 * @param aBase Pointer to the libraries base data structure.
 * @return FALSE on success, TRUE on failure.
 */
BOOL CustomLibInit( LIBRARY_BASE_TYPE* aBase );

/**
 * Cleans up the custom part of the library base data structure.
 *
 * Frees all memory allocated, closes all libraries opened and
 * releases all resources blocked by CustomLibInit.
 * The implementation shall have in mind, that CustomLibInit
 * might not been run to completion, so every library pointer
 * shall be checked etc.!
 *
 * @param aBase Pointer to the libraries base data structure.
 */
VOID CustomLibCleanup( LIBRARY_BASE_TYPE* aBase );

/**
 * Empty startup function.
 *
 * Has to be the first function defined in the library to prevent
 * random behaviour if somebody just executes the library.
 *
 * @return Returns command not found (-1).
 */
LONG _start( VOID );

/**
 * Library base structure factory function.
 *
 * It initializes the data owned by the opened library when the
 * library is loaded.
 *
 * @param aBase Presumably empty, but not zerofied, preallocated memory,
 *              where the data should be created.
 * @param aSegmentList Pointer to the segment list of the library,
 *                     needed for expunging it later.
 * @param aSysBase Exec/SysBase to use throughout the library
 * @return Pointer to the initialised data structure on success,
 *         NULL on failure, when library has been expunged cleanly.
 */
LIBRARY_BASE_TYPE* _LibInit(
  __reg("a6") struct ExecBase* aSysBase,
  __reg("a0") BPTR aSegmentList,
  __reg("d0") LIBRARY_BASE_TYPE* aBase );

/**
 * Entry point called by the function OpenLibrary().
 *
 * Increases the usage counter and deletes the
 * delayed expunge flag (LIBF_DELEXP).
 *
 * @param aBase Pointer to the libraries base data structure.
 * @return The provided library base structure.
 */
LIBRARY_BASE_TYPE* _LibOpen(
  __reg("a6") LIBRARY_BASE_TYPE* aBase );

/**
 * Entry point called by the function CloseLibrary().
 *
 * Decreases the usage counter and deletes the library base data structure
 * if the delayed expunge flag (LIBF_DELEXP) is set.
 *
 * @param aBase Pointer to the libraries base data structure.
 * @return If the library is no longer used and a delayed expunge was
 *         executed, a pointer to the segment list of the library is
 *         returned for cleaning it up.
 *         Otherwise NULL.
 */
BPTR _LibClose(
  __reg("a6") LIBRARY_BASE_TYPE* aBase );

/**
 * Prepares the library for removal from the system.
 *
 * If the usage counter is zero, all resources that were reserved during
 * initialization are released. This includes removing the library node,
 * closing all libraries used by the library and releasing all resources,
 * including the memory for the library node and the base data structure.
 * If the usage count is not zero, the delayed expunge flag (LIBF_DELEXP)
 * is set.
 *
 * @param aBase Pointer to the libraries base data structure.
 * @return If the library was expunged successfully, a pointer to
 *         the segment list of the library is returned for cleaning it up.
 *         Otherwise NULL is returned and the delayed expunge flag is set.
 */
BPTR _LibExpunge(
  __reg("a6") LIBRARY_BASE_TYPE* aBase );

/**
 * Fourth function vector reserved for future use.
 *
 * At least according to the Amiga RKM. It must always return zero.
 *
 * @param aBase Pointer to the libraries base data structure.
 * @return Always returns zero.
 */
ULONG _LibReserved(
  __reg("a6") LIBRARY_BASE_TYPE* aBase );

/**
 * Data structure identifying the library.
 *
 * Should be located as early as possible in the binary file to
 * decrease the loading overhead.
 */
extern const struct Resident RomTag;

/**
 * Library initialisation table steering the initialisation of the library.
 */
extern const APTR InitTable[];

/**
 * Name of the library.
 */
extern const BYTE LibName[];

/**
 * Id/Version string of the library.
 */
extern const BYTE LibIdString[];

/**
 * Function pointer table of the library.
 */
extern const APTR LibraryFunctions[];

#endif /* LIBRARY_H */
