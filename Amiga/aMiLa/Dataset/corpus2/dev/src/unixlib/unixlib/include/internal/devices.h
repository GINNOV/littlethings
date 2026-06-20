#ifndef DEVICES_H
#define DEVICES_H

struct IORequest *_device_open(char *name, unsigned long unit, unsigned long flags,
			       void *data, unsigned long data_len, int req_size);

void _device_close(struct IORequest *ioreq);

#endif
