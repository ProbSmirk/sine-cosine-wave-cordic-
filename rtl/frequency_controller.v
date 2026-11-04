`timescale 1ns / 1ps
module frequency_controller(input wire clk, input wire a, input wire b, input wire reset, output reg [31:0] target_freq, output wire [31:0] phase_inc);

    localparam IDLE=4'd0, R1=4'd1, R2=4'd2, R3=4'd3, ADD=4'd4;
    localparam L1=4'd5, L2=4'd6, L3 = 4'd7, SUB = 4'd8;
    reg [3:0] curState;
    reg [3:0] nextState;
    reg [31:0] step_up;
    reg [31:0] step_down;

    always @(*) 
    begin
        //Step Down
        if(target_freq<10)       
        step_up=32'd1;
        else if(target_freq<100)      
        step_up=32'd10;
        else if(target_freq<1000)     
        step_up=32'd100;
        else if (target_freq<10000)    
        step_up=32'd1000;
        else if(target_freq<100000)   
        step_up=32'd10000;
        else                             
        step_up=32'd100000;

        //Step Down
        if(target_freq<=10)      
        step_down=32'd1;
        else if(target_freq<=100)     
        step_down=32'd10;
        else if(target_freq<=1000)    
        step_down=32'd100;
        else if(target_freq<=10000)   
        step_down= 32'd1000;
        else if(target_freq<=100000)  
        step_down=32'd10000;
        else 
        step_down=32'd100000;
    end

   
    always @(*) 
    begin
        case(curState)
            IDLE: nextState=(b==1'b0) ? R1 : ((a==1'b0) ? L1 : IDLE);
            R1:   nextState=(b==1'b1) ? IDLE : ((a==1'b0) ? R2 : R1);
            R2:   nextState=(a==1'b1) ? R1 : ((b==1'b1) ? R3 : R2);
            R3:   nextState=(b==1'b0) ? R2 : ((a==1'b1) ? ADD : R3);
            ADD:  nextState=IDLE;
            L1:   nextState=(a==1'b1) ? IDLE : ((b==1'b0) ? L2 : L1);
            L2:   nextState=(b==1'b1) ? L1 : ((a==1'b1) ? L3 : L2);
            L3:   nextState=(a==1'b0) ? L2 : ((b==1'b1) ? SUB : L3);
            SUB:  nextState=IDLE;
            default: nextState=IDLE;
        endcase
    end

    
    always @(posedge clk) 
    begin
        if(reset) 
        begin
            curState<=IDLE;
            target_freq<=32'd1000;
        end 
        else 
        begin
            if (curState!=nextState) 
            begin
                if(nextState==ADD) 
                begin 
                    if(target_freq+step_up<=32'd1000000) 
                        target_freq<=target_freq+step_up;
                    else 
                        target_freq<=32'd1000000;
                end 
                else if(nextState==SUB) 
                begin 
                    if(target_freq>step_down) 
                    target_freq<=target_freq-step_down;
                    else 
                    target_freq<=32'd1;
                end
            end
            curState<=nextState;
        end
    end

    // assign phase_inc=(target_freq*64'd175922)>>12;
    assign phase_inc=(target_freq*64'd3518)>>12;

endmodule