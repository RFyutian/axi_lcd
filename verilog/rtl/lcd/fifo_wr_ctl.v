module fifo_wr_ctl #(
	parameter integer FIFO_ALMOSTFULL_DEPTH = 32'd768,
	parameter integer FIFO_ALMOSTEMPTY_DEPTH = 32'd128
)(
	//system
	rst_n,						//input
	//axi stream		
	axis_data_en,				//input
	axis_data_requst,			//output
	//fifo write
	fifo_wr_clk,				
	fifo_wr_en,					//output fifo 写使能
	fifo_full,					//input fifo 满标志，高有效
	fifo_wr_cnt					//input fifo 写入数据
);	
//--------------------------------------------------------------------------//	
	input 					rst_n;
	//axi interface
	input 					axis_data_en;				//input axi stream 数据输出使能
	output 					axis_data_requst;      		//output axi stream  数据请求
	//fifo interface 			
	input 					fifo_wr_clk;				
	output					fifo_wr_en;					//output fifo 写使能
	input					fifo_full;					//input fifo 满标志，高有效
	input		[9 : 0]		fifo_wr_cnt;				//input fifo 写入数据
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
	wire 					axis_data_requst;				//axi stream 数据请求
	reg 					wr_ready;
//--------------------------------------------------------------------------//
	
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
	
endmodule








