/*
  $Id: rexx_supp_protos.h,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $
  
  $Log: rexx_supp_protos.h,v $
  Revision 1.2  1997/10/21 22:35:08  wegge
  Snapshot inden upload af 2.13 i source og binær form

  Revision 1.1  1997/10/21 03:49:58  wegge
  Initial revision

 */

#if !defined( REXX_SUPP_PROTOS_H )
#define REXX_SUPP_PROTOS_H

VOID QueryPoint(struct RexxMatch_ret * RV, struct RexxMsg * RMsg,
		struct RexxGLSBase * ent_RglsBase);

VOID ArexxMatchPoint(struct RexxMsg * __asm("a1"),
                     struct RexxGLSBase * __asm("a6"));

VOID SetRexxRC(struct RexxMsg *RMsg, LONG RC_Val);

BOOL PerformInit(VOID);

#endif /* REXX_SUPP_PROTOS_H */
