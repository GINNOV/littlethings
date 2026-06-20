#include "amiga.h"
#include "devices.h"

struct IORequest *_device_open(char *name, ULONG unit, ULONG flags,
			       APTR data, ULONG data_len, int req_size)
{
    struct MsgPort *port;
    struct IORequest *ioreq;

    if ((port = CreateMsgPort()) && (ioreq = CreateIORequest(port, req_size))) {
	if (data) {
	    struct IOStdReq *io2 = (struct IOStdReq *) ioreq;
	    io2->io_Data = data;
	    io2->io_Length = data_len;
	}
	if (OpenDevice(name, unit, ioreq, flags) == 0)
	    return ioreq;
    }
    if (ioreq)
	DeleteIORequest(ioreq);
    if (port)
	DeletePort(port);
    return 0;
}

void _device_close(struct IORequest *ioreq)
{
    if (ioreq) {
	CloseDevice(ioreq);
	DeletePort(ioreq->io_Message.mn_ReplyPort);
	DeleteIORequest(ioreq);
    }
}
