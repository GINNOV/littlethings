/*  It greater the obstacle, the more glory in overcoming it.  Moliere   */

/*          Jerry J. Trantow                                             */
/*          1560 A East Irving Place                                     */
/*          Milwaukee, Wi 53202-1460                                     */

/* 30 Nov 88 JJT started program to give correct values for proportional */
/*           Gadget always using the best resolution \w floating point   */
/*  1 Dec 88 Added test for (body==total) instead of /(total+1L)         */
/*  4 Dec 88 Renamed file to Prop.inc                                    */
/* 17 Dec 88 Should be able to use Conditional Operator			 */
/*  2 Jan 89 Added (count+body=total) special case			 */
/*  4 Jan 89 Initialized index=16 saves an instruction			 */
/*  4 Jan 89 Realized I could limit shifts to 16 (any more are wasted)   */
/*  4 Jan 89 Some error is introduced by shifting rather than *0xffff    */
/*  9 Jan 89 Implemented a 32x32=64 bit Multiply for Reverse calculation */
/*           a 64/32=32 bit Divide would simplify the other routine      */
/*           Finished 64/32=64 bit divide                                */
/* 25 Jan 89 Cleaned up the routines                                     */
/* 30 Jan 89 Added 020 Mult routines                                     */
/* 30 Jan 89 NOTE the 020 divide is a 64/32=32 bit divide (not 64 bit)   */
/*  1 Feb 89 Changed over to Harriet Tolly's Names and modified Reverse()*/
/*  1 Feb 89 Added QuadAdd68000 and QuadDiv020 routines			 */

#ifdef machine=MC68020
  #define QuadMult QuadMult020
  #define QuadDiv  QuadDiv020
#else
  #define QuadMult QuadMult68000
  #define QuadDiv  QuadDiv68000
#endif
/* #define QuadAdd  QuadAdd */		/* no particular advantage w/ 020 */

/* Returns proper First value given the current total,body, and pot */
ULONG Prop_Gad_Reverse(total,visible,pot)
FAST ULONG total;
FAST ULONG visible;
FAST ULONG pot;
{
  ULONG quad[2];

  QuadMult(pot,(total-visible),&quad[0]); /* 16 bit * 32 bit multiply	*/
  QuadAdd(0x8000l,&quad[0]);		/* add 2^15 			*/
  QuadDiv(&quad[0],0xffffl);		/* divide by 0xffffl		*/
  return(quad[1]);			/* answer is low ULONG of QUAD	*/ 
}

/* This routine calculates the Body and Pot variables for a Prop Gadget */
/* given the Visible,First, and total */
USHORT Prop_Gad_Calculate(visible,first,total,body,pot)
FAST ULONG visible,first,total;
ULONG *body,*pot;
{
  FAST ULONG quad[2];

  if ((total==0L)||(visible==total)) 	/* Null Hypothesis always true */
  {
    *body=0xffffl;
    *pot=0L;
#ifdef LATTICE
    return((USHORT)0);	/* for some unknown Reason Aztec choked on this */
#else
    return();		
#endif
  }
					/* calculate the BODY	*/
  QuadMult(visible,0xffffl,&quad[0]); 	/* [visible * 0xffffl] 	*/
  QuadDiv(&quad[0],total);		/* [visible * 0x10000l] / total	*/
  *body=quad[1];                	/* answer is lower 32 bits  	*/
  
  if (first+visible >= total)	/* check for error or limit of travel */
    *pot=(LONG)0xffffl;
  else
  { 					/* calculate the POT 		*/
    QuadMult(first,0xffffl,&quad[0]);
    QuadDiv(&quad[0],total-visible); /* [first * 0xffff0000l]/total*/
    *pot=quad[1]; 
  } 
}
