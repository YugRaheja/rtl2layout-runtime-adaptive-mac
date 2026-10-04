`timescale 1ns / 1ps
// Self-checking testbench for top_mac.
//  * ONE testbench for the whole design - submodules are exercised through top_mac
//  * Inputs are driven on negedge, DUT output is checked on the next negedge
//    (race-free: DUT updates on posedge, reference model updates on posedge)
//  * Prints PASS/FAIL and a final error count; dumps VCD for Covered
module tb_top_mac;

    reg                clk, rst, clear, enable;
    reg  signed [15:0] A, B;
    reg         [1:0]  mode;
    wire signed [31:0] Y;

    top_mac uut (.clk(clk), .rst(rst), .clear(clear), .enable(enable),
                 .A(A), .B(B), .mode(mode), .Y(Y));

    // ---------------- clock ----------------
    initial clk = 1'b0;
    always #5 clk = ~clk;                       // 100 MHz

    // ---------------- reference model ----------------
    function signed [15:0] ext;                 // select + sign-extend
        input signed [15:0] x;
        input        [1:0]  m;
        begin
            case (m)
                2'b00:   ext = {{12{x[3]}}, x[3:0]};
                2'b01:   ext = {{8{x[7]}},  x[7:0]};
                default: ext = x;
            endcase
        end
    endfunction

    reg signed [31:0] exp_Y;
    reg signed [15:0] ea, eb;
    always @(posedge clk or posedge rst) begin
        if (rst)         exp_Y <= 32'sd0;
        else if (clear)  exp_Y <= 32'sd0;
        else if (enable) begin
            ea = ext(A, mode);
            eb = ext(B, mode);
            exp_Y <= exp_Y + ea * eb;
        end
    end

    // ---------------- checker ----------------
    integer errors = 0, checks = 0;
    always @(negedge clk) begin
        checks = checks + 1;
        if (Y !== exp_Y) begin
            errors = errors + 1;
            $display("[FAIL] t=%0t mode=%b Y=%0d expected=%0d", $time, mode, Y, exp_Y);
        end
    end

    // ---------------- stimulus helpers ----------------
    task drive;
        input [1:0]         m;
        input signed [15:0] a_in, b_in;
        input               en, clr;
        begin
            @(negedge clk);
            mode = m; A = a_in; B = b_in; enable = en; clear = clr;
        end
    endtask

    integer i, m_i;
    reg [1:0] rm;

    initial begin
        $dumpfile("build/top_mac.vcd");
        $dumpvars(0, tb_top_mac.uut);   // DUT only: keeps VCD small and Covered-friendly

        rst = 1; clear = 0; enable = 0; A = 0; B = 0; mode = 2'b10;
        #23 rst = 0;                                   // async release off-edge

        // ---- directed: corner values in every mode ----
        for (m_i = 0; m_i < 4; m_i = m_i + 1) begin
            drive(m_i, 16'sd0,      16'sd0,      1, 1);   // clear
            drive(m_i, 16'sd0,      16'sd0,      1, 0);
            drive(m_i, 16'sd1,      16'sd1,      1, 0);
            drive(m_i, -16'sd1,     16'sd1,      1, 0);
            drive(m_i, -16'sd1,     -16'sd1,     1, 0);
            drive(m_i, 16'sd7,      16'sd7,      1, 0);   // INT4 max
            drive(m_i, -16'sd8,     -16'sd8,     1, 0);   // INT4 min
            drive(m_i, -16'sd8,     16'sd7,      1, 0);
            drive(m_i, 16'sd127,    16'sd127,    1, 0);   // INT8 max
            drive(m_i, -16'sd128,   -16'sd128,   1, 0);   // INT8 min
            drive(m_i, 16'sd32767,  16'sd32767,  1, 0);   // INT16 max
            drive(m_i, -16'sd32768, -16'sd32768, 1, 0);   // INT16 min
            drive(m_i, 16'sd32767,  -16'sd32768, 1, 0);
            drive(m_i, 16'shA5A5,   16'sh5A5A,   1, 0);   // upper bits must be ignored in INT4/8
        end

        // ---- directed: enable low must hold the accumulator ----
        drive(2'b10, 16'sd100, 16'sd100, 1, 0);
        drive(2'b10, 16'sd100, 16'sd100, 0, 0);
        drive(2'b10, 16'sd100, 16'sd100, 0, 0);

        // ---- directed: clear has priority over enable ----
        drive(2'b10, 16'sd9, 16'sd9, 1, 1);

        // ---- directed: 32-bit wrap-around ----
        drive(2'b10, 16'sd0, 16'sd0, 1, 1);
        for (i = 0; i < 8; i = i + 1)
            drive(2'b10, 16'sd32767, 16'sd32767, 1, 0);
        for (i = 0; i < 8; i = i + 1)
            drive(2'b10, -16'sd32768, 16'sd32767, 1, 0);

        // ---- directed: asynchronous reset in the middle of a run ----
        drive(2'b10, 16'sd5, 16'sd5, 1, 0);
        #2 rst = 1;  #3 rst = 0;                        // mid-cycle async pulse
        drive(2'b10, 16'sd5, 16'sd5, 1, 0);

        // ---- constrained-random: random mode/data/enable/clear ----
        for (i = 0; i < 20000; i = i + 1) begin
            rm = $random;
            drive(rm, $random, $random, ($random % 8) != 0, ($random % 64) == 0);
        end

        // ---- random with long mode dwell (like your original 4/8/16 sweep) ----
        for (m_i = 0; m_i < 3; m_i = m_i + 1)
            for (i = 0; i < 2000; i = i + 1)
                drive(m_i[1:0], $random, $random, 1, 0);

        @(negedge clk); @(negedge clk);
        $display("--------------------------------------------");
        $display("checks=%0d  errors=%0d", checks, errors);
        if (errors == 0) $display("TEST PASSED");
        else             $display("TEST FAILED");
        $display("--------------------------------------------");
        $finish;
    end

    // watchdog
    initial begin
        #5000000;
        $display("TIMEOUT"); $finish;
    end
endmodule
