module rails(clk, reset, data, valid, result);

input        clk;
input        reset;
input  [3:0] data;
output 	     valid;
output reg   result; 

reg [3:0] num,count;
reg [3:0] position;
reg [0:0] train [9:0];
wire wr_en;

assign wr_en = ((count == 4'd1) || (count == num) || (data > position) || (position-data == 4'd1)
			   ||(position-data==4'd2 && train[position-2]) || (position-data==4'd3 && train[position-2] && train[position-3])
			   ||(position-data==4'd4 && train[position-2] && train[position-3] && train[position-4])
			   ||(position-data==4'd5 && train[position-2] && train[position-3] && train[position-4] && train[position-5])
			   ||(position-data==4'd6 && train[position-2] && train[position-3] && train[position-4] && train[position-5] && train[position-6])
			   ||(position-data==4'd7 && train[position-2] && train[position-3] && train[position-4] && train[position-5] && train[position-6] && train[position-7])
			   ||(position-data==4'd8 && train[position-2] && train[position-3] && train[position-4] && train[position-5] && train[position-6] && train[position-7] && train[position-8])
			   ||(position-data==4'd9 && train[position-2] && train[position-3] && train[position-4] && train[position-5] && train[position-6] && train[position-7] && train[position-8] && train[position-9]));
      
always@(posedge clk or posedge reset)   
begin
	if(reset)
		count <= 4'd0;
	else if(valid)
		count <= 4'd0;
	else if (count <= num)
		count <= count + 4'd1;
	else
		count <= count;
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		num <= 4'd0;
	else if(count == 4'd0)
		num <= data;
	else
		num <= num;
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		train[0] <= 1'd0;
	else if(valid)
		train[0] <= 1'd0;
	else if(data == 4'd1 && count!= 4'd0 && wr_en)
		train[0] <= 1'd1;
	else
		train[0] <= train[0];
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		train[1] <= 1'd0;
	else if(valid)
		train[1] <= 1'd0;
	else if(data == 4'd2 && count!= 4'd0 && wr_en)
		train[1] <= 1'd1;
	else
		train[1] <= train[1];
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		train[2] <= 1'd0;
	else if(valid)
		train[2] <= 1'd0;
	else if(data == 4'd3 && count!= 4'd0 && wr_en)
		train[2] <= 1'd1;
	else
		train[2] <= train[2];
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		train[3] <= 1'd0;
	else if(valid)
		train[3] <= 1'd0;
	else if(data == 4'd4 && count!= 4'd0 && wr_en)
		train[3] <= 1'd1;
	else
		train[3] <= train[3];
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		train[4] <= 1'd0;
	else if(valid)
		train[4] <= 1'd0;
	else if(data == 4'd5 && count!= 4'd0 && wr_en)
		train[4] <= 1'd1;
	else
		train[4] <= train[4];
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		train[5] <= 1'd0;
	else if(valid)
		train[5] <= 1'd0;
	else if(data == 4'd6 && count!= 4'd0 && wr_en)
		train[5] <= 1'd1;
	else
		train[5] <= train[5];
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		train[6] <= 1'd0;
	else if(valid)
		train[6] <= 1'd0;
	else if(data == 4'd7 && count!= 4'd0 && wr_en)
		train[6] <= 1'd1;
	else
		train[6] <= train[6];
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		train[7] <= 1'd0;
	else if(valid)
		train[7] <= 1'd0;
	else if(data == 4'd8 && count!= 4'd0 && wr_en)
		train[7] <= 1'd1;
	else
		train[7] <= train[7];
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		train[8] <= 1'd0;
	else if(valid)
		train[8] <= 1'd0;
	else if(data == 4'd9 && count!= 4'd0 && wr_en)
		train[8] <= 1'd1;
	else
		train[8] <= train[8];
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		train[9] <= 1'd0;
	else if(valid)
		train[9] <= 1'd0;
	else if(data == 4'd10 && count!= 4'd0 && wr_en)
		train[9] <= 1'd1;
	else
		train[9] <= train[9];
end

always@(posedge clk or posedge reset)
begin
	if(reset)
		position <= 4'd0;
	else if(count == num + 4'd1)
		position <= position;
	else if(count <= num && count != 4'd0)
		position <= data;
	else
		position <= position;
end

assign valid = (num+4'd1 == count);

always@(posedge clk or posedge reset)
begin
	if(reset)
		result <= 1'd0;
	else if(valid)
		result <= 1'd1;
	else if(wr_en == 1'd0 && count != 4'd0)
		result <= 1'd0;
	else
		result <= result;
end

endmodule