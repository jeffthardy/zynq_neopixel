// Copyright 2016 Jeff Hardy
//--------------------------------------------------------------------------------
// Developer: Jeff Hardy
// Date     : 10/8/2016
// Purpose  : Top level wrapper for neopixel driver build
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module top #(
  parameter C_SIM_MODE = 0,
  parameter C_CONTROL_RATE  = 32'd50000000,
  parameter C_PIXEL_COUNT   = 12
)
(
  // ARM Signals (Auto Connected to PS)
  inout     [14:0]  DDR_addr,
  inout      [2:0]  DDR_ba,
  inout             DDR_cas_n,
  inout             DDR_ck_n,
  inout             DDR_ck_p,
  inout             DDR_cke,
  inout             DDR_cs_n,
  inout      [3:0]  DDR_dm,
  inout     [31:0]  DDR_dq,
  inout      [3:0]  DDR_dqs_n,
  inout      [3:0]  DDR_dqs_p,
  inout             DDR_odt,
  inout             DDR_ras_n,
  inout             DDR_reset_n,
  inout             DDR_we_n,
  inout             FIXED_IO_ddr_vrn,
  inout             FIXED_IO_ddr_vrp,
  inout     [53:0]  FIXED_IO_mio,
  inout             FIXED_IO_ps_clk,
  inout             FIXED_IO_ps_porb,
  inout             FIXED_IO_ps_srstb,

  // User Core Signals
  input             clock_125m,
  input             reset_125m,
  output            neopixel_drive1,
  output      [3:0] leds
);

wire axi_clock;
wire axi_resetn;

generate
  if(C_SIM_MODE == 1'b0)begin


    //*******************************************
    //   ARM BOARD DESIGN
    //*******************************************
    arm_core_wrapper  arm_core_wrapper_i(
      .DDR_addr               (DDR_addr),
      .DDR_ba                 (DDR_ba),
      .DDR_cas_n              (DDR_cas_n),
      .DDR_ck_n               (DDR_ck_n),
      .DDR_ck_p               (DDR_ck_p),
      .DDR_cke                (DDR_cke),
      .DDR_cs_n               (DDR_cs_n),
      .DDR_dm                 (DDR_dm),
      .DDR_dq                 (DDR_dq),
      .DDR_dqs_n              (DDR_dqs_n),
      .DDR_dqs_p              (DDR_dqs_p),
      .DDR_odt                (DDR_odt),
      .DDR_ras_n              (DDR_ras_n),
      .DDR_reset_n            (DDR_reset_n),
      .DDR_we_n               (DDR_we_n),
      .FIXED_IO_ddr_vrn       (FIXED_IO_ddr_vrn),
      .FIXED_IO_ddr_vrp       (FIXED_IO_ddr_vrp),
      .FIXED_IO_mio           (FIXED_IO_mio),
      .FIXED_IO_ps_clk        (FIXED_IO_ps_clk),
      .FIXED_IO_ps_porb       (FIXED_IO_ps_porb),
      .FIXED_IO_ps_srstb      (FIXED_IO_ps_srstb),
      .M00_AXI_araddr         (),
      .M00_AXI_arburst        (),
      .M00_AXI_arcache        (),
      .M00_AXI_arid           (),
      .M00_AXI_arlen          (),
      .M00_AXI_arlock         (),
      .M00_AXI_arprot         (),
      .M00_AXI_arqos          (),
      .M00_AXI_arready        (),
      .M00_AXI_arsize         (),
      .M00_AXI_arvalid        (),
      .M00_AXI_awaddr         (),
      .M00_AXI_awburst        (),
      .M00_AXI_awcache        (),
      .M00_AXI_awid           (),
      .M00_AXI_awlen          (),
      .M00_AXI_awlock         (),
      .M00_AXI_awprot         (),
      .M00_AXI_awqos          (),
      .M00_AXI_awready        (),
      .M00_AXI_awsize         (),
      .M00_AXI_awvalid        (),
      .M00_AXI_bid            (),
      .M00_AXI_bready         (),
      .M00_AXI_bresp          (),
      .M00_AXI_bvalid         (),
      .M00_AXI_rdata          (),
      .M00_AXI_rid            (),
      .M00_AXI_rlast          (),
      .M00_AXI_rready         (),
      .M00_AXI_rresp          (),
      .M00_AXI_rvalid         (),
      .M00_AXI_wdata          (),
      .M00_AXI_wid            (),
      .M00_AXI_wlast          (),
      .M00_AXI_wready         (),
      .M00_AXI_wstrb          (),
      .M00_AXI_wvalid         (),
      .axi_clock              (axi_clock),
      .axi_resetn             (axi_resetn)
    );

  end
  else begin
    assign axi_clock = clock_125m;
    assign axi_resetn = ~reset_125m;
  end
endgenerate

// Output a simple patter on the board
assign leds = 4'b0101;

wire [31:0] axi_data;
wire        axi_write_en;

axi_generator #(
  .C_RATE       (C_CONTROL_RATE),
  .C_PIXELS     (C_PIXEL_COUNT)
)axi_generator_i(
  .axi_clock    (axi_clock),
  .axi_reset    (~axi_resetn),
  .axi_data     (axi_data),
  .axi_write_en (axi_write_en)
);


// Connect the first Neopixel module to a driver
wire pixel_clock;
wire pixel_reset;
wire pixel_wren;
wire [31:0] pixel_address;
wire [31:0] pixel_write_data;
wire [31:0] pixel_read_data;
wire        pixel_write_ready;

neopixel_control #(
  .C_PIXELS         (C_PIXEL_COUNT)
  )neopixel_control_i(
  .axi_clock        (axi_clock),
  .axi_reset        (~axi_resetn),
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
  .C_FREQ_HZ        (50000000)
)neopixel_i(
  .neopixel_clock   (axi_clock),
  .neopixel_reset   (~axi_resetn),
  .neopixel_drive   (neopixel_drive1),
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
