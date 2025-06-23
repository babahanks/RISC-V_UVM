// Memory behavioral model


`ifndef __MEMORY__
    `define __MEMORY__

module memory_bm(
  /*
  input  logic       clk,
  input  logic       reset,
  input  logic[31:0] rd_addr,
  input  logic[31:0] wr_addr,
  input  logic[31:0] wr_data,
  input  logic       rd_wr,  // 0 => rd
  input  logic	     req_valid,  
  output logic[31:0] rd_data,
  output logic		 ack */);
  
  localparam int MEM_SIZE = 64000; // Compile-time constant
  logic [31:0] memory [0:MEM_SIZE - 1]; // Array with 64000 elements  
  
  logic last_req_valid;  // keeping track of the req_valid signal in the previous clk
  
  //assign req_valid_posedge = ~last_req_valid  && req_valid;
  
  task load_data();
    fork
      forever begin
        
        $display("load data");
        
      end          
    join    
  endtask
  
  
  
endmodule

`endif
  
