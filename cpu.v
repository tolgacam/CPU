module cpu(clk,reset,out,N,V,Z,w,
			read_data, mem_cmd, mem_addr, present_state, pc_out,
			R0, R1, R2, R3, R4, R5, R6, R7, 
			load_addr, addr_sel);
// define instructions, put them into instruction register
`define SW 5
`define MOVcode 3'b110 // opcode for mov instructions
`define ALUcode 3'b101 // opcode for alu instructions
`define LDRcode 3'b011 // opcode for ldr instructions
`define STRcode 3'b100 // opcode for str instructions
`define Halt 3'b111 // opcode for halt instructions

`define IMMop 2'b10
`define REGop 2'b00
`define ADDop 2'b00
`define CMPop 2'b01
`define ANDop 2'b10
`define MVNop 2'b11
`define LDRop 2'b00
`define STRop 2'b00

`define high 1'b1
`define low 1'b0
`define RST 5'b00000 // 0
`define Rn 3'b001
`define Rd 3'b010
`define Rm 3'b100
// everything below this is arbitrary states
// doesn't need to be 5 bit, but not enough time to change
`define opcodeDecode 5'b00001 // 1
`define MOVstate 5'b11000 // 24
`define writeImm 5'b10111 // 23
`define ALUstate 5'b11001 // 25
`define getMOVReg 5'b10110 // 22
`define loadMOVReg 5'b10101 // 21
`define writeMOVReg 5'b10100 // 20
`define getA 5'b10011 // 19
`define getB 5'b11011 // 27
`define writeReg 5'b00011 // 3
`define CMPstate 5'b00100 // 4

//new states:
`define IF1 5'b00101// 5
`define IF2 5'b00110 // 6
`define UpdatePC 5'b00111 // 7
`define Haltstate 5'b01000 // 8

`define MNONE 2'b00
`define MREAD 2'b01
`define MWRITE 2'b10

`define writeAddress 5'b10010 // 18
`define Addsximm5 5'b10001 // 17
`define readRd 5'b10000 // 16
`define readAddress 5'b01111 // 15
`define updateReg 5'b11010 //26


input clk, reset;
//input [15:0] in;
output [15:0] out;
output N, V, Z, w;
reg w;

wire [15:0] instreg;

// inputs for the controller FSM
wire [2:0] opcode;
wire [1:0] op;

// inputs to the datapath
wire [1:0] ALUop, shift;
wire [15:0] mdata;
reg [15:0] sximm5, sximm8;
wire [4:0] imm5;
wire [7:0] imm8, PC;
wire [2:0] Rn, Rd, Rm;
reg [2:0] nsel;
reg [2:0] readnum, writenum;
reg loada, loadb, asel, bsel, loadc, loads, write;
reg [1:0] vsel;

//new I/Os
output reg [1:0] mem_cmd;
output reg [8:0] mem_addr;
reg load_pc, reset_pc, load_ir; 
output reg load_addr, addr_sel;

wire [8:0] addr_data;

wire [8:0] next_pc;
output [8:0] pc_out;
input [15:0] read_data;

output [15:0] R0;
output [15:0] R1;
output [15:0] R2;
output [15:0] R3;
output [15:0] R4;
output [15:0] R5;
output [15:0] R6;
output [15:0] R7;

// instruction register inputs: load, in. outputs: instreg
vDFFE #(16) instructionRegister(clk, load_ir, read_data, instreg);

// instruction decoder inputs: instreg. outputs: opcode, op, output to datapath

// assigns opcode, op, Rm, Rd, Rn, shift, imm8, imm5, ALUop based on slide decoder
assign opcode = instreg[15:13];
assign op = instreg[12:11];
assign Rm = instreg[2:0];
assign Rd = instreg[7:5];
assign Rn = instreg[10:8];
assign shift = instreg[4:3];
assign imm8 = instreg[7:0];
assign imm5 = instreg[4:0];
assign ALUop = instreg[12:11];

// extends imm8 and imm5 to 16 bits
always @(*) begin
    // extends imm8 to 16 bits
    if (imm8[7] == 1'b1) begin 
        sximm8 = {8'b11111111, imm8};
    end else begin
        sximm8 = {8'b00000000, imm8};
    end
    // extends imm5 to 16 bits
    if (imm5[4] == 1'b1) begin
        sximm5 = {11'b11111111111, imm5};
    end else begin
        sximm5 = {11'b00000000000, imm5};
    end
end

// assigns readnum and writenum based on the nsel value from the FSM
always@(*) begin
    if(nsel==3'b001)begin 
        //Rn
        readnum = Rn;
        writenum = Rn;
    end
    else if(nsel==3'b010)begin
        //Rd
        readnum = Rd;
        writenum = Rd;
    end
    else if(nsel==3'b100)begin
        //Rm
        readnum = Rm;
        writenum = Rm;
    end
    else begin
        readnum = Rn;
        writenum = Rm;
    end
end


// state machine code below
// 6 instructions: MOV immediate, MOV register with shift operations
// ADD reg, CMP reg, AND reg, MVN reg

 wire [4:0] next_state_reset;
 output wire [4:0] present_state;
 reg [4:0] next_state;

// DFF to change state
 vDFF #(`SW) STATE(clk, next_state_reset, present_state);
   
 assign next_state_reset = reset ? `RST : next_state; // reset function

// main FSM always block, determines next state
 always @(*) begin
        // need to initiate these to stop any unwanted write operations and inferred latches
         nsel = 3'b010;
         write = `low;
         vsel = 2'b11; 
         loada = `low;
         loadb = `low;
         asel = `low;
         bsel = `low;
         loadc = `low;
         loads = `low;
         next_state = `RST;
         w = `low;
		 
		 reset_pc = `low;
         load_pc = `low;
         addr_sel = 1'bx;
         mem_cmd = 2'bxx;
         load_ir = `low;
		 load_addr = `low;

     case (present_state)
   `RST: begin // cycle 1
         w = `high;
         reset_pc = `high;
         load_pc = `high;
         addr_sel = `low;
         load_ir = `low;
		 mem_cmd = `MNONE;
         if (reset == `low) begin
         next_state = `IF1;
     end else begin
         next_state = `RST;
     end
     end
     `IF1: begin		//cycle 2
        w = `low;
        reset_pc = `low;
        load_pc = `low;
        addr_sel = `high;
        mem_cmd = `MREAD;
        next_state = `IF2;
		load_addr = `low;
        end

     `IF2: begin		//cycle 3
         load_ir = `high;
         next_state = `UpdatePC;
		 mem_cmd = `MREAD;
		 addr_sel = `high;
         end

     `UpdatePC: begin	//cycle 4
        load_pc = `high;
        mem_cmd = `MNONE;
        addr_sel = `low;
        load_ir = `low;
        next_state = `opcodeDecode;

		end
     `opcodeDecode: begin // decodes the opcode and decides whether it is an ALU operation or MOV operation
         w = `low;
         if (opcode == `MOVcode) begin
         next_state = `MOVstate;
     end else if (opcode == `ALUcode) begin
         next_state = `getA;
     end else if (opcode == `LDRcode) begin
         next_state = `getA;
     end else if (opcode == `STRcode) begin
         next_state = `getA;
    end else begin
         next_state = `Haltstate;
      end
	  end
     `MOVstate: if (op == `IMMop) begin // checks whether to MOV an immediate or a register
         next_state = `writeImm; 
     end else begin
         next_state = `getMOVReg;
     end
     `writeImm: begin // instruction 1
         nsel = `Rn; 
         write = `high;
         vsel = 2'b01; // is going to write sximm8 to the register
         loadb = `low;
         loada = `low;
         asel = `low;
         bsel = `low;
         loadc = `low;
         loads = `low;
         next_state = `IF1; 
     end
     // getMOVReg -> loadMOVReg -> writeReg finishes instruction 2
     `getMOVReg: begin // loads Rm into register B
         nsel = `Rm; 
         write = `low;
         loadb = `high;
         loada = `low;
         asel = `low;
         bsel = `low;
         loadc = `low;
         loads = `low;
         next_state = `loadMOVReg;
     end
     `loadMOVReg: begin // loads Rm into register C, with shift applied
         loada = `low;
         loadb = `low;
         write = `low;
         asel = `high;
         bsel = `low;
         loadc = `high;
         loads = `low;
	if (opcode == `STRcode) begin
		load_addr = `high;
		mem_cmd = `MWRITE;
		addr_sel = `low;
		next_state = `writeAddress;
	end

	else
        		next_state = `writeReg;
     end


    `writeAddress: begin
		load_addr = `low;
		mem_cmd = `MNONE;
		next_state = `IF1;
end


     `getA: begin // loads register A with whatever has Rn
         nsel = `Rn; 
         write = `low;
         vsel = 2'b10; 
         loada = `high;
         loadb = `low;
         asel = `low;
         bsel = `low;
         loadc = `low;
         loads = `low;
         if(opcode == `ALUcode) begin
         next_state = `getB;
     end else begin
         next_state = `Addsximm5; // LDR
         end
   end
// R[Rd]=M[R[Rn]+sx(im5)]  // M[R[Rn]+sx(im5)]=R[Rd]
  
   `Addsximm5: begin
          loada = `low;
         loadb = `low;
         write = `low;
         asel = `low;
         bsel = `high;
         loadc = `high;
         loads = `low;
        if(opcode == `LDRcode) begin
        load_addr = `high;
        mem_cmd = `MREAD;
        next_state = `readAddress;

        end else begin		//STR
        load_addr = `low;
        mem_cmd = `MNONE;
        write = `low;
        //nsel = `Rd;
        next_state = `readRd;
        end
     end
 `readRd: begin	//Rn address now on datapath_out
	nsel = `Rd;
	load_addr = `low;
	mem_cmd = `MNONE;
	write = `low;
	loada =  `low;
	loadb =  `high;
	loadc = `low;
	next_state = `loadMOVReg;
end



 `readAddress: begin
	mem_cmd = `MREAD;
	load_addr = `high;
	addr_sel = `low;

	next_state = `updateReg;
end

 `updateReg: begin
addr_sel =  `low;
load_addr =  `high;
next_state =  `writeReg;
mem_cmd = `MREAD;
end



     `Haltstate: begin
	if (opcode == 3'b111) begin
        	 	next_state = `Haltstate;
end else begin
next_state = `opcodeDecode;
end
     end
     `getB: begin // loads register B with whatever has Rm
         nsel = `Rm; 
         write = `low;
         vsel = 2'b10; 
         loada = `low;
         loadb = `high;
         asel = `low;
         bsel = `low;
         loadc = `low;
         loads = `low;
         if (ALUop == `CMPop)begin
             next_state = `CMPstate;
         end else begin
             next_state = `ALUstate;
         end
     end
     `ALUstate: begin // finishes instruction 3, 5, 6
         loada = `low;
         loadb = `low;
         write = `low;
         asel = `low;
         bsel = `low;
         loadc = `high;
         loads = `low;
         next_state = `writeReg;
     end
     `CMPstate: begin // finishes instruction 4
         loada = `low;
         loadb = `low;
         write = `low;
         asel = `low;
         bsel = `low;
         loadc = `low;
         loads = `high;
         next_state = `IF1;
     end
     `writeReg: begin // writes to the register the value of whatever C is
         nsel = `Rd; 
         if(opcode == `LDRcode) begin
         vsel = 2'b00;				//Take mdata as input
		 load_addr = `high;
		 addr_sel = `low;
		 mem_cmd = `MREAD;
        end else begin
          vsel = 2'b11;				//Take C (datapath_out) as input
         end
         write = `high;
         asel = `low;
         bsel = `low;
         loadc = `low;
         loads = `low;
         next_state = `IF1;
     end
     default: begin // default state
         nsel = 3'b010; 
         write = `low;
         vsel = 2'b11; 
         loada = `low;
         loadb = `low;
         asel = `low;
         bsel = `low;
         loadc = `low;
         loads = `low;
     end
     endcase
 end

// instantiates datapath module
 datapath DP(clk, write, vsel, loada, loadb, asel, bsel, loadc, loads, readnum, writenum, shift, ALUop, sximm8, read_data, PC, sximm5, out, Z, V, N, R0, R1, R2, R3, R4, R5, R6, R7);
 
 //lab7 other logic block instantiations
 resetMux MUXPC1 (pc_out, reset_pc, next_pc);
 PC ProgramCounter (load_pc, clk, next_pc, pc_out);	//Figure 4 (3)
 
//Figure 4 (5) 
 always @(*) begin
		case(addr_sel)
			1'b1: mem_addr = pc_out;
			1'b0: mem_addr = addr_data;
			default: mem_addr = 9'bxxxxxxxxx;
		endcase
	end

PC DataAddress(load_addr, clk, out[8:0], addr_data);


endmodule

// register module
module vDFF (clk, in, out);
 parameter n = 3; // width
 input clk;
 input [n-1:0] in;
 output reg [n-1:0] out;
  
 always @ (posedge clk)
    out = in;
endmodule

// register module with write en
module vDFFE(clk, en, in, out) ;
  parameter n = 1;  // width
  input clk, en ;
  input  [n-1:0] in ;
  output [n-1:0] out ;
  reg    [n-1:0] out ;
  wire   [n-1:0] next_out ;

  assign next_out = en ? in : out;

  always @(posedge clk)
    out = next_out;  
endmodule

//9bit input 2 input Mux for before the program counter
//Includes the +1 logic block
module resetMux (pc_in, reset_pc, next_pc);
	input [8:0] pc_in;
	input reset_pc;
	output wire [8:0] next_pc;

	assign next_pc = reset_pc ? 9'b000000000 : pc_in + 1'b1;
endmodule

//Figure 4 (3)
//Program Counter
 module PC (load_pc, clk, next_pc, pc_out);
	input load_pc, clk;
	input [8:0] next_pc;
	output [8:0] pc_out;

	wire [8:0] mux_out;

	PCMux PC_Mux(next_pc, pc_out, load_pc, mux_out);
	vDFF9 PC_DFF(clk, mux_out, pc_out);

endmodule

//9bit input 2 input Mux for the program counter
module PCMux (pc_in, pc_out, load_pc, out);
	input [8:0] pc_in, pc_out;
	input load_pc;
	output wire [8:0] out;

	assign out = load_pc ? pc_in : pc_out;
endmodule

//9-bit DFF
module vDFF9 (clk, in, out);
 parameter n = 9; // width
 input clk;
 input [n-1:0] in;
 output reg [n-1:0] out;
  
 always @ (posedge clk)
    out = in;
endmodule
