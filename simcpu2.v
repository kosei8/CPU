module simcpu;
reg CK, RST;
wire RW;
wire [15:0] IA, DA, DD;
reg [15:0] ID, DDi;
reg [15:0] IMEM [0:127], DMEM[0:127];

	CPU c(CK,RST,IA,ID,DA,DD,RW);

   assign DD = ((RW == 1) ? DDi : 'b Z);

initial begin
	CK = 0;
	RST = 0;
#5	RST = 1;
#100	RST = 0;
	
        #10000 $finish;
end

always @(negedge CK) begin
   if( DA == 'b 0 && DD == 'b 0100 && RW == 0 ) begin
      $display( "OK" );
      $finish;
   end
end

always @(negedge CK) begin
	ID = IMEM[IA];
end

always @(negedge CK) begin
   if( RW == 1 ) DDi = DMEM[DA];
   else DMEM[DA] = DD;
end

initial begin
   IMEM[0]=	'b 1100_0000_0000_0000;	// IMM  R0, [0]
   IMEM[1]=	'b 1100_0001_0000_0001; // IMM  R1, [1]
   IMEM[2]=	'b 1100_0010_0000_0010; // IMM  R2, [2]
   IMEM[3]=	'b 1100_0011_0000_0011; // IMM  R3, [3]
   IMEM[4]=	'b 1100_0100_0000_0100; // IMM  R4, [4]
   IMEM[5]=	'b 0000_0101_0001_0011; // ADD  R5, R1, R3
   IMEM[6]=	'b 1010_0000_0101_0000; // ST  R5, R0
end

always #10 CK = ~CK;

endmodule