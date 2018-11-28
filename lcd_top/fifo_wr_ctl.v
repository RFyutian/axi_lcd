module fifo_wr_ctl #(
	parameter integer FIFO_ALMOSTFULL_DEPTH
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
//--------------------------------------------------------------------------//
	
assign lcd_framesync = axis_data_requst;

	always @(posedge fifo_wr_clk)begin
		if(!rst_n)begin
		
	end
	else 
	begin

	end
end
	
endmodule








