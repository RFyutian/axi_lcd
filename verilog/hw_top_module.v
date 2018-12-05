`timescale 1ns / 1ps

module hw_top_module(
	//ddr
	DDR_addr,
	DDR_ba,
	DDR_cas_n,
	DDR_ck_n,
	DDR_ck_p,
	DDR_cke,
	DDR_cs_n,
	DDR_dm,
	DDR_dq,
	DDR_dqs_n,
	DDR_dqs_p,
	DDR_odt,
	DDR_ras_n,
	DDR_reset_n,
	DDR_we_n,
	//ps io
	FIXED_IO_ddr_vrn,
	FIXED_IO_ddr_vrp,
	FIXED_IO_mio,
	FIXED_IO_ps_clk,
	FIXED_IO_ps_porb,
	FIXED_IO_ps_srstb,
	//iic
	iic_0_scl_io,
	iic_0_sda_io,
	//lcd interface 
	lcd_dclk,	
	lcd_hs,		
	lcd_vs,		
	lcd_de,		
	lcd_rgb
);

	inout 		[14:0]			DDR_addr;
	inout 		[2:0]			DDR_ba;
	inout 						DDR_cas_n;
	inout 						DDR_ck_n;
	inout 						DDR_ck_p;
	inout 						DDR_cke;
	inout 						DDR_cs_n;
	inout 		[3:0]			DDR_dm;
	inout 		[31:0]			DDR_dq;
	inout 		[3:0]			DDR_dqs_n;
	inout 		[3:0]			DDR_dqs_p;
	inout 						DDR_odt;
	inout 						DDR_ras_n;
	inout 						DDR_reset_n;
	inout 						DDR_we_n;
	inout 						FIXED_IO_ddr_vrn;
	inout 						FIXED_IO_ddr_vrp;
	inout 		[53:0]			FIXED_IO_mio;
	inout 						FIXED_IO_ps_clk;
	inout 						FIXED_IO_ps_porb;
	inout 						FIXED_IO_ps_srstb;
	//iic 
	inout 						iic_0_scl_io;
	inout 						iic_0_sda_io;
	//lcd pin out
	output 						lcd_dclk;
	output 						lcd_hs;
	output 						lcd_vs;	
	output 						lcd_de;	
	output 		[23:0]			lcd_rgb;
	
	
//--------------------------------------------------------------------------//	
//global
	wire						FCLK_140M;
	wire						FCLK_9M;		
	wire						IRQ_F2P;
	wire 						FCLK_RESET0_N;
//lcd vdma axi lite signal
	wire 						s_lcd_cfgaxi_awvalid;
	wire 						s_lcd_cfgaxi_awready;
	wire 		[8 : 0]			s_lcd_cfgaxi_awaddr;
	wire 						s_lcd_cfgaxi_wvalid;
	wire 						s_lcd_cfgaxi_wready;
	wire 		[31 : 0]		s_lcd_cfgaxi_wdata;
	wire 		[1 : 0]			s_lcd_cfgaxi_bresp;
	wire 						s_lcd_cfgaxi_bvalid;
	wire 						s_lcd_cfgaxi_bready;
	wire 						s_lcd_cfgaxi_arvalid;
	wire 						s_lcd_cfgaxi_arready;
	wire 		[8 : 0]			s_lcd_cfgaxi_araddr;
	wire 						s_lcd_cfgaxi_rvalid;
	wire 						s_lcd_cfgaxi_rready;
	wire 		[31 : 0]		s_lcd_cfgaxi_rdata;
	wire 		[1 : 0]			s_lcd_cfgaxi_rresp;
//lcd vdma 连接zynq
	wire  		[31 : 0]		m_lcd_axi_araddr;
	wire  		[7 : 0]			m_lcd_axi_arlen;            
	wire  		[2 : 0]			m_lcd_axi_arsize;         
	wire  		[1 : 0]			m_lcd_axi_arburst;         
	wire  		[2 : 0] 		m_lcd_axi_arprot;           
	wire  		[3 : 0]			m_lcd_axi_arcache;         
	wire  						m_lcd_axi_arvalid;          
	wire  						m_lcd_axi_arready;          
	wire  		[63 : 0]		m_lcd_axi_rdata;            
	wire  		[1 : 0]			m_lcd_axi_rresp;         
	wire  						m_lcd_axi_rlast;         
	wire  						m_lcd_axi_rvalid;         
	wire  						m_lcd_axi_rready;           
//vdma 中断
	wire						lcd_vdma_introut;
//lcd 帧同步信号
	wire 						lcd_framesync;
//lcd vdma axi stream out 连接lcd驱动
	wire		[31:0]			m_lcd_mm2s_tdata;
	wire		[3 : 0]			m_lcd_mm2s_tkeep;
	wire		[0 : 0]			m_lcd_mm2s_tuser;
	wire						m_lcd_mm2s_tvalid;
	wire						m_lcd_mm2s_tready;
	wire						m_lcd_mm2s_tlast;
//lcd pinout 
	wire 		[23:0]			lcd_rgb;
	wire 						lcd_dclk;
	wire 						lcd_hs;
	wire 						lcd_vs;	
	wire 						lcd_de;	
//iic 0 pinout
	wire 						iic_0_scl_io;
	wire 						iic_0_sda_io;	
//--------------------------------------------------------------------------//	
	
ps_block_wrapper u_ps_block(
	//ddr
	.DDR_addr					(DDR_addr),
	.DDR_ba						(DDR_ba),
	.DDR_cas_n					(DDR_cas_n),
	.DDR_ck_n					(DDR_ck_n),
	.DDR_ck_p					(DDR_ck_p),
	.DDR_cke					(DDR_cke),
	.DDR_cs_n					(DDR_cs_n),
	.DDR_dm						(DDR_dm),
	.DDR_dq						(DDR_dq),
	.DDR_dqs_n					(DDR_dqs_n),
	.DDR_dqs_p					(DDR_dqs_p),
	.DDR_odt					(DDR_odt),
	.DDR_ras_n					(DDR_ras_n),
	.DDR_reset_n				(DDR_reset_n),
	.DDR_we_n					(DDR_we_n),
	//fixed io	
	.FIXED_IO_ddr_vrn			(FIXED_IO_ddr_vrn),
	.FIXED_IO_ddr_vrp			(FIXED_IO_ddr_vrp),
	.FIXED_IO_mio				(FIXED_IO_mio),
	.FIXED_IO_ps_clk			(FIXED_IO_ps_clk),
	.FIXED_IO_ps_porb			(FIXED_IO_ps_porb),
	.FIXED_IO_ps_srstb			(FIXED_IO_ps_srstb),
	//inner clk 	
	.FCLK_140M					(FCLK_140M),
	.FCLK_9M					(FCLK_9M),
	//interrupt	
    .IRQ_F2P					(IRQ_F2P),
	//reset
	.FCLK_RESET0_N				(FCLK_RESET0_N),
	//axi4 - m00  -vdma cfg
	.M00_AXI_LCD_VDMA_araddr	(s_lcd_cfgaxi_araddr),											
	.M00_AXI_LCD_VDMA_arburst	(),                                                              
	.M00_AXI_LCD_VDMA_arcache	(),                                                              
	.M00_AXI_LCD_VDMA_arid		(),                                                              
	.M00_AXI_LCD_VDMA_arlen 	(),                                                              
	.M00_AXI_LCD_VDMA_arlock	(),                                                              
	.M00_AXI_LCD_VDMA_arprot	(),                                                              
	.M00_AXI_LCD_VDMA_arqos		(),                                                              
	.M00_AXI_LCD_VDMA_arready	(s_lcd_cfgaxi_arready),                                          
	.M00_AXI_LCD_VDMA_arregion	(),                                                              
	.M00_AXI_LCD_VDMA_arsize	(),                                                              
	.M00_AXI_LCD_VDMA_arvalid	(s_lcd_cfgaxi_arvalid),                                          
	.M00_AXI_LCD_VDMA_awaddr	(s_lcd_cfgaxi_awaddr),                                           
	.M00_AXI_LCD_VDMA_awburst	(),	                                                             
	.M00_AXI_LCD_VDMA_awcache	(),                                                              
	.M00_AXI_LCD_VDMA_awid		(),                                                              
	.M00_AXI_LCD_VDMA_awlen		(),
	.M00_AXI_LCD_VDMA_awlock	(),
	.M00_AXI_LCD_VDMA_awprot	(),
	.M00_AXI_LCD_VDMA_awqos		(),
	.M00_AXI_LCD_VDMA_awready	(s_lcd_cfgaxi_awready),
	.M00_AXI_LCD_VDMA_awregion	(),
	.M00_AXI_LCD_VDMA_awsize	(),
	.M00_AXI_LCD_VDMA_awvalid	(s_lcd_cfgaxi_awvalid),
	.M00_AXI_LCD_VDMA_bid		(),
	.M00_AXI_LCD_VDMA_bready	(s_lcd_cfgaxi_bready),
	.M00_AXI_LCD_VDMA_bresp		(s_lcd_cfgaxi_bresp),
	.M00_AXI_LCD_VDMA_bvalid	(s_lcd_cfgaxi_bvalid),
	.M00_AXI_LCD_VDMA_rdata		(s_lcd_cfgaxi_rdata),
	.M00_AXI_LCD_VDMA_rid		(),
	.M00_AXI_LCD_VDMA_rlast		(),
	.M00_AXI_LCD_VDMA_rready	(s_lcd_cfgaxi_rready),
	.M00_AXI_LCD_VDMA_rresp		(s_lcd_cfgaxi_rresp),
	.M00_AXI_LCD_VDMA_rvalid	(s_lcd_cfgaxi_rvalid),
	.M00_AXI_LCD_VDMA_wdata		(s_lcd_cfgaxi_wdata),				
	.M00_AXI_LCD_VDMA_wlast		(),
	.M00_AXI_LCD_VDMA_wready	(s_lcd_cfgaxi_wready),				
	.M00_AXI_LCD_VDMA_wstrb		(),				
	.M00_AXI_LCD_VDMA_wvalid	(s_lcd_cfgaxi_wvalid),
	//axi4 - m01
	.M01_AXI_araddr				(),
	.M01_AXI_arburst			(),
	.M01_AXI_arcache			(),
	.M01_AXI_arid				(),
	.M01_AXI_arlen				(),
	.M01_AXI_arlock				(),
	.M01_AXI_arprot				(),
	.M01_AXI_arqos				(),
	.M01_AXI_arready			(),
	.M01_AXI_arregion			(),
	.M01_AXI_arsize				(),
	.M01_AXI_arvalid			(),
	.M01_AXI_awaddr				(),
	.M01_AXI_awburst			(),
	.M01_AXI_awcache			(),
	.M01_AXI_awid				(),
	.M01_AXI_awlen				(),
	.M01_AXI_awlock				(),
	.M01_AXI_awprot				(),
	.M01_AXI_awqos				(),
	.M01_AXI_awready			(),
	.M01_AXI_awregion			(),
	.M01_AXI_awsize				(),
	.M01_AXI_awvalid			(),
	.M01_AXI_bid				(),
	.M01_AXI_bready				(),
	.M01_AXI_bresp				(),
	.M01_AXI_bvalid				(),
	.M01_AXI_rdata				(),
	.M01_AXI_rid				(),
	.M01_AXI_rlast				(),
	.M01_AXI_rready				(),
	.M01_AXI_rresp				(),
	.M01_AXI_rvalid				(),
	.M01_AXI_wdata				(),
	.M01_AXI_wlast				(),
	.M01_AXI_wready				(),
	.M01_AXI_wstrb				(),
	.M01_AXI_wvalid				(),
	//axi hp0 - s00
    .S00_AXIS_VDMA_araddr		(m_lcd_axi_araddr),                                                                  
    .S00_AXIS_VDMA_arburst		(m_lcd_axi_arburst),                                                                 
    .S00_AXIS_VDMA_arcache		(m_lcd_axi_arcache),                                                                 
    .S00_AXIS_VDMA_arid			(),                                                                    
    .S00_AXIS_VDMA_arlen		(m_lcd_axi_arlen),                                                                   
    .S00_AXIS_VDMA_arlock		(),                                                                  
    .S00_AXIS_VDMA_arprot		(m_lcd_axi_arprot),                                                                  
    .S00_AXIS_VDMA_arqos		(),                                                                   
    .S00_AXIS_VDMA_arready		(m_lcd_axi_arready),                                                                 
    .S00_AXIS_VDMA_arsize		(m_lcd_axi_arsize),                                                                  
    .S00_AXIS_VDMA_arvalid		(m_lcd_axi_arvalid),  
    .S00_AXIS_VDMA_awaddr		(),                                                                  
    .S00_AXIS_VDMA_awburst		(),                                                                 
    .S00_AXIS_VDMA_awcache		(),
    .S00_AXIS_VDMA_awid			(),
    .S00_AXIS_VDMA_awlen		(),
    .S00_AXIS_VDMA_awlock		(),
    .S00_AXIS_VDMA_awprot		(),
    .S00_AXIS_VDMA_awqos		(),
    .S00_AXIS_VDMA_awready		(),
    .S00_AXIS_VDMA_awsize		(),
    .S00_AXIS_VDMA_awvalid		(),
    .S00_AXIS_VDMA_bid			(),
    .S00_AXIS_VDMA_bready		(),
    .S00_AXIS_VDMA_bresp		(),
    .S00_AXIS_VDMA_bvalid		(),
    .S00_AXIS_VDMA_rdata		(m_lcd_axi_rdata),
    .S00_AXIS_VDMA_rid			(),
    .S00_AXIS_VDMA_rlast		(m_lcd_axi_rlast),
    .S00_AXIS_VDMA_rready		(m_lcd_axi_rready),
    .S00_AXIS_VDMA_rresp		(m_lcd_axi_rresp),
    .S00_AXIS_VDMA_rvalid		(m_lcd_axi_rvalid),
    .S00_AXIS_VDMA_wdata		(),
    .S00_AXIS_VDMA_wid			(),
    .S00_AXIS_VDMA_wlast		(),
    .S00_AXIS_VDMA_wready		(),
    .S00_AXIS_VDMA_wstrb		(),
    .S00_AXIS_VDMA_wvalid		(),
	//iic
    .iic_0_scl_io				(iic_0_scl_io),
    .iic_0_sda_io				(iic_0_sda_io)
);

lcd_vdma u_lcd_vdma(
	//global
	.s_axi_lite_aclk			(FCLK_140M),        		// input wire s_axi_lite_aclk
	.m_axi_mm2s_aclk			(FCLK_140M),        		// input wire m_axi_mm2s_aclk
	.m_axis_mm2s_aclk			(FCLK_140M),      			// input wire m_axis_mm2s_aclk
	.axi_resetn					(FCLK_RESET0_N),			// input wire axi_resetn
	//axi 4 - lite 配置vdma
	.s_axi_lite_awvalid			(s_lcd_cfgaxi_awvalid),  	// input wire s_axi_lite_awvalid
	.s_axi_lite_awready			(s_lcd_cfgaxi_awready),  	// output wire s_axi_lite_awready
	.s_axi_lite_awaddr			(s_lcd_cfgaxi_awaddr),    	// input wire [8 : 0] s_axi_lite_awaddr
	.s_axi_lite_wvalid			(s_lcd_cfgaxi_wvalid),    	// input wire s_axi_lite_wvalid
	.s_axi_lite_wready			(s_lcd_cfgaxi_wready),    	// output wire s_axi_lite_wready
	.s_axi_lite_wdata			(s_lcd_cfgaxi_wdata),      	// input wire [31 : 0] s_axi_lite_wdata
	.s_axi_lite_bresp			(s_lcd_cfgaxi_bresp),      	// output wire [1 : 0] s_axi_lite_bresp
	.s_axi_lite_bvalid			(s_lcd_cfgaxi_bvalid),    	// output wire s_axi_lite_bvalid
	.s_axi_lite_bready			(s_lcd_cfgaxi_bready),    	// input wire s_axi_lite_bready
	.s_axi_lite_arvalid			(s_lcd_cfgaxi_arvalid),  	// input wire s_axi_lite_arvalid
	.s_axi_lite_arready			(s_lcd_cfgaxi_arready),  	// output wire s_axi_lite_arready
	.s_axi_lite_araddr			(s_lcd_cfgaxi_araddr),		// input wire [8 : 0] s_axi_lite_araddr
	.s_axi_lite_rvalid			(s_lcd_cfgaxi_rvalid),		// output wire s_axi_lite_rvalid
	.s_axi_lite_rready			(s_lcd_cfgaxi_rready),		// input wire s_axi_lite_rready
	.s_axi_lite_rdata			(s_lcd_cfgaxi_rdata),      	// output wire [31 : 0] s_axi_lite_rdata
	.s_axi_lite_rresp			(s_lcd_cfgaxi_rresp),      	// output wire [1 : 0] s_axi_lite_rresp
	//axi4 master  连接zynq
	.m_axi_mm2s_araddr			(m_lcd_axi_araddr),    		// output wire [31 : 0] m_axi_mm2s_araddr
	.m_axi_mm2s_arlen			(m_lcd_axi_arlen),      	// output wire [7 : 0] m_axi_mm2s_arlen
	.m_axi_mm2s_arsize			(m_lcd_axi_arsize),    		// output wire [2 : 0] m_axi_mm2s_arsize
	.m_axi_mm2s_arburst			(m_lcd_axi_arburst),  		// output wire [1 : 0] m_axi_mm2s_arburst
	.m_axi_mm2s_arprot			(m_lcd_axi_arprot),    		// output wire [2 : 0] m_axi_mm2s_arprot
	.m_axi_mm2s_arcache			(m_lcd_axi_arcache),  		// output wire [3 : 0] m_axi_mm2s_arcache
	.m_axi_mm2s_arvalid			(m_lcd_axi_arvalid),  		// output wire m_axi_mm2s_arvalid
	.m_axi_mm2s_arready			(m_lcd_axi_arready),  		// input wire m_axi_mm2s_arready
	.m_axi_mm2s_rdata			(m_lcd_axi_rdata),      	// input wire [63 : 0] m_axi_mm2s_rdata
	.m_axi_mm2s_rresp			(m_lcd_axi_rresp),      	// input wire [1 : 0] m_axi_mm2s_rresp
	.m_axi_mm2s_rlast			(m_lcd_axi_rlast),      	// input wire m_axi_mm2s_rlast
	.m_axi_mm2s_rvalid			(m_lcd_axi_rvalid),    		// input wire m_axi_mm2s_rvalid
	.m_axi_mm2s_rready			(m_lcd_axi_rready),    		// output wire m_axi_mm2s_rready
	//axi stream 连接lcd驱动
	.m_axis_mm2s_tdata			(m_lcd_mm2s_tdata),    		// output wire [31 : 0] m_axis_mm2s_tdata
	.m_axis_mm2s_tkeep			(m_lcd_mm2s_tkeep),    		// output wire [3 : 0] m_axis_mm2s_tkeep
	.m_axis_mm2s_tuser			(m_lcd_mm2s_tuser),    		// output wire [0 : 0] m_axis_mm2s_tuser
	.m_axis_mm2s_tvalid			(m_lcd_mm2s_tvalid),  		// output wire m_axis_mm2s_tvalid
	.m_axis_mm2s_tready			(m_lcd_mm2s_tready),  		// input wire m_axis_mm2s_tready
	.m_axis_mm2s_tlast			(m_lcd_mm2s_tlast),    		// output wire m_axis_mm2s_tlast
	
	//cfg
	.mm2s_frame_ptr_out			(),  						// output wire [5 : 0] mm2s_frame_ptr_out
	.mm2s_fsync					(lcd_framesync),            // input wire mm2s_fsync
	.mm2s_introut				(lcd_vdma_introut)          // output wire mm2s_introut
);

lcd_top u_lcd_module(  	
	//global clock
	.rst_n						(FCLK_RESET0_N),     		//sync reset
	.lcd_pixel_clk				(FCLK_9M),					//9M时钟输入
	//axi stream interface 	
	.axis_aresetn				(FCLK_RESET0_N),			// input wire s00_axis_aresetn				
	.axis_aclk					(FCLK_140M),        		// input wire s00_axis_aclk                     
	.axis_tdata					(m_lcd_mm2s_tdata),     	// input wire [31 : 0] write data               
	.axis_tvalid				(m_lcd_mm2s_tvalid),    	// 数据有效，从机为输入                         
	.axis_tready				(m_lcd_mm2s_tready),    	// 数据输入准备，从机为输出                     
	.axis_tuser					(m_lcd_mm2s_tuser),			// input wire frame sync                         
	.axis_tlast					(m_lcd_mm2s_tlast),      	// input wire axis_tlast
	.axis_tstrb					(),      					// input wire [3 : 0] axis_tstrb
	.axis_tkeep					(m_lcd_mm2s_tkeep),			
	//lcd interface	
	.lcd_dclk					(lcd_dclk),   				//lcd pixel clock
	.lcd_hs						(lcd_hs),	    			//lcd horizontal sync
	.lcd_vs						(lcd_vs),	    			//lcd vertical sync
	.lcd_de						(lcd_de),					//lcd display enable
	.lcd_rgb					(lcd_rgb),					//lcd display data
	.lcd_framesync          	(lcd_framesync),			//场同步信号		驱动：pixel clk上升沿
	.lcd_xpos					(),							//lcd horizontal coordinate
	.lcd_ypos					()							//lcd vertical coordinate
);

endmodule





