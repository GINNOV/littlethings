
#include	"mytypes.h" 


ULONG system_time();
LONG OpenDevice();
VOID CloseDevice();
LONG DoIO();





ULONG system_time( seconds )
ULONG seconds;
{
  STATIC STRUCT timerequest TI;


  if( OpenDevice("timer.device", (long)UNIT_MICROHZ, &TI, NULL))
	return(NULL);
		/* opendevice() returns error code */

  TI.tr_node.io_Message.mn_Node.ln_Type = NT_MESSAGE;
  TI.tr_node.io_Message.mn_Node.ln_Pri  = 2;
  TI.tr_node.io_Message.mn_Node.ln_Name = "timerIO";
  TI.tr_node.io_Message.mn_ReplyPort = NULL;

  TI.tr_time.tv_micro = NULL;

  if( seconds ){
  	TI.tr_time.tv_secs = seconds;
  	TI.tr_node.io_Command = TR_SETSYSTIME;
	(void)DoIO(&TI);
  }
  else {
  	TI.tr_node.io_Command = TR_GETSYSTIME;
  	(void)DoIO(&TI);
	seconds = TI.tr_time.tv_secs;
  }

  CloseDevice( &TI );
  return( seconds );
}




