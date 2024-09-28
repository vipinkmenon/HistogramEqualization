#include "histEq.h"
#include "xstatus.h"
#include "xil_io.h"


int initHistEq(histEq *instPntr,u32 BaseAddr,u32 imageSize){
	instPntr->baseAddr = BaseAddr;
	instPntr->TxBuffer = (char *)malloc(imageSize+1024);
	if(instPntr->TxBuffer <= 0){
		print("Tx buffer allocation failed. Check heap size");
		return XST_FAILURE;
	}
	instPntr->TxBuffer = (char *)(((int )instPntr->TxBuffer+1023) & 0xFFFFFC00);
	instPntr->RxBuffer = (char *)malloc(imageSize+1024);
	if(instPntr->RxBuffer <= 0){
		print("Rx buffer allocation failed. Check heap size");
		return XST_FAILURE;
	}
	instPntr->RxBuffer = (char *)(((int )instPntr->RxBuffer+1023) & 0xFFFFFC00);
	Xil_Out32((UINTPTR)((instPntr->baseAddr)+STAT_REG_OFFSET),0);//clear interrupt bit
	return XST_SUCCESS;
}

unsigned int getTxBufferAddr(histEq *instPntr){
	return (unsigned int)(instPntr->TxBuffer);
}


unsigned int getRxBufferAddr(histEq *instPntr){
	return (unsigned int)(instPntr->RxBuffer);
}



int startHistEq(histEq *instPntr){
	Xil_Out32((UINTPTR)((instPntr->baseAddr)+TX_BUFF_OFFSET),(u32)instPntr->TxBuffer);
	Xil_Out32((UINTPTR)((instPntr->baseAddr)+RX_BUFF_OFFSET),(u32)instPntr->RxBuffer);
	Xil_Out32((UINTPTR)((instPntr->baseAddr)+CTRL_REG_OFFSET),1);
	return 0;
}

int isBusy(histEq *instPntr){
	return (Xil_In32((instPntr->baseAddr)+CTRL_REG_OFFSET))&0x1;
}

int waitComplete(histEq *instPntr){
	while((Xil_In32((instPntr->baseAddr)+CTRL_REG_OFFSET))&0x1);
	Xil_Out32((UINTPTR)((instPntr->baseAddr)+STAT_REG_OFFSET),0);//clear interrupt bit
	return XST_SUCCESS;
}

void histEQISR(histEq *instPntr){
	Xil_Out32((UINTPTR)((instPntr->baseAddr)+STAT_REG_OFFSET),0);//clear interrupt bit
}

void deleteHistEq(histEq *instPntr){
	free(instPntr->TxBuffer);
	free(instPntr->RxBuffer);
}
