`ifndef  __risc_inst_cycle_analyzer__
 `define __risc_inst_cycle_analyzer__

`include "type_defs.sv"
`include "risc_v_circuit_state.sv"
`include "risc_txns_in_instruction_cycle.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;


class risc_inst_cycle_analyzer extends uvm_object;
  
  `uvm_object_utils(risc_inst_cycle_analyzer)
  
  
  
/*  
  string register_hdl_path = "risc_test_top.circuit.risc_chip.regfile_.registers[%0d]";
  string memory_hdl_path   = "risc_test_top.circuit.mem.memory[%0d]";
  string PC_hdl_path       = "risc_test_top.circuit.risc_chip.rih.PC";
*/
  
  function new(string name = "risc_inst_cycle_analyzer");
    super.new(name);
  endfunction
  
  function int analyze(
    risc_txns_in_instruction_cycle instruction_cycle,
    logic[31:0] PC_post_last_instruction,
    array_32_bit dut_reg_file_copy_post_last_instruction);
  endfunction
 
  
      // makes sure the value in new regfile and the old regfile is the same
  function int compare_reg_file_copies(
    array_32_bit dut_reg_file_copy,
    array_32_bit dut_reg_file_copy_post_last_instruction);
    
    if (dut_reg_file_copy.size() != dut_reg_file_copy_post_last_instruction.size()) begin      
           `uvm_error("risc_inst_cycle_analyzer", 
                      $sformatf("sizes of the two dut reg file copies are not equal. dut_reg_file_copy size: %0d;  dut_reg_file_copy_post_last_instruction size: %0d", 
                                dut_reg_file_copy.size(), 
                                dut_reg_file_copy_post_last_instruction.size()));      
      return 0;
    end

    // dut_reg_file_copy_post_last_instruction must be udpated by the result of the current instruction
    for (int i=0; i < dut_reg_file_copy.size(); i++) begin
      if (dut_reg_file_copy[i] != dut_reg_file_copy_post_last_instruction[i]) begin
           `uvm_error("risc_inst_cycle_analyzer", 
                      $sformatf("values of the two dut reg file registers copies are not equal. dut_reg_file_copy[%0d]: %0d;  dut_reg_file_copy_post_last_instruction[%0d]: %0d", 
                                i, dut_reg_file_copy[i], 
                                i, dut_reg_file_copy_post_last_instruction[i])); 
        return 0;        
      end
    end
    
    return 1;    
  endfunction
    
  
  
  
  function int check_PC(
    risc_txns_in_instruction_cycle instruction_cycle,
    logic[31:0] last_PC);
    
    if (instruction_cycle.post_instruction_PC != last_PC + 1) begin
      `uvm_fatal("risc_inst_cycle_analyzer", 
                 $sformatf("last_PC: %0d;  instruction_cycle.post_instruction_PC: %0d", 
                          last_PC, instruction_cycle.post_instruction_PC));      
      return 0;                      
    end
    
    return 1;
    
  endfunction   
                 

                 
                 
             
    
    
              
    
 
  
endclass

`endif