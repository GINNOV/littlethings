int Testbit(void *,int);int Testbit(void *w2A,int At){return(((char *)w2A)[At>>3] & (128>>(At&7)));
}