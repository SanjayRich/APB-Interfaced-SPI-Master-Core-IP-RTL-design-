
module tb_baudrate_generator;

    // Inputs
    reg PCLK;
    reg PRESETn;
    reg [1:0] spi_mode;
    reg spiswai;
    reg [2:0] sppr;
    reg [2:0] spr;
    reg cpol;
    reg cpha;
    reg ss;

    // Outputs
    wire sclk;
    wire flag_low, flag_high;
    wire flags_low, flags_high;
    wire [11:0] baudratedivisor;

    // Instantiate the DUT (Device Under Test)
    baudrate_generator uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .spi_mode(spi_mode),
        .spiswai(spiswai),
        .sppr(sppr),
        .spr(spr),
        .cpol(cpol),
        .cpha(cpha),
        .ss(ss),
        .sclk(sclk),
        .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .baudratedivisor(baudratedivisor)
    );

    // Clock generation
    initial PCLK = 0;
    always #5 PCLK = ~PCLK;  // 100 MHz clock (10 ns period)

    // Stimulus
    initial begin
        

        // Initial setup
        PRESETn = 0;
        spi_mode = 2'b01;   // SPI Mode 1
        spiswai = 0;
        sppr = 3'b000;
        spr  = 3'b000;
        cpol = 0;
        cpha = 1;           // CPOL=0, CPHA=1 ? Mode 1
        ss = 1;             // Slave not selected initially

        #20 PRESETn = 1;    // Release reset
        #10 ss = 0;         // Enable slave (active low)

        
    end

endmodule
