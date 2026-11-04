`timescale 1ns / 1ps

module tb_top_module();
    reg clk;
    reg rst;
    reg JD1_N;
    reg JD1_P;
    reg sw0;

    wire nSYNC;
    wire D1;
    wire D2;
    wire clk_spi;

    // Instantiate the top module
    top_module uut (
        .clk(clk),
        .rst(rst),
        .JD1_N(JD1_N),
        .JD1_P(JD1_P),
        .sw0(sw0),
        .nSYNC(nSYNC),
        .D1(D1),
        .D2(D2),
        .clk_spi(clk_spi)
    );
// Tap into internal top_module wires using the 'uut' instance name
wire [31:0] probe_phase_inc = uut.my_phase.phase_inc;
    wire [11:0] probe_target_angle = uut.target_angle;
    wire [11:0] probe_out_analog = uut.out_analog;
    // 100 MHz system clock generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 100 kHz Probe (Triggers every 10,000 ns)
    always begin
        #10000;
        if (!rst) begin
            $display("Time: %0t ns | Angle: %d | CORDIC Out: %d", 
                     $time, uut.target_angle, uut.out_analog);
        end
    end

    // Simulation Sequence
    initial begin
        // Initialize inputs
        rst = 1;
        JD1_N = 0;
        JD1_P = 0;
        sw0 = 0;

        // Hold reset long enough for the 10 MHz clock to tick several times
        #20000; 
        rst = 0;

        // Run for 5 milliseconds
        #5000000; 
        
        $display("Simulation complete.");
        $stop;
    end
endmodule