`ifndef __risc_inst_agent__
 `define __risc_inst_agent__

`include "risc_test_driver.sv"
`include "risc_seq_item_instruction.sv"
`include "risc_test_monitor.sv"

`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM 


class risc_test_agent extends uvm_agent;
  `uvm_component_utils(risc_test_agent)

  risc_test_driver driver;  
  uvm_sequencer#(risc_seq_item_instruction) sequencer;
  risc_test_monitor monitor;

  function new(string name = "risc_test_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver = risc_test_driver::type_id::create("driver", this);
    monitor = risc_test_monitor::type_id::create("monitor", this);
    sequencer = uvm_sequencer#(risc_seq_item_instruction)::type_id::create("sequencer", this);
  	if (sequencer == null) begin
      `uvm_fatal("risc_test_agent", "Sequencer creation failed!")
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
  
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #50;
    phase.drop_objection(this);
    //scoreboard.print_results();
  endtask
  
endclass
`endif