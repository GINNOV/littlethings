/*
 * Example 1 - Play the included sound
 *
 * Compile: dcc -f -v -// -3.0 -leasysound
 */

#include <exec/types.h>
#include "easysound.h"
#include "whiff.h"

main() {

    PlayIff(&whiff,           // The sound data
            64,               // Max Volume
            L0,               // Play Sound on the left channel
            -35,              // Priority
            0,                // Play at original rate
            1,                // Play the sound 1 time
            0,                // Play this sample from the beginning
            0,                // Play the whole sample
            1,                // Wait 'til the sample if played
            );

    StopIff(L0);    // Stop Sound on L0

}




