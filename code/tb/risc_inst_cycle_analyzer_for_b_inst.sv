`ifndef   __risc_inst_cycle_analyzer_for_b_inst__
 `define  __risc_inst_cycle_analyzer_for_b_inst__
`include "risc_inst_cycle_analyzer.sv"
`include "risc_v_circuit_state.sv"
`include "risc_txns_in_instruction_cycle.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;

class risc_inst_cycle_analyzer_for_b_inst extends risc_inst_cycle_analyzer;
    `uvm_object_utils(risc_inst_cycle_analyzer_for_b_inst)
  
  string register_hdl_path = "risc_test_top.circuit.risc_chip.regfile_.registers[%0d]";
  string memory_hdl_path   = "risc_test_top.circuit.mem.memory[%0d]";
  string PC_hdl_path       = "risc_test_top.circuit.risc_chip.rih.PC";

  function new(string name = "risc_inst_cycle_analyzer_for_b_inst");
    super.new(name);
  endfunction

  function int analyze(
    risc_txns_in_instruction_cycle instruction_cycle,
    logic[31:0]  PC_post_last_instruction,
    ref array_32_bit dut_reg_file_copy_post_last_instruction);


    logic[31:0]  instruction;
    logic[31:0]  reg_addr_a;
    logic[31:0]  reg_addr_b;
    logic[31:0]  reg_addr_a_data;
    logic[31:0]  reg_addr_b_data;
    logic signed [12:1]  expected_jump_offset;
    logic[31:0]  expected_PC;
    
    int jump = 0;
    int result;
    
	instruction = instruction_cycle.instruction;
    `uvm_info("risc_inst_cycle_analyzer_for_b_inst", $sformatf("**** instruction: %b", instruction), UVM_MEDIUM);            

    
    if (instruction_cycle.instruction[6:0] != 7'b1100011) begin
      `uvm_fatal("risc_inst_cycle_analyzer_for_b_inst", "Wrong instruction[6:0]")
      // something wrong with the code.. end it now and fix it
      return 0;
    end
       
    if (instruction_cycle.memory_write_queue.size() > 0) begin
      `uvm_error("risc_inst_cycle_analyzer_for_b_inst", "Write to memory found in B instruction execution")
      return 0;
    end 
    
    if (instruction_cycle.reg_file_write_queue.size() > 0) begin
      `uvm_error("risc_inst_cycle_analyzer_for_b_inst", "Write to reg_file found in B instruction execution")
      return 0;
    end 
   
    result = check_PC(instruction_cycle,  
                      dut_reg_file_copy_post_last_instruction, 
                      PC_post_last_instruction);
    
    if (result != 1) return result;

    result = compare_reg_file_copies(
      instruction_cycle.post_instruction_dut_reg_file_copy,
      dut_reg_file_copy_post_last_instruction);
    
    return result;

  endfunction

  
  function int check_PC(
    risc_txns_in_instruction_cycle instruction_cycle,
    array_32_bit dut_reg_file_old_upated,
    logic[31:0] last_PC);

    logic[31:0] instruction;
    logic[5:0]  reg_addr_a;
    logic[5:0]  reg_addr_b;
    logic[31:0]  reg_addr_a_data;
    logic[31:0]  reg_addr_b_data;
    logic signed [12:1]  expected_jump_offset;
    logic[31:0]  expected_PC;

    
    logic [31:0] read_PC;
    int hdl_req_status;
    logic jump = 1'b0;
    

    instruction = instruction_cycle.instruction;
    reg_addr_a = instruction[19:15];
    reg_addr_b = instruction[24:20];


        
    reg_addr_a_data = dut_reg_file_old_upated[reg_addr_a];
    reg_addr_b_data = dut_reg_file_old_upated[reg_addr_b];
    
    expected_jump_offset = 11'b1;
    
    
    case (instruction[14:12])
      `RISC_B_FUNCT_3_EQUAL:            jump = (reg_addr_a_data == reg_addr_b_data);
      `RISC_B_FUNCT_3_NOT_EQUAL:        jump = (reg_addr_a_data != reg_addr_b_data);		
      `RISC_B_FUNCT_3_LESS_THAN:        jump = ($signed(reg_addr_a_data) <  $signed(reg_addr_b_data));		
      `RISC_B_FUNCT_3_GREATER_OR_EQ:    jump = (reg_addr_a_data >= reg_addr_b_data);	
      `RISC_B_FUNCT_3_U_LESS_THAN:	    jump = (reg_addr_a_data <  reg_addr_b_data);	
      `RISC_B_FUNCT_3_U_GREATER_OR_EQ:	jump = (reg_addr_a_data <= reg_addr_b_data);
    endcase
    
    if (jump) begin
      expected_jump_offset[4:1]  = instruction[11:8];
      expected_jump_offset[10:5] = instruction[30:25];
      expected_jump_offset[11]   = instruction[7];
      expected_jump_offset[12]   = instruction[31]; 
    end
    
    expected_PC = $signed(last_PC)  + expected_jump_offset;
    
    if (expected_PC != instruction_cycle.post_instruction_PC) begin
      
      `uvm_fatal("risc_inst_cycle_analyzer_for_b_inst",  
                 $sformatf("expected_jump_offset: %d, last_PC: %0d, expected_PC: %0d; current PC: %0d", 
                            expected_jump_offset,    
                           last_PC,       
                           expected_PC,     
                           instruction_cycle.post_instruction_PC));      
      return 0;
    end
    `uvm_info("risc_inst_cycle_analyzer_for_b_inst", 
              $sformatf("PC: %0d", instruction_cycle.post_instruction_PC), UVM_MEDIUM);   
    return 1;
  endfunction


endclass

`endif