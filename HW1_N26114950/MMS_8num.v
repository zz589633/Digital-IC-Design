`include "MMS_4num.v"

module MMS_8num(result, select, number0, number1, number2, number3, number4, number5, number6, number7);

input        select;
input  [7:0] number0;
input  [7:0] number1;
input  [7:0] number2;
input  [7:0] number3;
input  [7:0] number4;
input  [7:0] number5;
input  [7:0] number6;
input  [7:0] number7;
output [7:0] result; 

wire 		cmp0;
wire [7:0]	result0,result1;
reg  [7:0]	result2;

assign cmp0 = (result0 > result1);

MMS_4num u0
(
	.result(result0), 
	.select(select),
	.number0(number0), 
	.number1(number1),
	.number2(number2),
	.number3(number3)
);

MMS_4num u1
(
	.result(result1), 
	.select(select),
	.number0(number4), 
	.number1(number5),
	.number2(number6),
	.number3(number7)
);

always@(*)
begin
	case({select,cmp0})
		2'b00: result2 = result1;
		2'b01: result2 = result0;
		2'b10: result2 = result0;
		2'b11: result2 = result1;
	endcase
end

assign result = result2;

endmodule