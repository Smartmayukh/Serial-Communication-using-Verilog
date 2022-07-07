module top_module(
    input clk,
    input in,
    input reset,    
    output [7:0] out_byte,
    output done
); 
    reg [7:0] mayukh;
    reg [3:0] state,next_state; 

    parameter start = 4'h0;
    parameter data1 = 4'h1;
    parameter data2 = 4'h2;
    parameter data3= 4'h3;
    parameter data4= 4'h4;
    parameter data5= 4'h5;
    parameter data6= 4'h6;
    parameter data7= 4'h7;
    parameter data8 = 4'h8;
    parameter stopmiss = 4'd9;
    parameter faultydone = 4'hA;
    parameter stop = 4'hB;
    parameter yay = 4'hC;
    parameter parity =4'hD;
    parameter noyay = 4'hE;
    parameter parityfault =4'hF;
    
    
    always@(*)begin
        case(state)    
            
            start:     next_state=(in)?start:data1;
            data1:     next_state=data2;
            data2:     next_state=data3;
            data3:     next_state=data4;
            data4:     next_state=data5;
            data5:     next_state=data6;
            data6:     next_state=data7;
            data7:     next_state=data8;
            data8:     next_state=parity;

            parity:    next_state=((^mayukh)^in)?stop:parityfault;
            
            
            
            parityfault: next_state=(in)?noyay:stopmiss;
            stop:      next_state=(in)?yay:stopmiss;
            
            
            yay:         next_state=(in)?start:data1;
            noyay:       next_state=(in)?start:data1;
            

            stopmiss:  next_state=(in)?faultydone:stopmiss;
            faultydone:next_state=(in)?start:data1;
            
        endcase
    end
    
    always@(posedge clk)
        begin
            
            if(reset)
                
                state<=start;

            else
                state<=next_state;
        end
    
    assign  done= (state==yay);
    
    
    always@(posedge clk)begin
        if(reset || state==start)
            mayukh<=8'h0;
        else if(next_state!=stop &&state!=stop)
            mayukh<={in,mayukh[7:1]};
    end
    assign out_byte=mayukh &({8{done}});

endmodule
