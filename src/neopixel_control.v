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
  // AXI Interface
  input                   axi_clock,
  input                   axi_reset,
  input            [31:0] axi_data,
  input                   axi_write_en,


  // neopixel control interface
  output                  ctrl_clock,
  output                  ctrl_reset,
  output reg              ctrl_write_en = 1'b0,
  output reg       [31:0] ctrl_address = 32'd0,
  output reg       [31:0] ctrl_write_data = 32'd0,
  input            [31:0] ctrl_read_data,
  input                   ctrl_ready
);

wire [63:0]     fifo_read_data;
reg             fifo_read_en = 1'b0;
wire [13:0]     fifo_rd_count;
wire [13:0]     fifo_wr_count;
wire            fifo_almost_full;
wire            fifo_almost_empty;
wire            fifo_full;
wire            fifo_empty;



FIFO36E1 #(
.ALMOST_EMPTY_OFFSET        (13'h0080),               // Sets the almost empty threshold
.ALMOST_FULL_OFFSET         (13'h0080),               // Sets almost full threshold
.DATA_WIDTH                 (36),                     // Sets data width to 4-72
.DO_REG                     (1),                      // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
.EN_ECC_READ                ("FALSE"),                // Enable ECC decoder, FALSE, TRUE
.EN_ECC_WRITE               ("FALSE"),                // Enable ECC encoder, FALSE, TRUE
.EN_SYN                     ("FALSE"),                // Specifies FIFO as Asynchronous (FALSE) or Synchronous (TRUE)
.FIFO_MODE                  ("FIFO36"),               // Sets mode to "FIFO36" or "FIFO36_72"
.FIRST_WORD_FALL_THROUGH    ("FALSE"),                // Sets the FIFO FWFT to FALSE, TRUE
.INIT                       (72'h000000000000000000), // Initial values on output port
.SIM_DEVICE                 ("7SERIES"),              // Must be set to "7SERIES" for simulation behavior
.SRVAL                      (72'h000000000000000000)  // Set/Reset value for output port
)
FIFO36E1_inst (
// ECC Signals: 1-bit (each) output: Error Correction Circuitry ports
.DBITERR          ( ),              // 1-bit output: Double bit error status
.ECCPARITY        ( ),              // 8-bit output: Generated error correction parity
.SBITERR          ( ),              // 1-bit output: Single bit error status

// Read Data: 64-bit (each) output: Read output data
.DO               (fifo_read_data), // 64-bit output: Data output
.DOP              ( ),              // 8-bit output: Parity data output

// Status: 1-bit (each) output: Flags and other FIFO status outputs
.ALMOSTEMPTY      (fifo_almost_empty),  // 1-bit output: Almost empty flag
.ALMOSTFULL       (fifo_almost_full),   // 1-bit output: Almost full flag
.EMPTY            (fifo_empty),         // 1-bit output: Empty flag
.FULL             (fifo_full),          // 1-bit output: Full flag
.RDCOUNT          (fifo_rd_count),      // 13-bit output: Read count
.RDERR            ( ),                  // 1-bit output: Read error
.WRCOUNT          (fifo_wr_count),      // 13-bit output: Write count
.WRERR            ( ),                  // 1-bit output: Write error

// ECC Signals: 1-bit (each) input: Error Correction Circuitry ports
.INJECTDBITERR    (1'b0),           // 1-bit input: Inject a double bit error input
.INJECTSBITERR    (1'b0),

// Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
.RDCLK            (axi_clock),    // 1-bit input: Read clock
.RDEN             (fifo_read_en), // 1-bit input: Read enable
.REGCE            (1'b1),         // 1-bit input: Clock enable
.RST              (axi_reset),    // 1-bit input: Reset
.RSTREG           (axi_reset),    // 1-bit input: Output register set/reset

// Write Control Signals: 1-bit (each) input: Write clock and enable input signals
.WRCLK            (axi_clock),    // 1-bit input: Rising edge write clock.
.WREN             (axi_write_en), // 1-bit input: Write enable

// Write Data: 64-bit (each) input: Write input data
.DI               ({32'd0,axi_data}),     // 64-bit input: Data input
.DIP              (8'd0)          // 8-bit input: Parity input
);



assign ctrl_clock = axi_clock;
assign ctrl_reset = axi_reset;


reg        fifo_read_en_r1 = 1'b0;

always @ (posedge ctrl_clock)begin

  fifo_read_en_r1 <= fifo_read_en;

  if(ctrl_reset == 1'b1)begin
    fifo_read_en <= 1'b0;
    ctrl_write_en <= 1'b0;
  end
  else begin
    fifo_read_en <= 1'b0;
    ctrl_write_en <= 1'b0;

    // Read FIFO data if neopixel buffer is ready
    if((fifo_almost_empty == 1'b0) || ((fifo_empty == 1'b0) && (fifo_read_en == 1'b0)))begin
      fifo_read_en <= 1'b1;
    end

    if(fifo_read_en_r1 == 1'b1)begin
      ctrl_address     <= fifo_read_data[31:24];
      ctrl_write_data  <= fifo_read_data[23:0];
      ctrl_write_en    <= 1'b1;
    end


  end

end




endmodule
