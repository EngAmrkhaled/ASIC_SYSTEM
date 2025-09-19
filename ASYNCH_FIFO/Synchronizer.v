
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Amr khaled 
// 
// Create Date: 07/04/2025 06:32:59 PM
// Module Name: Synchronizer
// Project Name: FIFO
//////////////////////////////////////////////////////////////////////////////////


module Synchronizer #(parameter PTR_WIDTH = 3 )(    //size of ptr is 4 but we use bit no. of 3 for full & empty conditions
    input clk,rst_n,
    input [PTR_WIDTH:0] d1,
    output reg [PTR_WIDTH:0] q2
    );
    
 reg [PTR_WIDTH:0] q1;
 
 always @(posedge clk) begin   
    if(!rst_n) begin
      q1 <= 0;
      q2 <= 0;  end
      
    else       begin
      q1 <= d1;
      q2 <= q1;  end
    
                       end   
endmodule
 
 