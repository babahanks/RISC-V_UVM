`ifndef   __uvm_hdl_util__
 `define  __uvm_hdl_util__

`include "type_defs.sv"
`include "risc_test_constants.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;

class uvm_hdl_util;
  
  
  static string register_hdl_path = "risc_test_top.circuit.risc_chip.regfile_.registers[%0d]";
  static string memory_hdl_path   = "risc_test_top.circuit.mem.memory[%0d]";
  static string PC_hdl_path       = "risc_test_top.circuit.risc_chip.rih.PC";

  
  static function array_32_bit get_reg_file_snapshot();
    logic [31:0] array[];
    int size;
    size = `REG_FILE_SIZE;
    
    array = new[size];
    
    for (int i=0; i<size; i++) begin
      array[i] = get_reg_value(i);
    end 
    
    return array;
  endfunction
  
    
  static function logic[31:0] get_reg_value(int address);
    
    logic[31:0] reg_value;
    string formated_hdl_path;
    int hdl_req_status;
    
    formated_hdl_path =  $sformatf(register_hdl_path, address);
    hdl_req_status = uvm_hdl_read(formated_hdl_path, reg_value);
    
    if (hdl_req_status == 0) begin
      `uvm_fatal("uvm_hdl_util", 
                $sformatf("could not read: regfile[%0d]: address", address));      
    end
    
    return reg_value; 
  endfunction
  
  
  static function int get_PC();
    logic [31:0] PC;
    int hdl_req_status;

    hdl_req_status = uvm_hdl_read(PC_hdl_path, PC);
    if (hdl_req_status == 0) begin
      `uvm_fatal("uvm_hdl_util",  "could not read PC");
    end
    
    return PC;
  endfunction
  
  
endclass

`endif