#ifndef tcptimesync_h
#define tcptimesync_h

struct SYNC_PACKET {
	unsigned char type;
	union {
		struct {
			Uint32 s;
			Uint32 c;
		} u;
		struct {
			Sint32 s;
			Sint32 c;
		} s;
	} data;
};

typedef struct SYNC_PACKET SyncPacket;

void sendSyncPacket(TCPsocket sock, SyncPacket *sp)
{
	char tmp[8];
	SDLNet_TCP_Send(sock,&sp->type,1);
	SDLNet_Write32(sp->data.u.s,tmp);
	SDLNet_Write32(sp->data.u.c,tmp+4);
	SDLNet_TCP_Send(sock,tmp,8);
}

void recvSyncPacket(TCPsocket sock, SyncPacket *sp)
{
	char tmp[8];
	SDLNet_TCP_Recv(sock,&sp->type,1);
	SDLNet_TCP_Recv(sock,tmp,8);
	sp->data.u.s=SDLNet_Read32(tmp);
	sp->data.u.c=SDLNet_Read32(tmp+4);
}

void printSyncPacket(SyncPacket *sp)
{
	printf("SyncPacket %8p:\n",sp);
	printf("\ttype=%d\n",sp->type);
	printf("\tdata.u.s=%u\n",sp->data.u.s);
	printf("\tdata.u.c=%u\n",sp->data.u.c);
	printf("\tdata.s.s=%d\n",sp->data.s.s);
	printf("\tdata.s.c=%d\n",sp->data.s.c);
}

#endif
