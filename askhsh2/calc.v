`include  "../askhsh1/alu.v"
`include "calc_enc.v"

module calc
(input wire clk, btnc, btnl, btnu, btnr, btnd, input wire signed[15:0] sw, output reg [15:0] led);
reg [15:0] accumulator;

reg signed [31:0] signal_op1,signal_op2;
wire [3:0] n;
wire [31:0] n1;

alu Ua(.op1(signal_op1),.op2(signal_op2),.result(n1),.alu_op(n));
calc_enc Uf(.A(btnr),.B(btnl),.C(btnc),.AL(n));

always @(sw or accumulator)
begin
    signal_op2 = {{16{sw[15]}}, sw};
    signal_op1 = {{16{accumulator[15]}}, accumulator};
end  

always @(posedge btnd or posedge clk  or posedge btnu) 
begin 
    if (btnu) begin
        accumulator=16'b0;
        led=accumulator;
    end
    else if (btnd) begin
        accumulator=n1[15:0]; 
        led=accumulator;
    end
    else
        led=accumulator;       
        
end

endmodule