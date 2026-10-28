`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.10.2026 14:06:58
// Design Name: 
// Module Name: Block2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Block2
(
    input              PCLK,
    input              PRESET_n,
    input              mstr_i,
    input              spiswai_i,
    input      [1:0]   spi_mode_i,
    input              send_data_i,
    input      [11:0]  BaudRateDivisor_i,

    output reg         ss_o,
    output reg         receive_data_o,
    output             tip_o
);

parameter mode_run  = 2'b00;
parameter mode_wait = 2'b01;
parameter mode_stop = 2'b10;

reg  [15:0] count_s;
reg         rcv_s;

wire [15:0] target_s;

assign target_s = BaudRateDivisor_i * 16'd8;

assign tip_o = ~ss_o;

// Block-1 : SS Generation

always @(posedge PCLK or negedge PRESET_n)
begin
    if(!PRESET_n)
        ss_o <= 1'b1;

    else if(mstr_i && ((spi_mode_i==mode_run)||(spi_mode_i==mode_wait)) && !spiswai_i)
    begin
        if(send_data_i)
            ss_o <= 1'b0;

        else if(count_s <= (target_s-1))//-1
            ss_o <= 1'b0;

        else
            ss_o <= 1'b1;
    end

    else
        ss_o <= 1'b1;
end

// Block-2 : Counter

always @(posedge PCLK or negedge PRESET_n)
begin
    if(!PRESET_n)
        count_s <= 16'hFFFF;

    else if(mstr_i && ((spi_mode_i==mode_run)||(spi_mode_i==mode_wait)) && !spiswai_i)
    begin
        if(send_data_i)
            count_s <= 16'd0;

        else if(count_s <= (target_s-1))//-1
            count_s <= count_s + 16'd1;

        else
            count_s <= 16'hFFFF;
    end

    else
        count_s <= 16'hFFFF;
end

// Block-3 : RCV Generation

always @(posedge PCLK or negedge PRESET_n)
begin
    if(!PRESET_n)
        rcv_s <= 1'b0;

    else if(mstr_i && ((spi_mode_i==mode_run)||(spi_mode_i==mode_wait)) && !spiswai_i)
    begin
        if(send_data_i)
            rcv_s <= 1'b0;

        else if(count_s == (target_s-1))
            rcv_s <= 1'b1;

        else
            rcv_s <= 1'b0;
    end

    else
        rcv_s <= 1'b0;
end

// Block-4 : Receive Data Generation

always @(posedge PCLK or negedge PRESET_n)
begin
    if(!PRESET_n)
        receive_data_o <= 1'b0;

    else
        receive_data_o <= rcv_s;
end

endmodule
