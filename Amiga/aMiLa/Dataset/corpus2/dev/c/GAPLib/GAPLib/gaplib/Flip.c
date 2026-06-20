void Flip(void *,const long int);void Flip(void *w2A,const long int At){((char *)w2A)[At>>3]^=(128>>(At&7));
}