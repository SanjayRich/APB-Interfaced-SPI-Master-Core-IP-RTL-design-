module spi_core (
    input         PCLK,
    input         PRESETn,
    input  [2:0]  PADDR,
    input         PWRITE,
    input         PSEL,
    input         PENABLE,
    input  [7:0]  PWDATA,
    input         miso,

    output        ss,
    output        sclk,
    output        spi_interrupt_request,
    output        mosi,
    output [7:0]  PRDATA,
    output        PREADY,
    output        PSLVERR
);

    wire tip;
    wire [1:0] spi_mode;
    wire spiswai, cpol, cpha, lsbfe, mstr;
    wire flag_low, flag_high, flags_low, flags_high;
    wire send_data, receive_data;
    wire [11:0] BaudRateDivisor;
    wire [7:0] mosi_data, data_miso;
    wire [2:0] spr, sppr;

    apb_slave_interface APB_SLAVE (
        .PCLK(PCLK), .PRESETn(PRESETn), .PADDR(PADDR), .PWRITE(PWRITE),
        .PSEL(PSEL), .PENABLE(PENABLE), .PWDATA(PWDATA), .ss(ss),
        .miso_data(data_miso), .receive_data(receive_data), .tip(tip),
        .PRDATA(PRDATA), .mstr(mstr), .cpol(cpol), .cpha(cpha),
        .lsbfe(lsbfe), .spiswai(spiswai), .sppr(sppr), .spr(spr),
        .spi_interrupt_request(spi_interrupt_request),
        .PREADY(PREADY), .PSLVERR(PSLVERR), .send_data(send_data),
        .mosi_data(mosi_data), .spi_mode(spi_mode)
    );

    baudrate_generator BAUD_GEN (
        .PCLK(PCLK), .PRESETn(PRESETn), .spi_mode(spi_mode),
        .spiswai(spiswai), .sppr(sppr), .spr(spr), .cpol(cpol),
        .cpha(cpha), .ss(ss), .sclk(sclk), .flag_low(flag_low),
        .flag_high(flag_high), .flags_low(flags_low), .flags_high(flags_high),
        .baudratedivisor(BaudRateDivisor)
    );

    spi_slave_control_select SPI_CTRL (
        .PCLK(PCLK), .PRESETn(PRESETn), .mstr(mstr), .spiswai(spiswai),
        .spi_mode(spi_mode), .send_data(send_data),
        .BaudRateDivisor(BaudRateDivisor), .receive_data(receive_data),
        .ss(ss), .tip(tip)
    );

    shift_reg SHIFT_REG (
        .PCLK(PCLK), .PRESETn(PRESETn), .ss(ss), .send_data(send_data),
        .receive_data(receive_data), .lsbfe(lsbfe), .cpha(cpha), .cpol(cpol),
        .flag_low(flag_low), .flag_high(flag_high), .flags_low(flags_low),
        .flags_high(flags_high), .data_mosi(mosi_data), .miso(miso),
        .mosi(mosi), .data_miso(data_miso)
    );

endmodule
