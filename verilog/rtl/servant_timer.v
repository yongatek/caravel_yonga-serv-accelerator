`default_nettype none
module servant_timer
  #(parameter WIDTH = 32,
    parameter DIVIDER = 0)
  (input wire 	     i_clk,
   input wire 	     i_rst,
   output reg 	     o_irq,
   input wire [31:0] i_wb_dat,
   input wire 	     i_wb_we,
   input wire 	     i_wb_cyc,
   output reg       o_wb_ack,
   output reg [31:0] o_wb_dat);

    always@(posedge i_clk) begin
        o_wb_ack <= i_wb_cyc & !o_wb_ack;
        if (i_rst) begin
            o_wb_ack <= 1'b0;
        end
    end
   localparam HIGH = WIDTH-1-DIVIDER;

   reg [WIDTH-1:0]   mtime;
   reg [HIGH:0]      mtimecmp;

   wire [HIGH:0]     mtimeslice = mtime[WIDTH-1:DIVIDER];

   always @(mtimeslice) begin
      o_wb_dat = 32'd0;
      o_wb_dat[HIGH:0] = mtimeslice;
   end

    always @(posedge i_clk) begin
        if (i_wb_cyc & i_wb_we)
            mtimecmp <= i_wb_dat[HIGH:0];
        mtime <= mtime + 'd1;
        o_irq <= (mtimeslice >= mtimecmp);
        if (i_rst) begin
            mtime <= 0;
            mtimecmp <= 0;
        end
    end
endmodule
