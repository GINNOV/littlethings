/*  :ts=8
 * Code to open various resources under Intuition
 */

#include <exec/types.h>
#include <exec/io.h>

#define REV		0
#define SUB_PORT	"Subtsk Port"
#define	SUB_REPLY	"Subtsk Reply"

#define CMD_HELLO	CMD_NONSTD
#define	CMD_SUICIDE	(CMD_NONSTD + 1)

struct infopacket	*CreateExtIO();

struct infopacket {
	struct Message msg;
	long command;
} *sub_cmd;

struct MsgPort		*subport, *subreply;
struct Task		*subtask;
void			neeto();


openstuff ()
{
	if (!(subreply = CreatePort (SUB_REPLY, 0L)))
		bomb ("I need a reply port.");

	/*  We can get away with this  */
	if (!(sub_cmd = CreateExtIO (subreply, (long) sizeof (*sub_cmd))))
		bomb ("Can't make subtsk ExtIO.");

	subtask = CreateTask ("Neeto", 1, neeto, 2048L);
	if (!(subport = FindPort (SUB_PORT)))
		bomb ("Can't find SUB_PORT.");
}

closestuff ()
{
	if (subtask) {
		if (subport) {
			sub_cmd -> command = CMD_SUICIDE;
			PutMsg (subport, sub_cmd);
			WaitPort (subreply);
			GetMsg (subreply);
		}
		DeleteTask (subtask);
	}
	if (sub_cmd)
		DeleteExtIO (sub_cmd, (long) sizeof (*sub_cmd));
	if (subreply)
		DeletePort (subreply);
}

bomb (str)
char *str;
{
	printf ("%s\n", str);
	closestuff ();
}



/*
 * The sub-task.
 */

void
neeto ()
{
	struct infopacket *cmd;
	struct MsgPort *prgport = NULL;

	/*  Since this is an independent task, we'll have to do
	 *  everything ourselves.....
	 */
	if (!(prgport = CreatePort (SUB_PORT, 1L)))
		goto die;

	/*
	 * Stand around twiddling our thumbs until the main program
	 * wants us to do something.
	 */
	WaitPort (prgport);
	cmd = GetMsg (prgport);
	if (cmd -> command != CMD_HELLO)
		/*
		 * If we come here, then something is very wrong.  Let the
		 * machine crash (we can't do printf's from a task).
		 */
		bomb ("neeto(): Hello???");
	ReplyMsg (cmd);

	while (1) {
		WaitPort (prgport);

		while (cmd = (struct infopacket *) GetMsg (prgport))
			switch (cmd -> command) {
			case CMD_UPDATE:
				cmd -> command = 0;
				ReplyMsg (cmd);
				break;
			case CMD_SUICIDE:
				goto die;
			default:
				ReplyMsg (cmd);
			}
	}
die:
	if (prgport)
		DeletePort (prgport);
	if (cmd)
		/*  This must be the suicide message, so reply it  */
		ReplyMsg (cmd);

	/*  Wait for Godot  */
	Wait (0L);
}

main ()
{
	int i;

	openstuff ();

	sub_cmd -> command = CMD_HELLO;
	PutMsg (subport, sub_cmd);
	WaitPort (subreply);
	GetMsg (subreply);

	for (i=0; i<10; i++) {
		PutMsg (subport, sub_cmd);
		WaitPort (subreply);
		GetMsg (subreply);
		if (i == 6)
			sub_cmd -> command = CMD_UPDATE;
		printf ("command = %ld\n", sub_cmd -> command);
	}

	closestuff ();	/*  This kills off the subtask  */
}
