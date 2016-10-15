
 `timescale 1ns/1ns


module tb ();


reg clock_125m = 1'b0;
reg reset_125m = 1'b0;

localparam CLOCK_PER = 8.0;

always begin
  #(CLOCK_PER/2) clock_125m <= ~clock_125m;
end

// Quit after 1 ms
initial begin
  #(CLOCK_PER) reset_125m <= 1'b1;
  #(CLOCK_PER*10) reset_125m <= 1'b0;
  #5000000  $finish;
end

wire neopixel_link1;
wire board_leds;

top #(
  .C_SIM_MODE         (1),
  .C_CONTROL_RATE     (8000),
  .C_PIXEL_COUNT      (4)
) top_i
(
  .clock_125m     (clock_125m),
  .reset_125m     (reset_125m),
  .axi_data       (32'd0),
  .axi_write_en   (1'b0),
  .neopixel_drive (neopixel_link1),
  .leds           (board_leds)
);




endmodule