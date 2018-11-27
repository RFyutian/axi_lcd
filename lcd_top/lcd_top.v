/*-------------------------------------------------------------------------
This confidential and proprietary software may be only used as authorized
by a licensing agreement from amfpga.
(C) COPYRIGHT 2013.www.amfpga.com ALL RIGHTS RESERVED
Filename			:		sdram_ov7670_vga.v
Author				:		Amfpga
Data				:		2013-02-1
Version				:		1.0
Description			:		sdram vga controller with ov7670 display.
Modification History	:
Data			By			Version			Change Description
===========================================================================
13/02/1
--------------------------------------------------------------------------*/
module lcd_top
(  	
	//global clock
	input				rst_n,     		//sync reset
	input				clk,			//system clock
//	input 				axis_if_clk,	//140M时钟输入
	input 				lcd_if_clk,		//9M时钟输入
	//axi stream interface 
	input 				axis_aresetn,		// input wire s00_axis_aresetn
	input 				axis_aclk,        	// input wire s00_axis_aclk
	input 	[31:0] 		axis_tdata,     	// input wire [31 : 0] write data
	input 				axis_tvalid,    	// 数据有效，从机为输入
	output				axis_tready,    	// 数据输入准备，从机为输出
	input 				axis_tuser,			// input wire frame sync
	input 				axis_tlast,      	// input wire axis_tlast
	input 				axis_tstrb,      	// input wire [3 : 0] axis_tstrb
	//lcd interface
	output				lcd_dclk,   		//lcd pixel clock
	output				lcd_blank,			//lcd blank
	output				lcd_sync,			//lcd sync
	output				lcd_hs,	    		//lcd horizontal sync
	output				lcd_vs,	    		//lcd vertical sync
	output				lcd_en,				//lcd display enable
	output	[23:0]		lcd_rgb				//lcd display data
);
	  
	//signal
//--------------------------------------------------------------------------//	
	wire 				lcd_if_clk;

	wire 				axis_data_en;			//output axi stream 数据输出使能
	wire 				axis_data_sync;        	//output axi stream 数据同步
	wire 				axis_data_requst;      	//input axi stream  数据请求
//--------------------------------------------------------------------------//	
	
//-------------------------------------//
//	lcd driver interface               //
//-------------------------------------//
axis_if u_axis_if(
	//axi stream interface
	.axis_aresetn(axis_aresetn),			// input wire s00_axis_aresetn
	.axis_aclk(axis_aclk),        			// input wire s00_axis_aclk
	//.axis_tdata(axis_tdata),     			// input wire [31 : 0] write data
	.axis_tvalid(axis_tvalid),    			// input wire s00_axis_tvalid
	.axis_tready(axis_tready),    			// output wire read data ready
	.axis_tuser(axis_tuser),				// input wire frame sync
	.axis_tlast(axis_tlast),      			// input wire s00_axis_tlast
	.axis_tstrb(axis_tstrb),      			// input wire [3 : 0] s00_axis_tstrb
	//内部信号
	//.axis_data_out(axis_data_out),
	.axis_data_en(axis_data_en),			//output axi stream 数据输出使能
	.axis_data_sync(axis_data_sync),		//output axi stream 数据同步
	.axis_data_requst(axis_data_requst),	//input axi stream  数据请求
);

//-------------------------------------//
//	fifo control                	   //
//-------------------------------------//
wire 						fifo_rd_en;
wire 						fifo_empty;
wire 		[9 : 0]			fifo_rd_cnt;
	
wire						fifo_wr_en;
wire 						fifo_full;
wire 		[9 : 0]			wr_data_count;
	
wire 						lcd_data_requst;	//lcd 读请求
wire 						lcd_framesync;		//lcd 帧同步

fifo_ctl_top u_fifo_ctl_top#(
	.FIFO_DEPTH(1024),
	.FIFO_ALMOSTFULL_DEPTH(768),
	.FIFO_ALMOSTEMPTY_DEPTH(256)
)(
	//system
	clk(clk),								//input		系统时钟	140M
	rst_n(rst_n),							//input		系统复位
	//axi stream interface 
	.axis_data_en(axis_data_en),			//output axi stream 数据输出使能
	.axis_data_sync(axis_data_sync),  		//output axi stream 数据同步
	.axis_data_requst(axis_data_requst),	//input axi stream  数据请求
	//fifo port
		//read
	fifo_rd_clk(lcd_if_clk),				//input		fifo读时钟
	fifo_rd_en(fifo_rd_en),					//output	fifo读使能
	fifo_empty(fifo_empty),					//input		fifo空指示	
	fifo_rd_cnt(fifo_rd_cnt),				//input 	fifo读计数器
		//write
	fifo_wr_clk(axis_aclk),					//input		fifo写时钟
	fifo_wr_en(fifo_wr_en),					//output	fifo写使能
	fifo_full(fifo_full),					//input		fifo满指示
	fifo_wr_cnt(wr_data_count),				//input		fifo写计数器
	//lcd driver port
	lcd_framesync(lcd_framesync),			//output 	帧同步输出
	lcd_data_requst(lcd_data_requst)		//input		数据请求输入
);

//-------------------------------------//
//	fifo                			   //
//-------------------------------------//
wire 		[31:0]			fifo_wr_din;
wire 		[31:0]			fifo_rd_dout;

assign fifo_wr_din = (fifo_wr_en)?axis_tdata:32'd0;

fifo_gen u_fifo_gen (
	//system
	.rst(!rst_n),                      	// input wire rst
	//write
	.wr_clk(axis_aclk),                	// input wire wr_clk
	.wr_en(fifo_wr_en),                 // input wire wr_en
	.din(fifo_wr_din),                  // input wire [31 : 0] din
	.full(fifo_full),                   // output wire full
	.wr_data_count(wr_data_count)  		// output wire [9 : 0] wr_data_count
	//read
	.rd_clk(lcd_if_clk),                // input wire rd_clk
	.rd_en(fifo_rd_en),             	// input wire rd_en
	.dout(fifo_rd_dout),                // output wire [31 : 0] dout
	.empty(fifo_empty),                 // output wire empty
	.rd_data_count(fifo_rd_cnt),  		// output wire [9 : 0] rd_data_count
);

//-------------------------------------//
//	lcd driver interface               //
//-------------------------------------//
wire 		[23:0]			lcd_data;

assign lcd_data = (fifo_rd_en)?fifo_dout[ 23 : 0]:24'd0;

lcd_driver u_lcd_driver(
	//global clock
	.clk			(lcd_if_clk),		
	.rst_n			(rst_n), 
	 //lcd interface
	.lcd_dclk		(lcd_dclk),
	.lcd_hs			(lcd_hs),		
	.lcd_vs			(lcd_vs),
	.lcd_en			(lcd_en),		
	.lcd_rgb		(lcd_rgb),
	//user interface
	.lcd_rd_en		(fifo_rd_en),		//输入，lcd 读使能
	.lcd_request	(lcd_data_requst),	//输出，lcd 读请求
	.lcd_framesync	(lcd_framesync),	//输入，lcd 帧同步,,,应改为输入，清空计数
	.lcd_data		(lcd_data),	
	.lcd_xpos		(),	
	.lcd_ypos		()
);

endmodule


