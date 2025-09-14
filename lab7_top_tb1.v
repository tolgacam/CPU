module lab7top_tb1 ();
	reg [3:0] sim_KEY;
	reg [9:0] sim_SW;
	wire [9:0] sim_LEDR;
	wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 
	
	reg err;
	
	lab7_top DUT(sim_KEY, sim_SW, sim_LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	
	initial begin
	err = 0;
	//the KEY inputs are inverted because of the DE1-SoC push buttons
	//so sim_KEY[0] = positive clk edge
	sim_KEY[0] = 1'b1;
	sim_KEY[1] = 1'b0;
	#5;
	sim_KEY[0] = 1'b0;	//RST state
				//reset_pc = 1
				//load_pc = 1
	#5;
	sim_KEY[0] = 1'b1;
	sim_KEY[1] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//IF1
				//addr_sel = 1
				//mem_cmd = MREAD
				//PC = 0
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//IF2
				//load_ir = 1
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//UpdatePC
				//load_pc = 1
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0; //Decode
				// PC = 1
				//Instructions on instruction register
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0; //WriteIMM
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0; //IF1
	#5;
	sim_KEY[0] = 1'b1;
	#5;					//75
	sim_KEY[0] = 1'b0; //IF2
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0; //UpdatePC
	
	if (lab7top_tb1.DUT.CPU.R0 !== 16'b0000000000000111) begin
      err = 1;
      $display("FAILED: MOV R0, #7");
      //$stop;
	  end
	
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//Decode
						//PC = 2
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0; //MOVstate
	
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0; //WriteIMM
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0; //IF1
	#5;
	sim_KEY[0] = 1'b1;
	#5;					//135
	sim_KEY[0] = 1'b0; //IF2
	
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//UpdatePC
	
	if (lab7top_tb1.DUT.CPU.R1 !== 16'b0000000000000010) begin
      err = 1;
      $display("FAILED: MOV R1, #2");
    end
	
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//Decode
						//PC = 3
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//MOVstate
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//WriteIMM
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0; //IF1
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0; //IF2
						//out is updated
	#5;				
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//UpdatePC
	
	#5;
	sim_KEY[0] = 1'b1;
	#5;					//215
	sim_KEY[0] = 1'b0;	//Decode
						//PC = 4			
						
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//getA
	
if (lab7top_tb1.DUT.CPU.R2 !== 16'b0000000000010000) begin
      err = 1;
      $display("FAILED");
    end	
		#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//getB
		#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//ALUstate
		#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//writeReg
		#5;
	sim_KEY[0] = 1'b1;
	#5;					//215
	sim_KEY[0] = 1'b0;	//IF1				
						//out updated to R2
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//IF2
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0; //UpdatePC
	#5;
	sim_KEY[0] = 1'b1;
	#5;					//245
	sim_KEY[0] = 1'b0; //Decode
						//PC = 5
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//getA
	#5;
	sim_KEY[0] = 1'b1;
	#5;					//265
	sim_KEY[0] = 1'b0;	//Addsximm5
	#5;
	sim_KEY[0] = 1'b1;
	#5;		
	sim_KEY[0] = 1'b0;	//readAddress
						//out = 2
	#5;
	sim_KEY[0] = 1'b1;
	#5;					//285
	sim_KEY[0] = 1'b0;	//updateReg
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//writeReg
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//305
						//IF1
						//R3 = M[2]
	if (lab7top_tb1.DUT.CPU.R3 !== 16'b1010000101001000) begin
      err = 1;
      $display("FAILED");
    end					
	
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//IF2
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0; //UpdatePC
	#5;
	sim_KEY[0] = 1'b1;
	#5;					//335
	sim_KEY[0] = 1'b0; //Decode
						//PC = 5
	#5;
	sim_KEY[0] = 1'b1;
	#5;					
	sim_KEY[0] = 1'b0; //MOVstate
		#5;
	sim_KEY[0] = 1'b1;
	#5;					
	sim_KEY[0] = 1'b0;	//WriteIMM
		#5;
	sim_KEY[0] = 1'b1;
	#5;					//365
	sim_KEY[0] = 1'b0;	//IF1
						//R4 = 17
						//MOV R4
						
	if (lab7top_tb1.DUT.CPU.R4 !== 16'b0000000000010001) begin
      err = 1;
      $display("FAILED");
    end	
	
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//IF2
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0; //UpdatePC
	#5;
	sim_KEY[0] = 1'b1;
	#5;					
	sim_KEY[0] = 1'b0; //Decode
						//PC = 5
	#5;					//400
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//getA
	#5;
	sim_KEY[0] = 1'b1;
	#5;					
	sim_KEY[0] = 1'b0;	//Addsximm5
	#5;
	sim_KEY[0] = 1'b1;
	#5;		
	sim_KEY[0] = 1'b0;	//readRd
	#5;
	sim_KEY[0] = 1'b1;
	#5;					
	sim_KEY[0] = 1'b0;	//loadMOVReg
	#5;
	sim_KEY[0] = 1'b1;
	#5;					//445
	sim_KEY[0] = 1'b0;	//writeAddress
						//din = 7
						//STR
	if (lab7top_tb1.DUT.din !== 16'b0000000000000111) begin
      err = 1;
      $display("FAILED");
    end				
			
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	
						//IF1
	
	#5;
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//IF2
	#5;
	sim_KEY[0] = 1'b1;
	#5;					
	sim_KEY[0] = 1'b0;	//UpdatePC
	#5;
	sim_KEY[0] = 1'b1;
	#5;		
	sim_KEY[0] = 1'b0;	//Decode
	#5;
	sim_KEY[0] = 1'b1;
	#5;					
	sim_KEY[0] = 1'b0;	//getA
	#5;					//500
	sim_KEY[0] = 1'b1;
	#5;
	sim_KEY[0] = 1'b0;	//getB
	#5;
	sim_KEY[0] = 1'b1;
	#5;					//515
	sim_KEY[0] = 1'b0;	//ALUstate
	#5;
	sim_KEY[0] = 1'b1;
	#5;					
	sim_KEY[0] = 1'b0;	
	#5;
	sim_KEY[0] = 1'b1;
	#5;					//535	
	sim_KEY[0] = 1'b0;	//R5 = -8
						//IF1
						
	if (lab7top_tb1.DUT.CPU.R5 !== 16'b1111111111111000) begin
      err = 1;
      $display("FAILED");
    end						
	
	#5;
	$stop;
	end
endmodule