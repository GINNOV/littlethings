
#ifndef ADPCM_H
#define ADPCM_H

extern __asm ULONG DecompressADPCM2(    
        register __a0 UBYTE *Source, register __d0 ULONG Length,
        register __a1 UBYTE *Destination, register __d1 ULONG JoinCode);

extern __asm ULONG DecompressADPCM3(    
        register __a0 UBYTE *Source, register __d0 ULONG Length,
        register __a1 UBYTE *Destination, register __d1 ULONG JoinCode);

extern __asm ULONG CompressADPCM2(
        register __a0 UBYTE *Source, register __d0 ULONG Length,
        register __a1 UBYTE *Destination, register __d1 ULONG JoinCode);

extern __asm ULONG CompressADPCM3(
        register __a0 UBYTE *Source, register __d0 ULONG Length,
        register __a1 UBYTE *Destination,register __d1 ULONG JoinCode);

#endif
