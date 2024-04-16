// `define num_of_ports 16
module write_arbiter #(
    parameter num_of_ports = 16,
    parameter arbiter_data_width = 256
)
(
    // ports
    input                                                       rst,
    input                                                       clk,
    input                                                       sp0_wrr1,
    input   wire    [(num_of_ports * arbiter_data_width)-1:0]   data_in_p,
    output  reg     [(num_of_ports)-1:0]                        data_out
);

    wire    [arbiter_data_width-1:0]    data_in     [num_of_ports-1:0];

    genvar i;
    generate
        for (i = 0; i < num_of_ports; i = i + 1) begin
            assign data_in[i] = data_in_p[i * arbiter_data_width + arbiter_data_width - 1:i * arbiter_data_width];
        end
    endgenerate

    always @(posedge clk ) begin
        if (rst) begin
            data_out <= 1'b0;
        end else begin
            case (sp0_wrr1)
                1'b0: begin // *SP严格优先级
                    data_out <= data_in[1];
                    // TODO
                end
                1'b1: begin // *WRR加权轮询调度
                    // TODO
                end
                default: data_out <= data_out;
            endcase
        end
    end
    
endmodule