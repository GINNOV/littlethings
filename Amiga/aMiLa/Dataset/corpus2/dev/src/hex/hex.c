/*
 * $VER: hex.c 1.0 (7.5.96)
 *
 * ©1996 António Manuel Santos
 * 
 * EMAIL: L38058@ALFA.IST.UTL.PT
 *
 * SNAIL:  António Manuel Santos
 *         Rua do Zaire,5 1ºdto
 *         1170 Lisbon, Portugal
 *
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>

#define INVALID_CHAR	'.'
#define STDIN_FD		0

int input = -1;

int main(int argc, char **argv)
{
	if (argc <2) {
		input = STDIN_FD;
	} else {
		input = open(argv[1], O_RDONLY);
	}
	
	if (input != -1) {
		int k;
		char buff[16];
		int offset = 0;
		
		while ( (k = read(input, buff, 16)) > 0 ) {
			int j;
			
			printf("\033[1m%08lx:\033[22m  ", offset);
			
			for (j = 0; j < k; j++) {
				printf("%02x", (unsigned char)buff[j]);
				if (!((j+1) % 4))
					printf(" ");
			}
				
			for (j = 0; j < (17-k); j++) {
				printf("  ");
				if (!((j+1) % 4))
					printf(" ");
			}
			
			
			for (j = 0; j < k; j++) {
				printf("%c", ((buff[j] >= ' ') && (buff[j] <= 'z')) ? buff[j] : INVALID_CHAR);
			}
			
			if (k == 16)
				printf("\n");
			else if (k > 0) {
				printf("\n");
			}
			
			offset += 4;
		}
		
		if (input != STDIN_FD)
			close(input);
	}
	
	exit(0);
}
