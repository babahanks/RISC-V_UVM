`ifndef __risc_seq_item_instruction__
    `define __risc_seq_item_instruction__

`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 

class risc_seq_item_instruction extends uvm_sequence_item;
  `uvm_object_utils(risc_seq_item_instruction)
  
  rand logic[31:0]  inst;
  int current_index;

  function new(string name = "risc_seq_item_instruction");
    super.new(name);
  endfunction
  
  virtual function void set_parameters(int index);
    this.current_index = index;
  endfunction
  
  virtual function void build_inst();
  endfunction
  
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer); // Call parent do_print()
  endfunction
  
  
endclass

`endif
