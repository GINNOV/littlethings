#define DEAMON "SecurityDeamon"

#define PASSWD "s:passwords"

#define OK	0x00000000	/*action ok*/
#define LOGIN   0x00000001	/*login a user*/
#define LOGOUT  0x00000002	/*logout a user*/
#define SLEEP   0x00000004	/*goto sleep, do not remain active*/
#define ACTIVE	0x00000008	/*Wake UP, become active*/
#define LOCK	0x00000010	/*Lock Filesystem*/
#define ULOCK	0x00000020	/*Unlock Filesystem*/
#define WHOAMI	0x00000040	/*Who is the current user*/
#define CHANGE	0x00000080	/*Change Password*/

#define QUIT	0x80000000	/*get deamon to quit*/

struct LockList {
	APTR			Locks;
	struct LockList		*Next;
	struct LockList		*Prev;
};

struct CurrentUser {
	char 			Name[100];
	char 			Login[20];
	struct LockList 	*Locks;
	long			UID;
	long			GID;
};


struct SecMessage {
    	struct Message 		LoginMsg;
    	char			Password[100];
    	char			User[100];
   	unsigned long		Control;
    	BOOL			Access;
    	struct CurrentUser	*UserData;
	APTR			Data;
};
