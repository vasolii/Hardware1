module alu

    //parameters
    #(parameter [3:0] ALUOP_AND = 4'b0000,
    ALUOP_OR = 4'b0001,
    ALUOP_ADD = 4'b0010,
    ALUOP_SUB = 4'b0110,
    ALUOP_LESS =4'b0111,
    ALUOP_L_2BITS_RIGHT = 4'b1000,
    ALUOP_L_2BITS_LEFT = 4'b1001,
    ALUOP_2BITS_RIGHT = 4'b1010,
    ALUOP_XOR = 4'b1101)
    (input wire signed [31:0] op1, op2, input wire[3:0] alu_op, output reg zero, output reg [31:0] result );

    //alu options
    always @ (*) 
    begin  
    case (alu_op)
            ALUOP_AND :  result=op1 & op2;
            ALUOP_OR :  result=op1 | op2;
            ALUOP_ADD :  result=op1 + op2;
            ALUOP_SUB :  result=op1 - op2;
            ALUOP_LESS:  result=op1 < op2;
            ALUOP_L_2BITS_RIGHT :  result=op1 >> op2[4:0];
            ALUOP_L_2BITS_LEFT :  result=op1 << op2[4:0];
            ALUOP_2BITS_RIGHT :  result=op1 >>> op2[4:0];
            ALUOP_XOR :  result=op1 ^ op2;
            default :  result=1'bz;
    endcase        
    zero = (result == 32'b0) ? 1 : 0;

    end


endmodule
