//General sizes
`define WORD    	[15:0]
`define OPcode		[15:12]
`define dest		[11:8]
`define src		[7:4]
`define alt     	[3:0]
`define imm     	[7:0]
`define OP		[4:0]

`define EN     		[31:0]
`define STATE    	[3:0]
`define REGSIZE	 	[15:0]
`define MEMSIZE 	[65535:0]
`define RETADDR    	[63:0]
`define REGNAME		[3:0]
`define ESIZE		[31:0]

//Opcodes
`define OPadd 		4'b0000
`define OPmul 		4'b0001
`define OPsll 		4'b0010
`define OPsra 		4'b0011
`define OPslt 		4'b0100
`define OPand 		4'b0101
`define OPor 		4'b0110
`define OPxor 		4'b0111
`define OPli8 		4'b1011
`define OPlu8 		4'b1100
`define OPleft		4’b1011
`define OPright		4’b1100
`define OPgor		4’b1101
`define OPSrc		4’b1000
`define OPNop		4’b1111
 

// extended Opcodes
`define OPneg 		5'b10000
`define OPlnot 		5'b10001
`define OPload 		5'b10010
`define OPstore 	5'b10011
`define OPjump 		5'b10100
`define OPcall 		5'b10101
`define OPtrap 		5'b10110
`define OPret 		5'b10111
`define OPjumpf 	5'b11000
`define OPgor		5’b11001
`define OPleft		5’b11010
`define OPright		5’b11011
`define OPallen 	5'b11100
`define OPpushen 	5'b11101
`define OPpopen 	5'b11110

//SRC values (Forwarding and Squashing)
`define SRCneg 		4'b0000
`define SRClnot 	4'b0001
`define SRCload 	4'b0010
`define SRCstore	4'b0011
`define SRCjump 	4'b0100
`define SRCcall 	4'b0101
`define SRCtrap 	4'b0110
`define SRCret 		4'b0111
`define SRCjumpf	4'b1000
`define SRCgor		4’b1001
`define SRCleft		4’b1010
`define SRCright	4’b1011
`define SRCallen 	4'b1100
`define SRCpushen 	4'b1101
`define SRCpopen 	4'b1110

-------------------------------------------------------------------------------------------------------------------------------
module decode(out, regd, in, ireg);
output reg `OPcode out;
output reg `REGNAME regd;
input wire `OPcode in;
input `WORD ireg;

always @(in, ireg) begin
	if((in == `OPjumpf) || (in == `OPjump) || (in == `OPcall)) begin
		out = `OPNop;  // 2nd word of li becomes nop
		regd = 0;           // No writing will occur
	end else begin
		case (ireg `OPcode)
		`OPsrc: begin
regd = 0;
// Assign 5 bit state value based on 4 bit source value
case(ir `dest)
	`SRCneg: 	out = `OPneg;
`SRClnot: 		out = `OPlnot;
`SRCload: 		out = `OPload;
`SRCstore: 		out = `OPstore;
`SRCjump: 		out = `OPjump;
`SRCcall: 		out = `OPcall;
`SRCtrap: 		out = `OPtrap;
`SRCret: 		out = `OPret;
`SRCjumpf: 		out = `OPjumpf;;
`SRCallen: 		out = `OPallen;
`SRCpushen: 	out = `OPpushen;
`SRCpopen: 		out = `OPpopen;
endcase
end
default: begin out = ireg `OPcode; regd <= ireg `Dest; end
	endcase
----------------------------------------------------------------------------------------------------------------------------

// ALU module
module alu(result, OPcode, in1, in2);
output reg `WORD result;
input wire `OPcode opcodes;
input wire `WORD in1, in2;

// Instruction cases 
always @(opcodes, in1, in2) begin
  case (opcodes)
	`OPadd: begin result = in1 + in2; end
	`OPand: begin result = in1 & in2; end
	`OPmul: begin result = in1 * in2; end
	`OPor: begin result = in1 | in2; end
	`OPlnot: begin result = !in1; end
	`OPneg: begin result = ~in1; end
`OPleft: begin result = in2; end
	`OPright: begin result = in2; end
	`OPgor: begin result = in2; end 
	`OPxor: begin result = in1 ^ in2; end
	`OPsll: begin result = in1 << (in2 & 4’b1111); end 
	`OPsra: begin result = in1 >>> (in2 & 4’b1111); end
	`OPslt: begin result = (in1 < in2)? 4’b1 : 4’b0; end
	default: begin result = in1; end
  endcase
end
endmodule
----------------------------------------------------------------------------------------------------------------------------

module processor(halt, reset, clk);
output reg halt;
input reset, clk;

reg `WORD regfile `REGSIZE;
reg `WORD mainmem `MEMSIZE;
reg `WORD inst [65535:0];
reg `WORD data [65535:0];
reg `WORD PC;
reg `WORD ir, srcval, dstval, newpc;
reg `WORD s1srcval, s1dstval;
reg `WORD s2val;

reg ifsquash, rrsquash;

wire `OP decOP;
wire `REGNAME regdest;
wire `WORD aluresult;

reg `ESTACKSIZE en = 1;
reg `OP s0op, s1op, s2op;
reg `REGNAME s0src, s0dst, s0regst, s1regdst, s2regdst;
reg [31:0] en;
reg [63:0] retaddr; /*Need to be capital RETADDR?*/

always @(reset) begin
halt = 0;
PC = 0;
regfile[0] = 0;
regfile[1] = 0;
regfile[2] = 1;
en = -1;
s0OP = `OPNop;
s1OP = `OPNop;
s2OP = `OPNop;
$readmemh0(regfile);
$readmemh1(mainmem);
end

decode mydecode(op, regdest, s0op, ir);
	alu myalu(aluresult, s1op, s1srcval, s1dstval);
	
	always @(*) ir = mainmem[pc];

	//compute srcval
	always @(*) if ((s0op == `OPli8) || (s0op == `OPlu8)) srcval =ir;
            else srcval = ((s1regdst && (s0src == s1regdst)) ? res :
                           ((s2regdst && (s0src == s2regdst)) ? s2val:
                            regfile[s0src]));
	end

	//compute dstval
	always @(*) dstval = ((s1regdst && (s0dst == s1regdst)) ? res :
                      ((s2regdst && (s0dst == s2regdst)) ? s2val :
                       regfile[s0dst]));
	end

	//new pcval - Not so sure . . . . .
	always @(*) begin
		newpc = ((s1OP == `OPjumpf) && (s1dstval == 0)) ? s1srcval:
			(s1OP == `OPjumpf) ? s1srcval: ((s1OP == `OPcall) &&
			(en[0] == 1)) ? s1srcval: (PC + 1); 
	end
	
	//ifsquash jumpf only?
	always@(*) ifsquash = ((s1op == `OPjumpf && (s1dstval == 0));

	//rrsquash jumpf, jump, and call
always@(*) rrsquash = = (((s1op == `OPjumpf) || (s1op == `OPjump) 
|| (s1op == `OP call) && (s1dstval == 0));

	//Register Read
	alway@(posedge clk) if (!halt) begin
		s1op <= (rrsquash ? `OPNop : s0op);
		s1regdst <= (rrsquash ? 0 : s0regdst);
  		s1srcval <= srcval;
  		s1dstval <= dstval;
end

	always@(posedge clk) if (!halt) begin
		s2op <= s1op;
s2regdst <= s1regdst;
//if loading load val, else use result from alu
s2val <= ((s1op == `OPload) ? mainmem[s1srcval] : res);
if (s1op == `OPstore) mainmem[s1srcval] <= s1dstval;
if (s1op == `OPtrap) halt <= 1;
if (s1op == `OPpushen) en = ((en << 1) | (en & 1))
if (s1op == `OPpopen) en = (en >> 1);
If (s1op == ‘OPret) pc = unstack();
	end
	
	// Register Write
	always @(posedge clk) if (!halt) begin
		if (s2regdst != 0) regfile[s2regdst] <= s2val;
	end

//Instruction Fetch
always @(posedge clk) if (!halt) begin
	 S0op <= (decOP == `OPtrap) ? `OPnop : decOP; 
	 S0regdst <= (decOP == ‘OPtrap) ? 0 : regdest;
	 s0Src <= ir `src;
	 s0dst <= ir `dest;
	 pc <= newpc;
end 
endmodule



//Test Bench
module bench;
reg reset = 1;
reg clk = 0;
wire done;
processor PE(done, reset, clk);
initial begin
  $dumpfile;
  $dumpvars(0, PE);
  #10 reset = 0;
  while (done == 0) begin
    #10 clk = 1;
    #10 clk = 0;
  end
 $finish;
end
endmodule


// AIK Specification
add $ud,$us,$ut := 0:4 ud:4 us:4 ut:4
mul $ud,$us,$ut := 1:4 ud:4 us:4 ut:4
sll $ud,$us,$ut := 2:4 ud:4 us:4 ut:4
sra $ud,$us,$ut := 3:4 ud:4 us:4 ut:4
slt $ud,$us,$ut := 4:4 ud:4 us:4 ut:4
neg $ud,$us := 8:4 ud:4 us:4 0:4

and $ud,$us,$ut := 5:4 ud:4 us:4 ut:4
or $ud,$us,$ut := 6:4 ud:4 us:4 ut:4
xor $ud,$us,$ut := 7:4 ud:4 us:4 ut:4
lnot $ud,$us := 8:4 ud:4 us:4 1:4

jump addr := 8:4 0:8 4:4 addr:16
call addr := 8:4 0:8 5:4 addr:16
trap := 8:4 0:8 6:4
ret := 8:4 0:8 7:4
load $ud,$us := 8:4 ud:4 us:4 2:4
store $ud,$us := 8:4 ud:4 us:4 3:4
jumpf $ud addr := 8:4 ud:4 0:4 8:4 addr:16

gor $ud,$us := 8:4 ud:4 us:4 9:4
left $ud,$us := 8:4 ud:4 us:4 10:4
right $ud,$us := 8:4 ud:4 us:4 11:4
allen := 8:4 0:8 12:4
pushen := 8:4 0:8 13:4
popen := 8:4 0:8 14:4

li8 $ud,imm := 11:4 ud:4 imm:8
lu8 $ud,imm := 12:4 ud:4 imm:8
li $ud,i16 ?((i16-.<=127)&&(i16-.>=-128)) := 11:4 ud:4 i16:8
li $ud,i16 := 11:4 ud:4 i16:8 12:4 ud:4 (i16>>8):8

.const 0 .lowfirst
.const {zero IPROC NPROC sp fp rv u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 }



//Test AIK Program

.text
	.origin	0x0000
jump next
start:	add	$u0,$zero,$IPROC
	Allen
	ret
next: 	and	$u1,$NPROC,$sp
	call	start
	gor	$u2,$fp
	left	$u4,$rv
	li8	$u5,42
	lnot	$u6,$u7
	load	$u0,$u8
	lu8	$u5,0x42
	mul	$u0,$u1,$u2
	neg	$u3,$u4
	or	$u5,$u6,$u7
	li8 $u0, 8
	jumpf	$u0, tr
pushen
	right	$u8,$u9
	sll	$u0,$NPROC,$NPROC
	slt	$u1,$u2,$u3
	sra	$u4,$NPROC,$NPROC
	popen
	store	$u5,$u6
	xor	$u7,$u8,$u9
yuck:	li	$u5,yuck
	li	$u5,yuck-100
	li	$u5,128
jumpf $zero, tr
add $u3, $u0, $u1
mul $u5, $u2, $u3
tr: trap
