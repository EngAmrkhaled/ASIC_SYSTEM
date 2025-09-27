module sys_ctrl #(
  parameter DATA_W    = 8,
  parameter ADDR_W    = 4,
  parameter ALU_OUT_W = 16,
  parameter ALU_FUN_W = 4
)(
  input  wire                   CLK,
  input  wire                   RST_n,

  // From Data Synchronizer
  input  wire [DATA_W-1:0]      SYNC_BUS,
  input  wire                   ENABLE_PULSE_D,

  // From ALU
  input  wire [ALU_OUT_W-1:0]   ALU_OUT,
  input  wire                   OUT_Valid,

  // To ALU
  output reg  [ALU_FUN_W-1:0]   ALU_FUN,
  output reg                    EN,
  output reg                    CLK_EN,

  // RegFile
  output reg  [ADDR_W-1:0]      Address,
  output reg                    WrEn,
  output reg                    RdEn,
  output reg  [DATA_W-1:0]      WrData,
  input  wire [DATA_W-1:0]      RdData,
  input  wire                   RdData_Valid,

  // FIFO
  input  wire                   FULL,
  output reg                    W_INC,
  output reg  [DATA_W-1:0]      WR_DATA,

  // CLKDIV
  output reg                    clk_div_en
);

  // command constants (binary)
  localparam [7:0] RF_WR_CMD = 8'b10101010,  // 0xAA
                   RF_RD_CMD = 8'b10111011,  // 0xBB
                   ALU_WOP   = 8'b11001100,  // 0xCC
                   ALU_WNOP  = 8'b11011101;  // 0xDD

  // FSM states (renamed WR_DATA -> WR_DATA_S to avoid conflict)
  localparam [3:0] IDLE        = 4'b0000,
                   WR_ADDR     = 4'b0001,
                   WR_DATA_S   = 4'b0010,
                   RD_ADDR     = 4'b0011,
                   SEND_RD     = 4'b0100,
                   ALU_OPA     = 4'b0101,
                   ALU_OPB     = 4'b0110,
                   ALU_FUN_S   = 4'b0111,
                   ALU_OUT_WT  = 4'b1000,
                   ALU_SEND1   = 4'b1001,
                   ALU_SEND2   = 4'b1010;

  reg [3:0] current_state, next_state;

  // saved regs
  reg [DATA_W-1:0] addr_reg;
  reg [ALU_OUT_W-1:0] alu_result;

  //------------------------------------------------
  // 1) State register
  //------------------------------------------------
  always @(posedge CLK or negedge RST_n) begin
    if(!RST_n) begin
      current_state <= IDLE;
      addr_reg      <= {DATA_W{1'b0}};
      alu_result    <= {ALU_OUT_W{1'b0}};
    end else begin
      current_state <= next_state;

      // save address byte
      if(ENABLE_PULSE_D && current_state == WR_ADDR)
        addr_reg <= SYNC_BUS;

      if(ENABLE_PULSE_D && current_state == RD_ADDR)
        addr_reg <= SYNC_BUS;

      // latch ALU result
      if(OUT_Valid)
        alu_result <= ALU_OUT;
    end
  end

  //------------------------------------------------
  // 2) Next state logic
  //------------------------------------------------
  always @(*) begin
    next_state = current_state;
    case(current_state)
      IDLE: begin
        if(ENABLE_PULSE_D) begin
          case(SYNC_BUS)
            RF_WR_CMD : next_state = WR_ADDR;
            RF_RD_CMD : next_state = RD_ADDR;
            ALU_WOP   : next_state = ALU_OPA;
            ALU_WNOP  : next_state = ALU_FUN_S;
            default   : next_state = IDLE;
          endcase
        end
      end

      WR_ADDR: begin
        if(ENABLE_PULSE_D)
          next_state = WR_DATA_S;
      end

      WR_DATA_S: begin
        if(ENABLE_PULSE_D)
          next_state = IDLE;
      end

      RD_ADDR: begin
        if(ENABLE_PULSE_D)
          next_state = SEND_RD;
      end

      SEND_RD: begin                        //recieve data  from rf
        if(RdData_Valid && !FULL)
          next_state = IDLE;
      end

      ALU_OPA: begin
        if(ENABLE_PULSE_D)
          next_state = ALU_OPB;
      end

      ALU_OPB: begin
        if(ENABLE_PULSE_D)
          next_state = ALU_FUN_S;
      end

      ALU_FUN_S: begin
        if(ENABLE_PULSE_D)
          next_state = ALU_OUT_WT;
      end

      ALU_OUT_WT: begin
        if(OUT_Valid)
          next_state = ALU_SEND1;
      end

      ALU_SEND1: begin
        if(!FULL)
          if(ALU_OUT_W > DATA_W)
            next_state = ALU_SEND2;
          else
            next_state = IDLE;
      end

      ALU_SEND2: begin
        if(!FULL)
          next_state = IDLE;
      end

      default: next_state = IDLE;
    endcase
  end

  //------------------------------------------------
  // 3) Output logic
  //------------------------------------------------
  always @(*) begin
    // defaults
    WrEn      = 1'b0;
    RdEn      = 1'b0;
    EN        = 1'b0;
    CLK_EN    = 1'b0;
    W_INC     = 1'b0;
    WR_DATA   = {DATA_W{1'b0}};
    Address   = {ADDR_W{1'b0}};
    WrData    = {DATA_W{1'b0}};
    ALU_FUN   = {ALU_FUN_W{1'b0}};
    clk_div_en= 1'b1;  // always enabled

    case(current_state)
      WR_DATA_S: begin
        if(ENABLE_PULSE_D) begin
          Address = addr_reg[ADDR_W-1:0];
          WrData  = SYNC_BUS;
          WrEn    = 1'b1;
        end
      end

      RD_ADDR: begin
        if(ENABLE_PULSE_D) begin
          Address = SYNC_BUS[ADDR_W-1:0];
          RdEn    = 1'b1;
        end
      end

      SEND_RD: begin
        if(RdData_Valid && !FULL) begin
          WR_DATA = RdData;
          W_INC   = 1'b1;
        end
      end

      ALU_OPA: begin
        if(ENABLE_PULSE_D) begin
          Address = 4'b0000;
          WrData  = SYNC_BUS;
          WrEn    = 1'b1;
        end
      end

      ALU_OPB: begin
        if(ENABLE_PULSE_D) begin
          Address = 4'b0001;
          WrData  = SYNC_BUS;
          WrEn    = 1'b1;
        end
      end

      ALU_FUN_S: begin
        if(ENABLE_PULSE_D) begin
          ALU_FUN = SYNC_BUS[ALU_FUN_W-1:0];
          EN      = 1'b1;
          CLK_EN  = 1'b1;
        end
      end

      ALU_SEND1: begin
        if(!FULL) begin
          WR_DATA = alu_result[ALU_OUT_W-1 -: DATA_W]; // MSB
          W_INC   = 1'b1;
        end
      end

      ALU_SEND2: begin
        if(!FULL) begin
          WR_DATA = alu_result[DATA_W-1:0]; // LSB
          W_INC   = 1'b1;
        end
      end
    endcase
  end

endmodule
