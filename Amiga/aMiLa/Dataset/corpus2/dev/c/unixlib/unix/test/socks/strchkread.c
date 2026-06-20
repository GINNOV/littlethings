#include <proto/socket.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <errno.h>
#define TRUE 1

/*
 * This program uses select() to check that someone is trying to connect
 * before calling accept(). 
 */

int
main(void)
{
	int sock;
	long length;
	struct sockaddr_in server;
	int msgsock;
	char buf[1024];
	int rval;
	fd_set ready;
	struct timeval to;
	int pid;
	int fifo_ok = 1;
	int std_in[2];
	int std_out[2];
	char *argv[2];

	if (pipe(std_in) != 0 || pipe(std_out) != 0) {
	    printf("Cannot get a pipe.\n");
	    exit(1);
	}
	fcntl(std_out[0], F_SETFL, O_NONBLOCK);
	argv[0] = "getaline";
	argv[1] = NULL;
	pid = exec(argv[0], argv, std_in[0], std_out[1], NULL, 4096);
	if (pid < 0) {
	    printf("Cannot exec %s.\n", argv[0]);
	    exit(1);
	}

	/* Create socket */
	sock = socket(AF_INET, SOCK_STREAM, 0);
	if (sock < 0) {
		perror("opening stream socket");
		exit(1);
	}
	/* Name socket using wildcards */
	server.sin_family = AF_INET;
	server.sin_addr.s_addr = INADDR_ANY;
	server.sin_port = 0;
	if (bind(sock, (struct sockaddr *)&server, sizeof(server))) {
		perror("binding stream socket");
		exit(1);
	}
	/* Find out assigned port number and print it out */
	length = sizeof(server);
	if (getsockname(sock, (struct sockaddr *)&server, &length)) {
		perror("getting socket name");
		exit(1);
	}
	printf("Socket has port #%d\n", ntohs(server.sin_port));

	/* Start accepting connections */
	listen(sock, 5);
	do {
		FD_ZERO(&ready);
		FD_SET(sock, &ready);
		if (fifo_ok)
		    FD_SET(std_out[0], &ready);
		to.tv_sec = 5;
		to.tv_usec = 0;
		if (select(max(sock,std_out[0]) + 1, &ready, 0, 0, &to) < 0) {
			perror("select");
			continue;
		}
		if (FD_ISSET(sock, &ready)) {
			msgsock = accept(sock, (struct sockaddr *)0, (long *)0);
			if (msgsock == -1)
				perror("accept");
			else do {
				bzero(buf, sizeof(buf));
				if ((rval = read(msgsock, buf, 1024)) < 0)
					perror("reading stream message");
				else if (rval == 0)
					printf("Ending connection\n");
				else
					printf("-->%s\n", buf);
			} while (rval > 0);
			close(msgsock);
		} else if (fifo_ok && FD_ISSET(std_out[0], &ready)) {
			bzero(buf, sizeof(buf));
			if ((rval = read(std_out[0], buf, 1024)) > 1)
			    printf("-->%s", buf);
			else if (errno != EAGAIN || rval == 1) {
			    printf("Child exited\n");
			    wait(0);
			    close(std_out[0]);
			    close(std_in[1]);
			    fifo_ok = 0;
			}
		} else
			printf("Do something else\n");
	} while (TRUE);
}
