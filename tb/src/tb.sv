
 `timescale 1ns/1ns


module tb ();


reg my_clock = 1'b0;

always begin
  #4 my_clock <= ~my_clock;
end

// Quit after 1 ms
initial begin
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
  .clock_125m     (my_clock),
  .neopixel_drive (neopixel_link1),
  .leds           (board_leds)
);




endmodule