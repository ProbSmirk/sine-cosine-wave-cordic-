module dacspi(input CLK, input RST, output reg D1, output reg D2, output reg CLK_OUT, output reg nSYNC, input [11:0] DATA1, input [11:0] DATA2,input START, output reg DONE);

    // SPI State Machine Variables
    reg [1:0] current_state=2'b00;
    reg [4:0] bit_counter=0;
    reg [15:0] shift_reg1=0;
    reg [15:0] shift_reg2=0;
    reg START_prev=1'b0;

    localparam IDLE=2'b00;
    localparam SYNC=2'b01;
    localparam SHIFT=2'b10;
    localparam FINISH=2'b11;

    always @(posedge CLK or posedge RST) 
    begin
        if (RST) 
        begin
            current_state<=IDLE;
            D1<=1'b0;
            D2<=1'b0;
            CLK_OUT<=1'b0;
            nSYNC<=1'b1;
            DONE<=1'b0;
            bit_counter<=0;
            shift_reg1<=0;
            shift_reg2<=0;
            START_prev<=1'b0;
        end 
        else 
        begin
            //Edge detector to prevent multi-triggering from wide START pulses
            START_prev<=START; 
            case (current_state)
            IDLE: 
            begin
            nSYNC<=1'b1;
            CLK_OUT<=1'b0;
            DONE<=1'b0;    
            //Trigger only on the rising edge of START
            if (START == 1'b1 && START_prev == 1'b0) 
            begin
            //DAC121S101 requires 16 bits: XX+00(normal mode of operation)+SPI 12 bits 
            shift_reg1<={4'b0000, DATA1};
            shift_reg2<= {4'b0000, DATA2};
            current_state<=SYNC;
            end
            end
            SYNC: 
            begin
            nSYNC<=1'b0; //Pull Chip Select low to wake up the DAC
            bit_counter<=5'd16;
            current_state<=SHIFT;
            end
            SHIFT: 
            begin
            CLK_OUT<=~CLK_OUT; //Toggle the SPI clock
            // Present data on the rising edge of CLK_OUT so it is stable for the DAC's falling edge read
            if (CLK_OUT==1'b0) 
            begin 
            D1<=shift_reg1[15];
            D2<=shift_reg2[15];
            shift_reg1<={shift_reg1[14:0], 1'b0};
            shift_reg2<={shift_reg2[14:0], 1'b0};
            end
            else 
            begin
            bit_counter<=bit_counter-1;
            if (bit_counter==1) 
            begin
            current_state<=FINISH;
            end
            end
            end
            FINISH: 
            begin
            CLK_OUT<=1'b0;
            nSYNC<=1'b1; 
            DONE<=1'b1;
            current_state<=IDLE;
            end
            default: current_state<=IDLE;
            endcase
        end
    end
endmodule