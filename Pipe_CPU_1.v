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
//control signal
wire [31:0] sign_extend;
wire [153:0] id_ex_r;
wire [31:0] r1_data;
wire [31:0] r2_data;
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
//control signal
wire [31:0] alu_result;
wire [31:0] add_result;
wire [31:0] shift_result;
wire [31:0] src1;
wire [31:0] src2;
wire [4:0] write_addr;
wire [3:0] ctrl;
wire zero;
wire rs_shamt;
wire [106:0] ex_mem_r;

/**** MEM stage ****/
//control signal
wire [70:0] mem_wb_r;
wire [31:0] mem_data;
wire pcsrc;
/**** WB stage ****/
wire [31:0] write_data;
//control signal


/****************************************
Instnatiate modules
****************************************/
//Instantiate the components in IF stage
MUX_2to1 #(.size(32)) Mux1(
       .data0_i(pc_next),
       .data1_i(ex_mem_r[100:69]),
	   .select_i(pcsrc),
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
/*
	if_id_r array
	if_id_r[31:0] = instruction
	if_id_r[63:32] = pc_next
*/

Reg_File RF(
      .clk_i(clk_i),
	   .rst_i(rst_i),
      .RSaddr_i(if_id_r[25:21]),
      .RTaddr_i(if_id_r[20:16]),
      .RDaddr_i(mem_wb_r[4:0]),
      .RDdata_i(write_data),
      .RegWrite_i(mem_wb_r[70]),
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
	  .MemToReg_o(memtoreg_o)
		);

Sign_Extend Sign_Extend_(
      .data_i(if_id_r[15:0]),
      .data_o(sign_extend)
		);	

Pipe_Reg #(.size(10+32+32+32+32+5+5+6)) ID_EX(
      .clk_i(clk_i),
	  .rst_i(rst_i),
	  .data_i({regwrite_o , memtoreg_o , branch_o , memwrite_o , memread_o , alusrc_o , alu_op_o , regdst_o , if_id_r[63:32] , r1_data , r2_data , sign_extend , if_id_r[20:16] , if_id_r[15:11] , if_id_r[5:0]}),
	  .data_o(id_ex_r)
		);

//Instantiate the components in EX stage	   
/*
	id_ex_r array
	id_ex_r[5:0] = funct code
	id_ex_r[10:6] = rd address
	id_ex_r[15:11] = rt address
	id_ex_r[47:16] = sign_extend
	id_ex_r[79:48] =  rt data
	id_ex_r[111:80] = rs data
	id_ex_r[143:112] = next instruction
	id_ex_r[144] = regdst
	id_ex_r[147:145] = alu_op
	id_ex_r[148] = alusrc
	id_ex_r[149] = memread
	id_ex_r[150] = memwrite
	id_ex_r[151] = branch
	id_ex_r[152] = memtoreg
	id_ex_r[153] = regwrite
*/

ALU ALU(
	  .rst_i(rst_i),
      .src1_i(src1),
      .src2_i(src2),
	  .ctrl_i(ctrl),
      .result_o(alu_result),
	  .zero_o(zero)
		);

ALU_Ctrl ALU_Ctrl(
      .funct_i(id_ex_r[5:0]),
      .ALUOp_i(id_ex_r[147:145]),
      .ALUCtrl_o(ctrl),
	  .ALU_o(rs_shamt)
		);

Shift_Left_Two_32 shift_left_two_32(
		.data_i(id_ex_r[47:16]),
		.data_o(shift_result)
		);
		
Adder add_branch(
	   .src1_i(id_ex_r[111:80]),
	   .src2_i(shift_result),
	   .sum_o(add_result)
		);
		
MUX_2to1 #(.size(32)) Mux2(
      .data0_i(id_ex_r[79:48]),
      .data1_i(id_ex_r[47:16]),
	  .select_i(id_ex_r[148]), 
	  .data_o(src2)
        );
		  
MUX_2to1 #(.size(32)) Mux_for_sll(
      .data0_i(id_ex_r[111:80]),
      .data1_i({27'd0 , id_ex_r[26:22]}),
	  .select_i(rs_shamt), 
	  .data_o(src1)
        );
		  
MUX_2to1 #(.size(5)) Mux3(
      .data0_i(id_ex_r[15:11]),
      .data1_i(id_ex_r[10:6]),
	  .select_i(id_ex_r[144]), 
	  .data_o(write_addr)
        );

Pipe_Reg #(.size(107)) EX_MEM(
       .clk_i(clk_i),
	   .rst_i(rst_i),
	   .data_i({zero , id_ex_r[153:149], add_result , alu_result , id_ex_r[79:48] , write_addr }),
	   .data_o(ex_mem_r)
		);

//Instantiate the components in MEM stage
/*
	ex_mem_r array:
	ex_mem_r[4:0] = write_addr;
	ex_mem_r[36:5] = rtdata;
	ex_mem_r[68:37] = alu_result;
	ex_mem_r[100:69] = add_result;
	ex_mem_r[105:101] = wb and mem register
	ex_mem_r[101] = memread
	ex_mem_r[102] = memwrite
	ex_mem_r[103] = branch
	ex_mem_r[104] = memtoreg
	ex_mem_r[105] = regwrite
	ex_mem_r[106] = zero
	
*/
Data_Memory DM(
	   .clk_i(clk_i),
	   .addr_i(ex_mem_r[68:37]),
	   .data_i(ex_mem_r[36:5]),
	   .MemRead_i(ex_mem_r[101]),
	   .MemWrite_i(ex_mem_r[102]),
	   .data_o(mem_data)
	    );
and Branch(pcsrc , ex_mem_r[103] , ex_mem_r[106]);


Pipe_Reg #(.size(71)) MEM_WB(
        .clk_i(clk_i),
	   .rst_i(rst_i),
	   .data_i({ex_mem_r[105:104] , mem_data , ex_mem_r[68:37] , ex_mem_r[4:0]}),
	   .data_o(mem_wb_r)       
		);

//Instantiate the components in WB stage
/*
	mem_wb_r array
	mem_wb_r[4:0] = write_addr
	mem_wb_r[36:5] = alu result
	mem_wb_r[68:37] = mem data
	mem_wb_r[70:69] wb 
	mem_wb_r[69] = memtoreg
	mem_wb_r[70] = regwrite
*/
MUX_2to1 #(.size(32)) Mux4(
       .data0_i(mem_wb_r[68:37]),
       .data1_i(mem_wb_r[36:5]),
	   .select_i(mem_wb_r[69]), 
	   .data_o(write_data)
        );

/****************************************
signal assignment
****************************************/	
endmodule
