/*
 * subservient.v : Toplevel for the subservient SoC
 *
 * SPDX-FileCopyrightText: 2021 Olof Kindgren <olof.kindgren@gmail.com>
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
module subservient
#(//Memory parameters
    parameter memsize  = 1024,
    parameter aw       = $clog2(memsize),
    //Enable CSR + interrupts
    parameter WITH_CSR = 1)
(
    `ifdef USE_POWER_PINS
        inout vccd1,	// User area 1 1.8V supply
        inout vssd1,	// User area 1 digital ground
    `endif
    input wire   i_clk,
    input wire   i_rst,

    //SRAM interface
    output wire [aw-1:0] o_sram_waddr,
    output wire [7:0]    o_sram_wdata,
    output wire          o_sram_wen,
    output wire [aw-1:0] o_sram_raddr,
    input wire [7:0]     i_sram_rdata,
    output wire          o_sram_ren,

    //Debug interface
    input wire           i_debug_mode,
    input wire [31:0]    i_wb_dbg_adr,
    input wire [31:0]    i_wb_dbg_dat,
    input wire [3:0]     i_wb_dbg_sel,
    input wire           i_wb_dbg_we ,
    input wire           i_wb_dbg_stb,
    output wire [31:0]   o_wb_dbg_rdt,
    output wire          o_wb_dbg_ack,

    //External I/O
    output wire  [37:0]   o_gpio);

    wire [31:0]  wb_core_adr;
    wire [31:0]  wb_core_dat;
    wire [3:0]   wb_core_sel;
    wire         wb_core_we;
    wire         wb_core_stb;
    wire [31:0]  wb_core_rdt;
    wire         wb_core_ack;

    wire timer_irq;

   subservient_core
     #(.memsize (memsize),
       .WITH_CSR (WITH_CSR))
   core
     (.i_clk       (i_clk),
      .i_rst       (i_rst),
      .i_timer_irq (timer_irq),

      //SRAM interface
      .o_sram_waddr (o_sram_waddr),
      .o_sram_wdata (o_sram_wdata),
      .o_sram_wen   (o_sram_wen),
      .o_sram_raddr (o_sram_raddr),
      .i_sram_rdata (i_sram_rdata),
      .o_sram_ren   (o_sram_ren),

      //Debug interface
      .i_debug_mode (i_debug_mode),
      .i_wb_dbg_adr (i_wb_dbg_adr),
      .i_wb_dbg_dat (i_wb_dbg_dat),
      .i_wb_dbg_sel (i_wb_dbg_sel),
      .i_wb_dbg_we  (i_wb_dbg_we ),
      .i_wb_dbg_stb (i_wb_dbg_stb),
      .o_wb_dbg_rdt (o_wb_dbg_rdt),
      .o_wb_dbg_ack (o_wb_dbg_ack),

      //Peripheral interface
      .o_wb_adr (wb_core_adr),
      .o_wb_dat (wb_core_dat),
      .o_wb_sel (wb_core_sel),
      .o_wb_we  (wb_core_we) ,
      .o_wb_stb (wb_core_stb),
      .i_wb_rdt (wb_core_rdt),
      .i_wb_ack (wb_core_ack));


    wire [31:0] wb_gpio_rdt;
    wire        wb_gpio_ack;
    wire        wb_gpio_stb;

    wire [31:0] acc_rdt;
    wire   acc_ack;
    wire   acc_stb;
    wire   acc_o;

    wire [31:0] timer_rdt;
    wire        timer_ack;
    wire        timer_stb;

    // The base address 2'b00 is assigned to the memory in serving_mux module
    wire   gpio_en =  (wb_core_adr[31:30] == 2'b01);
    wire   timer_en = (wb_core_adr[31:30] == 2'b10);
    wire   acc_en =   (wb_core_adr[31:30] == 2'b11);

    assign wb_gpio_stb = wb_core_stb & gpio_en;
    assign timer_stb = wb_core_stb & timer_en;
    assign acc_stb = wb_core_stb & acc_en;

    assign wb_core_rdt = gpio_en ? wb_gpio_rdt :
                        timer_en ? timer_rdt :
                        acc_en   ? acc_rdt :
                        32'b0;

    assign wb_core_ack = gpio_en  ? wb_gpio_ack :
                        timer_en  ? timer_ack :
                        acc_en    ? acc_ack :
                        1'b0;

   subservient_gpio gpio
     (.i_wb_clk (i_clk),
      .i_wb_rst (i_rst),
      .i_wb_adr (wb_core_adr[2]),
      .i_wb_dat (wb_core_dat),
      .i_wb_we  (wb_core_we),
      .i_wb_stb (wb_gpio_stb),
      .o_wb_rdt (wb_gpio_rdt),
      .o_wb_ack (wb_gpio_ack),
      .o_gpio   (o_gpio));


    servant_timer timer
    (  .i_clk(i_clk),
       .i_rst(i_rst),
       .o_irq(timer_irq),
       .i_wb_dat(wb_core_dat),
       .i_wb_we(wb_core_we),
       .i_wb_cyc(timer_stb),
       .o_wb_dat(timer_rdt),
       .o_wb_ack (timer_ack));

   Matrix_TOP acc
     (.i_wb_adr (wb_core_adr),
      .i_wb_clk (i_clk),
      .i_wb_rst (i_rst),
      .i_wb_dat (wb_core_dat),
      .i_wb_we  (wb_core_we),
      .i_wb_stb (acc_stb),
      .o_wb_rdt (acc_rdt),
      .o_wb_ack (acc_ack));


endmodule
