#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xil_cache.h"

#include "picture.h"

//#define Frame_1_BASEADDR 0x08000000
#define 		Frame_1_BASEADDR 					0x00800000		//0x00800000,  0x0087f800,  0x00880000
#define 		Frame_2_BASEADDR 					0x00900000
#define 		Frame_3_BASEADDR 					0x00a00000

#define 		REG_SLCR_BASEADDR 					0xF8000000
#define 		REG_SLCR_LOCK_OFFSET				0x00000004			//0x767B
#define 		REG_SLCR_UNLOCK_OFFSET				0x00000008			//0xDF0D
#define			REG_FPGA_RST_CTRL_OFFSET			0x00000240			//FPGA0_OUT_RST FCLKRESETN0

#define 		VDMA_REG_BASEADDR					XPAR_M00_AXI_LCD_VDMA_BASEADDR


void delay(){
	u32 time = 0x8ffffff;
	while(time--);
}

int main()
{
	u32 i,j,k,m;
	u32 Image;

	init_platform();
	xil_printf("----------The test is start......----------\n\r");

	if(0){
		k = 0;
		m = 0;
		for(i = 0;i<272;i++){
			for(j = 0;j<480;j++){
				Image = (((u32)(gImage_picture1[k])<<0) | ((u32)(gImage_picture1[k+1])<<8) | ((u32)(gImage_picture1[k+2])<<16));
				Xil_Out32(Frame_1_BASEADDR + m,Image);
				Image = 0;
				k = k + 3;
				m = m + 4;
			}
		}
		Xil_DCacheFlush();
	}

//    Xil_Out32(REG_SLCR_BASEADDR + REG_SLCR_UNLOCK_OFFSET, 0xDF0D);
//    RstStatus = Xil_In32(REG_SLCR_BASEADDR + REG_FPGA_RST_CTRL_OFFSET);
//    Xil_Out32(REG_SLCR_BASEADDR + REG_FPGA_RST_CTRL_OFFSET, RstStatus|0x00000001);	//de reset
//    Xil_Out32(REG_SLCR_BASEADDR + REG_SLCR_LOCK_OFFSET, 0x767B);
//
//    Xil_Out32(REG_SLCR_BASEADDR + REG_SLCR_UNLOCK_OFFSET, 0xDF0D);
//    RstStatus = Xil_In32(REG_SLCR_BASEADDR + REG_FPGA_RST_CTRL_OFFSET);
//    Xil_Out32(REG_SLCR_BASEADDR + REG_FPGA_RST_CTRL_OFFSET, RstStatus&0xfffffffe);	//reset
//    Xil_Out32(REG_SLCR_BASEADDR + REG_SLCR_LOCK_OFFSET, 0x767B);

	//read
	//AXI VDMA1
	Xil_Out32(VDMA_REG_BASEADDR + 0x0, 0x4); //reset   MM2S VDMA Control Register
	Xil_Out32(VDMA_REG_BASEADDR + 0x0, 0x8); //gen-lock

	Xil_Out32(VDMA_REG_BASEADDR + 0x5C,   Frame_1_BASEADDR);   //MM2S Start Addresses
//	Xil_Out32(VDMA_REG_BASEADDR + 0x5C+4, Frame_2_BASEADDR);
//	Xil_Out32(VDMA_REG_BASEADDR + 0x5C+8, Frame_3_BASEADDR);
	Xil_Out32(VDMA_REG_BASEADDR + 0x54, 480*4);//MM2S HSIZE Register
	Xil_Out32(VDMA_REG_BASEADDR + 0x58, 0x01000000|0x0780);//S2MM FRMDELAY_STRIDE Register 480*4=1920 对齐之后为2048=0x800
	Xil_Out32(VDMA_REG_BASEADDR + 0x0, 0x03);//MM2S VDMA Control Register
	Xil_Out32(VDMA_REG_BASEADDR + 0x50, 272);//MM2S_VSIZE    启动传输

	while(1){
		k = 0;
		m = 0;
		for(i = 0;i<272;i++){
			for(j = 0;j<480;j++){
				Image = (((u32)(gImage_picture1[k])<<0) | ((u32)(gImage_picture1[k+1])<<8) | ((u32)(gImage_picture1[k+2])<<16));
				Xil_Out32(Frame_1_BASEADDR + m,Image);
				Image = 0;
				k = k + 3;
				m = m + 4;
			}
		}
		Xil_DCacheFlush();
		delay();

		k = 0;
		m = 0;
		for(i = 0;i<272;i++){
			for(j = 0;j<480;j++){
				Image = (((u32)(gImage_picture2[k])<<0) | ((u32)(gImage_picture2[k+1])<<8) | ((u32)(gImage_picture2[k+2])<<16));
				Xil_Out32(Frame_1_BASEADDR + m,Image);
				Image = 0;
				k = k + 3;
				m = m + 4;
			}
		}
		Xil_DCacheFlush();
		delay();
	}

	cleanup_platform();
	return 0;
}






