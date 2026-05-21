//
// Created by stef on 31/03/2020.

// needs the "netinclude" headers from https://www.hyperion-entertainment.com/index.php/downloads?view=download&layout=form&file=82

// based on https://gilles-pelletier-vft.pagesperso-orange.fr/amiga/bsdsocket.htm
// I added code the split the headers from the content
// usage: wget www.google.com 80 /index.htm
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <proto/exec.h>
#include <proto/bsdsocket.h>

struct Library *SocketBase ;

char *find_header_end(char *buf, int bytes) {

    char *end = buf + bytes;

    while (buf < end && !(*buf++ == '\n'
                          && (*buf == '\n'
                              || (*buf++ == '\r'
                                  && *buf == '\n')))) ;
    if (*buf == '\n')
        return buf + 1;
    return NULL;
}


int main(int argc, char* argv[])
{
    struct sockaddr_in servaddr ;
    struct hostent *hp ;
    struct protoent *pe ;
    int sock_id ;
    char *message ;
    int msglen, msgcur, msgtodolen,header_found ;
    char *h_end_ptr;
    int err ;
    int port ;
    ULONG addr ;

    if (argc < 3)
    {
        printf("Usage: %s   ", argv[0]) ;
        exit(0) ;
    }

    port = atoi(argv[2]) ;
    if (port == 0) port = 80 ;

    message = malloc(2048) ;
    if (message == NULL)
    {
        printf("no mem\n") ;
        exit(0) ;
    }
    else
    {
        memset(message, 0, 2048) ;
    }

    SocketBase = OpenLibrary("bsdsocket.library", 0) ;
    if (SocketBase == NULL)
    {
        printf("no TCP/IP stack, no BSDsocket.library\n") ;
        exit(0) ;
    }
    else
    {
        printf("%s %ld.%ld\n", SocketBase->lib_Node.ln_Name, SocketBase->lib_Version, SocketBase->lib_Revision ) ;
    }

    pe = (struct protoent*)getprotobyname("tcp") ;
    if (pe == NULL)
    {
        printf("Cannot find protocol\n") ;
        exit(0) ;
    }
    else
    {
        printf("Got protocol \"%s\" %ld\n", pe->p_name, pe->p_proto) ;
    }

    /* create a socket */
    sock_id = socket(AF_INET, SOCK_STREAM, pe->p_proto) ;
    if( sock_id == -1 )
    {
        printf("Couldn't get a socket.\n") ;
        exit(EXIT_FAILURE) ;
    }
    else
    {
        printf("Got a socket.\n");
    }

    memset(&servaddr, 0, sizeof(servaddr)) ;

    /* get server address */
    hp = (struct hostent*) gethostbyname(argv[1]) ;
    if (hp == NULL)
    {
        printf("Couldn't get an address.\n") ;
        exit(EXIT_FAILURE) ;
    }
    else
    {
        UBYTE *p = (UBYTE *)hp->h_addr ;
        addr = p[0] << 24 | p[1] << 16 | p[2] << 8 | p[3] ;

        printf("Got an address.\n") ;
        printf("\"%s\" len=%ld %s\n", hp->h_name, hp->h_length, Inet_NtoA(addr)) ;
    }

    /* set the address */
    servaddr.sin_addr.s_addr = inet_addr((APTR)Inet_NtoA(addr)) ;

    /* port and type */
    servaddr.sin_port   = htons(port) ;
    servaddr.sin_family = AF_INET ;

    /* connect */
    err = connect(sock_id, (struct sockaddr *)&servaddr, sizeof(servaddr)) ;
    if (err != 0)
    {
        int i ;
        printf("Couldn't connect. %ld\n", err);
        printf("%02x", servaddr.sin_len) ;
        printf("%02x", servaddr.sin_family) ;
        for (i=0; i< 14; i++)
        {
            printf("%02x", ((struct sockaddr*)&servaddr)->sa_data[i]) ;
        }
        printf("\n") ;
    }
    else
    {
        printf("Got a connection!!!\n");
    }

    if (err == 0)
    {
        /* open temp file in RAM to hold te response */
        FILE *f= fopen("ram:file.bin", "wb") ;

        /* Create a http GET request */
        sprintf( message,
                 "GET %s HTTP/1.0\r\n"
                 "Host: %s\r\n"
                 "From: nowhere\r\n"
                 "User-Agent: %s\r\n\r\n",
                 argv[3],   /* l'url */
                 argv[1],   /* le serveur */
                 argv[0]) ; /* le nom du programme */

        msglen     = 0 ;
        msgtodolen = strlen(message) ;
        msgcur     = 0 ;


        /* send  GET */
        do{
            msglen = send(sock_id, message+msgcur, msgtodolen, 0) ;
            if (msglen > 0){
                msgcur     += msglen ;
                msgtodolen -= msglen ;
            }
        } while ((msglen > 0) && (msgtodolen > 0)) ;

        /* read response, first look for header */

        header_found = 0;


        do{
            msglen = recv(sock_id, message, 2048, 0) ;

            if (msglen < 0){
            }else if (msglen == 0){
            }else{

                if (!header_found){
                    h_end_ptr = find_header_end(message, msglen);
                    printf("header ps:%s\n", h_end_ptr);

                    if (h_end_ptr != NULL) {
                        /* Found header end , print up to delimiter to stdout and rest to file */
                        fwrite(message, h_end_ptr - message, 1, stderr);
                        printf("header\n");
                        printf(stderr);
                        fwrite(h_end_ptr, msglen - (h_end_ptr - message), 1, f);
                        header_found = 1;
                    } else {

                        /* Not found, print all and read for more headers */
                        printf("response (%ld bytes):%s", msglen,message);
                    }

                }else{
                    printf("response (%ld bytes):%s", msglen);

                    if (f != NULL){
                        /* we got some content after the header -> write to file */
                        fwrite(message, msglen, 1, f) ;
                    }
                }


            }
        } while (msglen > 0) ;

        if (f != NULL)
        {
            /* clean up  */
            fclose(f) ;
        }
    }

    CloseSocket(sock_id) ;

    free(message) ;

    CloseLibrary(SocketBase) ;

    return 0 ;
}
