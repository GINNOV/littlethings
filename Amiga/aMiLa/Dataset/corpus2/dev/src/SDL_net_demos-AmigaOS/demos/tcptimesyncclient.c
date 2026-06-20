#include <stdlib.h>
#ifndef _MSC_VER
#include <unistd.h>
#endif
#include <SDL/SDL.h>
#include <SDL/SDL_net.h>
#include "tcptimesync.h"

#define DO_BUSY

int main(int argc, char **argv)
{
    IPaddress ip;
    TCPsocket sock=NULL;
    char *hostname;
    int simlag=0,done=0;
    Sint32 base,now;
    Uint16 port;
    SyncPacket sp;
    float lag=0;
    
    // check our commandline
    if(argc<3)
    {
        printf("%s hostname port lag\n",argv[0]);
        exit(0);
    }
    
    // initialize SDL
    if(SDL_Init(0)==-1)
    {
        printf("SDL_Init: %s\n",SDL_GetError());
        exit(1);
    }

    // initialize SDL_net
    if(SDLNet_Init()==-1)
    {
        printf("SDLNet_Init: %s\n",SDLNet_GetError());
        exit(2);
    }

    // get the desired simulated lag from the commandline
    if(argc>3)
        simlag=strtol(argv[3],NULL,0);
    
    // get the port from the commandline
    port=(Uint16) strtol(argv[2],NULL,0);

    // get the hostname from commandline (for client)
    hostname=argv[1];
    
    // Resolve the argument into an IPaddress type
    if(SDLNet_ResolveHost(&ip,hostname,port)==-1)
    {
        printf("SDLNet_ResolveHost: %s\n",SDLNet_GetError());
        exit(3);
    }

    // open the client socket
    sock=SDLNet_TCP_Open(&ip);
    if(!sock)
    {
        printf("SDLNet_TCP_Open: %s\n",SDLNet_GetError());
        goto endC;
    }

    base=0;
    now=SDL_GetTicks();
    while(!done)
    {
        static Uint32 last;
        
        last=now;
        recvSyncPacket(sock,&sp);
        if(simlag) SDL_Delay(simlag);
        now=SDL_GetTicks();
        lag=(now-last)/2.0f;
        printSyncPacket(&sp);
        if(simlag) SDL_Delay(simlag);
        switch(sp.type)
        {
            case 0:
                base=now-sp.data.u.s;
                sp.data.u.c=now;
                sendSyncPacket(sock,&sp);
                break;
            case 1:
                base-=(Sint32) lag;
                sp.data.u.c=SDL_GetTicks()-base;
                sp.data.s.s=((Sint32)(now-base-sp.data.s.s))/2;
                sendSyncPacket(sock,&sp);
                break;
            case 2:
                base-=sp.data.s.c;
                sp.data.u.c=SDL_GetTicks()-base;
                sp.data.s.s=((Sint32)(now-base-sp.data.s.s+lag))/2;
                sendSyncPacket(sock,&sp);
                break;
            case 3:
                base-=sp.data.s.c;
                printf("wait until %u\n",sp.data.u.s);
#ifdef DO_BUSY
                while(SDL_GetTicks()-base<sp.data.u.s);
#else
                SDL_Delay(sp.data.u.s-(SDL_GetTicks()-base));
#endif
                printf("TIME = %u\n",SDL_GetTicks()-base);
            default:
                done=1;
                break;
        }
        printf("now-base=%u (lag=%.2f)\n",now-base,sp.type?lag:lag*2);
        sp.type=10;
    }
    
    SDLNet_TCP_Close(sock);

endC:
    // shutdown SDL_net
    SDLNet_Quit();

    // shutdown SDL
    SDL_Quit();

    return(0);
}
