`timescale 1 ns/1 ps
module sinecosinecordic(input wire clock, input wire signed [11:0] angle, input wire signed [bitwidth-1:0] Xin, input wire signed [bitwidth-1:0] Yin, input wire select, output wire signed [bitwidth-1:0] wave_out);
   parameter bitwidth = 12; //bitwidth of X and Y 
   input  wire signed [bitwidth-1:0] Xin;
   input  wire signed [bitwidth-1:0] Yin;
   output wire signed [bitwidth-1:0] wave_out;
   // The upper 2 bits therefore tell us which quadrant we are in.
   //upper 2 bits for quadrant 00: 0-pi/2 01: pi/2-pi 10: pi-3pi/2 11: 3pi/2 to 2pi 
   wire signed [11:0] atan_table [0:11];
// 12-bit angles: 360 degrees = 4096, 90 degrees = 1024
assign atan_table[0]  = 12'b0010_0000_0000; // 45.000 degrees -> 512
assign atan_table[1]  = 12'b0001_0010_1110; // 26.565 degrees -> 302
assign atan_table[2]  = 12'b0000_1010_0000; // 14.036 degrees -> 160
assign atan_table[3]  = 12'b0000_0101_0001; //  7.125 degrees -> 81
assign atan_table[4]  = 12'b0000_0010_1001; //  3.576 degrees -> 41
assign atan_table[5]  = 12'b0000_0001_0100; //  1.790 degrees -> 20
assign atan_table[6]  = 12'b0000_0000_1010; //  0.895 degrees -> 10
assign atan_table[7]  = 12'b0000_0000_0101; //  0.448 degrees -> 5
assign atan_table[8]  = 12'b0000_0000_0011; //  0.224 degrees -> 3
assign atan_table[9]  = 12'b0000_0000_0001; //  0.112 degrees -> 1
assign atan_table[10] = 12'b0000_0000_0001; //  0.056 degrees -> 1
assign atan_table[11] = 12'b0000_0000_0000; //  0.028 degrees -> 0

   reg signed [bitwidth :0] X [0:bitwidth-1]; //one bit more than xin yin 
   reg signed [bitwidth :0] Y [0:bitwidth-1];
   reg signed [11:0] Z [0:bitwidth-1]; //standard dac converters have 16 bit inputs but this is internal also to increase precision
   
  
   wire [1:0] quadrant;
   assign quadrant=angle[11:10];
   //rotate angles if not in -pi/2 to pi/2
   always @(posedge clock)
   begin 
      case (quadrant)
         2'b00, 2'b11:
         begin
            X[0]<=Xin;
            Y[0]<=Yin;
            Z[0]<=angle;
         end
         2'b01:
         begin
            X[0]<=-Yin;//x and y vector rotated to right by 90 degrees
            Y[0]<=Xin;
            Z[0]<= {2'b00,angle[9:0]}; //subtract pi/2 
         end
         
         2'b10:
         begin
            X[0]<=Yin; //x and y vector rotated to the left by 90 degrees
            Y[0]<=-Xin;
            Z[0]<={2'b11,angle[9:0]}; //add pi/2 
         end
         
      endcase
   end
   
   genvar i;
   generate
   for (i=0; i <(bitwidth-1); i=i+1)
   begin: XYZ
      wire Z_sign;
      wire signed [bitwidth:0] X_shr, Y_shr; 
      assign X_shr=X[i]>>>i; //arithmetic shift right-pad with sign 
      assign Y_shr=Y[i]>>>i;
      assign Z_sign=Z[i][11];
      always @(posedge clock)
      begin
         X[i+1]<=Z_sign ? X[i]+Y_shr: X[i]-Y_shr;
         Y[i+1]<=Z_sign ? Y[i]-X_shr: Y[i]+X_shr;
         Z[i+1]<=Z_sign ? Z[i]+atan_table[i]:Z[i]-atan_table[i];
      end
   end
   endgenerate
assign wave_out=select ? Y[bitwidth-1][bitwidth-1:0] : X[bitwidth-1][bitwidth-1:0];
endmodule