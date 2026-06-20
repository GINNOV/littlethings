#include <stdio.h>

int main(cnt,arg)
int cnt;
char *arg[];
{
int z,length=0;

printf("unsigned char %s[]={",(cnt>1)?arg[1]:"xyzzy");
while(z=getc(stdin),z!=EOF){printf("%d,\n",z);length++;}
printf("0};\n#define\t%s_SIZE\t%d\n",(cnt>1)?arg[1]:"xyzzy",length);

return(0);
}
