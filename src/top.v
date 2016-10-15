// Copyright 2016 Jeff Hardy
//--------------------------------------------------------------------------------
// Developer: Jeff Hardy
// Date     : 10/8/2016
// Purpose  : Top level wrapper for neopixel driver build
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module top #(
  parameter C_SIM_MODE = 0,
  parameter C_CONTROL_RATE  = 32'd33000000,
  parameter C_PIXEL_COUNT   = 12
)
(
  input             clock_125m,
  input             reset_125m,
  input      [31:0] axi_data,
  input             axi_write_en,
  output            neopixel_drive,
  output      [3:0] leds
);

// Output a simple patter on the board
assign leds = 4'b0101;



// Connect the first Neopixel module to a driver
wire pixel_clock;
wire pixel_reset;
wire pixel_wren;
wire [31:0] pixel_address;
wire [31:0] pixel_write_data;
wire [31:0] pixel_read_data;
wire        pixel_write_ready;

neopixel_control #(
  .C_PIXELS         (C_PIXEL_COUNT),
  .C_RATE           (C_CONTROL_RATE)
  )neopixel_control_i(
  .axi_clock        (clock_125m),
  .axi_reset        (reset_125m),
  .axi_data         (axi_data),
  .axi_write_en     (axi_write_en),
  .ctrl_clock       (pixel_clock),
  .ctrl_reset       (pixel_reset),
  .ctrl_write_en    (pixel_wren),
  .ctrl_address     (pixel_address),
  .ctrl_write_data  (pixel_write_data),
  .ctrl_read_data   (pixel_read_data),
  .ctrl_ready       (pixel_write_ready)
);

neopixel #(
  .C_SIM_MODE       (C_SIM_MODE),
  .C_PIXELS         (C_PIXEL_COUNT),
  .C_FREQ_HZ        (125000000)
)neopixel_i(
  .neopixel_clock   (clock_125m),
  .neopixel_reset   (1'b0),
  .neopixel_drive   (neopixel_drive),
  //control interface
  .ctrl_clock       (pixel_clock),
  .ctrl_reset       (pixel_reset),
  .ctrl_write       (pixel_wren),
  .ctrl_address     (pixel_address),
  .ctrl_write_data  (pixel_write_data),
  .ctrl_read_data   (pixel_read_data),
  .ctrl_ready       (pixel_write_ready)
);

endmodule
