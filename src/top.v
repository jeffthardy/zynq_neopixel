// Copyright 2016 Jeff Hardy
//--------------------------------------------------------------------------------
// Developer: Jeff Hardy
// Date     : 10/8/2016
// Purpose  : Top level wrapper for neopixel driver build
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module top
(
  input             clock_125m,
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

neopixel_driver #(
  .C_RATE   (32'd33000000)
  )neopixel_driver_i(
  .clock          (clock_125m),
  .reset          (1'b0),
  .clock_ctrl     (pixel_clock),
  .reset_ctrl     (pixel_reset),
  .write_readf    (pixel_wren),
  .address        (pixel_address),
  .write_data     (pixel_write_data),
  .read_data      (pixel_read_data)
);


neopixel #(
  .C_PIXELS         (12),
  .C_FREQ_HZ        (125000000)
)neopixel_i(
  .clock            (clock_125m),
  .reset            (1'b0),
  .neopixel_drive   (neopixel_drive),
  //control interface
  .clock_ctrl       (pixel_clock),
  .reset_ctrl       (pixel_reset),
  .write_readf      (pixel_wren),
  .address          (pixel_address),
  .write_data       (pixel_write_data),
  .read_data        (pixel_read_data)
);

endmodule
