`timescale 1ns/10ps
module  ATCONV(
	input		clk,
	input		reset,
	output		busy,	
	input		ready,	
			
	output reg	 [11:0]	iaddr,
	input signed [12:0]	idata,
	
	output	 			cwr,
	output  	[11:0]	caddr_wr,
	output  	[12:0] 	cdata_wr,
	
	output	 			crd,
	output reg	[11:0] 	caddr_rd,
	input 		[12:0] 	cdata_rd,
	
	output  	csel
	);

parameter Initial = 3'd0;
parameter Get_kernel = 3'd1;
parameter Conv_ReLU = 3'd2;
parameter Get_pool = 3'd3;
parameter Pool_Round = 3'd4;
integer i;

reg [2:0] cs,ns;
reg [12:0] kernel[8:0];
reg [3:0] kernel_count;
wire[11:0]ker0,ker1,ker2,ker3,ker4,ker5,ker6,ker7,ker8;
reg [11:0] lower_bound,upper_bound;
reg [12:0] iteration;
wire[11:0]distance_up,distance_down;
wire [15:0]Conv_add_value;
wire[12:0]kervalue0,kervalue1,kervalue2,kervalue3,kervalue4,kervalue5,kervalue6,kervalue7,kervalue8;
reg [5:0] row_count;
wire [16:0]Conv_value_bias;
wire [14:0]Conv_value_relu;
wire[14:0]Conv_value;
reg[1:0]pool_count;
reg[12:0]Max_pool_reg;
wire[12:0]Max_pool_reg_Round;
reg[11:0]y_stride;
reg[4:0]count_row;
wire[11:0]pool_index;

always @(posedge clk or posedge reset) 
if(reset)
	cs <= 3'd0;
else
	cs <= ns;

always@(*)
case(cs)
	3'd0: ns = (ready)? Get_kernel : Initial;
	3'd1: ns = (kernel_count==4'd8)? Conv_ReLU : Get_kernel;
	3'd2: ns = (caddr_wr==12'd4095)? Get_pool : Get_kernel;
	3'd3: ns = (pool_count==2'd3)? Pool_Round : Get_pool;
	3'd4: ns = (caddr_wr==12'd1023)? Initial : Get_pool;
	default: ns = Initial;
endcase

always@(posedge clk or posedge reset)
if(reset)
	begin
		kernel_count <= 4'd0;
		iteration <= 13'd0;
		row_count <=  6'd0;
		lower_bound <= 12'd0;
		upper_bound <= 12'd63;
		for(i=0;i<9;i=i+1)
			kernel[i] <= 13'd0;
		pool_count <= 2'd0;
		y_stride <= 12'd0;
		count_row <= 5'd0;
		Max_pool_reg <= 13'd0;
	end
else
	begin
		case(cs)
			Initial:
			begin
				kernel_count <= 4'd0;
				iteration <= 13'd0;
				row_count <=  6'd0;
				lower_bound <= 12'd0;
				upper_bound <= 12'd63;
				for(i=0;i<9;i=i+1)
					kernel[i] <= 13'd0;
				pool_count <= 2'd0;
				y_stride <= 12'd0;
				count_row <= 5'd0;
				Max_pool_reg <= 13'd0;
			end
			Get_kernel:
			begin
				kernel_count <= kernel_count + 4'd1;
				kernel [kernel_count] <= idata;
			end
			Conv_ReLU:
			begin
				kernel_count <= 4'd0;
				//iteration <= (iteration==13'd4095)? 13'd0 : iteration + 13'd1; // count to 4095
				iteration <= iteration + 13'd1;
				//row_count <= (row_count==6'd63)? 6'd0 : row_count + 6'd1;
				row_count <= row_count + 6'd1;
				lower_bound <= (row_count==6'd63)? lower_bound + 12'd64 : lower_bound;
				upper_bound <= (row_count==6'd63)? upper_bound + 12'd64 : upper_bound;
			end
			Get_pool:
			begin
				//pool_count <= (pool_count==2'd3)? 2'd0 : pool_count + 2'd1;
				pool_count <= pool_count + 2'd1;
				Max_pool_reg <= (cdata_rd > Max_pool_reg)? cdata_rd : Max_pool_reg;
			end
			Pool_Round:
			begin
				iteration <= (iteration==13'd1023)? 13'd0 : iteration + 13'd2; //stride=2
				y_stride <= (count_row==5'd31)? y_stride + 12'd1 : y_stride;
				//count_row <= (count_row==5'd31)? 5'd0 : count_row + 5'd1; //16 pool-kernal per row
				count_row <= count_row + 5'd1; //16 pool-kernal per row 
				Max_pool_reg <= 13'd0;
			end
			default:
			begin
				kernel_count <= 4'd0;
				iteration <= 13'd0;
				row_count <=  6'd0;
				lower_bound <= 12'd0;
				upper_bound <= 12'd63;
				for(i=0;i<9;i=i+1)
					kernel[i] <= 13'd0;
				pool_count <= 2'd0;
				y_stride <= 12'd0;
				count_row <= 5'd0;
				Max_pool_reg <= 13'd0;
			end
		endcase
	end

//------------------------------------------------------------------------------------------------------------------------
assign pool_index = iteration[11:0] + (y_stride << 6);

always@(*)
begin
	case(pool_count)
		2'd0: caddr_rd = pool_index;
		2'd1: caddr_rd = pool_index + 12'd1;
		2'd2: caddr_rd = pool_index + 12'd64;
		2'd3: caddr_rd = pool_index + 12'd65;
	endcase
end

assign Max_pool_reg_Round = (Max_pool_reg[3:0] == 4'b0000)? {Max_pool_reg[12:4],4'd0}:{Max_pool_reg[12:4]+9'd1,4'd0} ;
	
//------------------------------------------------------------------------------------------------------------------------
always@(*)
begin
	case(kernel_count)
		4'd0: iaddr = ker0;
		4'd1: iaddr = ker1;
		4'd2: iaddr = ker2;
		4'd3: iaddr = ker3;
		4'd4: iaddr = ker4;
		4'd5: iaddr = ker5;
		4'd6: iaddr = ker6;
		4'd7: iaddr = ker7;
		4'd8: iaddr = ker8;
		default: iaddr = 12'd0;
	endcase
end
	
assign distance_up = (iteration<13'd64)? 12'd0 : ((iteration<13'd128)&&(iteration>13'd63))? 12'd64 : 12'd128;
assign distance_down = (iteration>13'd4031)? 12'd0 : ((iteration<13'd4032)&&(iteration>13'd3967))? 12'd64 : 12'd128;

assign ker0 = ker3 - distance_up;
assign ker1 = ker4 - distance_up;
assign ker2 = ker5 - distance_up;
assign ker3 = (iteration < lower_bound + 12'd2)? lower_bound : iteration - 13'd2;
assign ker4 = iteration;
assign ker5 = (iteration + 13'd2 > upper_bound)? upper_bound : iteration + 13'd2;
assign ker6 = ker3 + distance_down;
assign ker7 = ker4 + distance_down;
assign ker8 = ker5 + distance_down;

//------------------------------------------------------------------------------------------------------------------------
//assign busy = (cs == Initial)? 1'd0 : 1'd1;
assign busy = !(cs == Initial);

//assign csel = (cs == Conv_ReLU || cs == Get_pool)? 1'd0 : 1'd1;
assign csel = !(cs == Conv_ReLU || cs == Get_pool);

//assign cwr = (cs == Conv_ReLU || cs == Pool_Round)? 1'd1 : 1'd0;
assign cwr = (cs == Conv_ReLU || cs == Pool_Round);

assign caddr_wr = (cs == Conv_ReLU)? iteration[11:0] : (cs == Pool_Round)? (iteration[11:0] >> 1) : 12'd0;
assign cdata_wr = (cs == Conv_ReLU)? Conv_value_relu[12:0] : (cs == Pool_Round)? Max_pool_reg_Round : 13'd0;

//assign crd = (cs == Get_pool)? 1'd1 : 1'd0; 
assign crd = (cs == Get_pool);


assign Conv_add_value = ({~kervalue0[12],{kervalue0[11:0] >> 4}}) + ({~kervalue1[12],{kervalue1[11:0] >> 3}}) + ({~kervalue2[12],{kervalue2[11:0] >> 4}}) + ({~kervalue3[12],{kervalue3[11:0] >> 2}}) +
					({~kervalue5[12],{kervalue5[11:0] >> 2}}) + ({~kervalue6[12],{kervalue6[11:0] >> 4}}) + ({~kervalue7[12],{kervalue7[11:0] >> 3}}) + ({~kervalue8[12],{kervalue8[11:0] >> 4}});
assign Conv_value = ({2'd0,kervalue4} > Conv_add_value[14:0])? {2'd0,kervalue4} - Conv_add_value[14:0] : 15'd0;
assign Conv_value_relu = (Conv_value > 15'b000000000001100)? Conv_value - 15'b000000000001100 : 15'd0;

assign kervalue0 = kernel[0];
assign kervalue1 = kernel[1];
assign kervalue2 = kernel[2];
assign kervalue3 = kernel[3];
assign kervalue4 = kernel[4];
assign kervalue5 = kernel[5];
assign kervalue6 = kernel[6];  
assign kervalue7 = kernel[7];
assign kervalue8 = kernel[8];


endmodule