# SHA-256
Online sources I have reviewed: 
- Youtube           :  https://www.youtube.com/watch?v=orIgy2MjqrA&t=103s
- Scientific article:  https://ieeexplore.ieee.org/abstract/document/9367201

  
1.Overview
- This project implements the SHA-256 cryptographic hash algorithm entirely in Verilog on Vivado.
- It is designed for FPGA synthesis, demonstrating digital design skills in pipelining, FSM control, message scheduling, and data path design.


1.1 Dataflow:
  - UART Receiver (8-bit)
  - Message Packer (8-bit → 512-bit)
  - SHA-256 Core (32-bit internal)
  - UART TX (8-bit)


  
2.Features
- Fully compliant with SHA-256 specification
- Modular structure (Message Expansion, Compression, and Control Units)
- Pipeline-friendly design for better throughput
- Parameterizable data width[32bit] and easy integration
- Testbench included for simulation and verification
- Synthesizable and activable on ZCU102 (FPGA board)
  
3.Structures
<img width="1133" height="1041" alt="Screenshot from 2025-11-12 07-17-00" src="https://github.com/user-attachments/assets/ddd3c297-8db7-406d-80e2-dbfb6a9751fc" />
<img width="1725" height="290" alt="Screenshot from 2025-12-05 18-11-22" src="https://github.com/user-attachments/assets/0e1b83a0-42b7-4430-b2c5-84a47247800f" />



- README.md

  
📂 RTL
- sha256_top.v            # Top-level module
- sha256_core.v           # Include Message Expansion and Message Compression
- receiver                # UART receiver for converting the string input to binary (designed by my teacher)
- transmitter             # UART transmitter for converting the string output to binary (designed by my teacher)
- MP.v                    # Receive data from UART RX, compile 16 Words(32 bits/ 1 Word) and send to CORE.
- rME.v                   # Message Expansion generates W(16 to 63) based on W(0 to 15)
- MC.v                    # Message Compression uses inital hash values and does 64 loops to generate the final hash values.
- maj                     # Control Units instantiated in MC
- CHS                     # Control Units instantiated in MC 
- EP0                     # Control Units instantiated in MC
- EP1                     # Control Units instantiated in MC
- SIG0                    # Control Units instantiated in ME
- SIG1                    # Control Units instantiated in ME

📂 Testbench
- sha256_top_tb.v            # Testbench of top module including UART RX-> Message Packer -> CORE -> UART TX
<img width="2219" height="1408" alt="Screenshot from 2025-12-09 21-44-42" src="https://github.com/user-attachments/assets/1233b0d6-477a-46e6-be04-ca3bdb39c576" />



- sha256_core_tb.v            # Testbench of SHA256 core including ME, MC and other computational logic.
<img width="2171" height="1372" alt="Screenshot from 2025-11-28 01-38-52" src="https://github.com/user-attachments/assets/905a9184-a9f1-48c5-b73b-7a599ddc0434" />

- rME_tb.v                    # Testbench of Message Expansion.
  
- MC_tb.v                     # Testbench of Message Compression.
  
- MP_tb.v                     # Testbench of Message Packer.

  
📂 UART
- receiver                # UART receiver for converting the string input to binary (designed by my teacher)
- transmitter             # UART transmitter for converting the string output to binary (designed by my teacher)

📂 Embedded Code
- main.c                  # This file allows us to communicate to ZCU102 board and load input to board, then print out the hash output.
<img width="1144" height="528" alt="Screenshot from 2025-12-10 15-03-21" src="https://github.com/user-attachments/assets/028b6177-73ba-47f0-a85b-c90bbcde0a3f" />
- MEvMC.c                 # Code in C langauge for testing does hash value in hardware is similar to software

- SHA256.c                # Control the activation of MEvMC.c
<img width="2047" height="1486" alt="Screenshot from 2025-12-09 21-44-55" src="https://github.com/user-attachments/assets/23af4f8e-6765-4307-85d9-21a2fd1803da" />




