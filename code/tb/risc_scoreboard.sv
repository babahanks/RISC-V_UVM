`ifndef  __risc_scoreboard__
 `define __risc_scoreboard__

`include "uvm_hdl_util.sv"
`include "type_defs.sv"
`include "reg_file_tracker.sv"
`include "risc_inst_seq_item.sv"
`include "risc_v_circuit_state.sv"
`include "risc_inst_cycle_analyzer.sv"
`include "risc_inst_cycle_analyzer_for_r_inst.sv"
`include "risc_inst_cycle_analyzer_for_i_inst.sv"
`include "risc_inst_cycle_analyzer_for_b_inst.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 




// uvm_scoreboard can have only one uvm_analysis_imp port
// for anymore we need to do the following
//`uvm_analysis_imp_decl(_port_risc_seq_item_instruction);  // for the second port

class risc_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(risc_scoreboard)
  
  reg_file_tracker reg_file_tracker_obj;
  risc_inst_cycle_analyzer_for_r_inst risc_inst_cycle_analyzer_for_r_inst_obj;
  risc_inst_cycle_analyzer_for_i_inst risc_inst_cycle_analyzer_for_i_inst_obj;
  risc_inst_cycle_analyzer_for_b_inst risc_inst_cycle_analyzer_for_b_inst_obj;

  int pass_count = 0; // Track passed tests
  int fail_count = 0; // Track failed tests
  int total_tests = 0;
  logic[31:0] PC_post_last_instruction = 0;

  risc_txns_in_instruction_cycle txns_queue[$];
  //logic[31:0] risc_code[$];
  array_32_bit dut_reg_file_copy_post_last_instruction;
  

  
  //uvm_analysis_imp#(risc_inst_seq_item, risc_scoreboard) seq_imp;
  uvm_analysis_imp#
  	(risc_txns_in_instruction_cycle, risc_scoreboard) 
  	txns_port_to_scoreboard_imp; // Default
  

  function new(string name = "risc_scoreboard", uvm_component parent);
    super.new(name, parent);
    //seq_imp = new("seq_imp", this);
    txns_port_to_scoreboard_imp = new("error_event_port", this);
    //port_risc_seq_item_instruction_imp = new ("port_risc_seq_item_instruction_imp", this);

    risc_inst_cycle_analyzer_for_r_inst_obj = new();
    risc_inst_cycle_analyzer_for_i_inst_obj = new();
    risc_inst_cycle_analyzer_for_b_inst_obj = new();
    
    // initialize
    initialize_dut_reg_file_copy_post_last_instruction();
  endfunction
  
  // write function for the uvm_analysis_imp port
  function void write(risc_txns_in_instruction_cycle txns);
    txns_queue.push_back(txns);
  endfunction

  
  function void initialize_dut_reg_file_copy_post_last_instruction();  
    int size;
    size = `REG_FILE_SIZE;
    
    dut_reg_file_copy_post_last_instruction = new[size];
    
    for (int i=0; i<size; i++) begin
      dut_reg_file_copy_post_last_instruction[i] = 31'b0;
    end 
  endfunction
  
  
  
  function void display_reg_file_copy(array_32_bit dut_reg_file_copy);
    for (int i=0; i<10; i++) begin
      `uvm_info("risc_scoreboard",$sformatf("dut_reg_file_copy[%0d]: %0d", i, dut_reg_file_copy[i]), UVM_MEDIUM);     
    end
  endfunction

  
  virtual task run_phase(uvm_phase phase);
    
    risc_txns_in_instruction_cycle instruction_cycle;
    
    int result = 0;
    

     
    forever begin
	   #100;
      
      if (txns_queue.size() > 0 ) begin
        //`uvm_info("risc_scoreboard", "in forever txns_queue.size() > 0", UVM_MEDIUM)
        
        instruction_cycle = txns_queue.pop_front();
        
        if (instruction_cycle.instruction[6:0] == 7'b0110011) begin
          result = risc_inst_cycle_analyzer_for_r_inst_obj.analyze(instruction_cycle, 
                                                                   PC_post_last_instruction, 
                                                                   dut_reg_file_copy_post_last_instruction);
        end
        else if (instruction_cycle.instruction[6:0] == 7'b0010011) begin
          result = risc_inst_cycle_analyzer_for_i_inst_obj.analyze(instruction_cycle, 
                                                                   PC_post_last_instruction, 
                                                                   dut_reg_file_copy_post_last_instruction);

        end
        else if (instruction_cycle.instruction[6:0] == 7'b1100011) begin
          result = risc_inst_cycle_analyzer_for_b_inst_obj.analyze(instruction_cycle, 
                                                                   PC_post_last_instruction, 
                                                                   dut_reg_file_copy_post_last_instruction);                
        end
        else begin
          `uvm_fatal("risc_scoreboard", "unknown instruction in risc_txns_in_instruction_cycle");        
        end
       
        //wether teh test fails or passes for the next test we accept the current snap shot
        
        PC_post_last_instruction = instruction_cycle.post_instruction_PC;
       	dut_reg_file_copy_post_last_instruction = instruction_cycle.post_instruction_dut_reg_file_copy;
 
        if (result == 1) begin
         pass_count = pass_count + 1;
          //`uvm_info("risc_scoreboard", "---------Tests Passed ", UVM_MEDIUM)
          
        end
        else begin
          fail_count = fail_count + 1;
                    //`uvm_info("risc_scoreboard", "---------Tests Passed ", UVM_MEDIUM)

        end
      end 
    end
    
  endtask
  
  function void analyse_risc_txns_in_instruction_cycle(risc_txns_in_instruction_cycle txns);
    
    //if (txn.instruction
  endfunction
  
  
  function void print_results();
    `uvm_info("risc_scoreboard", $sformatf("Total Tests Run: %0d", total_tests), UVM_MEDIUM)
    `uvm_info("risc_scoreboard", $sformatf("Tests Passed: %0d", pass_count), UVM_MEDIUM)
    `uvm_info("risc_scoreboard", $sformatf("Tests Failed: %0d", fail_count), UVM_MEDIUM)

    if (fail_count == 0)
      `uvm_info("risc_scoreboard", " ALL TESTS PASSED ", UVM_NONE)
    else
      `uvm_info("risc_scoreboard", " SOME TESTS FAILED ", UVM_NONE)
  endfunction

endclass

`endif