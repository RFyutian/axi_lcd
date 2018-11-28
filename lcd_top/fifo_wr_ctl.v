module fifo_wr_ctl #(
	parameter integer FIFO_ALMOSTFULL_DEPTH
)(
	//system
	rst_n,
	//axi stream
	axis_data_en,
	axis_data_sync,
	axis_data_requst,
	//fifo write
	fifo_wr_clk,
	fifo_wr_en,
	fifo_full,
	fifo_wr_cnt,
	//lcd
	lcd_framesync
);	

assign lcd_framesync = axis_data_requst;




endmodule








