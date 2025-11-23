#include <stdint.h>
#include "ME.h"


uint32_t ROTRIGHT(uint32_t a, uint32_t b) {
    return (a >> b) | (a << (32 - b));
}
uint32_t SIG0(uint32_t x)       { return ROTRIGHT(x,7)  ^  ROTRIGHT(x,18)  ^ ((x)>>3);  };
uint32_t SIG1(uint32_t x)       { return ROTRIGHT(x,17) ^  ROTRIGHT(x,19)  ^ ((x)>>10); };

void ME_c(const uint32_t message[16], uint32_t W[64])
{

    //Message Expansion
    for (int i=0; i<16 ; i++)
    {
        W[i] = message[i];
    }
    for (int i=16; i<64 ; i++)
    {
        W[i] = SIG1(W[i-2]) + W[i-7] + SIG0(W[i-15]) + W[i-16];
    }
}
