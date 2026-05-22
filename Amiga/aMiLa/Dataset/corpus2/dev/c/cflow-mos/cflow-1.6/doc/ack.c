/* Ackermann's function */

typedef unsigned long u_long;

u_long
ack (u_long a, u_long b) 
{
  if (a == 0)
    return b + 1;
  if (b == 0)
    return ack (a - 1, 1);
  return ack (a - 1, ack (a, b - 1));
}

