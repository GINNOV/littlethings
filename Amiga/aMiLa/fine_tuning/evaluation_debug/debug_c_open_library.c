#include <Intuition/Intuition.h>
#include <Exec/Exec.h>
#include <unistd.h> // For Sleep()

/**
 * @brief Opens Intuition.library, verifies the base pointer, and closes the library.
 * 
 * This routine demonstrates the proper lifecycle management for a loaded library:
 * Open -> Use -> Close.
 * 
 * @return int Returns 0 on successful execution.
 */
int main()
{
    Library *IntuitionLib = NULL;
    BPort intu_door = SYSDIR;
    
    // ---------------------------------------------------------------------
    // 1. Open the Library
    // ---------------------------------------------------------------------
    
    // Attempt to open Intuition.library.
    // The flags (TLIB) request the library be loaded into the task's address space.
    IntuitionLib = OpenLibrary(&Intuition, intu_door, TLIB);

    // ---------------------------------------------------------------------
    // 2. Check the Base Pointer
    // ---------------------------------------------------------------------
    
    if (IntuitionLib == NULL)
    {
        // CRITICAL FAILURE: If OpenLibrary returns NULL, the library could not be found 
        // or loaded into memory. This is usually a fatal system error.
        printf("FATAL ERROR: Could not obtain base pointer for Intuition.library.\n");
        return 1; // Indicate failure
    }
    else
    {
        // SUCCESS: IntuitionLib now holds the valid base pointer (Library *) 
        // allowing access to all Intuition functions.
        printf("SUCCESS: Intuition.library successfully loaded into memory.\n");
        printf("Base pointer verified.\n");
    }

    // ---------------------------------------------------------------------
    // 3. Close the Library
    // ---------------------------------------------------------------------
    
    if (IntuitionLib != NULL)
    {
        CloseLibrary(IntuitionLib);
        printf("Intuition.library successfully unloaded from memory.\n");
    }

    // In a real application, you would likely wait here for events.
    // Sleep(3); 
    
    return 0; // Indicate successful program exit
}