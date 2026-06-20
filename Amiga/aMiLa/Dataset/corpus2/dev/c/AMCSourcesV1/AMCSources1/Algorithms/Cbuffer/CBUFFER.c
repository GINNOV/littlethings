#include <stdio.h>

#define QUE_L  5

void main( void )
{
int queue[QUE_L];
int p_ind, c_ind;
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
        printf("\tscrivi il numero: ");
        scanf("%d", &dato );
        if ( p_ind == c_ind )
          printf("\t\t\007 buffer pieno, non posso inserire %d\n", dato );
        else {
          queue[p_ind] = dato;
          p_ind = ( ++p_ind ) % QUE_L;
        }
        break;
      case 1:
        if ( (c_ind + 1) % QUE_L == p_ind )
          printf("\t\t\007 buffer vuoto, non posso leggere\n");
        else {
          c_ind = ( ++c_ind ) % QUE_L;
          printf("\t\tdato: %d\n", queue[c_ind]);
        }
        break;
    }
  }
  return;
}

