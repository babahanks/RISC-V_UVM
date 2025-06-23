`ifndef __risc_instruction_simulator_r__
 `define __risc_instruction_simulator_r__
`include "risc_instruction_simulator.sv"
`include "ALU.sv"
`include "risc_instruction_constants.sv"
`include "risc_v_circuit_state.sv"
`include "uvm_macros.svh"
`include "uvm_pkg.sv"
import uvm_pkg::*;


class risc_instruction_simulator_r extends risc_instruction_simulator;
  

  function new(logic[31:0] instruction);
    super.new(instruction);
  endfunction
  
  function void simulate(
    ref risc_v_circuit_state state);
    
    logic[31:0] reg_addr_a;
    logic[31:0] reg_addr_b;
    logic[31:0] reg_a_value;
    logic[31:0] reg_b_value;
    logic[31:0] expected_value;
    logic[31:0] reg_dest_addr;
    ALU_OP_CODE alu_op_code;
    
    
    reg_addr_a = instruction[19:15];
    reg_addr_b = instruction[24:20];
    reg_dest_addr = instruction[11:7];
    
    reg_a_value = state.regfile[reg_addr_a];
    reg_b_value = state.regfile[reg_addr_b];
    
    alu_op_code = get_op_code(instruction);     
    expected_value = get_expected_value(reg_a_value, reg_b_value, alu_op_code); 
    
    
    state.regfile[reg_dest_addr] = expected_value;
    state.PC = state.PC + 1;
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
    `uvm_info("risc_r_inst_seq_item", ">>>>>>Setting op_code", UVM_MEDIUM);            

    if (instruction[14:12] == `RISC_R_FUNC_3_ADD && 
        instruction[31:25] == `RISC_R_FUNC_7_ADD)
      begin
        $display("instruction: ADD");
        alu_op_code = ADD; 
        `uvm_info("risc_r_inst_seq_item", "op_code: ADD", UVM_MEDIUM);            
      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_SUBTRACT && 
             instruction[31:25] == `RISC_R_FUNC_7_SUBTRACT)
      begin
        alu_op_code = SUBTRACT; 
        `uvm_info("risc_r_inst_seq_item", "op_code: SUBTRACT", UVM_MEDIUM);            

      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_XOR && 
             instruction[31:25] == `RISC_R_FUNC_7_XOR)
      begin
        alu_op_code = XOR;                
        `uvm_info("risc_r_inst_seq_item", "op_code: XOR", UVM_MEDIUM);            
      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_OR && 
             instruction[31:25] == `RISC_R_FUNC_7_OR)
      begin
        alu_op_code = OR;                
        `uvm_info("risc_r_inst_seq_item", "op_code: OR", UVM_MEDIUM);            
      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_AND && 
             instruction[31:25] == `RISC_R_FUNC_7_AND)
      begin
        alu_op_code = AND;                
        `uvm_info("risc_r_inst_seq_item", "op_code: AND", UVM_MEDIUM);            
      end
    else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_LT_LOG && 
             instruction[31:25] == `RISC_R_FUNC_7_SHIFT_LT_LOG)
      begin
        alu_op_code = SHIFT_LT_LOG;                
        `uvm_info("risc_r_inst_seq_item", "op_code: SHIFT_LT_LOG", UVM_MEDIUM);            
      end  
    else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_RT_LOG && 
             instruction[31:25] == `RISC_R_FUNC_7_SHIFT_RT_LOG)
      begin
        alu_op_code = SHIFT_RT_LOG;                
        `uvm_info("risc_r_inst_seq_item", "op_code: SHIFT_RT_LOG", UVM_MEDIUM);            
      end            
    else if (instruction[14:12] == `RISC_R_FUNC_3_SHIFT_RT_AR && 
             instruction[31:25] == `RISC_R_FUNC_7_SHIFT_RT_AR)
      begin
        alu_op_code = SHIFT_RT_AR;                
        `uvm_info("risc_r_inst_seq_item", "op_code: SHIFT_RT_AR", UVM_MEDIUM);            
      end 
    else begin
      `uvm_fatal("risc_r_inst_seq_item", "Could not get op_code");
    end
    return alu_op_code;
  endfunction
  
  
  
endclass

`endif