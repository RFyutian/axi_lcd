module fifo_rd_ctl#(
	parameter integer FIFO_ALMOSTEMPTY_DEPTH
)(
	//system
	rst_n,
	//fifo read
	fifo_rd_clk,
	fifo_rd_en,
	fifo_empty,
	fifo_rd_cnt,
	//lcd interface
	lcd_data_requst
);
//--------------------------------------------------------------------------//
	//interface 
	//system
	input 					rst_n;		
	//fifo read	
	input					fifo_rd_clk;
	output 					fifo_rd_en;	
	input					fifo_empty;	
	input 		[9 : 0]		fifo_rd_cnt;
	//lcd interface
	input 					lcd_data_requst;
//--------------------------------------------------------------------------//

	//wire rd_ready;
	reg rd_ready;

//assign rd_ready = ((fifo_rd_cnt>FIFO_ALMOSTEMPTY_DEPTH)&&(!fifo_empty))?1:0;	//若fifo非空，且数据量大于最小数据深度时，可读，高有效


always@(posedge fifo_rd_clk)begin
	if(!rst_n)begin
		rd_ready <= 0;
	end
	else
	begin
		if((fifo_rd_cnt>FIFO_ALMOSTEMPTY_DEPTH)&&(!fifo_empty))begin
			rd_ready <= 1;			//若fifo非空，且数据量大于最小数据深度时，可读，高有效
		end
		else
		begin
			rd_ready <= 0;
		end
	end
end
	
assign fifo_rd_en = (rd_ready&&lcd_data_requst&&rst_n)?1:0;			//若读就绪且有数据请求且未复位时，读使能输出为1
	
//状态机方式实现：
/*
parameter IDLE = 0;
parameter BUSY = 1;

reg [1:0] 			status;

always@(posedge fifo_rd_clk)begin
	if(!rst_n)begin
		status = IDLE;
	end
	else 
	begin
		case (status)
			IDLE:
			begin
				
			end
			BUSY:
			begin
			
			end
			default:
			begin
			
			end
		endcase
	end
end
*/

endmodule



















