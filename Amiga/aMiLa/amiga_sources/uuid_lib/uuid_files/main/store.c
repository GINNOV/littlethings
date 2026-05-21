/* store.c */

#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/bsdsocket.h>
#include <proto/timer.h>
#include <proto/timezone.h>
#include <libraries/timezone.h>

#include <stdbool.h>
#include <stdio.h>

#define GREGTOAMIGASECS (uint64)12471768000ULL
//12471757200ULL

struct uuid_store {
   int ver;
    bool mac_set;
    UBYTE        mac[6];
    bool clockseq_set;
    uint16 clockseq;
    uint64 lasttime;
    uint8 seq;
};

#define STORE_VER 1
static struct uuid_store store = { 0, false, {0,0,0,0,0,0},
							false, 0, 0, 0xff};

static void store_save(void)
{
	IDOS->SetVar("uuid/store", &store, sizeof(struct uuid_store),
		GVF_GLOBAL_ONLY | GVF_SAVE_VAR | GVF_BINARY_VAR);
}

static bool store_get_random_bytes(UBYTE *ptr, int s)
{
	FILE *rndf = NULL;
	if((rndf = fopen("RANDOM:", "r"))) {
		fread(ptr, 1, s, rndf);
		fclose(rndf);
		return true;
	}
	return false;
}

static void store_set_clockseq(void)
{
	store.clockseq_set = store_get_random_bytes((UBYTE *)&store.clockseq, 2);

	if(store.clockseq_set == false) {
		// couldn't get random bytes
		// not sure what to do here
	}
}

static void store_inc_clockseq(void)
{
	if(store.clockseq_set == true) {
		store.clockseq += 1;
	} else {
		store_set_clockseq();
	}
}

UBYTE *store_get_clockseq(void)
{
	return (UBYTE *)&store.clockseq;
}

UBYTE *store_get_mac(void)
{
	struct Library *SocketBase;
	struct SocketIFace *ISocket;
	UBYTE mac[20];
	
	if(store.mac_set == true) return (UBYTE *)&store.mac;
	
	if((SocketBase = IExec->OpenLibrary("bsdsocket.library",4))) {
		if((ISocket = (struct SocketIFace *)IExec->GetInterface(SocketBase,"main",1,NULL))) {
			struct List *interfaces = NULL;
			struct Node *interface = NULL;
			if((interfaces = ISocket->ObtainInterfaceList())) {
				if((interface = IExec->GetHead(interfaces))) {
#ifdef DEBUG
					IExec->DebugPrintF("Found interface: %s\n", interface->ln_Name);
#endif

					ISocket->QueryInterfaceTags(interface->ln_Name, IFQ_HardwareAddress, &mac, TAG_DONE);
					store.mac_set = true;
					
					if((mac[0] == store.mac[0]) &&
						(mac[1] == store.mac[1]) &&
						(mac[2] == store.mac[2]) &&
						(mac[3] == store.mac[3]) &&
						(mac[4] == store.mac[4]) &&
						(mac[5] == store.mac[5])) {
#ifdef DEBUG
						IExec->DebugPrintF("MAC address: %02x:%02x:%02x:%02x:%02x:%02x\n", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
#endif

					} else {
						store.mac[0] = mac[0];
						store.mac[1] = mac[1];
						store.mac[2] = mac[2];
						store.mac[3] = mac[3];
						store.mac[4] = mac[4];
						store.mac[5] = mac[5];
						store_set_clockseq(); // only if mac has changed otherwise use stored ver
					}
				}
				ISocket->ReleaseInterfaceList(interfaces);
			}
			IExec->DropInterface(ISocket);
		}
		IExec->CloseLibrary(SocketBase);
	}
	
	if(store.mac_set == false) {
	/* unable to obtain a MAC address so make one up */
		store_get_random_bytes((UBYTE *)&store.mac, 6);
		store.mac[0] |= 1;
		store.mac_set = true;

		store_set_clockseq();
	}

	return &store.mac;
}

static void store_load(void)
{
	if(IDOS->GetVar("uuid/store", &store, sizeof(struct uuid_store) - 1,
			GVF_GLOBAL_ONLY | GVF_BINARY_VAR | GVF_DONT_NULL_TERM) == -1) {
		store.ver = STORE_VER;
	} else {
		store.mac_set = false;
		store.seq = 0xff;
	}
}

uint64 store_get_timestamp(void)
{
	struct TimeVal tv;
	uint64 uuidtime;
	int32 offset = 0;

	if(store.ver == 0) store_load();

	if(store.seq < 9) {
		store.seq++;
		return store.lasttime + (uint64)store.seq;
	} else {
		store.seq = 0;
	}

	ITimer->GetSysTime(&tv);

	ITimezone->GetTimezoneAttrs(NULL, TZA_UTCOffset, &offset, TAG_DONE);
	offset *= 60;
	
	uuidtime = (((uint64)tv.Seconds + GREGTOAMIGASECS + offset) * (uint64)10000000) + ((uint64)tv.Microseconds * 10);
	if(store.lasttime == uuidtime) return 0ULL;
	if(store.lasttime > uuidtime) store_inc_clockseq();
	store.lasttime = uuidtime;

	store_save();

	return uuidtime;	
}
