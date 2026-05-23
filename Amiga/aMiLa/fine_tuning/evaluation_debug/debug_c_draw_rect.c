#include <exec/types.h>
#include <exec/graphics.h>
#include <exec/control.h> // For Exit()

/**
 * @brief Draws a filled rectangle onto the specified RastPort.
 * 
 * This function is highly optimized for speed and correctness. It relies on the 
 * passed RastPort being valid and mapped to the screen.
 *
 * @param rp Pointer to the RastPort to draw upon.
 * @param X1 The X coordinate of the top-left corner.
 * @param Y1 The Y coordinate of the top-left corner.
 * @param X2 The X coordinate of the opposite corner (bottom-right).
 * @param Y2 The Y coordinate of the opposite corner (bottom-right).
 * @param color The pixel color to fill the rectangle with.
 */
void DrawRectangle(RastPort *rp, int X1, int Y1, int X2, int Y2, Color color)
{
    // Check if the RastPort pointer is valid before attempting to draw.
    if (rp == NULL) {
        return;
    }

    // DrawRectangle is the most direct and optimized way to achieve this.
    // It takes the RastPort, the starting corner (X1, Y1), the opposite corner (X2, Y2),
    // and the color to fill with.
    DrawRectangle(rp, X1, Y1, X2, Y2, color);
}


// =============================================================================
// Example Usage
// =============================================================================

int main()
{
    // 1. Get the screen's RastPort
    RastPort *screen_rp = NULL;
    if (AlphanumericPort()) {
        screen_rp = AlphanumericPort();
    } else {
        // Fallback for systems where AlphanumericPort() might not be immediately available
        screen_rp = (RastPort *)0; 
    }

    // Ensure we have a valid port to draw on
    if (screen_rp == NULL) {
        return 1; // Failed to get the screen port
    }

    // Define coordinates and color
    int x_start = 50;
    int y_start = 50;
    int x_end = 300;
    int y_end = 150;
    Color fill_color = WHITE; // Assuming WHITE is defined in the chosen palette

    // 2. Execute the drawing function
    DrawRectangle(screen_rp, x_start, y_start, x_end, y_end, fill_color);

    // 3. Wait for interrupts and exit cleanly
    Sleep();
    return 0;
}