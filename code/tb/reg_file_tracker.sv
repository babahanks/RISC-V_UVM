`ifndef   __reg_file_tracker__
  `define __reg_file_tracker__
`include "risc_test_constants.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;

class reg_file_tracker extends uvm_object ;
    `uvm_object_utils(reg_file_tracker)
  
  logic[31:0] reg_file[];
  int reg_file_size;
  
  function new(string name = "reg_file_tracker");
    super.new(name);
    this.reg_file_size = `REG_FILE_SIZE;
    this.reg_file = new[reg_file_size];    
  endfunction
  
  function void copy_dut_reg_file();
    
  endfunction
  	
endclass

`endif