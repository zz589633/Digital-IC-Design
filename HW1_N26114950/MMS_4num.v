module MMS_4num(result, select, number0, number1, number2, number3);

input        select;
input  [7:0] number0;
input  [7:0] number1;
input  [7:0] number2;
input  [7:0] number3;
output [7:0] result; 

wire cmp0,cmp1,cmp2;
reg [7:0] cmp_result0,cmp_result1,cmp_result2;

assign cmp0 = (number0 > number1);
assign cmp1 = (number2 > number3);
assign cmp2 = (cmp_result0 > cmp_result1);

always@(*)
begin
	case({select,cmp0})
		2'b00: cmp_result0 = number1;
		2'b01: cmp_result0 = number0;
		2'b10: cmp_result0 = number0;
		2'b11: cmp_result0 = number1;
	endcase
end

always@(*)
begin
	case({select,cmp1})
		2'b00: cmp_result1 = number3;
		2'b01: cmp_result1 = number2;
		2'b10: cmp_result1 = number2;
		2'b11: cmp_result1 = number3;
	endcase
end

always@(*)
begin
	case({select,cmp2})
		2'b00: cmp_result2 = cmp_result1;
		2'b01: cmp_result2 = cmp_result0;
		2'b10: cmp_result2 = cmp_result0;
		2'b11: cmp_result2 = cmp_result1;
	endcase
end

assign result = cmp_result2;

endmodule