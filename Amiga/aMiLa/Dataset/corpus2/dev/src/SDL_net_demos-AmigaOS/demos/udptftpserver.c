#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#ifndef _MSC_VER
#include <unistd.h>
#endif
#include <SDL/SDL.h>
#include <SDL/SDL_net.h>

#define ERROR (0xff)
#define TIMEOUT (5000) //five seconds

int udpsend(UDPsocket sock, int channel, UDPpacket *out, UDPpacket *in, Uint32 delay, Uint8 expect, int timeout)
{
    Uint32 t,t2;
    int err;
    
    in->data[0]=0;
    t=SDL_GetTicks();
    do
    {
        t2=SDL_GetTicks();
        if(t2-t>(Uint32)timeout)
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
        if(t2-t>(Uint32)timeout)
        {
            printf("timed out\n");
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
    char *host,fname[65535];
    int len=1400, plen, err=0;
    Sint32 flen;
    Uint16 port;
    Uint32 ipnum,ack;
    IPaddress ip;
    UDPsocket sock;
    UDPpacket *out, *in, **packets, *outs[32];
    FILE *f=NULL;
    Sint32 p,p2,i;
    
    // check our commandline
    if(argc<2)
    {
        printf("%s port [packet-len]\n",argv[0]);
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
    if(!port)
    {
        printf("a server port cannot be 0.\n");
        exit(3);
    }
    
    if(argc>2)
        len=strtol(argv[2],NULL,0);
    
    // open udp server socket
    if(!(sock=SDLNet_UDP_Open(port)))
    {
        printf("SDLNet_UDP_Open: %s\n",SDLNet_GetError());
        exit(4);
    }
    printf("port %hd opened\n", port);

    // allocate max packet
    if(!(out=SDLNet_AllocPacket(65535)))
    {
        printf("SDLNet_AllocPacket: %s\n",SDLNet_GetError());
        exit(5);
    }
    if(!(in=SDLNet_AllocPacket(65535)))
    {
        printf("SDLNet_AllocPacket: %s\n",SDLNet_GetError());
        exit(5);
    }

    // allocate 32 packets of size len
    if(!(packets=SDLNet_AllocPacketV(32,len)))
    {
        printf("SDLNet_AllocPacket: %s\n",SDLNet_GetError());
        exit(6);
    }
    
    while(1)
    {
        if(f)
        {
            fclose(f);
            f=NULL;
        }
        SDLNet_UDP_Unbind(sock, 0);
        in->data[0]=0;
        printf("waiting...\n");
        while(!SDLNet_UDP_Recv(sock, in))
            SDL_Delay(100); //1/10th of a second
        if(in->data[0]!=1<<4)
        {
            in->data[0]=ERROR;
            in->len=1;
            SDLNet_UDP_Send(sock, -1, in);
            continue; // not a request...
        }
        memcpy(&ip,&in->address,sizeof(IPaddress));
        host=SDLNet_ResolveIP(&ip);
        ipnum=SDL_SwapBE32(ip.host);
        port=SDL_SwapBE16(ip.port);
        if(host)
            printf("request from host=%s port=%hd\n",host,port);
        else
            printf("request from host=%d.%d.%d.%d port=%hd\n",
                    ipnum>>24,
                    (ipnum>>16)&0xff,
                    (ipnum>>8)&0xff,
                    ipnum&0xff,
                    port);
        if(SDLNet_UDP_Bind(sock, 0, &ip)==-1)
        {
            printf("SDLNet_UDP_Bind: %s\n",SDLNet_GetError());
            exit(7);
        }

        strcpy(fname,in->data+1);
        printf("fname=%s\n",fname);
        
        // get actual filesize
        {
            struct stat buf;

#ifndef _MSC_VER
            if(stat(fname, &buf)>=0 && S_ISREG(buf.st_mode) && (f=fopen(fname,"rb")))
#else
            /* window MSVC version has no check for a valid file except that it opens */
            if(stat(fname, &buf)>=0 && (f=fopen(fname,"rb")))
#endif
                flen=buf.st_size;
            else
                flen=-1;
        }

        // send filesize / expect ready
        printf("sending filesize=%d blocksize=%d\n",flen,len);
        out->data[0]=1;
        SDLNet_Write32(flen,out->data+1);
        SDLNet_Write32(len-6,out->data+5);
        out->len=9;
        if(udpsend(sock,0,out,in,10,2<<4,TIMEOUT)<1)
            continue;

        if(flen<0)
            continue; // invalid file...

        // send file
        printf("sending file\n");
        //out->data[0]=2;
        //out->len=1;
        //SDLNet_UDP_Send(sock, -1, out);

        plen=len-6;
        err=0;
        for(p=0;p<flen && !err;p+=32*plen)
        {
            while(SDLNet_UDP_Recv(sock, in)); // flush input
            printf("p=%d\n",p);
            // fill packets
            for(p2=0;p+p2*plen<flen && p2<32;p2++)
            {
                packets[p2]->data[0]=2;
                packets[p2]->data[1]=p2;
                SDLNet_Write32(p+p2*plen,packets[p2]->data+2);
                packets[p2]->len=len;
                packets[p2]->channel=0;
                if(p+(p2+1)*plen>=flen)
                    packets[p2]->len=6+(flen-(p+p2*plen));
                if(!fread(packets[p2]->data+6, packets[p2]->len-6, 1, f))
                {
                    perror("fread");
                    continue; // error on read
                }
                outs[p2]=packets[p2];
            }
            
            // setup the acks expected
            ack=0;
            for(i=p2;i<32;i++)
                ack|=1<<i;

            // send packets/expect ack
            while(ack!=0xffffffff && !err)
            {
                do
                {
                    printf("sending %d packets\n",p2);
                    if(SDLNet_UDP_SendV(sock, outs, p2)<p2)
                    {
                        printf("SDLNet_UDP_SendV: %s\n",SDLNet_GetError());
                        err=-1;
                        continue;
                    }
                    err=udprecv(sock,in,10,3<<4,TIMEOUT);
                } while(err==1 && (Sint32) SDLNet_Read32(in->data+1)!=p);
                if(err<1)
                {
                    err=1;
                    continue; // we have an error...
                }
                err=0;
                ack|=SDLNet_Read32(in->data+5);
                printf("received ack 0x%08X\n",ack);
                for(p2=i=0;i<32;i++)
                    if(!((ack>>i)&1))
                        outs[p2++]=packets[i];
            }
        }
        if(!err)
            printf("done\n");
        else
            printf("finished with an error\n");

        fclose(f);
        f=NULL;
    }
    
    // close the socket
    SDLNet_UDP_Close(sock);
    
    // free packet
    SDLNet_FreePacket(out);
    SDLNet_FreePacket(in);
    SDLNet_FreePacketV(packets);
    
    // shutdown SDL_net
    SDLNet_Quit();

    // shutdown SDL
    SDL_Quit();

    return(0);
}
