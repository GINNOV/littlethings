/*
  $Id: rexx_gls_base.h,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $

  $Log: rexx_gls_base.h,v $
  Revision 1.2  1997/10/21 22:35:08  wegge
  Snapshot inden upload af 2.13 i source og binær form

  Revision 1.1  1997/10/21 03:49:58  wegge
  Initial revision

 */

#if !defined(REXX_GLS_BASE_H)
#define REXX_GLS_BASE_H

/* Our own library base. */

struct RexxGLSBase
  {
    /* Exec uses this to keep track of the library. */
    struct Library rgls_lib;
    /* No use whatsoever, but needed to keep us at longword
       alignment. */ 
    UWORD rgls_pad;		
    /* Store the SegList for the time when the library is expunged. */
    APTR rgls_seglist;

    /* Other library bases */
    struct DosLibrary   *rgls_DOSBase;
    struct RxsLib       *rgls_RexxSysBase;
    struct ExecBase     *rgls_SYSBase;
    struct UtilityBase  *rgls_UtilityBase;
    struct LocaleBase   *rgls_LocaleBase;

    /* We use this semaphore to guard against race conditions, when
       updating the internal variables. */
    
    struct SignalSemaphore RexxGLS_Sem;

    /* We don't keep track of the opened locales, only the
       count. Instead, we let ARexx tell us when a script terminates
       without cleaning up after itself. */

    ULONG CookieCount;
  };

#endif /* REXX_GLS_BASE_H */
