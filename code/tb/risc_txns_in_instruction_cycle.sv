`ifndef __risc_txns_in_instruction_cycle__
  `define __risc_txns_in_instruction_cycle__

`include "risc_test_constants.sv"
`include "risc_txn_memory_write.sv"
`include "risc_txn_reg_file_write.sv"

`include "uvm_macros.svh"
import uvm_pkg::*;


class risc_txns_in_instruction_cycle extends uvm_object;
  `uvm_object_utils(risc_txns_in_instruction_cycle)
  
  
  logic[31:0] instruction;
  logic[31:0] post_instruction_PC;
  array_32_bit post_instruction_dut_reg_file_copy;
  
  risc_txn_memory_write    memory_write_queue[$];
  risc_txn_reg_file_write  reg_file_write_queue[$];
  
  function new(string name = "risc_txns_in_instruction_cycle."); 
    super.new(name);
  endfunction
               
  function void set_post_instruction_dut_reg_file_copy(array_32_bit dut_reg_file_copy);
    this.post_instruction_dut_reg_file_copy = dut_reg_file_copy;
  endfunction

  function array_32_bit get_post_instruction_dut_reg_file_copy();
    return this.post_instruction_dut_reg_file_copy;
  endfunction
   
  function void set_instruction(logic[31:0] instruction);
    this.instruction = instruction;
  endfunction
 
  function logic[31:0] get_instruction();
    return instruction;
  endfunction

  
  function void add_txn_memory_write(risc_txn_memory_write txn);
    memory_write_queue.push_back(txn);
  endfunction
    
  
  function void add_txn_reg_file_write(risc_txn_reg_file_write txn);
    reg_file_write_queue.push_back(txn);
  endfunction
  
  function void set_post_instruction_PC(logic[31:0] PC);
    this.post_instruction_PC = PC;
  endfunction


endclass

`endif