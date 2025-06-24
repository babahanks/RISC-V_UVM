`ifndef __risc_seq_item_instruction_sequence__
    `define __risc_seq_item_instruction_sequence__
`include "../rtl/risc_instruction_constants.sv"
`include "risc_test_constants.sv"
`include "risc_seq_item_instruction.sv"
`include "risc_seq_item_instruction_r.sv"
`include "risc_seq_item_instruction_b.sv"
`include "risc_seq_item_instruction_load_register.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 

class risc_seq_item_instruction_sequence extends uvm_sequence#(risc_seq_item_instruction);
  `uvm_object_utils(risc_seq_item_instruction_sequence)
  
  function new(string name = "risc_seq_item_instruction_sequence");
    super.new(name);
  endfunction
  
  virtual task pre_start();
    if (m_sequencer == null) begin
      `uvm_fatal("risc_seq_item_instruction_sequence", "m_sequencer is NULL before start!")
    end
    super.pre_start();
  endtask

  task body();
    risc_seq_item_instruction inst;
    risc_seq_item_instruction inst_array[$];
    string hdl_path;
    int status;
    int random_instruction;
    
    int start_address = `MEMORY_CODE_START_ADDR;
    int end_address   = `MEMORY_CODE_END_ADDR;
    int reg_file_size = `REG_FILE_SIZE;
    
    //int start_address = 0;
    //int end_address = 100;

    risc_seq_item_instruction_b::min_index = start_address;
    risc_seq_item_instruction_b::max_index = end_address;
    
    
    // instruction to initialize the registers with some random data. 
    // reg[0] is always 0.
    for (int j=1; j <= reg_file_size; j++) begin
      inst = risc_seq_item_instruction_load_register::type_id::create("risc_seq_item_instruction_load_register");
      inst.set_parameters(j);      
      if (!inst.randomize())
        `uvm_error("risc_test", "Randomization failed!")        
      inst.build_inst();
      inst.print();
      inst_array.push_back(inst);
    end
    
    for (int i=32; i<= end_address; i++) begin
      random_instruction = $urandom_range(1,0);
      random_instruction = $urandom_range(0);
      `uvm_info("risc_seq_item_instruction_sequence", $sformatf("random_instruction: %0d", random_instruction), UVM_MEDIUM);               
          
      case (random_instruction)
        0: inst = risc_seq_item_instruction_r::type_id::create("risc_seq_item_instruction_r");
        1: inst = risc_seq_item_instruction_b::type_id::create("risc_seq_item_instruction_b");
        default: `uvm_fatal("SEQ_ERR", $sformatf("Invalid instruction type: %0d", random_instruction))
      endcase
            
      inst.set_parameters(i);      
      if (!inst.randomize())
        `uvm_error("risc_test", "Randomization failed!")
        
      inst.build_inst();
      inst.print();
      inst_array.push_back(inst);          
    end
    
    while (inst_array.size() > 0 ) begin
      inst = inst_array.pop_front();
      start_item(inst);
      finish_item(inst);      
    end
        
  endtask
  
endclass
  `endif
