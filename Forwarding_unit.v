module Forwarding_unit(
		id_ex_rs_i,
		id_ex_rt_i,
		ex_mem_rd_i,
		mem_wb_rd_i,
		ex_mem_regwrite_i,
		mem_wb_regwrite_i,
		rs_data_o,
		rt_data_o		
		);
///signal
input [4:0] id_ex_rs_i;
input [4:0] id_ex_rt_i;
input [4:0] ex_mem_rd_i;
input [4:0] mem_wb_rd_i;
input       ex_mem_regwrite_i;
input 		mem_wb_regwrite_i;
output [1:0] rs_data_o; 		
output [1:0] rt_data_o; 		
		
wire [4:0] id_ex_rs_i;
wire [4:0] id_ex_rt_i;
wire [4:0] ex_mem_rd_i;
wire [4:0] mem_wb_rd_i;
wire       ex_mem_regwrite_i;
wire       mem_wb_regwrite_i;
reg [1:0] rs_data_o; 		
reg [1:0] rt_data_o; 

always@(*) begin
	if(ex_mem_regwrite_i==1'b1 && id_ex_rs_i == ex_mem_rd_i) begin
		rs_data_o = 2'b01;
	end
	else if(mem_wb_regwrite_i==1'b1 && id_ex_rs_i == mem_wb_rd_i) begin
		rs_data_o = 2'b10;
	end
	else begin
		rs_data_o = 2'b00;
	end		
end
always@(*) begin
	if(ex_mem_regwrite_i==1'b1 && id_ex_rt_i == ex_mem_rd_i) begin
		rt_data_o = 2'b01;
	end
	else if(mem_wb_regwrite_i==1'b1 && id_ex_rt_i == mem_wb_rd_i) begin
		rt_data_o = 2'b10;
	end
	else begin
		rt_data_o = 2'b00;
	end	
end		
		
endmodule