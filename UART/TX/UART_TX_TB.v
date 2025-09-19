`timescale 1ns/1ps

module UART_TX_TB;

  // Parameters
  parameter DATA_WIDTH = 8;
  parameter CLK_PERIOD = 10;   // 100 MHz clock (10 ns period)

  // DUT signals
  reg                    clk;
  reg                    rst_n;
  reg  [DATA_WIDTH-1:0]  P_DATA;
  reg                    Data_Valid;
  reg                    parity_enable;
  reg                    parity_type;
  wire                   TX_OUT;
  wire                   busy;

  // Instantiate DUT
  UART_TX #(.DATA_WIDTH(DATA_WIDTH)) DUT (
    .clk(clk),
    .rst_n(rst_n),
    .P_DATA(P_DATA),
    .Data_Valid(Data_Valid),
    .parity_enable(parity_enable),
    .parity_type(parity_type),
    .TX_OUT(TX_OUT),
    .busy(busy)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // Stimulus
  initial begin
    // Initialize
    rst_n = 0;
    Data_Valid = 0;
    P_DATA = 0;
    parity_enable = 0;
    parity_type = 0;

    // Apply reset
    #(5*CLK_PERIOD);
    rst_n = 1;

    // Send first byte without parity
    #(5*CLK_PERIOD);
    P_DATA = 8'b10101010;
    Data_Valid = 1;
    #(CLK_PERIOD); 
    Data_Valid = 0;

    // Wait until UART not busy
    wait(!busy);

    // Send second byte with even parity
    #(10*CLK_PERIOD);
    parity_enable = 1;
    parity_type = 1;   // even
    P_DATA = 8'hA5;
    Data_Valid = 1;
    #(CLK_PERIOD);
    Data_Valid = 0;

    // Wait until UART not busy
    wait(!busy);

    // Send third byte with odd parity
    #(10*CLK_PERIOD);
    parity_enable = 1;
    parity_type = 0;   // odd
    P_DATA = 8'h3C;
    Data_Valid = 1;
    #(CLK_PERIOD);
    Data_Valid = 0;

    // Wait and finish
    #(200*CLK_PERIOD);
    $finish;
  end

  // Monitor TX_OUT
  initial begin
    $monitor("Time=%0t | TX_OUT=%b | busy=%b | P_DATA=%h", 
              $time, TX_OUT, busy, P_DATA);
  end

endmodule
