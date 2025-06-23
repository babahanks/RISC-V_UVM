`ifndef __risc_instruction_simulator__
 `define __risc_instruction_simulator__
`include "../src/ALU.sv"
`include "risc_v_circuit_state.sv"
`include "uvm_macros.svh"
`include "uvm_pkg.sv"
import uvm_pkg::*;


class risc_instruction_simulator extends uvm_object;
  
  logic[31:0] instruction;
  
  function new(logic[31:0] instruction);
    this.instruction = instruction;
  endfunction
  
  virtual function void simulate(ref risc_v_circuit_state state);
  endfunction
  
endclass

`endif
