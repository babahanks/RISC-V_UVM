`ifndef __risc_test_driver__
 `define __risc_test_driver__

`include "risc_test_constants.sv"
`include "risc_seq_item_instruction.sv"

`include "../src/memory_if.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM

class risc_test_driver extends uvm_driver#(risc_seq_item_instruction);
  `uvm_component_utils(risc_test_driver)
  
  int code_start_address = `MEMORY_CODE_START_ADDR;
  int code_end_address = `MEMORY_CODE_END_ADDR;
  int memory_size = `MEMORY_SIZE;
  

  string hdl_register = "risc_test_top.circuit.risc_chip.regfile_.registers[%0d]";
  
  virtual memory_if memory_if_i;
  uvm_analysis_port#(risc_seq_item_instruction) port_to_scoreboard; // ✅ Sends seq_items to the scoreboard
	
  
  
  function new(string name = "risc_inst_driver", uvm_component parent);
    super.new(name, parent);
    port_to_scoreboard = new ("port_to_scoreboard", this);
  endfunction
  
    //uvm_config_db#(virtual risc_v_2_circuit)::set(null, "*", "risc_v_2_circuit", risc_v_2_circuit);

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);    
    if (!uvm_config_db#(virtual memory_if)::get(this, "", "memory_if", memory_if_i))
      begin
        `uvm_fatal("DRIVER", "Failed to get virtual interface memory_if")
      end
    
    /*
    if (!uvm_config_db#(risc_v_circuit_simulator)::get(this, "", "simulator", simulator)) 
      begin
  		`uvm_fatal("GET_SIM", "Failed to get simulator handle from config DB")
	  end
    */
  endfunction
  
  
  
  
  task run_phase(uvm_phase phase);
    i
    risc_seq_item_instruction txn;    
    
    @(posedge memory_if_i.reset)
    `uvm_info("risc_test_driver",  $sformatf("memory_if_i.reset = %b", memory_if_i.reset), UVM_MEDIUM);
    
    @(posedge  memory_if_i.clk);
    @(posedge  memory_if_i.clk);
    
    for (int i=code_start_address; i <= code_end_address; i++) begin
      seq_item_port.get_next_item(txn);
      
      `uvm_info("risc_test_driver",  $sformatf("txn.inst = %b", txn.inst), UVM_MEDIUM);
      load_memory(txn.inst, i);
      //simulator(txn.inst, i);
      port_to_scoreboard.write(txn);      
      seq_item_port.item_done(); // ✅ Ensure transaction completes            
    end 
    
    for (int j = code_end_address + 1; j < memory_size; j++) begin
      load_memory(32'b0, j);
    end
  endtask
    
  
  function void load_memory(logic[31:0] value, int index);
    int status;
    
    string hdl_path = $sformatf("risc_test_top.circuit.mem.memory[%0d]", index);

      status = uvm_hdl_deposit(hdl_path, value);
      if (status) begin
        `uvm_info("risc_test_driver", $sformatf("data written to risc_test_top.circuit.mem.memory[%0d] = %b", index, value), UVM_MEDIUM);            
      end 
      else begin
        `uvm_error("risc_test_driver", $sformatf("Failed to write data to risc_test_top.circuit.mem.memory[%0d]", index));
      end  
  endfunction
  
  
  function int get_next_instruction_signal();
    logic get_next_instruction = 0;
    string hdl = "risc_test_top.circuit.risc_chip.rih.get_next_instruction";
    
    uvm_hdl_read(hdl, get_next_instruction);
    `uvm_info("risc_test_driver",  $sformatf("get_next_instruction = %b", get_next_instruction), UVM_MEDIUM);
  endfunction


 

endclass
`endif     
