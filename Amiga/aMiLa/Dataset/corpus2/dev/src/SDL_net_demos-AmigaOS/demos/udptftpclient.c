#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#ifndef _MSC_VER
#include <unistd.h>
#endif
#include <SDL/SDL.h>
#include <SDL/SDL_net.h>

#define TIMEOUT (5000) //five seconds
#define ERROR (0xff)

int udpsend(UDPsocket sock, int channel, UDPpacket *out, UDPpacket *in, Uint32 delay, Uint8 expect, int timeout)
{
    Uint32 t,t2;
    int err;
    
    in->data[0]=0;
    t=SDL_GetTicks();
    do
    {
        t2=SDL_GetTicks();
        if(t2-t>(Uint32) timeout)
        {
            printf("timed out\n");
            return(0);
        }
        if(!SDLNet_UDP_Send(sock, channel, out))
        {
            printf("SDLNet_UDP_Send: %s\n",SDLNet_GetError());
            exit(1);
        }
        err=SDLNet_UDP_Recv(sock, in);
        if(!err)
            SDL_Delay(delay);
    } while(!err || (in->data[0]!=expect && in->data[0]!=ERROR));
    if(in->data[0]==ERROR)
        printf("received error code\n");
    return(in->data[0]==ERROR?-1:1);
}

int udprecv(UDPsocket sock, UDPpacket *in, Uint32 delay, Uint8 expect, int timeout)
{
    Uint32 t,t2;
    int err;
    
    in->data[0]=0;
    t=SDL_GetTicks();
    do
    {
        t2=SDL_GetTicks();
        if(t2-t>(Uint32) timeout)
        {
            //printf("timed out\n"); // this is commented to look nicer...
            return(0);
        }
        err=SDLNet_UDP_Recv(sock, in);
        if(!err)
            SDL_Delay(delay);
    } while(!err || (in->data[0]!=expect && in->data[0]!=ERROR));
    if(in->data[0]==ERROR)
        printf("received error code\n");
    return(in->data[0]==ERROR?-1:1);
}

int main(int argc, char **argv)
{
    Uint16 port;
    char *host,*fname,*fbasename;
    Sint32 flen,pos,p2;
    int len,blocks,i,err=0;
    Uint32 ack;
    IPaddress ip;
    UDPsocket sock;
    UDPpacket *in, *out;
    FILE *f;
    
    // check our commandline
    if(argc<4)
    {
        printf("%s host port file\n",argv[0]);
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

    // get the host from the commandline
    host=argv[1];
    // get the port from the commandline
    port=(Uint16) strtol(argv[2],NULL,0);
    if(!port)
    {
        printf("a server port cannot be 0.\n");
        exit(3);
    }
    // get filename to get from server from commandline
    fname=argv[3];

    if(SDLNet_ResolveHost(&ip,host,port)==-1)
    {
        printf("SDLNet_ResolveHost: %s\n",SDLNet_GetError());
        exit(4);
    }
    
    // open udp client socket
    if(!(sock=SDLNet_UDP_Open(0)))
    {
        printf("SDLNet_UDP_Open: %s\n",SDLNet_GetError());
        exit(5);
    }

    // allocate max packet
    if(!(out=SDLNet_AllocPacket(65535)))
    {
        printf("SDLNet_AllocPacket: %s\n",SDLNet_GetError());
        exit(6);
    }
    if(!(in=SDLNet_AllocPacket(65535)))
    {
        printf("SDLNet_AllocPacket: %s\n",SDLNet_GetError());
        exit(6);
    }
    
    // bind server address to channel 0
    if(SDLNet_UDP_Bind(sock, 0, &ip)==-1)
    {
        printf("SDLNet_UDP_Bind: %s\n",SDLNet_GetError());
        exit(7);
    }

    // open output file
    fbasename=strrchr(fname,'/');
    if(!fbasename)
        fbasename=fname;
    else
        fbasename++;
    printf("writting file: %s\n",fbasename);
    if(!(f=fopen(fbasename,"wb")))
    {
        perror("fopen");
        exit(8);
    }

    // request file / expect filesize
    printf("requesting file=%s\n",fname);
    out->data[0]=1<<4;
    strcpy(out->data+1,fname);
    out->len=strlen(fname)+2;
    if(udpsend(sock,0,out,in,200,1,TIMEOUT)<1)
        exit(9);
    
    flen=SDLNet_Read32(in->data+1);
    len=SDLNet_Read32(in->data+5);
    blocks=(flen+len-1)/len;
    printf("flen=%d blocksize=%d blocks=%d\n",flen,len,blocks);

    // send ready / expect file
    printf("starting transfer\n");
    out->data[0]=2<<4;
    out->len=1;
    if(udpsend(sock,0,out,in,10,2,TIMEOUT)<1)
        exit(10);
    
    if(flen<0)
    {
        printf("file not available...\n");
        exit(11);
    }

    pos=0; // count per 32 blocks
    while(pos*32<blocks && !err)
    {
        //printf("pos=%d\n",pos);
        ack=0;
        if((pos+1)*32>=blocks)
        {
            for(i=blocks%32;i<32;i++)
                ack|=1<<i;
        }
        printf("\r                                                                  "
                "\r%3d%% %08x: ",(pos*3200)/blocks,pos*32*len);
        while(ack!=0xffffffff && !err)
        {
            i=in->data[1];
            p2=SDLNet_Read32(in->data+2);
            //printf("received %d,%d\n",i,p2);
            if(!(ack&1<<i) && p2>=pos*32*len)
            {
                fseek(f,p2,SEEK_SET);
                fwrite(in->data+6,in->len-6,1,f);
                ack|=1<<i;

                printf(".");
                fflush(stdout);
            }
            if(ack!=0xffffffff)
                err=udprecv(sock,in,10,2,500);
            if(err<0)
                continue; // error...
            if(!err)
            {
                //printf("sending ack 0x%0X\n",ack);
                out->data[0]=3<<4;
                SDLNet_Write32(pos*32*len,out->data+1);
                SDLNet_Write32(ack,out->data+5);
                out->len=9;
                SDLNet_UDP_Send(sock,0,out);
            }
            err=0;
        }
        pos++;
    }
    
    printf("\ndone.\n");

    fclose(f);
    
    // close the socket
    SDLNet_UDP_Close(sock);
    
    // free packets
    SDLNet_FreePacket(out);
    SDLNet_FreePacket(in);
    
    // shutdown SDL_net
    SDLNet_Quit();

    // shutdown SDL
    SDL_Quit();

    return(0);
}
