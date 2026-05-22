#include <stdlib.h>
#ifndef _MSC_VER
#include <unistd.h>
#endif
#include <SDL/SDL.h>
#include <SDL/SDL_net.h>

int main(int argc, char **argv)
{
    IPaddress ip,*remoteip;
    TCPsocket server,client;
    char message[1024];
    int len;
    Uint32 ipaddr;
    Uint16 port;
    
    // check our commandline
    if(argc<2)
    {
        printf("%s port\n",argv[0]);
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
    port=(Uint16)strtol(argv[1],NULL,0);
    
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
        // try to accept a connection
        client=SDLNet_TCP_Accept(server);
        if(!client)
        { // no connection accepted
            //printf("SDLNet_TCP_Accept: %s\n",SDLNet_GetError());
            SDL_Delay(100); //sleep 1/10th of a second
            continue;
        }
        
        // get the clients IP and port number
        remoteip=SDLNet_TCP_GetPeerAddress(client);
        if(!remoteip)
        {
            printf("SDLNet_TCP_GetPeerAddress: %s\n",SDLNet_GetError());
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

        // read the buffer from client
        len=SDLNet_TCP_Recv(client,message,1024);
        SDLNet_TCP_Close(client);
        if(!len)
        {
            printf("SDLNet_TCP_Recv: %s\n",SDLNet_GetError());
            continue;
        }

        // print out the message
        printf("Received: %.*s\n",len,message);

        if(message[0]=='Q')
        {
            printf("Quitting on a Q received\n");
            break;
        }
    }
    
    // shutdown SDL_net
    SDLNet_Quit();

    // shutdown SDL
    SDL_Quit();

    return(0);
}
