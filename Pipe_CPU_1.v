//Subject:     CO project 4 - Pipe CPU 1
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Pipe_CPU_1(
        clk_i,
		rst_i
		);
    
/****************************************
I/O ports
****************************************/
input clk_i;
input rst_i;

/****************************************
Internal signal
****************************************/
/**** IF stage ****/
wire [31:0] pc_out;
wire [31:0] pc_in;
wire [31:0] pc_next;
wire [31:0] instruction;
wire [63:0] if_id_r;
/**** ID stage ****/
//data signal
wire [31:0] sign_extend;
wire [10+32+32+32+32+5+5-1:0] id_ex_r;
wire [31:0] r1_data;
wire [31:0] r2_data;
//control signal
wire regwrite_o;
wire [2:0] alu_op_o;
wire alusrc_o;
wire regdst_o;
wire branch_o;
wire memread_o;
wire memwrite_o;
wire memtoreg_o;
//wire [1:0] branchtype_o;

/**** EX stage ****/
wire [31:0] alu_result;
wire [31:0] add_result;
wire [4:0] regdst;
//control signal
wire [19:0] ex_mem_r;

/**** MEM stage ****/

//control signal


/**** WB stage ****/

//control signal


/****************************************
Instnatiate modules
****************************************/
//Instantiate the components in IF stage
MUX_2to1 #(.size(32)) Mux1(
      .data0_i(pc_next),
      .data1_i(),//later
		.select_i(),//later 
		.data_o(pc_in)
		);

ProgramCounter PC(
		.clk_i(clk_i),
	   .rst_i(rst_i),
	   .pc_in_i(pc_in),
	   .pc_out_o(pc_out)
        );

Instr_Memory IM(
      .addr_i(pc_out),
	   .instr_o(instruction)
	    );

Adder Add_pc(
		.src1_i(32'd4),
	   .src2_i(pc_out),
	   .sum_o(pc_next)
		);

		
Pipe_Reg #(.size(64)) IF_ID(       //N is the total length of input/output
      .clk_i(clk_i),
	   .rst_i(rst_i),
	   .data_i({pc_next , instruction}),
	   .data_o(if_id_r)
		);

//Instantiate the components in ID stage
Reg_File RF(
      .clk_i(clk_i),
		.rst_i(rst_i),
      .RSaddr_i(if_id_r[25:21]),
      .RTaddr_i(if_id_r[20:16]),
      .RDaddr_i(),//later
      .RDdata_i(),//later
      .RegWrite_i(),//later
      .RSdata_o(r1_data),
      .RTdata_o(r2_data)
		);

Decoder Control(
     .instr_op_i(if_id_r[31:26]),
	  .RegWrite_o(regwrite_o),
	  .ALU_op_o(alu_op_o),
	  .ALUSrc_o(alusrc_o),
	  .RegDst_o(regdst_o),
	  .Branch_o(branch_o),
	  .MemRead_o(memread_o),
	  .MemWrite_o(memwrite_o),
	  .MemToReg_o(memtoreg_o),
	  //.Branchtype_o(branchtype_o)
		);

Sign_Extend Sign_Extend(
     .data_i(if_id_r[15:0]),
     .data_o(sign_extend)
		);	

Pipe_Reg #(.size(10+32+32+32+32+5+5)) ID_EX(
      .clk_i(clk_i),
	   .rst_i(rst_i),
	   .data_i({regwrite_o , memtoreg_o , branch_o , memwrite_o , memread_o , alusrc_o , alu_op_o , regdst_o}),
	   .data_o(id_ex_r)
		);

//Instantiate the components in EX stage	   
ALU ALU(

		);

ALU_Ctrl ALU_Ctrl(

		);

MUX_2to1 #(.size(32)) Mux2(

        );

MUX_2to1 #(.size(5)) Mux3(

        );

Pipe_Reg #(.size(N)) EX_MEM(

		);

//Instantiate the components in MEM stage
Data_Memory DM(

	    );

Pipe_Reg #(.size(N)) MEM_WB(
        
		);

//Instantiate the components in WB stage
MUX_2to1 #(.size(32)) Mux4(

        );

/****************************************
signal assignment
****************************************/	
endmodule

