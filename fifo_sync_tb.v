`timescale 1ns/1ps

module fifo_basic_tb;

  parameter DATA_WIDTH = 8;
  parameter DEPTH = 16;
  parameter ADDR_WIDTH = 4;

  reg clk, rst;
  reg wr_en, rd_en;
  reg [DATA_WIDTH-1:0] din;
  wire [DATA_WIDTH-1:0] dout;
  wire full, empty;
  wire [ADDR_WIDTH:0] count;

  // Instantiate DUT
  fifo_sync #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) dut (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .din(din),
    .dout(dout),
    .full(full),
    .empty(empty),
    .count(count)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Stimulus
  initial begin
    $dumpfile("fifo.vcd");
    $dumpvars(0, fifo_basic_tb);

    // Initial state
    rst = 1; wr_en = 0; rd_en = 0; din = 0;
    #20 rst = 0;

    // Write data into FIFO
    repeat (5) begin
      @(posedge clk);
      if (!full) begin
        wr_en = 1;
        din = $random;
      end
    end
    @(posedge clk); wr_en = 0;

    // Read data from FIFO
    repeat (5) begin
      @(posedge clk);
      if (!empty)
        rd_en = 1;
    end
    @(posedge clk); rd_en = 0;

    // Underflow attempt (read when empty)
    @(posedge clk); rd_en = 1;
    @(posedge clk); rd_en = 0;

    // Overflow attempt (write beyond full)
    repeat (DEPTH) begin
      @(posedge clk);
      wr_en = 1;
      din = $random;
    end
    @(posedge clk); wr_en = 0;

    // Attempt one extra write (should be blocked)
    @(posedge clk);
    wr_en = 1; din = $random;
    @(posedge clk);
    wr_en = 0;

    #20 $finish;
  end

  initial begin
    $monitor("T=%0t wr=%b din=%h rd=%b dout=%h full=%b empty=%b count=%0d",
      $time, wr_en, din, rd_en, dout, full, empty, count);
  end

endmodule
