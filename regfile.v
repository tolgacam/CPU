`define S 3
`define SR0 3'b000
`define SR1 3'b001
`define SR2 3'b010
`define SR3 3'b011
`define SR4 3'b100
`define SR5 3'b101
`define SR6 3'b110
`define SR7 3'b111

module regfile(data_in, writenum, write, readnum, clk, data_out, R0, R1, R2, R3, R4, R5, R6, R7);
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;
    output [15:0] data_out;
    reg [15:0] data_out;

    
output [15:0] R0;
output [15:0] R1;
output [15:0] R2;
output [15:0] R3;
output [15:0] R4;
output [15:0] R5;
output [15:0] R6;
output [15:0] R7;
    reg [7:0] en;

    vDFFE #(16) MEMORY0(clk, en[0], data_in, R0);
    vDFFE #(16) MEMORY1(clk, en[1], data_in, R1);
    vDFFE #(16) MEMORY2(clk, en[2], data_in, R2);
    vDFFE #(16) MEMORY3(clk, en[3], data_in, R3);
    vDFFE #(16) MEMORY4(clk, en[4], data_in, R4);
    vDFFE #(16) MEMORY5(clk, en[5], data_in, R5);
    vDFFE #(16) MEMORY6(clk, en[6], data_in, R6);
    vDFFE #(16) MEMORY7(clk, en[7], data_in, R7);


    always @ (*) begin
        case(writenum)
                `SR0: en = write == 1'b1 ? 8'b0000_0001 : 8'b0000_0000;
                `SR1: en = write == 1'b1 ? 8'b0000_0010 : 8'b0000_0000;
                `SR2: en = write == 1'b1 ? 8'b0000_0100 : 8'b0000_0000;
                `SR3: en = write == 1'b1 ? 8'b0000_1000 : 8'b0000_0000;
                `SR4: en = write == 1'b1 ? 8'b0001_0000 : 8'b0000_0000;
                `SR5: en = write == 1'b1 ? 8'b0010_0000 : 8'b0000_0000;
                `SR6: en = write == 1'b1 ? 8'b0100_0000 : 8'b0000_0000;
                `SR7: en = write == 1'b1 ? 8'b1000_0000 : 8'b0000_0000;
                default: en = 8'bxxxx_xxxx;
        endcase 

        case(readnum)
            `SR0: data_out = R0;
            `SR1: data_out = R1;
            `SR2: data_out = R2;
            `SR3: data_out = R3;
            `SR4: data_out = R4;
            `SR5: data_out = R5;
            `SR6: data_out = R6;
            `SR7: data_out = R7;
            default: data_out = 16'bx;
        endcase   
    end
    
    
endmodule

