`ifndef __risc_txn_reg_file_write__
  `define __risc_txn_reg_file_write__

`include "risc_txn.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;


class risc_txn_reg_file_write  extends risc_txn;
  
  `uvm_object_utils(risc_txn_reg_file_write)
  
  logic[5:0] address;
  logic[31:0] data;
  
  function new(string name = "risc_txn_reg_file_write.");    
    super.new(name);
  endfunction
  
  function void set_values(
    logic[4:0] address,
    logic[31:0] data);
    
    this.address = address;
    this.data = data;    
  endfunction
    
endclass

`endif