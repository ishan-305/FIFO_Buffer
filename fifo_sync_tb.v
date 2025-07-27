`timescale 1ns/1ps

module fifo_sync_tb;

  parameter DATA_WIDTH = 8;
  parameter DEPTH = 16;
  parameter ADDR_WIDTH = 4;

  // DUT I/O
  reg clk;
  reg rst;
  reg wr_en;
  reg rd_en;
  reg [DATA_WIDTH-1:0] din;
  wire [DATA_WIDTH-1:0] dout;
  wire full;
  wire empty;

  // Instantiate DUT
  fifo_sync #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH),
    .ADDR_WIDTH(ADDR_WIDTH)
  ) uut (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .din(din),
    .dout(dout),
    .full(full),
    .empty(empty)
  );

  // Clock
  initial clk = 0;
  always #5 clk = ~clk;

  // Stimulus
  initial begin
    $dumpfile("fifo.vcd");
    $dumpvars(0, fifo_sync_tb);

    rst = 1; wr_en = 0; rd_en = 0; din = 0;

    #20 rst = 0;

    // Write 5 data
    repeat (5) begin
      @(posedge clk);
      wr_en = 1;
      din = $random % 256;
    end
    @(posedge clk);
    wr_en = 0;

    #20;

    // Read 5 data
    repeat (5) begin
      @(posedge clk);
      rd_en = 1;
    end
    @(posedge clk);
    rd_en = 0;

    #50 $finish;
  end

  initial begin
    $monitor("T=%0t wr_en=%b din=%h rd_en=%b dout=%h full=%b empty=%b",
      $time, wr_en, din, rd_en, dout, full, empty);
  end

endmodule