/*
 * Play an external sound, i.e the sample is loaded first and then played
 *
 * Compile: dcc -f -v -// -3.0 -leasysound
 */

#include <exec/types.h>
#include "easysound.h"

main() {

    struct SoundInfo *whiff;

    /*
     * Load an 8SVX Sample
     */
    whiff = (struct SoundInfo *)LoadIff("whiff.8svx");

    /*
     * If the sample isn't loaded exit
     */
    if (!whiff) {
        puts("Sorry, I can't play this file");
    }

    /*
     * Play the sample
     */
    PlayIff(whiff,            // The sound data
            64,               // Max Volume
            L0,               // Play Sound on the left channel
            -35,              // Priority
            0,                // Play at original rate
            1,                // Play the sound 1 time
            0,                // Play this sample from the beginning
            0,                // Play the whole sample
            1,                // Wait 'til the sample if played
            );

    /*
     * Stop the sample
     */
    StopIff(L0);    // Stop Sound on L0

    /*
     * Free the memory
     */
    RemoveIff(whiff);
}




