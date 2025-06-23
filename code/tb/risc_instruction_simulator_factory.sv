`ifndef __risc_instruction_simulator_factory__
	`define __risc_instruction_simulator_factory__

`include "risc_instruction_simulator.sv"
`include "risc_instruction_simulator_r.sv"
`include "risc_instruction_simulator_b.sv"


`include "risc_v_circuit_state.sv"
`include "uvm_macros.svh"
`include "uvm_pkg.sv"
import uvm_pkg::*;


class risc_instruction_simulator_factory extends uvm_object;
  
  static function risc_instruction_simulator get_simulator(logic[31:0] instruction);
    
    //risc_instruction_simulator simulator;
    
    if (instruction[6:0] == 7'b0110011) begin
      risc_instruction_simulator_r sim_r;
      sim_r = new(instruction);
      return sim_r;
    end
    
    if (instruction[6:0] == 7'b1100011) begin
      risc_instruction_simulator_b sim_b;
      sim_b = new(instruction);
      return sim_b;
    end
    
    `uvm_fatal("risc_instruction_simulator_factory", "Unknown instruction");
       
  endfunction
  
  
endclass

`endif