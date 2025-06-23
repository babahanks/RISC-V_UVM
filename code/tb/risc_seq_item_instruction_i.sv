
`ifndef __risc_seq_item_instruction_i__
    `define __risc_seq_item_instruction_i__

`include "risc_test_constants.sv"
`include "risc_instruction_constants.sv"
`include "risc_seq_item_instruction.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 

class risc_seq_item_instruction_i extends risc_seq_item_instruction;
  `uvm_object_utils(risc_seq_item_instruction_i)
  
  
  int reg_file_size = `REG_FILE_SIZE;

  
  constraint inst_type_I {inst[6:0] == 7'b0010011;}
  
  constraint limited_register_address {inst[19:15] < reg_file_size;  //r1
                                       inst[11:7]  < reg_file_size;}  //rd

   
  constraint func3_constraints {  // func3
    inst[14:12] inside {
		RISC_I_FUNC_3_ADD,
  		RISC_I_FUNC_3_XOR,
		RISC_I_FUNC_3_OR,
  		RISC_I_FUNC_3_AND,
  		RISC_I_FUNC_3_SHIFT_LT_LOG,
		RISC_I_FUNC_3_SHIFT_RT_LOG,
  		RISC_I_FUNC_3_SHIFT_RT_AR,
		RISC_I_FUNC_3_SET_LESS_THAN,
		RISC_I_FUNC_3_SET_LESS_THAN_U  
    }
  }
  
  constraint funct7_constraints {
    // Only valid for shift operations
    if      (funct3 == RISC_I_FUNC_3_SHIFT_LT_LOG) inst[31:25] = 0x00;
    else if (funct3 == RISC_I_FUNC_3_SHIFT_RT_LOG) inst[31:25] = 0x00;
    else if (funct3 == RISC_I_FUNC_3_SHIFT_RT_AR)  inst[31:25] = 0x20;
  }

  

  
  function new(string name = "risc_instruction_i");
    super.new(name);
  endfunction
  
  
  virtual function void do_print(uvm_printer printer);
    //super.do_print(printer); 
    `uvm_info("risc_seq_item_instruction_i", 
              $sformatf("inst[6:0]=%b, inst[14:12]=%b, inst[31:25]=%b",
                         inst[6:0],    inst[14:12],    inst[31:25]), 
              UVM_MEDIUM);

  endfunction
  
endclass

`endif
