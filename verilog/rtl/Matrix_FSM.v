`default_nettype none
module Matrix_FSM 
(
    input wire i_clk,
    input wire start,
    input wire [7:0] f_matrix_row_size,
    input wire [7:0] f_matrix_column_size,
    input wire [7:0] s_matrix_column_size,
    //output wire o_rst,
    output wire [7:0]o_fm_adr,
    output wire [7:0]o_sm_adr,
    output wire [7:0]o_t_adr,
    output reg finished,
    output reg m_rst,
    output wire o_run
);
    reg [7:0]fm_adr;
    reg [7:0]sm_adr;
    reg [7:0]t_adr;
    assign o_fm_adr = fm_adr;
    assign o_sm_adr = sm_adr;
    assign o_t_adr = t_adr;

    reg run;
    assign o_run = run;
    reg [1:0]state;
    localparam START_DOWN = 0;
    localparam RUN = 1;
    localparam START_UP = 2;

    reg [7:0] f_matrix_column_counter;
    reg [7:0] f_matrix_row_counter;
    reg [7:0] s_matrix_column_counter;

    always@(posedge i_clk) begin
        if(run == 1) begin 
            f_matrix_column_counter <= f_matrix_column_counter + 1;
            if(f_matrix_column_counter == (f_matrix_column_size-1)) begin
                f_matrix_column_counter <= 0;
                f_matrix_row_counter <= f_matrix_row_counter + 1;
            end
            if(f_matrix_row_counter == (f_matrix_row_size-1) && f_matrix_column_counter == (f_matrix_column_size-1))
                f_matrix_row_counter <= 0;
        end
        else begin
            f_matrix_column_counter <= 0;
            f_matrix_row_counter <= 0;
        end
    end
    always@(posedge i_clk) begin
        if(run == 1) begin 
            if(f_matrix_row_counter == (f_matrix_row_size-1) && f_matrix_column_counter == (f_matrix_column_size-1))
                s_matrix_column_counter <= s_matrix_column_counter + 1;
        end
        else
            s_matrix_column_counter <= 0;
    end
    always@(posedge i_clk) begin
        if(run == 1) begin
            if(f_matrix_row_counter == (f_matrix_row_size-1) && f_matrix_column_counter == (f_matrix_column_size-1))
                fm_adr <= 0;
            else
                fm_adr <= fm_adr + 1;
        end
        else
            fm_adr <= 0;
    end
    always@(posedge i_clk) begin
        if(run == 1) begin
            if(f_matrix_row_counter == (f_matrix_row_size-1) && f_matrix_column_counter == (f_matrix_column_size-1))
                    sm_adr <= s_matrix_column_counter + 1;
            else if(f_matrix_column_counter == (f_matrix_column_size-1))
                sm_adr <= s_matrix_column_counter;
            else
                sm_adr <= sm_adr + s_matrix_column_size;
        end
        else
            sm_adr <= 0;
    end
    always@(posedge i_clk) begin
        if(run == 1) begin
            if(f_matrix_column_counter == (f_matrix_column_size-1))
                m_rst <= 0;
            else
                m_rst <= 1;
            if(f_matrix_row_counter == (f_matrix_row_size-1) && (f_matrix_column_counter == (f_matrix_column_size-1))) begin
                t_adr <= s_matrix_column_counter + 1;
            end
            else if(f_matrix_column_counter == (f_matrix_column_size-1))
                t_adr <= t_adr + s_matrix_column_size;
        end
        else begin
            t_adr <= 0;
            m_rst <= 1;
        end
    end
    always@(posedge i_clk) begin
        case(state)
            START_DOWN: begin
                finished <= 1;
                if (start == 1) begin
                    run <= 1;
                    state <= RUN;
                end
                else
                    state <= START_DOWN;
            end
            RUN: begin
                finished <= 0;
                if (s_matrix_column_counter == (s_matrix_column_size-1) && f_matrix_row_counter == (f_matrix_row_size-1) && f_matrix_column_counter == (f_matrix_column_size-1)) begin
                    state <= START_UP;
                    run <= 0;
                end
                else
                    state <= RUN;
            end
            START_UP: begin
                finished <= 1;
                if (start == 1)
                    state <= START_UP;
                else
                    state <= START_DOWN;
            end
            default:
                state <= START_DOWN;
        endcase
    end
endmodule
