`timescale 1ns/1ps

module top_tb;

    // =====================
    // Clock parameters
    // =====================
    localparam CLK_PERIOD = 10; // 100 MHz → 10 ns
    localparam TEST_MIN = 0;
    localparam TEST_SEC = 30;

    // =====================
    // DUT signals
    // =====================
    reg clk;
    reg reset;
    reg pause;
    reg adjust;
    reg select;

    wire [6:0] seg;
    wire [3:0] anode;
    
    integer sec_count = 0;
    integer exp_sec = 0;
    integer exp_min = 0;

    // =====================
    // Instantiate DUT
    // =====================
    top dut (
        .clk    (clk),
        .reset  (reset),
        .pause  (pause),
        .adjust (adjust),
        .select (select),
        .seg    (seg),
        .anode  (anode)
    );


    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
    end


    // =====================
    // Clock generation
    // =====================
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;


    // =====================
    // Test sequence
    // =====================
    initial begin
        // Initialize inputs
        reset  = 1;
        pause  = 0;
        adjust = 0;
        select = 0;

        // Hold reset for 100 ns
        #100;
        reset = 0;

        $display("=== TEST START ===");
        $display("No inputs applied, running stopwatch...");        

    end

    // =====================
    // Monitoring
    // =====================


    


    always @(posedge dut.en_2hz) begin
    
        // $display(
        //     "T=%0t | %0d%0d:%0d%0d",
        //     $time,
        //     dut.MinL, dut.MinR,
        //     dut.SecL, dut.SecR
        // );
        $display(
            "EXPECTED %0d:%02d | DUT %0d%0d:%0d%0d",
            exp_min, exp_sec,
            dut.MinL, dut.MinR,
            dut.SecL, dut.SecR
        );

    end


    always @(posedge dut.en_1hz) begin
        // Expected counter
        exp_sec = exp_sec + 1;
        if (exp_sec == 60) begin
            exp_sec = 0;
            exp_min = exp_min + 1;
        end

        // expected counter
        sec_count = sec_count + 1;
        if (sec_count == TEST_MIN*60 + TEST_SEC) begin
            $display("=== TEST END: %0d stopwatch seconds ===", sec_count);
            $finish;
        end
    end




endmodule