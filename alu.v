`define ADD     2'b00
`define MINUS   2'b01
`define BAND    2'b10
`define NOT     2'b11

module ALU(Ain,Bin,ALUop,out,Z, V, N);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output [15:0] out;
    output Z, V, N;

    assign out =    ALUop == `ADD ? Ain + Bin : 
                    ALUop == `MINUS ? Ain - Bin:
                    ALUop == `BAND ? Ain & Bin : ~Bin;
    assign Z = out == 16'b0 ? 1'b1 : 1'b0;
    
    // negative if MSB is 1
    assign N = out[15] == 1'b1 ? 1'b1 : 1'b0;
    
    // overflow if out MSB is different sign than Ain and Bin MSB
    assign V = (~out[15] & Ain[15] & Bin[15]) | (out[15] & ~Ain[15] & ~Bin[15]);

endmodule