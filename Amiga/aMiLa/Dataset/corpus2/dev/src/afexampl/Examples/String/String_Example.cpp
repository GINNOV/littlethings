//////////////////////////////////////////////////////////////////////////////
// String Example
// 6.16.96 Deryk Robosson

//////////////////////////////////////////////////////////////////////////////
// Includes
#include "aframe:include/object.hpp"
#include "aframe:include/string.hpp"

//////////////////////////////////////////////////////////////////////////////
// MAIN

void main()
{
    AFString string="This is";
    AFString string2="an AFrame";
    AFString string3="AFString example.";
    AFString buffer;
    int i;

    printf("Basic AFString usage:\n");
    printf("%s %s %s\n\n",string,string2,string3);

    printf("Adding strings:\n");
    buffer="AFrame ";
    buffer+="is really";
    buffer+=" cool stuff!";
    printf("%s\n\n",buffer);

    printf("String Lengths:\n");
    printf("String1: %d  %s\n",string.length(),string);
    printf("String2: %d  %s\n",string2.length(),string2);
    printf("String2: %d  %s\n\n",string3.length(),string3);

    printf("String Comparing:\n");
    string=string2="AFrame";
    printf("String1: %s\nString2: %s\n",string, string2);
    if(string=="AFrame")
        printf("Equal\n");
    else printf("Not Equal\n");

    printf("String Indexing:\n");
    for(i=1;i<string.length();i++)
        printf("%c",string[i]);
    printf("\n\nAll Done!\n");
}
