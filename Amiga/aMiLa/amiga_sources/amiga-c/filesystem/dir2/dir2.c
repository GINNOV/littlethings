#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>

int main(void){
    DIR *dirp;
    struct dirent *dp;
    char *path = "PROGDIR:data";
    char *file;

    if(dirp = opendir(path), dirp) {
        puts("ok");

        while(dp = readdir(dirp), dp) {
			file = dp->d_name;
            puts(file);		
		}
		closedir(dirp);
    }else{
        puts("not ok");
    }

    
    return 0;
}