module fifo_wr_ctl #(
	parameter integer FIFO_ALMOSTFULL_DEPTH,
	parameter integer FIFO_ALMOSTEMPTY_DEPTH
)(
	//system
	rst_n,						//input
	//axi stream		
	axis_data_en,				//input
	axis_data_sync,				//input
	axis_data_requst,			//output
	//fifo write
	fifo_wr_clk,				
	fifo_wr_en,					//output fifo 写使能
	fifo_full,					//input fifo 满标志，高有效
	fifo_wr_cnt,				//input fifo 写入数据
	//lcd
	lcd_framesync				//同步输出
);	
//--------------------------------------------------------------------------//	
	input 					rst_n;
	//axi interface
	input 					axis_data_en;				//input axi stream 数据输出使能
	input 					axis_data_sync;        		//input axi stream 数据同步
	output 					axis_data_requst;      		//output axi stream  数据请求
	//fifo interface
	input 			
	input 					fifo_wr_clk;				
	output					fifo_wr_en;					//output fifo 写使能
	input					fifo_full;					//input fifo 满标志，高有效
	input		[9 : 0]		fifo_wr_cnt;				//input fifo 写入数据
	
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
	//signal
	reg 					wr_ready;
	reg 					axis_data_requst;
//--------------------------------------------------------------------------//
	
assign lcd_framesync = axis_data_sync;						//使用axi stream 同步信号进行数据同步
assign fifo_wr_en = ((axis_data_requst)&&(wr_ready))?1:0;	//fifo内部数据小于最小存储深度且写准备就绪时，写使能
	
always @(posedge fifo_wr_clk)begin
	if(!rst_n)begin
		wr_ready <= 0;
	end
	else 
	begin
		if((fifo_wr_cnt>FIFO_ALMOSTEMPTY_DEPTH)&&(fifo_wr_cnt<FIFO_ALMOSTFULL_DEPTH))begin
			wr_ready <= 1;
		end
		else
		begin
			wr_ready <= 0;
		end
	end
end

always @(posedge fifo_wr_clk)begin
	if(!rst_n)begin
		axis_data_requst <= 0;
	end
	else
	begin
		if(fifo_wr_cnt<FIFO_ALMOSTEMPTY_DEPTH)begin	//fifo内数据若小于最小存储深度，申请读请求
			axis_data_requst <= 1;
		end
		else
		begin
			axis_data_requst <= 0;
		end
	end
end
	
endmodule








