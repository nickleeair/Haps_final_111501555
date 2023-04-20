`ifndef __SQRT_V__
`define __SQRT_V__
        module sqrt(
            input clk,
            input rst,
            input [31:0] in_data,
            input en,
            output out_valid,
            output [11:0] out_data
        );


reg [11:0] out_data_true;
reg [11:0] out_data_true_next;
reg out_valid_true;
reg out_valid_true_next;

reg [7:0] integer_parts;
reg [7:0] integer_parts_next;
reg [3:0] fraction_parts;
reg [3:0] fraction_parts_next;
reg integer_trigger;
reg [7:0] temp1;
reg [15:0] temp2;
reg [31:0] temp_result;
reg [31:0] difference;

reg [31:0] last_temp_result;
reg [7:0] last_integer_parts;
reg [3:0] last_fraction_parts;


always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        out_valid_true <= 0;
    end
    else if(en)
        out_valid_true <= out_valid_true_next;
    else
        out_valid_true <= 0;
end

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        out_data_true <= 0;
    end
    else if(en)
        out_data_true <= out_data_true_next;
    else
        out_data_true <= 0;
end

always @(posedge clk or posedge rst)
begin
    if(rst)
        fraction_parts <= 0;
    else if(en)
        fraction_parts <= fraction_parts_next;
    else
        fraction_parts <= 0;
end

always @(*)
begin //fraction_parts
    if (fraction_parts < 15)
    begin
        fraction_parts_next = fraction_parts + 1;
        integer_trigger = 0;
    end
    else
    begin
        fraction_parts_next = 0;
        integer_trigger = 1;
    end
end

always @(posedge clk or posedge rst)
begin
    if(rst)
        integer_parts <= 0;
    else if(en == 1 && integer_trigger == 1)
        integer_parts <= integer_parts_next;
    else if(en == 1 && integer_trigger != 1)
        integer_parts <= integer_parts;
    else
        integer_parts <= 0;
end

always @(*)
begin //integer_parts
    if (integer_parts < 256)
        integer_parts_next = integer_parts + 1;
    else
        integer_parts_next = 0;
end

always @(posedge clk) begin
    last_temp_result <= temp_result;
    last_fraction_parts <= fraction_parts;
    last_integer_parts  <= integer_parts;
end

always @(*) begin
    difference = in_data - last_temp_result;
end

always @(*)
begin
    temp1 = fraction_parts * fraction_parts;
    temp2 = integer_parts * integer_parts;
    temp_result = {temp2,8'b0} + temp1 +2*{integer_parts,4'b0}*fraction_parts;
    if (in_data == temp_result)
    begin
        out_data_true_next = {integer_parts,fraction_parts};
        out_valid_true_next = 1;
    end
    else if (in_data > temp_result )
    begin
        out_data_true_next = {integer_parts,fraction_parts};
        out_valid_true_next = 0;
    end
    else
    begin
        if(difference > temp_result - in_data)
        begin
            out_data_true_next = {integer_parts,fraction_parts};
            out_valid_true_next = 1;
        end
        else begin
            out_data_true_next = {last_integer_parts,last_fraction_parts};
            out_valid_true_next = 1;
        end
    end
end



assign out_data = out_data_true;   //final assignment of output.
assign out_valid = out_valid_true;

endmodule


`endif
