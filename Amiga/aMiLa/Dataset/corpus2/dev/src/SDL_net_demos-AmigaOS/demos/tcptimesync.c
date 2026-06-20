#include <stdlib.h>
#ifndef _MSC_VER
#include <unistd.h>
#endif
#include <SDL/SDL.h>
#include <SDL/SDL_net.h>

int main(int argc, char **argv)
{
    IPaddress ip,*remoteip;
    TCPsocket server=NULL,client=NULL,sock=NULL;
    char *hostname;
    int simlag;
    Uint32 ipaddr,t[2],base,now;
    float lag;
    Uint16 port;
    
    // check our commandline
    if(argc<3)
    {
        printf("%s lag port [hostname]\n",argv[0]);
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
    simlag=strtol(argv[1],NULL,0);
    
    // get the port from the commandline
    port=(Uint16) strtol(argv[2],NULL,0);

    // get the hostname from commandline (for client)
    hostname=argc>3?argv[3]:NULL;
    
    // Resolve the argument into an IPaddress type
    if(SDLNet_ResolveHost(&ip,hostname,port)==-1)
    {
        printf("SDLNet_ResolveHost: %s\n",SDLNet_GetError());
        exit(3);
    }

    lag=-1;
    if(!hostname)
    {
        // open the server socket
        server=SDLNet_TCP_Open(&ip);
        if(!server)
        {
            printf("SDLNet_TCP_Open: %s\n",SDLNet_GetError());
            exit(4);
        }

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
            goto endS;
        }

        // print out the clients IP and port number
        ipaddr=SDL_SwapBE32(remoteip->host);
        printf("Accepted a connection from %d.%d.%d.%d port %hu\n",
            ipaddr>>24,
            (ipaddr>>16)&0xff,
            (ipaddr>>8)&0xff,
            ipaddr&0xff,
            remoteip->port);

        base=SDL_GetTicks();
        t[0]=SDL_SwapBE32(0);
        t[1]=SDL_SwapBE32(~0L);
        SDLNet_TCP_Send(client,t,sizeof(t));
        
        SDLNet_TCP_Recv(client,t,sizeof(t));
        now=SDL_GetTicks()-base;
        t[0]=SDL_SwapBE32(t[0]);
        t[1]=SDL_SwapBE32(t[1]);
        lag=(now-t[0])/2.0f;
        printf("S1) now=%u t[0]=%u t[1]=%u (lag=%f)\n",
                now ,t[0], t[1], lag);

        t[0]=SDL_SwapBE32(SDL_GetTicks()-base+(Uint32)lag);
        t[1]=SDL_SwapBE32(t[1]);
        SDLNet_TCP_Send(client,t,sizeof(t));

        SDLNet_TCP_Recv(client,t,sizeof(t));
        now=SDL_GetTicks()-base;
        t[0]=SDL_SwapBE32(t[0]);
        t[1]=SDL_SwapBE32(t[1]);
        lag+=(Sint32)t[0];
        printf("S2) now=%u t[0]=%d t[1]=%u (lag=%f)\n",
                now ,t[0], t[1], lag);

        t[0]=SDL_GetTicks()-base+(Uint32) lag;
        t[0]=SDL_SwapBE32(t[0]);
        t[1]=((Sint32)(now-t[1]))/2;
        t[1]=SDL_SwapBE32(t[1]);
        SDLNet_TCP_Send(client,t,sizeof(t));
        /*for(i=0; i<20; i++)
        {
            printf("Server time : %u\n", SDL_GetTicks()-base);
            fflush(stdout);
            SDL_Delay(50);
        }*/
endS:
        SDLNet_TCP_Close(client);
        SDLNet_TCP_Close(server);
    }
    else
    {
        // open the server socket
        sock=SDLNet_TCP_Open(&ip);
        if(!sock)
        {
            printf("SDLNet_TCP_Open: %s\n",SDLNet_GetError());
            goto endC;
        }

        SDLNet_TCP_Recv(sock,t,sizeof(t));
        if(simlag) SDL_Delay(simlag);
        base=SDL_GetTicks();
        t[0]=SDL_SwapBE32(t[0]);
        printf("C1) t[0]=%u\n",t[0]);

        
        t[0]=SDL_SwapBE32(t[0]);
        t[1]=SDL_SwapBE32(SDL_GetTicks()-base);
        if(simlag) SDL_Delay(simlag);
        SDLNet_TCP_Send(sock,t,sizeof(t));
        
        SDLNet_TCP_Recv(sock,t,sizeof(t));
        if(simlag) SDL_Delay(simlag);
        now=SDL_GetTicks()-base;
        t[0]=SDL_SwapBE32(t[0]);
        t[1]=SDL_SwapBE32(t[1]);
        lag=(now-t[1])/2.0f;
        base-=(Uint32) lag;
        now+=(Uint32) lag;
        printf("C2) now=%u t[0]=%u t[1]=%u (lag=%f)\n",
                now, t[0], t[1], lag);

        t[0]=((Sint32)(now-t[0]))/2;
        t[0]=SDL_SwapBE32(t[0]);
        t[1]=(SDL_GetTicks()-base+(Uint32) lag);
        t[1]=SDL_SwapBE32(t[1]);
        if(simlag) SDL_Delay(simlag);
        SDLNet_TCP_Send(sock,t,sizeof(t));
        
        SDLNet_TCP_Recv(sock,t,sizeof(t));
        if(simlag) SDL_Delay(simlag);
        now=SDL_GetTicks()-base;
        t[0]=SDL_SwapBE32(t[0]);
        t[1]=SDL_SwapBE32(t[1]);
        lag+=(Sint32)t[1];
        base-=(Sint32)t[1];
        now+=(Sint32)t[1];
        printf("C3) now=%u t[0]=%u t[1]=%d (lag=%f)\n",
                now, t[0], t[1], lag);
        /*for(i=0; i<20; i++)
        {
            printf("Client time : %u\n", SDL_GetTicks()-base);
            fflush(stdout);
            SDL_Delay(50);
        }*/
endC:
        SDLNet_TCP_Close(sock);
    }
    
    // shutdown SDL_net
    SDLNet_Quit();

    // shutdown SDL
    SDL_Quit();

    return(0);
}
