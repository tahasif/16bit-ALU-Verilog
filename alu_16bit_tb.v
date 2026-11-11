`timescale 1ns / 1ps

module alu_16bit_tb;

    // Testbench drives inputs -> reg ; observes outputs -> wire
    reg  [15:0] A, B;
    reg  [3:0]  opcode;
    wire [15:0] result;
    wire        carry, overflow, zero, negative;

    integer pass_count, fail_count;

    // Device Under Test
    alu_16bit uut (
        .A(A), .B(B), .opcode(opcode),
        .result(result), .carry(carry), .overflow(overflow),
        .zero(zero), .negative(negative)
    );

    // Reusable check routine: apply inputs, wait, compare with expected
    task check;
        input [3:0]  op;
        input [15:0] a_in, b_in;
        input [15:0] exp_result;
        input        exp_carry;
        input        exp_overflow;
        begin
            A = a_in; B = b_in; opcode = op;
            #10;  // let combinational logic settle
            if (result === exp_result && carry === exp_carry && overflow === exp_overflow) begin
                pass_count = pass_count + 1;
                $display("PASS | op=%b A=%h B=%h | result=%h C=%b V=%b Z=%b N=%b",
                         op, a_in, b_in, result, carry, overflow, zero, negative);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL | op=%b A=%h B=%h | got %h C=%b V=%b | expected %h C=%b V=%b",
                         op, a_in, b_in, result, carry, overflow,
                         exp_result, exp_carry, exp_overflow);
            end
        end
    endtask

    initial begin
        pass_count = 0;
        fail_count = 0;

        //     op     A       B       result  C  V
        check(4'b0000, 16'h0005, 16'h0003, 16'h0008, 0, 0); // ADD
        check(4'b0000, 16'hFFFF, 16'h0001, 16'h0000, 1, 0); // ADD carry, zero
        check(4'b0000, 16'h7FFF, 16'h0001, 16'h8000, 0, 1); // ADD signed overflow
        check(4'b0001, 16'h0009, 16'h0004, 16'h0005, 0, 0); // SUB
        check(4'b0001, 16'h0004, 16'h0009, 16'hFFFB, 1, 0); // SUB borrow
        check(4'b0001, 16'h8000, 16'h0001, 16'h7FFF, 0, 1); // SUB overflow
        check(4'b0010, 16'hF0F0, 16'hFF00, 16'hF000, 0, 0); // AND
        check(4'b0011, 16'hF0F0, 16'h0F0F, 16'hFFFF, 0, 0); // OR
        check(4'b0100, 16'hAAAA, 16'h5555, 16'hFFFF, 0, 0); // XOR
        check(4'b0101, 16'h00FF, 16'h0000, 16'hFF00, 0, 0); // NOT
        check(4'b0110, 16'h8001, 16'h0000, 16'h0002, 1, 0); // SHL
        check(4'b0111, 16'h0003, 16'h0000, 16'h0001, 1, 0); // SHR
        check(4'b1000, 16'hFFFF, 16'h0000, 16'h0000, 1, 0); // INC
        check(4'b1001, 16'h0000, 16'h0000, 16'hFFFF, 1, 0); // DEC
        check(4'b1010, 16'hFFFF, 16'hFFFF, 16'h0000, 0, 0); // NAND
        check(4'b1011, 16'h0000, 16'h0000, 16'hFFFF, 0, 0); // NOR
        check(4'b1100, 16'hAAAA, 16'hAAAA, 16'hFFFF, 0, 0); // XNOR
        check(4'b1101, 16'h0003, 16'h0005, 16'h0001, 0, 0); // SLT true
        check(4'b1101, 16'h0005, 16'h0003, 16'h0000, 0, 0); // SLT false
        check(4'b1110, 16'h8001, 16'h0000, 16'h0003, 0, 0); // ROL
        check(4'b1111, 16'h8001, 16'h0000, 16'hC000, 0, 0); // ROR

        $display("-----------------------------------------");
        $display("TOTAL PASS = %0d, FAIL = %0d", pass_count, fail_count);
        $display("-----------------------------------------");
        $finish;
    end

endmodule
