'timescale 1ns/1ps
module phaseaccumulator (input wire clk, input wire reset, input wire [31:0] phase_inc, output wire [11:0] angle);
reg [31:0] phase_acc;
always @(posedge clk)
begin 
    if(reset)
    phase_acc<=0;
    else 
    phase_acc<=phase_acc+phase_inc;
end
assign angle=phase_acc[31:20];
endmodule 