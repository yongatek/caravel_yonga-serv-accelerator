/*
 * subservient_gpio.v : Single-bit GPIO for the subservient SoC
 *
 * SPDX-FileCopyrightText: 2021 Olof Kindgren <olof.kindgren@gmail.com>
 * SPDX-License-Identifier: Apache-2.0
 */

module Matrix_TOP #(
    parameter F_MATRIX_ROW_SIZE_MAX = 8,
    parameter F_MATRIX_COLUMN_SIZE_MAX = 8,
    parameter S_MATRIX_COLUMN_SIZE_MAX = 8
)
  (
    input wire [31:0] i_wb_adr,
    input wire i_wb_clk,
    input wire i_wb_rst,
    input wire [31:0] i_wb_dat,
    input wire i_wb_we,
    input wire i_wb_stb,
    output reg [31:0] o_wb_rdt,
    output reg o_wb_ack);

    wire [7:0] fm_adr;
    wire [7:0] sm_adr;
    wire [7:0] t_adr;
    wire finished;
    wire m_rst;

    reg [31:0] first_matrix[((F_MATRIX_ROW_SIZE_MAX*F_MATRIX_COLUMN_SIZE_MAX)-1):0];
    reg [31:0] second_matrix[((F_MATRIX_COLUMN_SIZE_MAX*S_MATRIX_COLUMN_SIZE_MAX)-1):0];
    reg [31:0] third_matrix[((F_MATRIX_ROW_SIZE_MAX*S_MATRIX_COLUMN_SIZE_MAX)-1):0];
    wire [31:0] acc;
    wire [7:0] f_matrix_row_size;
    wire [7:0] f_matrix_column_size;
    wire [7:0] s_matrix_column_size;
    wire start;
    wire run;
    reg [24:0] control_register;
    assign f_matrix_row_size = control_register[7:0];
    assign f_matrix_column_size = control_register[15:8];
    assign s_matrix_column_size = control_register[23:16];
    assign start = control_register[24];
    always@(posedge i_wb_clk) begin
        o_wb_ack <= i_wb_stb & !o_wb_ack;
        if (i_wb_rst) begin
            control_register <= 25'b0;
            o_wb_ack <= 1'b0;
        end
        else begin
            case(i_wb_adr[12:10])
                3'd0: begin
                    if(i_wb_stb & i_wb_we)
                        control_register <= i_wb_dat;
                end
                3'd1: begin
                    if(i_wb_stb & i_wb_we)
                        first_matrix[i_wb_adr[9:2]] <= i_wb_dat;
                end
                3'd2: begin
                    if(i_wb_stb & i_wb_we)
                        second_matrix[i_wb_adr[9:2]] <= i_wb_dat;
                end
                3'd3: begin
                    o_wb_rdt <= third_matrix[i_wb_adr[9:2]];
                end
                3'd4: begin
                    o_wb_rdt <= finished;
                end
                default: begin
                    control_register <= control_register;
                end
            endcase
        end
    end
    Matrix_FSM FSM_0(
        .i_clk(i_wb_clk),
        .start(start),
        .f_matrix_row_size(f_matrix_row_size),
        .f_matrix_column_size(f_matrix_column_size),
        .s_matrix_column_size(s_matrix_column_size),
        .o_fm_adr(fm_adr),
        .o_sm_adr(sm_adr),
        .o_t_adr(t_adr),
        .finished(finished),
        .m_rst(m_rst),
        .o_run(run)
    );

    reg m_rst_t;
    always@(negedge i_wb_clk) begin
        if(m_rst == 0)
            m_rst_t <= 1;
        else
            m_rst_t <= 0;
    end

    Matrix_Core ma_core(
        .clk(i_wb_clk),
        .m_rst(m_rst_t),
        .run(run),
        .a(first_matrix[fm_adr]),
        .b(second_matrix[sm_adr]),
        .acc(acc)
    );

    reg [7:0] t_adr_p;
    reg [7:0] t_adr_pp;

    always@(negedge i_wb_clk) t_adr_p <= t_adr;
    always@(negedge i_wb_clk) t_adr_pp <= t_adr_p;

    always@(posedge m_rst_t) begin
        third_matrix[t_adr_pp] <= acc;
    end


endmodule
