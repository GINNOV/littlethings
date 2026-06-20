/*
 * This is a C-comment which is ignored by nuqneH.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "nuqneH.h"   /* nuqneH definitions start here. Note that /* must come after '#'.

section options
   switch      # This is the default anyway.
end

section args
   test=int
   name=string
   strings=[string]
   baz={foo,bar,quux}
   blog=int
   numbers=[int]
   fparg=float*      # This argument has no description or alias.
   foo=bool
   elist=[{a,b,c}]
   flist=[float]
   other=rest
end

section alias
   test=t
   name=n
   strings=s
   numbers=num
end

section desc
   test="An integer test argument"
   name="A string test argument"
   strings="Stringlist argument"
   numbers="Integerlist argument"
   foo="Boolean argument, which also has a really long description. This description will be broken into several lines so that it will be more readable - at least that is the intention. If it does not work, well - it's just a quick fix anyway I did not feel up to emulating TeX just to break a line appropriately. So there. Is this description long enough?"
end

section default
   test=17
end

section required
   foo      # The user must always specify "foo" on the commandline.
end

section validate
   test="test>=0 && test<17"      # False if test<0 or test>16 
   name="strcmp($,""foo"")"   # False if name is "foo". This example uses the '$' abbreviation for the argument.
end

finished

*/

int main(int cnt,char *arg[])
{
int i;

#include "muvtay.c"

if(fparg_test) {
   printf("fparg=%f\n",fparg);
}

if(test_test) {
   printf("test=%ld\n",test);
} else {
   printf("test has default value, which is %ld.\n",test);
}

if(name_test) {
   printf("name=%s\n",name);
}

if(strings_test) {
   for(i=0;i<strings_count;i++) {
      printf("strings[%d]=%s\n",i,strings[i]);
   }   
}

if(numbers_test) {
   for(i=0;i<numbers_count;i++) {
      printf("numbers[%d]=%ld\n",i,numbers[i]);
   }
}

if(baz_test) {
   printf("baz=%d\n",baz);
}

if(foo_test) {
   printf("foo was on the commandline (obviously).\n");
}

if(blog_test) {
   printf("blog=%ld\n",blog);
}

if(other_test) {
   printf("Others:\n");
   for(i=0;i<other_count;i++) {
      printf("\t%s\n",other[i]);
   }
}

if(elist_test) {
   printf("elist:\n");
   for(i=0;i<elist_count;i++) {
      printf("\t%d (%s)\n",elist[i],OptName(elist[i]));
   }
}

if(flist_test) {
   printf("flist:\n");
   for(i=0;i<elist_count;i++) {
      printf("\t%f\n",flist[i]);
   }
}

return(0);
}

