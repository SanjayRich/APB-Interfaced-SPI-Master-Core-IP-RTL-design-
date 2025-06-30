
module spi_slave_control_select_tb;

  // DUT inputs
  reg         PCLK;
  reg         PRESETn;
  reg         mstr;
  reg         spiswai;
  reg  [1:0]  spi_mode;
  reg         send_data;
  reg  [11:0] BaudRateDivisor;

  // DUT outputs
  wire        receive_data;
  wire        ss;
  wire        tip;

  // Instantiate DUT
  spi_slave_control_select dut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .mstr(mstr),
    .spiswai(spiswai),
    .spi_mode(spi_mode),
    .send_data(send_data),
    .BaudRateDivisor(BaudRateDivisor),
    .receive_data(receive_data),
    .ss(ss),
    .tip(tip)
  );

  // Clock generation
  always #5 PCLK = ~PCLK; // 100MHz clock

  initial begin
    // Initial values
    PCLK = 0;
    PRESETn = 0;
    mstr = 0;
    spiswai = 0;
    spi_mode = 2'b00;
    send_data = 0;
    BaudRateDivisor = 12'd10; // target = 10 << 4 = 160

    // Apply reset
    #12;
    PRESETn = 1;

    // Start SPI in master mode with send_data high
    #10;
    mstr = 1;
    spi_mode = 2'b00;
    spiswai = 0;
    send_data = 1;

    // Wait a few clock cycles
    #40;
    send_data = 0;

    // Wait for count to reach target and rcv to trigger receive_data
    #(160 * 10); // wait enough cycles for the counter

    // Hold
 

    // Stop simulation
  end

  // Monitor outputs
  initial begin
    $monitor("Time=%0t | ss=%b | tip=%b | receive_data=%b | send_data=%b | count_target=%d",
             $time, ss, tip, receive_data, send_data, dut.target);
  end

endmodule

