module fifo_rd_ctl#(
	parameter integer FIFO_ALMOSTEMPTY_DEPTH = 32'd128
)(
	//system
	rst_n,
	//fifo read
	fifo_rd_clk,
	fifo_rd_en,
	fifo_empty,
	fifo_rd_cnt,
	//lcd interface
	rd_data_requst
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
	input 					rd_data_requst;
//--------------------------------------------------------------------------//

	//wire rd_ready;
	reg rd_ready;
	reg data_requst_dly1;
	reg data_requst_dly2;
	
	wire data_requst;

//assign rd_ready = ((fifo_rd_cnt>FIFO_ALMOSTEMPTY_DEPTH)&&(!fifo_empty))?1:0;	//若fifo非空，且数据量大于最小数据深度时，可读，高有效
//打一拍在读，否则会出现亚稳态
always@(posedge fifo_rd_clk)begin
	if(!rst_n)begin
		data_requst_dly1 <= 0;
		data_requst_dly2 <= 0;
	end
	else 
	begin 
//		if(rd_data_requst)
		begin
			data_requst_dly1 <= rd_data_requst;
			data_requst_dly2 <= data_requst_dly1; 
		end
	end
end

//assign data_requst = data_requst_dly1&&rd_data_requst;
assign data_requst = data_requst_dly1;
//assign data_requst = data_requst_dly1&&data_requst_dly2;

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
	
assign fifo_rd_en = (rd_ready&&data_requst&&rst_n)?1:0;			//若读就绪且有数据请求且未复位时，读使能输出为1

endmodule



















