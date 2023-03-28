`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2023 15:48:41
// Design Name: 
// Module Name: imageControl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module imageControl(
    input clk,
    input rst,
    input [7:0] inPixelData,
    input inPixelDataValid,
    output reg [71:0] outPixelData,
    output outPixelDataValid,
    output reg intr
);

reg [8:0] pixelCounter;
reg [1:0] currentWrLineBuffer;
reg [1:0] currentRdLineBuffer;
reg [3:0] lineBuffWrValid;
reg [3:0] lineBuffRdValid;
wire [23:0] lb0data;
wire [23:0] lb1data;
wire [23:0] lb2data;
wire [23:0] lb3data;
reg [8:0] rdCounter;
reg rdLineBuffer;
reg [11:0] totalPixelCounter;
reg rdState;

localparam IDLE = 'b0,
           RD_BUFFER = 'b1;

assign outPixelDataValid = rdLineBuffer;

always @(posedge clk)
begin
    if(rst)
        totalPixelCounter <= 0;
    else
    begin
        if(inPixelDataValid & !rdLineBuffer)
            totalPixelCounter <= totalPixelCounter + 1;
        else if(!inPixelDataValid & rdLineBuffer)
            totalPixelCounter <= totalPixelCounter - 1;
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        rdState <= IDLE;
        rdLineBuffer <= 1'b0;
        intr <= 1'b0;
    end
    else
    begin
        case(rdState)
            IDLE:
            begin
                intr <= 1'b0;
                if(totalPixelCounter >= 1536)
                begin
                    rdLineBuffer <= 1'b1;
                    rdState <= RD_BUFFER;
                end
            end
            RD_BUFFER:
            begin
                if(rdCounter == 511)
                begin
                    rdState <= IDLE;
                    rdLineBuffer <= 1'b0;
                    intr <= 1'b1;
                end
            end
        endcase
    end
end
    
always @(posedge clk)
begin
    if(rst)
        pixelCounter <= 0;
    else 
    begin
        if(inPixelDataValid)
            pixelCounter <= pixelCounter + 1;
    end
end

always @(posedge clk)
begin
    if(rst)
        currentWrLineBuffer <= 0;
    else
    begin
        if(pixelCounter == 511 & inPixelDataValid)
            currentWrLineBuffer <= currentWrLineBuffer + 1;
    end
end

always @(*)
begin
    lineBuffWrValid = 4'h0;
    lineBuffWrValid[currentWrLineBuffer] = inPixelDataValid;
end

always @(posedge clk)
begin
    if(rst)
        rdCounter <= 0;
    else 
    begin
        if(rdLineBuffer)
            rdCounter <= rdCounter + 1;
    end
end

always @(posedge clk)
begin
    if(rst)
    begin
        currentRdLineBuffer <= 0;
    end
    else
    begin
        if(rdCounter == 511 & rdLineBuffer)
            currentRdLineBuffer <= currentRdLineBuffer + 1;
    end
end

always @(*)
begin
    case(currentRdLineBuffer)
        0:begin
            outPixelData = {lb2data,lb1data,lb0data};
        end
        1:begin
            outPixelData = {lb3data,lb2data,lb1data};
        end
        2:begin
            outPixelData = {lb0data,lb3data,lb2data};
        end
        3:begin
            outPixelData = {lb1data,lb0data,lb3data};
        end
    endcase
end

always @(*)
begin
    case(currentRdLineBuffer)
        0:begin
            lineBuffRdValid[0] = rdLineBuffer;
            lineBuffRdValid[1] = rdLineBuffer;
            lineBuffRdValid[2] = rdLineBuffer;
            lineBuffRdValid[3] = 1'b0;
        end
       1:begin
            lineBuffRdValid[0] = 1'b0;
            lineBuffRdValid[1] = rdLineBuffer;
            lineBuffRdValid[2] = rdLineBuffer;
            lineBuffRdValid[3] = rdLineBuffer;
        end
       2:begin
             lineBuffRdValid[0] = rdLineBuffer;
             lineBuffRdValid[1] = 1'b0;
             lineBuffRdValid[2] = rdLineBuffer;
             lineBuffRdValid[3] = rdLineBuffer;
       end  
      3:begin
             lineBuffRdValid[0] = rdLineBuffer;
             lineBuffRdValid[1] = rdLineBuffer;
             lineBuffRdValid[2] = 1'b0;
             lineBuffRdValid[3] = rdLineBuffer;
       end        
    endcase
end
    
lineBuffer lB0(
    .clk(clk),
    .rst(rst),
    .inData(inPixelData),
    .inDataValid(lineBuffWrValid[0]),
    .inReadData(lineBuffRdValid[0]),
    .outData(lb0data)
); 
 
lineBuffer lB1(
    .clk(clk),
    .rst(rst),
    .inData(inPixelData),
    .inDataValid(lineBuffWrValid[1]),
    .inReadData(lineBuffRdValid[1]),
    .outData(lb1data)
); 
  
lineBuffer lB2(
    .clk(clk),
    .rst(rst),
    .inData(inPixelData),
    .inDataValid(lineBuffWrValid[2]),
    .inReadData(lineBuffRdValid[2]),
    .outData(lb2data)
); 
   
lineBuffer lB3(
    .clk(clk),
    .rst(rst),
    .inData(inPixelData),
    .inDataValid(lineBuffWrValid[3]),
    .inReadData(lineBuffRdValid[3]),
    .outData(lb3data)
);    
    
endmodule