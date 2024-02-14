`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.02.2024 17:16:21
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
input logic clk, reset,
input logic [7:0] inData,
input logic inDataValid,
output logic [71:0] outData,
output logic outDataValid,
output logic interrupt
    );

logic readBufferValid;
logic [8:0] writeCounter, readCounter;
logic [11:0] totalCounter;
logic [1:0] currentWriteLineBuffer, currentReadLineBuffer;
logic [3:0] bufferDataValid, bufferSelect;
logic [23:0] lb0Data, lb1Data, lb2Data, lb3Data;

typedef enum logic {s0, s1} statetype;
statetype state;

assign outDataValid = readBufferValid;

//Write Buffer Logic
always_ff @(posedge clk)
begin
    if(reset)
        writeCounter <= 0;
    else if(inDataValid)
        writeCounter <= writeCounter + 1;
end

always_ff @(posedge clk)
begin
    if(reset)
        currentWriteLineBuffer <= 0;
    else if(writeCounter == 511 & inDataValid)
        currentWriteLineBuffer <= currentWriteLineBuffer + 1;
end

always_comb
begin
    bufferDataValid = 4'b0;
    bufferDataValid[currentWriteLineBuffer] = inDataValid;
end

//Read Buffer Logic
always_ff @(posedge clk)
begin
    if(reset)
        readCounter <= 0;
    else if(readBufferValid)
        readCounter <= readCounter + 1;
end

always_ff @(posedge clk)
begin
    if(reset)
        currentReadLineBuffer <= 0;
    else if(readCounter == 511 & readBufferValid)
        currentReadLineBuffer <= currentReadLineBuffer + 1;
end

always_comb
begin
    case(currentReadLineBuffer)
        0: outData = {lb2Data, lb1Data, lb0Data};
        1: outData = {lb3Data, lb2Data, lb1Data};
        2: outData = {lb0Data, lb3Data, lb2Data};
        3: outData = {lb1Data, lb0Data, lb3Data};
    endcase 
end

always_comb
begin
    case(currentReadLineBuffer)
        0: bufferSelect = {1'b0, readBufferValid, readBufferValid, readBufferValid};
        1: bufferSelect = {readBufferValid, readBufferValid, readBufferValid, 1'b0};
        2: bufferSelect = {readBufferValid, readBufferValid, 1'b0, readBufferValid};
        3: bufferSelect = {readBufferValid, 1'b0, readBufferValid, readBufferValid};
    endcase 
end

always_ff @(posedge clk)
begin
    if(reset)
        totalCounter <= 0;
    else
    begin
        if(inDataValid & !readBufferValid)
            totalCounter <= totalCounter + 1;
        else if(!inDataValid & readBufferValid)
            totalCounter <= totalCounter - 1;
    end
end

always_ff @(posedge clk)
begin
    if(reset)
        begin
            state <= s0;
            readBufferValid <= 1'b0;
            interrupt <= 1'b0;
        end
    else
        begin
            case(state)
                s0:begin
                    interrupt <= 1'b0;
                    if(totalCounter >= 1536)
                        begin
                            readBufferValid <= 1'b1;
                            state <= s1;
                        end 
                   end
                s1:begin
                    if(readCounter == 511)
                        begin
                            interrupt <= 1'b1;
                            readBufferValid <= 1'b0;
                            state <= s0;
                        end
                   end
            endcase
        end
end


//Line Buffer Instantiation
lineBuffer LB0 (
.clk(clk), 
.reset(reset),
.inData(inData),
.inDataValid(bufferDataValid[0]),
.bufferSelect(bufferSelect[0]),
.outData(lb0Data)
    );
    
lineBuffer LB1 (
.clk(clk), 
.reset(reset),
.inData(inData),
.inDataValid(bufferDataValid[1]),
.bufferSelect(bufferSelect[1]),
.outData(lb1Data)
    );
    
lineBuffer LB2 (
.clk(clk), 
.reset(reset),
.inData(inData),
.inDataValid(bufferDataValid[2]),
.bufferSelect(bufferSelect[2]),
.outData(lb2Data)
    );

lineBuffer LB3 (
.clk(clk), 
.reset(reset),
.inData(inData),
.inDataValid(bufferDataValid[3]),
.bufferSelect(bufferSelect[3]),
.outData(lb3Data)
    );    
    
endmodule
