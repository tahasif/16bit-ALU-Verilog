`timescale 1ns / 1ps

// 16-bit Arithmetic Logic Unit (combinational)
module alu_16bit (
    input  wire [15:0] A,        // first operand
    input  wire [15:0] B,        // second operand
    input  wire [3:0]  opcode,   // selects the operation (16 possible)
    output reg  [15:0] result,   // result of the operation
    output reg         carry,    // carry out (add) / borrow (sub) / shifted-out bit
    output reg         overflow, // signed overflow flag
    output wire        zero,     // 1 when result == 0
    output wire        negative  // 1 when result MSB is 1 (negative in 2's complement)
);

    // Opcode names make the code readable
    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b0001;
    localparam AND_ = 4'b0010;
    localparam OR_  = 4'b0011;
    localparam XOR_ = 4'b0100;
    localparam NOT_ = 4'b0101;
    localparam SHL  = 4'b0110;
    localparam SHR  = 4'b0111;
    localparam INC  = 4'b1000;
    localparam DEC  = 4'b1001;
    localparam NAND_= 4'b1010;
    localparam NOR_ = 4'b1011;
    localparam XNOR_= 4'b1100;
    localparam SLT  = 4'b1101;   // set if A < B (unsigned)
    localparam ROL  = 4'b1110;
    localparam ROR  = 4'b1111;

    always @(*) begin
        // Default values: avoids unwanted latches
        result   = 16'b0;
        carry    = 1'b0;
        overflow = 1'b0;

        case (opcode)
            ADD: begin
                {carry, result} = A + B;
                overflow = (A[15] == B[15]) && (result[15] != A[15]);
            end
            SUB: begin
                {carry, result} = A - B;   // carry = 1 means borrow (A < B)
                overflow = (A[15] != B[15]) && (result[15] != A[15]);
            end
            AND_:  result = A & B;
            OR_:   result = A | B;
            XOR_:  result = A ^ B;
            NOT_:  result = ~A;
            SHL:   {carry, result} = {A, 1'b0};   // carry gets old MSB
            SHR:   {result, carry} = {1'b0, A};   // carry gets old LSB
            INC:   {carry, result} = A + 16'd1;
            DEC:   {carry, result} = A - 16'd1;
            NAND_: result = ~(A & B);
            NOR_:  result = ~(A | B);
            XNOR_: result = ~(A ^ B);
            SLT:   result = (A < B) ? 16'd1 : 16'd0;
            ROL:   result = {A[14:0], A[15]};
            ROR:   result = {A[0], A[15:1]};
            default: result = 16'b0;
        endcase
    end

    // Status flags derived continuously from result
    assign zero     = (result == 16'b0);
    assign negative = result[15];

endmodule
