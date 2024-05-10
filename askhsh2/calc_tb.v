`include "calc.v"
`timescale 1ns/1ps  // Adjust the timescale as needed

module calc_tb;

  // Inputs
  reg clk;
  reg btnc, btnl, btnu, btnr, btnd;
  reg signed [15:0] sw;

  // Outputs
  wire [15:0] led;

  // Instantiate the calc module
  calc uut (
    .clk(clk),
    .btnc(btnc),
    .btnl(btnl),
    .btnu(btnu),
    .btnr(btnr),
    .btnd(btnd),
    .sw(sw),
    .led(led)
  );

  //Clock generation
  initial
  begin
    clk = 1'b0;
    btnd= 1'b0;
  end
  always
  begin
    #10 clk = ~clk;
    btnd = ~btnd;
  end

  // Stimulus generation
  initial 
  begin
    $dumpfile("calc_tb.vcd");
    $dumpvars(0,calc_tb);

    // Test cases
    // Reset
    btnu = 1;
    #20;
    btnu = 0;

    //OR
    btnl = 0;
    btnc = 1;
    btnr = 1;
    sw=16'h1234;
    #20;

    //AND
    btnl = 0;
    btnc = 1;
    btnr = 0;
    sw=16'h0ff0;
    #20; 

    //ADD
    btnl = 0;
    btnc = 0;
    btnr = 0;
    sw=16'h324f;
    #20; 

    //SUB
    btnl = 0;
    btnc = 0;
    btnr = 1;
    sw=16'h2d31;
    #20;

    //XOR
    btnl = 1;
    btnc = 0;
    btnr = 0;
    sw=16'hffff;
    #20;

    //Less Than
    btnl = 1;
    btnc = 0;
    btnr = 1;
    sw=16'h7346;
    #20;

    //Shift Left Logical
    btnl = 1;
    btnc = 1;
    btnr = 0;
    sw=16'h0004;
    #20;

    //Shift Right Arithmetic
    btnl = 1;
    btnc = 1;
    btnr = 1;
    sw=16'h0004;
    #20;

    //Less Than
    btnl = 1;
    btnc = 0;
    btnr = 1;
    sw=16'hffff;
    #20;

    $finish;

  end

endmodule
