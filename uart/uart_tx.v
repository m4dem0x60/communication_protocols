`timescale 1ns / 1ps

module uart_tx
#(  parameter p_clockFreq = 100_000_000,        // p_ prefix -> parameter
    parameter p_baudRate = 115_200    )         // stop bit not configurable, default 1  
    (
    input       clk,
    input       rstn,     //active low reset
    input       enable_i, // _i suffix -> input
    input [7:0] datain_i,   
    output  reg tx_o,   
    output  reg txdone_o  // _o suffix -> output
    );

localparam S_IDLE     = 1'b1;       // S_ prefix -> state
localparam S_TRANSMIT = 1'b0;

localparam  c_periodTimer = p_clockFreq/p_baudRate;    // c_ prefix -> constant

reg [8:0]   buffer = 0; // b_ prefix -> buffer, {data_8bit,stopbit_1bit}
reg         state = S_IDLE;
reg [3:0]   count_bit = 0;
reg [15:0]  timer_periodTimer = 0;  //count for baudrate period

always @(posedge clk) begin
    if (!rstn) begin
        // outputs
        tx_o     <= 1'b1;
        txdone_o <= 1'b0;
        // regs
        state             <= S_IDLE;
        buffer            <= {1'b1, 8'd0};
        count_bit         <= 4'd0;
        timer_periodTimer <= 16'd0;
    end
    else begin   
        case (state)
        S_IDLE: 
        begin
            tx_o     <= 1'b1;  // output
            txdone_o <= 1'b0;  // output
            if (enable_i) begin
                state              <= S_TRANSMIT; 
                buffer             <= {1'b1, datain_i};
                count_bit          <= 4'd0;
                timer_periodTimer  <= 16'd0;
                tx_o               <= 1'b0; // start sending start bit 0
            end
            else
                state <= S_IDLE;
        end
        S_TRANSMIT: //firts send start bit 0 then starts sends data
        begin
            if (timer_periodTimer == (c_periodTimer-1)) // -1 because starting timer from zero not one
            begin
                timer_periodTimer <= 16'd0;
                if (count_bit == 9)
                begin
                    txdone_o <= 1'b1;      
                    state    <= S_IDLE;  
                end
                else 
                begin
                    tx_o      <= buffer[count_bit]; // send data from lsb to msb bit, last send stop bit
                    count_bit <= count_bit + 1;
                end
            end
            else
                timer_periodTimer <= timer_periodTimer +1;
        end

        default: 
        begin
            state <= S_IDLE;
            tx_o  <= 1'b1;
        end
        endcase
    end
end

endmodule
