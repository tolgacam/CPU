module datapath(clk,  
                write, vsel, loada, loadb, asel, bsel, loadc, loads, 
                readnum, writenum,
                shift, ALUop,
                sximm8,
                mdata,
                PC,
                sximm5,
                datapath_out,
                Z_out,
                V_out,
                N_out,
				R0, R1, R2, R3, R4, R5, R6, R7);
    input clk;
    input [15:0] mdata, sximm8, sximm5;
    input [7:0] PC;
    input write, loada, loadb, asel, bsel, loadc, loads;
    input [1:0] vsel; // changed to 2 bit select
    input [2:0] readnum, writenum;
    input [1:0] shift, ALUop;

    output [15:0] datapath_out;
    output Z_out, N_out, V_out;
    
    wire [15:0] data_in, data_out, sout, loadaOut, loadbOut, Ain, Bin, out;
    wire Z, V, N;

 output [15:0] R0;
output [15:0] R1;
output [15:0] R2;
output [15:0] R3;
output [15:0] R4;
output [15:0] R5;
 output [15:0] R6;
 output [15:0] R7;

    // 9
    // vsel == 11: C = datapath_out vsel == 10: 8'b0 + PC, vsel == 01: sximm8, vsel == 00: mdata
    assign data_in = vsel[1] ? (vsel[0] ? datapath_out : {8'b0, PC}) : (vsel[0] ? sximm8 : mdata); // modified to be 4 input multiplexer

    // 1
    regfile REGFILE(data_in, writenum, write, readnum, clk, data_out, R0, R1, R2, R3, R4, R5, R6, R7);
    
    // 3
    vDFFE #(16) MODULE3(clk, loada, data_out, loadaOut);

    // 4 
    vDFFE #(16) MODULE4(clk, loadb, data_out, loadbOut);

    // 6
    assign Ain = asel == 1'b1 ? 16'b0 : loadaOut;

    // 8
    shifter MODULE8(loadbOut, shift, sout);

    // 7
    assign Bin = bsel == 1'b1 ? sximm5 : sout; // lab 6 change: replace 11'b0, datapath_in[4:0] with sximm5

    // 2
    ALU MODULE2(Ain, Bin, ALUop, out, Z, V, N); // ALU module now decides whether output is 0, negative, or if overflow occurred

    // 5
    vDFFE #(16) MODULE5(clk, loadc, out, datapath_out);

    // 10
    vDFFE #(3) MODULE6(clk, loads, {Z, V, N}, {Z_out, V_out, N_out}); // status register with zero, overflow, negative

endmodule


