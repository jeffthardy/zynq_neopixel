//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (lin64) Build 1412921 Wed Nov 18 09:44:32 MST 2015
//Date        : Mon Sep 12 19:27:36 2016
//Host        : jeff-VirtualBox running 64-bit Ubuntu 16.04.1 LTS
//Command     : generate_target top_hw_wrapper.bd
//Design      : top_hw_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module top
   (
    clock_125m,
    neopixel_drive,

    DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    leds_tri_o
    );

  input clock_125m;
  output neopixel_drive;
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output [3:0]leds_tri_o;

  wire clock_125m;
  wire neopixel_drive;
  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [3:0]leds_tri_o;

//  wire clock_50mhz;
//  wire reset_n;
//
//wire pixel_clock;
//wire pixel_reset;
//wire pixel_wren;
//wire [31:0] pixel_address;
//wire [31:0] pixel_write_data;
//wire [31:0] pixel_read_data;

//neopixel_driver #(
//  .C_RATE   (32'd33000000)
//  )neopixel_driver_i(
//  .clock          (clock_125m),
//  .reset          (1'b0),
//  .clock_ctrl     (pixel_clock),
//  .reset_ctrl     (pixel_reset),
//  .write_readf    (pixel_wren),
//  .address        (pixel_address),
//  .write_data     (pixel_write_data),
//  .read_data      (pixel_read_data)
//);
//
//
//  neopixel #(
//  .C_PIXELS         (12),
//  .C_FREQ_HZ        (125000000)
//  )neopixel_i(
//  .clock            (clock_125m),
//  .reset            (1'b0),
//  .neopixel_drive   (neopixel_drive),
//  //control interface
//  .clock_ctrl       (pixel_clock),
//  .reset_ctrl       (pixel_reset),
//  .write_readf      (pixel_wren),
//  .address          (pixel_address),
//  .write_data       (pixel_write_data),
//  .read_data        (pixel_read_data)
//  );


  top_hw top_hw_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .clock_50mhz(clock_50mhz),
        .leds_tri_o(leds_tri_o),
        .neopixel_drive(neopixel_drive),
        .reset_n(reset_n));
endmodule
