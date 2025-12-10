#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

#define SERIAL_PORT "/dev/ttyUSB2"
#define BAUDRATE    B115200


#define FRAC_BITS   7
#define SCALE       (1 << FRAC_BITS)
#define MAX_VAL     255.992f
#define MIN_VAL    -256.0f

#define OP_NOP		    0
#define OP_ADD		    1
#define OP_SUB		    2
#define OP_MUL		    3
#define OP_AND		    4
#define OP_OR		    5
#define OP_NOT		    6
#define OP_XOR		    7

static int setup_serial(const char *device) {
    int fd = open(device, O_RDWR | O_NOCTTY);
    if (fd < 0) {
        perror("open");
        return -1;
    }

    struct termios options;
    tcgetattr(fd, &options);
    options.c_cflag = BAUDRATE | CS8 | CLOCAL | CREAD;
    options.c_iflag = IGNPAR;
    options.c_oflag = 0;
    options.c_lflag = 0;
    tcflush(fd, TCIFLUSH);
    tcsetattr(fd, TCSANOW, &options);
    return fd;
}

// =======================
// SAFE WRITE 
// =======================
static int uart_write_full(int fd, uint8_t *buf, int size) {
    int sent = 0;
    while (sent < size) {
        int n = write(fd, buf + sent, size - sent);
        if (n <= 0) return -1;
        sent += n;
    }
    return 0;
}

// =======================
// SAFE READ 
// =======================
static int uart_read_full(int fd, uint8_t *buf, int size) {
    int r = 0;
    while (r < size) {
        int n = read(fd, buf + r, size - r);
        if (n <= 0) return -1;
        r += n;
    }
    return 0;
}

// =======================
// MAIN
// =======================
int main(void) {

    // 64-BYTE SHA256 MESSAGE BLOCK
    uint8_t msg[64] = {
        0x53, 0x65, 0x63, 0x75, //1 
    	0x72, 0x65, 0x20, 0x48, //2 
    	0x61, 0x73, 0x68, 0x20, //3 
    	0x41, 0x6C, 0x67, 0x6F, //4 
    	0x72, 0x69, 0x74, 0x68, //5 
    	0x6D, 0x20, 0x32, 0x35, //6 
    	0x36, 0x80, 0x00, 0x00, //7 
    
    	// Zero Padding 
    	0x00, 0x00, 0x00, 0x00, //8
    	0x00, 0x00, 0x00, 0x00, //9
    	0x00, 0x00, 0x00, 0x00, //10
    	0x00, 0x00, 0x00, 0x00, //11
    	0x00, 0x00, 0x00, 0x00, //12
    	0x00, 0x00, 0x00, 0x00, //13
    	0x00, 0x00, 0x00, 0x00, //14
    
	0x00, 0x00, 0x00, 0x00, //15 (High 32 bits length)
	0x00, 0x00, 0x00, 0xC8  //16
    };

    printf("Opening UART...\n");

    int fd = setup_serial(SERIAL_PORT);
    if (fd < 0) return 1;

    // =======================
    // SEND 64 BYTE MESSAGE
    // =======================
    printf("Sending 64-byte message...\n");
    if (uart_write_full(fd, msg, 64) < 0) {
        printf("UART write error!\n");
        close(fd);
        return 1;
    }

    // =======================
    // READ 32 BYTE OUTPUT HASH
    // =======================
    uint8_t H_out[32];
    printf("Waiting for output hash...\n");

    if (uart_read_full(fd, H_out, 32) < 0) {
        printf("UART read error!\n");
        close(fd);
        return 1;
    }

    // PRINT RESULT
    printf("Hash Output = ");
    for (int i = 0; i < 32; i++)
        printf("%02X ", H_out[i]);
    printf("\n");

    close(fd);
    return 0;
}
