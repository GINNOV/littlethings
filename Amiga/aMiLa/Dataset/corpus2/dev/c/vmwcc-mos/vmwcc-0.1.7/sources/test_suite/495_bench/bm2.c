#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %ld", x);
#define ReadLong(a) if (fscanf(stdin, "%ld", &a) != 1) a = 0;

long N;

// keep the columns of queens.  I.e. queen in row k 
// will be at a column queencols[k]
// note: this indexes rows starting at 1, so that we
// can differentiate between row 0 and not assigned
long queenrows[100];

// these arrays hold which columns and diagonals 
// are eliminated by previous placements of queens
long rows[100];
// the main diagonal has index N-1, the one above N-2, and so on to 0.
// the ones below have index N, N+1,... 2N-2    
long diag[100] ;
long bdiag[100] ;
long conflicts[100];
long printsoln;
long numSoln;
void disp_board() {
	long i,j;
	i=0;
	WriteLine();
	while(i<N) {
	    j=0;
	    while(j<N) {
			if(queenrows[j] == i+1) {
			    WriteLong(8);
			}
			else {
				WriteLong(1);
			}
			j = j+1;
	    }
	    WriteLine();
	    i = i + 1;
	}
	WriteLine();
}

// recursively place num queens on board
void recurse(long num) {  
	long i;
	i=0;
	if(num == N) {
	    if(printsoln != 0) {
			disp_board();
	    }
	    numSoln = numSoln + 1;    
	}
	else {
		while(i<N) 
		{ // which row do we try for queen in col num
		    if(rows[i] == 0)
			{
				if(diag[i+num]==0) 
				{
					if(bdiag[N-1+i-num] == 0) 
					{
						queenrows[num] = i+1;
						rows[i] = 1;
						diag[i+num] = 1; 
						bdiag[N-1+i-num] = 1;
						recurse(num+1);
						rows[i] = 0;
						diag[i+num] = 0; 
						bdiag[N-1+i-num] = 0;      
					}
	    		}	
			}
		    i = i+1;
		}
		queenrows[num] = 0; // reset
	}
}

void main() { 
	ReadLong(N);
	printsoln = 1;
	recurse(0);
}

