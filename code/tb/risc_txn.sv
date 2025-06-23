`ifndef __risc_txn__
  `define __risc_txn__

`include "uvm_macros.svh"
import uvm_pkg::*;


class risc_txn extends uvm_object;
  
  `uvm_object_utils(risc_txn)
  
  function new(string name = "risc_txn");
    super.new(name);
  endfunction
  
endclass

`endif