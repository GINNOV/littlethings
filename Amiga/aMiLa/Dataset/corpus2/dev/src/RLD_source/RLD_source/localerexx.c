/*
  $Id: localerexx.c,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $
 
  $Log: localerexx.c,v $
  Revision 1.2  1997/10/21 22:35:08  wegge
  Snapshot inden upload af 2.13 i source og binær form

  Revision 1.1  1997/10/21 03:49:58  wegge
  Initial revision

 */

#include "rexx_gls.h"

extern struct RexxGLSBase *RglsBase;

#include "rexx_supp_priv.h"	/* struct RexxMatch_ret */
#include "localerexx_protos.h"
#include "rexx_supp_protos.h"
#include "localerexx.h"
#include "rxslibinlines.h"

/* ARexx support functions. */

VOID GetLocaleString(struct RexxMatch_ret *RMR, struct RexxMsg *RxMsg)
{

  UBYTE *LocaleString = NULL;
  ULONG TempLen, StringNum = 0;
  struct Locale *ThisLocale;
  struct CVa2i_ret CVal;
  KPRINTF_HERE;

  if (RxMsg->rm_Args[2])
    {
      CVa2i(&CVal, RxMsg->rm_Args[2]);
      StringNum = CVal.Value;
    }

  if (StringNum <= 0)
    {
      RMR->ArgStr = CreateArgstring("", 0);
      RMR->Error = RC_OK;
      SetRexxRC(RxMsg, RC_WARN);
    }
  else
    {

      ThisLocale = FindCookie(RxMsg->rm_TaskBlock, (UBYTE *)RxMsg->rm_Args[1]);
      if (ThisLocale == NULL)
	{
	  RMR->ArgStr = CreateArgstring("", 0);
	  RMR->Error = ERR10_018 /* Invalid argument to function. */ ;
	  SetRexxRC(RxMsg, RC_ERROR);
	}

      LocaleString = GetLocaleStr(ThisLocale, StringNum);

      if (LocaleString == NULL)
	{
	  RMR->ArgStr = CreateArgstring("", 0);
	  RMR->Error = RC_OK;
	  SetRexxRC(RxMsg, RC_WARN);
	}
      else
	{
	  TempLen = Strlen(LocaleString);
	  RMR->Error = RC_OK;
	  RMR->ArgStr = CreateArgstring(LocaleString, TempLen);
	  SetRexxRC(RxMsg, RC_OK);
	}

    }
  return;

}

VOID rld_GetSysTime(struct RexxMatch_ret * RMR, struct RexxMsg * RxMsg)
{
  struct DateStamp CurrentTime;
  UBYTE *ArgString;
  struct RexxArg *RxArg;

  KPRINTF_HERE;

  DateStamp(&CurrentTime);
  ArgString = CVi2arg (((ULONG)CurrentTime.ds_Tick / 50) +
		       (CurrentTime.ds_Minute * 60) +
		       (CurrentTime.ds_Days * 24 * 60 * 60), 0);
  RxArg = (struct RexxArg *) (ArgString - 8);
  
  RMR->ArgStr = CreateArgstring(ArgString, RxArg->ra_Length);
  DeleteArgstring(ArgString);
  
  RMR->Error = RC_OK;
}

VOID SupOpenLocale(struct RexxMatch_ret * RMR, struct RexxMsg * RxMsg)
{
  UBYTE *Cookie;
  struct Locale *ThisLocale;
  KPRINTF_HERE;

  ThisLocale = OpenLocale(RxMsg->rm_Args[1]);

  if (ThisLocale)
    SetRexxRC(RxMsg, RC_OK);

  if (ThisLocale == NULL)
    {
      ThisLocale = OpenLocale(NULL);
      SetRexxRC(RxMsg, RC_WARN);
    }

  Cookie = AddCookie(RxMsg->rm_TaskBlock, ThisLocale);

  RMR->ArgStr = CreateArgstring(Cookie, 8);
  RMR->Error = RC_OK;
}

VOID SupCloseLocale(struct RexxMatch_ret *RMR, struct RexxMsg *RxMsg)
{

  /* DelCookie handles the actual closing of the locale. */
  KPRINTF_HERE;

  DelCookie(RxMsg->rm_TaskBlock, (UBYTE *)RxMsg->rm_Args[1]);

  RMR->ArgStr = CreateArgstring("", 0);
  RMR->Error = RC_OK;
  SetRexxRC(RxMsg, RC_OK);
}

VOID GetLocaleVars(struct RexxMatch_ret *RMR, struct RexxMsg *RxMsg)
{
  struct Locale *ThisLocale;
  UBYTE *VarNames, *TmpRes;
  ULONG Length1, Length2;
  LONG  NumericVal;
  struct RexxArg *RxArg;

  KPRINTF_HERE;
  
  ThisLocale = FindCookie(RxMsg->rm_TaskBlock, (UBYTE *)RxMsg->rm_Args[1]);
  if (ThisLocale == NULL)
    {
      RMR->ArgStr = CreateArgstring("", 0);
      RMR->Error = ERR10_018 /* Invalid argument to function. */ ;
      SetRexxRC(RxMsg, RC_ERROR);
      return;
    }

  Length1 = Strlen(RxMsg->rm_Args[2]);

  if ((VarNames = (UBYTE *) AllocMem(Length1 + 17, MEMF_ANY)) == NULL)
    {
      RMR->ArgStr = CreateArgstring("", 0);
      RMR->Error = ERR10_003;	/* Out of mem. */
      SetRexxRC(RxMsg, RC_FATAL);
      return;
    }

  StrcpyN(VarNames, RxMsg->rm_Args[2], Length1);

  StrcpyN((VarNames + Length1), ".LOCALENAME", 12);
  Length2 = Strlen(ThisLocale->loc_LocaleName);
  SetRexxVar((struct Message *) RxMsg, VarNames,
	     ThisLocale->loc_LocaleName, Length2); 

  StrcpyN((VarNames + Length1), ".LANGUAGE", 10);
  Length2 = Strlen(ThisLocale->loc_LanguageName);
  SetRexxVar((struct Message *) RxMsg, VarNames,
	     ThisLocale->loc_LanguageName, Length2); 


  StrcpyN((VarNames + Length1), ".DATETIME", 10);
  Length2 = Strlen(ThisLocale->loc_DateTimeFormat);
  SetRexxVar((struct Message *) RxMsg, VarNames,
	     ThisLocale->loc_DateTimeFormat, Length2); 

  StrcpyN((VarNames + Length1), ".DATEFORMAT", 12);
  Length2 = Strlen(ThisLocale->loc_DateFormat);
  SetRexxVar((struct Message *) RxMsg, VarNames,
	     ThisLocale->loc_DateFormat, Length2); 

  StrcpyN((VarNames + Length1), ".TIMEFORMAT", 12);
  Length2 = Strlen(ThisLocale->loc_TimeFormat);
  SetRexxVar((struct Message *) RxMsg, VarNames,
	     ThisLocale->loc_TimeFormat, Length2); 


  StrcpyN((VarNames + Length1), ".SHORTDATETIME", 15);
  Length2 = Strlen(ThisLocale->loc_ShortDateTimeFormat);
  SetRexxVar((struct Message *) RxMsg, VarNames,
	     ThisLocale->loc_ShortDateTimeFormat, Length2); 

  StrcpyN((VarNames + Length1), ".SHORTDATEFORMAT", 17);
  Length2 = Strlen(ThisLocale->loc_ShortDateFormat);
  SetRexxVar((struct Message *) RxMsg, VarNames,
	     ThisLocale->loc_ShortDateFormat, Length2); 

  StrcpyN((VarNames + Length1), ".SHORTTIMEFORMAT", 17);
  Length2 = Strlen(ThisLocale->loc_ShortTimeFormat);
  SetRexxVar((struct Message *) RxMsg, VarNames,
	     ThisLocale->loc_ShortTimeFormat, Length2); 

  StrcpyN((VarNames + Length1), ".GMTOFFSET", 11);
  NumericVal = ThisLocale->loc_GMTOffset;
  TmpRes = CVi2arg(NumericVal, 0);
  RxArg = (struct RexxArg *) (TmpRes - 8);
  RMR->Error = SetRexxVar((struct Message *) RxMsg, VarNames, TmpRes,
			  RxArg->ra_Length); 

  /* Clean Up */

  FreeMem(VarNames, Length1 + 17);

  /* Normal exit */

  RMR->ArgStr = CreateArgstring("", 0);
  SetRexxRC(RxMsg, RC_OK);
}

VOID SupFormatDate(struct RexxMatch_ret *RMR, struct RexxMsg *RxMsg)
{

  /* From Arexx' point of view, we're called with:
     
     FormatDate( Locale, Date, Format)
     
     If Date is NULL, we'll return current time & date.
     If Format is NULL, we'll use Locale->loc_DateTimeFormat */

  struct StringHookData FormatedDate;
  struct DateStamp TimeToFormat;
  struct Locale *ThisLocale;
  struct Hook FmtDateHook;
  UBYTE *Fmt = NULL;

  KPRINTF_HERE;
  
  ThisLocale = FindCookie(RxMsg->rm_TaskBlock, (UBYTE *)RxMsg->rm_Args[1]);
  if (ThisLocale == NULL)
    {
      RMR->ArgStr = CreateArgstring("", 0);
      RMR->Error = ERR10_018 /* Invalid argument to function. */ ;
      SetRexxRC(RxMsg, RC_ERROR);
      return;
    }

  /* Are we passed a date, or should we use the current? */

  if (RxMsg->rm_Args[2] == NULL)
    {
      DateStamp(&TimeToFormat);
    }
  else
    {
      ULONG Length1;
      LONG RexxErr;
      UBYTE *TmpVar, *TmpRes;
      struct CVa2i_ret CVR;

      /* If we received a scalar value, we use that. This is an
	 extension to the previous version, which only accepted a stem
	 for this argument. The scalar (if any), is the number of
	 seconds since 1/1-1978 00:00:00 */
      CVa2i(&CVR, RxMsg->rm_Args[2]);

      if (CVR.Digits > 0)
	{
	  TimeToFormat.ds_Days = CVR.Value / (24 * 60 * 60);
	  CVR.Value %= (24 * 60 * 60);
	  TimeToFormat.ds_Minute = CVR.Value / 60 ;
	  TimeToFormat.ds_Tick = (CVR.Value % 60) * 50;
	}
      else
	{
	  /* That was not the case, so we proceed on the assumption
	     that the provided value is the basename on a stem
	     variable. */

	  Length1 = Strlen(RxMsg->rm_Args[2]);

	  if ((TmpVar = (UBYTE *)
	       AllocMem(Length1 + 9, MEMF_ANY | MEMF_CLEAR)) != NULL)
	    {
	      StrcpyN(TmpVar, RxMsg->rm_Args[2], Length1);
	      
	      StrcpyN(TmpVar + Length1, ".SECONDS", 9);
	      RexxErr = GetRexxVar((struct Message *) RxMsg, TmpVar, &TmpRes);
	      
	      if (RexxErr == 0 && TmpRes)
		{
		  CVa2i(&CVR, TmpRes);
		  TimeToFormat.ds_Minute = CVR.Value / 60 ;
		  TimeToFormat.ds_Tick = (CVR.Value % 60) * 50;
		}
	      else
		{
		  TimeToFormat.ds_Minute = -1;
		  TimeToFormat.ds_Tick = -1;
		}
	      
	      StrcpyN(TmpVar + Length1, ".DAYS\0", 6);
	      RexxErr = GetRexxVar((struct Message *) RxMsg, TmpVar, &TmpRes);
	      
	      if (RexxErr == 0 && TmpRes)
		{
		  CVa2i(&CVR, TmpRes);
		  TimeToFormat.ds_Days = CVR.Value;
		}
	      else
		TimeToFormat.ds_Days = -1;
	      
	      FreeMem(TmpVar, Length1 + 9);
	    }
	  else
	    {
	      TimeToFormat.ds_Days = -1;
	      TimeToFormat.ds_Minute = -1;
	      TimeToFormat.ds_Tick = -1;
	    }
	}
    }
  

  /*  If any of the fields of TimeToFormat contains -1, we'll bomb out
      with ERR010_018 (Invalid args). Otherwise everything is OK. */

  if ((TimeToFormat.ds_Days == -1) || (TimeToFormat.ds_Minute == -1))
    {
      RMR->ArgStr = CreateArgstring("", 0);
      RMR->Error = ERR10_018 /* Invalid argument to function. */ ;
      SetRexxRC(RxMsg, RC_ERROR);
      return;
    }

  if ((FormatedDate.Buffer = (UBYTE *)
       AllocMem(MISC_STR_ALLOC, MEMF_ANY)) == NULL)
    {
      RMR->ArgStr = CreateArgstring("", 0);
      RMR->Error = ERR10_003 /* Not enough memory. */ ;
      SetRexxRC(RxMsg, RC_FATAL);
      return;
    }
  else
    {
      FormatedDate.BufLen = MISC_STR_ALLOC;
      FormatedDate.BufPos = 0;
    }


  FmtDateHook.h_Entry = &StringWriteHook;
  FmtDateHook.h_Data = &FormatedDate;

  if (RxMsg->rm_Args[3])
    Fmt = RxMsg->rm_Args[3];
  else
    Fmt = ThisLocale->loc_DateTimeFormat;

  FormatDate(ThisLocale, Fmt, &TimeToFormat, &FmtDateHook);

  RMR->ArgStr = CreateArgstring(FormatedDate.Buffer,
				Strlen(FormatedDate.Buffer)); 
  RMR->Error = RC_OK;
  SetRexxRC(RxMsg, RC_OK);

  FreeMem(FormatedDate.Buffer, FormatedDate.BufLen);

}

VOID SupParseDate(struct RexxMatch_ret *RMR, struct RexxMsg *RxMsg)
{

  /* From Arexx point of view, we're called with:
     
     ParseDate( Locale, Date, Format, DateString)
     
     If Format is NULL, we'll use Locale->loc_DateTimeFormat */

  struct StringHookData FormatedDate;
  struct DateStamp ParsedTime;
  struct Locale *ThisLocale;
  struct Hook ParseDateHook;
  UBYTE *Fmt = NULL;
  ULONG ParseDate_Res;

  KPRINTF_HERE;

  ThisLocale = FindCookie(RxMsg->rm_TaskBlock, (UBYTE *)RxMsg->rm_Args[1]);
  if (ThisLocale == NULL)
    {
      RMR->ArgStr = CreateArgstring("", 0);
      RMR->Error = ERR10_018 /* Invalid argument to function. */ ;
      SetRexxRC(RxMsg, RC_ERROR);
      return;
    }

  if (RxMsg->rm_Args[3] == NULL)
    Fmt = ThisLocale->loc_DateTimeFormat;
  else
    Fmt = RxMsg->rm_Args[3];

  if (RxMsg->rm_Args[4] == NULL)
    {
      RMR->ArgStr = CreateArgstring("", 0);
      RMR->Error = ERR10_018 /* Invalid argument to function. */ ;
      SetRexxRC(RxMsg, RC_ERROR);
      return;
    }

  ParseDateHook.h_Entry = &StringReadHook;
  ParseDateHook.h_Data = &FormatedDate;

  FormatedDate.Buffer = RxMsg->rm_Args[4];
  FormatedDate.BufPos = 0;
  FormatedDate.BufLen = Strlen(RxMsg->rm_Args[4]);

  if ((ParseDate_Res =
       ParseDate(ThisLocale, &ParsedTime, Fmt, &ParseDateHook)) == FALSE)
    {
      RMR->ArgStr = CreateArgstring("0", 1);
      RMR->Error = RC_OK;
      SetRexxRC(RxMsg, RC_OK);
      return;
    }
  else
    {
      ULONG Length1;
      UBYTE *DstVar;
      UBYTE *TmpRes;

      Length1 = Strlen(RxMsg->rm_Args[2]);

      if ((DstVar = (UBYTE *) 
	   AllocMem(Length1 + 9, MEMF_ANY | MEMF_CLEAR)) != NULL)
	{
	  ULONG Seconds;
	  struct RexxArg *RxArg;

	  StrcpyN(DstVar, RxMsg->rm_Args[2], Length1);

	  StrcpyN(DstVar + Length1, ".DAYS", 6);
	  TmpRes = CVi2arg(ParsedTime.ds_Days, 0);

	  RxArg = (struct RexxArg *) (TmpRes - 8);

	  SetRexxVar((struct Message *) RxMsg, DstVar, TmpRes,
		     RxArg->ra_Length); 
	  DeleteArgstring(TmpRes);

	  Seconds = (ParsedTime.ds_Minute * 60) +
	    ((ULONG)ParsedTime.ds_Tick / 50); 

	  StrcpyN(DstVar + Length1, ".SECONDS", 9);
	  TmpRes = CVi2arg(Seconds, 0);

	  RxArg = (struct RexxArg *) (TmpRes - 8);

	  SetRexxVar((struct Message *) RxMsg, DstVar, TmpRes,
		     RxArg->ra_Length); 
	  DeleteArgstring(TmpRes);

	  FreeMem(DstVar, Length1 + 9);

	}
      else
	{
	  RMR->ArgStr = CreateArgstring("0", 1);
	  RMR->Error = ERR10_003;	/* No memory */
	  SetRexxRC(RxMsg, RC_FATAL);
	  return;
	}
    }

  /* Contrary to what we did previously, we are going to return the
     number of seconds since 1/1-1978 00:00:00, in case of
     success. This shouldn't break any existing scripts, since people
     normally test on existance of a value, and not a specific on, as
     in 'IF (Foo = ParseDate( ...) THEN' */
  
  {
      UBYTE *ArgString;
      struct RexxArg *RxArg;
      ArgString = CVi2arg (((ULONG)ParsedTime.ds_Tick / 50) +
			   (ParsedTime.ds_Minute * 60) +
			   (ParsedTime.ds_Days * 24 * 60 * 60), 0);
      RxArg = (struct RexxArg *) (ArgString - 8);

      RMR->ArgStr = CreateArgstring(ArgString, RxArg->ra_Length);
      DeleteArgstring(ArgString);
  }
  
  RMR->Error = RC_OK;
  SetRexxRC(RxMsg, RC_OK);
  return;
}

/* Support for the support functions (Yuck!) */

struct Locale *FindCookie(struct RexxTask *TaskID, UBYTE *Cookie)
{

  struct RexxRsrc *Res_Node;
  
  /*  Find the Locale which corresponds to Cookie, and return a
      pointer to it, or NULL if not found. */

  KPRINTF_HERE;

  Res_Node = FindRsrcNode(&TaskID->rt_Header3, Cookie, RRT_LIB);
  
  if (Res_Node != NULL)
    return ((struct Locale *)Res_Node->rr_Arg2);
  else
    return NULL;
}

UBYTE *AddCookie(struct RexxTask *TaskID, struct Locale *AddLocale)
{

  /*  Add the Locale to the list of opened Locales, and return the
      cookie connected with it, or 0 in case of a failure. */

  struct RexxRsrc *Res_Node;
  UBYTE  *Id_String;

  KPRINTF_HERE;

  /* We're going to write, so we need exclusive locking. */
  ObtainSemaphore(&RglsBase->RexxGLS_Sem);

  Id_String = AllocMem(9,MEMF_ANY);
  if (Id_String != NULL)
    {
      I2X((ULONG)TaskID, Id_String);
      
      /* Allocate a Resource node, and link it to the Memory allocation list */

      Res_Node = AddRsrcNode(&TaskID->rt_Header3,Id_String,32);
      
      if ( Res_Node != NULL)
	{
	  Res_Node->rr_Func = 0;
	  Res_Node->rr_Base = &Release_Locale;
	  Res_Node->rr_Node.ln_Type=RRT_LIB;
      
	  Res_Node->rr_Arg1 = (LONG)RglsBase;
	  Res_Node->rr_Arg2 = (LONG)AddLocale;
	  
	  RglsBase->CookieCount++;
	  
	  ReleaseSemaphore(&RglsBase->RexxGLS_Sem);
	  return Id_String;
	}
      else
	FreeMem(Id_String,9);
    }
  
  ReleaseSemaphore(&RglsBase->RexxGLS_Sem);
  return NULL;
  
}

VOID DelCookie(struct RexxTask *TaskID, UBYTE *Cookie)
{

  /* Find the Locale which corresponds to Cookie, and remove it from
     the list of opened Locales. */ 

  struct RexxRsrc *Res_Node;

  KPRINTF_HERE;
  
  Res_Node = FindRsrcNode(&TaskID->rt_Header3, Cookie, RRT_LIB);
  
  if (Res_Node != NULL)
    RemRsrcNode(Res_Node);
    
}

ULONG StringWriteHook(struct Hook *ThisHook __asm("a0"),
		      ULONG AddChr __asm("a1"), struct Locale
		      *ThisLocale __asm("a2"))
{
  struct StringHookData *ThisString = 
    (struct StringHookData *) ThisHook->h_Data;

  /* Room to add another character? */

  if (ThisString->BufPos >= ThisString->BufLen)
    {
      /* Extend the string. In this particular case, we extend it with
	 MISC_STR_ALLOC bytes each time. */

      UBYTE *NewBuf;
      ULONG NewLen;

      NewLen = ThisString->BufLen + MISC_STR_ALLOC;

      if ((NewBuf = (UBYTE *) AllocMem(NewLen, MEMF_ANY)) == NULL)
	return (0L);		/* What else to do? */

      /* Move the old buffer contents, and adjust pointers */

      CopyMem(ThisString->Buffer, NewBuf, ThisString->BufLen);
      FreeMem(ThisString->Buffer, ThisString->BufLen);

      ThisString->Buffer = NewBuf;
      ThisString->BufLen = NewLen;
    }


  *(ThisString->Buffer + ThisString->BufPos++) = AddChr;
  return (0L);
}

ULONG StringReadHook(struct Hook *ThisHook __asm("a0"),
		      ULONG AddChr __asm("a1"), struct Locale
		      *ThisLocale __asm("a2"))
{
  struct StringHookData *ThisString = (struct StringHookData *)
    ThisHook->h_Data; 

  if (ThisString->BufPos < ThisString->BufLen)
    return ((ULONG) * (ThisString->Buffer + ThisString->BufPos++));
  else
    return (0L);

}

VOID I2X(ULONG val, UBYTE *buf)
{
  /* Translate a longword to 8 HEX digits. */
  unsigned long tmp,cnt;

  KPRINTF_HERE;
  
  for (cnt = 0; cnt <=7;cnt++)
    {
      tmp = ((val & 0xF0000000) >> 28);
      val = ((val << 4) & 0xFFFFFFF0);
      buf[cnt] = ((tmp < 10) ? tmp+48 : tmp+55);
    }
  buf[8]='\0';
}

VOID Release_Locale(struct RexxRsrc *Node __asm("a0"), 
		    ULONG Base __asm("a6"))
{
  KPRINTF_HERE;

  ObtainSemaphore(&RglsBase->RexxGLS_Sem);
  CloseLocale((struct Locale *)Node->rr_Arg2);
  RglsBase->CookieCount--;
  ReleaseSemaphore(&RglsBase->RexxGLS_Sem);

}
