# SHA-256 Implementation on ZCU102

## 1. Overview
This project implements the SHA-256 cryptographic hash algorithm entirely in Verilog using the Xilinx Vivado Design Suite. It is designed for FPGA synthesis, specifically targeting the ZCU102 board.

The project demonstrates advanced digital design skills, including:
  - Pipelining: Optimized data paths for better throughput.
  - FSM Control: Complex state machine logic for message scheduling.
  - Data Path Design: Efficient 32-bit internal processing with 512-bit message blocks.
  - Hardware-Software Co-design: Integration with C-based embedded code for verification.
  
## 2. Features
  - Compliant: Fully compliant with the standard SHA-256 specification.
  - Modular: distinct units for Message Expansion (ME), Message Compression (MC), and Control.
  - High Throughput: Pipeline-friendly design architecture.
  - Flexible: Parameterizable data width (default 32-bit) for easy integration.
  - Verified: Includes a comprehensive Testbench for simulation and C code for hardware verification.
  - Hardware Ready: Synthesizable and tested on the Xilinx ZCU102 FPGA board.

## 3. Industrial Applications (FPGA, SoC, IC) 
SHA-256 is a cornerstone of modern digital security. Implementing it in hardware (Verilog) offers significant advantages over software, making it critical in the following domains:

* **FPGA (Field Programmable Gate Arrays):**
    * **Blockchain Technology:** FPGAs utilize massive parallelism to perform high-speed hashing required for cryptocurrency mining and blockchain validation.
    * **Network Acceleration:** Used in SSL/TLS offloading to verify data packet integrity in real-time without burdening the network infrastructure.

* **SoC (System on Chip):**
    * **Secure Boot (Root of Trust):** In modern SoCs (like the Zynq UltraScale+ on the ZCU102), SHA-256 verifies the integrity of the bootloader and OS kernel before the system starts. If the hash doesn't match, the system prevents booting to block malware.
    * **Hardware Acceleration:** It acts as a dedicated co-processor, allowing the main CPU (e.g., ARM Cortex) to focus on application logic while the hardware handles cryptography efficiently.

* **IC (Integrated Circuits) & Smart Cards:**
    * **Authentication:** Essential in EMV banking cards and SIM cards for generating digital signatures during transactions.
    * **IoT Security:** Low-power hardware implementations ensure data integrity in resource-constrained IoT sensors where software hashing would consume too much battery.

## 4. Architecture & Dataflow
The data processing flow moves from the UART receiver through the SHA-256 core and back to the transmitter.
<img width="1133" height="1041" alt="Screenshot from 2025-11-12 07-17-00" src="https://github.com/user-attachments/assets/ddd3c297-8db7-406d-80e2-dbfb6a9751fc" />

## 5. Project Structure
The repository is organized as follows:
- README.md

### 📂 RTL

| Module Name | Type | Function / Description |
| :--- | :---: | :--- |
| `sha256_top.v` | **Top Level** | Main entry point; connects UART to SHA Core. |
| `sha256_core.v` | **Core** | Wrapper containing ME and MC units. |
| `MP_in.v` | **Datapath** | **Message Packer:** Compile data from RX then send to core |
| `MP_out.v` | **Datapath** | **Message Packer:** Compile data from core then send to TX|
| `ME.v` | **Compute** | **Message Expansion:** Generates schedule words $W_{16}$..$W_{63}$. |
| `MC.v` | **Compute** | **Message Compression:** Performs 64-round hash loop. |
| `maj.v` / `CHS.v` | **Logic** | Helper math functions for SHA-256 calculation. |
| `receiver.v` | **IO** | UART Receiver (RX). |
| `transmitter.v` | **IO** | UART Transmitter (TX). |

### 📂 Testbench          

| Testbench File | Description |
| :--- | :--- |
| `sha256_top_tb.sv` | Full system simulation (UART -> Core -> UART) |
| `sha256_core_tb.sv` | Core logic simulation |
| `ME_tb.sv` | Message Expansion unit test |
| `MC_tb.sv` | Message Compression unit test |
| `MP_in_tb.sv` | Message Packer unit test (in)|
| `MP_out_tb.sv` | Message Packer unit test (out)|
| `RX_tb.v` | UART Receiver unit test |
| `TX_tb.v` | UART Transmitter unit test |

### 📂 Embedded_Code      

| File Name | Role | Function / Description |
| :--- | :---: | :--- |
| `main.c` | **Entry Point** | **UART Handler:** Communicates with the board, loads input data, and prints the final hash output. |
| `MEvMC.c` | **Verification** | **Software Model:** Pure C implementation of SHA-256 used to verify hardware accuracy. |
| `SHA256.c` | **Driver** | **Control Logic:** Manages the activation and execution flow of the `MEvMC` verification. |

## 6. Getting Started

### Prerequisites
  -  Xilinx Vivado Design Suite (2020.2 or later recommended)
  -  ZCU102 FPGA Evaluation Board
  -  Terminal Emulator (TeraTerm, PuTTY, etc.)

### Simulation
  1. Open the project in Vivado.
  2. Set sha256_top_tb.v as the top simulation source.
  3. Run Behavioral Simulation to verify the waveform outputs against the expected SHA-256 hash.

### Hardware Implementation
  1. Run Synthesis, Implementation, and Generate Bitstream in Vivado.
  2. Export Hardware (including bitstream) to Vitis/SDK.
  3. Load the main.c embedded code onto the ZCU102 ARM processor.
  4. Connect the ZCU102 to your PC via UART/USB.
  5. Open your terminal emulator (Baud Rate: 115200).
  6. Input a string to see the calculated SHA-256 hash returned.

## 7. References
  -  Concept: [SHA-256 Step-By-Step Explanation(Youtube)](https://www.youtube.com/watch?v=orIgy2MjqrA&t=103s)
  -  Research: [High-Performance Multimem SHA-256 Accelerator (IEEE)](https://ieeexplore.ieee.org/abstract/document/9367201)

## 8. Acknowledgments
  -  UART Receiver/Transmitter modules provided by course instructor.
  -  GEMINI thinking 3 pro helps me how to decorate file README.md

## 9. Screenshots
  -  This is the schematic of my project SHA256.
<img width="1754" height="277" alt="Screenshot from 2025-12-25 10-29-58" src="https://github.com/user-attachments/assets/40cd0df9-d9f2-406e-a949-0e6ea2e5e8f1" />

  -  This is the picture when I run simulation of file sha256_top_tb.v. I usually use waveform to check timing delay and errors to correct dataflow.
<img width="2219" height="1408" alt="Screenshot from 2025-12-09 21-44-42" src="https://github.com/user-attachments/assets/1233b0d6-477a-46e6-be04-ca3bdb39c576" />

  -  This picture shows the center computational logic (core of the project).
<img width="2171" height="1372" alt="Screenshot from 2025-11-28 01-38-52" src="https://github.com/user-attachments/assets/905a9184-a9f1-48c5-b73b-7a599ddc0434" />

  -  This picture shows the hash output of string" Secure Hash Algorithm 256" running on ZCU102 FPGA board.
<img width="1922" height="934" alt="Screenshot from 2025-12-18 01-50-02" src="https://github.com/user-attachments/assets/f9ae7a91-a356-4ed7-9623-42e221bee434" />


  -  The file in this picture is SHA256.c, which I use the hash output on Software to verify the result on Hardware
<img width="2047" height="1486" alt="Screenshot from 2025-12-09 21-44-55" src="https://github.com/user-attachments/assets/23af4f8e-6765-4307-85d9-21a2fd1803da" />



