module channel_selecter #(
    // parameters
    parameter num_of_ports = 16,
    parameter arbiter_data_width = 64,
    parameter des_port_width = 4,
    parameter pack_length_width  = 8
) (
    // ports
    input                                                   clk,
    input                                                   rst,
    input                                                   enable,
    input                                                   busy,
    input       [3:0]                                       select,
    input       [3:0]                                       pre_selected,
    input       [(arbiter_data_width * num_of_ports)-1:0]   selected_data_in,
    input       [des_port_width*num_of_ports-1:0]           des_port_in,
    input       [pack_length_width*num_of_ports-1:0]        pack_length_in,
    output  reg [arbiter_data_width-1:0]                    selected_data_out,
    output  reg [des_port_width-1:0]                        des_port_out,
    output  reg [pack_length_width-1:0]                     pack_length_out,
    output  reg [des_port_width-1:0]                        pre_des_port_out,
    output  reg [pack_length_width-1:0]                     pre_pack_length_out,
    output  reg [3:0]                                       enabled
);

    wire    [arbiter_data_width-1:0]    datas       [num_of_ports-1:0];
    wire    [des_port_width-1:0]        des_ports   [num_of_ports-1:0];
    wire    [pack_length_width-1:0]     pack_length [num_of_ports-1:0];
    reg                                 des_port_lock;

    // 解压缩selected_data_in端口
    genvar i;
    generate
        for (i = 0; i < num_of_ports; i = i + 1) begin
            assign datas[i] = selected_data_in[(i + 1) * arbiter_data_width - 1 : i * arbiter_data_width];
            assign des_ports[i] = des_port_in[(i+1)*des_port_width-1:i*des_port_width];
            assign pack_length[i] = pack_length_in[(i+1)*pack_length_width-1:i*pack_length_width];
        end
    endgenerate

    always @(posedge clk ) begin
        if (rst) begin
            selected_data_out <= 0; enabled <= 0;
        end else begin
            if (enable) begin
                selected_data_out <= datas[select];
                if (!des_port_lock) begin
                    des_port_out <= des_ports[select];
                    pack_length_out <= pack_length[select];
                    des_port_lock <= 1'b1;                    
                end
                enabled <= select;
            end else begin
                selected_data_out <= {arbiter_data_width{1'b0}};
                des_port_lock <= 1'b0;
                des_port_out <= {des_port_width{1'b0}};
                pre_des_port_out <= {des_port_width{1'b0}};
                pre_pack_length_out <= {pack_length_width{1'b0}};
                enabled <= 4'b0000;
            end
            if (busy) begin
                pre_des_port_out <= des_ports[pre_selected];
                pre_pack_length_out <= pack_length[pre_selected];
            end
        end
    end
    
endmodule
