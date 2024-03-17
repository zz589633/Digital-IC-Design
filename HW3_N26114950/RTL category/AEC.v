module AEC(clk, rst, ascii_in, ready, valid, result);

// Input signal
input clk;
input rst;
input ready;
input [7:0] ascii_in;

// Output signal
output valid;
output [6:0] result;

reg [1:0] cs,ns;
reg [7:0] Postfix [15:0];
reg [7:0] Stack [7:0];

reg [3:0] Post_ptr;
reg [2:0] Stack_ptr;
reg [3:0] Cal_ptr;

reg [7:0] num_in;
wire is_num;
wire is_operand;
wire not_parenthesis;
wire left_parenthesis,right_parenthesis;
wire stack_push,stack_push_2;
wire countable;
wire [7:0] Stack_ptr_nof,Stack_ptr_nof_2;
integer i;

assign Stack_ptr_nof = (Stack_ptr == 8'd0)? 8'd0 : Stack_ptr - 8'd1 ; 
assign Stack_ptr_nof_2 = (Stack_ptr < 8'd2)? 8'd0 : Stack_ptr - 8'd2;

assign is_num = ((ascii_in > 8'd47)&&(ascii_in < 8'd58)) || ((ascii_in > 8'd96)&&(ascii_in < 8'd103));
assign is_operand = (ascii_in > 8'd39) && (ascii_in < 8'd46);
assign not_parenthesis = (Stack[Stack_ptr_nof] != 8'd40) && (Stack[Stack_ptr_nof] != 8'd41);
assign left_parenthesis = (Stack[Stack_ptr_nof] == 8'd40);
assign right_parenthesis = (ascii_in == 8'd41);
assign stack_push =(((ascii_in == 8'd43)||(ascii_in == 8'd45)) && (Stack[Stack_ptr_nof] == 8'd42))
                  ||((ascii_in == Stack[Stack_ptr_nof]) && (ascii_in != 8'd40))
                  ||((ascii_in == 8'd43 && Stack[Stack_ptr_nof] == 8'd45) || (ascii_in == 8'd45 && Stack[Stack_ptr_nof] == 8'd43));

assign stack_push_2 = ((ascii_in == 8'd43)||(ascii_in == 8'd45)) && (Stack[Stack_ptr_nof] == 8'd42) && (Stack_ptr >= 8'd2) && (Stack[Stack_ptr_nof_2]==8'd43 || Stack[Stack_ptr_nof_2]==8'd45);
assign countable = (Postfix[Cal_ptr] == 8'd42)||(Postfix[Cal_ptr] == 8'd43)||(Postfix[Cal_ptr] == 8'd45);

always@(posedge clk or posedge rst)   
begin 
    if(rst)
        cs <= 2'd0;
    else
        cs <= ns;
end
 
always@(*)
begin 
    case(cs)
        2'd0: ns = (ready)? 2'd1 : 2'd0;
        2'd1: ns = (ascii_in==8'd61)? 2'd2 : 2'd1;
        2'd2: ns = (Stack_ptr==4'd0)? 2'd3 : 2'd2;
        2'd3: ns = (Cal_ptr == Post_ptr)? 2'd0 : 2'd3;
    endcase
end 

always@(*) 
begin
    case(ascii_in)
        8'd48:  num_in = 8'd0;
        8'd49:  num_in = 8'd1; 
        8'd50:  num_in = 8'd2;
        8'd51:  num_in = 8'd3;
        8'd52:  num_in = 8'd4;
        8'd53:  num_in = 8'd5;
        8'd54:  num_in = 8'd6;
        8'd55:  num_in = 8'd7;
        8'd56:  num_in = 8'd8;
        8'd57:  num_in = 8'd9;
        8'd97:  num_in = 8'd10;
        8'd98:  num_in = 8'd11;
        8'd99:  num_in = 8'd12;
        8'd100: num_in = 8'd13;
        8'd101: num_in = 8'd14;
        8'd102: num_in = 8'd15;
        default:num_in = 8'd0; 
    endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst) begin
        for(i = 0; i < 16 ; i = i+1)
            Postfix[i] <= 8'd0;
        end
    else if(valid) begin
        for(i = 0; i < 16 ; i = i+1)
            Postfix[i] <= 8'd0;
        end
    else if(cs==2'd0 && ready)
        Postfix[0] <= num_in;
    else if(cs==2'd1 && is_num)
        Postfix[Post_ptr] <= num_in;
    else if(cs==2'd1 && stack_push_2) 
    begin
        Postfix[Post_ptr] <= Stack[Stack_ptr_nof];
        Postfix[Post_ptr+1] <= Stack[Stack_ptr_nof_2];
    end
    else if(cs==2'd1 && stack_push)
        Postfix[Post_ptr] <= Stack[Stack_ptr_nof];
    else if(cs==2'd1 && right_parenthesis && !left_parenthesis)
        Postfix[Post_ptr] <= Stack[Stack_ptr_nof];
    else if(cs==2'd2 && (Stack_ptr!=4'd0) && not_parenthesis)
        Postfix[Post_ptr] <= Stack[Stack_ptr_nof];
    else
        Postfix[Post_ptr] <= Postfix[Post_ptr];
end


always@(posedge clk or posedge rst)
begin
    if(rst)
        Post_ptr <= 4'd0;
    else if(valid)
        Post_ptr <= 4'd0;
    else if(cs==2'd0 && ready && ascii_in == 8'd40)
        Post_ptr <= 4'd0;
    else if(cs==2'd0 && ready)
        Post_ptr <= Post_ptr + 4'd1;
    else if(cs==2'd1 && is_num)
        Post_ptr <= Post_ptr + 4'd1;
    else if(cs==2'd1 && stack_push_2) 
        Post_ptr <= Post_ptr + 4'd2;
    else if(cs==2'd1 && stack_push)
        Post_ptr <= Post_ptr + 4'd1;
    else if(cs==2'd1 && right_parenthesis)
        Post_ptr <= Post_ptr + 4'd1;
    else if(cs==2'd2 && (Stack_ptr!=4'd0) && not_parenthesis) 
        Post_ptr <= Post_ptr + 4'd1;
    else 
        Post_ptr <= Post_ptr;
end

always@(posedge clk or posedge rst)
begin
    if(rst) begin
        for(i = 0; i < 8 ; i = i+1)
            Stack[i] <= 8'd0;
        end
    else if(valid)begin
        for(i = 0; i < 8 ; i = i+1)
            Stack[i] <= 8'd0;
        end
    else if(cs==2'd0 && ready && ascii_in==8'd40)
        Stack[0] <= ascii_in;
    else if(cs==2'd1 && is_operand && !stack_push && !right_parenthesis) 
        Stack[Stack_ptr] <= ascii_in;
    else if(cs==2'd1 && stack_push_2) 
        Stack[0] <= ascii_in;
    else if(cs==2'd1 && is_operand && stack_push)
        Stack[Stack_ptr_nof] <= ascii_in; 
    else if(cs==2'd3 && countable==1'd0) 
        Stack[Stack_ptr] <= Postfix[Cal_ptr];
    else if(cs==2'd3 && Postfix[Cal_ptr]==8'd42)
    begin
        Stack[Stack_ptr-2] <= Stack[Stack_ptr-2] * Stack[Stack_ptr-1];
        //Stack[Stack_ptr-1] <= 8'd0;
    end
    else if(cs==2'd3 && Postfix[Cal_ptr]==8'd43) 
    begin
        Stack[Stack_ptr-2] <= Stack[Stack_ptr-2] + Stack[Stack_ptr-1];
        //Stack[Stack_ptr-1] <= 8'd0;   
    end
    else if(cs==2'd3 && Postfix[Cal_ptr]==8'd45)
    begin
        Stack[Stack_ptr-2] <= Stack[Stack_ptr-2] - Stack[Stack_ptr-1];
        //Stack[Stack_ptr-1] <= 8'd0;
    end   
    else 
        Stack[Stack_ptr] <= Stack[Stack_ptr];
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        Stack_ptr <= 3'd0;
    else if(valid)
        Stack_ptr <= 3'd0;
    else if(cs==2'd0 && ready && ascii_in ==8'd40)
        Stack_ptr <= Stack_ptr + 3'd1;
    else if(cs==2'd1 && right_parenthesis)
        Stack_ptr <= Stack_ptr_nof_2; //bug 
    else if(cs==2'd1 && stack_push_2) 
        Stack_ptr <= Stack_ptr_nof; 
    else if(cs==2'd1 && is_operand && !stack_push && !stack_push_2)
        Stack_ptr <= Stack_ptr + 3'd1;
    else if(cs==2'd2 && (Stack_ptr!=4'd0))
        Stack_ptr <= Stack_ptr_nof;
    else if(cs==2'd3 && countable==1'd0)
        Stack_ptr <= Stack_ptr + 3'd1;
    else if(cs==2'd3 && countable==1'd1)
        Stack_ptr <= Stack_ptr_nof;
    else 
        Stack_ptr <= Stack_ptr;
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        Cal_ptr <= 4'd0;
    else if(valid)
        Cal_ptr <= 4'd0;
    else if(cs==2'd3)
        Cal_ptr <= Cal_ptr + 4'd1;
    else
        Cal_ptr <= Cal_ptr;
end

assign valid = (cs == 2'd3) && (Cal_ptr == Post_ptr);
assign result = Stack[0]; 

endmodule