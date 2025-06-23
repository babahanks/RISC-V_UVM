`ifndef __risc_v_circuit_simulator__
 `define __risc_v_circuit_simulator__
`include "uvm_macros.svh"
`include "uvm_pkg.sv"
import uvm_pkg::*;

class risc_v_circuit_simulator extends uvm_component;
  `uvm_component_utils(risc_v_circuit_simulator)


  logic [31:0] PC;
  logic [31:0] instruction;
  logic [31:0] memory_state[];
  logic [5:0]  regfile_state[];

  int memory_size;
  int regfile_size;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    seq_item_port = new("seq_item_port", this);  // Analysis port constructor
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.run_phase(phase);
    logic[31:0] PC;
    logic[31:0] instruction;

    @(negedge memory_if_i.reset);  // starts when the reset goes negative

    forever begin
      
      while (get_next_instruction_signal() != 1) begin
        @(posedge memory_if_i.clk)
      end      
      `uvm_info("risc_test_monitor", "get_next_instruction_signal is true", UVM_MEDIUM);
      
      // that means start of process or the last instruction has been run
      
      @(posedge memory_if_i.clk)  // wait to get instruction.
      instruction = get_instruction();  
    end 
    
    
  endfunction
      


  virtual function void run_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  function void load_memory( 
    logic[31:0] value,
    int         index);

    memory_state[address] = value; 
    `uvm_info("risc_v_circuit_simulator", $sformatf("load_memory[%0d] = %b", index, value), UVM_MEDIUM); 
  endfunction


endclass
`endif