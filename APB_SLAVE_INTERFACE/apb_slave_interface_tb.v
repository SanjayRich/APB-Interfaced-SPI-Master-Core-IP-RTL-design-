module tb_apb_slave_interface;

  reg PCLK;
  reg PRESETn;
  reg [2:0] PADDR;
  reg PSEL;
  reg PENABLE;
  reg PWRITE;
  reg [7:0] PWDATA;
  reg ss;
  reg receive_data;
  reg [7:0] miso_data;
  reg tip;

  wire PREADY;
  wire PSLVERR;
  wire [7:0] PRDATA;
  wire spi_interrupt_request;
  wire send_data;
  wire mstr;
  wire cpol;
  wire cpha;
  wire lsbfe;
  wire spiswai;
  wire [7:0] mosi_data;
  wire [1:0] spi_mode;
  wire [2:0] spr;
  wire [2:0] sppr;

  apb_slave_interface uut (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PADDR(PADDR),
    .PWRITE(PWRITE),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWDATA(PWDATA),
    .ss(ss),
    .receive_data(receive_data),
    .miso_data(miso_data),
    .tip(tip),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR),
    .PRDATA(PRDATA),
    .spi_interrupt_request(spi_interrupt_request),
    .send_data(send_data),
    .mstr(mstr),
    .cpol(cpol),
    .cpha(cpha),
    .lsbfe(lsbfe),
    .spiswai(spiswai),
    .mosi_data(mosi_data),
    .spi_mode(spi_mode),
    .spr(spr),
    .sppr(sppr)
  );

  initial begin
    PCLK = 0;
    forever #5 PCLK = ~PCLK;
  end

  initial begin
    PRESETn = 0;
    ss = 1;
    tip = 0;
    receive_data = 0;
    miso_data = 8'h00;
    #20;
    PRESETn = 1;
    PSEL = 0;
    PENABLE = 0;
    PWRITE = 0;

    apb_write(3'b000, 8'b10101101); 
    apb_write(3'b001, 8'b11101101);
    apb_write(3'b010, 8'b11001010);
    apb_write(3'b101, 8'b10010011);

    apb_read(3'b000);
    apb_read(3'b001);
    apb_read(3'b010);
    apb_read(3'b101);

    // Simulate receiving data
    miso_data = 8'h5C;
    receive_data = 1;
    #20 receive_data = 0;

    apb_read(3'b101);

    #100 $finish;
  end

  task apb_write(input [2:0] addr, input [7:0] data);
  begin
    @(posedge PCLK);
    PSEL = 1;
    PENABLE = 0;
    PWRITE = 1;
    PADDR = addr;
    PWDATA = data;

    @(posedge PCLK);
    PENABLE = 1;

    @(posedge PCLK);
    PSEL = 0;
    PENABLE = 0;
  end
  endtask

  task apb_read(input [2:0] addr);
  begin
    @(posedge PCLK);
    PSEL = 1;
    PENABLE = 0;
    PWRITE = 0;
    PADDR = addr;

    @(posedge PCLK);
    PENABLE = 1;

    @(posedge PCLK);
    PSEL = 0;
    PENABLE = 0;

    @(posedge PCLK);
    $display("Read from addr %b = %h", addr, PRDATA);
  end
  endtask

endmodule

