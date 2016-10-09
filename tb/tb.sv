
 `timescale 1ns/1ns


module tb ();


reg my_clock = 1'b0;

always begin
  #4 my_clock <= ~my_clock;
end


wire neopixel_link1;
wire board_leds;

top
(
  .clock_125m     (my_clock),
  .neopixel_drive (neopixel_link1),
  .leds           (board_leds)
);



endmodule