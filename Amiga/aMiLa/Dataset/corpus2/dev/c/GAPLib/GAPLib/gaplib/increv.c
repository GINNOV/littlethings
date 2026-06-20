#include <stdio.h>
#include <string.h>
int main(int w8U,char *s4E[])
{
FILE *f;
long val;
if(w8U<2 || (w8U==2 && !strcmp(s4E[1],"val"))) {
if((f=fopen("GAP_Revision","rb"))!=NULL) {
fscanf(f,"%d",&val);
fclose(f);
if((f=fopen("GAP_Revision","wb"))!=NULL) {
fprintf(f,"%d",val+1);
} else {
fprintf(stderr,"Revision update failed.\n");
}
} else {
fprintf(stderr,"Revision update failed.\n");
}
} else if(w8U==2 && !strcmp(s4E[1],"ver")) {
if((f=fopen("GAP_Version","rb"))!=NULL) {
fscanf(f,"%d",&val);
fclose(f);
if((f=fopen("GAP_Version","wb"))!=NULL) {
fprintf(f,"%d",val+1);
} else {
fprintf(stderr,"Version update failed.\n");
}
} else {
fprintf(stderr,"Version update failed.\n");
}
}
return(0);
}
