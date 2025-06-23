`ifndef __risc_inst_seq_test__
    `define __risc_inst_seq_test__

`include "risc_test_constants.sv"
//`include "risc_instruction.sv"
//`include "risc_r_instruction.sv"
//`include "risc_i_instruction.sv"
//`include "risc_b_instruction.sv"

`include "risc_seq_item_instruction.sv"
`include "risc_seq_item_instruction_sequence.sv"
`include "risc_test_env.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 


class risc_test extends uvm_test;
  `uvm_component_utils(risc_test)

  risc_test_env env;
  risc_seq_item_instruction_sequence _sequence;
  virtual memory_if memory_if_i;

  
  rand logic[31:0] reg_value;
  

  //uvm_sequencer#(risc_inst_seq_item) sequencer;
  

  function new(string name = "risc_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    `uvm_info("risc_inst_seq_test", "build_phase", UVM_MEDIUM);

    env = risc_test_env::type_id::create("env", this);
  endfunction

  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this); // ✅ Prevent test from ending immediately
    
    `uvm_info("risc_test", "run_phase sequence", UVM_MEDIUM);
     
    _sequence = risc_seq_item_instruction_sequence::type_id::create("seq");
    if (_sequence == null) begin
      `uvm_fatal("risc_test", "Sequence creation failed")
    end
    
    if (env.agent.sequencer == null) begin
      `uvm_fatal("risc_test", "Sequencer is NULL in test!")
    end
    
    
    if (!uvm_config_db#(virtual memory_if)::get(this, "", "memory_if", memory_if_i))
      begin
        `uvm_fatal("DRIVER", "Failed to get virtual interface memory_if")
      end
    
    //seq.print();
    _sequence.start(env.agent.sequencer);// ✅ Start sequence on sequencer
    
    repeat (300) @(posedge memory_if_i.clk);
    
    //#100; // Some wait time
    phase.drop_objection(this); // ✅ Allow test to finish
  endtask
  
  
 
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info("risc_test", "Finalizing risc test...", UVM_MEDIUM);
    env.scoreboard.print_results(); // ✅ Print test report
  endfunction

  

  
endclass

`endif