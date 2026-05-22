#include <string.h>
#ifndef WIN32
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#else
#include <windows.h>
#include <time.h>
#endif
#include <stdlib.h>
#include <SDL/SDL.h>
#include <SDL/SDL_thread.h>
#include <SDL/SDL_net.h>
#include "tcputil.h"

#define MAXLEN (1*10*1024) // 10 KB - adequate for text

int net_thread_main(void *);
int local_thread_main(void *);

int done=0;
SDL_Thread *net_thread=NULL, *local_thread=NULL;

int main(int argc, char **argv)
{
    IPaddress ip;
    TCPsocket sock;
    Uint16 port;
    char *name;

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

    // get the port from the commandline
    port=(Uint16) strtol(argv[2],NULL,0);
    
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
    
    // login with a name
    if(!putMsg(sock,name))
    {
        SDLNet_TCP_Close(sock);
        SDLNet_Quit();
        SDL_Quit();
        exit(7);
    }

    printf("Logged in as %s\n",name);

    local_thread=SDL_CreateThread(local_thread_main,sock);
    if(!local_thread)
    {
        printf("SDL_CreateThread: %s\n",SDL_GetError());
        SDLNet_Quit();
        SDL_Quit();
        exit(8);
    }
    
    net_thread=SDL_CreateThread(net_thread_main,sock);
    if(!net_thread)
    {
        printf("SDL_CreateThread: %s\n",SDL_GetError());
        SDLNet_Quit();
        SDL_Quit();
        exit(9);
    }
    
    // threads are doing the work now
    // we wait for them to finish on their own...
    SDL_WaitThread(local_thread,NULL);
    SDL_WaitThread(net_thread,NULL);

    // this shows our unique reason where the threads ended
    printf("Finished code %d\n",done);
    
    // shutdown SDL_net
    SDLNet_Quit();

    // shutdown SDL
    SDL_Quit();

    return(0);
}

int local_thread_main(void *data)
{
    TCPsocket sock=(TCPsocket)data;
#ifndef _MSC_VER
    fd_set fdset;
    int result;
#endif
    char message[MAXLEN];

    while(!net_thread && !done)
        SDL_Delay(1);
    
    // this is the local input loop
    while(!done)
    {
#ifndef _MSC_VER
        // set up the file descriptor set
        FD_ZERO(&fdset);
        FD_SET(fileno(stdin),&fdset);
        
        // wait for keyboard input on stdin
        result=select(fileno(stdin)+1, &fdset, NULL, NULL, NULL);
        if(result==-1)
        {
            perror("select");
            done=6;
            break;
        }

        // is there input?
        if(result && FD_ISSET(fileno(stdin),&fdset))
        {
#endif
            // get the string from stdin
            if(!fgets(message,MAXLEN,stdin))
            {
                done=7;
                break;
            }

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
#ifndef _MSC_VER
        }
#endif
    }
    if(!done)
        done=1;
    SDL_KillThread(net_thread);
    return(0);
}

// the network input loop
int net_thread_main(void *data)
{
    TCPsocket sock=(TCPsocket)data;
    SDLNet_SocketSet set;
    int numready;
    char *str=NULL;

    set=SDLNet_AllocSocketSet(1);
    if(!done && !set)
    {
        printf("SDLNet_AllocSocketSet: %s\n", SDLNet_GetError());
        SDLNet_Quit();
        SDL_Quit();
        done=2;
    }

    if(!done && SDLNet_TCP_AddSocket(set,sock)==-1)
    {
        printf("SDLNet_TCP_AddSocket: %s\n",SDLNet_GetError());
        SDLNet_Quit();
        SDL_Quit();
        done=3;
    }
    
    while(!done)
    {
        numready=SDLNet_CheckSockets(set, (Uint32)-1);
        if(numready==-1)
        {
            printf("SDLNet_CheckSockets: %s\n",SDLNet_GetError());
            done=4;
            break;
        }

        // check to see if the server sent us data
        if(numready && SDLNet_SocketReady(sock))
        {
            // getMsg is in tcputil.h, it gets a string from the socket
            // with a bunch of error handling
            if(!getMsg(sock,&str))
            {
                char *errstr=SDLNet_GetError();
                printf("getMsg: %s\n",strlen(errstr)?errstr:"Server disconnected");
                done=5;
                break;
            }
            // post it to the screen
            printf("%s\n",str);
        }
    }
    if(!done)
        done=1;
    SDL_KillThread(local_thread);
    return(0);
}
