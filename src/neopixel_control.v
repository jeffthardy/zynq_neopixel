// Copyright 2016 Jeff Hardy
//--------------------------------------------------------------------------------
// Developer: Jeff Hardy
// Date     : 10/8/2016
// Purpose  : Test Generator to drive neopixel module
//--------------------------------------------------------------------------------
`timescale 1ns / 1ps



module neopixel_control #(
  parameter C_RATE = 125000000,
  parameter C_PIXELS = 12
)(
  input             clock,
  input             reset,

  //control interface
  output                 clock_ctrl,
  output                 reset_ctrl,
  output reg             write_readf = 1'b0,
  output reg      [31:0] address = 32'd0,
  output reg      [31:0] write_data = 32'd0,
  input           [31:0] read_data
);


assign clock_ctrl = clock;
assign reset_ctrl = reset;


reg [31:0] cycle_timer = 32'd0;
reg        timer_trig  = 1'b0;

always @ (posedge clock)begin
  if(reset == 1'b1)begin
    cycle_timer <= 32'd0;
    timer_trig <= 1'b0;
    write_readf <= 1'b0;
  end
  else begin
    write_readf <= 1'b0;
    timer_trig <= 1'b0;
    cycle_timer <= cycle_timer + 1'b1;

    if(cycle_timer == C_RATE)begin
      cycle_timer <= 32'd1;
      timer_trig <= 1'b1;
    end

    if(timer_trig == 1'b1)begin
      write_data <= write_data + 32'h040201;
      write_readf <= 1'b1;

    end

    if(write_readf == 1'b1)begin
      address <= address + 1'b1;
      if(address == C_PIXELS-1)begin
        address <= 32'd0;
      end
    end


  end

end




endmodule
