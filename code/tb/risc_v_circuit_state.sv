/* keeps the state of the circuit, i.e., the regfile, and the memory
   

*/

`ifndef __risc_v_circuit_state__
 `define __risc_v_circuit_state__

`include "risc_test_constants.sv"
`include "uvm_macros.svh" // Required for UVM macros
`include "uvm_pkg.sv"
import uvm_pkg::*;        // Imports all UVM


class risc_v_circuit_state extends uvm_object;
  
  logic [31:0] PC;
  logic [31:0] instruction;
    
  logic [31:0]  code[$];
  logic [5:0]  regfile[];  
  
  int memory_size;
  int regfile_size;
  
  function  new(string name="risc_v_circuit_state");
    super.new(name);
    regfile_size = `REG_FILE_SIZE;
    //memory_size = `MEMORY_SIZE;
    regfile = new[regfile_size];
    PC = 32'b0;   
  endfunction
  
  
  function void add_to_code(logic[31:0] instruction);
    code.push_back(instruction);       
  endfunction
  
  function void set_regfile_sate(
    logic[5:0]  address, 
    logic[31:0] value);

    regfile[address] = value;    
  endfunction
  
  
  function void set_PC(logic[31:0] PC);
    this.PC = PC;
  endfunction
  
  
  function void set_instruction(logic[31:0] instruction);
    this.instruction = instruction;
  endfunction
  
  

 /* 
  function int is_same_as(risc_v_circuit_state other_state);
    string message;
    int success = 1;  // Assume all match unless we find otherwise

    if (this.memory.size() != other_state.memory.size()) begin
      `uvm_error("risc_v_circuit_state", "Mismatched memory sizes");
      return 0;
    end

    if (this.regfile.size() != other_state.regfile.size()) begin
      `uvm_error("risc_v_circuit_state", "Mismatched regfile sizes");
      return 0;
    end

    for (int i = 0; i < memory_size; i++) begin
      if (this.memory[i] != other_state.memory[i]) begin
        message = $sformatf("memory[%0d] mismatch: this=%0d, other=%0d",
                            i, this.memory[i], other_state.memory[i]);
        `uvm_error("risc_v_circuit_state", message);
        success = 0;  // Mark as failure, but keep checking
      end
    end

    for (int i = 0; i < regfile_size; i++) begin
      if (this.regfile[i] != other_state.regfile[i]) begin
        message = $sformatf("regfile[%0d] mismatch: this=%0d, other=%0d",
                            i, this.regfile[i], other_state.regfile[i]);
        `uvm_error("risc_v_circuit_state", message);
        success = 0;
      end
    end

    return success;  // 1 = all matched, 0 = mismatch found
  endfunction
*/
  
endclass
`endif
    
    
   
  