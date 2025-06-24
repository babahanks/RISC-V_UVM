`ifndef __risc_instruction_simulator_b__
 `define __risc_instruction_simulator_b__
`include "risc_instruction_simulator.sv"
`include "../rtl/ALU.sv"
`include "risc_v_circuit_state.sv"
`include "uvm_macros.svh"
`include "uvm_pkg.sv"
import uvm_pkg::*;


class risc_instruction_simulator_b extends risc_instruction_simulator;
  

  function new(logic[31:0] instruction);
    super.new(instruction);
  endfunction
  
  function void simulate(ref risc_v_circuit_state state);
    
    logic[31:0]  reg_addr_a;
    logic[31:0]  reg_addr_b;
    logic[31:0]  reg_addr_a_data;
    logic[31:0]  reg_addr_b_data;
    logic signed [12:1]  expected_jump_offset;
    
    int jump = 0;    

    
    reg_addr_a = instruction[19:15];
    reg_addr_b = instruction[24:20];
    
    reg_addr_a_data = state.regfile[reg_addr_a];
    reg_addr_b_data = state.regfile[reg_addr_b];
    
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
    
    state.PC = $signed(state.PC)  + expected_jump_offset;

  endfunction
endclass

`endif
