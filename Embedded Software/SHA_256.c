// I desgin this file to compute the hash value via software and then verify it on testbench and waveform.

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "ME.c"

int main(){
    uint32_t state[8] ={
        0x6a09e667,
        0xbb67ae85,
        0x3c6ef372,
        0xa54ff53a,
        0x510e527f,
        0x9b05688c,
        0x1f83d9ab,
        0x5be0cd19
    };
    const uint32_t input_block[16] ={   
        0x53656375, // "Secu"
        0x72652048, // "re H"
        0x61736820, // "ash "
        0x416C676F, // "Algo"
        0x72697468, // "rith"
        0x6D203235, // "m 25"
        0x36800000, // "6" + Padding (0x80) + 0x00...
        0x00000000, // Padding zeros
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000, // Length (High 32-bit)
        0x000000C8, // Length (Low 32-bit) = 200 bits
    };
    uint32_t W[64];
    ME_c(input_block,W);

    MC(state,W);

    printf("Secure Hash Algorithm 256= \n");
    for (int i = 0; i < 8; i++)
    {
        printf("State[%02d] = %08x\n ",i, state[i]);
    }
    return 0;



}
