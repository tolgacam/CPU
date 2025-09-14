`define ORIGINAL    2'b00
`define LEFT        2'b01
`define RIGHT0      2'b10
`define RIGHT_COPY  2'b11

module shifter(in,shift,sout);
    input [15:0] in;
    input [1:0] shift;
    output [15:0] sout;
    
    assign sout =   shift == `ORIGINAL ? in  : shift == `LEFT ? in << 1 : shift == `RIGHT0 ? in >> 1 : {in[15], in[15:1]};

endmodule
