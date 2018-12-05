/*-------------------------------------------------------------------------
===========================================================================
Filename			:		lcd_top.v
Author				:		bh1whq
Data				:		2018-11-29
Version				:		1.0
Description			:		lcd controller with fifo and axi stream interface.
Modification History	:
Data			By			Version			Change Description
===========================================================================
--------------------------------------------------------------------------*/
module lcd_top(  	
	//global clock
	input				rst_n,     			//sync reset
	input				clk,				//system clock
	input 				lcd_pixel_clk,		//9M时钟输入
	//axi stream interface 
	input 				axis_aresetn,		// input wire s00_axis_aresetn
	input 				axis_aclk,        	// input wire s00_axis_aclk
	input 	[31:0] 		axis_tdata,     	// input wire [31 : 0] write data
	input 				axis_tvalid,    	// 数据有效，从机为输入
	output				axis_tready,    	// 数据输入准备，从机为输出
	input 	[0 : 0]		axis_tuser,			// input wire frame sync
	input 				axis_tlast,      	// input wire axis_tlast
	input 				axis_tstrb,      	// input wire [3 : 0] axis_tstrb
	input	[3 : 0]		axis_tkeep,
	//lcd interface
	output				lcd_dclk,   		//lcd pixel clock
	output				lcd_hs,	    		//lcd horizontal sync
	output				lcd_vs,	    		//lcd vertical sync
	output				lcd_de,				//lcd display enable
	output	[23:0]		lcd_rgb,			//lcd display data
	output 				lcd_framesync,		//lcd 同步信号
	output	[10:0]		lcd_xpos,			//lcd horizontal coordinate
	output	[10:0]		lcd_ypos			//lcd vertical coordinate
);
	  
//--------------------------------------------------------------------------//	
	//signal
	wire 				lcd_pixel_clk;

	wire 				axis_data_en;			//output axi stream 数据输出使能
	wire 				axis_data_sync;        	//output axi stream 数据同步
	wire 				axis_data_requst;      	//input axi stream  数据请求
//--------------------------------------------------------------------------//	
	parameter 			FIFO_DEPTH = 1024;
	parameter			FIFO_ALMOSTFULL_DEPTH = 1000;
	parameter			FIFO_ALMOSTEMPTY_DEPTH = 64;
//--------------------------------------------------------------------------//	
//-------------------------------------//
//	lcd driver interface               //
//-------------------------------------//
axis_if u_axis_if(
	//axi stream interface
	.axis_aresetn(axis_aresetn),			// input wire s00_axis_aresetn
	.axis_aclk(axis_aclk),        			// input wire s00_axis_aclk
	.axis_tvalid(axis_tvalid),    			// input wire s00_axis_tvalid
	.axis_tready(axis_tready),    			// output wire read data ready
	.axis_tuser(),							// input wire frame sync
	.axis_tlast(),      					// input wire s00_axis_tlast
	.axis_tstrb(),      					// input wire [3 : 0] s00_axis_tstrb
	//内部信号
	.axis_data_en(axis_data_en),			//output axi stream 数据输出使能
	.axis_data_sync(axis_data_sync),		//output axi stream 数据同步
	.axis_data_requst(axis_data_requst)		//input axi stream  数据请求
);

//-------------------------------------//
//	fifo control                	   //
//-------------------------------------//
	wire 						fifo_rd_en;
	wire 						fifo_empty;
	wire 		[9 : 0]			fifo_rd_cnt;
		
	wire						fifo_wr_en;
	wire 						fifo_full;
	wire 		[9 : 0]			fifo_wr_cnt;
		
	wire 						lcd_data_requst;	//lcd 读请求
	wire 						lcd_framesync;		//lcd 帧同步

fifo_ctl_top #(
	.FIFO_DEPTH(FIFO_DEPTH),
	.FIFO_ALMOSTFULL_DEPTH(FIFO_ALMOSTFULL_DEPTH),
	.FIFO_ALMOSTEMPTY_DEPTH(FIFO_ALMOSTEMPTY_DEPTH)
)u_fifo_ctl_top(
	//system
	.rst_n(rst_n||(!lcd_framesync)),		//input		系统复位
	//axi stream interface 
	.axis_data_en(axis_data_en),			//output axi stream 数据输出使能
	.axis_data_requst(axis_data_requst),	//outpt axi stream  数据请求
	//fifo port
		//read
	.fifo_rd_clk(lcd_pixel_clk),			//input		fifo读时钟
	.fifo_rd_en(fifo_rd_en),				//output	fifo读使能
	.fifo_empty(fifo_empty),				//input		fifo空指示	
	.fifo_rd_cnt(fifo_rd_cnt),				//input 	fifo读计数器
		//write
	.fifo_wr_clk(axis_aclk),				//input		fifo写时钟
	.fifo_wr_en(fifo_wr_en),				//output	fifo写使能
	.fifo_full(fifo_full),					//input		fifo满指示
	.fifo_wr_cnt(fifo_wr_cnt),				//input		fifo写计数器
	//lcd driver port
	.rd_data_requst(lcd_data_requst)		//input		数据请求输入
);

//-------------------------------------//
//	fifo                			   //
//-------------------------------------//
	wire 		[31:0]			fifo_wr_din;
	wire 		[31:0]			fifo_rd_dout;

assign fifo_wr_din = (fifo_wr_en)?axis_tdata:32'd0;

lcd_rdfifo u_lcd_rdfifo(
	//system
	.rst((!rst_n)||(lcd_framesync)),      // input wire rst
	//write
	.wr_clk(axis_aclk),                	// input wire wr_clk
	.wr_en(fifo_wr_en),                 // input wire wr_en
	.din(fifo_wr_din),                  // input wire [31 : 0] din
	.full(fifo_full),                   // output wire full
	.wr_data_count(fifo_wr_cnt), 		// output wire [9 : 0] wr_data_count
	//read
	.rd_clk(lcd_pixel_clk),             // input wire rd_clk
	.rd_en(fifo_rd_en),             	// input wire rd_en
	.dout(fifo_rd_dout),                // output wire [31 : 0] dout
	.empty(fifo_empty),                 // output wire empty
	.rd_data_count(fifo_rd_cnt)  		// output wire [9 : 0] rd_data_count
);

//-------------------------------------//
//	lcd driver interface               //
//-------------------------------------//
wire 		[23:0]			lcd_data;

assign lcd_data = (fifo_rd_en) ? fifo_rd_dout[ 23 : 0] : 24'd0;

//暂时不引入帧同步，帧同步需要master发出，并且在该模块中有跨时钟域问题，需要注意
//assign						lcd_framesync = 1;

lcd_driver u_lcd_driver(
	//global clock
	.clk			(lcd_pixel_clk),		
	.rst_n			(rst_n), 
	 //lcd interface
	.lcd_dclk		(lcd_dclk),
	.lcd_hs			(lcd_hs),		
	.lcd_vs			(lcd_vs),
	.lcd_de			(lcd_de),		
	.lcd_rgb		(lcd_rgb),
	//user interface
	.lcd_rd_en		(fifo_rd_en),		//输入，lcd 读使能
	.lcd_request	(lcd_data_requst),	//输出，lcd 读请求
	.lcd_framesync	(lcd_framesync),	//输入，lcd 帧同步,应改为输入，清空计数
	.lcd_data		(lcd_data),	
	.lcd_xpos		(lcd_xpos),	
	.lcd_ypos		(lcd_ypos)
);

endmodule


