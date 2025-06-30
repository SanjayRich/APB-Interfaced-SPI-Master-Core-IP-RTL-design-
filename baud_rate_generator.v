module baudrate_generator(
    input PCLK,
    input PRESETn,
    input [1:0] spi_mode,
    input spiswai,
    input [2:0] sppr,
    input [2:0] spr,
    input cpol,
    input cpha,
    input ss,
    
    
   
    
    
    output reg sclk,
    output reg flag_low, 
    output reg flag_high,
    output reg flags_low, 
    output reg flags_high,
    output reg [11:0] baudratedivisor
);

reg [11:0] count;

wire w1, w2;
assign w1 = (~ss) & (~spiswai) & ((spi_mode == 2'b00) || (spi_mode == 2'b01));
xor g0(w2, cpol, cpha);
wire pre_sclk = cpol;



always @(*) begin
    baudratedivisor = (sppr + 1) * (1 << (spr + 1));
end


// count
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        count <= 12'b0;
    else
        count <= w1? ((count==baudratedivisor-1'b1)?(12'b0):(count+1'b1)):(12'b0);
end

// SCLK
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) 
        sclk <= pre_sclk; 
    else 
        sclk <= w1 ?((count==baudratedivisor-1'b1)?(~sclk):(sclk)):(pre_sclk); 
end

// flags_low 
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) 
        flags_low <= 1'b0;
    else 
	flags_low <= w2? (flags_low):((sclk)?(1'b0):((count==baudratedivisor-2'b10)?(1'b1):(1'b0)));
        end

// flags_high
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) 
        flags_high <= 1'b0;
    else 
	flags_high <= w2? ((sclk)?((count==baudratedivisor-2'b10)?(1'b1):(1'b0)):(1'b0)):(flags_high);
	end
// flag_low 
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) 
        flag_low <= 1'b0;
    else 
        flag_low <= w2?(flag_low):((sclk)?(1'b0):((count==baudratedivisor-1'b1)?(1'b1):(1'b0)));
end
// flag_high
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) 
        flag_high <= 1'b0;
    else 
        flag_high <= w2?((sclk)?((count==baudratedivisor-1'b1)?(1'b1):(1'b0)):(1'b0)):(flag_high);
end

endmodule

