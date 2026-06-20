#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

int
main(void)
{
	int fd;

	fd = open("pippo", O_WRONLY | O_CREAT | O_TRUNC, 400);
	write(fd, "pluto\n", 6);
	dup2(fd, 1);
	write(1, "nave\n", 5);
	printf("prua\n");
	close(fd);
	return(0);
}
	
