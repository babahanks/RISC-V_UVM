 
`ifndef   __risc_inst_cycle_analyzer_for_r_inst__
  `define __risc_inst_cycle_analyzer_for_r_inst__

`include "risc_inst_cycle_analyzer.sv"
`include "risc_v_circuit_state.sv"
`include "risc_txns_in_instruction_cycle.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;
      
class risc_inst_cycle_analyzer_for_r_inst extends risc_inst_cycle_analyzer;
                    
  `uvm_object_utils(risc_inst_cycle_analyzer_for_r_inst)
  
  string register_hdl_path = "risc_test_top.circuit.risc_chip.regfile_.registers[%0d]";
  string memory_hdl_path   = "risc_test_top.circuit.mem.memory[%0d]";
  string PC_hdl_path       = "risc_test_top.circuit.risc_chip.rih.PC";

  
  function new(string name = "risc_inst_cycle_analyzer_for_r_inst");
    super.new(name);
  endfunction
  
  function int analyze(
    risc_txns_in_instruction_cycle instruction_cycle,
    logic[31:0]  PC_post_last_instruction,
    ref array_32_bit dut_reg_file_copy_post_last_instruction);
 
    
    int result;
    
    if (instruction_cycle.instruction[6:0] != 7'b0110011) begin
      `uvm_fatal("risc_inst_cycle_analyzer_for_r_inst", "Wrong instruction[6:0]")
      // something wrong with the code.. end it now and fix it
      return 0;
    end
       
    if (instruction_cycle.memory_write_queue.size() > 0) begin
      `uvm_error("risc_inst_cycle_analyzer_for_r_inst", "Write to memory found in R instruction execution")
      return 0;
    end 
    
    result = check_reg_file_write(instruction_cycle, dut_reg_file_copy_post_last_instruction);
    
    if (result != 1) return result;
    
    result = check_PC(instruction_cycle, PC_post_last_instruction);
    
    if (result != 1) return result;

    result = compare_reg_file_copies(
      instruction_cycle.post_instruction_dut_reg_file_copy,
      dut_reg_file_copy_post_last_instruction);
    
    return result;
    
  endfunction
  
  
  function int check_reg_file_write(
    risc_txns_in_instruction_cycle instruction_cycle,
    ref array_32_bit dut_reg_file_copy_post_last_instruction);
    
    int hdl_req_status;
    string formated_hdl_path;
    
    logic[31:0] instruction;
    
    logic[5:0] reg_addr_a;
    logic[5:0] reg_addr_b;
    logic[5:0] reg_dest_addr;

    
    logic[31:0] reg_a_value;
    logic[31:0] reg_b_value;
    logic[31:0] value_state;

    logic[31:0] reg_a_value_read;
    logic[31:0] reg_b_value_read;
    logic[31:0] expected_value;
    
    
    logic[31:0] read_value;
    ALU_OP_CODE alu_op_code;
    
    instruction = instruction_cycle.instruction;
    reg_addr_a = instruction[19:15];
    reg_addr_b = instruction[24:20];
    reg_dest_addr = instruction[11:7];
        
    
    reg_a_value = dut_reg_file_copy_post_last_instruction[reg_addr_a];
    reg_b_value = dut_reg_file_copy_post_last_instruction[reg_addr_b];
    
    alu_op_code = get_op_code(instruction); 
    
    expected_value = get_expected_value(reg_a_value, reg_b_value, alu_op_code); 
    
     
     if (instruction_cycle.post_instruction_dut_reg_file_copy[reg_dest_addr] != expected_value) begin
      `uvm_error("risc_inst_cycle_analyzer_for_r_inst", 
                 $sformatf("instruction_cycle.post_instruction_dut_reg_file_copy[%0d]: %0d;  expected value: %0d", 
                          reg_dest_addr, instruction_cycle.post_instruction_dut_reg_file_copy[reg_dest_addr], 
                           expected_value));      
      return 0;                
    end
    
    dut_reg_file_copy_post_last_instruction[reg_dest_addr] = expected_value;
    
    `uvm_info("risc_inst_cycle_analyzer_for_i_inst", 
              $sformatf("instruction_cycle.post_instruction_dut_reg_file_copy[%0d]: %0d", 
                        reg_dest_addr,  expected_value), UVM_MEDIUM);      


    
    return 1;
  endfunction
  

  
  
  function logic[31:0] get_expected_value(
    logic[31:0] input_a,
    logic[31:0] input_b,
  	ALU_OP_CODE alu_op_code);
    
    logic[31:0] expected_value;
    
    case (alu_op_code)
        ADD:          expected_value = input_a + input_b;               
        SUBTRACT:     expected_value = input_a - input_b;
        XOR:          expected_value = input_a ^ input_b;
        OR:           expected_value = input_a | input_b;
        AND:          expected_value = input_a & input_b;
        SHIFT_LT_LOG: expected_value = input_a << input_b;
        SHIFT_RT_LOG: expected_value = input_a >> input_b;
        SHIFT_RT_AR:  expected_value = input_a >>> input_b;
        //BARREL_SHIFTER: 
        IS_EQUAL:     expected_value = input_a == input_b;
        IS_GREATER:   expected_value = input_a > input_b; 
    endcase
    
    `uvm_info("risc_r_instruction_data", $sformatf("expected_value = %b", expected_value), UVM_MEDIUM);  
    return expected_value;
  endfunction

  
  function ALU_OP_CODE get_op_code(logic[31:0] instruction);
    ALU_OP_CODE alu_op_code;
    `uvm_info("risc_inst_cycle_analyzer_for_r_inst", ">>>>>>Setting op_code", UVM_MEDIUM);            

    if (instruction[14:12] == `RISC_R_FUNC_3_ADD && 
        instruction[31:25] == `RISC_R_FUNC_7_ADD)
      begin
        $display("instruction: ADD");
        alu_op_code = ADD; 
        `uvm_info("risc_inst_cycle_analyzer_for_r_inst", "op_code: ADD", UVM_MEDIUM);            
      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_SUBTRACT && 
             instruction[31:25] == `RISC_R_FUNC_7_SUBTRACT)
      begin
        alu_op_code = SUBTRACT; 
        `uvm_info("risc_inst_cycle_analyzer_for_r_inst", "op_code: SUBTRACT", UVM_MEDIUM);            

      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_XOR && 
             instruction[31:25] == `RISC_R_FUNC_7_XOR)
      begin
        alu_op_code = XOR;                
        `uvm_info("risc_inst_cycle_analyzer_for_r_inst", "op_code: XOR", UVM_MEDIUM);            
      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_OR && 
             instruction[31:25] == `RISC_R_FUNC_7_OR)
      begin
        alu_op_code = OR;                
        `uvm_info("risc_inst_cycle_analyzer_for_r_inst", "op_code: OR", UVM_MEDIUM);            
      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_AND && 
             instruction[31:25] == `RISC_R_FUNC_7_AND)
      begin
        alu_op_code = AND;                
        `uvm_info("risc_inst_cycle_analyzer_for_r_inst", "op_code: AND", UVM_MEDIUM);            
      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_LT_LOG && 
             instruction[31:25] == `RISC_R_FUNC_7_SHIFT_LT_LOG)
      begin
        alu_op_code = SHIFT_LT_LOG;                
        `uvm_info("risc_inst_cycle_analyzer_for_r_inst", "op_code: SHIFT_LT_LOG", UVM_MEDIUM);            
      end  
    else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_RT_LOG && 
             instruction[31:25] == `RISC_R_FUNC_7_SHIFT_RT_LOG)
      begin
        alu_op_code = SHIFT_RT_LOG;                
        `uvm_info("risc_inst_cycle_analyzer_for_r_inst", "op_code: SHIFT_RT_LOG", UVM_MEDIUM);            
      end            
    else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_RT_AR && 
             instruction[31:25] == `RISC_R_FUNC_7_SHIFT_RT_AR)
      begin
        alu_op_code = SHIFT_RT_AR;                
        `uvm_info("risc_inst_cycle_analyzer_for_r_inst", "op_code: SHIFT_RT_AR", UVM_MEDIUM);            
      end 
    else begin
      `uvm_fatal("risc_inst_cycle_analyzer_for_r_inst", "Could not get op_code");
  end
    return alu_op_code;
  endfunction
  
  
endclass

`endif