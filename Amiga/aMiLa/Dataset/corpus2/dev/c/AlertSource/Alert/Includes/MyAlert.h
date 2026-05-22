#include <stdlib.h>
#include <string.h>
#include <intuition/intuition.h>
#include <clib/intuition_protos.h>

// Return TRUE or FALSE if successful and -1 if not.
int MyAlert(unsigned long alertNumber,char *message);

// This is how Intuition's DisplayAlert should have been implemented!
// Feel free to use this routine in you program! 8-) Ketil

int MyAlert(unsigned long alertNumber,char *msg) {
					char	*alertMsg;
register	UBYTE	*p,*c;
register	int		ypos=14,result=0;
register	BOOL	done=FALSE;
					char	*tmp,*message=strdup(msg);

	if(alertMsg=malloc(2500))
	{
		c=alertMsg;
		while(!done)
		{
			tmp=message;
			message=stpchr(message,'\n');
			if(message==NULL)
				done=TRUE;
			++message;

			for(p=tmp; *p!='\n'; ++p);
			*p='\0';

			*((USHORT *)c)=(80-strlen(tmp))<<2;
			c++;
			c++;
			*c++=ypos;
			while(*tmp!='\0')
				*c++=*tmp++;
			*c++=0;
			*c++=1;
			ypos=ypos+11;

		}
		*(c-1)=0;
		result=DisplayAlert(RECOVERY_ALERT,alertMsg,ypos);
		free(alertMsg);
		return result;
	} else
		return -1;

return 0;
}
