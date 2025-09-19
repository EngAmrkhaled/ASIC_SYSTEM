`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2025 08:13:18 PM
// Design Name: 
// Module Name: Fifo_top
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


module asynchronous_fifo #(parameter DEPTH=8, DATA_WIDTH=8) (
  input wclk, wrst_n,
  input rclk, rrst_n,
  input w_en, r_en,
  input [DATA_WIDTH-1:0] data_in,
  output wire [DATA_WIDTH-1:0] data_out,
  output wire full, empty
);
  
  parameter PTR_WIDTH = 3;
 
  wire [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync;
  wire [PTR_WIDTH:0] b_wptr, b_rptr;
  wire [PTR_WIDTH:0] g_wptr, g_rptr;

  wire [PTR_WIDTH:0] waddr, raddr;

  Synchronizer #(PTR_WIDTH) sync_wptr (
      .clk(rclk),           // map to rclk
      .rst_n(rrst_n),       // map to rrst_n
      .d1(g_wptr),          // map to g_wptr (input data)
      .q2(g_wptr_sync)      // map to g_wptr_sync (synchronized output)
    ); // write pointer to read clock domain
  
    Synchronizer #(PTR_WIDTH) sync_rptr (
      .clk(wclk),           // map to wclk
      .rst_n(wrst_n),       // map to wrst_n
      .d1(g_rptr),          // map to g_rptr (input data)
      .q2(g_rptr_sync)      // map to g_rptr_sync (synchronized output)
    ); // read pointer to write clock domain
    
  wptr_handler #(PTR_WIDTH) wptr_h (
      .wclk(wclk),          // map to wclk
      .wrst_n(wrst_n),      // map to wrst_n
      .w_en(w_en),          // map to w_en
      .g_rptr_sync(g_rptr_sync), // map to g_rptr_sync
      .b_wptr(b_wptr),      // map to b_wptr
      .g_wptr(g_wptr),      // map to g_wptr
      .full(full)           // map to full
    );
 
  rptr_handler #(PTR_WIDTH) rptr_h (
      .rclk(rclk),          // map to rclk
      .rrst_n(rrst_n),      // map to rrst_n
      .r_en(r_en),          // map to r_en
      .g_wptr_sync(g_wptr_sync), // map to g_wptr_sync
      .b_rptr(b_rptr),      // map to b_rptr
      .g_rptr(g_rptr),      // map to g_rptr
      .empty(empty)         // map to empty
    );
  
  fifo_mem fifom (
      .wclk(wclk),          // map to wclk
      .w_en(w_en),          // map to w_en
      .rclk(rclk),          // map to rclk
      .r_en(r_en),          // map to r_en
      .b_wptr(b_wptr),      // map to b_wptr
      .b_rptr(b_rptr),      // map to b_rptr
      .data_in(data_in),    // map to data_in
      .full(full),          // map to full
      .empty(empty),        // map to empty
      .data_out(data_out)   // map to data_out
    );

endmodule
