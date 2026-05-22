
#include <stdio.h>
#define WriteLine() printf("\n");
#define WriteLong(x) printf(" %ld", x);
#define ReadLong(a) if (fscanf(stdin, "%ld", &a) != 1) a = 0;




long face[9][20];
long bigArray[1111][1111];
long k, yawn;
void iAmSleepy(){
	long a, b, c,d;
	yawn = yawn+face[k%9][k%20];

}

void iAmVERYtired(){
		iAmSleepy();
		yawn = yawn+face[(k+5)%9][(k+2)%20];
		iAmSleepy();
		yawn = yawn-face[(k*2)%9][(k%2)%20];
		iAmSleepy();
		iAmSleepy();
		iAmSleepy();
		iAmSleepy();
		iAmSleepy();
		iAmSleepy();
		iAmSleepy();
		iAmSleepy();
		iAmSleepy();
		iAmSleepy();
		iAmSleepy();
}

void main () {
    long a, b, c, d, e;
    long f, g, h, i, j;
    long temp[20];
    
    
    ///////////////////////////////
    // TEST (ALMOST) EMPTY BLOCKS//
    ///////////////////////////////
    a = 10;
    WriteLong(a); //10
    while(a<5){
        WriteLong(a);  // no output
    }
    WriteLong(a);
    if(0==0){
    }else{
    }
    WriteLong(a); //a = 10
    
    
     while(a>5){
         if(a!=a){
         }else{
             a= 0;
             WriteLong(a);	
          }
      }
   //	a = 0
     
	WriteLine();
a = 6;
    
    b = 10;
    
    while(a>b){
    }
    if(a==a){
    }else{
    }
    
    while(a>a){
        if(a==a){
        }else{
        }
    }
    WriteLong(a); 
    WriteLine();
    WriteLong(b);
    WriteLine();
    WriteLine();
    WriteLine();
    WriteLine();
    WriteLine();
    WriteLine();
   
    
    
    /////////////////////
    // PLAY WITH ARRAYS//
    /////////////////////
    i = 0;
    j = 0;
    while(i < 9){

        if(i == 0){ 
            j=0;
            while(j < 20){ // initialize line to '7's
            face[i][j] = 7;
            j = j+1;   
            }
        }
        if(i == 1){
            j=0;
            while(j < 20){ // initialize line to '7's
                face[i][j] = 7;
                j = j+1;   
            }
        }
        if(i == 2){
            j=0;
            while(j < 20){ 
                if(j<3){ 
                    face[i][j] = 7;
                } else {
                    if(j>15){ 
                        face[i][j] = 7;
                    } else {
                        face[i][j] = 8;
                    }
                    
                }
                
                j = j+1;   
            }
         face[i][8] = 7;
            face[i][9] = 7;
            face[i][10] = 7;
        }
        if(i == 3){
            j=0;
            while(j < 20){ 
                if(j<5){ 
                    face[i][j] = 7;
                } else {
                    if(j>13){ 
                        face[i][j] = 7;
                    } else {
                        face[i][j] = 8;
                    }
                    
                }
                
                j = j+1;   
            }
            face[i][9] = 7;
        }
        if(i == 4){
            j=0;
            while(j < 20){ // initialize line to '7's
                face[i][j] = 7;
                j = j+1;   
            }
        }
        if(i == 5){
            j=0;
            while(j < 20){ 
                if(j<7){ 
                    face[i][j] = 7;
                } else {
                    if(j>11){ 
                        face[i][j] = 7;
                    } else {
                        face[i][j] = 8;
                    }
                    
                }
                j = j+1;   
            }
        }
        if(i == 6){
            j=0;
            while(j < 20){ 
                if(j>4){
                    face[i][j] = 8;
                } else {
                    face[i][j] = 7;
                }
                if(j>7){
                    face[i][j] = 7;
                }
                if(j>10){
                    face[i][j] = 8;
                }
                if(j>13){
                    face[i][j] = 7;
                }
                j = j+1;   
            }
        }
        if(i == 7){
            j=0;
            while(j < 20){ // initialize line to '7's
                face[i][j] = 7;
                if(j == 5){
                   face[i][j] = 8;
                }
                if(j == 13){
                    face[i][j] = 8;
                } 
                j = j+1;   
            }
        }
        if(i == 8){
            j=0;
            while(j < 20){ // initialize line to '7's
                face[i][j] = 7;
                j = j+1;   
            }
        }
        
        i = i+1;   
    }

    i = 0;
    j = 0;
    while(i < 9){
        j = 0;
        while(j < 20){
            WriteLong(face[i][j]);
            //printf("%lld", face[i][j]);
            j = j+1;
        }
        WriteLine();
        //printf("\n");
        i = i+1;  
    }
    
    WriteLine();
    //printf("\n");
    WriteLine();
    //printf("\n");
    WriteLine();
    //printf("\n");
    
    k = 0;
    while(k<20){
        temp[k] = face[7][k];
        face[7][k] = face[5][k];
        face[5][k] = temp[k];
        k = k+1;
    }
    

    
    ///////////////////
    // TEST BIG LOOPS//
    ///////////////////

    k = 0;
    b = 0;
    while(k<100){
        j= 500;
        while(j> -500){
	  bigArray[k][j+500] = k;
	  iAmSleepy();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  iAmVERYtired();
	  if(k == 430){
	    if(j == 10){
	      b = 12345;
	    }
	  }
	  j = j-1;   
        }
        k = k+1;   
    }
    
    WriteLong(b);
   
    WriteLine();
 
    WriteLong(yawn);
    WriteLine();
    WriteLine();

//print the face
    i = 0;
    while(i < 9){
        j = 0;
        while(j < 20){
            WriteLong(face[i][j]);
            j = j+1;
        }
        WriteLine();
        i = i+1;  
    }
}

//output
/*
 10 10 10 0
 6
 10





 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
 7 7 7 8 8 8 8 8 7 7 7 8 8 8 8 8 7 7 7 7
 7 7 7 7 7 8 8 8 8 7 8 8 8 8 7 7 7 7 7 7
 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
 7 7 7 7 7 7 7 8 8 8 8 8 7 7 7 7 7 7 7 7
 7 7 7 7 7 8 8 8 7 7 7 8 8 8 7 7 7 7 7 7
 7 7 7 7 7 8 7 7 7 7 7 7 7 8 7 7 7 7 7 7
 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7



 12345
 1782401000

 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
 7 7 7 8 8 8 8 8 7 7 7 8 8 8 8 8 7 7 7 7
 7 7 7 7 7 8 8 8 8 7 8 8 8 8 7 7 7 7 7 7
 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
 7 7 7 7 7 8 7 7 7 7 7 7 7 8 7 7 7 7 7 7
 7 7 7 7 7 8 8 8 7 7 7 8 8 8 7 7 7 7 7 7
 7 7 7 7 7 7 7 8 8 8 8 8 7 7 7 7 7 7 7 7
 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
*/



