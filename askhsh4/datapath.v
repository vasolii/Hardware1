`include "../askhsh1/alu.v"
`include "../askhsh3/regfile.v"

module datapath
#(parameter [31:0] INITIAL_PC=32'h00400000)
(input wire clk,rst,PCSrc,ALUSrc,RegWrite,MemToReg,loadPC, input wire[31:0] instr,dReadData, input wire[3:0] ALUCtrl,
output wire[31:0] dAddress, dWriteData,WriteBackData, output wire Zero,output reg [31:0] PC);

//Register File
wire [31:0] write_back_mux;
wire [31:0] op1_readdata1,op2_readdata2;
regfile u1(.readReg1(instr[19:15]),.readReg2(instr[24:20]),.writeReg(instr[11:7]),.write(RegWrite),
.readData1(op1_readdata1),.readData2(op2_readdata2),.writeData(write_back_mux),.clk(clk));

//Immediate Generation for immediate(addi)
wire [11:0] input_imm_gen_addi;
assign input_imm_gen_addi=instr[31:20];
wire [31:0] signed_output_imm_gen_addi;
assign signed_output_imm_gen_addi={{20{input_imm_gen_addi[11]}},input_imm_gen_addi};

//Immediate Generation for store(sw)
wire [11:0] input_imm_gen_sw;
assign input_imm_gen_sw={instr[31:25],instr[11:7]};
wire [31:0] signed_output_imm_gen_sw;
assign signed_output_imm_gen_sw={{20{input_imm_gen_sw[11]}},input_imm_gen_sw};

//Immediate Generation for branch(beq)
wire [11:0] input_imm_gen_beq;
assign input_imm_gen_beq={instr[31],instr[7],instr[30:25],instr[11:8]};
wire [31:0] signed_output_imm_gen_beq;
assign signed_output_imm_gen_beq={{19{input_imm_gen_beq[11]}},input_imm_gen_beq,1'b0};

//MUX for choosing command type (S or I)
wire [31:0] signed_output_imm_gen;
assign signed_output_imm_gen=(instr[6:0]==7'b0100011)?signed_output_imm_gen_sw:signed_output_imm_gen_addi;

//MUX
wire [31:0] mux_result_op2;  
assign mux_result_op2= ALUSrc ? signed_output_imm_gen :op2_readdata2;

//ALU
wire [31:0] alu_result;
alu u2(.op1(op1_readdata1),.op2(mux_result_op2),.alu_op(ALUCtrl),.result(alu_result),.zero(Zero));

//Branch Target
wire [31:0] left_input_add,sum_pc_immgen;
assign left_input_add=signed_output_imm_gen_beq<<1;
assign sum_pc_immgen=left_input_add+PC;

//Write Back -MUX
assign write_back_mux= MemToReg ? dReadData : alu_result;

//Outputs
assign WriteBackData=write_back_mux;
assign dWriteData=op2_readdata2;
assign dAddress=alu_result;

//PC
always @(posedge clk)
begin
    if (rst)
        PC<=INITIAL_PC;
    else if (loadPC)begin
        if (PCSrc)
            PC<=sum_pc_immgen;            
        else 
            PC<=PC+4;
    end            
end    
endmodule