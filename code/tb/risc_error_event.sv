`ifndef __risc_error_event__
  	`define __risc_error_event__

typedef enum logic [2:0] {
  
  UNEXPECTED_MEMORY_WRITE_EVENT = 3'b000,
  UNEXPECTED_MEMORY_WRITE_VALUE = 3'b001,

  UNEXPECTED_REGFILE_WRITE_EVENT = 3'b010,
  UNEXPECTED_REGFILE_WRITE_VALUE = 3'b011,
  
  UNEXPECTED_PC_VALUE = 3'b100
} 
RISC_ERROR_EVENT_ENUM;


class risc_error_event extends uvm_object;
  RISC_ERROR_EVENT_ENUM risc_event;
  
  function new (RISC_ERROR_EVENT_ENUM risc_event);
    this.risc_event = risc_event;
  endfunction
endclass

`endif