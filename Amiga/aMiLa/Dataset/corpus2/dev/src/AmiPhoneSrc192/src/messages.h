#ifndef MESSAGES_H
#define MESSAGES_H

#define MESSAGE_CONTROLMAIN_INVALID       0	/* Should never occur */
#define MESSAGE_CONTROLMAIN_IMLEAVING	  1	/* Notification of exit by player */
#define MESSAGE_CONTROLMAIN_XMITPACKET    2	/* Request by player to transmit packet */
#define MESSAGE_CONTROLMAIN_PLAYFILE      3	/* Request to launch player */
#define MESSAGE_CONTROLMAIN_REQCLOSED     4	/* Sent by File Requester to tell main to re-enable it's menu item */
#define MESSAGE_CONTROLMAIN_STOPPLAYING   5	/* Sent by whomever to tell Main to Ctrl-c the sound player */
#define MESSAGE_CONTROLMAIN_BROWSEROPEN   6	/* Sent by browser to tell main it's open */
#define MESSAGE_CONTROLMAIN_BROWSERCLOSED 7	/* Sent by browser to tell main it's leaving */

struct PlayerMessage
{
	struct Message Message;
	UBYTE ubControl;
	void * data;
	ULONG ulData2;
};

/* routines for listening to stored messages */
void PlayUserFile(char * szDefaultDir, char * szOptFile);

/* These are for use by amiphone.c */
struct Task * LaunchFileReq(char * szDir);	/* dir to open req in */
struct Task * LaunchPlayer(char * szFile);	/* needs full path! */

BOOL SendPlayerMessage(UBYTE ubControl, void * data, ULONG ulData2, struct MsgPort * WaitForReplyAt);

void RemovePortSafely(struct MsgPort * RemoveMe);

#endif
