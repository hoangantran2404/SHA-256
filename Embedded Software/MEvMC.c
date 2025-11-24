#include <stdint.h>


uint32_t ROTRIGHT(uint32_t a, uint32_t b) {
    return (a >> b) | (a << (32 - b));
}
uint32_t SIG0(uint32_t x)      
    { return ROTRIGHT(x,7)  ^  ROTRIGHT(x,18)  ^ ((x)>>3);  };
uint32_t SIG1(uint32_t x)      
    { return ROTRIGHT(x,17) ^  ROTRIGHT(x,19)  ^ ((x)>>10); };

uint32_t CH(uint32_t x, uint32_t y, uint32_t z) 
    {   return (((x) & (y))  ^ ((~x) & (z)));                     };
uint32_t MAJ(uint32_t x, uint32_t y, uint32_t z)
    {   return (((x) & (y))  ^ ((x) & (z)) ^ ((y) & (z)));        };
uint32_t EP0(uint32_t x)
    {   return (ROTRIGHT(x,2) ^ ROTRIGHT(x,13) ^ ROTRIGHT (x,22));};
uint32_t EP1(uint32_t x)
    {   return (ROTRIGHT(x,6) ^ ROTRIGHT(x,11) ^ ROTRIGHT (x,25));};
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
static const uint32_t k[64] = {
	0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
	0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
	0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
	0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
	0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
	0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
	0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
	0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
};
void MC(uint32_t state[8], const uint32_t message[64])
{
    uint32_t a,b,c,d,e,f,g,h,t1,t2;
    uint32_t i;

    a = state[0];
    b = state[1];
    c = state[2];
    d = state[3];
    e = state[4];
    f = state[5];
    g = state[6];
    h = state[7];

    for (i=0 ; i < 64; i++){
        t1 = h + EP1(e) + CH(e,f,g) + k[i] + message[i];
        t2 = EP0(a) + MAJ(a,b,c);
        h = g;
        g = f;
        f = e;
        e = d + t1;
        d = c;
        c = b;
        b = a;
        a = t1 + t2;
    }

    state[0] += a;
    state[1] += b;
    state[2] += c;
    state[3] += d;
    state[4] += e;
    state[5] += f;
    state[6] += g;
    state[7] += h;
}
