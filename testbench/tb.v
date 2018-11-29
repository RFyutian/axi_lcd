module tb;
    
	reg 				rst_n;
	reg 				wr_clk;	//140M时钟输入	
	reg 				rd_clk;		//9M时钟输入
		
	//axi stream interface 	
	reg 	[31:0] 		axis_tdata;     	// reg wire [31 : 0] write data	
	reg 				axis_tvalid;    	// 数据有效，从机为输入	
	wire				axis_tready;    	// 数据输入准备，从机为输出	
	//reg 				axis_tuser;			// reg wire frame sync	
	//reg 				axis_tlast;      	// reg wire axis_tlast	
	//reg 				axis_tstrb;      	// reg wire [3 : 0] axis_tstrb	

	//lcd interface	
	wire				lcd_dclk;   		//lcd pixel clock	
	wire				lcd_hs;	    		//lcd horizontal sync	
	wire				lcd_vs;	    		//lcd vertical sync	
	wire				lcd_de;				//lcd display enable	
	wire	[23:0]		lcd_rgb;			//lcd display data	
	wire	[10:0]		lcd_xpos;
	wire	[10:0]		lcd_ypos;

	parameter 			FrameMaxCnt = 130560;			//480*272 = 130560 同步最大帧
	reg 	[31:0]		FrameSyncCnt;
	wire 				FrameSyncFlag;
//--------------------------------------------------------------------------//	

initial	
begin
	wr_clk = 0;
	rd_clk = 0;
	
    rst_n = 0;
    #20000
    rst_n = 1;
end

always #1 wr_clk = ~wr_clk;
always #10 rd_clk = ~rd_clk;		

//--------------------------------------------------------------------------//	
initial 
begin
	//axi stream
	axis_tdata = 0;
	axis_tvalid = 0;
	#30000
	@(posedge wr_clk) axis_tvalid = 1;			//数据一直可以传输
end 

always @(posedge wr_clk)
begin
	if(!rst_n)
	begin
		FrameSyncCnt <= 32'd0;
	end
	else
	begin
		if(axis_tready&&axis_tvalid)
		begin
			if(FrameSyncCnt < FrameMaxCnt - 1) 
			begin
				FrameSyncCnt <= FrameSyncCnt + 1;
			end
			else 
			begin
				FrameSyncCnt <= 32'd0;
			end
		end
	end	
end

assign FrameSyncFlag = (FrameSyncCnt == 32'd0)? 32'd1 : 32'd0;

always @(posedge wr_clk)
begin
	if(!rst_n)
	begin
		axis_tdata = 32'd0;
	end
	else
	begin
		if(axis_tready&&axis_tvalid) 
		begin
			if(axis_tdata < FrameMaxCnt - 1) 
			begin
				axis_tdata <= axis_tdata + 1;
			end
			else 
			begin
				axis_tdata <= 32'd0;
			end
		end
	end
end

lcd_top u_lcd_top(  	
	//global clock
	.rst_n(rst_n),     				//sync reset
	.clk(wr_clk),					//system clock
	.lcd_pixel_clk(rd_clk),			//9M时钟输入
	//axi stream interface 
	.axis_aresetn(rst_n),			// reg wire s00_axis_aresetn
	.axis_aclk(wr_clk),        		// reg wire s00_axis_aclk
	.axis_tdata(axis_tdata),     	// reg wire [31 : 0] write data
	.axis_tvalid(axis_tvalid),    	// 数据有效，从机为输入
	.axis_tready(axis_tready),    	// 数据输入准备，从机为输出
	.axis_tuser(FrameSyncFlag),		// reg wire frame sync
	.axis_tlast(),      			// reg wire axis_tlast
	.axis_tstrb(),      			// reg wire [3 : 0] axis_tstrb
	//lcd interface
	.lcd_dclk(lcd_dclk),   			//lcd pixel clock
	.lcd_hs(lcd_hs),	    		//lcd horizontal sync
	.lcd_vs(lcd_vs),	    		//lcd vertical sync
	.lcd_de(lcd_de),				//lcd display enable
	.lcd_rgb(lcd_rgb),				//lcd display data
	.lcd_xpos(lcd_xpos),
	.lcd_ypos(lcd_ypos)
);

endmodule



