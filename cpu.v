module CPU(CK,RST,IA,ID,DA,DD,RW);
input CK,RST;
input [15:0] ID;
inout [15:0] DD;
output RW;
output [15:0] IA,DA;

reg [1:0] STAGE;
reg [15:0] RF [0:14];
reg [15:0] INST, PC, FUA, FUB, FUC, LSUA, LSUB, LSUC, PCC, PCI;
reg FLAG, RW;
wire [3:0] OPCODE, OPR1, OPR2, OPR3;
wire [7:0] IMM;
wire [15:0] ABUS, BBUS, CBUS;
wire [15:0] PCn;
wire [15:0] RF01, RF05;

assign PCn = PC +1; 
assign RF01 = RF[1];
assign RF05 = RF[5];
assign IA = PC;
assign OPCODE = INST[15:12];
assign OPR1 = INST[11:8];
assign OPR2 = INST[7:4];
assign OPR3 = INST[3:0];
assign IMM = INST[7:0];
assign ABUS = (OPR2 == 0 ? 0:RF[OPR2]);
assign BBUS = (OPR3 == 0 ? 0:RF[OPR3]);
assign DD = (RW==0 ? LSUA:16'bZ);
assign DA = LSUB;
assign CBUS = (OPCODE[3]==0 ? FUC:(OPCODE[3:1]=='b101 ? LSUC:
(OPCODE=='b1100 ? {8'b 0, IMM}:OPCODE=='b1000 ? PCC:'bZ)));

always@(posedge CK)begin
    if(RST==1) begin
        PC <= 0;
        STAGE <= 0;
        RW <= 1;
    end else begin 
        if(STAGE==0)begin
            INST <= ID;
            STAGE<=1;
        end else if(STAGE==1)begin
            if(OPCODE[3]==0)begin
                FUA <= ABUS;
                FUB <= BBUS;
            end
            if(OPCODE[2:1]=='b01)begin
                LSUA <= ABUS;
                LSUB <= BBUS;
            end
            if(OPCODE[3:0]=='b1000 || (OPCODE[3:0]=='b1001 && FLAG ==1))begin
                PCI <= BBUS;
            end else begin
                // PCI <= PC +1;
                PCI <= PCn;
            end
            STAGE<=2;
        end else if(STAGE==2)begin
            if(OPCODE[3]==0)begin
                case(OPCODE[2:0])
                'b000:FUC <= FUA + FUB;
                'b001:FUC <= FUA - FUB;
                'b010:FUC <= FUA >> FUB;
                'b011:FUC <= FUA << FUB;
                'b100:FUC <= FUA | FUB;
                'b101:FUC <= FUA & FUB;
                'b110:FUC <= ~FUA;
                'b111:FUC <= FUA ^ FUB;
                endcase
            end else if(OPCODE[3:1]=='b101)begin
                if(OPCODE[0]==0)begin
                    RW <= 0;
                end else begin
                    RW <= 1;
                    LSUC <= DD;
                end
            end else if(OPCODE[3:0]=='b1000)begin
                // PCC <= PC +1;
                PCC <= PCn;
            end
            STAGE<=3;
        end else if(STAGE==3)begin
            RF[OPR1] <= CBUS;
            PC <= PCI;
            RW <= 1;
            if(OPCODE[3]==0)begin
                if(CBUS==0)FLAG<=1;
                else FLAG<=0;
            end
            STAGE<=0;
        end
    end
end
endmodule

