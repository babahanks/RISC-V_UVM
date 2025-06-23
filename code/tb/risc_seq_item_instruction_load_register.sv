`ifndef __risc_seq_item_instruction_load_register__
    `define __risc_seq_item_instruction_load_register__

`include "risc_instruction_constants.sv"
`include "risc_seq_item_instruction.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 

class risc_seq_item_instruction_load_register extends risc_seq_item_instruction;
  
  `uvm_object_utils(risc_seq_item_instruction_load_register)

  /*
  	A class to add random values to registers.
    It generates a random value is generated for inst[31:20], the immediate value.
    This is added to the zeros in the reg[0]
    The destination register reg[index passed in]
  */

  
  constraint inst_type_R {inst[6:0] == 7'b0010011;}
  
  constraint rs1_constraint {inst[19:15] == 7'b0;}  
  // reg[0] can only have zeros. 
  // We will be adding the zeros there to rand num created here 

  constraint rd_constraint {inst[11:7] == current_index;}  
  // setting the destination 

  constraint inst_r_alu_codes {
  {inst[14:12], inst[31:25]} inside {
    {`RISC_R_FUNC_3_ADD,         `RISC_R_FUNC_7_ADD}};
  }
  
                 
  function new(string name = "risc_seq_item_instruction_load_register");
    super.new(name);
  endfunction
  
  function void set_parameters(int current_index);
    super.set_parameters(current_index);
	
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