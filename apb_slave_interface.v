module apb_slave_interface (
  input         PCLK,
  input         PRESETn,
  input  [2:0]  PADDR,
  input         PWRITE,
  input         PSEL,
  input         PENABLE,
  input  [7:0]  PWDATA,
  input         ss,
  input  [7:0]  miso_data,
  input         receive_data,
  input         tip,

  output [7:0]  PRDATA,
  output        mstr,
  output        cpol,
  output        cpha,
  output        lsbfe,
  output        spiswai,
  output [2:0]  sppr,
  output [2:0]  spr,
  output        spi_interrupt_request,
  output        PREADY,
  output        PSLVERR,
  output        send_data,
  output [7:0]  mosi_data,
  output [1:0]  spi_mode
);

  reg [7:0] SPI_CR1, SPI_CR2, SPI_SR, SPI_DR, SPI_BR;
  reg [1:0] present_state, next_state, spi_mode_reg, next_mode;
  reg send_data_reg;
  reg [7:0] mosi_data_reg;

  wire sptef, spif, spe, modfen, modf, ssoe, wr_enb, rd_enb, spie, sptie;

  assign mstr   = SPI_CR1[4];
  assign spe    = SPI_CR1[6];
  assign spie   = SPI_CR1[7];
  assign sptie  = SPI_CR1[5];
  assign cpol   = SPI_CR1[3];
  assign cpha   = SPI_CR1[2];
  assign lsbfe  = SPI_CR1[0];
  assign modfen = SPI_CR2[4];
  assign spiswai= SPI_CR2[1];
  assign sppr   = SPI_BR[6:4];
  assign spr    = SPI_BR[2:0];

  parameter cr2_mask = 8'b0001_1011;
  parameter br_mask  = 8'b0111_0111;

  parameter [1:0] idle = 2'b00, setup = 2'b01, enable = 2'b10;
  parameter [1:0] spi_run = 2'b00, spi_wait = 2'b01, spi_stop = 2'b10;

  assign wr_enb = (PWRITE && (present_state == enable));
  assign rd_enb = (!PWRITE && (present_state == enable));
  assign PREADY = (present_state == enable);
  assign PSLVERR = (present_state == enable) ? tip : 1'b0;
  assign sptef = (SPI_DR == 8'b0);
  assign spif  = (SPI_DR != 8'b0);
  assign modf  = (mstr & modfen & (~ssoe) & (~ss));

  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      present_state <= idle;
      spi_mode_reg  <= spi_run;
    end else begin
      present_state <= next_state;
      spi_mode_reg  <= next_mode;
    end
  end

  always @(*) begin
    next_state = present_state;
    case (present_state)
      idle:    if (PSEL && !PENABLE) next_state = setup;
      setup:   if (PSEL && PENABLE) next_state = enable;
               else if (!PSEL) next_state = idle;
      enable:  next_state = PSEL ? setup : idle;
    endcase
  end

  always @(*) begin
    next_mode = spi_mode_reg;
    case (spi_mode_reg)
      spi_run:  if (!spe) next_mode = spi_wait;
      spi_wait: if (spe) next_mode = spi_run;
                else if (spiswai) next_mode = spi_stop;
      spi_stop: if (!spiswai) next_mode = spi_wait;
                else if (spe) next_mode = spi_run;
    endcase
  end

  assign spi_mode = spi_mode_reg;

  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
      SPI_SR <= 8'b0;
    else
      SPI_SR <= {spif, 1'b0, sptef, modf, 4'b0};
  end

  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
      SPI_CR1 <= 8'h04;
    else if (wr_enb && PADDR == 3'b000)
      SPI_CR1 <= PWDATA;
  end

  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
      SPI_CR2 <= 8'h00;
    else if (wr_enb && PADDR == 3'b001)
      SPI_CR2 <= PWDATA & cr2_mask;
  end

  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
      SPI_BR <= 8'h00;
    else if (wr_enb && PADDR == 3'b010)
      SPI_BR <= PWDATA & br_mask;
  end

  assign spi_interrupt_request = (!spie && !sptie) ? 1'b0 :
                                 (spie && !sptie) ? (spif || modf) :
                                 (!spie && sptie) ? sptef :
                                 (spif || sptef || modf);

  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
      SPI_DR <= 8'b0;
    else if (wr_enb && PADDR == 3'b101)
      SPI_DR <= PWDATA;
    else if (receive_data && (spi_mode_reg != spi_stop))
      SPI_DR <= miso_data;
  end

  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
      mosi_data_reg <= 8'b0;
    else if ((SPI_DR != 8'b0) && (spi_mode_reg != spi_stop))
      mosi_data_reg <= SPI_DR;
  end

  assign mosi_data = mosi_data_reg;

  assign PRDATA = (!rd_enb) ? 8'b0 :
                  (PADDR == 3'b000) ? SPI_CR1 :
                  (PADDR == 3'b001) ? SPI_CR2 :
                  (PADDR == 3'b010) ? SPI_BR :
                  (PADDR == 3'b011) ? SPI_SR : SPI_DR;

  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
      send_data_reg <= 1'b0;
    else if ((SPI_DR != 8'b0) && (spi_mode_reg != spi_stop))
      send_data_reg <= 1'b1;
    else
      send_data_reg <= 1'b0;
  end

  assign send_data = send_data_reg;

endmodule

