#include <Intuition/Intuition.h>
#include <Exec/Types.h>
#include <stdio.h>

// Global pointers for the Intuition library base registers
// These are often needed for library calls.
IntuitionBasePtr gIntuitionBase = NULL;
BP_Screen gScreen = NULL;

/**
 * @brief Creates and opens a screen using IntuitionOpenScreen().
 * 
 * @return int Returns 0 on success, 1 on failure.
 */
int create_and_open_screen()
{
    // 1. Initialize Intuition Base Pointer
    // We must get the base pointer to Intuition before any calls.
    gIntuitionBase = IntuitionBase();
    if (gIntuitionBase == NULL)
    {
        fprintf(stderr, "Error: Could not get Intuition base pointer.\n");
        return 1; // Failure
    }

    // 2. Allocate and Initialize OpenScreen Structure
    // The OpenScreen structure defines the properties of the screen to be created.
    OpenScreen os = {0};
    
    // Set the desired screen properties
    os.ScreenID = 1; // A unique ID for this screen
    os.ScreenType = SCREEN_TYPE_NORMAL; // Standard screen type
    os.ScreenFlags = 0; // No special flags needed for a basic screen
    os.ScreenSize = SCREEN_SIZE_FULL; // Full screen size
    os.ScreenBuffer = NULL; // We are not providing custom buffers
    os.ScreenName = "My Amiga Screen"; // A descriptive name

    // 3. Call IntuitionOpenScreen()
    // This function attempts to allocate system resources and create the screen.
    BP_Screen newScreen = IntuitionOpenScreen(&os);

    // 4. Error Checking and Assignment
    if (newScreen == NULL)
    {
        fprintf(stderr, "Error: IntuitionOpenScreen failed to create a screen.\n");
        // The error is likely due to system limits or improper initialization.
        return 1; // Failure
    }
    else
    {
        // Success! Assign the created screen to our global pointer.
        gScreen = newScreen;
        printf("Successfully created and opened a screen!\n");
        return 0; // Success
    }
}

// --- Main Entry Point ---
int main()
{
    int result;

    printf("Attempting to create screen...\n");
    
    // Attempt the operation
    result = create_and_open_screen();

    if (result == 0)
    {
        printf("Screen created successfully. The program could now enter its main loop.\n");
        
        // In a real application, the screen would be used here.
        // Since this is a minimal example, we must close the screen cleanly on exit.
        printf("Closing the screen...\n");
        if (gScreen != NULL)
        {
            IntuitionCloseScreen(gScreen);
            gScreen = NULL;
            printf("Screen closed gracefully.\n");
        }
    }
    else
    {
        printf("Failed to create screen. Exiting.\n");
    }

    return 0;
}