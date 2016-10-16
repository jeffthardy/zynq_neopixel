// Copyright 2016 Jeff Hardy
//--------------------------------------------------------------------------------
// Developer: Jeff Hardy
// Date     : 10/8/2016
// Purpose  : Test Generator to drive neopixel module
//--------------------------------------------------------------------------------
`timescale 1ns / 1ps



module axi_generator #(
  parameter C_RATE = 125000000,
  parameter C_PIXELS = 12
)(
  // AXI Interface
  input                   axi_clock,
  input                   axi_reset,
  output reg       [31:0] axi_data = 32'd0,
  output reg              axi_write_en = 1'b0
);


localparam MESSAGE_COUNT = 36;
localparam [31:0] MESSAGES [0:MESSAGE_COUNT-1] = {
                                      32'h00FF0000,
                                      32'h0100FF00,
                                      32'h020000FF,
                                      32'h030000FF,
                                      32'h0400FF00,
                                      32'h05FF0000,
                                      32'h0600ff00,
                                      32'h070000ff,
                                      32'h0800ff00,
                                      32'h09ff0000,
                                      32'h0A00ff00,
                                      32'h0B0000ff,

                                      32'h000ff000,
                                      32'h01000ff0,
                                      32'h02f0000f,
                                      32'h030ff000,
                                      32'h04000ff0,
                                      32'h05f0000f,
                                      32'h060ff000,
                                      32'h07000ff0,
                                      32'h08f0000f,
                                      32'h090ff000,
                                      32'h0Affff00,
                                      32'h0B00ffff,

                                      32'h00555555,
                                      32'h01444444,
                                      32'h02500050,
                                      32'h03123456,
                                      32'h04654321,
                                      32'h05987654,
                                      32'h06999911,
                                      32'h07114466,
                                      32'h08345345,
                                      32'h09800080,
                                      32'h0A00ffff,
                                      32'h0Bff00ff
};

reg [31:0] cycle_counter = 32'd0;
reg [31:0] message_index = 32'd0;

always @(posedge axi_clock)begin
  if(axi_reset == 1'b1)begin
    axi_write_en <= 1'b0;
    cycle_counter <= 32'd0;
  end
  else begin
    axi_write_en <= 1'b0;
    cycle_counter <= cycle_counter + 1'b1;

    // send the next message every C_RATE cycles
    if(cycle_counter == C_RATE)begin
      axi_data <= MESSAGES[message_index];
      axi_write_en <= 1'b1;
      cycle_counter <= 32'd0;
      message_index <= message_index + 1'b1;
      if(message_index == MESSAGE_COUNT-1)begin
        message_index <= 32'd0;
      end
    end

  end
end

endmodule
