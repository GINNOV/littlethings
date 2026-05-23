#include <exec/types.h>
#include <exec/memory.h>
#include <stdio.h>

/**
 * @brief Allocates 2048 bytes of chip memory using ExecAllocMem().
 * 
 * This routine demonstrates proper dynamic memory allocation on Amiga hardware.
 * It ensures the allocated block is freed upon exit.
 *
 * @return void* A pointer to the allocated block, or NULL if allocation failed.
 */
void *allocate_chip_memory()
{
    void *ptr = NULL;
    const unsigned long allocation_size = 2048;
    const unsigned long alignment = 0; // Standard alignment

    printf("Attempting to allocate %lu bytes of chip memory...\n", allocation_size);

    // ExecAllocMem(size, alignment, flags)
    // MB_CHIP flag forces the allocation to occur in fast, local chip RAM.
    ptr = ExecAllocMem(allocation_size, alignment, MB_CHIP);

    if (ptr != NULL)
    {
        printf("\n==================================================\n");
        printf("SUCCESS: %lu bytes of chip memory allocated at address %p.\n", allocation_size, ptr);
        printf("==================================================\n\n");
        
        // In a real application, you would use 'ptr' here.
        // For this example, we return the pointer to be freed by the caller.
        return ptr;
    }
    else
    {
        printf("\nERROR: Failed to allocate %lu bytes of chip memory.\n", allocation_size);
        return NULL;
    }
}

/**
 * @brief Releases memory previously allocated by ExecAllocMem().
 * 
 * @param ptr The base address of the allocated memory block.
 */
void release_chip_memory(void *ptr)
{
    if (ptr != NULL)
    {
        printf("\nReleasing allocated memory block...\n");
        // ExecFreeMem() is the required counterpart to ExecAllocMem()
        if (ExecFreeMem(ptr, 0, MB_CHIP) == IOError)
        {
            printf("WARNING: ExecFreeMem failed!\n");
        }
        else
        {
            printf("Memory successfully released.\n");
        }
    }
}


int main()
{
    void *my_buffer = allocate_chip_memory();

    // Use the allocated memory (if successful)
    if (my_buffer != NULL)
    {
        // IMPORTANT: Always release dynamically allocated system resources!
        release_chip_memory(my_buffer);
    }

    return 0;
}