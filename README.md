# SHA-256

1.Overview
- This project implements the SHA-256 cryptographic hash algorithm entirely in Verilog on Vivado.
- It is designed for FPGA synthesis, demonstrating digital design skills in pipelining, FSM control, message scheduling, and data path design.

2.Features
- Fully compliant with SHA-256 specification
- Modular structure (Message Expansion, Compression, and Control Units)
- Pipeline-friendly design for better throughput
- Parameterizable data width[32bit] and easy integration
- Testbench included for simulation and verification
- Synthesizable and activable on ZCU102 (FPGA board)
  
3.Structures
<img width="1133" height="1041" alt="Screenshot from 2025-11-12 07-17-00" src="https://github.com/user-attachments/assets/ddd3c297-8db7-406d-80e2-dbfb6a9751fc" />

📂 sha256_verilog
src/
- sha256_top.v            # Top-level module
- receiver                # UART receiver for converting the string input to binary (designed by my teacher)
- ME.v                    # Message Expansion generates W(16 to 63) based on W(0 to 15)
<img width="690" height="1342" alt="Screenshot from 2025-11-15 14-39-38" src="https://github.com/user-attachments/assets/c7ebb689-eaf9-4559-ba8c-c0831a606ebb" />
<img width="1493" height="685" alt="Screenshot from 2025-11-15 14-36-22" src="https://github.com/user-attachments/assets/ef7c4dc3-7b7f-4c98-a2e1-e52866baab57" />

- MC.v                    # Message Compression uses inital hash values and does 64 loops to generate the final hash values.
- maj                     # Control Units instantiated in MC
- CHS                     # Control Units instantiated in MC 
- EP0                     # Control Units instantiated in MC
- EP1                     # Control Units instantiated in MC
- SIG0                    # Control Units instantiated in ME
- SIG1                    # Control Units instantiated in ME
sim/
- sha256_tb.v            # Testbench
docs/
- architecture_diagram.png
- waveform_example.png
- README.md
- LICENSE
