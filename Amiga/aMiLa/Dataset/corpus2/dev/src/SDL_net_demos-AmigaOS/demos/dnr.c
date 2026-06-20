#include <stdlib.h>
#ifndef _MSC_VER
#include <unistd.h>
#endif
#include <string.h>
#include <SDL/SDL.h>
#include <SDL/SDL_net.h>

int main(int argc, char **argv)
{
    IPaddress ip;
    char *host;
    Uint8 *ipaddr;
    
    // check our commandline
    if(argc>1 && !strncmp("-h",argv[1],2))
    {
        printf("%s host|ip\n",argv[0]);
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

#ifndef WIN32 // has no gethostname that we can use here...
    {
        char localhostname[256];
        if((gethostname(localhostname, 256)>=0))
        {
            printf("Local Host: %s\n",localhostname);
            printf("Resolving %s\n",localhostname);
            if(SDLNet_ResolveHost(&ip,localhostname,0)==-1)
            {
                printf("Could not resolve host \"%s\"\n%s\n",
                        localhostname,SDLNet_GetError());
            }
            else
            {
                // use the IP as a Uint8[4]
                ipaddr=(Uint8*)&ip.host;

                // output the IP address nicely
                printf("Local IP Address : %d.%d.%d.%d\n",
                        ipaddr[0], ipaddr[1], ipaddr[2], ipaddr[3]);
            }
        }
    }
#endif
    
    if(argc<2)
        exit(0);
    
    // Resolve the argument into an IPaddress type
    printf("Resolving %s\n",argv[1]);
    if(SDLNet_ResolveHost(&ip,argv[1],0)==-1)
    {
        printf("Could not resolve host \"%s\"\n%s\n",argv[1],SDLNet_GetError());
        exit(3);
    }

    // use the IP as a Uint8[4]
    ipaddr=(Uint8*)&ip.host;

    // output the IP address nicely
    printf("IP Address : %d.%d.%d.%d\n",
            ipaddr[0], ipaddr[1], ipaddr[2], ipaddr[3]);

    // resolve the hostname for the IPaddress
    host=SDLNet_ResolveIP(&ip);

    // print out the hostname we got
    if(host)
        printf("Hostname   : %s\n",host);
    else
        printf("No Hostname found\n");

    // shutdown SDL_net
    SDLNet_Quit();

    // shutdown SDL
    SDL_Quit();

    return(0);
}
