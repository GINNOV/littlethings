/* easy.c: a complete example of how to open an Amiga function library in
 * C. In this case the function library is Intuition.  Once the Intuition
 * function library is open, any Intuition function can be called.  This
 * example uses the DisplayBeep() function of Intuition to flash the
 * screen With SAS/C (Lattice), compile with lc -L easy.c
 */

/* Declare the return type of the functions we will use.                 */
struct Library *OpenLibrary();  /* These Exec library functions can be   */
void            CloseLibrary(); /* called anytime (Exec is always open). */

void            DisplayBeep();  /* Before using this Intuition function, */
                                /* the Intuition library must be opened  */

struct IntuitionBase *IntuitionBase; /* Get storage for the library base */
                                     /* The base name MUST be            */
                                     /* IntuitionBase                    */
int main()
{
    IntuitionBase=(struct IntuitionBase *)
                  OpenLibrary("intuition.library",33L);
    if(IntuitionBase)           /* Check to see if it actually opened.   */
        {                       /* The Intuition library is now open so  */
        DisplayBeep(0L);        /* any of its functions may be used.     */
        CloseLibrary(IntuitionBase); /* Always close a library if not    */
                                     /* in use.                          */
        }
    else                        /* The library did not open so return an */
       {                        /* error code.  The exit() function is   */
       exit(20);                /* not part of the OS, it is part of the */
       }                        /* compiler link library.                */
}