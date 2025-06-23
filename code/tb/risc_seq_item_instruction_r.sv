`ifndef __risc_seq_item_instruction_r__
    `define __risc_seq_item_instruction_r__

`include "../src/risc_instruction_constants.sv"
`include "risc_test_constants.sv"

`include "risc_seq_item_instruction.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 

class risc_seq_item_instruction_r extends risc_seq_item_instruction;
  
    `uvm_object_utils(risc_seq_item_instruction_r)

  int reg_file_size = `REG_FILE_SIZE;
  
  constraint inst_type_R {inst[6:0] == 7'b0110011;}
  
  constraint limited_register_address {inst[19:15] < reg_file_size;  //r1
                                       inst[24:20] < reg_file_size;  //r2
                                       inst[11:7]  < reg_file_size;} //rd

  
  constraint inst_r_alu_codes {
  {inst[14:12], inst[31:25]} inside {
    {`RISC_R_FUNC_3_ADD,         `RISC_R_FUNC_7_ADD},
    {`RISC_R_FUNC_3_SUBTRACT,    `RISC_R_FUNC_7_SUBTRACT},
    {`RISC_R_FUNC_3_XOR,         `RISC_R_FUNC_7_XOR},
    {`RISC_R_FUNC_3_OR,          `RISC_R_FUNC_7_OR},
    {`RISC_R_FUNC_3_AND,         `RISC_R_FUNC_7_AND},  
    {`RISC_R_FUNC_3_SHIFT_RT_AR, `RISC_R_FUNC_7_SHIFT_RT_AR},  
    {`RISC_R_FUNC_3_SHIFT_LT_LOG, `RISC_R_FUNC_7_SHIFT_LT_LOG} };
  }
  
                 
  function new(string name = "risc_seq_item_instruction_r");
    super.new(name);
  endfunction
  
  

  
  virtual function void do_print(uvm_printer printer);     
    `uvm_info(
      "risc_seq_item_instruction_r", 
      $sformatf("inst[6:0]=%b, rs1= %0d, 	rs2= %0d, 	 rsd = %0d,  func3 = %0d, funct7= %0d",
                inst[6:0],    inst[19:15],  inst[24:20], inst[11:7], inst[14:12], inst[31:25]), 
      UVM_MEDIUM);
  endfunction
  
  

endclass

`endif
