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
    IPaddress ip,*remoteip;
    TCPsocket server=NULL,client=NULL;
    Uint32 ipaddr,now,last;
    float lag;
    Uint16 port;
    SyncPacket sp;
    int done;
    int minoff=5; //that's + or -
    
    // check our commandline
    if(argc<2)
    {
        printf("%s port [minoff]\n",argv[0]);
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

    // get the port from the commandline
    port=(Uint16) strtol(argv[1],NULL,0);

    // get the minoff from the commandline
    if(argc>2)
        minoff=strtol(argv[2],NULL,0);

    // Resolve the argument into an IPaddress type
    if(SDLNet_ResolveHost(&ip,NULL,port)==-1)
    {
        printf("SDLNet_ResolveHost: %s\n",SDLNet_GetError());
        exit(3);
    }

    // open the server socket
    server=SDLNet_TCP_Open(&ip);
    if(!server)
    {
        printf("SDLNet_TCP_Open: %s\n",SDLNet_GetError());
        exit(4);
    }

    while(1)
    {
        client=NULL;
        while(!client)
        { // no connection accepted
            client=SDLNet_TCP_Accept(server);
            if(!client)
                SDL_Delay(100); //sleep 1/10th of a second
        }
        
        // get the clients IP and port number
        remoteip=SDLNet_TCP_GetPeerAddress(client);
        if(!remoteip)
        {
            printf("SDLNet_TCP_GetPeerAddress: %s\n",SDLNet_GetError());
            SDLNet_TCP_Close(client);
            continue;
        }

        // print out the clients IP and port number
        ipaddr=SDL_SwapBE32(remoteip->host);
        printf("Accepted a connection from %d.%d.%d.%d port %hu\n",
                ipaddr>>24,
                (ipaddr>>16)&0xff,
                (ipaddr>>8)&0xff,
                ipaddr&0xff,
                remoteip->port);

        done=0;
        lag=0;
        sp.type=0;
        sp.data.u.s=SDL_GetTicks();
        sendSyncPacket(client,&sp);
        now=SDL_GetTicks();
        while(!done)
        {
            last=now;
            recvSyncPacket(client,&sp);
            now=SDL_GetTicks();
            lag=(now-last)/2.0f;
            
            printSyncPacket(&sp);
            switch(sp.type)
            {
                case 0:
                    sp.type=1;
                    sp.data.u.s=SDL_GetTicks()+(Uint32) lag;
                    sendSyncPacket(client,&sp);
                    break;
                case 1:
                    sp.type=2;
                case 2:
                    sp.data.s.c=now-(Uint32) lag-sp.data.u.c;
                    if(sp.data.s.c<minoff && sp.data.s.c>-minoff)
                        /* too strict!
                            && sp.data.s.s<minoff && sp.data.s.s>-minoff)
                        */
                    {
                        sp.type=3;
                        sp.data.u.s=SDL_GetTicks()+(Uint32) lag+minoff*100;
                    }
                    else
                        sp.data.u.s=SDL_GetTicks()+(Uint32) lag;
                    sendSyncPacket(client,&sp);
                    if(sp.type==3)
                    {
                        printf("wait until %u\n",sp.data.u.s);
#ifdef DO_BUSY
                        while(SDL_GetTicks()<sp.data.u.s);
#else
                        SDL_Delay(sp.data.u.s-SDL_GetTicks());
#endif
                        printf("TIME = %u\n",SDL_GetTicks());
                        done=1;
                    }
                    break;
                default:
                    done=1;
                    break;
            }
            printf("now=%u (lag=%.2f)\n",now,lag);
            sp.type=10;
        }

        SDLNet_TCP_Close(client);
    }

    SDLNet_TCP_Close(server);
    
    // shutdown SDL_net
    SDLNet_Quit();

    // shutdown SDL
    SDL_Quit();

    return(0);
}
