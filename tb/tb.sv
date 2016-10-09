
 `timescale 1ns/1ns


module tb ();


reg my_clock = 1'b0;

always begin
  #4 my_clock <= ~my_clock;
end


wire         pixel_clock;
wire         pixel_reset;
wire         pixel_wren;
wire [31:0]  pixel_address;
wire [31:0]  pixel_write_data;
wire [31:0]  pixel_read_data;


wire         pixel_output;

neopixel_driver #(
  .C_RATE         (32'd80)
)neopixel_driver_i(
  .clock          (my_clock),
  .reset          (1'b0),
  .clock_ctrl     (pixel_clock),
  .reset_ctrl     (pixel_reset),
  .write_readf    (pixel_wren),
  .address        (pixel_address),
  .write_data     (pixel_write_data),
  .read_data      (pixel_read_data)
);



neopixel neopixel_i(
  .clock          (my_clock),
  .reset          (1'b0),
  .neopixel_drive (pixel_output),
  .clock_ctrl     (pixel_clock),
  .reset_ctrl     (pixel_reset),
  .write_readf    (pixel_wren),
  .address        (pixel_address),
  .write_data     (pixel_write_data),
  .read_data      (pixel_read_data)
);




endmodule