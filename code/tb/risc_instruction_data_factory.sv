`ifndef __risc_instruction_data_factory__
    `define __risc_instruction_data_factory__

`include "risc_instruction_data.sv"
`include "risc_r_instruction_data.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 


class risc_instruction_data_factory;
  
  static function risc_instruction_data  create(logic[31:0] instruction);    
    risc_instruction_data rid;    
    if (instruction[6:0] == `RISC_R_INSTRUCTION) begin
      risc_r_instruction_data rrid;
      rrid =  new(instruction);
      rid = rrid;
    end
    else begin    
    	`uvm_fatal("risc_data_instruction_factory", "Unknown Instruction!!")
    end
    return rid;
  endfunction
  
  
endclass

`endif

