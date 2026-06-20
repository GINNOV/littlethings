#include <stdio.h>

#define QUE_L  5

int p_ind, c_ind;
int queue[QUE_L];

void Enqueue( x )
{
	if ( p_ind == c_ind )
    	printf("\t\t\007 buffer pieno, non posso inserire %d\n", x );
    else {
    	queue[p_ind] = x;
        p_ind = ( ++p_ind ) % QUE_L;
    }
    return;
}

int Dequeue( void )
{
    if ( (c_ind + 1) % QUE_L == p_ind ) {
        printf("\t\t\007 buffer vuoto, non posso leggere\n");
        return -1;
    }
    else 
        c_ind = ( ++c_ind ) % QUE_L;

    return queue[c_ind];
}


void main( void )
{
int dato;
int c;

  p_ind = 0;
  c_ind = QUE_L - 1;

  while(1) {
    do {
      printf("scrivi (0)\tleggi (1): ");
      scanf("%d", &c);
    } while (( c != 0 ) && ( c != 1 ));
    switch (c) {
      case 0:
        printf("\tscrivi il numero (positivo): ");
        scanf("%d", &dato );
        Enqueue(dato);
        break;
      case 1:
        dato = Dequeue();
 		if ( dato > 0 )
            printf("\t\tdato: %d\n", dato);
        break;
    }
  }
  return;
}

