`define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10

module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);
	input [3:0] KEY;
	input [9:0] SW;
	output [9:0] LEDR;
output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	//temporary testing variables
	wire N,V,Z,w;
	
	//RAM combinational logic variables
	wire [1:0] mem_cmd;
	wire [8:0] mem_addr;
	wire ANDin, msel, enable;
	wire [15:0] read_data;
	wire [7:0] read_address;
	wire [15:0] dout;

	//stage 2 variables
	wire [15:0] write_data;
	wire [7:0] write_address;
	wire [15:0] out;
	wire write, ANDinWrite, ANDinRead;
	wire [15:0] din;
	
	wire [4:0] present_state;
	wire [8:0] pc_out;
	wire [15:0] R0;
	wire [15:0] R1;
	wire [15:0] R2;
	wire [15:0] R3;
	wire [15:0] R4;
	wire [15:0] R5;
	wire [15:0] R6;
	wire [15:0] R7;
	
	assign write_data = out;
	
	cpu CPU(.clk 	(~KEY[0]),
				.reset  (~KEY[1]),
				.out(out),
				.N (N),
				.V (V),
				.Z (Z),
				.w (W),
				.read_data (read_data), 
				.mem_cmd (mem_cmd), 
				.mem_addr (mem_addr),
				.present_state(present_state),
				.pc_out	(pc_out),
				.R0(R0),
				.R1(R1),
				.R2(R2),
				.R3(R3),
				.R4(R4),
				.R5(R5),
				.R6(R6),
				.R7(R7),
				.load_addr(load_addr),
				.addr_sel(addr_sel));
	
	//Figure 5 din
	assign write_data = out;
	assign din = write_data;
		
	//Figure 4 (9)
	assign ANDinRead = (`MREAD == mem_cmd) ? 1'b1 : 1'b0;

	//Figure 5 MWRITE
	assign ANDinWrite = (`MWRITE == mem_cmd) ? 1'b1 : 1'b0;

	//Figure 4 (8)
	assign msel = (mem_addr[8] == 1'b0) ? 1'b1 :  1'b0;
	
	assign enable = ANDinRead & msel;

	//Figure 5 write
	assign write = ANDinWrite & msel;
	
	assign read_address = mem_addr[7:0];
	assign write_address = mem_addr[7:0];

	RAM MEM(~KEY[0],read_address,write_address,write,din,dout);

	//Figure 4 (7)
	assign read_data = enable ? dout : {16{1'bz}};


endmodule

// To ensure Quartus uses the embedded MLAB memory blocks inside the Cyclone
// V on your DE1-SoC we follow the coding style from in Altera's Quartus II
// Handbook (QII5V1 2015.05.04) in Chapter 12, “Recommended HDL Coding Style”
//
// 1. "Example 12-11: Verilog Single Clock Simple Dual-Port Synchronous RAM 
//     with Old Data Read-During-Write Behavior" 
// 2. "Example 12-29: Verilog HDL RAM Initialized with the readmemb Command"

module RAM(clk,read_address,write_address,write,din,dout);          
  parameter data_width = 16;	//Was originally 32 but I think it's supposed to be 16? 
  parameter addr_width = 8;
  parameter filename = "data.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;

  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename, mem);

  always @ (posedge clk) begin
    if (write)
      mem[write_address] <= din;
    dout <= mem[read_address]; // dout doesn't get din in this clock cycle 
                               // (this is due to Verilog non-blocking assignment "<=")
  end 
endmodule
