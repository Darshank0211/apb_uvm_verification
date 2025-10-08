
# APB UVM Verification IP

This repository contains a fully functional, modular UVM environment for APB (Advanced Peripheral Bus) protocol verification. It includes all UVM components, testbench, APB DUT, SystemVerilog assertions, functional coverage, and ready-made scripts. Comprehensive documentation and simulation results are provided.

***

## 📐 Architecture Overview

![uvm_tb_arch](https://github.com/user-attachments/assets/abd86817-874d-4bdd-b112-dc084d9fa431)

- **TB_TOP**: Testbench top module initializing UVM and interface components  
- **TEST/ENV**: Test class and Environment, driving stimulus and UVM connections  
- **SUBSCRIBER**: Collects coverage information for APB protocol features  
- **SCB (Scoreboard)**: Reference model for data and transaction checking  
- **AGENT**: Houses sequencer, driver, and monitor for UVM flow  
- **INTERFACE**: Connects testbench to DUT  
- **DUT**: APB RTL implementation  

***

## 📁 Directory Structure

| File/Folder              | Description                                      |
|--------------------------|--------------------------------------------------|
| `apb_seq_item.sv`        | APB sequence item, randomized transaction fields |
| `apb_seq.sv`             | Random/constrained/paired sequence classes       |
| `apb_seqr.sv`            | UVM sequencer organizing item flow               |
| `apb_drv.sv`             | Driver for protocol-correct stimulus             |
| `apb_mon.sv`             | Monitor capturing bus activity and transactions  |
| `apb_scb.sv`             | Scoreboard for data/memory checking              |
| `apb_subscriber.sv`      | Coverage subscriber                              |
| `apb_agent.sv`           | Integrated sequencer/driver/monitor agent        |
| `apb_env.sv`             | Environment assembling all UVM blocks            |
| `apb_test.sv`            | UVM tests (random, read, write, mixed)           |
| `apb_intf.sv`            | SystemVerilog interface and assertions           |
| `apb_dut.sv`             | Simple APB-compliant slave DUT                   |
| `apb_tb_top.sv`          | Top module connecting everything                 |
| `run.txt`                | TCL script for compilation and simulation        |
| `image.jpg`              | Testbench/architecture block diagram             |
| `coverage.jpg`           | Coverage results screenshot                      |
| `waveform.jpg`           | Simulation waveform result                       |
| `assertion.jpg`          | Assertion report from simulation                 |

***

## 🚦 Functional Verification Flow

- **Sequencer** provides randomized, directed, and paired APB transactions.
- **Driver** pushes protocol-compliant transactions onto the APB DUT signals.
- **Monitor** captures responses and transactions from DUT for analysis and coverage.
- **Scoreboard** cross-checks results against expected values in a reference memory model.
- **Subscriber/Covergroup** monitors functional coverage (addresses, data, protocol phases).
- **Assertions** (in `apb_intf.sv`) validate protocol compliance at signal and timing levels.

***

## 📝 How To Run

1. **Clone this repository**  

2. **Tool requirements**  
   - Mentor Questa/ModelSim or other UVM SystemVerilog simulator.

3. **Add top.svh file in Questasim**

4. **Change the run.do file path**
   - Change the path to your downloaded path and run the code in Questasim using (do run.do) command. 
   

# APB UVM Verification IP

A complete SystemVerilog UVM environment for APB (Advanced Peripheral Bus) protocol verification. Features include full verification IP structure, functional coverage, self-checking scoreboard, SV assertions, stimulus generation, and reports—all demonstrated with real waveform and coverage results.

---



## Protocol Coverage

![coverage](https://github.com/user-attachments/assets/6dc58b2f-d950-482c-b3c3-4f6cddf5a6ba)


- All functional coverpoints in the APB subscriber reach 100%. Every address, write/read, enable/select, data value, protocol phase is exercised by the testbench simulation.

---

## Waveform Example

![waveform](https://github.com/user-attachments/assets/22a859ed-2db7-40d8-bb03-d758a77815ce)


- Confirms correct APB handshakes, address, data, and response timing. Both read and write transfers are cleanly sequenced in the generated verification scenario.

---

## Assertion Pass Report

![assertion](https://github.com/user-attachments/assets/9099b041-dbae-4ed0-bd71-94f2877882e8)


- Every SystemVerilog assertion for protocol checks (setup/enable ordering, signal stability, enable/handshake) passes, confirming high verification confidence on protocol safety and correctness.

---

## Customization and Reuse

- The agent, subscriber, sequencer, monitor, and scoreboard are reusable and extensible for any APB slave variant.
- Coverage, scoreboard, and assertions can be tailored based on target design requirements or extra features.

---

## License

MIT License

