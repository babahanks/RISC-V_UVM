`ifndef __risc_instruction_data__
    `define __risc_instruction_data__


`include "risc_instruction_constants.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM


class risc_instruction_data;
  
  function new(logic[31:0] instruction);
  endfunction
  
                   
  virtual function int executedCorrectly();
  endfunction
  
  virtual function void print();
  endfunction

      
endclass

`endif