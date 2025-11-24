#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "MEvMC.c"

int main(){
// Message Expander

    uint32_t message [16] ={
        0x61626380, 0x00000000, 0x00000000, 0x00000000, // "abc" + 1 padding bit
		0x00000000, 0x00000000, 0x00000000, 0x00000000,
		0x00000000, 0x00000000, 0x00000000, 0x00000000,
		0x00000000, 0x00000000, 0x00000000, 0x00000018 
    };

    uint32_t W[64];
    ME_c(message,W);

    printf("ME(\"abc\")= \n");
    for (int i = 0; i < 64; i++)
    {
        printf("W[%02d] = %08x\n ",i, W[i]);
    }
    return 0;

// Message Compression
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
    const uint32_t message[64] ={    // "abc"
        0x61626380,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000018,
        0x61626380,
        0x000f0000,
        0x7da86405,
        0x600003c6,
        0x3e9d7b78,
        0x0183fc00,
        0x12dcbfdb,
        0xe2e2c38e,
        0xc8215c1a,
        0xb73679a2,
        0xe5bc3909,
        0x32663c5b,
        0x9d209d67,
        0xec8726cb,
        0x702138a4,
        0xd3b7973b,
        0x93f5997f,
        0x3b68ba73,
        0xaff4ffc1,
        0xf10a5c62,
        0x0a8b3996,
        0x72af830a,
        0x9409e33e,
        0x24641522,
        0x9f47bf94,
        0xf0a64f5a,
        0x3e246a79,
        0x27333ba3,
        0x0c4763f2,
        0x840abf27,
        0x7a290d5d,
        0x065c43da,
        0xfb3e89cb,
        0xcc7617db,
        0xb9e66c34,
        0xa9993667,
        0x84badedd,
        0xc21462bc,
        0x1487472c,
        0xb20f7a99,
        0xef57b9cd,
        0xebe6b238,
        0x9fe3095e,
        0x78bc8d4b,
        0xa43fcf15,
        0x668b2ff8,
        0xeeaba2cc,
        0x12b1edeb
    };
    MC(state,message);

    printf("MC(\"abc\")= \n");
    for (int i = 0; i < 8; i++)
    {
        printf("State[%02d] = %08x\n ",i, state[i]);
    }
    return 0;



}
