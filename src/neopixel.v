// Copyright 2016 Jeff Hardy
//--------------------------------------------------------------------------------
// Developer: Jeff Hardy
// Date     : 10/8/2016
// Purpose  : Neopixel control module
//--------------------------------------------------------------------------------
`timescale 1ns / 1ps



module neopixel #(
  parameter C_SIM_MODE = 0,
  parameter C_PIXELS = 12,
  parameter C_FREQ_HZ = 125000000
)(
  input             neopixel_clock,
  input             neopixel_reset,
  output reg        neopixel_drive = 1'b0,

  //control interface
  input             ctrl_clock,
  input             ctrl_reset,
  input             ctrl_write,
  input      [31:0] ctrl_address,
  input      [31:0] ctrl_write_data,
  output reg [31:0] ctrl_read_data = 32'd0,
  output reg        ctrl_ready = 1'b0
);

localparam [7:0] C_INIT_BLUE_VAL  [0:C_PIXELS-1]= '{C_PIXELS{8'd0  }};
localparam [7:0] C_INIT_RED_VAL   [0:C_PIXELS-1]= '{C_PIXELS{8'd128}};
localparam [7:0] C_INIT_GREEN_VAL [0:C_PIXELS-1]= '{C_PIXELS{8'd255}};

reg [7:0]   mem_green      [0:C_PIXELS-1] = C_INIT_BLUE_VAL;
reg [7:0]   mem_red        [0:C_PIXELS-1] = C_INIT_RED_VAL;
reg [7:0]   mem_blue       [0:C_PIXELS-1] = C_INIT_GREEN_VAL;

reg [7:0]   display_green  [0:C_PIXELS-1] = C_INIT_BLUE_VAL;
reg [7:0]   display_red    [0:C_PIXELS-1] = C_INIT_RED_VAL;
reg [7:0]   display_blue   [0:C_PIXELS-1] = C_INIT_GREEN_VAL;



// ****************************************************
// Handle external interface to Pixel Memory
// ****************************************************

reg [7:0]   wdata_red       = 8'd0;
reg [7:0]   wdata_green     = 8'd0;
reg [7:0]   wdata_blue      = 8'd0;
reg [31:0]  wdata_address   = 32'd0;

// Handshaking for write to pixel mem
reg         requesting_write = 1'b0;
reg         write_complete_m1 = 1'b0;
reg         write_complete_m2 = 1'b0;

always @(posedge ctrl_clock)begin
  // No reset on Metastability regs
  write_complete_m1 <= write_complete;
  write_complete_m2 <= write_complete_m1;

  if(ctrl_reset == 1'b1)begin
    ctrl_ready <= 1'b1;
    ctrl_read_data <= 32'd0;
  end
  else begin
    ctrl_ready <= 1'b1;

    // Probably should be CDCing this
    ctrl_read_data <= {8'd0,mem_red[ctrl_address],mem_green[ctrl_address],mem_blue[ctrl_address]};


    if(ctrl_write == 1'b1)begin
      wdata_red     <= ctrl_write_data[23:16];
      wdata_green   <= ctrl_write_data[15:8];
      wdata_blue    <= ctrl_write_data[7:0];
      wdata_address <= ctrl_address;
      requesting_write <= 1'b1;
    end

    // notify controller while write is pending
    if((requesting_write == 1'b1) || (write_complete_m2 == 1'b1))begin
      ctrl_ready <= 1'b0;
    end

    // ready_for_write dropped low indicates the write has passed boundaries
    if((requesting_write == 1'b1) && (write_complete_m2 == 1'b1))begin
      requesting_write <= 1'b0;
    end

  end
end


// ****************************************************
// Write out pixels to the string on a continuous loop
// ****************************************************

localparam ST_IDLE        = 0;
localparam ST_UPDATE      = 1;
localparam ST_START       = 2;
localparam ST_GREEN       = 3;
localparam ST_RED         = 4;
localparam ST_BLUE        = 5;


localparam C_HZ_MULT = C_FREQ_HZ/125000000.0;
localparam integer C_IDLE_CYCLES  = (C_HZ_MULT)*30000000;  // .25 sec
localparam integer C_START_CYCLES = (C_HZ_MULT)*15000;      // 120 us
localparam integer C_PIXEL_T0H_CYCLES = (C_HZ_MULT)*50;    // .40 us
localparam integer C_PIXEL_T0L_CYCLES = (C_HZ_MULT)*108;    // .86 us
localparam integer C_PIXEL_T1H_CYCLES = (C_HZ_MULT)*100;    // .80 us
localparam integer C_PIXEL_T1L_CYCLES = (C_HZ_MULT)*55;    // .44 us


reg [3:0]   pixel_state   = ST_IDLE;
reg [31:0]  cycle_counter = 32'd0;
reg [3:0]   pixel_bit     = 4'd0;
reg         pixel_high_lowf = 1'b1;
reg [7:0]   pixel_index     = 8'd0;

// This signal will handshake with the control logic to allow pixel updating
reg         ready_for_write = 1'b0;
reg         write_complete = 1'b0;
reg         requesting_write_m1 = 1'b0;
reg         requesting_write_m2 = 1'b0;

// loop variable
integer     i;

// Handle writes to memory
always @(posedge neopixel_clock)begin
  // CDC write request
  requesting_write_m1 <= requesting_write;
  requesting_write_m2 <= requesting_write_m1;

  if(neopixel_reset == 1'b1)begin
    write_complete <= 1'b1;

    // Initial pixel values
    for(i=0;i<C_PIXELS;i=i+1)begin
      mem_green[i]       <= C_INIT_GREEN_VAL[i];
      mem_red[i]         <= C_INIT_RED_VAL[i];
      mem_blue[i]        <= C_INIT_BLUE_VAL[i];
    end
  end
  else begin

    // turn off notifier once request is dropped
    write_complete <= 1'b0;

    // write requested and capable
    if((requesting_write_m2 == 1'b1) && (ready_for_write == 1'b1))begin
      mem_red[wdata_address] <= wdata_red;
      mem_green[wdata_address] <= wdata_green;
      mem_blue[wdata_address] <= wdata_blue;
      write_complete <= 1'b1;
    end

  end
end


always @(posedge neopixel_clock)begin
  if(neopixel_reset == 1'b1)begin

    neopixel_drive    <= 1'b1;
    pixel_state       <= ST_IDLE;
    cycle_counter     <= 32'd0;
    ready_for_write   <= 1'b0;
  end
  else begin
    neopixel_drive <= 1'b1;

    case(pixel_state)
      ST_IDLE:begin
        ready_for_write <= 1'b1;
        cycle_counter <= cycle_counter+ 1'b1;
        if(cycle_counter == C_IDLE_CYCLES)begin
          pixel_state <= ST_UPDATE;
          cycle_counter <= 32'd0;
        end
        // Skip idle time when in sim mode
        if(C_SIM_MODE == 1'b1)begin
          pixel_state <= ST_UPDATE;
          cycle_counter <= 32'd0;
        end

      end
      ST_UPDATE:begin
        // Wait for a current memory write to complete, otherwise start mem copy
        if(requesting_write_m2 == 1'b1)begin
          //wait for ongoing write to complete
        end
        // now the write is complete and we can block for memory copy
        else begin
          cycle_counter <= cycle_counter+ 1'b1;
          ready_for_write <= 1'b0;

          // No writes should be happening now, so no CDC concerns
          // Copy memory array to output array
          if(cycle_counter == 2)begin
            for(i=0;i<C_PIXELS;i=i+1)begin
              display_green[i]       <= mem_green[i];
              display_red[i]         <= mem_red[i];
              display_blue[i]        <= mem_blue[i];
            end
          end

          if(cycle_counter == 3)begin
            ready_for_write <= 1'b1;
            pixel_state <= ST_START;
          end
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
          if(display_green[pixel_index][pixel_bit] == 1'b1)begin
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
          if(display_green[pixel_index][pixel_bit] == 1'b1)begin
            if(cycle_counter == C_PIXEL_T1L_CYCLES)begin
              cycle_counter <= 32'd0;
              pixel_high_lowf <= 1'b1;
              pixel_bit <= pixel_bit - 1'b1;
              if(pixel_bit == 4'd0)begin
                pixel_state <= ST_RED;
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
          if(display_red[pixel_index][pixel_bit] == 1'b1)begin
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
          if(display_red[pixel_index][pixel_bit] == 1'b1)begin
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
          if(display_blue[pixel_index][pixel_bit] == 1'b1)begin
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
          if(display_blue[pixel_index][pixel_bit] == 1'b1)begin
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
