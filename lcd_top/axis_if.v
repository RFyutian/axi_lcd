module axis_if(
	//axi stream interface
	axis_aresetn,				// input wire s00_axis_aresetn
	axis_aclk,        			// input wire s00_axis_aclk
	//.axis_tdata(axis_tdata),     			// input wire [31 : 0] write data
	axis_tvalid,    			// input wire s00_axis_tvalid
	axis_tready,    			// output wire read data ready
	axis_tuser,					// input wire frame sync
	axis_tlast,      			// input wire s00_axis_tlast
	axis_tstrb,      			// input wire [3 : 0] s00_axis_tstrb
	//内部信号
	//.axis_data_out(axis_data_out),
	axis_data_en,				//output axi stream 数据输出使能
	axis_data_sync,				//output axi stream 数据同步
	axis_data_requst,			//input axi stream  数据请求
);
	//system
	input 					axis_aresetn;
	input 					axis_aclk;
	//axi interface 
	input 					axis_tvalid;
	output 					axis_tready;
	input 					axis_tuser;
	input 					axis_tlast; 
	
	//内部信号
	output 					axis_data_en;
    output 					axis_data_sync;	
    input					axis_data_requst;

		//signal
//--------------------------------------------------------------------------//	
	wire 					axis_data_en;
	wire 					axis_data_sync;
	
//--------------------------------------------------------------------------//

//always@(posedge axis_aclk)begin
//	if(!axis_aresetn)begin
//		axis_tready <= 0;
//	end
//	else
//	begin
//		
//	end
//end
assign axis_data_en = axis_tvalid;
assign axis_tready = axis_data_requst;	
assign axis_data_sync = axis_tuser;

//always@(posedge axis_aclk)begin
//	if(!axis_aresetn)begin
//		axis_data_sync <= 0;
//	end
//	else
//	begin
//		if(axis_tuser)begin
//			axis_data_sync <= 1;
//		end
//		else
//		begin
//			axis_data_sync <= 0;
//		end
//	end
//end
	
endmodule










