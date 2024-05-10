`include "../askhsh4/datapath.v"

module top_proc
    #(parameter [31:0] INITIAL_PC=32'h00400000)
    (input wire clk,rst,input wire [31:0] instr,dReadData,
    output wire [31:0] dAddress,dWriteData,WriteBackData,PC, output reg MemRead,MemWrite);
    
    // FSM
    reg [4:0] current_state, next_state;
    parameter [4:0]  IF=5'b00001, ID=5'b00010, EX=5'b00100, MEM=5'b01000, WB=5'b10000;
   
    //Procedural Block for State Memory
    always @(posedge clk) // ακολουθιακό για αυτό μπαίνει το clk
    begin: STATE_MEMORY
        if (rst)
            current_state<=IF;
        else
            current_state<=next_state;    
    end    
    
    //Procedural Block for Next State
    always @(current_state) // πρέπει να είναι συνδιαστικό (όχι μνήμη) άρα όχι clk
    begin: NEXT_STATE_LOGIC
    case (current_state)
    IF: next_state=ID;
    ID: next_state=EX;
    EX: next_state=MEM;
    MEM:next_state=WB;
    WB: next_state=IF;
    default: next_state=IF;     
    endcase 
    end 

    //Procedural Block for Outputs
    wire zero;
    reg loadPC,RegWrite,PCSrc,MemToReg;
    always @(current_state)
    begin:OUTPUT_LOGIC
    case (current_state)
    IF: begin
        loadPC<=0;
        RegWrite<=0;
        PCSrc<=0;
        MemToReg<=0;
    end
    ID:begin end
    EX:begin end
    MEM:begin
        if (instr[6:0]==7'b0100011) //SW
            MemWrite<=1;
        else if (instr[6:0]==7'b0000011) //LW
            MemRead<=1;
    end       
    WB:begin
        if (instr[6:0]==7'b1100011 || instr[6:0]==7'b0100011) //BEQ and SW
            RegWrite<=0;
        else RegWrite<=1;    
        loadPC<=1;
        MemRead<=0;
        MemWrite<=0;  
        if (instr[6:0]==7'b0000011) //LW
            MemToReg<=1;
        else MemToReg<=0;    
        if (instr[6:0]==7'b1100011 && zero==1) //BEQ   
            PCSrc<=1;       
    end    
    endcase
    end 

    //ALUCtrl
    reg [3:0] ALUCtrl;
    always @(instr)begin
        if (instr[6:0]==7'b1100011) //BEQ (-)
            ALUCtrl=4'b0110;
        else if (instr[6:0]==7'b0000011) //LW (+)
            ALUCtrl=4'b0010; 
        else if (instr[6:0]==7'b0100011)  //SW(+)
            ALUCtrl=4'b0010;
        else if (instr[6:0]==7'b0010011)begin
            if (instr[14:12]==3'b111) //ANDI
                ALUCtrl=4'b0000;
            else if (instr[14:12]==3'b110)  //ORI
                ALUCtrl=4'b0001;
            else if (instr[14:12]==3'b000) //ADDI
                ALUCtrl=4'b0010;
            else if (instr[14:12]==3'b010)  //SLTI
                ALUCtrl=4'b0111;
            else if (instr[14:12]==3'b100)  //XORI  
                ALUCtrl=4'b1101;
            else if (instr[14:12]==3'b001)  //SLLI  
                ALUCtrl=4'b1001;
            else if (instr[14:12]==3'b101) begin  
                if (instr[31:25]==7'b0000000) //SRLI 
                    ALUCtrl=4'b1000;
                else if (instr[31:25]==7'b0100000) //SRAI
                    ALUCtrl=4'b1010;
            end
        end    
        else if (instr[6:0]==7'b0110011) begin
                if (instr[14:12]==3'b000) begin  
                    if (instr[31:25]==7'b0000000) //ADD
                       ALUCtrl=4'b0010;
                    else if (instr[31:25]==7'b0100000) //SUB
                       ALUCtrl=4'b0110;    
                end 
                else if (instr[14:12]==3'b001)  //SLL 
                    ALUCtrl=4'b1001;
                else if (instr[14:12]==3'b010)  //SLT
                    ALUCtrl=4'b0111;
                else if (instr[14:12]==3'b100) //XOR
                    ALUCtrl=4'b1101;  
                else if (instr[14:12]==3'b101) begin
                    if (instr[31:25]==7'b0000000)//SRL
                        ALUCtrl=4'b1000;
                    else if (instr[31:25]==7'b0100000) //SRA   
                        ALUCtrl=4'b1010; 
                end         
                else if (instr[14:12]==3'b110) //OR
                    ALUCtrl=4'b0001;
                else if (instr[14:12]==3'b111) //AND
                    ALUCtrl=4'b0000;  
        end
        end  

    //ALUsrc
    wire ALUSrc; 
    assign ALUSrc=(instr[5]==1'b0 || instr[6:0]==7'b0100011)?1:0;     

    //Datapath  
    datapath    #(.INITIAL_PC(INITIAL_PC))
                u3(.PC(PC),.instr(instr),.dAddress(dAddress),.dReadData(dReadData),.dWriteData(dWriteData),
                .ALUCtrl(ALUCtrl),.ALUSrc(ALUSrc),.Zero(zero),.loadPC(loadPC),.clk(clk),.rst(rst),.PCSrc(PCSrc),
                .RegWrite(RegWrite),.MemToReg(MemToReg),.WriteBackData(WriteBackData));
    

endmodule