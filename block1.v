`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.10.2026 13:41:15
// Design Name: 
// Module Name: block1
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


module Block1(
	input pclk,preset,spiswai,cpol,cpha,ss,
	input [1:0] spi_mode,
        input [2:0] sppr,spr,
        output reg sclk,mosi_send_pos,mosi_send_neg,miso_receive_pos,miso_receive_neg,
	output  [11:0] baudrate_divisor);
	wire pre_sclk;
	reg [11:0] count;
	assign baudrate_divisor=(sppr+1'b1)*2'd2**(spr+1'b1);
	assign pre_sclk=(cpol)?1'b1:1'b0;
	always@(posedge pclk,negedge preset)
	begin
		if(!preset)
		begin
			count<=12'd0;
			sclk<=pre_sclk;
		end
		else if(!ss&&!spiswai&&(spi_mode==2'b00||spi_mode==2'b01))
		begin
			if(count==baudrate_divisor/2-1'b1)
			begin
				sclk<=~sclk;
				count<=12'b0;
			end
			else
				count<=count+1'b1;
		end
		else 
		begin
			sclk<=pre_sclk;
			count<=12'b0;
		end
	end
	always@(posedge pclk,negedge preset)
	begin
		if(!preset)
		begin
			miso_receive_neg<=1'b0;
			miso_receive_pos<=1'b0;
		end
		else if((!cpol&&cpha)||(cpol&&!cpha))
			begin
				if(sclk)
				begin
					if(count==baudrate_divisor/2-1'b1)
                                        begin
						miso_receive_neg<=1'b1;
                                                 miso_receive_pos<=1'b0;

                                                
                                        end

					else
                                        begin
						miso_receive_neg<=1'b0;
 			                        miso_receive_pos<=1'b0;
                                        end
				end

				else
                                  begin
					miso_receive_neg<=1'b0;
                                        miso_receive_pos<=1'b0;
                                  end
			end
			else if((cpol&&cpha)||(!cpol&&!cpha))
			begin
				if(!sclk)
				begin
					if(count==baudrate_divisor/2-1'b1)
                                         begin
						miso_receive_pos<=1'b1;
                                                miso_receive_neg<=1'b0;
                                          end
					else
                                        begin 
						miso_receive_pos<=1'b0;
                                                miso_receive_neg<=1'b0;
                                        end
				end
				else
                                begin
					miso_receive_pos<=1'b0;
                                        miso_receive_neg<=1'b0;
                                end
			end
			else
					miso_receive_pos<=miso_receive_pos;


		end
		
	always@(posedge pclk,negedge preset)
	begin
		if(!preset)
		begin
			mosi_send_neg<=1'b0;
			mosi_send_pos<=1'b0;
		end
		else if((!cpol&&cpha)||(cpol&&!cpha))
			begin
				if(sclk)
				begin
					if(count==baudrate_divisor/2-2'b10)
                                            begin
						mosi_send_neg<=1'b1;
                                                mosi_send_pos<=1'b0;
                                            end
					else
                                        begin
						mosi_send_neg<=1'b0;
                                               mosi_send_pos<=1'b0;
				end
                                 end
				else
                                begin
					mosi_send_neg<=1'b0;
                                        mosi_send_pos<=1'b0;
                                end
			end
			else if((cpol&&cpha)||(!cpol&&!cpha))
			begin
				if(!sclk)
				begin
					if(count==baudrate_divisor/2-2'b10)
                                              begin
						mosi_send_pos<=1'b1;
                                                mosi_send_neg<=1'b0;
                                               end
					else
                                       begin
						mosi_send_pos<=1'b0;
                                                mosi_send_neg<=1'b0;
                                        end
				end
				else
                                begin
					mosi_send_pos<=1'b0;
                                        mosi_send_neg<=1'b0;
                                end
			end
			else 
					mosi_send_pos<=mosi_send_pos;

          	
	end
	endmodule








	


