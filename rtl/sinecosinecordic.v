`timescale 1 ns/1 ps
module sinecosinecordic(input wire clock, input wire signed [31:0] angle, input wire signed [bitwidth-1:0] Xin, input wire signed [bitwidth-1:0] Yin, input wire select, output wire signed [bitwidth-1:0] wave_out);
   parameter bitwidth = 16; //bitwidth of X and Y 
   input  wire signed [bitwidth-1:0] Xin;
   input  wire signed [bitwidth-1:0] Yin;
   output wire signed [bitwidth-1:0] wave_out;
   wire signed [31:0] atan_table [0:30];
   
   // The upper 2 bits therefore tell us which quadrant we are in.
   //upper 2 bits for quadrant 00: 0-pi/2 01: pi/2-pi 10: pi-3pi/2 11: 3pi/2 to 2pi 
   assign atan_table[00] = 32'b00100000000000000000000000000000; //45.000 degrees-atan(2^0)
   assign atan_table[01] = 32'b00010010111001000000010100011101; //26.565 degrees->atan(2^-1)
   assign atan_table[02] = 32'b00001001111110110011100001011011; //etc etc 
   assign atan_table[03] = 32'b00000101000100010001000111010100; 
   assign atan_table[04] = 32'b00000010100010110000110101000011;
   assign atan_table[05] = 32'b00000001010001011101011111100001;
   assign atan_table[06] = 32'b00000000101000101111011000011110;
   assign atan_table[07] = 32'b00000000010100010111110001010101;
   assign atan_table[08] = 32'b00000000001010001011111001010011;
   assign atan_table[09] = 32'b00000000000101000101111100101110;
   assign atan_table[10] = 32'b00000000000010100010111110011000;
   assign atan_table[11] = 32'b00000000000001010001011111001100;
   assign atan_table[12] = 32'b00000000000000101000101111100110;
   assign atan_table[13] = 32'b00000000000000010100010111110011;
   assign atan_table[14] = 32'b00000000000000001010001011111001;
   assign atan_table[15] = 32'b00000000000000000101000101111101;
   assign atan_table[16] = 32'b00000000000000000010100010111110;
   assign atan_table[17] = 32'b00000000000000000001010001011111;
   assign atan_table[18] = 32'b00000000000000000000101000101111;
   assign atan_table[19] = 32'b00000000000000000000010100011000;
   assign atan_table[20] = 32'b00000000000000000000001010001100;
   assign atan_table[21] = 32'b00000000000000000000000101000110;
   assign atan_table[22] = 32'b00000000000000000000000010100011;
   assign atan_table[23] = 32'b00000000000000000000000001010001;
   assign atan_table[24] = 32'b00000000000000000000000000101000;
   assign atan_table[25] = 32'b00000000000000000000000000010100;
   assign atan_table[26] = 32'b00000000000000000000000000001010;
   assign atan_table[27] = 32'b00000000000000000000000000000101;
   assign atan_table[28] = 32'b00000000000000000000000000000010;
   assign atan_table[29] = 32'b00000000000000000000000000000001; 
   assign atan_table[30] = 32'b00000000000000000000000000000000;
   

   reg signed [bitwidth :0] X [0:bitwidth-1]; //one bit more than xin yin 
   reg signed [bitwidth :0] Y [0:bitwidth-1];
   reg signed [31:0] Z [0:bitwidth-1]; //standard dac converters have 16 bit inputs but this is internal also to increase precision
   
  
   wire [1:0] quadrant;
   assign quadrant=angle[31:30];
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
            Z[0]<= {2'b00,angle[29:0]}; //subtract pi/2 
         end
         
         2'b10:
         begin
            X[0]<=Yin; //x and y vector rotated to the left by 90 degrees
            Y[0]<=-Xin;
            Z[0]<={2'b11,angle[29:0]}; //add pi/2 
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
      assign Z_sign=Z[i][31];
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