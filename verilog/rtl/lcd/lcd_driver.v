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
module lcd_driver
(  	
	//global clock
	input			clk,			//system clock
	input			rst_n,     		//sync reset

	//lcd interface
	output			lcd_dclk,   	//lcd pixel clock
	output			lcd_hs,	    	//lcd horizontal sync
	output			lcd_vs,	    	//lcd vertical sync
	output			lcd_de,			//lcd display enable
	output	[23:0]	lcd_rgb,		//lcd display data

	//user interface
	input			lcd_rd_en,		//读使能
	output			lcd_request,	//lcd 数据请求
	output			lcd_framesync,	//lcd frame sync
	output	[10:0]	lcd_xpos,		//lcd horizontal coordinate
	output	[10:0]	lcd_ypos,		//lcd vertical coordinate
	input	[23:0]	lcd_data		//lcd data
);	 
`include "lcd_para.v"  

/*******************************************
		SYNC--BACK--DISP--FRONT
*******************************************/
//------------------------------------------
//h_sync counter & generator
reg [10:0] hcnt; 
always @ (posedge clk or negedge rst_n)
begin
	//if ((!rst_n)&&(lcd_framesync))
	if (!rst_n)
		hcnt <= 11'd0;
	else
		begin
        if(hcnt < `H_TOTAL - 1'b1)		//line over			
            hcnt <= hcnt + 1'b1;
        else
            hcnt <= 11'd0;
		end
end 
assign	lcd_hs = (hcnt <= `H_SYNC - 1'b1) ? 1'b0 : 1'b1;

//------------------------------------------
//v_sync counter & generator
reg [10:0] vcnt;
always@(posedge clk or negedge rst_n)
begin
	//if ((!rst_n)&&(lcd_framesync))
	if (!rst_n)
		vcnt <= 11'b0;
	else if(hcnt == `H_TOTAL - 1'b1)		//line over
		begin
		if(vcnt < `V_TOTAL - 1'b1)		//frame over
			vcnt <= vcnt + 1'b1;
		else
			vcnt <= 11'd0;
		end
end
assign	lcd_vs = (vcnt <= `V_SYNC - 1'b1) ? 1'b0 : 1'b1;

//------------------------------------------
//LCELL	LCELL(.in(clk),.out(lcd_dclk));
assign	lcd_dclk = ~clk;
//assign	lcd_blank = lcd_de;//lcd_hs & lcd_vs;		
//assign	lcd_sync = 1'b0;
assign	lcd_de		=	(hcnt >= `H_SYNC + `H_BACK  && hcnt < `H_SYNC + `H_BACK + `H_DISP) &&
						(vcnt >= `V_SYNC + `V_BACK  && vcnt < `V_SYNC + `V_BACK + `V_DISP) 
						? 1'b1 : 1'b0;
//assign	lcd_rgb 	=  (lcd_de && lcd_request) ? lcd_data : 24'd0;
assign	lcd_rgb 	=  (lcd_de) ? lcd_data : 24'd0;

//抓取同步信号
reg lcd_vs_edge1;
reg lcd_vs_edge2;
always @(posedge clk)begin
	if(!rst_n)
	begin
		lcd_vs_edge1 <= 0;
		lcd_vs_edge2 <= 0;
	end
	else 
	begin 
		lcd_vs_edge1 <= lcd_vs;
		lcd_vs_edge2 <= lcd_vs_edge1;
	end
end

assign	lcd_framesync = (lcd_vs&&(!lcd_vs_edge2))? 1 :0 ;	//取出场同步信号上升沿作为同步,2个时钟沿


//------------------------------------------
//ahead 1 clock
assign	lcd_request	=	(hcnt >= `H_SYNC + `H_BACK  - 2'd1 && hcnt < `H_SYNC + `H_BACK + `H_DISP - 2'd1) &&
						(vcnt >= `V_SYNC + `V_BACK && vcnt < `V_SYNC + `V_BACK + `V_DISP) 
						? 1'b1 : 1'b0;
assign	lcd_xpos	= 	lcd_request ? (hcnt - (`H_SYNC + `H_BACK  - 1'b1)) : 11'd0;
assign	lcd_ypos	= 	lcd_request ? (vcnt - (`V_SYNC + `V_BACK - 1'b1)) : 11'd0;		

endmodule

