module fifo_wr_ctl #(
	parameter integer FIFO_ALMOSTFULL_DEPTH = 32'd768,
	parameter integer FIFO_ALMOSTEMPTY_DEPTH = 32'd128
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
	input 					fifo_wr_clk;				
	output					fifo_wr_en;					//output fifo 写使能
	input					fifo_full;					//input fifo 满标志，高有效
	input		[9 : 0]		fifo_wr_cnt;				//input fifo 写入数据
	//lcd
	output					lcd_framesync;				//lcd 帧同步输出
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
	//signal
	wire 					axis_data_requst;				//axi stream 数据请求
	reg 					wr_ready;
//--------------------------------------------------------------------------//
	
assign lcd_framesync = axis_data_sync;						//使用axi stream 同步信号进行数据同步
assign fifo_wr_en = ((axis_data_requst)&&(axis_data_en))?1:0;		//数据请求，输出数据有效后，即握手成功，可开启fifo写使能

assign axis_data_requst = wr_ready;				//可写就发数据请求

always @(posedge fifo_wr_clk)begin
	if(!rst_n) begin
		wr_ready = 0;
	end
	else 
	begin			//fifo小于最小存数量时，可写，写到快满时，停止。
		if(fifo_wr_cnt < FIFO_ALMOSTEMPTY_DEPTH) begin
			wr_ready = 1;
		end
		if(fifo_wr_cnt == FIFO_ALMOSTFULL_DEPTH) begin
			wr_ready = 0;
		end
		
	end
end

//always @(posedge fifo_wr_clk)begin
//	if(!rst_n)begin
//		wr_almost_empty <= 0;
//	end
//	else 
//	begin
//		if((fifo_wr_cnt < FIFO_ALMOSTEMPTY_DEPTH)begin	//fifo快空时，
//			wr_almost_empty <= 1;
//		end
//		else
//		begin
//			wr_almost_empty <= 0;
//		end
//	end
//end
//
//always @(posedge fifo_wr_clk)begin
//	if(!rst_n)begin
//		axis_data_requst <= 0;
//	end
//	else
//	begin
//		if(fifo_wr_cnt<FIFO_ALMOSTFULL_DEPTH)begin	//fifo内数据若小于最大存储深度，申请读请求
//			axis_data_requst <= 1;
//		end
//		else
//		begin
//			axis_data_requst <= 0;
//		end
//	end
//end
	
endmodule








