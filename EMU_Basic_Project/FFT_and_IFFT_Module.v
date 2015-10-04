`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    22:45:10 07/24/2014 
// Design Name:    EMU Device
// Module Name:    FFT_Module     - note, analysis is included as well 
//////////////////////////////////////////////////////////////////////////////////
module FFT_Module(
CLK,  
DesiredDMInterfaceOutput,
DesiredDMMemoryLocationToRead,
DesiredDM,
DMLocationWritingTo,
IFFTOutputWE,
IFFTOutput,
IFFTOutputIndex,
SampleDelayZero,
rst,
FioSp
);
	 
input         CLK, SampleDelayZero, rst;
input [9:0]   DMLocationWritingTo;
input [8:0]   DesiredDMInterfaceOutput;
output [9:0]  DesiredDMMemoryLocationToRead;

input [13:0]  FioSp;


output        IFFTOutputWE;
output [1:0]  DesiredDM;
output [8:0]  IFFTOutputIndex;
output [11:0] IFFTOutput;


wire          IDONE, IRFD, IDV, IBUSY, IEDONE, IFWD_INV, IFWD_INV_WE, ISTART, IUNLOAD, IFFTOutputWE;
wire [1:0]    DesiredDM;
wire [1:0]    FFTStartNumber; 
wire [8:0]    IXN_INDEX, IXK_INDEX, IFFTOutputIndex;
wire [8:0]    IXN_RE, IXN_IM, DesiredAnalyzerOutputRe, DesiredAnalyzerOutputIm;
wire [11:0]   IFFTOutput;
wire [18:0]   IXK_RE, IXK_IM;

                             
              
reg [23:0]    FFTStoredOutput1;
                                
reg [23:0]    FFTStoredOutput2;

reg [23:0]    FFTStoredOutput3;

reg [23:0]    FFTStoredOutput4;


reg [23:0]    FFTStored1 [511:0];         //Note: Changed due to sample frequency and bitdepth

reg [23:0]    FFTStored2 [511:0];     

reg [23:0]    FFTStored3 [511:0];     

reg [23:0]    FFTStored4 [511:0];     


reg [23:0]    AnalyzerStored [511:0];


reg [23:0]    FFTCount;   //Note: 21:0 is the maximum of what's needed (given 16 * 512 * 512). 
                          //Two bits are superfluous to avoid off-by-one errors

wire          CLK, SampleDelayZero, DONE, RFD, DV, BUSY, EDONE,  ArraySideToCalculate, FWD_INV, FWD_INV_WE, START, UNLOAD, FFTOutputWE;
wire [8:0]    XN_INDEX, XK_INDEX;
wire [9:0]    DMLocationWritingTo;
wire [8:0]    XN_RE, XN_IM, DesiredDMInterfaceOutput, FFTOutputIndex;
wire [11:0]   FFTOutputRe, FFTOutputIm;
wire [9:0]    DesiredDMMemoryLocationToRead;
wire [18:0]   XK_RE, XK_IM;








assign ArraySideToCalculate = !DMLocationWritingTo[9];

always @(posedge CLK)       // Counts to 16 * 512 * 512.   512-point / samples at 512 DMCLKs each from 16 of 50,000,000
begin
  if ( (~| DMLocationWritingTo[8:0]) && SampleDelayZero)    // Can be 0 0000_00000 0000 or 1 0000_00000 0000  Note: this does occur.
  begin
    FFTCount <= 0;
  end

  else 
  begin
    FFTCount <= FFTCount + 1;         // If DMLocationWritingTo[8:0] == 0, then 0 / reset. else + 1.                           
  end                                 // FFTCount is [23:0], although it will only go to use all of 21:0
  
end

assign DesiredDM[1:0] =  {(FFTCount >= 20000), (((FFTCount < 20000) && (FFTCount >= 10000)) || (FFTCount >= 30000))};      // Pulls the data from the second microphone past a certain point
assign START = (FFTCount == 100) || (FFTCount == 10100) || (FFTCount == 20100) || (FFTCount == 30100);     //
assign FWD_INV = 1;                   //
assign FWD_INV_WE = (FFTCount == 60); //



assign UNLOAD = DONE;

assign DesiredDMMemoryLocationToRead = {ArraySideToCalculate, XN_INDEX + 1};
assign XN_RE = {!DesiredDMInterfaceOutput[8], DesiredDMInterfaceOutput [7:0]};
assign XN_IM = 9'b0000_0000_0;    


assign FFTOutputRe = {XK_RE[18], XK_RE[17:7]}; 
assign FFTOutputIm = {XK_IM[18], XK_IM[17:7]};
//Note: data from the FFT output must still be in this clean form so that the phase shift results are still accurate (the others have been tried).



assign FFTOutputWE = DV;
assign FFTOutputIndex = XK_INDEX[8:0];






FFT_IFFT_IP_CORE FFT_IP_CORE_Instance (
  .clk(CLK), // input clk
  .start(START), // input start
  .unload(UNLOAD), // input unload
  .xn_re(XN_RE), // input [8 : 0] xn_re
  .xn_im(XN_IM), // input [8 : 0] xn_im
  .fwd_inv(FWD_INV), // input fwd_inv
  .fwd_inv_we(FWD_INV_WE), // input fwd_inv_we
  .rfd(RFD), // output rfd
  .xn_index(XN_INDEX), // output [8 : 0] xn_index
  .busy(BUSY), // output busy
  .edone(EDONE), // output edone
  .done(DONE), // output done
  .dv(DV), // output dv
  .xk_index(XK_INDEX), // output [8 : 0] xk_index
  .xk_re(XK_RE), // output [18 : 0] xk_re
  .xk_im(XK_IM) // output [18 : 0] xk_im
);














wire          ND1, RDY1, RFD1;
wire [9:0]    X_IN1, Y_IN1, X_OUT1, PHASE_OUT1;

wire          ND2, RDY2, RFD2;
wire [9:0]    X_IN2, Y_IN2, X_OUT2, PHASE_OUT2;

wire          ND3, RDY3, RFD3;
wire [9:0]    X_IN3, Y_IN3, X_OUT3, PHASE_OUT3;

wire          ND4, RDY4, RFD4;
wire [9:0]    X_IN4, Y_IN4, X_OUT4, PHASE_OUT4;



wire [8:0]    FFTStoredOutputIndex;

assign FFTStartNumber = DesiredDM;
///
always @(posedge CLK)
begin
  if (DV && !FFTStartNumber[1] && !FFTStartNumber[0])
  begin
    FFTStored1[XK_INDEX] <= {FFTOutputRe[11:0], FFTOutputIm[11:0]};   //Note : can be varied to find the ideal noise option
  end

  FFTStoredOutput1 <= FFTStored1[FFTStoredOutputIndex];
end
///

///
always @(posedge CLK)
begin
  if (DV && !FFTStartNumber[1] && FFTStartNumber[0])
  begin
    FFTStored2[XK_INDEX] <= {FFTOutputRe[11:0], FFTOutputIm[11:0]};   //Note : can be varied to find the ideal noise option
  end
                   
  FFTStoredOutput2 <= FFTStored2[FFTStoredOutputIndex];
end
///

///
always @(posedge CLK)
begin
  if (DV && FFTStartNumber[1] && !FFTStartNumber[0])
  begin
    FFTStored3[XK_INDEX] <= {FFTOutputRe[11:0], FFTOutputIm[11:0]};   //Note : can be varied to find the ideal noise option
  end

  FFTStoredOutput3 <= FFTStored3[FFTStoredOutputIndex];
end
///

///
always @(posedge CLK)
begin
  if (DV && FFTStartNumber[1] && FFTStartNumber[0])
  begin
    FFTStored4[XK_INDEX] <= {FFTOutputRe[11:0], FFTOutputIm[11:0]};    //Note : can be varied to find the ideal noise option
  end
                   
  FFTStoredOutput4 <= FFTStored4[FFTStoredOutputIndex];
end
///


wire          AnalyzerInterval;
wire [17:0]   FFTStoredOutputIndexMath;


assign AnalyzerInterval = ((FFTCount >= 17'b1100_0011_1000_0000_0) && (FFTCount <= 18'b1010_0001_1100_0000_00));
//100096 to 165632
//Starts at the first |[6:0]==0 after 100000 and then stops after 512 cycles of 128 each
//assign FFTStoredOutputIndexMath = (FFTCount[17:7] - 10'b1100_0011_10); //15:7 gives 9 bits
//assign FFTStoredOutputIndex = FFTStoredOutputIndexMath[8:0];

assign FFTStoredOutputIndex[8:0] = (FFTCount[17:7] - 10'b1100_0011_10); //15:7 gives 9 bits

assign AnalyzerCount = FFTCount[6:0];   //6:0 gives 7 bits
// It counts to 128


assign X_IN1 = {FFTStoredOutput1[23], FFTStoredOutput1[23], FFTStoredOutput1[22:15]};  // Input width is 10 bits
assign Y_IN1 = {FFTStoredOutput1[11], FFTStoredOutput1[11], FFTStoredOutput1[10:3]};
assign X_IN2 = {FFTStoredOutput2[23], FFTStoredOutput2[23], FFTStoredOutput2[22:15]};
assign Y_IN2 = {FFTStoredOutput2[11], FFTStoredOutput2[11], FFTStoredOutput2[10:3]};
assign X_IN3 = {FFTStoredOutput3[23], FFTStoredOutput3[23], FFTStoredOutput3[22:15]};
assign Y_IN3 = {FFTStoredOutput3[11], FFTStoredOutput3[11], FFTStoredOutput3[10:3]};
assign X_IN4 = {FFTStoredOutput4[23], FFTStoredOutput4[23], FFTStoredOutput4[22:15]};
assign Y_IN4 = {FFTStoredOutput4[11], FFTStoredOutput4[11], FFTStoredOutput4[10:3]};

//assign ND1   = ((AnalyzerInterval) && (AnalyzerCount == 7'b0000_100));
//assign ND2   = ((AnalyzerInterval) && (AnalyzerCount == 7'b0000_100));

//assign ND1   = ((AnalyzerInterval) && (FFTCount[6:0] == 7'b0000_100));
//assign ND2   = ((AnalyzerInterval) && (FFTCount[6:0] == 7'b0000_100));

assign ND1   = (((FFTCount >= 17'b1100_0011_1000_0000_0) && (FFTCount <= 18'b1010_0001_1100_0000_00)) && (FFTCount[6:0] == 7'b0000_100));
assign ND2   = (((FFTCount >= 17'b1100_0011_1000_0000_0) && (FFTCount <= 18'b1010_0001_1100_0000_00)) && (FFTCount[6:0] == 7'b0000_100));
assign ND3   = (((FFTCount >= 17'b1100_0011_1000_0000_0) && (FFTCount <= 18'b1010_0001_1100_0000_00)) && (FFTCount[6:0] == 7'b0000_100));
assign ND4   = (((FFTCount >= 17'b1100_0011_1000_0000_0) && (FFTCount <= 18'b1010_0001_1100_0000_00)) && (FFTCount[6:0] == 7'b0000_100));


wire [7:0] P1a, P2a, P3a, P4a;

assign P1a = {PHASE_OUT1[9], PHASE_OUT1[6:0]};  //correctly formatted {+/-, int1, int0, decimal0, decimal1, decimal2, ...}
assign P2a = {PHASE_OUT2[9], PHASE_OUT2[6:0]};
assign P3a = {PHASE_OUT3[9], PHASE_OUT3[6:0]};
assign P4a = {PHASE_OUT4[9], PHASE_OUT4[6:0]};








//Past Comparison options: 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//assign AnalyzerConditionRe  = (((P1a - P2a) > (P2a - P1a)) && (FFTStoredOutputIndex == 9'b0010_0000_0)) || (((P1a - P2a) < (P2a - P1a)) && (FFTStoredOutputIndex == 9'b1100_0000_0));
//assign AnalyzerConditionIm  = (((P1a - P2a) > (P2a - P1a)) && (FFTStoredOutputIndex == 9'b0010_0000_0)) || (((P1a - P2a) < (P2a - P1a)) && (FFTStoredOutputIndex == 9'b1100_0000_0));
// Note: Ideal frequency is about 762 Hertz


//assign AnalyzerConditionRe  = (((P1a - P2a) > (P2a - P1a)) && (FFTStoredOutputIndex < 9'b1000_0000_0)) || (((P1a - P2a) < (P2a - P1a)) && (FFTStoredOutputIndex > 9'b1000_0000_0));
//assign AnalyzerConditionIm  = (((P1a - P2a) > (P2a - P1a)) && (FFTStoredOutputIndex < 9'b1000_0000_0)) || (((P1a - P2a) < (P2a - P1a)) && (FFTStoredOutputIndex > 9'b1000_0000_0));
// Note: Run to test for all frequencies


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//assign AnalyzerConditionRe  = (((P1a - P2a) <= 8'b1000_0000) && ({(P1a - P2a), 8'b0000_0000} <= (49 * FFTStoredOutputIndex))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
// Works for angles 0 < x < 60

//assign AnalyzerConditionRe  = (({(P1a - P2a), 8'b0000_0000} >= (25 * FFTStoredOutputIndex)) && ({(P1a - P2a), 8'b0000_0000} <= (49 * FFTStoredOutputIndex))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
//assign AnalyzerConditionIm  = (({(P1a - P2a), 8'b0000_0000} >= (25 * FFTStoredOutputIndex)) && ({(P1a - P2a), 8'b0000_0000} <= (49 * FFTStoredOutputIndex))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
//works for angles 30 < x < 60

//assign AnalyzerConditionRe  = (({(P1a - P2a), 8'b0000_0000} >= (207 * FFTStoredOutputIndex)) && ({(P1a - P2a), 8'b0000_0000} <= (231 * FFTStoredOutputIndex))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
//assign AnalyzerConditionIm  = (({(P1a - P2a), 8'b0000_0000} >= (207 * FFTStoredOutputIndex)) && ({(P1a - P2a), 8'b0000_0000} <= (231 * FFTStoredOutputIndex))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
//




/*
wire         aValF, aValM, bValF, bValM;
//wire [6:0] aVal, bVal;
wire [8:0]   aVal, bVal;    //a realistic max of 97
wire [17:0]  aValIndMult, bValIndMult;    //9 bit Index plus 9 bit (128 maximum, though) phase difference
*/












wire         aValF1, bValF1, aCond1, bCond1;
wire         aValF2, bValF2, aCond2, bCond2;
wire         aValF3, bValF3, aCond3, bCond3;
wire         aValF4, bValF4, aCond4, bCond4;

reg          aValFr1, bValFr1, aValM1, bValM1;
reg          aValFr2, bValFr2, aValM2, bValM2;
reg          aValFr3, bValFr3, aValM3, bValM3;
reg          aValFr4, bValFr4, aValM4, bValM4;

reg [8:0]    aVal1, bVal1;    //a realistic max of 68
reg [8:0]    aVal2, bVal2;
reg [8:0]    aVal3, bVal3;
reg [8:0]    aVal4, bVal4;

wire [17:0]  aValIndMult1, bValIndMult1;    //9 bit Index plus 9 bit (128 maximum, though) phase difference
wire [17:0]  aValIndMult2, bValIndMult2;
wire [17:0]  aValIndMult3, bValIndMult3;
wire [17:0]  aValIndMult4, bValIndMult4;

reg          AnalyzerConditionRe1;
reg          AnalyzerConditionRe2;
reg          AnalyzerConditionRe3;
reg          AnalyzerConditionRe4;

wire         AnalyzerConditionRe;
wire         AnalyzerConditionIm;
wire [11:0]  AnalyzerOutputRe, AnalyzerOutputIm;





assign aCond1 = !FioSp[12] && !FioSp[11] && FioSp[10] &&  FioSp[9];
assign bCond1 = !FioSp[12] && !FioSp[11] && FioSp[10] && !FioSp[9];

assign aCond2 = !FioSp[12] &&  FioSp[11] && FioSp[10] &&  FioSp[9];
assign bCond2 = !FioSp[12] &&  FioSp[11] && FioSp[10] && !FioSp[9];

assign aCond3 =  FioSp[12] && !FioSp[11] && FioSp[10] &&  FioSp[9];
assign bCond3 =  FioSp[12] && !FioSp[11] && FioSp[10] && !FioSp[9];

assign aCond4 =  FioSp[12] &&  FioSp[11] && FioSp[10] &&  FioSp[9];
assign bCond4 =  FioSp[12] &&  FioSp[11] && FioSp[10] && !FioSp[9];





always @ (aCond1 or FioSp[8])
  begin 
    if (aCond1 == 1)
      aValFr1 = FioSp[8];
  end

always @ (aCond1 or FioSp[7])
  begin
    if (aCond1 == 1)
      aValM1 = FioSp[7];
  end

always @ (aCond1 or FioSp[6:0])
  begin
    if (aCond1 == 1)
      aVal1 = FioSp[6:0];
  end


always @ (bCond1 or FioSp[8])
  begin
    if (bCond1 == 1)
      bValFr1 = FioSp[8];
  end

always @ (bCond1 or FioSp[7])
  begin
    if (bCond1 == 1)
      bValM1 = FioSp[7];
  end

always @ (bCond1 or FioSp[6:0])
  begin
    if (bCond1 == 1)
      bVal1 = FioSp[6:0];
  end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always @ (aCond2 or FioSp[8])
  begin 
    if (aCond2 == 1)
      aValFr2 = FioSp[8];
  end

always @ (aCond2 or FioSp[7])
  begin
    if (aCond2 == 1)
      aValM2 = FioSp[7];
  end

always @ (aCond2 or FioSp[6:0])
  begin
    if (aCond2 == 1)
      aVal2 = FioSp[6:0];
  end


always @ (bCond2 or FioSp[8])
  begin
    if (bCond2 == 1)
      bValFr2 = FioSp[8];
  end

always @ (bCond2 or FioSp[7])
  begin
    if (bCond2 == 1)
      bValM2 = FioSp[7];
  end

always @ (bCond2 or FioSp[6:0])
  begin
    if (bCond2 == 1)
      bVal2 = FioSp[6:0];
  end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always @ (aCond3 or FioSp[8])
  begin 
    if (aCond3 == 1)
      aValFr3 = FioSp[8];
  end

always @ (aCond3 or FioSp[7])
  begin
    if (aCond3 == 1)
      aValM3 = FioSp[7];
  end

always @ (aCond3 or FioSp[6:0])
  begin
    if (aCond3 == 1)
      aVal3 = FioSp[6:0];
  end


always @ (bCond3 or FioSp[8])
  begin
    if (bCond3 == 1)
      bValFr3 = FioSp[8];
  end

always @ (bCond3 or FioSp[7])
  begin
    if (bCond3 == 1)
      bValM3 = FioSp[7];
  end

always @ (bCond3 or FioSp[6:0])
  begin
    if (bCond3 == 1)
      bVal3 = FioSp[6:0];
  end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always @ (aCond4 or FioSp[8])
  begin 
    if (aCond4 == 1)
      aValFr4 = FioSp[8];
  end

always @ (aCond4 or FioSp[7])
  begin
    if (aCond4 == 1)
      aValM4 = FioSp[7];
  end

always @ (aCond4 or FioSp[6:0])
  begin
    if (aCond4 == 1)
      aVal4 = FioSp[6:0];
  end


always @ (bCond4 or FioSp[8])
  begin
    if (bCond4 == 1)
      bValFr4 = FioSp[8];
  end

always @ (bCond4 or FioSp[7])
  begin
    if (bCond4 == 1)
      bValM4 = FioSp[7];
  end

always @ (bCond4 or FioSp[6:0])
  begin
    if (bCond4 == 1)
      bVal4 = FioSp[6:0];
  end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


assign aValF1 = aValFr1 == (FFTStoredOutputIndex <= 9'b1000_0000_0);
assign bValF1 = bValFr1 == (FFTStoredOutputIndex <= 9'b1000_0000_0);

assign aValF2 = aValFr2 == (FFTStoredOutputIndex <= 9'b1000_0000_0);
assign bValF2 = bValFr2 == (FFTStoredOutputIndex <= 9'b1000_0000_0);

assign aValF3 = aValFr3 == (FFTStoredOutputIndex <= 9'b1000_0000_0);
assign bValF3 = bValFr3 == (FFTStoredOutputIndex <= 9'b1000_0000_0);

assign aValF4 = aValFr4 == (FFTStoredOutputIndex <= 9'b1000_0000_0);
assign bValF4 = bValFr4 == (FFTStoredOutputIndex <= 9'b1000_0000_0);



/*
assign aVal  = 9'b0000_1100_1; //30  (d25)
assign aValF = (1 == (FFTStoredOutputIndex <= 9'b1000_0000_0));  //0: P1a - P2a;           1: P2a - P1a              // 1 means its negative
assign aValM = 1;  //0: {Px - Px,~} <= mult; 0: {Px - Px,~} >= mult;   // Needed to account for negativity
assign bVal  = 9'b0001_1000_1; //60  (d49)
assign bValF = (1 == (FFTStoredOutputIndex <= 9'b1000_0000_0));      // 1 means its negative
assign bValM = 0;      // Needed to account for negativity
*/


assign aValIndMult1 = aVal1 * FFTStoredOutputIndex;
assign bValIndMult1 = bVal1 * FFTStoredOutputIndex;

assign aValIndMult2 = aVal2 * FFTStoredOutputIndex;
assign bValIndMult2 = bVal2 * FFTStoredOutputIndex;

assign aValIndMult3 = aVal3 * FFTStoredOutputIndex;
assign bValIndMult3 = bVal3 * FFTStoredOutputIndex;

assign aValIndMult4 = aVal4 * FFTStoredOutputIndex;
assign bValIndMult4 = bVal4 * FFTStoredOutputIndex;




always @ (aValF1 or aValM1 or bValF1 or bValM1 or P1a or P2a or aValIndMult1 or bValIndMult1 or FFTStoredOutputIndex) 
begin
  case ({aValF1, aValM1, bValF1, bValM1}) 
    4'b0000 :  begin
                 AnalyzerConditionRe1 = (({(P1a - P2a), 8'b0000_0000} <= (aValIndMult1)) && ({(P1a - P2a), 8'b0000_0000} <= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly 
               end  
    4'b0001 :  begin
                 AnalyzerConditionRe1 = (({(P1a - P2a), 8'b0000_0000} <= (aValIndMult1)) && ({(P1a - P2a), 8'b0000_0000} >= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0); 
               end
    4'b0010 :  begin
                 AnalyzerConditionRe1 = (({(P1a - P2a), 8'b0000_0000} <= (aValIndMult1)) || ({(P2a - P1a), 8'b0000_0000} <= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0); 
               end
    4'b0011 :  begin
                 AnalyzerConditionRe1 = (({(P1a - P2a), 8'b0000_0000} <= (aValIndMult1)) || ({(P2a - P1a), 8'b0000_0000} >= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b0100 :  begin 
                 AnalyzerConditionRe1 = (({(P1a - P2a), 8'b0000_0000} >= (aValIndMult1)) && ({(P1a - P2a), 8'b0000_0000} <= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b0101 :  begin
                 AnalyzerConditionRe1 = (({(P1a - P2a), 8'b0000_0000} >= (aValIndMult1)) && ({(P1a - P2a), 8'b0000_0000} >= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly
               end
    4'b0110 :  begin
                 AnalyzerConditionRe1 = (({(P1a - P2a), 8'b0000_0000} >= (aValIndMult1)) || ({(P2a - P1a), 8'b0000_0000} <= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b0111 :  begin
                 AnalyzerConditionRe1 = (({(P1a - P2a), 8'b0000_0000} >= (aValIndMult1)) || ({(P2a - P1a), 8'b0000_0000} >= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1000 :  begin
                 AnalyzerConditionRe1 = (({(P2a - P1a), 8'b0000_0000} <= (aValIndMult1)) || ({(P1a - P2a), 8'b0000_0000} <= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b1001 :  begin
                 AnalyzerConditionRe1 = (({(P2a - P1a), 8'b0000_0000} <= (aValIndMult1)) || ({(P1a - P2a), 8'b0000_0000} >= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1010 :  begin
                 AnalyzerConditionRe1 = (({(P2a - P1a), 8'b0000_0000} <= (aValIndMult1)) && ({(P2a - P1a), 8'b0000_0000} <= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly
               end
    4'b1011 :  begin
                 AnalyzerConditionRe1 = (({(P2a - P1a), 8'b0000_0000} <= (aValIndMult1)) && ({(P2a - P1a), 8'b0000_0000} >= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b1100 :  begin
                 AnalyzerConditionRe1 = (({(P2a - P1a), 8'b0000_0000} >= (aValIndMult1)) || ({(P1a - P2a), 8'b0000_0000} <= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1101 :  begin
                 AnalyzerConditionRe1 = (({(P2a - P1a), 8'b0000_0000} >= (aValIndMult1)) || ({(P1a - P2a), 8'b0000_0000} >= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1110 :  begin
                 AnalyzerConditionRe1 = (({(P2a - P1a), 8'b0000_0000} >= (aValIndMult1)) && ({(P2a - P1a), 8'b0000_0000} <= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b1111 :  begin
                 AnalyzerConditionRe1 = (({(P2a - P1a), 8'b0000_0000} >= (aValIndMult1)) && ({(P2a - P1a), 8'b0000_0000} >= (bValIndMult1))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly
               end
    default :  begin
                 AnalyzerConditionRe1 = 0; 
               end
  endcase 
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


always @ (aValF2 or aValM2 or bValF2 or bValM2 or P2a or P3a or aValIndMult2 or bValIndMult2 or FFTStoredOutputIndex) 
begin
  case ({aValF2, aValM2, bValF2, bValM2}) 
    4'b0000 :  begin
                 AnalyzerConditionRe2 = (({(P2a - P3a), 8'b0000_0000} <= (aValIndMult2)) && ({(P2a - P3a), 8'b0000_0000} <= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly 
               end  
    4'b0001 :  begin
                 AnalyzerConditionRe2 = (({(P2a - P3a), 8'b0000_0000} <= (aValIndMult2)) && ({(P2a - P3a), 8'b0000_0000} >= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0); 
               end
    4'b0010 :  begin
                 AnalyzerConditionRe2 = (({(P2a - P3a), 8'b0000_0000} <= (aValIndMult2)) || ({(P3a - P2a), 8'b0000_0000} <= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0); 
               end
    4'b0011 :  begin
                 AnalyzerConditionRe2 = (({(P2a - P3a), 8'b0000_0000} <= (aValIndMult2)) || ({(P3a - P2a), 8'b0000_0000} >= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b0100 :  begin 
                 AnalyzerConditionRe2 = (({(P2a - P3a), 8'b0000_0000} >= (aValIndMult2)) && ({(P2a - P3a), 8'b0000_0000} <= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b0101 :  begin
                 AnalyzerConditionRe2 = (({(P2a - P3a), 8'b0000_0000} >= (aValIndMult2)) && ({(P2a - P3a), 8'b0000_0000} >= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly
               end
    4'b0110 :  begin
                 AnalyzerConditionRe2 = (({(P2a - P3a), 8'b0000_0000} >= (aValIndMult2)) || ({(P3a - P2a), 8'b0000_0000} <= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b0111 :  begin
                 AnalyzerConditionRe2 = (({(P2a - P3a), 8'b0000_0000} >= (aValIndMult2)) || ({(P3a - P2a), 8'b0000_0000} >= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1000 :  begin
                 AnalyzerConditionRe2 = (({(P3a - P2a), 8'b0000_0000} <= (aValIndMult2)) || ({(P2a - P3a), 8'b0000_0000} <= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b1001 :  begin
                 AnalyzerConditionRe2 = (({(P3a - P2a), 8'b0000_0000} <= (aValIndMult2)) || ({(P2a - P3a), 8'b0000_0000} >= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1010 :  begin
                 AnalyzerConditionRe2 = (({(P3a - P2a), 8'b0000_0000} <= (aValIndMult2)) && ({(P3a - P2a), 8'b0000_0000} <= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly
               end
    4'b1011 :  begin
                 AnalyzerConditionRe2 = (({(P3a - P2a), 8'b0000_0000} <= (aValIndMult2)) && ({(P3a - P2a), 8'b0000_0000} >= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b1100 :  begin
                 AnalyzerConditionRe2 = (({(P3a - P2a), 8'b0000_0000} >= (aValIndMult2)) || ({(P2a - P3a), 8'b0000_0000} <= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1101 :  begin
                 AnalyzerConditionRe2 = (({(P3a - P2a), 8'b0000_0000} >= (aValIndMult2)) || ({(P2a - P3a), 8'b0000_0000} >= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1110 :  begin
                 AnalyzerConditionRe2 = (({(P3a - P2a), 8'b0000_0000} >= (aValIndMult2)) && ({(P3a - P2a), 8'b0000_0000} <= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b1111 :  begin
                 AnalyzerConditionRe2 = (({(P3a - P2a), 8'b0000_0000} >= (aValIndMult2)) && ({(P3a - P2a), 8'b0000_0000} >= (bValIndMult2))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly
               end
    default :  begin
                 AnalyzerConditionRe2 = 0;        
               end
  endcase 
end



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



always @ (aValF3 or aValM3 or bValF3 or bValM3 or P1a or P3a or aValIndMult3 or bValIndMult3 or FFTStoredOutputIndex) 
begin
  case ({aValF3, aValM3, bValF3, bValM3}) 
    4'b0000 :  begin
                 AnalyzerConditionRe3 = (({(P1a - P3a), 8'b0000_0000} <= (aValIndMult3)) && ({(P1a - P3a), 8'b0000_0000} <= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly 
               end  
    4'b0001 :  begin
                 AnalyzerConditionRe3 = (({(P1a - P3a), 8'b0000_0000} <= (aValIndMult3)) && ({(P1a - P3a), 8'b0000_0000} >= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0); 
               end
    4'b0010 :  begin
                 AnalyzerConditionRe3 = (({(P1a - P3a), 8'b0000_0000} <= (aValIndMult3)) || ({(P3a - P1a), 8'b0000_0000} <= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0); 
               end
    4'b0011 :  begin
                 AnalyzerConditionRe3 = (({(P1a - P3a), 8'b0000_0000} <= (aValIndMult3)) || ({(P3a - P1a), 8'b0000_0000} >= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b0100 :  begin 
                 AnalyzerConditionRe3 = (({(P1a - P3a), 8'b0000_0000} >= (aValIndMult3)) && ({(P1a - P3a), 8'b0000_0000} <= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b0101 :  begin
                 AnalyzerConditionRe3 = (({(P1a - P3a), 8'b0000_0000} >= (aValIndMult3)) && ({(P1a - P3a), 8'b0000_0000} >= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly
               end
    4'b0110 :  begin
                 AnalyzerConditionRe3 = (({(P1a - P3a), 8'b0000_0000} >= (aValIndMult3)) || ({(P3a - P1a), 8'b0000_0000} <= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b0111 :  begin
                 AnalyzerConditionRe3 = (({(P1a - P3a), 8'b0000_0000} >= (aValIndMult3)) || ({(P3a - P1a), 8'b0000_0000} >= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1000 :  begin
                 AnalyzerConditionRe3 = (({(P3a - P1a), 8'b0000_0000} <= (aValIndMult3)) || ({(P1a - P3a), 8'b0000_0000} <= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b1001 :  begin
                 AnalyzerConditionRe3 = (({(P3a - P1a), 8'b0000_0000} <= (aValIndMult3)) || ({(P1a - P3a), 8'b0000_0000} >= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1010 :  begin
                 AnalyzerConditionRe3 = (({(P3a - P1a), 8'b0000_0000} <= (aValIndMult3)) && ({(P3a - P1a), 8'b0000_0000} <= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly
               end
    4'b1011 :  begin
                 AnalyzerConditionRe3 = (({(P3a - P1a), 8'b0000_0000} <= (aValIndMult3)) && ({(P3a - P1a), 8'b0000_0000} >= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b1100 :  begin
                 AnalyzerConditionRe3 = (({(P3a - P1a), 8'b0000_0000} >= (aValIndMult3)) || ({(P1a - P3a), 8'b0000_0000} <= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1101 :  begin
                 AnalyzerConditionRe3 = (({(P3a - P1a), 8'b0000_0000} >= (aValIndMult3)) || ({(P1a - P3a), 8'b0000_0000} >= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1110 :  begin
                 AnalyzerConditionRe3 = (({(P3a - P1a), 8'b0000_0000} >= (aValIndMult3)) && ({(P3a - P1a), 8'b0000_0000} <= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b1111 :  begin
                 AnalyzerConditionRe3 = (({(P3a - P1a), 8'b0000_0000} >= (aValIndMult3)) && ({(P3a - P1a), 8'b0000_0000} >= (bValIndMult3))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly
               end
    default :  begin
                 AnalyzerConditionRe3 = 0;        
               end
  endcase 
end



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


always @ (aValF4 or aValM4 or bValF4 or bValM4 or P1a or P4a or aValIndMult4 or bValIndMult4 or FFTStoredOutputIndex) 
begin
  case ({aValF4, aValM4, bValF4, bValM4}) 
    4'b0000 :  begin
                 AnalyzerConditionRe4 = (({(P1a - P4a), 8'b0000_0000} <= (aValIndMult4)) && ({(P1a - P4a), 8'b0000_0000} <= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly 
               end  
    4'b0001 :  begin
                 AnalyzerConditionRe4 = (({(P1a - P4a), 8'b0000_0000} <= (aValIndMult4)) && ({(P1a - P4a), 8'b0000_0000} >= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0); 
               end
    4'b0010 :  begin
                 AnalyzerConditionRe4 = (({(P1a - P4a), 8'b0000_0000} <= (aValIndMult4)) || ({(P4a - P1a), 8'b0000_0000} <= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0); 
               end
    4'b0011 :  begin
                 AnalyzerConditionRe4 = (({(P1a - P4a), 8'b0000_0000} <= (aValIndMult4)) || ({(P4a - P1a), 8'b0000_0000} >= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b0100 :  begin 
                 AnalyzerConditionRe4 = (({(P1a - P4a), 8'b0000_0000} >= (aValIndMult4)) && ({(P1a - P4a), 8'b0000_0000} <= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b0101 :  begin
                 AnalyzerConditionRe4 = (({(P1a - P4a), 8'b0000_0000} >= (aValIndMult4)) && ({(P1a - P4a), 8'b0000_0000} >= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly
               end
    4'b0110 :  begin
                 AnalyzerConditionRe4 = (({(P1a - P4a), 8'b0000_0000} >= (aValIndMult4)) || ({(P4a - P1a), 8'b0000_0000} <= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b0111 :  begin
                 AnalyzerConditionRe4 = (({(P1a - P4a), 8'b0000_0000} >= (aValIndMult4)) || ({(P4a - P1a), 8'b0000_0000} >= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1000 :  begin
                 AnalyzerConditionRe4 = (({(P4a - P1a), 8'b0000_0000} <= (aValIndMult4)) || ({(P1a - P4a), 8'b0000_0000} <= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b1001 :  begin
                 AnalyzerConditionRe4 = (({(P4a - P1a), 8'b0000_0000} <= (aValIndMult4)) || ({(P1a - P4a), 8'b0000_0000} >= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1010 :  begin
                 AnalyzerConditionRe4 = (({(P4a - P1a), 8'b0000_0000} <= (aValIndMult4)) && ({(P4a - P1a), 8'b0000_0000} <= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly
               end
    4'b1011 :  begin
                 AnalyzerConditionRe4 = (({(P4a - P1a), 8'b0000_0000} <= (aValIndMult4)) && ({(P4a - P1a), 8'b0000_0000} >= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b1100 :  begin
                 AnalyzerConditionRe4 = (({(P4a - P1a), 8'b0000_0000} >= (aValIndMult4)) || ({(P1a - P4a), 8'b0000_0000} <= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1101 :  begin
                 AnalyzerConditionRe4 = (({(P4a - P1a), 8'b0000_0000} >= (aValIndMult4)) || ({(P1a - P4a), 8'b0000_0000} >= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //silly
               end
    4'b1110 :  begin
                 AnalyzerConditionRe4 = (({(P4a - P1a), 8'b0000_0000} >= (aValIndMult4)) && ({(P4a - P1a), 8'b0000_0000} <= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0);
               end
    4'b1111 :  begin
                 AnalyzerConditionRe4 = (({(P4a - P1a), 8'b0000_0000} >= (aValIndMult4)) && ({(P4a - P1a), 8'b0000_0000} >= (bValIndMult4))) && (FFTStoredOutputIndex == 9'b0010_0000_0);  //Silly
               end
    default :  begin
                 AnalyzerConditionRe4 = 0;        
               end
  endcase 
end









assign AnalyzerConditionRe = ((AnalyzerConditionRe1) && (AnalyzerConditionRe2) && (AnalyzerConditionRe3) && (AnalyzerConditionRe4));




///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////






assign AnalyzerConditionIm = AnalyzerConditionRe;


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




assign AnalyzerOutputRe = ((AnalyzerConditionRe) || rst) ? FFTStoredOutput3[23:12] : 12'b0000_0000_0000;//FFTStoredOutput1[23:12];
assign AnalyzerOutputIm = ((AnalyzerConditionIm) || rst) ? FFTStoredOutput3[11:0]  : 12'b0000_0000_0000;//FFTStoredOutput1[11:0];










assign AnalyzerOutputWE = (((FFTCount >= 17'b1100_0011_1000_0000_0) && (FFTCount <= 18'b1010_0001_1100_0000_00)) && (FFTCount[6:0] == 7'b0111_111)); // Gives 64 counts for CORDIC; 20 needed.  

reg [23:0] AnalyzerStoredOutput;



always @(posedge CLK)
begin
  if (AnalyzerOutputWE)
  begin
    AnalyzerStored[FFTStoredOutputIndex] <= {AnalyzerOutputRe[11:0], AnalyzerOutputIm[11:0]};
  end
  
  AnalyzerStoredOutput <= AnalyzerStored[IXN_INDEX + 1];
end





assign IXN_RE = ((IXN_INDEX >= 9'b00000_0100) && (IXN_INDEX <= 9'b11111_1100)) ? {AnalyzerStoredOutput[23], AnalyzerStoredOutput[19:12]} : 9'b00000_0000;  //Note: CHANGED ADFGADFBADBDAGBAE
assign IXN_IM = ((IXN_INDEX >= 9'b00000_0100) && (IXN_INDEX <= 9'b11111_1100)) ? {AnalyzerStoredOutput[11], AnalyzerStoredOutput[7:0]}   : 9'b00000_0000;




// ^ checks if harmonics (including those for negative frequencies) are for frequencies above about 60Hz.
//        ie if it is above a minimum and below a mximum, then it fits the range perfectly and is outputted. Otherwise, 0.




//assign ISTART      = (FFTCount[20:0] == 2000100);   //  21'b1111_0100_0010_0111_0010_0 = 2,000,100   Out of 16 * 512 * 512 = (4,194,304)  

assign ISTART      = (FFTCount == 200100);      //  200100   Out of 16 * 512 * 512 = (4,194,304) 
assign IFWD_INV    = 0;                               //
assign IFWD_INV_WE = (FFTCount == 60);                //   Can do it whenever, really- earlier, of course     



assign IUNLOAD = IDONE;

//assign IFFTOutput      = {(!IXK_RE[18]), (!IXK_RE[18]), (!IXK_RE[18]), IXK_RE[7:0]}; //Terrible Idea
assign IFFTOutput      = {(!IXK_RE[18]), IXK_RE[7:0], 3'b000}; 
assign IFFTOutputWE    = IDV;
assign IFFTOutputIndex = IXK_INDEX[8:0];


	 
	 
FFT_IFFT_IP_CORE IFFT_IP_CORE_Instance (
.clk(CLK), // input clk
.start(ISTART), // input start
.unload(IUNLOAD), // input unload
.xn_re(IXN_RE), // input [8 : 0] xn_re
.xn_im(IXN_IM), // input [8 : 0] xn_im
.fwd_inv(IFWD_INV), // input fwd_inv
.fwd_inv_we(IFWD_INV_WE), // input fwd_inv_we
.rfd(IRFD), // output rfd
.xn_index(IXN_INDEX), // output [8 : 0] xn_index
.busy(IBUSY), // output busy
.edone(IEDONE), // output edone
.done(IDONE), // output done
.dv(IDV), // output dv
.xk_index(IXK_INDEX), // output [8 : 0] xk_index
.xk_re(IXK_RE), // output [18 : 0] xk_re
.xk_im(IXK_IM) // output [18 : 0] xk_im
);






Translation_Module_DM Translation_Module_DM_Instance1 (
  .x_in(X_IN1), // input [9 : 0] x_in
  .y_in(Y_IN1), // input [9 : 0] y_in
  .nd(ND1), // input nd
  .x_out(X_OUT1), // output [9 : 0] x_out
  .phase_out(PHASE_OUT1), // output [9 : 0] phase_out
  .rdy(RDY1), // output rdy
  .rfd(RFD1), // output rfd
  .clk(CLK) // input clk
);

Translation_Module_DM Translation_Module_DM_Instance2 (
  .x_in(X_IN2), // input [9 : 0] x_in
  .y_in(Y_IN2), // input [9 : 0] y_in
  .nd(ND2), // input nd
  .x_out(X_OUT2), // output [9 : 0] x_out
  .phase_out(PHASE_OUT2), // output [9 : 0] phase_out
  .rdy(RDY2), // output rdy
  .rfd(RFD2), // output rfd
  .clk(CLK) // input clk
);

Translation_Module_DM Translation_Module_DM_Instance3 (
  .x_in(X_IN3), // input [9 : 0] x_in
  .y_in(Y_IN3), // input [9 : 0] y_in
  .nd(ND3), // input nd
  .x_out(X_OUT3), // output [9 : 0] x_out
  .phase_out(PHASE_OUT3), // output [9 : 0] phase_out
  .rdy(RDY3), // output rdy
  .rfd(RFD3), // output rfd
  .clk(CLK) // input clk
);

Translation_Module_DM Translation_Module_DM_Instance4 (
  .x_in(X_IN4), // input [9 : 0] x_in
  .y_in(Y_IN4), // input [9 : 0] y_in
  .nd(ND4), // input nd
  .x_out(X_OUT4), // output [9 : 0] x_out
  .phase_out(PHASE_OUT4), // output [9 : 0] phase_out
  .rdy(RDY4), // output rdy
  .rfd(RFD4), // output rfd
  .clk(CLK) // input clk
);












endmodule
