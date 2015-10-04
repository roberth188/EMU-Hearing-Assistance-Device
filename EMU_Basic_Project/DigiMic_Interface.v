`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    21:13:46 07/24/2014 
// Design Name:    EMU Device
// Module Name:    DigiMic_Interface
//////////////////////////////////////////////////////////////////////////////////


module DigiMic_Interface(
CLK, 
DesiredDMMemoryLocationToRead, 
DMLocationWritingTo, 
SampleDelayZero,
DesiredDMInterfaceOutput,
DMCLK,
DMDATA1,
DMDATA2,
DMDATA3,
DMDATA4,
DesiredDM
);



input          CLK, DMDATA1, DMDATA2, DMDATA3, DMDATA4;
input  [1:0]   DesiredDM;
input  [9:0]   DesiredDMMemoryLocationToRead;      //Selects location from chosen array.
output         DMCLK, SampleDelayZero;
output [9:0]   DMLocationWritingTo;                //Beware of simultaneous write + read.
output [8:0]   DesiredDMInterfaceOutput;           //The value from the chosen array and location.


reg [8:0]      DMAdder1, DMAdder2, DMAdder3, DMAdder4;
reg [9:0]      DMLocationWritingTo;
reg [8:0]      DesiredDMInterfaceOutput1, DesiredDMInterfaceOutput2, DesiredDMInterfaceOutput3, DesiredDMInterfaceOutput4;
reg [12:0]     SampleDelayCount;

wire           DMCLK, DMDATA1, DMDATA2, DMDATA3, DMDATA4, SampleDelayZero;
wire [1:0]     DesiredDM;

reg [8:0]      DesiredDMInterfaceOutput;

   (* RAM_STYLE="{auto | block |  block_power1 | block_power2}" *)
reg [8:0]      StoredDMValues1 [1023:0];   //512*2 = 1024
   (* RAM_STYLE="{auto | block |  block_power1 | block_power2}" *)
reg [8:0]      StoredDMValues2 [1023:0];   //512*2 = 1024
   (* RAM_STYLE="{auto | block |  block_power1 | block_power2}" *)
reg [8:0]      StoredDMValues3 [1023:0];   //512*2 = 1024
   (* RAM_STYLE="{auto | block |  block_power1 | block_power2}" *)
reg [8:0]      StoredDMValues4 [1023:0];   //512*2 = 1024



/* ////////////////////////////////////////////////////////////

                         Main Code

*/ ////////////////////////////////////////////////////////////

assign   DMCLK = SampleDelayCount[3];  

//Divides the clock by 16, giving a result that syncs with the SampleDelayCount. 
//Every sampling interval, this will send 8,192 / 16, or 512 clock signals to the DigiMic.

// SampleDelayCount 50000000 / 16........./512 ....   Should be 512 * 16 = 8192, or 13 bits gives 12:0

assign SampleDelayZero = ~| SampleDelayCount;    // States that a single data point has been made, ie all 512 bits have been counted

always @(posedge CLK)
begin 
  SampleDelayCount <= SampleDelayCount + 1;  // Out of a maximum of 8,191.
end

always @(posedge CLK)
begin
  if (SampleDelayZero)
  begin
    DMLocationWritingTo <= DMLocationWritingTo + 1;
  end
end


assign    DMRead = (SampleDelayCount[3] && SampleDelayCount[2] && SampleDelayCount[1] && !SampleDelayCount[0]);



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



always @(posedge CLK)
begin
  if (DMRead || SampleDelayZero)
  begin
    if (SampleDelayZero)
    begin
      DMAdder1 <= 0;
    end
    
    else
    begin
      DMAdder1 <= DMAdder1 + DMDATA1;
    end
  end
end


always @(posedge CLK)
begin
  if (DMRead || SampleDelayZero)
  begin
    if (SampleDelayZero)
    begin
      DMAdder2 <= 0;
    end
    
    else
    begin
      DMAdder2 <= DMAdder2 + DMDATA2;
    end
  end
end


always @(posedge CLK)
begin
  if (DMRead || SampleDelayZero)
  begin
    if (SampleDelayZero)
    begin
      DMAdder3 <= 0;
    end
    
    else
    begin
      DMAdder3 <= DMAdder3 + DMDATA3;
    end
  end
end


always @(posedge CLK)
begin
  if (DMRead || SampleDelayZero)
  begin
    if (SampleDelayZero)
    begin
      DMAdder4 <= 0;
    end
    
    else
    begin
      DMAdder4 <= DMAdder4 + DMDATA4;
    end
  end
end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


always @(posedge CLK)
begin
  if (SampleDelayZero)
  begin
    StoredDMValues1[DMLocationWritingTo] <= DMAdder1[8:0];
  end
  
  DesiredDMInterfaceOutput1[8:0] <= StoredDMValues1[DesiredDMMemoryLocationToRead];
end

always @(posedge CLK)
begin
  if (SampleDelayZero)
  begin
    StoredDMValues2[DMLocationWritingTo] <= DMAdder2[8:0];
  end
  
  DesiredDMInterfaceOutput2[8:0] <= StoredDMValues2[DesiredDMMemoryLocationToRead];
end

always @(posedge CLK)
begin
  if (SampleDelayZero)
  begin
    StoredDMValues3[DMLocationWritingTo] <= DMAdder3[8:0];
  end
  
  DesiredDMInterfaceOutput3[8:0] <= StoredDMValues3[DesiredDMMemoryLocationToRead];
end

always @(posedge CLK)
begin
  if (SampleDelayZero)
  begin
    StoredDMValues4[DMLocationWritingTo] <= DMAdder4[8:0];
  end
  
  DesiredDMInterfaceOutput4[8:0] <= StoredDMValues4[DesiredDMMemoryLocationToRead];
end




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




always @(DesiredDM or DesiredDMInterfaceOutput1 or DesiredDMInterfaceOutput2 or DesiredDMInterfaceOutput3 or DesiredDMInterfaceOutput4)
begin
  case (DesiredDM)
    2'b00   : begin
               DesiredDMInterfaceOutput = DesiredDMInterfaceOutput1;
             end
    2'b01   : begin
               DesiredDMInterfaceOutput = DesiredDMInterfaceOutput2;
             end
    2'b10   : begin
               DesiredDMInterfaceOutput = DesiredDMInterfaceOutput3;
             end
    2'b11   : begin
               DesiredDMInterfaceOutput = DesiredDMInterfaceOutput4;
             end
    default: begin
               DesiredDMInterfaceOutput = 9'b0000_0000_0;
             end
  endcase
end		
    

/*
***********************************************************************
*                                                                     *       
*  DMRead  >                                               ****       *   
*                                                                     *      
*                                                                     *      
*  DMMIC   >                       _________________________________  *      
*  ________________________________                                   *     
*                                                                     *        
*  |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |      *           
*  0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15   ^  *        
*                                                                     *         
*  **Each number is the positive edge of a clock pulse.               *         
*                                                                     *     
***********************************************************************
*/

endmodule


