#include "stdlib.h"
#include "xil_types.h"

#define CTRL_REG_OFFSET   0x0
#define STAT_REG_OFFSET   0x4
#define TX_BUFF_OFFSET    0x8
#define RX_BUFF_OFFSET    0xC

typedef struct histEq{
	u32 baseAddr;
	u32 imageSize;
	char *TxBuffer;
	char *RxBuffer;
}histEq;


int initHistEq(histEq *instPntr,u32 BaseAddr,u32 imageSize);
int startHistEq(histEq *instPntr);
int isBusy(histEq *instPntr);
int waitComplete(histEq *instPntr);
void histEQISR(histEq *instPntr);
unsigned int getTxBufferAddr(histEq *instPntr);
unsigned int getRxBufferAddr(histEq *instPntr);
void deleteHistEq(histEq *instPntr);
