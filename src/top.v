// Floating-point convertion (FPCTV)


module top (
    input wire clk,             // system clock (100MHz from the board)
    input wire reset,           // reset button
    input wire pause,           // pause button
    input wire adjust,          // adjust switch (0/1)
    input wire select,          // select switch (0/1)

    output reg [6:0]  seg,      // 7 segment display output
    output reg [3:0] anode     // Selector for anode
);
    reg [6:0] seg_raw;
    reg [3:0] MinL, MinR, SecL, SecR;
    reg [3:0] display;
    
    reg [1:0] display_digit = 0;

    wire en_1hz;
    wire en_2hz;
    wire en_10hz;
    wire en_400hz;
    
    // Instantiate the clock divider
    enable_gen clkenbl (
        // .clkdiv_inputs   (outputs that get set)
        .clk_100mhz (clk),
        .reset      (reset),

        .en_1hz    (en_1hz),
        .en_2hz    (en_2hz),
        .en_10hz   (en_10hz),
        .en_400hz  (en_400hz)
    );

    // We need integers so we can assign them without nonblocking
    reg [3:0] newSecR, newSecL, newMinR, newMinL;

    // Create a clock divider 
    // 1 HZ, 2 Hz, 10 Hz (blinking), 400 Hz (display update)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MinL <= 0;
            MinR <= 0;
            SecL <= 0;
            SecR <= 0;
            
        end else if (!pause) begin
            
            // STOPWATCH MODE
            if (adjust == 0) begin
                if (en_1hz) begin  

                    // Compute next second
                    newSecR = SecR + 1;
                    newSecL = SecL;
                    newMinR = MinR;
                    newMinL = MinL;

                    if (newSecR == 10) begin
                        newSecR = 0;
                        newSecL = newSecL + 1;
                    end
                    if (newSecL == 6) begin
                        newSecL = 0;
                        newMinR = newMinR + 1;
                    end
                    if (newMinR == 10) begin
                        newMinR = 0;
                        newMinL = newMinL + 1;
                    end
                    if (newMinL == 6) begin
                        newMinL = 0;
                    end

                    // Assign back
                    SecR <= newSecR;
                    SecL <= newSecL;
                    MinR <= newMinR;
                    MinL <= newMinL;
                end


            // ADJUST MODE
            end else begin
                if (en_2hz) begin               // increment every 2hz
                    // ADJUST MINUTES
                    if (select == 0) begin
                        newMinR = MinR + 1;
                        newMinL = MinL;
                        if (newMinR == 10) begin
                            newMinR = 0;
                            newMinL = newMinL + 1;
                        end
                        if (newMinL == 6) begin
                            newMinL = 0;
                        end
                        MinR <= newMinR;
                        MinL <= newMinL;

                    // ADJUST SECONDS
                    end else begin
                        newSecR = SecR + 1;
                        newSecL = SecL;
                        if (newSecR == 10) begin
                            newSecR = 0;
                            newSecL = newSecL + 1;
                        end
                        if (newSecL == 6) begin
                            newSecL = 0;
                        end
                        SecR <= newSecR;
                        SecL <= newSecL;
                    end
                end
            end
        end
    end


    always @(posedge clk or posedge reset) begin
        if (reset)
            display_digit <= 0;
        else if (en_400hz)
            display_digit <= display_digit + 1;
    end
        
    reg blink_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            blink_state <= 0;
        else if (en_10hz)
            blink_state <= ~blink_state;
    end
    
    // If adjust select and 10hz
    
    always @(*) begin
        case (display_digit)
            2'b00: begin
                anode = 4'b0111; 
                if (blink_state && adjust && ~select) begin
                    display = 10;
                end else begin
                    display = MinL;
                end
            end
             2'b01: begin
                anode = 4'b1011;
                if (blink_state && adjust && ~select) begin
                    display = 10;
                end else begin
                    display = MinR;
                end

            end
             2'b10: begin
                anode = 4'b1101;
                if (blink_state && adjust && select) begin
                    display = 10;
                end else begin
                    display = SecL;
                end
            end
            2'b11: begin
                anode = 4'b1110;
                if (blink_state && adjust && select) begin
                    display = 10;
                end else begin
                    display = SecR;
                end
            end
        endcase
    end
    
    // Cathode patterns of the 7-segment LED display 
    always @(*)
        begin
            case(display)
            4'b0000: seg = 7'b0000001; // "0"     
            4'b0001: seg = 7'b1001111; // "1" 
            4'b0010: seg = 7'b0010010; // "2" 
            4'b0011: seg = 7'b0000110; // "3" 
            4'b0100: seg = 7'b1001100; // "4" 
            4'b0101: seg = 7'b0100100; // "5" 
            4'b0110: seg = 7'b0100000; // "6" 
            4'b0111: seg = 7'b0001111; // "7" 
            4'b1000: seg = 7'b0000000; // "8"     
            4'b1001: seg = 7'b0000100; // "9" 
            4'b1010: seg = 7'b1111111; // "OFF"
            default: seg = 7'b0000001; // "0"
        endcase
    end

    
endmodule