`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.10.2026 14:09:46
// Design Name: 
// Module Name: Block4
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

module Block4 (pclk,presetn,paddr_i,pwrite_i,psel_i,penable_i,pwdata_i,ss_i,miso_data_i,receive_data_i,tip_i,prdata_o,mstr_o,cpol_o,cpha_o,lsbfe_o,spiswai_o,sppr_o,spr_o,spi_interrupt_request_o,pready_o,pslverr_o,send_data_o,mosi_data_o,spi_mode_o
);

input pclk, presetn, pwrite_i, psel_i, penable_i, ss_i, receive_data_i, tip_i;
input [2:0] paddr_i;
input [7:0] pwdata_i, miso_data_i;

output mstr_o, cpol_o, cpha_o, lsbfe_o, spiswai_o, pready_o, pslverr_o;
output reg send_data_o, spi_interrupt_request_o;
output [1:0] spi_mode_o;
output reg [7:0] prdata_o, mosi_data_o;
output [2:0] sppr_o, spr_o;

wire wr_enb, rd_enb;

reg [7:0] spi_cr1, spi_cr2, spi_br, spi_sr, spi_dr;

// Declared as local constants to prevent the tool from confusing them with module ports
localparam [7:0] cr2_mask = 8'b00011011; 
localparam [7:0] br_mask  = 8'b01110111; 

parameter spi_run  = 2'b00; 
parameter spi_wait = 2'b01;
parameter spi_stop = 2'b11;

reg [1:0] SPI_state, SPI_ns;

wire spif, sptef, spie, spe, sptie, modfen, ssoe, modf;

// FSM part
parameter idle   = 2'b00;
parameter setup  = 2'b01;
parameter enable = 2'b10; 

reg [1:0] state, ns1;

always @(posedge pclk or negedge presetn) begin
    if (!presetn)
        state <= idle;
    else
        state <= ns1;
end

// Added presetn to the sensitivity list to prevent simulation mismatches
always @(state, psel_i, penable_i, presetn) begin
    case (state)
        idle: begin
            if (!presetn)
                ns1 = idle;
            else if ((psel_i) && (!penable_i))
                ns1 = setup;
            else
                ns1 = idle;
        end

        setup: begin
            if ((psel_i == 1'b1) && (penable_i == 1'b1))
                ns1 = enable;
            else if (!psel_i)
                ns1 = idle;
            else
                ns1 = setup;
        end

        enable: begin
            if (psel_i)
                ns1 = setup;
            else
                ns1 = idle;
        end
        default: ns1 = idle;
    endcase
end

assign pready_o  = (state == enable) ? 1'b1 : 1'b0;
assign pslverr_o = (state == enable) ? ~tip_i : 1'b0;
assign wr_enb    = (pwrite_i && (state == enable)) ? 1'b1 : 1'b0;
assign rd_enb    = (!pwrite_i && (state == enable)) ? 1'b1 : 1'b0;

// CR1 Register Management Logic
always @(posedge pclk or negedge presetn) begin
    if (!presetn)
        spi_cr1 <= 8'h04;
    else begin
        if (wr_enb && (paddr_i == 3'b000))
            spi_cr1 <= pwdata_i;
        // Retain value when not writing so settings don't wipe out dynamically
    end
end

// CR2 Register Management Logic
always @(posedge pclk or negedge presetn) begin
    if (!presetn)
        spi_cr2 <= 8'h0;
    else begin
        if (wr_enb && (paddr_i == 3'b001))
            spi_cr2 <= pwdata_i & cr2_mask;
    end
end

// BR Register Management Logic
always @(posedge pclk or negedge presetn) begin
    if (!presetn)
        spi_br <= 8'h0;
    else begin
        if (wr_enb && (paddr_i == 3'b010))
            spi_br <= pwdata_i & br_mask;
    end
end

// Configuring Data Register
always @(posedge pclk or negedge presetn) begin
    if (!presetn)
        spi_dr <= 8'b0;
    else begin
        if (wr_enb && (paddr_i == 3'b101)) begin
            spi_dr <= pwdata_i;
        end
        else begin
            if ((spi_dr == pwdata_i) && (spi_dr != miso_data_i) && (spi_mode_o == spi_run || spi_mode_o == spi_wait))
                spi_dr <= 8'b0;
            else if ((spi_mode_o == spi_run || spi_mode_o == spi_wait) && (receive_data_i == 1'b1))
                spi_dr <= miso_data_i;
        end
    end
end

// Status register
always @(*) begin
    if (!presetn)
        spi_sr = 8'b00100000;
    else
        spi_sr = {spif, 1'b0, sptef, modf, 4'b0};
end

// FSM for SPI Modes
always @(posedge pclk or negedge presetn) begin
    if (!presetn)
        SPI_state <= spi_run;
    else
        SPI_state <= SPI_ns;
end

always @(*) begin
    // Fixed case verification expression to match control bits correctly against conditions
    case (SPI_state)
        spi_run: begin
            if (!spe)
                SPI_ns = spi_wait;
            else
                SPI_ns = spi_run;
        end
        spi_wait: begin
            if (!spe)
                SPI_ns = spi_wait;
            else if (spe)
                SPI_ns = spi_run;
            else if (spiswai_o)
                SPI_ns = spi_stop;
            else
                SPI_ns = spi_run;
        end
        spi_stop: begin
            if (!spiswai_o)
                SPI_ns = spi_wait;
            else if (spe)
                SPI_ns = spi_run;
            else
                SPI_ns = spi_stop;
        end
        default: SPI_ns = spi_run;
    endcase
end

assign spi_mode_o = (SPI_state == spi_run) ? 2'b00 : (SPI_state == spi_wait) ? 2'b01 : 2'b10;

// Send data flag assignment
always @(posedge pclk or negedge presetn) begin
    if (!presetn)
        send_data_o <= 1'b0;
    else begin
        if (!wr_enb) begin
            if ((spi_dr == pwdata_i) && (spi_dr !== miso_data_i) && (spi_mode_o == spi_run || spi_mode_o == spi_wait))
                send_data_o <= 1'b1;
            else
                send_data_o <= 1'b0;
        end
    end
end

// MOSI Data Buffer
always @(posedge pclk or negedge presetn) begin
    if (!presetn)
        mosi_data_o <= 8'b0;
    else begin
        if ((spi_dr == pwdata_i) && (spi_dr != miso_data_i) && (spi_mode_o == spi_run || spi_mode_o == spi_wait))
            mosi_data_o <= spi_dr;
    end
end

// Fault Identification
assign modf = ((!ss_i) && (mstr_o) && (modfen) && (!ssoe)) ? 1'b1 : 1'b0;

// Read Data Interface MUX
always @(*) begin
    if (rd_enb) begin
        case (paddr_i)
 
            3'b000:  prdata_o = spi_cr1;
            3'b001:  prdata_o = spi_cr2;
            3'b010:  prdata_o = spi_br;
            3'b011:  prdata_o = spi_sr;
            3'b100:  prdata_o = 8'b0;
            3'b101:  prdata_o = spi_dr;
            3'b110:  prdata_o = 8'b0;
            3'b111:  prdata_o = 8'b0;
            default: prdata_o = 8'b0;
        endcase
    end
    else
        prdata_o = 8'b0;
end

// Interrupt Generator logic
always @(*) begin
    if ((!spie) && (!sptie))
        spi_interrupt_request_o = 1'b0;
    else begin
        if ((!sptie) && (spie))
            spi_interrupt_request_o = (spif || modf);
        else begin
            if ((!spie) && (sptie))
                spi_interrupt_request_o = sptef;
            else
                spi_interrupt_request_o = (spif || modf || sptef);
        end
    end
end

assign mstr_o    = spi_cr1[4];
assign cpol_o    = spi_cr1[3];
assign cpha_o    = spi_cr1[2];
assign lsbfe_o   = spi_cr1[0];
assign spiswai_o = spi_cr2[1];
assign sppr_o    = spi_br[6:4];
assign spr_o     = spi_br[2:0];
assign spif      = (spi_dr != 8'b0) ? 1'b1 : 1'b0;
assign sptef     = (spi_dr == 8'b0) ? 1'b1 : 1'b0;
assign spie      = spi_cr1[7];
assign spe       = spi_sr[6];
assign sptie     = spi_cr1[5];
assign modfen    = spi_cr2[4];
assign ssoe      = spi_cr1[1];

endmodule
