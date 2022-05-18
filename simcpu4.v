module simcpu;
reg CK, RST;
wire RW;
wire [15:0] IA, DA, DD;
reg [15:0] ID, DDi;
reg [15:0] IMEM [0:127], DMEM[0:127];

	CPU c(CK,RST,IA,ID,DA,DD,RW);

   assign DD = ((RW == 1) ? DDi : 'b Z);

initial begin
   $dumpfile("simcpu4.vcd");
   $dumpvars;
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
    DMEM[0]=    5;
    DMEM[1]=    50;

    IMEM[0]=	'b 1100_0001_0000_0000;	
    IMEM[1]=	'b 1100_0100_0000_1111; 
    IMEM[2]=	'b 1100_0101_0000_0001; 
    IMEM[3]=	'b 0011_0101_0101_0100; 
    IMEM[4]=	'b 1100_0100_0000_0001; 
    IMEM[5]=	'b 1100_1001_0000_0000; 
    IMEM[6]=	'b 1100_1010_0000_0001;
    IMEM[7]=	'b 1100_1011_0000_0010;
    IMEM[8]=	'b 1100_0110_0001_0001;
    IMEM[9]=	'b 1100_0111_0001_0100;
    IMEM[10]=	'b 1100_1000_0000_1101;
    IMEM[11]=	'b 1011_0010_0000_1001;
    IMEM[12]=	'b 1011_0011_0000_1010;
    IMEM[13]=	'b 0011_0001_0001_0100;
    IMEM[14]=	'b 0101_0000_0101_0011;
    IMEM[15]=	'b 1001_0000_0101_0011;
    IMEM[16]=	'b 0000_0001_0001_0010;
    IMEM[17]=	'b 0010_0101_0101_0100;
    IMEM[18]=	'b 1001_0000_0000_0111;
    IMEM[19]=	'b 1000_0000_0000_1000;
    IMEM[20]=	'b 1010_0000_0001_1011;
end

always #10 CK = ~CK;

endmodule