# SHA-256

1.Overview
- This project implements the SHA-256 cryptographic hash algorithm entirely in Verilog HDL.
- It is designed for FPGA synthesis, demonstrating digital design skills in pipelining, FSM control, message scheduling, and data path design.

2.Features
- Fully compliant with SHA-256 specification
- Modular structure (Message Expansion, Compression, and Control Units)
- Pipeline-friendly design for better throughput
- Parameterizable data width[32bit] and easy integration
- Testbench included for simulation and verification
- Synthesizable and activable on ZCU102 (FPGA board)
  
3.Structures
📂 sha256_verilog
├── src/
│   ├── sha256_top.v            # Top-level module
│   └── receiver                # UART receiver for converting the string input to binary
│   ├── ME.v                    # Message Expansion generates W(16 to 63) based on W(0 to 15)
│   ├── MC.v                    # Message Compression uses inital hash values and does 64 loops to generate the final hash values.
│   └── maj                     # Control Units instantiated in MC
│   └── CHS                     # Control Units instantiated in MC 
│   └── EP0                     # Control Units instantiated in MC
│   └── EP1                     # Control Units instantiated in MC
│   └── SIG0                    # Control Units instantiated in ME
│   └── SIG1                    # Control Units instantiated in ME

├── sim/
│   ├── sha256_tb.v            # Testbench
├── docs/
│   ├── architecture_diagram.png
│   └── waveform_example.png
│
├── README.md
└── LICENSE
