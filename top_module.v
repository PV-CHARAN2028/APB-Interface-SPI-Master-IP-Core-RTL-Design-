`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.10.2026 14:12:14
// Design Name: 
// Module Name: top_module
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


module topBlock(pclk,presetn,paddr_i,pwrite_i,psel_i,penable_i,pwdata_i,miso_i,ss_o,sclk_o,spi_interrupt_request_o,mosi_o,prdata_o,pready_o,pslverr_o);
input pclk,presetn,pwrite_i,psel_i,penable_i,miso_i;
input [2:0]paddr_i;
input [7:0]pwdata_i;
output ss_o,sclk_o,spi_interrupt_request_o,mosi_o,pready_o,pslverr_o;
output [7:0]prdata_o;

wire spiswai_i,cpol_i,cpha_i,mstr_i,receive_data_i,tip_o,send_data_i,lsbfe_i;
wire [1:0]spi_mode_i;
wire [2:0] sppr_i,spr_i;

wire miso_receive_sclk_o,miso_receive_sclk0_o,mosi_send_sclk_o,mosi_send_sclk0_o;
wire [11:0] baud_rate_divisor_o;
wire [7:0] data_mosi_i,data_miso_o;


//serial clock instantiation

Block1 SCG(.pclk(pclk),.preset(presetn),.sclk(sclk_o),.spiswai(spiswai_i),.cpol(cpol_i),.cpha(cpha_i),.ss(ss_o),.spi_mode(spi_mode_i),.sppr(sppr_i),.spr(spr_i),.miso_receive_pos(miso_receive_sclk_o),.miso_receive_neg(miso_receive_sclk0_o),.mosi_send_pos(mosi_send_sclk_o),.mosi_send_neg(mosi_send_sclk0_o),.baudrate_divisor(baud_rate_divisor_o));

//slave select instantiation

Block2 SLAVE(.PCLK(pclk),.PRESET_n(presetn),.mstr_i(mstr_i),.spiswai_i(spiswai_i),.spi_mode_i(spi_mode_i),.send_data_i(send_data_i),.BaudRateDivisor_i(baud_rate_divisor_o),.receive_data_o(receive_data_i),.ss_o(ss_o),.tip_o(tip_o));

//shift_register instatntion


Block3 SHIFT_REG(.pclk(pclk),.presetn(presetn),.ss_i(ss_o),.send_data_i(send_data_i),.lsbfe_i(lsbfe_i),.cpha_i(cpha_i),.cpol_i(cpol_i),.miso_receive_sclk_i(miso_receive_sclk_o),.miso_receive_sclk0_i(miso_receive_sclk0_o),.mosi_send_sclk_i(mosi_send_sclk_o),.mosi_send_sclk0_i(mosi_send_sclk0_o),.data_mosi_i(data_mosi_i),.miso_i(miso_i),.receive_data_i(receive_data_i),.mosi_o(mosi_o),.data_miso_o(data_miso_o));


//APB slave interface instantiation


Block4 APB_INTERFACE(.pclk(pclk),.presetn(presetn),.paddr_i(paddr_i),.pwrite_i(pwrite_i),.psel_i(psel_i),.penable_i(penable_i),.pwdata_i(pwdata_i),.ss_i(ss_o),.miso_data_i(data_miso_o),.receive_data_i(receive_data_i),.tip_i(tip_o),.prdata_o(prdata_o),.mstr_o(mstr_i),.cpol_o(cpol_i),.cpha_o(cpha_i),.lsbfe_o(lsbfe_i),.spiswai_o(spiswai_i),.sppr_o(sppr_i),.spr_o(spr_i),.spi_interrupt_request_o(spi_interrupt_request_o),.pready_o(pready_o),.pslverr_o(pslverr_o),.send_data_o(send_data_i),.mosi_data_o(data_mosi_i),.spi_mode_o(spi_mode_i));

endmodule



