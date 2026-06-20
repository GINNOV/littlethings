#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

int
main(void)
{
	int fd1, fd2;

	fd1 = open("pippo", O_WRONLY | O_CREAT | O_TRUNC, 400);
	write(fd1, "pluto\n", 6);
	fd2 = dup(fd1);
	write(fd2, "nave\n", 5);
	write(fd1, "prua\n", 5);
	close(fd1);
	return(0);
}
	
