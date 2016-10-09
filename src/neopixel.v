`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 09/12/2016 06:28:37 PM
// Design Name:
// Module Name: neopixel
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module neopixel #(
  parameter C_PIXELS = 12,
  parameter C_FREQ_HZ = 125000000
)(
  input             clock,
  input             reset,
  output reg        neopixel_drive = 1'b0,

  //control interface
  input             clock_ctrl,
  input             reset_ctrl,
  input             write_readf,
  input      [31:0] address,
  input      [31:0] write_data,
  output reg [31:0] read_data
);

//localparam C_IDLE_CYCLES  = 30000000;  // .6 sec
//localparam C_START_CYCLES = 6000;      // 120 us
//localparam C_PIXEL_T0H_CYCLES = 20;    // .40 us
//localparam C_PIXEL_T0L_CYCLES = 43;    // .86 us
//localparam C_PIXEL_T1H_CYCLES = 40;    // .80 us
//localparam C_PIXEL_T1L_CYCLES = 22;    // .44 us

localparam C_HZ_MULT = C_FREQ_HZ/125000000.0;
localparam integer C_IDLE_CYCLES  = (C_HZ_MULT)*30000000;  // .25 sec
localparam integer C_START_CYCLES = (C_HZ_MULT)*15000;      // 120 us
localparam integer C_PIXEL_T0H_CYCLES = (C_HZ_MULT)*50;    // .40 us
localparam integer C_PIXEL_T0L_CYCLES = (C_HZ_MULT)*108;    // .86 us
localparam integer C_PIXEL_T1H_CYCLES = (C_HZ_MULT)*100;    // .80 us
localparam integer C_PIXEL_T1L_CYCLES = (C_HZ_MULT)*55;    // .44 us


localparam [7:0] C_INIT_BLUE_VAL  [0:C_PIXELS-1]= {8'd0   ,8'd0   ,8'd0   ,8'd0   ,8'd0   ,8'd0   ,8'd0   ,8'd0   ,8'd0   ,8'd0   ,8'd0   ,8'd0   };
localparam [7:0] C_INIT_RED_VAL   [0:C_PIXELS-1]= {8'd128 ,8'd128 ,8'd128 ,8'd128 ,8'd128 ,8'd128 ,8'd128 ,8'd128 ,8'd128 ,8'd128 ,8'd128 ,8'd128 };
localparam [7:0] C_INIT_GREEN_VAL [0:C_PIXELS-1]= {8'd255 ,8'd255 ,8'd255 ,8'd255 ,8'd255 ,8'd255 ,8'd255 ,8'd255 ,8'd255 ,8'd255 ,8'd255 ,8'd255 };


// Handle writing to Pixel Memory

reg         init_mem = 1;
reg [7:0]   green_value      [0:C_PIXELS-1];
reg [7:0]   red_value        [0:C_PIXELS-1];
reg [7:0]   blue_value       [0:C_PIXELS-1];
integer i;

always @(posedge clock_ctrl)begin
  if(init_mem == 1'b1)begin
    for(i=0;i<C_PIXELS;i=i+1)begin
      green_value[i]       <= C_INIT_GREEN_VAL[i];
      red_value[i]         <= C_INIT_RED_VAL[i];
      blue_value[i]        <= C_INIT_BLUE_VAL[i];
    end
    init_mem <= 1'b0;
    read_data <= 32'd0;
  end
  else begin
    read_data <= {8'd0,red_value[address[2:0]],green_value[address[2:0]],blue_value[address[2:0]]};

    if(write_readf == 1'b1)begin
      red_value[address] <= write_data[23:16];
      green_value[address] <= write_data[15:8];
      blue_value[address] <= write_data[7:0];
    end

  end
end













localparam ST_IDLE        = 0;
localparam ST_START       = 1;
localparam ST_GREEN       = 2;
localparam ST_RED         = 3;
localparam ST_BLUE        = 4;

reg         first_boot = 1;
reg [3:0]   pixel_state   = ST_IDLE;
reg [31:0]  cycle_counter = 32'd0;
reg [3:0]   pixel_bit     = 4'd0;
reg         pixel_high_lowf = 1'b1;
reg [7:0]   pixel_index     = 8'd0;

always @(posedge clock)begin
  if(first_boot == 1'b1)begin
    neopixel_drive    <= 1'b1;
    pixel_state       <= ST_IDLE;
    cycle_counter     <= 32'd0;
    first_boot <= 1'b0;
  end
  else begin
    neopixel_drive <= 1'b1;

    case(pixel_state)
      ST_IDLE:begin
        cycle_counter <= cycle_counter+ 1'b1;
        if(cycle_counter == C_IDLE_CYCLES)begin
          pixel_state <= ST_START;
          cycle_counter <= 32'd0;
        end

      end
      ST_START:begin
        neopixel_drive <= 1'b0;
        cycle_counter <= cycle_counter+ 1'b1;
        if(cycle_counter == C_START_CYCLES)begin
          pixel_state <= ST_GREEN;
          cycle_counter <= 32'd0;
          pixel_bit <= 4'd7;
          pixel_high_lowf <= 1'b1;
        end

      end
      ST_GREEN:begin
        cycle_counter <= cycle_counter+ 1'b1;

        // first part of bit (HIGH)
        if(pixel_high_lowf == 1'b1)begin
          neopixel_drive <= 1'b1;

          // BIT is 1
          if(green_value[pixel_index][pixel_bit] == 1'b1)begin
            if(cycle_counter == C_PIXEL_T1H_CYCLES)begin
              cycle_counter <= 32'd0;
              pixel_high_lowf <= 1'b0;
            end
          end

          // BIT is 0
          else begin
            if(cycle_counter == C_PIXEL_T0H_CYCLES)begin
              cycle_counter <= 32'd0;
              pixel_high_lowf <= 1'b0;
            end
          end
        end

        // Second part of bit (LOW)
        else begin
          neopixel_drive <= 1'b0;

          // BIT is 1
          if(green_value[pixel_index][pixel_bit] == 1'b1)begin
            if(cycle_counter == C_PIXEL_T1L_CYCLES)begin
              cycle_counter <= 32'd0;
              pixel_high_lowf <= 1'b1;
              pixel_bit <= pixel_bit - 1'b1;
              if(pixel_bit == 4'd0)begin
                pixel_state <= ST_RED;
                //green_value[pixel_index] <= green_value[pixel_index] + 1'b1;
                pixel_bit <= 8'd7;
              end
            end
          end

          // BIT is 0
          else begin
            if(cycle_counter == C_PIXEL_T0L_CYCLES)begin
              cycle_counter <= 32'd0;
              pixel_high_lowf <= 1'b1;
              pixel_bit <= pixel_bit - 1'b1;
              if(pixel_bit == 4'd0)begin
                pixel_state <= ST_RED;
                //green_value[pixel_index] <= green_value[pixel_index] + 1'b1;
                pixel_bit <= 8'd7;
              end
            end
          end
        end

      end
      ST_RED:begin
        cycle_counter <= cycle_counter+ 1'b1;

        // first part of bit (HIGH)
        if(pixel_high_lowf == 1'b1)begin
          neopixel_drive <= 1'b1;

          // BIT is 1
          if(red_value[pixel_index][pixel_bit] == 1'b1)begin
            if(cycle_counter == C_PIXEL_T1H_CYCLES)begin
              cycle_counter <= 32'd0;
              pixel_high_lowf <= 1'b0;
            end
          end

          // BIT is 0
          else begin
            if(cycle_counter == C_PIXEL_T0H_CYCLES)begin
              cycle_counter <= 32'd0;
              pixel_high_lowf <= 1'b0;
            end
          end
        end

        // Second part of bit (LOW)
        else begin
          neopixel_drive <= 1'b0;

          // BIT is 1
          if(red_value[pixel_index][pixel_bit] == 1'b1)begin
            if(cycle_counter == C_PIXEL_T1L_CYCLES)begin
              cycle_counter <= 32'd0;
              pixel_high_lowf <= 1'b1;
              pixel_bit <= pixel_bit - 1'b1;
              if(pixel_bit == 4'd0)begin
                pixel_state <= ST_BLUE;
                //red_value[pixel_index] <= red_value[pixel_index] + 1'b1;
                pixel_bit <= 8'd7;
              end
            end
          end

          // BIT is 0
          else begin
            if(cycle_counter == C_PIXEL_T0L_CYCLES)begin
              cycle_counter <= 32'd0;
              pixel_high_lowf <= 1'b1;
              pixel_bit <= pixel_bit - 1'b1;
              if(pixel_bit == 4'd0)begin
                pixel_state <= ST_BLUE;
                //red_value[pixel_index] <= red_value[pixel_index] + 1'b1;
                pixel_bit <= 8'd7;
              end
            end
          end
        end

      end
      ST_BLUE:begin
        cycle_counter <= cycle_counter+ 1'b1;

        // first part of bit (HIGH)
        if(pixel_high_lowf == 1'b1)begin
          neopixel_drive <= 1'b1;

          // BIT is 1
          if(blue_value[pixel_index][pixel_bit] == 1'b1)begin
            if(cycle_counter == C_PIXEL_T1H_CYCLES)begin
              cycle_counter <= 32'd0;
              pixel_high_lowf <= 1'b0;
            end
          end

          // BIT is 0
          else begin
            if(cycle_counter == C_PIXEL_T0H_CYCLES)begin
              cycle_counter <= 32'd0;
              pixel_high_lowf <= 1'b0;
            end
          end
        end

        // Second part of bit (LOW)
        else begin
          neopixel_drive <= 1'b0;

          // BIT is 1
          if(blue_value[pixel_index][pixel_bit] == 1'b1)begin
            if(cycle_counter == C_PIXEL_T1L_CYCLES)begin
              cycle_counter <= 32'd0;
              pixel_high_lowf <= 1'b1;
              pixel_bit <= pixel_bit - 1'b1;
              if(pixel_bit == 4'd0)begin
                if(pixel_index == C_PIXELS-1)begin
                  pixel_state <= ST_IDLE;
                  pixel_index <= 8'd0;
                end
                else begin
                  pixel_state <= ST_GREEN;
                  pixel_index <= pixel_index + 1'b1;
                end
                //blue_value[pixel_index] <= blue_value[pixel_index] + 1'b1;
                pixel_bit <= 8'd7;
              end
            end
          end

          // BIT is 0
          else begin
            if(cycle_counter == C_PIXEL_T0L_CYCLES)begin
              cycle_counter <= 32'd0;
              pixel_high_lowf <= 1'b1;
              pixel_bit <= pixel_bit - 1'b1;
              if(pixel_bit == 4'd0)begin
                if(pixel_index == C_PIXELS-1)begin
                  pixel_state <= ST_IDLE;
                  pixel_index <= 8'd0;
                end
                else begin
                  pixel_state <= ST_GREEN;
                  pixel_index <= pixel_index + 1'b1;
                end
                //blue_value[pixel_index] <= blue_value[pixel_index] + 1'b1;
                pixel_bit <= 8'd7;
              end
            end
          end
        end

      end
    endcase

  end

end






endmodule
