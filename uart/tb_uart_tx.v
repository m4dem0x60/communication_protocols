`timescale 1ns / 1ps

module tb_uart_tx();

reg clk = 1'b0, rstn, enable_i;
reg [7:0] datain_i;
wire tx_o, txdone_o;

uart_tx #(100_000_000, 115_200) UUT(clk, rstn, enable_i, datain_i, tx_o, txdone_o);

always #5 clk <= ~clk;  //creat clock in 100 MHz (period: 10ns)

initial begin
    rstn = 1'b0; #20; rstn = 1'b1;
    enable_i = 1'b0;  #10
    datain_i = 8'h55; enable_i = 1'b1; #10; enable_i = 1'b0; //send 55 in hex
    @(posedge txdone_o);    #10_000;
    
    datain_i <= 8'hab; enable_i <= 1'b1; #10; enable_i = 1'b0; //send ab in hex
    @(posedge txdone_o);   #10_000;

    $finish;

end

endmodule
