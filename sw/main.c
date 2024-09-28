#include "xparameters.h"
#include "xil_io.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "stdlib.h"
#include "histEq.h"

#define imgSize 640*480

static XScuGic IntcInstance;
histEq myHistEq;

int setupInterrupt(XScuGic *IntcInstance);

void DeviceDriverHandler(void *CallbackRef)
{
	XScuGic_Disable(&IntcInstance, XPAR_FABRIC_HISTEQ_0_O_INTR_INTR);
	histEQISR((histEq *)CallbackRef);
	print("Done...\n\r");
	XScuGic_Enable(&IntcInstance, XPAR_FABRIC_HISTEQ_0_O_INTR_INTR);
}

int main(){
	int Status;
	Status = initHistEq(&myHistEq,XPAR_HISTEQ_0_S00_AXI_BASEADDR,imgSize);
	if(Status != XST_SUCCESS){
		print("Histogram initialization failed\n\r");
		return XST_FAILURE;
	}
	xil_printf("Tx Buffer Address %0x\n\r",getTxBufferAddr(&myHistEq));
	xil_printf("Rx Buffer Address %0x\n\r",getRxBufferAddr(&myHistEq));
	Status = setupInterrupt(&IntcInstance);
	if(Status != XST_SUCCESS){
		print("Interrupt setup failed\n\r");
		return XST_FAILURE;
	}
	startHistEq(&myHistEq);
	while(1);
	return 0;
}


int setupInterrupt(XScuGic *IntcInstance){
	int Status;
	static XScuGic_Config *GicConfig;
	GicConfig = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
	Status = XScuGic_CfgInitialize(IntcInstance, GicConfig, GicConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		print("Interrupt controller init failed\n\r");
		return XST_FAILURE;
	}
	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT,(Xil_ExceptionHandler)XScuGic_InterruptHandler,IntcInstance);
	Xil_ExceptionEnable();
	Status = XScuGic_Connect(IntcInstance, XPAR_FABRIC_HISTEQ_0_O_INTR_INTR,(Xil_ExceptionHandler)DeviceDriverHandler,(void *)&myHistEq);
	if (Status != XST_SUCCESS) {
		print("GIC connect failed\n\r");
		return XST_FAILURE;
	}
	XScuGic_Enable(IntcInstance, XPAR_FABRIC_HISTEQ_0_O_INTR_INTR);
	return XST_SUCCESS;
}
