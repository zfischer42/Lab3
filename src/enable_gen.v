module enable_gen (
    input  wire clk_100mhz,
    input  wire reset,

    output reg  en_1hz,
    output reg  en_2hz,
    output reg  en_10hz,
    output reg  en_400hz
);

`ifdef SIM
    localparam integer DIV_1HZ   = 10;
    localparam integer DIV_2HZ   = 5;
    localparam integer DIV_10HZ  = 2;
    localparam integer DIV_400HZ = 1;
`else
    localparam integer DIV_1HZ   = 100_000_000;
    localparam integer DIV_2HZ   = 50_000_000;
    localparam integer DIV_10HZ  = 10_000_000;
    localparam integer DIV_400HZ = 250_000;
`endif

    reg [$clog2(DIV_1HZ)  :0] cnt_1hz;
    reg [$clog2(DIV_2HZ)  :0] cnt_2hz;
    reg [$clog2(DIV_10HZ) :0] cnt_10hz;
    reg [$clog2(DIV_400HZ):0] cnt_400hz;

    always @(posedge clk_100mhz or posedge reset) begin
        if (reset) begin
            cnt_1hz   <= 0;
            cnt_2hz   <= 0;
            cnt_10hz  <= 0;
            cnt_400hz <= 0;

            en_1hz    <= 0;
            en_2hz    <= 0;
            en_10hz   <= 0;
            en_400hz  <= 0;
        end else begin
            // default: one-cycle pulses
            en_1hz    <= 0;
            en_2hz    <= 0;
            en_10hz   <= 0;
            en_400hz  <= 0;

            if (cnt_1hz == DIV_1HZ - 1) begin
                cnt_1hz <= 0;
                en_1hz  <= 1;
            end else
                cnt_1hz <= cnt_1hz + 1;

            if (cnt_2hz == DIV_2HZ - 1) begin
                cnt_2hz <= 0;
                en_2hz  <= 1;
            end else
                cnt_2hz <= cnt_2hz + 1;

            if (cnt_10hz == DIV_10HZ - 1) begin
                cnt_10hz <= 0;
                en_10hz  <= 1;
            end else
                cnt_10hz <= cnt_10hz + 1;

            if (cnt_400hz == DIV_400HZ - 1) begin
                cnt_400hz <= 0;
                en_400hz  <= 1;
            end else
                cnt_400hz <= cnt_400hz + 1;
        end
    end
endmodule
