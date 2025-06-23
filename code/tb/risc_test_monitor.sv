`ifndef __risc_test_monitor__
`define __risc_test_monitor__

`include "type_defs.sv"
`include "risc_test_constants.sv"
`include "uvm_hdl_util.sv"
`include "risc_seq_item_instruction.sv"
`include "risc_error_event.sv"
`include "risc_instruction_simulator.sv"
`include "risc_instruction_simulator_factory.sv"
`include "risc_txn_memory_write.sv"
`include "risc_txn_reg_file_write.sv"
`include "risc_txns_in_instruction_cycle.sv"
`include "../src/memory_if.sv"
`include "../src/reg_file_if.sv"
`include "uvm_macros.svh"
`include "uvm_pkg.sv"
import uvm_pkg::*;


class risc_test_monitor extends uvm_monitor;
    `uvm_component_utils(risc_test_monitor)
  
  virtual memory_if memory_if_i;  // Interface to observe
  virtual reg_file_if reg_file_if_i;
 
  uvm_analysis_port#(risc_txns_in_instruction_cycle)  txns_port_to_scoreboard;
  
  string hdl_path_register_   = "risc_test_top.circuit.risc_chip.regfile_.registers[%0d]";
  string hdl_path_memory      = "risc_test_top.circuit.mem.memory[%0d]";
  string hdl_path_PC          = "risc_test_top.circuit.risc_chip.rih.PC";
  string hdl_path_instruction = "risc_test_top.circuit.risc_chip.rih.instruction";
  string hdl_path_signal_get_next_instruction = "risc_test_top.circuit.risc_chip.rih.get_next_instruction";

  
  function new(string name = "risc_test_monitor", uvm_component parent);
    super.new(name, parent);
    txns_port_to_scoreboard = new("txns_port_to_scoreboard", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual memory_if)::get(this, "", "memory_if", memory_if_i)) begin
      `uvm_fatal("MON", "Failed to get memory_if from config DB")
    end
    if (!uvm_config_db#(virtual reg_file_if)::get(this, "", "reg_file_if", reg_file_if_i)) begin
      `uvm_fatal("MON", "Failed to get reg_file_if from config DB")
    end
  endfunction

  

  
  task run_phase(uvm_phase phase);
    logic[31:0] PC;
    logic[31:0] instruction;
    
    @(negedge memory_if_i.reset);  // starts when the reset goes negative
    
    while (get_next_instruction_signal() != 1) begin        
      @(posedge memory_if_i.clk);
    end      

    forever begin
      instruction_cycle(); 
    end
  endtask
    
  
  task instruction_cycle();
    
    int clks = 0;
    int last_memory_write_clk = 0;
    int last_reg_file_write_clk = 0;
    int PC;
    logic [31:0] instruction;
    int reg_address;
    logic [31:0] reg_value;
    logic [31:0] dut_reg_file_copy[];
    
    risc_txn_memory_write   txn_memory_write;
    risc_txn_reg_file_write txn_reg_file_write;
    
    risc_txns_in_instruction_cycle txns;
    
    txns = risc_txns_in_instruction_cycle::type_id::create("txns");
    
    do begin
      if (clks == 5) begin
        instruction = get_instruction();
        txns.set_instruction(instruction);
      end
      // get a memory write        
      if (memory_if_i.mem_req_valid && memory_if_i.mem_rd_wr) begin
        if (last_memory_write_clk != clks - 1) begin // making sure it is not the same
          last_memory_write_clk = clks;
          txn_memory_write = risc_txn_memory_write::type_id::create("txns");
          txn_memory_write.set_values(memory_if_i.mem_wr_addr, memory_if_i.mem_wr_data);
          txns.add_txn_memory_write(txn_memory_write);
        end
      end
      // get reg-file write
      if (reg_file_if_i.reg_wr_data_valid) begin
        if (last_reg_file_write_clk != clks - 1) begin// not consecutive clks
          last_reg_file_write_clk = clks;
          txn_reg_file_write = risc_txn_reg_file_write::type_id::create("txns");
          txn_reg_file_write.set_values(reg_file_if_i.reg_wr_addr, reg_file_if_i.reg_wr_data);
          txns.add_txn_reg_file_write(txn_reg_file_write);          
        end
      end 
      
      @(posedge memory_if_i.clk);
      clks++;
    //end
    end while(get_next_instruction_signal() != 1);
    
    dut_reg_file_copy = uvm_hdl_util::get_reg_file_snapshot();
    txns.set_post_instruction_dut_reg_file_copy(dut_reg_file_copy);
    
    PC = uvm_hdl_util::get_PC();
    txns.set_post_instruction_PC(PC);
    txns_port_to_scoreboard.write(txns);
  endtask

  
  function void display_reg_file_copy(array_32_bit dut_reg_file_copy);
    for (int i=0; i<10; i++) begin
      `uvm_info("risc_test_monitor",$sformatf("dut_reg_file_copy[%0d]: %0d", i, dut_reg_file_copy[i]), UVM_MEDIUM);     
    end
  endfunction
  

  
  function int get_next_instruction_signal();
    logic get_next_instruction = 0;
    int status;
    
    status = uvm_hdl_read(hdl_path_signal_get_next_instruction, get_next_instruction);
    if (status) begin
    	//`uvm_info("risc_test_monitor",  $sformatf("get_next_instruction = %b", get_next_instruction), UVM_MEDIUM);
    end
    else begin
      `uvm_error("risc_test_monitor", "Could not get risc_test_top.circuit.risc_chip.rih.get_next_instruction");
    end
    return get_next_instruction;
  endfunction

  function logic[31:0] get_instruction();
    logic[31:0] instruction = 0;
    int status;
    
    status = uvm_hdl_read(hdl_path_instruction, instruction);
    if (status) begin
    	//`uvm_info("risc_test_monitor",  $sformatf("instruction = %b", instruction), UVM_MEDIUM);
    end
    else begin
      `uvm_error("risc_test_monitor", "Could not get risc_test_top.circuit.risc_chip.rih.get_next_instruction");
    end
    return instruction;
  endfunction

  
endclass
`endif
