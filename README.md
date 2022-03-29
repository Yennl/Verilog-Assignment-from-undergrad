# Verilog-Assignment-from-undergrad
From my undergrad years, circa 2017. Verilog code showcasing a facilitated computer architecture where the implementation is a single cycle pipeline. 


KySMet is a slightly strained acronym for KentuckY Simd Machine with --et added to mean "diminutive" -- a wimpy version of such a machine. SIMD is a nested acronym meaning Single Instruction stream, Multiple Data stream, which means performing the same instruction simultaneously on many data.

The machine has sixteen 16-bit registers, 16-bit datapaths, and 16-bit addresses, and each address in memory holds one 16-bit word. It can operate only on 16-bit integers. The odd thing is the memory structure: there is one instruction memory, but there is a separate data memory for each processing element. Of course, it's not that odd because it still works for having just one processing element.

The KySMet instruction set is quite straightforward, a general-register model encoding most instructions as a single 16-bit word:

Instruction	Description	Functionality:


add $d, $s, $t	ADD int	$d = $s + $t
allen	enable ALL processing elements	en = (en | 1)
and $d, $s, $t	bitwise AND integers	$d = $s & $t
call addr	CALL addr	if (active) { stack(pc+1); pc = addr }
gor $d, $s	Global bitwise OR	$d = gor($s)
jump addr	JUMP addr	pc = addr
jumpf $d, addr	JUMP False addr	if ($d==0) en = (en & ~1); if (none_active) pc = addr
left $d, $s	copy from LEFT processing element	$d = PE[(IPROC+1)%NPROC].$s
li8 $d, i8	Load Immediate 8-bit integer	$d = signed_extend(i8)
lnot $d, $s	Logical NOT (zero becomes 1, non-zero becomes 0)	$d = ! $s
load $d, $s	LOAD	$d = memory[$s]
lu8 $d, i8	Load Upper immediate 8-bit integer	$d = ($d & 0x00ff) | (i8 << 8))
mul $d, $s, $t	MULtiply int	$d = $s * $t
neg $d, $s	NEGate int	$d = - $s
or $d, $s, $t	bitwise OR integers	$d = $s | $t
popen	POP ENable state	en = (en >> 1)
pushen	PUSH ENable state	en = ((en << 1) | (en & 1))
ret	RETurn	if (active) pc = unstack()
right $d, $s	copy from RIGHT processing element	$d = PE[(IPROC+NPROC-1)%NPROC].$s
sll $d, $s, $t	Shift Left Logical	$d = $s << ($t & 15)
slt $d, $s, $t	Set Less Than int	$d = ($s < $t)
sra $d, $s, $t	Shift Right Arithmetic	$d = $s >> ($t & 15)
store $d, $s	STORE	memory[$s] = $d
trap	TRAP to operating system (end execution)	halt the user program
xor $d, $s, $t	bitwise eXclusive OR	$d = $s ^ $t


The KySMet General Registers
There are 16 general-purpose registers, some of which have special purposes -- a lot like MIPS. They all have names as well as numbers. 

.const {zero	IPROC	NPROC	sp	fp	rv	u0	u1
	      u2	  u3	  u4	  u5	u6	u7	u8	u9 }
Registers $u0 through $ub (aka, registers $4 through $15) are "user" registers to be used in any way the programmer sees fit. However, it is expected that the assembler or compiler would use registers starting at $u9 for "internal" things and starting at $u0 for normal coding. The first six registers have special meanings:

Register Number	Register Name	Read/Write?	Use
$0	$zero	Read Only	ZERO; constant 0x0000
$1	$NPROC	Read Only	NPROC; number of processing elements
$2	$IPROC	Read Only	IPROC; number of this processing element, unique in [0..NPROC-1]
$3	$sp	Read/Write	the Stack Pointer
$4	$fp	Read/Write	the Frame Pointer
$5	$rv	Read/Write	the Return Value



Please follow the link (if it still exists for you!) for more information relating the project during my undergrad: http://aggregate.org/EE480/kysmet.html
