
module tb1_shift_reg;

    reg PCLK, PRESETn;
    reg ss, send_data, receive_data, lsbfe, cpha, cpol;
    reg flag_low, flag_high, flags_low, flags_high;
    reg [7:0] data_mosi;
    reg miso;

    wire mosi;
    wire [7:0] data_miso;

    // Instantiate DUT
    shift_reg uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .ss(ss),
        .send_data(send_data),
        .receive_data(receive_data),
        .lsbfe(lsbfe),
        .cpha(cpha),
        .cpol(cpol),
        .flag_low(flag_low),
        .flag_high(flag_high),
        .flags_low(flags_low),
        .flags_high(flags_high),
        .data_mosi(data_mosi),
        .miso(miso),
        .mosi(mosi),
        .data_miso(data_miso)
    );

    // Clock generation
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;
    end

    integer i;
    reg [7:0] miso_data = 8'b11001100; // Data to be captured into data_miso from master

    initial begin
        // Initialize
        PRESETn = 0;
        ss = 1;
        send_data = 0;
        receive_data = 0;
        lsbfe = 1;  // LSB First
        cpha = 0;
        cpol = 0;
        flag_low = 0;
        flag_high = 0;
        flags_low = 0;
        flags_high = 0;
        data_mosi = 8'b10101010;
        miso = 0;

        #15 PRESETn = 1; // Deassert reset
        #10 ss = 0;       // Enable slave

        // Send data to shift register
        send_data = 1;
        #10 send_data = 0;

        // Shift out bits through MOSI and shift in MISO bits
        for (i = 0; i < 8; i = i + 1) begin
            miso = miso_data[i];      // Set miso bit to shift into data_miso
            flag_low = 1; flags_low = 1;
            #10;
            flag_low = 0; flags_low = 0;
            #10;
        end

        // Receive data into data_miso (temp_reg)
        receive_data = 1;
        #10 receive_data = 0;

    end

endmodule

