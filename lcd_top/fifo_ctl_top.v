module fifo_ctl_top #(
	parameter integer FIFO_DEPTH = 32'd1024,
	parameter integer FIFO_ALMOSTFULL_DEPTH = 32'd768,
	parameter integer FIFO_ALMOSTEMPTY_DEPTH = 32'd128
)(
	//system
	rst_n,							//input		系统复位
	//axi stream interface 
	axis_data_en,					//input axi stream 数据输出使能
	axis_data_sync,  				//input axi stream 数据同步
	axis_data_requst,				//output axi stream  数据请求
	//fifo port
		//read
	fifo_rd_clk,					//input		fifo读时钟
	fifo_rd_en,						//output	fifo读使能
	fifo_empty,						//input		fifo空指示	
	fifo_rd_cnt,					//input 	fifo读计数器
		//write	
	fifo_wr_clk,					//input		fifo写时钟
	fifo_wr_en,						//output	fifo写使能
	fifo_full,						//input		fifo满指示
	fifo_wr_cnt,					//input		fifo写计数器
	//lcd driver port
	lcd_framesync,					//output 	帧同步输出
	lcd_data_requst					//input	数据请求输入
);

//--------------------------------------------------------------------------//
	//interface 
	//system
	input 					rst_n;
	//axi stream
	input 					axis_data_en;
	input 					axis_data_sync;
	output  				axis_data_requst;
	//fifo
		//read
	input 					fifo_rd_clk;
	output 					fifo_rd_en;
	input					fifo_empty;
	input		[9 : 0]		fifo_rd_cnt;
		//write
	input 					fifo_wr_clk;
	output					fifo_wr_en;
	input 					fifo_full;
	input		[9 : 0]		fifo_wr_cnt;
	//lcd
	output 					lcd_framesync;
	input					lcd_data_requst;
//--------------------------------------------------------------------------//

fifo_wr_ctl #(
	.FIFO_ALMOSTFULL_DEPTH(FIFO_ALMOSTFULL_DEPTH),
	.FIFO_ALMOSTEMPTY_DEPTH(FIFO_ALMOSTEMPTY_DEPTH)
)u_fifo_wr_ctl(
	//system
	.rst_n				(rst_n),
	//axi stream
	.axis_data_en		(axis_data_en),
	.axis_data_sync		(axis_data_sync),
	.axis_data_requst	(axis_data_requst),
	//fifo write
	.fifo_wr_clk		(fifo_wr_clk),
	.fifo_wr_en			(fifo_wr_en),
	.fifo_full			(fifo_full),
	.fifo_wr_cnt		(fifo_wr_cnt),
	//lcd
	.lcd_framesync		(lcd_framesync)
);	

fifo_rd_ctl #(
	.FIFO_ALMOSTEMPTY_DEPTH(FIFO_ALMOSTEMPTY_DEPTH)
)u_fifo_rd_ctl(
	//system
	.rst_n				(rst_n),
	//fifo read
	.fifo_rd_clk		(fifo_rd_clk),
	.fifo_rd_en			(fifo_rd_en),
	.fifo_empty			(fifo_empty),
	.fifo_rd_cnt		(fifo_rd_cnt),
	//lcd interface
	.lcd_data_requst	(lcd_data_requst)
);

endmodule












