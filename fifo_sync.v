module fifo_sync #(
  parameter DATA_WIDTH = 8,
  parameter DEPTH = 16,
  parameter ADDR_WIDTH = 4 // log2(DEPTH)
)(
  input wire clk,
  input wire rst,

  input wire wr_en,
  input wire rd_en,
  input wire [DATA_WIDTH-1:0] din,

  output reg [DATA_WIDTH-1:0] dout,
  output reg full,
  output reg empty
);

  // ✅ FIFO Memory Array —> Storage is sequential
  reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];

  // ✅ Pointers and Counter —> Sequential registers
  reg [ADDR_WIDTH-1:0] write_ptr, read_ptr;
  reg [ADDR_WIDTH:0] count;  // Stores occupancy — sequential

  // ✅ Write Logic —> Updates write_ptr & storage synchronously
  always @(posedge clk) begin
    if (rst) begin
      write_ptr <= 0;
    end else if (wr_en && !full) begin
      fifo_mem[write_ptr] <= din;   // Write data into storage
      write_ptr <= write_ptr + 1;   // Advance write pointer
    end
  end

  // ✅ Read Logic —> Updates read_ptr & output synchronously
  always @(posedge clk) begin
    if (rst) begin
      dout <= 0;
      read_ptr <= 0;
    end else if (rd_en && !empty) begin
      dout <= fifo_mem[read_ptr];   // Output data from storage
      read_ptr <= read_ptr + 1;     // Advance read pointer
    end
  end

  // ✅ Counter Logic —> Tracks occupancy synchronously
  always @(posedge clk) begin
    if (rst) begin
      count <= 0;
    end else begin
      case ({wr_en && !full, rd_en && !empty})
        2'b10: count <= count + 1;   // Write only
        2'b01: count <= count - 1;   // Read only
        default: count <= count;     // Idle or both (write & read same cycle)
      endcase
    end
  end

  // ✅ Status Flags —> Sequentially update flags
  always @(posedge clk) begin
    if (rst) begin
      full <= 0;
      empty <= 1;
    end else begin
      full <= (count == DEPTH);
      empty <= (count == 0);
    end
  end

endmodule
