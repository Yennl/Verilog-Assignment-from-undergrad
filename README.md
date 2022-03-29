# Verilog-Assignment-from-undergrad
From my undergrad years, circa 2017. Verilog code showcasing a facilitated computer architecture where the implementation is a single cycle pipeline. 


KySMet is a slightly strained acronym for KentuckY Simd Machine with --et added to mean "diminutive" -- a wimpy version of such a machine. SIMD is a nested acronym meaning Single Instruction stream, Multiple Data stream, which means performing the same instruction simultaneously on many data.

The machine has sixteen 16-bit registers, 16-bit datapaths, and 16-bit addresses, and each address in memory holds one 16-bit word. It can operate only on 16-bit integers. The odd thing is the memory structure: there is one instruction memory, but there is a separate data memory for each processing element. Of course, it's not that odd because it still works for having just one processing element.
