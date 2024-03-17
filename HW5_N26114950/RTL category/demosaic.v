module demosaic(clk, reset, in_en, data_in, wr_r, addr_r, wdata_r, rdata_r, wr_g, addr_g, wdata_g, rdata_g, wr_b, addr_b, wdata_b, rdata_b, done);
input clk;
input reset;
input in_en;
input [7:0] data_in;
output wr_r;
output reg[13:0] addr_r;
output reg[7:0] wdata_r;
input [7:0] rdata_r;
output wr_g;
output reg[13:0] addr_g;
output reg[7:0] wdata_g;
input [7:0] rdata_g;
output wr_b;
output reg[13:0] addr_b;
output reg[7:0] wdata_b;
input [7:0] rdata_b;
output done;

parameter Init = 4'd0;
parameter Store_data = 4'd1;
parameter kernel_A = 4'd2;
parameter caseA = 4'd3;
parameter kernel_B = 4'd4;
parameter caseB = 4'd5;
parameter kernel_C = 4'd6;
parameter caseC = 4'd7;
parameter kernel_D = 4'd8;
parameter caseD = 4'd9;
parameter Done = 4'd10;
integer i;

reg[3:0]cs,ns;
reg[13:0]pattern_cnt,kernel_read_addr;
reg[6:0]row_cnt;
reg[4:0]kernel_cnt;
reg[7:0]kernel [24:0];

always @(posedge clk or posedge reset) 
if(reset)
    cs <= 4'd0;
else
    cs <= ns;

always@(*)
case(cs)
    Init:       ns = (in_en)? Store_data : Init;
    Store_data: ns = (pattern_cnt == 14'd16383)? kernel_A : Store_data;
    kernel_A:   ns = (kernel_cnt == 5'd24)? caseA : kernel_A;
    caseA:      ns = kernel_B;
    kernel_B:   ns = (kernel_cnt == 5'd24)? caseB : kernel_B;
    caseB:      ns = (row_cnt == 7'd127)? kernel_C : kernel_A;
    kernel_C:   ns = (kernel_cnt == 5'd24)? caseC : kernel_C;
    caseC:      ns = kernel_D;
    kernel_D:   ns = (kernel_cnt == 5'd24)? caseD : kernel_D;
    caseD:      ns = (pattern_cnt == 14'd16383)? Done : (row_cnt == 7'd127)? kernel_A : kernel_C;
    Done:       ns = Init;
    default:    ns = Init;
endcase

always@(posedge clk or posedge reset)
if(reset)
    begin
        pattern_cnt <= 14'd0; 
        row_cnt <= 7'd0;
        kernel_cnt <= 5'd0;
        for(i=0;i<25;i=i+1)
            kernel[i] <= 8'd0;
        kernel_read_addr <= 14'd0;
    end
else
    case(cs)
        Init:
            begin
                pattern_cnt <= 14'd0; 
                row_cnt <= 7'd0;
                kernel_cnt <= 5'd0;
                for(i=0;i<25;i=i+1)
                    kernel[i] <= 8'd0;
                kernel_read_addr <= 14'd0;
            end
        Store_data:
            begin
                pattern_cnt <= (pattern_cnt == 14'd16383)? 14'd0 : pattern_cnt + 14'd1;
                kernel_read_addr <= (pattern_cnt == 14'd16383)? pattern_cnt - 14'd258 : 14'd0;
            end
        kernel_A:
            begin
                kernel_cnt <= (kernel_cnt == 5'd24)? 5'd0 : kernel_cnt + 5'd1;
                kernel[kernel_cnt] <= ((kernel_cnt==5'd7)||(kernel_cnt==5'd17))? rdata_b : ((kernel_cnt==5'd11)||(kernel_cnt==5'd13))? rdata_r : rdata_g;
                kernel_read_addr <=  (kernel_cnt==5'd24)? pattern_cnt - 14'd257 : (kernel_cnt==5'd4 || kernel_cnt==5'd9 || kernel_cnt==5'd14 || kernel_cnt==5'd19)? kernel_read_addr +  14'd124 : kernel_read_addr + 14'd1;
            end
        caseA:
            begin
                row_cnt <= row_cnt + 7'd1;
                pattern_cnt <= pattern_cnt + 14'd1;
            end
        kernel_B:
            begin
                kernel_cnt <= (kernel_cnt == 5'd24)? 5'd0 : kernel_cnt + 5'd1;
                kernel[kernel_cnt] <= ((kernel_cnt==5'd6)||(kernel_cnt==5'd8)||(kernel_cnt==5'd16)||(kernel_cnt==5'd18))? rdata_b :
                                      ((kernel_cnt==5'd7)||(kernel_cnt==5'd11)||(kernel_cnt==5'd13)||(kernel_cnt==5'd17))? rdata_g : rdata_r;
                kernel_read_addr <=  (kernel_cnt==5'd24)? pattern_cnt - 14'd257 : (kernel_cnt==5'd4 || kernel_cnt==5'd9 || kernel_cnt==5'd14 || kernel_cnt==5'd19)? kernel_read_addr +  14'd124 : kernel_read_addr + 14'd1;
            end
        caseB:   
            begin
                row_cnt <= (row_cnt == 7'd127)? 7'd0 : row_cnt + 7'd1;
                pattern_cnt <= pattern_cnt + 14'd1;
            end
        kernel_C:
            begin
                kernel_cnt <= (kernel_cnt == 5'd24)? 5'd0 : kernel_cnt + 5'd1;
                kernel[kernel_cnt] <= ((kernel_cnt==5'd6)||(kernel_cnt==5'd8)||(kernel_cnt==5'd16)||(kernel_cnt==5'd18))? rdata_r :
                                      ((kernel_cnt==5'd7)||(kernel_cnt==5'd11)||(kernel_cnt==5'd13)||(kernel_cnt==5'd17))? rdata_g : rdata_b;
                kernel_read_addr <=  (kernel_cnt==5'd24)? pattern_cnt - 14'd257 : (kernel_cnt==5'd4 || kernel_cnt==5'd9 || kernel_cnt==5'd14 || kernel_cnt==5'd19)? kernel_read_addr +  14'd124 : kernel_read_addr + 14'd1;
            end
        caseC: 
            begin
                row_cnt <= row_cnt + 7'd1;
                pattern_cnt <= pattern_cnt + 14'd1;
            end  
        kernel_D:
            begin
                kernel_cnt <= (kernel_cnt == 5'd24)? 5'd0 : kernel_cnt + 5'd1;
                kernel[kernel_cnt] <= ((kernel_cnt==5'd11)||(kernel_cnt==5'd13))? rdata_b : ((kernel_cnt==5'd7)||(kernel_cnt==5'd17))? rdata_r : rdata_g;
                kernel_read_addr <=  (kernel_cnt==5'd24)? pattern_cnt - 14'd257 : (kernel_cnt==5'd4 || kernel_cnt==5'd9 || kernel_cnt==5'd14 || kernel_cnt==5'd19)? kernel_read_addr +  14'd124 : kernel_read_addr + 14'd1;
            end
        caseD: 
            begin
                row_cnt <= (row_cnt == 7'd127)? 7'd0 : row_cnt + 7'd1;
                pattern_cnt <= pattern_cnt + 14'd1;
            end  
        default:
            begin
                pattern_cnt <= 14'd0; 
                row_cnt <= 7'd0;
                kernel_cnt <= 5'd0;
                for(i=0;i<25;i=i+1)
                    kernel[i] <= 8'd0;
                kernel_read_addr <= 14'd0;
            end
    endcase
//---------------------------------------------------------------------------------------
assign wr_r = (cs == Store_data) || (cs == caseA) || (cs == caseC) || (cs == caseD);
assign wr_g = (cs == Store_data) || (cs == caseB) || (cs == caseC);
assign wr_b = (cs == Store_data) || (cs == caseA) || (cs == caseB) || (cs == caseD);

wire[17:0]sum1,sum2,sum3,sum4,sum5,sum6,sum7,sum8;

assign sum1 = ((kernel[2]) + (kernel[11]<<3) + ((kernel[12]<<3) + (kernel[12]<<1)) + (kernel[13]<<3) + (kernel[22]));
assign sum2 = ((kernel[6]+kernel[8]+kernel[10]+kernel[14]+kernel[16]+kernel[18])<<1);

assign sum3 = ((kernel[6]<<2) + (kernel[8]<<2) + ((kernel[12]<<3)+(kernel[12]<<2)) + (kernel[16]<<2) + (kernel[18]<<2));
assign sum4 = (((kernel[2]+kernel[10]+kernel[14]+kernel[22])<<1) + (kernel[2]+kernel[10]+kernel[14]+kernel[22]));

assign sum5 = ((kernel[7]<<3) + (kernel[10]) + ((kernel[12]<<3)+(kernel[12]<<1)) + (kernel[14]) + (kernel[17]<<3));
assign sum6 = ((kernel[2]+kernel[6]+kernel[8]+kernel[16]+kernel[18]+kernel[22])<<1);

assign sum7 = ((kernel[7]<<1) + (kernel[11]<<1) + (kernel[12]<<2) + (kernel[13]<<1) + (kernel[17]<<1));
assign sum8 = (kernel[2]+kernel[10]+kernel[14]+kernel[22]);


wire[17:0]cal_num1,cal_num2,cal_num3,cal_num4; //avoid overflow  
wire[17:0]cal_num11,cal_num22,cal_num33,cal_num44; //avoid overflow  

assign cal_num11 = (sum1 < sum2)? 18'd0 : (sum1 - sum2) >> 4;
assign cal_num22 = (sum3 < sum4)? 18'd0 : (sum3 - sum4) >> 4;
assign cal_num33 = (sum5 < sum6)? 18'd0 : (sum5 - sum6) >> 4;
assign cal_num44 = (sum7 < sum8)? 18'd0 : (sum7 - sum8) >> 3;  

assign cal_num1 =  (cal_num11>=18'd255)? 18'd255 : cal_num11;
assign cal_num2 =  (cal_num22>=18'd255)? 18'd255 : cal_num22;
assign cal_num3 =  (cal_num33>=18'd255)? 18'd255 : cal_num33;
assign cal_num4 =  (cal_num44>=18'd255)? 18'd255 : cal_num44;

always@(*)
if(cs == Store_data)
    wdata_r = data_in; 
else if(cs == caseA)
    wdata_r = cal_num1[7:0];
else if(cs == caseC)
    wdata_r = cal_num2[7:0];
else if(cs == caseD)
    wdata_r = cal_num3[7:0];
else
    wdata_r = 8'd0;

always@(*)
if(cs == Store_data)
    wdata_g = data_in; 
else if((cs == caseB) || (cs == caseC))
    wdata_g = cal_num4[7:0];
else 
    wdata_g = 8'd0;

always@(*)
if(cs == Store_data)
    wdata_b = data_in; 
else if(cs == caseA)
    wdata_b = cal_num3[7:0];
else if(cs == caseB)
    wdata_b = cal_num2[7:0];
else if(cs == caseD)
    wdata_b = cal_num1[7:0];
else 
    wdata_b = 8'd0;
//-----------------------------------------------------------------------------------

always@(*)
if(cs == Store_data)
    addr_r = pattern_cnt;
else if((cs == kernel_A) || (cs == kernel_B) || (cs == kernel_C) || (cs == kernel_D))
    addr_r = kernel_read_addr;
else if((cs == caseA) || (cs == caseC) || (cs == caseD))
    addr_r = pattern_cnt;
else
    addr_r = 14'd0;

always@(*)
if(cs == Store_data)
    addr_g = pattern_cnt;
else if((cs == kernel_A) || (cs == kernel_B) || (cs == kernel_C) || (cs == kernel_D))
    addr_g = kernel_read_addr;
else if((cs == caseB) || (cs == caseC))
    addr_g = pattern_cnt;
else
    addr_g = 14'd0;

always@(*)
if(cs == Store_data)
    addr_b = pattern_cnt;
else if((cs == kernel_A) || (cs == kernel_B) || (cs == kernel_C) || (cs == kernel_D))
    addr_b = kernel_read_addr;
else if((cs == caseA) || (cs == caseB) || (cs == caseD))
    addr_b = pattern_cnt;
else
    addr_b = 14'd0;


assign done = (cs==Done);

endmodule


