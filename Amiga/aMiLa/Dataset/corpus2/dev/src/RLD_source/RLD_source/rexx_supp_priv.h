/*
  $Id: rexx_supp_priv.h,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $
  
  $Log: rexx_supp_priv.h,v $
  Revision 1.2  1997/10/21 22:35:08  wegge
  Snapshot inden upload af 2.13 i source og binær form

  Revision 1.1  1997/10/21 03:49:58  wegge
  Initial revision

 */

#if !defined(REXX_SUPP_PRIV_H)
#define REXX_SUPP_PRIV_H

/* The structure we use to return values with. */
struct RexxMatch_ret {
  ULONG Error;
  UBYTE *ArgStr;
};

#endif /* REXX_SUPP_PRIV_H */
