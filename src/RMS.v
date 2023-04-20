// `timescale 1ns/100ps
// `include "../design/sqrt.v"

module top(
           input clk,
           input rst,
           input [7:0] in_data,
           input in_valid,
           input storage_reset,

           output [11:0] out_data,
           output out_valid,
           output in_rdy,
           output [1:0] err_data,
           output err_valid

       );

reg [2:0] current_state,next_state;
reg [7:0] rdy_data;
reg [17:0] square_result;
reg [17:0] square_result_next;
reg [8:0] count;
reg [8:0] count_next;

reg [11:0] out_data_reg;
reg in_rdy_reg;

wire [31:0] divide_result;
reg [31:0] divide_result_reg;
wire [11:0] ROOT;
wire en;
wire out_valid_reg1;
reg out_valid_reg;
reg  en_reg;
reg  en_add_reg;
sqrt U0(.clk(clk),.rst(rst),.in_data(divide_result),.en(en),.out_valid(out_valid_reg1),.out_data(ROOT));

//reg [11:0] RMS;

parameter RESET=0,READY=1, INPUT=2,CALCULATE=3,OUTPUT=4;



always@(posedge clk or posedge rst)
begin
    if(rst)
        current_state <= RESET;
    else
        current_state <= next_state;
end

always@(*)
begin
    case(current_state)
        RESET :
            next_state = (rst == 0)?READY:RESET;
        READY :
            next_state = (in_valid == 0)?READY:INPUT;
        INPUT :
            next_state = (in_valid == 1)?INPUT:CALCULATE;
        CALCULATE:
            next_state = (out_valid_reg1 == 1)?OUTPUT:CALCULATE;
        OUTPUT:
            next_state = READY;
        default:
            next_state = READY;
    endcase
end

always@(*)
begin
    case(current_state)
        RESET:
        begin
            in_rdy_reg = 0;
            en_add_reg = 0;
            out_valid_reg = 0;
            en_reg = 0;
        end
        READY:
        begin
            in_rdy_reg = 1;
            en_add_reg = 0;
            out_valid_reg = 0;
            en_reg = 0;
        end
        INPUT:
        begin
            in_rdy_reg = 0;
            out_valid_reg = 0;
            en_add_reg = 1;
            en_reg = 0;
        end
        CALCULATE:
        begin
            in_rdy_reg = 0;
            en_add_reg = 0;
            out_valid_reg = 0;
            en_reg = 1;
        end
        OUTPUT:
        begin
            in_rdy_reg = 0;
            en_add_reg = 0;
            out_valid_reg = 1;
            en_reg = 0;
        end
        default:
        begin
            in_rdy_reg = 0;
            en_add_reg = 0;
            out_valid_reg = 0;
            en_reg = 0;
        end
    endcase
end


always @(posedge clk or posedge rst)
begin
    if(rst)
        square_result <= 0;
    else if (storage_reset == 1)
        square_result <= 0;
    else if(next_state == INPUT)
        square_result <= square_result_next;
    else if (storage_reset == 1)
        square_result <= 0;
    else
        square_result <= square_result;
end

always @(*)
begin //accumulator
    rdy_data = in_data;
    square_result_next = square_result + rdy_data * rdy_data;
end

always @(posedge clk or posedge rst)
begin
    if(rst)
        count <= 0;
    else if(next_state == INPUT)
        count <= count_next;
    else
        count <= count;
end

always @(*)
begin //count
    count_next = count + 1;
end

always @(*)
begin
    divide_result_reg = ({square_result, 8'b0}) / count;
end

always @(posedge clk)
begin
    out_data_reg <= ROOT;
end


assign divide_result = divide_result_reg;
assign en = en_reg;

assign out_valid = out_valid_reg;
assign out_data = out_data_reg;
assign in_rdy = in_rdy_reg;
assign err_data = 0;
assign err_valid = 0;


endmodule
