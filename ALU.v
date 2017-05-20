//Subject:     CO project 2 - ALU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:     0416001 ¿àÝÂ­Û 0416225 ¿à«Â¤¯ 
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU(
	rst_i,
    src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o
	);
     
//I/O ports
input rst_i;
input  [32-1:0]  src1_i;
input  [32-1:0]	 src2_i;
input  [4-1:0]   ctrl_i;

output [32-1:0]	 result_o;
output           zero_o;

//Internal signals
reg    [32-1:0]  result_o;
reg              zero_o;

//Parameter

//Main function
always@(*) begin
	if(rst_i) begin
		case(ctrl_i[3:0])
			4'b1110: zero_o = (src1_i==src2_i)? 1:0;	//beq
			4'b0110: zero_o = (src1_i==src2_i)? 0:1;	//bne
			4'b0001: zero_o = ($signed(src1_i)<=$signed(src2_i))? 1:0;	//ble
			4'b0011: zero_o = ($signed(src1_i) <$signed(src2_i))? 1:0;	//blt
			4'b1010: zero_o = (src1_i==0)? 0:1;			//bnez
			default: zero_o = 0;
		endcase
	end
	else begin
		zero_o=0;
	end
end

always@(ctrl_i or src1_i or src2_i) begin
	//if(rst_i)
		//begin
			case(ctrl_i[3:0])
				4'b1110: result_o = (src2_i)<<(src1_i);
				4'b0010:	 result_o=src1_i + src2_i;
				4'b0110: result_o=src1_i - src2_i;
				4'b0000: begin
					result_o=src1_i & src2_i;
				end
				4'b0001: begin
					result_o=src1_i | src2_i;
				end
				4'b0111: result_o=($signed(src1_i) < $signed(src2_i))? 32'd1 : 32'd0;
				4'b1011: result_o=(src1_i < src2_i)? 32'd1 : 32'd0;
				//4'b0011: result_o=src2_i<<16;
				4'b1111: result_o=src1_i*src2_i;
				4'b1010: result_o=src2_i;
				//4'b1100: result_o=src1_i + src2_i;
				default:  result_o=0;
			endcase
		/*end
	else
		begin
			result_o = 32'b0;
		end*/
end


endmodule





                    
                    