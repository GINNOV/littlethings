long	seed=1234;

void setseed(newseed)
int newseed;
{
   seed=newseed;
}

long rnd(range)
int range;
{
   if(range>0){
      seed=(seed+1)*75;
      seed-=65537*(seed/65537);
      seed--;
      return (seed%range);
   }
   seed=101;
   return seed;
}
