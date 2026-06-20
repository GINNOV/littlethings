#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %ld", x);
#define ReadLong(a) if (fscanf(stdin, "%ld", &a) != 1) a = 0;

long N;
long a[15][15];
long qspoint[15];
long qsstack[15][15];

void Mark(long i, long j) {
  long x,y;
  
  a[i][j] = 1;
  x = 0;
  while (x<=N-1) {
    y = x+j-i;
    if (y >= 0) {
      if (y <= N-1) {
	if (x != i) {
	  if (y != j) {
	    a[x][y] = a[x][y]+1;
	  }
	}
      }
    }
    y = -x+j+i;
    if (y >= 0) {
      if (y <= N-1) {
	if (x != i) {
	  if (y != j) {
	    a[x][y] = a[x][y]+1;
	  }
	}
      }
    }
    if (x!=j) {
      a[i][x] = a[i][x] + 1;
    }
    if (x!=i) {
      a[x][j] = a[x][j] + 1;
    }
    x = x+1;	
  }
}

void Unmark(long i, long j) {
  long x,y;
  
  a[i][j] = 0;
  x = 0;
  while (x<=N-1) {
    y = x+j-i;
    if (y >= 0) {
      if (y <= N-1) {
	if (x != i) {
	  if (y != j) {
	    a[x][y] = a[x][y]-1;
	  }
	}
      }
    }
    y = -x+j+i;
    if (y >= 0) {
      if (y <= N-1) {
	if (x != i) {
	  if (y != j) {
	    a[x][y] = a[x][y]-1;
	  }
	}
      }
    }
    if (x!=j) {
      a[i][x] = a[i][x] - 1;
    }
    if (x!=i) {
      a[x][j] = a[x][j] - 1;
    }
    x = x+1;	
  }
}

void main ()
{
  long index1, index2, index3, i1, i2, i, j;
  long pushcount, solcount, solcount1, maxprofit, thisprofit, mirrorflag;
  long profsum, mirrorprofsum, addit;
  long profpos[15];
  long mirrorprofpos[15];
  long maxprofpos[15];
  long temp1, temp2, temp3,temp4, flg1, flg2, flg3, flg4;

  N = 11;
  //ReadLong(N);
  if (N%2 == 1) {
    addit = 1;
  }
  else {
    addit = 0;
  }
  pushcount = 0;
  solcount = 0;
  solcount1 =0;
  maxprofit = 0;

  i1 = 0;
  while (i1<=N-1) {
    i2 = 0;
    while (i2<=N-1) {
      a[i1][i2] = 0;
      qsstack[i1][i2] = 0;
      i2 = i2 + 1;
    }
    i1 = i1 + 1;
  }
  i1 = 0;
  while (i1<=N-1) {
    qspoint[i1] = 0;
    i1 = i1 +1;
  }
  index1 = 0;
  while (index1<=(N/2)-1+addit) {
    WriteLong(index1);
    WriteLine();
    Mark(0, index1);
    i=1;
    j=0;
    while(j<=N-1) {
      if (a[i][j]==0) {
	qspoint[i] = qspoint[i] + 1;
	qsstack[i][qspoint[i]] = j;
      }
      j = j + 1;
    }
    Mark(i, qsstack[i][qspoint[i]]);
    j = 0;
    i = i + 1;
    while (qspoint[1]!=0) {
      while (j<=N-1) {
	if (i == N-1) {
	  index2 = 0;
	  while (index2<=N-1) {
	    if (a[i][index2]==0) {
	      if (addit==1) {
		if (index1==(N/2)-1+addit) {
		  solcount1 = solcount1 + 1;
		}
	      }
	      if (addit != 1) {
		solcount = solcount + 1;
	      }
	      else {
		if (index1!=(N/2)-1+addit) {
		  solcount = solcount + 1;
		}
	      }
	      if (0-index1 >= 0) {
		profpos[0] = 0-index1;
	      }
	      else {
		profpos[0] = -(0-index1);
	      }
	      if ((0-(N-1-index1))>=0) {
		mirrorprofpos[0] = 0-(N-1-index1);
	      }
	      else {
		mirrorprofpos[0] = -(0-(N-1-index1));
	      }
	      index3 = 1;
	      while (index3<=N-2) {
		if ((index3-qsstack[index3][qspoint[index3]])>=0) {
		  profpos[index3] = index3-qsstack[index3][qspoint[index3]];
		}
		else {
		  profpos[index3] = -(index3-qsstack[index3][qspoint[index3]]);
		}
		if ((index3-(N-1-qsstack[index3][qspoint[index3]]))>=0) {
		  mirrorprofpos[index3] = index3-(N-1-qsstack[index3][qspoint[index3]]);
		}
		else {
		  mirrorprofpos[index3] = -(index3-(N-1-qsstack[index3][qspoint[index3]]));
		}
		index3 = index3 + 1;
	      }
	      if ((N-1-index2)>=0) {
		profpos[N-1] = N-1-index2;
	      }
	      else {
		profpos[N-1] = -(N-1-index2);
	      }
	      if ((N-1-(N-1-index2))>=0) {
		mirrorprofpos[N-1] = N-1-(N-1-index2);
	      }
	      else {
		mirrorprofpos[N-1] = -(N-1-(N-1-index2));
	      }
	      profsum = 0;
	      mirrorprofsum = 0;
	      index3 = 0;
	      while (index3<=N-1) {
		profsum = profsum + profpos[index3];
		mirrorprofsum = mirrorprofsum +  mirrorprofpos[index3];
		index3 = index3 + 1;
	      }
	      if (profsum>mirrorprofsum) {
		thisprofit = profsum;
		mirrorflag = 0;
	      }
	      else {
		thisprofit = mirrorprofsum;
		mirrorflag = 1;
	      }
	      if (thisprofit > maxprofit) {
		maxprofit = thisprofit;
		if (mirrorflag != 0) {
		  maxprofpos[0] = index1;
		  index3 = 1;
		  while (index3<=N-2) {
		    maxprofpos[index3] = qsstack[index3][qspoint[index3]];
		    index3 = index3 + 1;
		  }
		  maxprofpos[N-1] = index2;
		}		  
		else {
		  maxprofpos[0] = N-1-index1;
		  index3 = 1;
		  while (index3<=N-2) {
		    maxprofpos[index3] = N-1-qsstack[index3][qspoint[index3]];
		    index3 = index3 + 1;
		  }
		  maxprofpos[N-1] = N-1-index2;
		}		  		  		
	      }
	    }
	    index2 = index2 + 1;	          
	  }
	  j = N;
	}	  
	else {
	  if (a[i][j]==0) {
	    pushcount = pushcount + 1;
	    qspoint[i] = qspoint[i] + 1;
	    qsstack[i][qspoint[i]] = j;
	  }
	  j = j + 1;
	}
      }
      if (pushcount==0) {
	i = i - 1;
	Unmark(i, qsstack[i][qspoint[i]]);
	qspoint[i] = qspoint[i] - 1;
	flg1 = 0;
	flg2 = 0;
	flg4 = 0;
	while (qspoint[i] == 0) {
	  while (i!=1) {
	    i = i - 1;
	    Unmark(i, qsstack[i][qspoint[i]]);
	    qspoint[i] = qspoint[i] - 1;
	    if (qspoint[i] != 0) {
	      temp1 = i;
	      i = 1;
	      flg1 = 1;
	    }
	    if (flg1 == 0) {
	      if (i == 1) {
		temp2 = qspoint[i];
		qspoint[i] = -100;
		flg2 = 1;
	      }
	    }
	  }
	  if (flg1 == 0) {
	    if (flg2 == 0) {
	      if (i == 1) {
	        temp4 = qspoint[i];
		qspoint[i] = -100;
		flg4 = 1;
	      }
	    }
 	  }
	}
	if (flg1 == 1) {
	  i = temp1;
	}
	if (flg2 == 1) {
	  qspoint[i] = temp2;
	}
	if (flg4 == 1) {
	  qspoint[i] = temp4;
	}
	if (qspoint[i] != 0) {
	  Mark(i, qsstack[i][qspoint[i]]);
	  j = 0;
	  i = i + 1;
	}
	else {
	  if (i != 1) {
	    Mark(i, qsstack[i][qspoint[i]]);
	    j = 0;
	    i = i + 1;
	  }
	}
	flg3 = 0;
	if (qspoint[i] == 0) {
	  if (i == 1) {
	    temp3 = qspoint[1];
	    qspoint[1] = 0;
	    flg3 = 1;
	  }
	}
      }
      else {
	Mark(i, qsstack[i][qspoint[i]]);
	j = 0;
	i = i + 1;
	pushcount = 0;
      }
    }
    if (flg3 == 1) {
      qspoint[1] = temp3;
    }
    Unmark(0, index1);
    index1 = index1 + 1;
  }

  temp4 = 2*solcount+solcount1;
  WriteLong(temp4);
  WriteLine();
  WriteLong(solcount1);
  WriteLine();
  WriteLong(maxprofit);
  WriteLine();
}
/* Output
0
1
2
3
4
5
2680
350
54

This program calculates the number of solutions to Nqueen where N=11. It prints out iteration number (0..5), total number of solutions (2680), number of asymmetrical solotions (350), and the maximum profit metric (54).

*/
