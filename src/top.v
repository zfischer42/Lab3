// Floating-point convertion (FPCTV)


module top (
    input wire clk,             // system clock (100MHz from the board)
    input wire reset,           // reset button
    input wire pause,           // pause button
    input wire adjust,          // adjust switch (0/1)
    input wire select,          // select switch (0/1)

    output reg [6:0]  seg,      // 7 segment display output
    output reg [3:0]  anode     // Selector for anode
);
    reg [3:0] MinL, MinR, SecL, SecR;
    reg [3:0] display;

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
    integer newSecR, newSecL, newMinR, newMinL;

    // Create a clock divider 
    // 1 HZ, 2 Hz, 10 Hz (blinking), 400 Hz (display update)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MinL <= 0;
            MinR <= 0;
            SecL <= 0;
            SecR <= 0;
            
            anode   <= 4'b1000;     
            display <= 0;
            seg     <= 7'b1111110; 
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

        // DISPLAY
        if (en_400hz) begin
            // Set display based on anode, set next anode
            if (anode == 4'b1000) begin
                display <= MinL;
                anode   <= 4'b0100;
            end else if (anode == 4'b0100) begin
                display <= MinR;
                anode   <= 4'b0010;
            end else if (anode == 4'b0010) begin
                display <= SecL;
                anode   <= 4'b0001;
            end else if (anode == 4'b0001) begin
                display <= SecR; 
                anode   <= 4'b1000;
            end
        
            // Convert display to segments
            case (display)
                0: seg = 7'b1111110;
                1: seg = 7'b0110000;
                2: seg = 7'b1101101;
                3: seg = 7'b1111001;
                4: seg = 7'b0110011;
                5: seg = 7'b1011011;
                6: seg = 7'b1011111;
                7: seg = 7'b1110000;
                8: seg = 7'b1111111;
                9: seg = 7'b1110011;
                default: seg = 7'b1111111; // default to full display
            endcase
        end
    end


endmodule