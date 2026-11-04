`timescale 1ns / 1ps

module top_module(
    input clk,          // 100 MHz board clock
    input rst,          // BTNC
    input JD1_N,        // Rotary Encoder A
    input JD1_P,        // Rotary Encoder B
    input sw0,          // SW0 (Used for CORDIC wave select)
    output nSYNC,       // DAC nSYNC (JA1)
    output D1,          // DAC D1 (JA2)
    output D2,          // DAC D2 (JA3)
    output clk_spi      // DAC SPI Clock (JA4)
);

    wire clk_10mhz;
    
    // 1. Slow System Clock to 10 MHz (Creates a 5 MHz SPI Clock)
    clk_divider #(
        .INPUT_FREQ_MHZ(100),
        .TARGET_FREQ_MHZ(10)
    ) div_inst (
        .clk_in(clk),
        .rst(rst),
        .clk_out(clk_10mhz)
    );

    // 2. Synchronous 200 kHz START Pulse Generator
    // 10,000,000 Hz / 200,000 Hz = 50. Count 0 to 49.
    reg [5:0] start_count = 0;
    reg start_tick = 0;
    
    always @(posedge clk_10mhz) begin
        if (rst) begin
            start_count <= 0;
            start_tick <= 0;
        end else begin
            if (start_count == 49) begin
                start_count <= 0;
                start_tick <= 1'b1; // Pulses high for exactly one 10 MHz cycle
            end else begin
                start_count <= start_count + 1;
                start_tick <= 1'b0;
            end
        end
    end
    wire [31:0] target_freq;
    wire [31:0]  phase_inc;
    wire [11:0] target_angle;
    wire [11:0] out_analog;
    wire spi_done;

    frequency_controller freq_control(
        .clk(clk_10mhz),
        .a(JD1_P), 
        .b(JD1_N), 
        .reset(rst),
        .target_freq(target_freq),
        .phase_inc(phase_inc)
    );

    phaseaccumulator my_phase(
        .clk(clk_10mhz),
        .reset(rst),
        .phase_inc(phase_inc),
        .angle(target_angle)
    );

    sinecosinecordic my_cordic(
        .clock(clk_10mhz),
        .angle(target_angle),
        .Xin(12'd1243),
        .Yin(12'd0),
        .select(sw0), 
        .wave_out(out_analog)
    );

    // 3. DC Offset Fix: Flip MSB to convert Signed to Unsigned
        wire [11:0] unsigned_dac_data = {~out_analog[11], out_analog[10:0]};

    
    
    
    DA2RefComp DAC_Controller(
        .CLK(clk_10mhz),
        .RST(rst),
        .D1(D1),
        .D2(D2),
        .CLK_OUT(clk_spi),
        .nSYNC(nSYNC),
        .DATA1(unsigned_dac_data), // Connect the fixed unsigned data here
        .DATA2(out_analog),
        .START(start_tick),        // Driven by the 200 kHz synchronous pulse
        .DONE(spi_done)
    );

endmodule