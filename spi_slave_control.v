module spi_slave_control_select (
    input  PCLK,
    input  PRESETn,
    input  mstr,
    input  spiswai,
    input  [1:0]  spi_mode,
    input  send_data,
    input  [11:0] BaudRateDivisor,

    output reg receive_data,
    output reg ss,
    output tip
);


reg rcv;
wire w1;
reg [15:0] count;
reg [15:0] target;

always @(*) begin
    target = BaudRateDivisor << 4;
end


// receive block 
always@(posedge PCLK or negedge PRESETn) begin 
if(!PRESETn) begin 
receive_data <= 1'b0;
end 

else begin 
receive_data <= rcv;
end
end

assign w1 = ( mstr & (spi_mode == 2'b00 || spi_mode == 2'b01) & (!spiswai) ) ; 

//rcv
always@(posedge PCLK or negedge PRESETn) begin 
if(!PRESETn) 
rcv <= 1'b0;

else begin
	if(w1)
		rcv <= send_data? (1'b0):((count <= target-1'b1)?((count==target-1'b1)?(1'b1):(rcv)):(1'b0));
	else 
		rcv<= 1'b0;

end 


end 


//slave select logic
always@(posedge PCLK or negedge PRESETn) begin 
if(!PRESETn) 
ss <= 1'b1;

else begin 
	if(w1) 
		ss<= send_data ? (1'b0):((count <= target-1'b1)?(1'b0):(1'b1));
	else
		ss<=1'b0;
	end 
end

//tip logic
assign tip = ~ss;

//count 
always@(posedge PCLK or negedge PRESETn) begin 
if(!PRESETn) 
count <= 16'hffff;


else begin 
	if(w1) 
		count <= send_data?(16'b0):((count <= target-1'b1)?(count+1'b1):(16'hffff));
	else 
		count <= 16'hffff;
	end

end 


endmodule 
