module tb;
    
reg 				rst_n;
reg 				wr_clk;	//140M时钟输入	
reg 				rd_clk;		//9M时钟输入
	
//axi stream interface 	
reg 	[31:0] 		axis_tdata;     	// reg wire [31 : 0] write data	
reg 				axis_tvalid;    	// 数据有效，从机为输入	
wire				axis_tready;    	// 数据输入准备，从机为输出	
reg 				axis_tuser;			// reg wire frame sync	
reg 				axis_tlast;      	// reg wire axis_tlast	
reg 				axis_tstrb;      	// reg wire [3 : 0] axis_tstrb	
//lcd interface	
wire				lcd_dclk;   		//lcd pixel clock	
wire				lcd_blank;			//lcd blank	
wire				lcd_sync;			//lcd sync	
wire				lcd_hs;	    		//lcd horizontal sync	
wire				lcd_vs;	    		//lcd vertical sync	
wire				lcd_en;				//lcd display enable	
wire	[23:0]		lcd_rgb;			//lcd display data	

initial
begin
	wr_clk = 0;
	rd_clk = 0;
	
    rst_n = 0;
    #50
    rst_n = 1;
end

always #1 wr_clk = ~wr_clk;
always #10 rd_clk = ~rd_clk;		


initial 
begin
//axi stream
axis_tdata = 0;
axis_tvalid = 0;
axis_tuser = 0;
axis_tlast = 0;
axis_tstrb = 0;
#50;
axis_tvalid = 1;			//数据一直可以传输
end 

always@(posedge wr_clk)begin
	if(!rst_n)begin
		axis_tdata = 32'd0;
	end
	else
	begin
		if(axis_tready) begin
			axis_tdata = axis_tdata + 1;
		end
	end
end

lcd_top u_lcd_top(  	
	//global clock
	.rst_n(rst_n),     				//sync reset
	.clk(wr_clk),					//system clock
	.lcd_if_clk(rd_clk),			//9M时钟输入
	//axi stream interface 
	.axis_aresetn(rst_n),			// reg wire s00_axis_aresetn
	.axis_aclk(wr_clk),        		// reg wire s00_axis_aclk
	.axis_tdata(axis_tdata),     	// reg wire [31 : 0] write data
	.axis_tvalid(axis_tvalid),    	// 数据有效，从机为输入
	.axis_tready(axis_tready),    	// 数据输入准备，从机为输出
	.axis_tuser(axis_tuser),			// reg wire frame sync
	.axis_tlast(axis_tlast),      	// reg wire axis_tlast
	.axis_tstrb(axis_tstrb),      	// reg wire [3 : 0] axis_tstrb
	//lcd interface
	.lcd_dclk(lcd_dclk),   			//lcd pixel clock
	.lcd_blank(lcd_blank),			//lcd blank
	.lcd_sync(lcd_sync),			//lcd sync
	.lcd_hs(lcd_hs),	    		//lcd horizontal sync
	.lcd_vs(lcd_vs),	    		//lcd vertical sync
	.lcd_en(lcd_en),				//lcd display enable
	.lcd_rgb(lcd_rgb)				//lcd display data
);

endmodule



