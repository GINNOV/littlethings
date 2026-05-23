#include <exec/types.h>
#include <exec/vm.h>
#include <stdio.h>
#include <unistd.h> // For sleep() if needed for demonstration

/**
 * @brief Waits for the next vertical blanking interrupt.
 * 
 * This function blocks the calling thread until the system signals a VBlank event.
 * In a real graphics driver, this is the most efficient way to synchronize
 * custom buffer writes with the display hardware.
 *
 * @param timeout_ticks The maximum number of ticks to wait. Use a very large number
 *                       to wait indefinitely for the event.
 * @return int Returns 0 upon successful wake-up, -1 on error.
 */
int wait_for_vblank(unsigned long timeout_ticks)
{
    struct timespec ts;
    int result = -1;

    // Initialize the timespec structure.
    // We are waiting for the timeout_ticks to expire, or for an interrupt signal.
    ts.tv_sec = 0;
    ts.tv_nsec = timeout_ticks * TS_NS; // Convert ticks to nanoseconds

    // WaitTOF blocks the calling thread until the timeout expires OR
    // a signal arrives on the wait queue.
    // We pass the address of the timespec structure.
    int wait_status = WaitTOF(&ts);

    if (wait_status == 0) {
        // Success: The wait completed (either by timeout or signal)
        return 0;
    } else {
        // Error occurred during the wait call
        return -1;
    }
}


int main()
{
    printf("Amiga VBlank Waiter Initialized.\n");

    // --- Core Logic ---

    // We use a very large timeout value (e.g., waiting for 10 billion ticks)
    // to ensure the call blocks until the VBlank interrupt occurs.
    const unsigned long INDEFINITE_WAIT = 10000000000UL; 

    printf("Entering WaitTOF()... Waiting for VBlank signal.\n");

    // Call the function. This call will block the main thread here.
    int status = wait_for_vblank(UNDEFINITE_WAIT);

    if (status == 0) {
        printf("VBlank signal received. Resuming buffer writes.\n");
    } else {
        fprintf(stderr, "Error during WaitTOF execution.\n");
    }

    // --- Cleanup ---
    return 0;
}