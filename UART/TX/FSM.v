`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2025 04:08:24 AM
// Design Name: 
// Module Name: FSM
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
`timescale 1ns / 1ps

module FSM(
    input clk, rst_n,
    input Data_Valid, ser_done, par_en,
    output reg [1:0] mux_sel, // Changed from [2:0] to [1:0]
    output reg busy, ser_en
);
    
    parameter IDLE = 3'b000,
              START_STATE = 3'b001,
              DATA_STATE = 3'b010,
              PARITY_STATE = 3'b011,
              STOP_STATE = 3'b100;
              
    reg [2:0] cs, ns;
  
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            cs <= IDLE;
        else 
            cs <= ns;
    end 
                                         
    always @(*) begin
        case(cs)
            IDLE: begin
                if(Data_Valid)
                    ns <= START_STATE;
                else 
                    ns <= IDLE;  
            end     
            START_STATE: begin
                ns <= DATA_STATE;
            end              
            DATA_STATE: begin
                if(ser_done) begin
                    if(par_en)
                        ns <= PARITY_STATE;
                    else
                        ns <= STOP_STATE;  
                end 
                else
                    ns <= DATA_STATE;              
            end    
            PARITY_STATE: begin
                ns <= STOP_STATE;   
            end   
            STOP_STATE: begin        
                    ns <= IDLE;      
            end
            default: ns <= IDLE;
        endcase                                    
    end
                                          
    always @(*) begin
        case(cs)
            IDLE: begin
                mux_sel <= 2'b11;
                busy <= 0;
                ser_en <= 0; 
            end     
            START_STATE: begin
                mux_sel <= 2'b00;
                busy <= 1;
                ser_en <= 0;
            end              
            DATA_STATE: begin
                ser_en <= 1'b1;    
                busy <= 1'b1;
                mux_sel <= 2'b01;    
                if(ser_done)
                    ser_en <= 1'b0;  
                else
                    ser_en <= 1'b1;            
            end    
            PARITY_STATE: begin
                mux_sel <= 2'b10;
                busy <= 1;
                ser_en <= 0;   
            end   
            STOP_STATE: begin
                mux_sel <= 2'b11;
                busy <= 1;
                ser_en <= 0;  
            end
            default: begin
                busy <= 1'b0;
                ser_en <= 1'b0;
                mux_sel <= 2'b00;        
            end                 
        endcase                                                              
    end                                                                                   
endmodule