`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2025 06:16:33 PM
// Design Name: 
// Module Name: ALU_TB
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


`timescale 1ns/1ps

module ALU_TB();

  // Parameters
  parameter OPER_WIDTH = 8;
  parameter OUT_WIDTH  = OPER_WIDTH*2;

  // Testbench signals
  reg  [OPER_WIDTH-1:0] A, B;
  reg                   EN;
  reg  [3:0]            ALU_FUN;
  reg                   CLK;
  reg                   RST;
  wire [OUT_WIDTH-1:0]  ALU_OUT;
  wire                  OUT_VALID;

  // Instantiate DUT
  ALU #(
    .OPER_WIDTH(OPER_WIDTH),
    .OUT_WIDTH(OUT_WIDTH)
  ) DUT (
    .A(A),
    .B(B),
    .EN(EN),
    .ALU_FUN(ALU_FUN),
    .CLK(CLK),
    .RST(RST),
    .ALU_OUT(ALU_OUT),
    .OUT_VALID(OUT_VALID)
  );

  // Clock generation: 10ns period
  initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
  end

  // Reset task
  task reset_dut;
  begin
    RST = 0; EN = 0; A = 0; B = 0; ALU_FUN = 0;
    #20;
    RST = 1;
    #10;
  end
  endtask

  // Apply stimulus
  initial begin
    $display("---- Starting ALU Testbench ----");
    reset_dut();

    EN = 1;

    // Test all ALU_FUN operations
    apply_test(8'd15, 8'd3, 4'b0000); // ADD
    apply_test(8'd15, 8'd3, 4'b0001); // SUB
    apply_test(8'd6 , 8'd5, 4'b0010); // MUL
    apply_test(8'd12, 8'd4, 4'b0011); // DIV
    apply_test(8'hF0, 8'h0F, 4'b0100); // AND
    apply_test(8'hF0, 8'h0F, 4'b0101); // OR
    apply_test(8'hAA, 8'h55, 4'b0110); // NAND
    apply_test(8'hAA, 8'h55, 4'b0111); // NOR
    apply_test(8'hAA, 8'h55, 4'b1000); // XOR
    apply_test(8'hAA, 8'h55, 4'b1001); // XNOR
    apply_test(8'd8 , 8'd8 , 4'b1010); // Equal
    apply_test(8'd9 , 8'd5 , 4'b1011); // Greater
    apply_test(8'd3 , 8'd7 , 4'b1100); // Less
    apply_test(8'd16, 8'd0 , 4'b1101); // Shift Right
    apply_test(8'd16, 8'd0 , 4'b1110); // Shift Left

    // Disable EN
    EN = 0;
    #20;

    $display("---- Testbench Completed ----");
    $stop;
  end

  // Task for applying inputs
  task apply_test(input [OPER_WIDTH-1:0] tA,
                  input [OPER_WIDTH-1:0] tB,
                  input [3:0] tFUN);
  begin
    @(negedge CLK);
    A = tA;
    B = tB;
    ALU_FUN = tFUN;
    @(posedge CLK);
    #2; // small delay to sample
    $display("Time=%0t | FUN=%b | A=%0d | B=%0d | OUT=%0d | OUT_VALID=%b",
              $time, ALU_FUN, A, B, ALU_OUT, OUT_VALID);
  end
  endtask

endmodule

