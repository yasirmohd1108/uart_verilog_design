# UART Transmitter & Receiver (Verilog HDL)

A complete UART controller designed in Verilog for FPGA implementation, configured for 9600 baud with a 100 MHz system clock. Includes 16x oversampling on the receiver and a self-checking loopback testbench.

**Files & Modules**
* **`rtl/BAUD_RATE_GENERATOR.v`**: Generates single-cycle enable ticks (`tx_en`, `rx_en`) for 9600 baud and 16x RX oversampling.
* **`rtl/TX.v`**: 4-state FSM (`idle_state`, `start_state`, `data_state`, `stop_state`) serializing 8-bit input data with a `busy` flag.
* **`rtl/RX.v`**: 3-state FSM (`start_state`, `data_state`, `stop_state`) sampling incoming bits at the midpoint (`sample == 7`).
* **`rtl/TOP.v`**: Top-level wrapper connecting the Baud Generator, TX, and RX modules.
* **`sim/UART_TB.v`**: Loopback testbench (`rx = tx`) that automatically verifies transmitted data.

**Simulation Output**
Verified in Vivado with test patterns (`0xA5`, `0x5A`, `0xFF`, `0x00`, `0x3C`):

![UART Simulation Waveform](waveform.png)

**Key Concepts**
* **Enable Ticks over Derived Clocks:** Uses pulse enable ticks (`tx_en`/`rx_en`) to keep everything synchronous in a single 100 MHz clock domain.
* **16x Oversampling:** Samples incoming serial bits at the 8th tick (`sample == 7`) to avoid reading noisy signal edges.
* **Handshaking:** Tracks transmission and reception using `busy`, `ready`, and `ready_clr` flags.
