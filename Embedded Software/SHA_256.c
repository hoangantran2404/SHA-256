#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "ME.c"

int main(){
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
}
