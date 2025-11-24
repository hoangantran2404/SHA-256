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
<img width="1604" height="242" alt="Screenshot from 2025-11-21 17-46-31" src="https://github.com/user-attachments/assets/6b844e0b-3bbe-48b0-8bc4-2187ed04af32" />


- README.md
📂 RTL
- sha256_top.v            # Top-level module
- sha256_core.v           # Include Message Expansion and Message Compression
- receiver                # UART receiver for converting the string input to binary (designed by my teacher)
- transmitter             # UART transmitter for converting the string output to binary (designed by my teacher)
- rME.v                   # Message Expansion generates W(16 to 63) based on W(0 to 15)
- MC.v                    # Message Compression uses inital hash values and does 64 loops to generate the final hash values.
- maj                     # Control Units instantiated in MC
- CHS                     # Control Units instantiated in MC 
- EP0                     # Control Units instantiated in MC
- EP1                     # Control Units instantiated in MC
- SIG0                    # Control Units instantiated in ME
- SIG1                    # Control Units instantiated in ME

📂 Testbench
- sha256_tb.v            # Testbench

  
📂 UART
- receiver                # UART receiver for converting the string input to binary (designed by my teacher)
- transmitter             # UART transmitter for converting the string output to binary (designed by my teacher)



