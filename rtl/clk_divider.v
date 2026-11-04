module clk_divider #(
    parameter INPUT_FREQ_MHZ = 100,  // Base clock frequency in MHz
    parameter TARGET_FREQ_MHZ = 10   // Desired output frequency in MHz
)(
    input wire clk_in,
    input wire rst,
    output reg clk_out
);

    // The synthesizer calculates these constants at compile-time.
    // DIV_FACTOR is total cycles per output period.
    // TOGGLE_LIMIT is half that, to maintain a 50% duty cycle.
    localparam integer DIV_FACTOR = INPUT_FREQ_MHZ / TARGET_FREQ_MHZ;
    localparam integer TOGGLE_LIMIT = DIV_FACTOR / 2;

    // Log2 calculation could optimize this width, but 32-bit is safe and 
    // synthesis tools will automatically optimize away unused bits.
    reg [31:0] counter;

    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            // Toggle the clock output when the counter reaches the limit
            if (counter >= TOGGLE_LIMIT - 1) begin
                counter <= 0;
                clk_out <= ~clk_out;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule