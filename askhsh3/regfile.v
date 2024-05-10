module regfile
    (input wire clk,write, input wire[4:0] readReg1,readReg2,writeReg,input wire[31:0] writeData,
    output reg[31:0]readData1,readData2);

    reg [31:0] reg_table [31:0];
    integer i;

    initial 
    begin
        for (i=0; i<32; i=i+1)
        reg_table[i]=0;
    end    

    always @(posedge clk)
    begin
    readData1 <= reg_table[readReg1];
    readData2 <= reg_table[readReg2];
    if (write) 
    begin
        reg_table[writeReg] <= writeData;
    end
    end

endmodule