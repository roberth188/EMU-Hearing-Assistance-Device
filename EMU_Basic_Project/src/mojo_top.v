module mojo_top(
    // 50MHz clock input
    input clk,
    
    input user_switch,
    output user_led0,
    output user_led1,
	 
    output [11:0] DACD,
	  output DACCS,
	  output DACWE,
	  output DACLDAC,
	  output DACPD, 
	  input  DMDATA1,
	  input  DMDATA2,
    input  DMDATA3,
    input  DMDATA4,
    output DMCLK,
  
    input  [13:0] FioSp //13:0 to not deal with Rx and Tx
    );

wire rst = user_switch; // make reset active high

assign CLK = clk;

wire        SampleDelayZero; 
wire [9:0]  DMLocationWritingTo;
wire [8:0]  DesiredDMInterfaceOutput; 
wire [9:0]  DesiredDMMemoryLocationToRead;

assign DACD[11:0] = DACDataInput[11:0];
assign user_led0  = 1'b0;//DACDataInput[11];
assign user_led1  = DACDataInput[10];



wire [1:0]     DesiredDM;

DigiMic_Interface DigiMic_Interface_Instance(
.CLK(CLK), 
.DesiredDMMemoryLocationToRead(DesiredDMMemoryLocationToRead),
.DMLocationWritingTo(DMLocationWritingTo), 
.SampleDelayZero(SampleDelayZero),
.DesiredDMInterfaceOutput(DesiredDMInterfaceOutput),
.DMCLK(DMCLK),
.DMDATA1(DMDATA1),
.DMDATA2(DMDATA2),
.DMDATA3(DMDATA3),
.DMDATA4(DMDATA4),
.DesiredDM(DesiredDM)
);



wire           IFFTOutputWE;
wire [8:0]     IFFTOutputIndex;
wire [11:0]    IFFTOutput; 


FFT_Module FFT_Module_Instance(
.CLK(CLK),  
.DesiredDMInterfaceOutput(DesiredDMInterfaceOutput),
.DesiredDMMemoryLocationToRead(DesiredDMMemoryLocationToRead),
.DMLocationWritingTo(DMLocationWritingTo),
.IFFTOutputWE(IFFTOutputWE),
.IFFTOutputIndex(IFFTOutputIndex),
.IFFTOutput(IFFTOutput),
.SampleDelayZero(SampleDelayZero),
.DesiredDM(DesiredDM),
.rst(rst),
.FioSp(FioSp)
);


//wire        DACLDAC, DACPD, DACWE;   //DACCS
wire [11:0] DACDataInput;

DM_TLV5619_DAC_Interface_Module DM_TLV5619_DAC_Interface_Module_Instance(
.DACDataInput(DACDataInput),
.DACCS(DACCS),
.CLK(CLK),
.SampleDelayZero(SampleDelayZero),
.DACLDAC(DACLDAC),
.DACPD(DACPD),
.DACWE(DACWE),
.IFFTOutput(IFFTOutput),
.DMLocationWritingTo(DMLocationWritingTo),
.IFFTOutputWE(IFFTOutputWE),
.IFFTOutputIndex(IFFTOutputIndex)
);






endmodule