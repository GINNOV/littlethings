#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#ifndef WIN32
#include <unistd.h>
#endif
#include <SDL/SDL.h>
#include <SDL/SDL_net.h>
#include "tcputil.h"

typedef struct {
    TCPsocket sock;
    char *name;
} Client;

int running=1;
Client *clients=NULL;
int num_clients=0;
TCPsocket server;

#ifdef WIN32
#define strcasecmp _stricmp
#define strncasecmp _strnicmp

char *strsep(char **stringp, const char *delim)
{
    char *p;
    
    if(!stringp)
        return(NULL);
    p=*stringp;
    while(**stringp && !strchr(delim,**stringp))
        (*stringp)++;
    if(**stringp)
    {
        **stringp='\0';
        (*stringp)++;
    }
    else
        *stringp=NULL;
    return(p);
}

#endif

void send_all(char *buf);
int find_client_name(char *name);

// this is a simplistic printf-like function the format only takes a string of
// chars that represent datatypes.
// it mallocs space and prints into that buffer.
// it uses a static pointer so that the user doesn't have to free the buffer
char *mformat(char *format,...)
{
    va_list ap;
    Uint32 len=0;
    static char *str=NULL;
    char *p, *s;
    char c;
    int d;
    unsigned int u;

    if(str)
    {
        free(str);
        str=NULL;
    }
    if(!format)
        return(NULL);
    va_start(ap,format);
    for(p=format; *p; p++)
    {
        switch(*p)
        {
            case 's': // string
                s=va_arg(ap, char*);
                str=(char*)realloc(str,((len+strlen(s)+4)/4)*4);
                sprintf(str+len,"%s",s);
                break;
            case 'c': // char
                c=(char)va_arg(ap, int);
                str=(char*)realloc(str,len+4);
                sprintf(str+len,"%c",c);
                break;
            case 'd': // int
                d=va_arg(ap, int);
                str=(char*)realloc(str,((len+64)/4)*4);
                sprintf(str+len,"%d",d);
                break;
            case 'u': // unsigned int
                u=va_arg(ap, unsigned int);
                str=(char*)realloc(str,((len+64)/4)*4);
                sprintf(str+len,"%u",u);
                break;
        }
        // set len to the new string length
        if(str)
            len=strlen(str);
        else
            len=0;
    }
    va_end(ap);
    return(str);
}

// terminate the nick at "bad" characters...
void fix_nick(char *s)
{
    unsigned int i;

    if((i=strspn(s,"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ|_=+.,:;/\\?!@#$%^&*()~`"))!=strlen(s))
        s[i]='\0';
}

// test for nice name uniqueness among already connected users
int unique_nick(char *s)
{
    return(find_client_name(s)==-1);
}

// add a client into our array of clients
Client *add_client(TCPsocket sock, char *name)
{
    fix_nick(name);
    if(!strlen(name))
    {
        putMsg(sock,"Invalid Nickname...bye bye!");
        SDLNet_TCP_Close(sock);
        return(NULL);
    }
    if(!unique_nick(name))
    {
        putMsg(sock,"Duplicate Nickname...bye bye!");
        SDLNet_TCP_Close(sock);
        return(NULL);
    }
    clients=(Client*)realloc(clients, (num_clients+1)*sizeof(Client));
    clients[num_clients].name=name;
    clients[num_clients].sock=sock;
    num_clients++;
    // server side info
    printf("--> %s\n",name);
    // inform all clients, including the new one, of the joined user
    send_all(mformat("ss","--> ",name));
    return(&clients[num_clients-1]);
}

// find a client in our array of clients by it's socket.
// the socket is always unique
int find_client(TCPsocket sock)
{
    int i;
    for(i=0;i<num_clients;i++)
        if(clients[i].sock==sock)
            return(i);
    return(-1);
}

// find a client in our array of clients by it's socket.
// the name is always unique
int find_client_name(char *name)
{
    int i;
    for(i=0;i<num_clients;i++)
        if(!strcasecmp(clients[i].name,name))
            return(i);
    return(-1);
}

// remove a client from our array of clients
void remove_client(int i)
{
    char *name=clients[i].name;

    if(i<0 && i>=num_clients)
        return;
    
    // close the old socket, even if it's dead...
    SDLNet_TCP_Close(clients[i].sock);
    
    num_clients--;
    if(num_clients>i)
        memmove(&clients[i], &clients[i+1], (num_clients-i)*sizeof(Client));
    clients=(Client*)realloc(clients, num_clients*sizeof(Client));
    // server side info
    printf("<-- %s\n",name);
    // inform all clients, excluding the old one, of the disconnected user
    send_all(mformat("ss","<-- ",name));
    if(name)
        free(name);
}

// create a socket set that has the server socket and all the client sockets
SDLNet_SocketSet create_sockset()
{
    static SDLNet_SocketSet set=NULL;
    int i;

    if(set)
        SDLNet_FreeSocketSet(set);
    set=SDLNet_AllocSocketSet(num_clients+1);
    if(!set) {
        printf("SDLNet_AllocSocketSet: %s\n", SDLNet_GetError());
        exit(1); //most of the time this is a major error, but do what you want.
    }
    SDLNet_TCP_AddSocket(set,server);
    for(i=0;i<num_clients;i++)
        SDLNet_TCP_AddSocket(set,clients[i].sock);
    return(set);
}

// send a buffer to all clients
void send_all(char *buf)
{
    int cindex;

    if(!buf || !num_clients)
        return;
    cindex=0;
    while(cindex<num_clients)
    {
        // putMsg is in tcputil.h, it sends a buffer over a socket
        // with error checking
        if(putMsg(clients[cindex].sock,buf))
            cindex++;
        else
            remove_client(cindex);
    }
}

void do_command(char *msg, Client *client)
{
    char *command,*p;
    int len;

    if(!msg || !strlen(msg) || !client)
        return;
    len=strlen(msg);
    p=msg;
    command=strsep(&p," \t");
    // /NICK : change the clients name
    if(!strcasecmp(command,"NICK"))
    {
        if(p && strlen(p))
        {
            char *old_name=client->name;
            
            fix_nick(p);
            if(!strlen(p))
            {
                putMsg(client->sock,"--- Invalid Nickname!");
                return;
            }
            if(!unique_nick(p))
            {
                putMsg(client->sock,"--- Duplicate Nickname!");
                return;
            }
            client->name=strdup(p);
            send_all(mformat("ssss","--- ",old_name," --> ",p));
            free(old_name);
        }
        else
            putMsg(client->sock,"--- /NICK nickname");
        return;
    }
    // MSG : client to client message
    if(!strcasecmp(command,"MSG"))
    {
        char *name;
        int to;

        if(p)
        {
            name=strsep(&p," ");
            to=find_client_name(name);
            if(to<0)
            {
                putMsg(client->sock, mformat("sss","--- /MSG nickname ",name," not found!"));
                return;
            }
            else if(p && strlen(p))
            {
                putMsg(client->sock,mformat("ssss",">",clients[to].name,"< ",p));
                putMsg(clients[to].sock,mformat("ssss",">",client->name,"< ",p));
                return;
            }
        }
        putMsg(client->sock,"--- /MSG nickname message...");
        return;
    }
    // /ME : emote! to everyone
    if(!strcasecmp(command,"ME"))
    {
        if(p && strlen(p))
        {
            send_all(mformat("sss",client->name," ",p));
        }
        else
            putMsg(client->sock,"--- /ME message...");
        return;
    }
    // /QUIT : quit the server with a message
    if(!strcasecmp(command,"QUIT"))
    {
        if(!p || strcasecmp(p,"-h"))
        {
            if(p)
                send_all(mformat("ssss","--- ",client->name," quits : ",p));
            else
                send_all(mformat("sss","--- ",client->name," quits"));
            remove_client(find_client(client->sock));
        }
        else
            putMsg(client->sock,"--- /QUIT [message...]");
        return;
    }
    // /WHO : list the users online back to the client
    if(!strcasecmp(command,"WHO"))
    {
        int i;
        IPaddress *ipaddr;
        Uint32 ip;
        char *host;
        
        putMsg(client->sock,"--- Begin /WHO ");
        for(i=0;i<num_clients;i++)
        {
            ipaddr=SDLNet_TCP_GetPeerAddress(clients[i].sock);
            if(ipaddr)
            {
                ip=SDL_SwapBE32(ipaddr->host);
                host=SDLNet_ResolveIP(ipaddr);
                putMsg(client->sock,mformat("sssssdsdsdsdsd","--- ",clients[i].name,
                        " ",host?host:"",
                        "[",ip>>24,".", (ip>>16)&0xff,".", (ip>>8)&0xff,".", ip&0xff,
                        "] port ",(Uint32)ipaddr->port));
            }
        }
        putMsg(client->sock,"--- End /WHO");
        return;
    }
    // /HELP : tell the client all the supported commands
    if(!strcasecmp(command,"HELP"))
    {
        putMsg(client->sock,"--- Begin /HELP");
        putMsg(client->sock,"--- /HELP : this text");
        putMsg(client->sock,"--- /ME message... : emote!");
        putMsg(client->sock,"--- /MSG nickname message... : personal messaging");
        putMsg(client->sock,"--- /NICK nickname : change nickaname");
        putMsg(client->sock,"--- /QUIT [message...] : disconnect this client");
        putMsg(client->sock,"--- /WHO : list who is logged on");
        putMsg(client->sock,"--- End /HELP");
        return;
    }

    // invalid command...respond appropriately
    putMsg(client->sock,mformat("sss","--- What does the '",command,"' command do?"));
}

int main(int argc, char **argv)
{
    IPaddress ip;
    TCPsocket sock;
    SDLNet_SocketSet set;
    char *message=NULL,*host;
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
        SDL_Quit();
        exit(2);
    }

    // get the port from the commandline
    port=(Uint16)strtol(argv[1],NULL,0);

    // Resolve the argument into an IPaddress type
    if(SDLNet_ResolveHost(&ip,NULL,port)==-1)
    {
        printf("SDLNet_ResolveHost: %s\n",SDLNet_GetError());
        SDLNet_Quit();
        SDL_Quit();
        exit(3);
    }

    // perform a byte endianess correction for the next printf
    ipaddr=SDL_SwapBE32(ip.host);

    // output the IP address nicely
    printf("IP Address : %d.%d.%d.%d\n",
            ipaddr>>24,
            (ipaddr>>16)&0xff,
            (ipaddr>>8)&0xff,
            ipaddr&0xff);

    // resolve the hostname for the IPaddress
    host=SDLNet_ResolveIP(&ip);

    // print out the hostname we got
    if(host)
        printf("Hostname   : %s\n",host);
    else
        printf("Hostname   : N/A\n");

    // output the port number
    printf("Port       : %d\n",port);

    // open the server socket
    server=SDLNet_TCP_Open(&ip);
    if(!server)
    {
        printf("SDLNet_TCP_Open: %s\n",SDLNet_GetError());
        SDLNet_Quit();
        SDL_Quit();
        exit(4);
    }

    while(1)
    {
        int numready,i;
        set=create_sockset();
        numready=SDLNet_CheckSockets(set, (Uint32)-1);
        if(numready==-1)
        {
            printf("SDLNet_CheckSockets: %s\n",SDLNet_GetError());
            break;
        }
        if(!numready)
            continue;
        if(SDLNet_SocketReady(server))
        {
            numready--;
            //printf("Connection...\n");
            sock=SDLNet_TCP_Accept(server);
            if(sock)
            {
                char *name=NULL;

                //printf("Accepted...\n");
                if(getMsg(sock, &name))
                {
                    Client *client;
                    client=add_client(sock,name);
                    if(client)
                        do_command("WHO",client);
                }
                else
                    SDLNet_TCP_Close(sock);
            }
        }
        for(i=0; numready && i<num_clients; i++)
        {
            if(SDLNet_SocketReady(clients[i].sock))
            {
                if(getMsg(clients[i].sock, &message))
                {
                    char *str;
                    
                    numready--;
                    printf("<%s> %s\n",clients[i].name,message);
                    // interpret commands
                    if(message[0]=='/' && strlen(message)>1)
                    {
                        do_command(message+1,&clients[i]);
                    }
                    else // it's a regular message
                    {
                        // forward message to ALL clients...
                        str=mformat("ssss","<",clients[i].name,"> ",message);
                        if(str)
                            send_all(str);
                    }
                    free(message);
                    message=NULL;
                }
                else
                    remove_client(i);
            }
        }
    }

    // shutdown SDL_net
    SDLNet_Quit();

    // shutdown SDL
    SDL_Quit();

    return(0);
}
