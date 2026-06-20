/****************************************************************/
/* parsefd.c                                                    */
/****************************************************************/
/* Simple .fd file parser                                       */
/****************************************************************/
/* Gilles Pelletier                                             */
/****************************************************************/
/*                                                              */
/* Modification history                                         */
/* ====================                                         */
/* 26-Feb-2008 Aminet release for all                           */
/* 05-Dec-1999 Creation, to see function name, by parsing .fd   */
/*             files                                            */
/****************************************************************/

#include <stdio.h>
#include <stdlib.h>

#include <strings.h>

void vectorname(char *vecstr, char *full)
{
  char *pos ;

  pos = strchr(full, '(') ;
  if (pos != NULL)
  {
    vecstr[0] = 0 ;
    strncat(vecstr, full, (pos-full)) ;
  }
  else
  {
   strcpy(vecstr, "????") ;
  }
}

char **loadstrings(char *libname, int nb)
{
  char buffer[255] ;
  char filename[255] ;
  char command[255] ;
  char argument[255] ;
  char *pos    = NULL ;
  int index    = 0 ;
  int loop     = 0 ;
  int len      = 0 ;
  char **block = NULL ;
  FILE *f      = NULL ;

  pos = strchr(libname, '.') ;
  if (pos != NULL)
  {
    buffer[0] = 0 ;
    strncat(buffer, libname, pos-libname) ;
    
    sprintf(filename, "fd:%s_lib.fd", buffer) ;
    
    block = calloc( nb, sizeof(char*) ) ;
    if (block != NULL)
    {
      f = fopen(filename, "r") ;
      if (f == NULL)
      {
        free(block) ;
        block = NULL ;
      }
      else
      {
        loop = 1 ;
        index = 0 ;
        while (loop)
        {
          if (fgets(buffer, 255, f) != NULL)
          {
            switch (buffer[0])
            {
              case '*' : /* comment */
              {
                break ;
              }

              case '#' :
              {
                if (buffer[1] == '#')
                {
                  sscanf(&buffer[2], "%s %s", command, argument) ;

                  if (strcmp(command, "base") == 0)
                  {
                    /* ##base _Libname */  
                  }
                  else if(strcmp(command, "bias") == 0)
                  {
                    index =  (atoi(argument)/6) - 1 ;   
                  }
                  else if(strcmp(command, "public") == 0)
                  {
                    /* ##public */
                  }  
                  else if(strcmp(command, "private") == 0)
                  {
                    /* ##private */
                  }
                } 
                break ;
              }

              default :
              {
                len = strlen(buffer) ;
                if (len > 0)
                {
                  block[index] = malloc(strlen(buffer) + 1) ;
                  if (block[index]) 
                  {
                    strcpy(block[index], buffer) ;
                  }
                  index ++ ;
                  if (index >= nb)
                  {
                    loop = 0 ;
                  }
                }
              }
            }
          }
          else
          {
            loop = 0 ;
          }
        }
        fclose(f) ;
      }
    }
  }

  return block ;
}

void freestrings(char **block, int nb)
{
  int i ;

  if (block != NULL)
  {
    for (i = 0; i < nb; i++)
    {
        if (block[i] != NULL) free ( block[i] ) ;
    }
    free (block) ;
  }
}
