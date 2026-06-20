#ifdef _MSC_VER
#error MSVC will not produce a working file, select fails on stdin
#endif

#include <string.h>
#include <sys/types.h>
#ifndef WIN32
#include <unistd.h>
#include <sys/time.h>
#else
#include <windows.h>
#include <time.h>
#endif
#include <stdlib.h>
#include <SDL/SDL.h>
#include <SDL/SDL_thread.h>
#include <SDL/SDL_net.h>
#include "tcputil.h"

#define MAXLEN (10*1024) // 10 KB - adequate for text!

int main(int argc, char **argv)
{
    IPaddress ip;
    TCPsocket sock;
    char message[MAXLEN];
    int numready;
    Uint16 port;
    SDLNet_SocketSet set;
    fd_set fdset;
    int result;
    char *name,*str;
    struct timeval tv;

    // check our commandline
    if(argc<4)
    {
        printf("%s host port username\n",argv[0]);
        exit(0);
    }
    
    name=argv[3];
    
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
        SDL_Quit();
        exit(3);
    }

    set=SDLNet_AllocSocketSet(1);
    if(!set)
    {
        printf("SDLNet_AllocSocketSet: %s\n", SDLNet_GetError());
        SDLNet_Quit();
        SDL_Quit();
        exit(4); //most of the time this is a major error, but do what you want.
    }

    // get the port from the commandline
    port=(Uint16)strtol(argv[2],NULL,0);
    
    // Resolve the argument into an IPaddress type
    printf("Connecting to %s port %d\n",argv[1],port);
    if(SDLNet_ResolveHost(&ip,argv[1],port)==-1)
    {
        printf("SDLNet_ResolveHost: %s\n",SDLNet_GetError());
        SDLNet_Quit();
        SDL_Quit();
        exit(5);
    }

    // open the server socket
    sock=SDLNet_TCP_Open(&ip);
    if(!sock)
    {
        printf("SDLNet_TCP_Open: %s\n",SDLNet_GetError());
        SDLNet_Quit();
        SDL_Quit();
        exit(6);
    }
    
    if(SDLNet_TCP_AddSocket(set,sock)==-1)
    {
        printf("SDLNet_TCP_AddSocket: %s\n",SDLNet_GetError());
        SDLNet_Quit();
        SDL_Quit();
        exit(7);
    }
    
    // login with a name
    if(!putMsg(sock,name))
    {
        SDLNet_TCP_Close(sock);
        SDLNet_Quit();
        SDL_Quit();
        exit(8);
    }

    printf("Logged in as %s\n",name);
    while(1)
    {
        // we poll keyboard every 1/10th of a second...simpler than threads
        // this is fine for a text application
        
        // wait on the socket for 1/10th of a second for data
        numready=SDLNet_CheckSockets(set, 100);
        if(numready==-1)
        {
            printf("SDLNet_CheckSockets: %s\n",SDLNet_GetError());
            break;
        }

        // check to see if the server sent us data
        if(numready && SDLNet_SocketReady(sock))
        {
            // getMsg is in tcputil.h, it gets a string from the socket
            // with a bunch of error handling
            if(!getMsg(sock,&str))
                break;
            // post it to the screen
            printf("%s\n",str);
        }
        
        // set up the file descriptor set
        FD_ZERO(&fdset);
        FD_SET(fileno(stdin),&fdset);
        
        // no waiting ;)
        memset(&tv, 0, sizeof(tv));
        
        // check for keyboard input on stdin
        result=select(fileno(stdin)+1, &fdset, NULL, NULL, &tv);
        if(result==-1)
        {
            perror("select");
            break;
        }

        // is there input?
        if(result && FD_ISSET(fileno(stdin),&fdset))
        {
            // get the string from stdin
            if(!fgets(message,MAXLEN,stdin))
                break;

            // strip the whitespace from the end of the line
            while(strlen(message) && strchr("\n\r\t ",message[strlen(message)-1]))
                message[strlen(message)-1]='\0';

            // if there was a message after stripping the end, 
            // send it to the server
            if(strlen(message))
            {
                //printf("Sending: %s\n",message);
                putMsg(sock,message);
            }
        }
    }

    // shutdown SDL_net
    SDLNet_Quit();

    // shutdown SDL
    SDL_Quit();

    return(0);
}
