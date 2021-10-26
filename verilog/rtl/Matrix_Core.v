module Matrix_Core(
    input wire clk,
    input wire m_rst,
    input wire run,
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] acc
);
    reg [31:0]c;
    reg  [31:0]acc_r;

    assign acc = acc_r;

    always@(posedge clk) begin
        if(run) begin
            case(m_rst) 
                1:    acc_r <= a*b;
                0:    acc_r <= acc_r + a*b;
                default: acc_r <= 0;
            endcase
        end
        else
            acc_r <= 0;

    end
endmodule