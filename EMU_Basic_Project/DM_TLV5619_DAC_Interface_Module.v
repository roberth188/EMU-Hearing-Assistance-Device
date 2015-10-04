`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    21:13:46 07/24/2014 
// Design Name:    EMU Device
// Module Name:    DM_TLV5619_DAC_Interface
//////////////////////////////////////////////////////////////////////////////////


module DM_TLV5619_DAC_Interface_Module(
DACDataInput,
DACCS,
CLK,
SampleDelayZero,
DACLDAC,
DACPD,
DACWE,
IFFTOutput,
DMLocationWritingTo,
IFFTOutputWE,
IFFTOutputIndex
);
	 
	 
input          CLK, SampleDelayZero, IFFTOutputWE;
input [9:0]    DMLocationWritingTo;
input [11:0]   IFFTOutput;
input [8:0]    IFFTOutputIndex;

output         DACCS, DACLDAC, DACPD, DACWE;
output [11:0]  DACDataInput;

reg [11:0]     DACDataInput;   
reg [14:0]     DACDelayCount;    //Could be 12:0, but 2 bits added to avoid off-by one errors

wire           SampleDelayZero, DACCS, IFFTOutputWE;
wire [11:0]    IFFTOutput;
wire [8:0]     IFFTOutputIndex;


   (* RAM_STYLE="{auto | block |  block_power1 | block_power2}" *)
reg [11:0]      StoredDACValues [0:1023];


assign DACCS     = 0;

assign DACLDAC   = 0;

assign DACPD     = 1;

assign DACWE     = (~| DACDelayCount[12:4]) && ( DACDelayCount[3]);



assign DACMemWE = IFFTOutputWE;   //###############################      IFFT based     ##############################//



always @(posedge CLK)
begin
  if (DACMemWE)
  begin
    StoredDACValues [ {!DMLocationWritingTo[9], IFFTOutputIndex} ] <= IFFTOutput[11:0];   //IFFT Index, really     
  end
  
  DACDataInput[11:0] <= StoredDACValues[DMLocationWritingTo + 4];
end


always @(posedge CLK)
begin
  if ( SampleDelayZero ) // Counts from 0 to 8191 (1111111111111)
  begin
    DACDelayCount <= 0;
  end
  
  else
  begin
    DACDelayCount <= DACDelayCount + 1; 
  end
  
end  



endmodule