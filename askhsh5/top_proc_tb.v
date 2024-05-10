`include "top_proc.v"
`include "ram.v"
`include "rom.v"
`timescale 1ns/1ns  // Adjust the timescale as needed

module top_proc_tb;
reg clk,rst;
wire [31:0]instruction;
wire [31:0]addressrom, addressram,writedata;
wire [8:0] addressrom9bits, addressram9bits;
wire [31:0] dReadData,WriteBackData,PC;
wire MemRead,MemWrite;

//to we einai asos otan grafoume sthn mnhmh

top_proc umul(.clk(clk),.instr(instruction),.PC(addressrom), //for rom
                .dAddress(addressram),.dWriteData(writedata),.dReadData(dReadData),   //for ram
                .rst(rst),.WriteBackData(WriteBackData), //everything else
                .MemRead(MemRead),.MemWrite(MemWrite));  


assign addressrom9bits=addressrom[8:0];
assign addressram9bits=addressram[8:0];

INSTRUCTION_MEMORY urom(.clk(clk),.dout(instruction),.addr(addressrom9bits));
DATA_MEMORY uram(.clk(clk),.addr(addressram9bits),.din(writedata),.dout(dReadData),.we(MemWrite));

//clock generation
initial
begin
    clk=1'b0;
end
always 
begin
  #10 clk = ~clk;
end

// Stimulus generation
initial 
begin
    $dumpfile("top_proc_tb.vcd");
    $dumpvars(0,top_proc_tb);
    
    rst=1;
    #20
    rst=0;
    //512/4=128 entoles
    //128 *5 =640 clocks
    //640 * 20 (xronos 1 clk) =12800
    #12600;
    $finish;
end   
endmodule
