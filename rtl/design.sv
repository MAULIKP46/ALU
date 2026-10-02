module ALU #(
  parameter WIDTH = 32,
  parameter PIPELINE_STAGES = 8
)(
  input  logic clk,
  input logic reset,

  input logic [WIDTH-1:0] A,
  input logic [WIDTH-1:0] B,
  input logic [4:0] opcode,

  output logic [(2*WIDTH)-1:0] product,
  output logic [WIDTH-1:0] result,
  output logic [WIDTH-1:0] quotient,
  output logic [WIDTH-1:0] remainder,

  output logic carry,
  output logic borrow,
  output logic zero,
  output logic negative,
  output logic overflow,
  output logic div_zero,

  output logic valid
);

  // ============================================================
  // OPCODES
  // ============================================================

  localparam [4:0] ADD  = 5'd0;
  localparam [4:0] SUB  = 5'd1;
  localparam [4:0] AND  = 5'd2;
  localparam [4:0] OR   = 5'd3;
  localparam [4:0] XOR  = 5'd4;
  localparam [4:0] NOT_A = 5'd5;
  localparam [4:0] RIGHT_SHIFT = 5'd6;
  localparam [4:0] LEFT_SHIFT = 5'd7;
  localparam [4:0] ARITHMETIC_RIGHT_SHIFT = 5'd8;
  localparam [4:0] INC_A = 5'd9;
  localparam [4:0] DEC_A = 5'd10;
  localparam [4:0] NAND = 5'd11;
  localparam [4:0] NOR = 5'd12;
  localparam [4:0] XNOR = 5'd13;
  localparam [4:0] SLT = 5'd14;
  localparam [4:0] PASS_B = 5'd15;
  localparam [4:0] MUL = 5'd16;
  localparam [4:0] DIV = 5'd17;

  localparam integer PROD_WIDTH = 2 * WIDTH;
  localparam integer DIV_WIDTH  = WIDTH + 4;

  // ============================================================
  // OPCODE PIPELINE
  // ============================================================

  logic [4:0] opcode_s1;
  logic [4:0] opcode_s2;
  logic [4:0] opcode_s3;
  logic [4:0] opcode_s4;
  logic [4:0] opcode_s5;
  logic [4:0] opcode_s6;
  logic [4:0] opcode_s7;
  logic [4:0] opcode_s8;

  // ============================================================
  // VALID PIPELINE
  // ============================================================

  logic valid_s1;
  logic valid_s2;
  logic valid_s3;
  logic valid_s4;
  logic valid_s5;
  logic valid_s6;
  logic valid_s7;
  logic valid_s8;

  // ============================================================
  // SIMPLE OPERATIONS
  // ============================================================

  logic [WIDTH:0] add_ext;
  logic [WIDTH:0] inc_ext;
  logic [WIDTH:0] dec_ext;

  logic [WIDTH-1:0] sub_result;

  logic [WIDTH-1:0] simple_result_s1;
  logic [WIDTH-1:0] simple_result_s2;
  logic [WIDTH-1:0] simple_result_s3;
  logic [WIDTH-1:0] simple_result_s4;
  logic [WIDTH-1:0] simple_result_s5;
  logic [WIDTH-1:0] simple_result_s6;
  logic [WIDTH-1:0] simple_result_s7;
  logic [WIDTH-1:0] simple_result_s8;

  logic simple_carry_s1;
  logic simple_carry_s2;
  logic simple_carry_s3;
  logic simple_carry_s4;
  logic simple_carry_s5;
  logic simple_carry_s6;
  logic simple_carry_s7;
  logic simple_carry_s8;

  logic simple_borrow_s1;
  logic simple_borrow_s2;
  logic simple_borrow_s3;
  logic simple_borrow_s4;
  logic simple_borrow_s5;
  logic simple_borrow_s6;
  logic simple_borrow_s7;
  logic simple_borrow_s8;

  logic simple_zero_s1;
  logic simple_zero_s2;
  logic simple_zero_s3;
  logic simple_zero_s4;
  logic simple_zero_s5;
  logic simple_zero_s6;
  logic simple_zero_s7;
  logic simple_zero_s8;

  logic simple_negative_s1;
  logic simple_negative_s2;
  logic simple_negative_s3;
  logic simple_negative_s4;
  logic simple_negative_s5;
  logic simple_negative_s6;
  logic simple_negative_s7;
  logic simple_negative_s8;

  logic simple_overflow_s1;
  logic simple_overflow_s2;
  logic simple_overflow_s3;
  logic simple_overflow_s4;
  logic simple_overflow_s5;
  logic simple_overflow_s6;
  logic simple_overflow_s7;
  logic simple_overflow_s8;

  // ============================================================
  // MULTIPLIER PIPELINE
  //
  // 32 x 32 unsigned multiplication.
  //
  // Each stage processes 4 bits of B.
  //
  // Stage 1 -> B[3:0]
  // Stage 2 -> B[7:4]
  // Stage 3 -> B[11:8]
  // Stage 4 -> B[15:12]
  // Stage 5 -> B[19:16]
  // Stage 6 -> B[23:20]
  // Stage 7 -> B[27:24]
  // Stage 8 -> B[31:28]
  //
  // Therefore:
  //
  // 8 pipeline stages
  // 4 multiplier bits/stage
  // ============================================================

  logic [PROD_WIDTH-1:0] mul_a_s1;
  logic [PROD_WIDTH-1:0] mul_a_s2;
  logic [PROD_WIDTH-1:0] mul_a_s3;
  logic [PROD_WIDTH-1:0] mul_a_s4;
  logic [PROD_WIDTH-1:0] mul_a_s5;
  logic [PROD_WIDTH-1:0] mul_a_s6;
  logic [PROD_WIDTH-1:0] mul_a_s7;
  logic [PROD_WIDTH-1:0] mul_a_s8;

  logic [WIDTH-1:0] mul_b_s1;
  logic [WIDTH-1:0] mul_b_s2;
  logic [WIDTH-1:0] mul_b_s3;
  logic [WIDTH-1:0] mul_b_s4;
  logic [WIDTH-1:0] mul_b_s5;
  logic [WIDTH-1:0] mul_b_s6;
  logic [WIDTH-1:0] mul_b_s7;
  logic [WIDTH-1:0] mul_b_s8;

  logic [PROD_WIDTH-1:0] mul_acc_s1;
  logic [PROD_WIDTH-1:0] mul_acc_s2;
  logic [PROD_WIDTH-1:0] mul_acc_s3;
  logic [PROD_WIDTH-1:0] mul_acc_s4;
  logic [PROD_WIDTH-1:0] mul_acc_s5;
  logic [PROD_WIDTH-1:0] mul_acc_s6;
  logic [PROD_WIDTH-1:0] mul_acc_s7;
  logic [PROD_WIDTH-1:0] mul_acc_s8;

  logic [PROD_WIDTH-1:0] mul_next_s1;
  logic [PROD_WIDTH-1:0] mul_next_s2;
  logic [PROD_WIDTH-1:0] mul_next_s3;
  logic [PROD_WIDTH-1:0] mul_next_s4;
  logic [PROD_WIDTH-1:0] mul_next_s5;
  logic [PROD_WIDTH-1:0] mul_next_s6;
  logic [PROD_WIDTH-1:0] mul_next_s7;
  logic [PROD_WIDTH-1:0] mul_next_s8;

  // ============================================================
  // DIVIDER PIPELINE
  //
  // Radix-16 restoring digit recurrence.
  //
  // 32 dividend bits
  // 4 bits/stage
  // 8 stages
  //
  // Each stage calculates one hexadecimal quotient digit.
  // ============================================================

  logic [WIDTH-1:0] div_a_s1;
  logic [WIDTH-1:0] div_a_s2;
  logic [WIDTH-1:0] div_a_s3;
  logic [WIDTH-1:0] div_a_s4;
  logic [WIDTH-1:0] div_a_s5;
  logic [WIDTH-1:0] div_a_s6;
  logic [WIDTH-1:0] div_a_s7;
  logic [WIDTH-1:0] div_a_s8;

  logic [WIDTH-1:0] div_b_s1;
  logic [WIDTH-1:0] div_b_s2;
  logic [WIDTH-1:0] div_b_s3;
  logic [WIDTH-1:0] div_b_s4;
  logic [WIDTH-1:0] div_b_s5;
  logic [WIDTH-1:0] div_b_s6;
  logic [WIDTH-1:0] div_b_s7;
  logic [WIDTH-1:0] div_b_s8;

  logic [DIV_WIDTH-1:0] div_r_s1;
  logic [DIV_WIDTH-1:0] div_r_s2;
  logic [DIV_WIDTH-1:0] div_r_s3;
  logic [DIV_WIDTH-1:0] div_r_s4;
  logic [DIV_WIDTH-1:0] div_r_s5;
  logic [DIV_WIDTH-1:0] div_r_s6;
  logic [DIV_WIDTH-1:0] div_r_s7;
  logic [DIV_WIDTH-1:0] div_r_s8;

  logic [WIDTH-1:0] div_q_s1;
  logic [WIDTH-1:0] div_q_s2;
  logic [WIDTH-1:0] div_q_s3;
  logic [WIDTH-1:0] div_q_s4;
  logic [WIDTH-1:0] div_q_s5;
  logic [WIDTH-1:0] div_q_s6;
  logic [WIDTH-1:0] div_q_s7;
  logic [WIDTH-1:0] div_q_s8;

  logic div_zero_s1;
  logic div_zero_s2;
  logic div_zero_s3;
  logic div_zero_s4;
  logic div_zero_s5;
  logic div_zero_s6;
  logic div_zero_s7;
  logic div_zero_s8;

  // ============================================================
  // DIVIDER COMBINATIONAL TEMPORARY SIGNALS
  // ============================================================

  logic [DIV_WIDTH-1:0] div_temp1;
  logic [DIV_WIDTH-1:0] div_temp2;
  logic [DIV_WIDTH-1:0] div_temp3;
  logic [DIV_WIDTH-1:0] div_temp4;
  logic [DIV_WIDTH-1:0] div_temp5;
  logic [DIV_WIDTH-1:0] div_temp6;
  logic [DIV_WIDTH-1:0] div_temp7;
  logic [DIV_WIDTH-1:0] div_temp8;

  logic [3:0] div_digit1;
  logic [3:0] div_digit2;
  logic [3:0] div_digit3;
  logic [3:0] div_digit4;
  logic [3:0] div_digit5;
  logic [3:0] div_digit6;
  logic [3:0] div_digit7;
  logic [3:0] div_digit8;

  logic [DIV_WIDTH-1:0] div_rem1;
  logic [DIV_WIDTH-1:0] div_rem2;
  logic [DIV_WIDTH-1:0] div_rem3;
  logic [DIV_WIDTH-1:0] div_rem4;
  logic [DIV_WIDTH-1:0] div_rem5;
  logic [DIV_WIDTH-1:0] div_rem6;
  logic [DIV_WIDTH-1:0] div_rem7;
  logic [DIV_WIDTH-1:0] div_rem8;

  // ============================================================
  // FUNCTION: 4-BIT MULTIPLICATION
  //
  // Calculates value * nibble using shifts and additions.
  // No multiplication operator.
  // ============================================================

  function automatic [PROD_WIDTH-1:0] nibble_product;
    input [PROD_WIDTH-1:0] value;
    input [3:0] nibble;

    reg [PROD_WIDTH-1:0] temp;

    begin
      temp = {PROD_WIDTH{1'b0}};

      if (nibble[0])
        temp = temp + value;

      if (nibble[1])
        temp = temp + (value << 1);

      if (nibble[2])
        temp = temp + (value << 2);

      if (nibble[3])
        temp = temp + (value << 3);

      nibble_product = temp;
    end

  endfunction

  // ============================================================
  // FUNCTION: DIVISOR * DIGIT
  //
  // digit is 0...15.
  //
  // No multiplication operator.
  // ============================================================

  function automatic [DIV_WIDTH-1:0] digit_product;
    input [WIDTH-1:0] divisor;
    input [3:0] digit;

    reg [DIV_WIDTH-1:0] divisor_ext;
    reg [DIV_WIDTH-1:0] temp;

    begin

      divisor_ext = {{4{1'b0}}, divisor};

      temp = {DIV_WIDTH{1'b0}};

      if (digit[0])
        temp = temp + divisor_ext;

      if (digit[1])
        temp = temp + (divisor_ext << 1);

      if (digit[2])
        temp = temp + (divisor_ext << 2);

      if (digit[3])
        temp = temp + (divisor_ext << 3);

      digit_product = temp;

    end

  endfunction

  // ============================================================
  // FUNCTION: FIND RADIX-16 QUOTIENT DIGIT
  //
  // Finds largest digit 0...15 for which:
  //
  // digit * divisor <= temporary remainder
  //
  // No division or multiplication operators.
  // ============================================================

  function automatic [3:0] division_digit;
    input [DIV_WIDTH-1:0] temp;
    input [WIDTH-1:0] divisor;

    integer k;

    reg [DIV_WIDTH-1:0] trial;
    reg [3:0] best;

    begin

      best = 4'd0;

      for (k = 0; k < 16; k = k + 1) begin

        trial = digit_product(divisor, k[3:0]);

        if (trial <= temp)
          best = k[3:0];

      end

      division_digit = best;

    end

  endfunction

  // ============================================================
  // SIMPLE OPERATIONS
  // ============================================================

  always_comb begin

    add_ext = {1'b0, A} + {1'b0, B};

    sub_result = A - B;

    inc_ext = {1'b0, A} +
              {{WIDTH{1'b0}}, 1'b1};

    dec_ext = {1'b0, A} -
              {{WIDTH{1'b0}}, 1'b1};

    simple_result_s1 = {WIDTH{1'b0}};

    simple_carry_s1 = 1'b0;
    simple_borrow_s1 = 1'b0;
    simple_zero_s1 = 1'b0;
    simple_negative_s1 = 1'b0;
    simple_overflow_s1 = 1'b0;

    case (opcode)

      ADD: begin

        simple_result_s1 = add_ext[WIDTH-1:0];

        simple_carry_s1 = add_ext[WIDTH];

        simple_overflow_s1 =
          (~(A[WIDTH-1] ^ B[WIDTH-1])) &
          (simple_result_s1[WIDTH-1] ^
           A[WIDTH-1]);

      end

      SUB: begin

        simple_result_s1 = sub_result;

        simple_borrow_s1 = (A < B);

        simple_overflow_s1 =
          (A[WIDTH-1] ^ B[WIDTH-1]) &
          (simple_result_s1[WIDTH-1] ^
           A[WIDTH-1]);

      end

      AND:
        simple_result_s1 = A & B;

      OR:
        simple_result_s1 = A | B;

      XOR:
        simple_result_s1 = A ^ B;

      NOT_A:
        simple_result_s1 = ~A;

      RIGHT_SHIFT:
        simple_result_s1 = A >> B;

      LEFT_SHIFT:
        simple_result_s1 = A << B;

      ARITHMETIC_RIGHT_SHIFT:
        simple_result_s1 = $signed(A) >>> B;

      INC_A: begin

        simple_result_s1 = inc_ext[WIDTH-1:0];

        simple_carry_s1 = inc_ext[WIDTH];

      end

      DEC_A: begin

        simple_result_s1 = dec_ext[WIDTH-1:0];

        simple_borrow_s1 =
          (A == {WIDTH{1'b0}});

      end

      NAND:
        simple_result_s1 = ~(A & B);

      NOR:
        simple_result_s1 = ~(A | B);

      XNOR:
        simple_result_s1 = ~(A ^ B);

      SLT: begin

        if ($signed(A) < $signed(B))
          simple_result_s1 =
            {{(WIDTH-1){1'b0}}, 1'b1};
        else
          simple_result_s1 =
            {WIDTH{1'b0}};

      end

      PASS_B:
        simple_result_s1 = B;

      default:
        simple_result_s1 = {WIDTH{1'b0}};

    endcase

    simple_zero_s1 =
      (simple_result_s1 == {WIDTH{1'b0}});

    simple_negative_s1 =
      simple_result_s1[WIDTH-1];

  end

  // ============================================================
  // MULTIPLIER COMBINATIONAL PARTS
  // ============================================================

  always_comb begin

    mul_next_s1 =
      mul_acc_s1 +
      nibble_product(
        mul_a_s1,
        mul_b_s1[3:0]
      );

    mul_next_s2 =
      mul_acc_s2 +
      nibble_product(
        mul_a_s2,
        mul_b_s2[7:4]
      );

    mul_next_s3 =
      mul_acc_s3 +
      nibble_product(
        mul_a_s3,
        mul_b_s3[11:8]
      );

    mul_next_s4 =
      mul_acc_s4 +
      nibble_product(
        mul_a_s4,
        mul_b_s4[15:12]
      );

    mul_next_s5 =
      mul_acc_s5 +
      nibble_product(
        mul_a_s5,
        mul_b_s5[19:16]
      );

    mul_next_s6 =
      mul_acc_s6 +
      nibble_product(
        mul_a_s6,
        mul_b_s6[23:20]
      );

    mul_next_s7 =
      mul_acc_s7 +
      nibble_product(
        mul_a_s7,
        mul_b_s7[27:24]
      );

    mul_next_s8 =
      mul_acc_s8 +
      nibble_product(
        mul_a_s8,
        mul_b_s8[31:28]
      );

  end

  // ============================================================
  // DIVIDER COMBINATIONAL PARTS
  // ============================================================

  always_comb begin

    // ----------------------------------------------------------
    // DIVISION STAGE 1
    // ----------------------------------------------------------

    div_temp1 =
      (div_r_s1 << 4) |
      {{(DIV_WIDTH-4){1'b0}},
       div_a_s1[31:28]};

    div_digit1 =
      division_digit(
        div_temp1,
        div_b_s1
      );

    div_rem1 =
      div_temp1 -
      digit_product(
        div_b_s1,
        div_digit1
      );

    // ----------------------------------------------------------
    // DIVISION STAGE 2
    // ----------------------------------------------------------

    div_temp2 =
      (div_r_s2 << 4) |
      {{(DIV_WIDTH-4){1'b0}},
       div_a_s2[27:24]};

    div_digit2 =
      division_digit(
        div_temp2,
        div_b_s2
      );

    div_rem2 =
      div_temp2 -
      digit_product(
        div_b_s2,
        div_digit2
      );

    // ----------------------------------------------------------
    // DIVISION STAGE 3
    // ----------------------------------------------------------

    div_temp3 =
      (div_r_s3 << 4) |
      {{(DIV_WIDTH-4){1'b0}},
       div_a_s3[23:20]};

    div_digit3 =
      division_digit(
        div_temp3,
        div_b_s3
      );

    div_rem3 =
      div_temp3 -
      digit_product(
        div_b_s3,
        div_digit3
      );

    // ----------------------------------------------------------
    // DIVISION STAGE 4
    // ----------------------------------------------------------

    div_temp4 =
      (div_r_s4 << 4) |
      {{(DIV_WIDTH-4){1'b0}},
       div_a_s4[19:16]};

    div_digit4 =
      division_digit(
        div_temp4,
        div_b_s4
      );

    div_rem4 =
      div_temp4 -
      digit_product(
        div_b_s4,
        div_digit4
      );

    // ----------------------------------------------------------
    // DIVISION STAGE 5
    // ----------------------------------------------------------

    div_temp5 =
      (div_r_s5 << 4) |
      {{(DIV_WIDTH-4){1'b0}},
       div_a_s5[15:12]};

    div_digit5 =
      division_digit(
        div_temp5,
        div_b_s5
      );

    div_rem5 =
      div_temp5 -
      digit_product(
        div_b_s5,
        div_digit5
      );

    // ----------------------------------------------------------
    // DIVISION STAGE 6
    // ----------------------------------------------------------

    div_temp6 =
      (div_r_s6 << 4) |
      {{(DIV_WIDTH-4){1'b0}},
       div_a_s6[11:8]};

    div_digit6 =
      division_digit(
        div_temp6,
        div_b_s6
      );

    div_rem6 =
      div_temp6 -
      digit_product(
        div_b_s6,
        div_digit6
      );

    // ----------------------------------------------------------
    // DIVISION STAGE 7
    // ----------------------------------------------------------

    div_temp7 =
      (div_r_s7 << 4) |
      {{(DIV_WIDTH-4){1'b0}},
       div_a_s7[7:4]};

    div_digit7 =
      division_digit(
        div_temp7,
        div_b_s7
      );

    div_rem7 =
      div_temp7 -
      digit_product(
        div_b_s7,
        div_digit7
      );

    // ----------------------------------------------------------
    // DIVISION STAGE 8
    // ----------------------------------------------------------

    div_temp8 =
      (div_r_s8 << 4) |
      {{(DIV_WIDTH-4){1'b0}},
       div_a_s8[3:0]};

    div_digit8 =
      division_digit(
        div_temp8,
        div_b_s8
      );

    div_rem8 =
      div_temp8 -
      digit_product(
        div_b_s8,
        div_digit8
      );

  end

  // ============================================================
  // SEQUENTIAL PIPELINE
  // ============================================================

  always_ff @(posedge clk or posedge reset) begin

    if (reset) begin

      // --------------------------------------------------------
      // OPCODE
      // --------------------------------------------------------

      opcode_s1 <= 5'd0;
      opcode_s2 <= 5'd0;
      opcode_s3 <= 5'd0;
      opcode_s4 <= 5'd0;
      opcode_s5 <= 5'd0;
      opcode_s6 <= 5'd0;
      opcode_s7 <= 5'd0;
      opcode_s8 <= 5'd0;

      // --------------------------------------------------------
      // VALID
      // --------------------------------------------------------

      valid_s1 <= 1'b0;
      valid_s2 <= 1'b0;
      valid_s3 <= 1'b0;
      valid_s4 <= 1'b0;
      valid_s5 <= 1'b0;
      valid_s6 <= 1'b0;
      valid_s7 <= 1'b0;
      valid_s8 <= 1'b0;

      // --------------------------------------------------------
      // SIMPLE OPERATIONS
      // --------------------------------------------------------

      simple_result_s2 <= '0;
      simple_result_s3 <= '0;
      simple_result_s4 <= '0;
      simple_result_s5 <= '0;
      simple_result_s6 <= '0;
      simple_result_s7 <= '0;
      simple_result_s8 <= '0;

      simple_carry_s2 <= 1'b0;
      simple_carry_s3 <= 1'b0;
      simple_carry_s4 <= 1'b0;
      simple_carry_s5 <= 1'b0;
      simple_carry_s6 <= 1'b0;
      simple_carry_s7 <= 1'b0;
      simple_carry_s8 <= 1'b0;

      simple_borrow_s2 <= 1'b0;
      simple_borrow_s3 <= 1'b0;
      simple_borrow_s4 <= 1'b0;
      simple_borrow_s5 <= 1'b0;
      simple_borrow_s6 <= 1'b0;
      simple_borrow_s7 <= 1'b0;
      simple_borrow_s8 <= 1'b0;

      simple_zero_s2 <= 1'b0;
      simple_zero_s3 <= 1'b0;
      simple_zero_s4 <= 1'b0;
      simple_zero_s5 <= 1'b0;
      simple_zero_s6 <= 1'b0;
      simple_zero_s7 <= 1'b0;
      simple_zero_s8 <= 1'b0;

      simple_negative_s2 <= 1'b0;
      simple_negative_s3 <= 1'b0;
      simple_negative_s4 <= 1'b0;
      simple_negative_s5 <= 1'b0;
      simple_negative_s6 <= 1'b0;
      simple_negative_s7 <= 1'b0;
      simple_negative_s8 <= 1'b0;

      simple_overflow_s2 <= 1'b0;
      simple_overflow_s3 <= 1'b0;
      simple_overflow_s4 <= 1'b0;
      simple_overflow_s5 <= 1'b0;
      simple_overflow_s6 <= 1'b0;
      simple_overflow_s7 <= 1'b0;
      simple_overflow_s8 <= 1'b0;

      // --------------------------------------------------------
      // MULTIPLIER
      // --------------------------------------------------------

      mul_a_s1 <= '0;
      mul_a_s2 <= '0;
      mul_a_s3 <= '0;
      mul_a_s4 <= '0;
      mul_a_s5 <= '0;
      mul_a_s6 <= '0;
      mul_a_s7 <= '0;
      mul_a_s8 <= '0;

      mul_b_s1 <= '0;
      mul_b_s2 <= '0;
      mul_b_s3 <= '0;
      mul_b_s4 <= '0;
      mul_b_s5 <= '0;
      mul_b_s6 <= '0;
      mul_b_s7 <= '0;
      mul_b_s8 <= '0;

      mul_acc_s1 <= '0;
      mul_acc_s2 <= '0;
      mul_acc_s3 <= '0;
      mul_acc_s4 <= '0;
      mul_acc_s5 <= '0;
      mul_acc_s6 <= '0;
      mul_acc_s7 <= '0;
      mul_acc_s8 <= '0;

      // --------------------------------------------------------
      // DIVIDER
      // --------------------------------------------------------

      div_a_s1 <= '0;
      div_a_s2 <= '0;
      div_a_s3 <= '0;
      div_a_s4 <= '0;
      div_a_s5 <= '0;
      div_a_s6 <= '0;
      div_a_s7 <= '0;
      div_a_s8 <= '0;

      div_b_s1 <= '0;
      div_b_s2 <= '0;
      div_b_s3 <= '0;
      div_b_s4 <= '0;
      div_b_s5 <= '0;
      div_b_s6 <= '0;
      div_b_s7 <= '0;
      div_b_s8 <= '0;

      div_r_s1 <= '0;
      div_r_s2 <= '0;
      div_r_s3 <= '0;
      div_r_s4 <= '0;
      div_r_s5 <= '0;
      div_r_s6 <= '0;
      div_r_s7 <= '0;
      div_r_s8 <= '0;

      div_q_s1 <= '0;
      div_q_s2 <= '0;
      div_q_s3 <= '0;
      div_q_s4 <= '0;
      div_q_s5 <= '0;
      div_q_s6 <= '0;
      div_q_s7 <= '0;
      div_q_s8 <= '0;

      div_zero_s1 <= 1'b0;
      div_zero_s2 <= 1'b0;
      div_zero_s3 <= 1'b0;
      div_zero_s4 <= 1'b0;
      div_zero_s5 <= 1'b0;
      div_zero_s6 <= 1'b0;
      div_zero_s7 <= 1'b0;
      div_zero_s8 <= 1'b0;

    end
    else begin

      // ========================================================
      // OPCODE PIPELINE
      // ========================================================

      opcode_s1 <= opcode;
      opcode_s2 <= opcode_s1;
      opcode_s3 <= opcode_s2;
      opcode_s4 <= opcode_s3;
      opcode_s5 <= opcode_s4;
      opcode_s6 <= opcode_s5;
      opcode_s7 <= opcode_s6;
      opcode_s8 <= opcode_s7;

      // ========================================================
      // VALID PIPELINE
      // ========================================================

      valid_s1 <= 1'b1;
      valid_s2 <= valid_s1;
      valid_s3 <= valid_s2;
      valid_s4 <= valid_s3;
      valid_s5 <= valid_s4;
      valid_s6 <= valid_s5;
      valid_s7 <= valid_s6;
      valid_s8 <= valid_s7;

      // ========================================================
      // SIMPLE OPERATION PIPELINE
      // ========================================================

      simple_result_s2 <= simple_result_s1;
      simple_result_s3 <= simple_result_s2;
      simple_result_s4 <= simple_result_s3;
      simple_result_s5 <= simple_result_s4;
      simple_result_s6 <= simple_result_s5;
      simple_result_s7 <= simple_result_s6;
      simple_result_s8 <= simple_result_s7;

      simple_carry_s2 <= simple_carry_s1;
      simple_carry_s3 <= simple_carry_s2;
      simple_carry_s4 <= simple_carry_s3;
      simple_carry_s5 <= simple_carry_s4;
      simple_carry_s6 <= simple_carry_s5;
      simple_carry_s7 <= simple_carry_s6;
      simple_carry_s8 <= simple_carry_s7;

      simple_borrow_s2 <= simple_borrow_s1;
      simple_borrow_s3 <= simple_borrow_s2;
      simple_borrow_s4 <= simple_borrow_s3;
      simple_borrow_s5 <= simple_borrow_s4;
      simple_borrow_s6 <= simple_borrow_s5;
      simple_borrow_s7 <= simple_borrow_s6;
      simple_borrow_s8 <= simple_borrow_s7;

      simple_zero_s2 <= simple_zero_s1;
      simple_zero_s3 <= simple_zero_s2;
      simple_zero_s4 <= simple_zero_s3;
      simple_zero_s5 <= simple_zero_s4;
      simple_zero_s6 <= simple_zero_s5;
      simple_zero_s7 <= simple_zero_s6;
      simple_zero_s8 <= simple_zero_s7;

      simple_negative_s2 <= simple_negative_s1;
      simple_negative_s3 <= simple_negative_s2;
      simple_negative_s4 <= simple_negative_s3;
      simple_negative_s5 <= simple_negative_s4;
      simple_negative_s6 <= simple_negative_s5;
      simple_negative_s7 <= simple_negative_s6;
      simple_negative_s8 <= simple_negative_s7;

      simple_overflow_s2 <= simple_overflow_s1;
      simple_overflow_s3 <= simple_overflow_s2;
      simple_overflow_s4 <= simple_overflow_s3;
      simple_overflow_s5 <= simple_overflow_s4;
      simple_overflow_s6 <= simple_overflow_s5;
      simple_overflow_s7 <= simple_overflow_s6;
      simple_overflow_s8 <= simple_overflow_s7;

      // ========================================================
      // MULTIPLIER PIPELINE
      // ========================================================

      // Stage 1
      mul_a_s1 <= {{WIDTH{1'b0}}, A};
      mul_b_s1 <= B;
      mul_acc_s1 <= '0;

      // Stage 2
      mul_a_s2 <= mul_a_s1 << 4;
      mul_b_s2 <= mul_b_s1;
      mul_acc_s2 <= mul_next_s1;

      // Stage 3
      mul_a_s3 <= mul_a_s2 << 4;
      mul_b_s3 <= mul_b_s2;
      mul_acc_s3 <= mul_next_s2;

      // Stage 4
      mul_a_s4 <= mul_a_s3 << 4;
      mul_b_s4 <= mul_b_s3;
      mul_acc_s4 <= mul_next_s3;

      // Stage 5
      mul_a_s5 <= mul_a_s4 << 4;
      mul_b_s5 <= mul_b_s4;
      mul_acc_s5 <= mul_next_s4;

      // Stage 6
      mul_a_s6 <= mul_a_s5 << 4;
      mul_b_s6 <= mul_b_s5;
      mul_acc_s6 <= mul_next_s5;

      // Stage 7
      mul_a_s7 <= mul_a_s6 << 4;
      mul_b_s7 <= mul_b_s6;
      mul_acc_s7 <= mul_next_s6;

      // Stage 8
      mul_a_s8 <= mul_a_s7 << 4;
      mul_b_s8 <= mul_b_s7;
      mul_acc_s8 <= mul_next_s7;

      // ========================================================
      // DIVIDER PIPELINE
      // ========================================================

      // Stage 1
      div_a_s1 <= A;
      div_b_s1 <= B;
      div_r_s1 <= '0;
      div_q_s1 <= '0;
      div_zero_s1 <= (B == {WIDTH{1'b0}});

      // Stage 2
      div_a_s2 <= div_a_s1;
      div_b_s2 <= div_b_s1;
      div_r_s2 <= div_rem1;

      div_q_s2 <=
        {div_q_s1[WIDTH-5:0], div_digit1};

      div_zero_s2 <= div_zero_s1;

      // Stage 3
      div_a_s3 <= div_a_s2;
      div_b_s3 <= div_b_s2;
      div_r_s3 <= div_rem2;

      div_q_s3 <=
        {div_q_s2[WIDTH-5:0], div_digit2};

      div_zero_s3 <= div_zero_s2;

      // Stage 4
      div_a_s4 <= div_a_s3;
      div_b_s4 <= div_b_s3;
      div_r_s4 <= div_rem3;

      div_q_s4 <=
        {div_q_s3[WIDTH-5:0], div_digit3};

      div_zero_s4 <= div_zero_s3;

      // Stage 5
      div_a_s5 <= div_a_s4;
      div_b_s5 <= div_b_s4;
      div_r_s5 <= div_rem4;

      div_q_s5 <=
        {div_q_s4[WIDTH-5:0], div_digit4};

      div_zero_s5 <= div_zero_s4;

      // Stage 6
      div_a_s6 <= div_a_s5;
      div_b_s6 <= div_b_s5;
      div_r_s6 <= div_rem5;

      div_q_s6 <=
        {div_q_s5[WIDTH-5:0], div_digit5};

      div_zero_s6 <= div_zero_s5;

      // Stage 7
      div_a_s7 <= div_a_s6;
      div_b_s7 <= div_b_s6;
      div_r_s7 <= div_rem6;

      div_q_s7 <=
        {div_q_s6[WIDTH-5:0], div_digit6};

      div_zero_s7 <= div_zero_s6;

      // Stage 8
      div_a_s8 <= div_a_s7;
      div_b_s8 <= div_b_s7;
      div_r_s8 <= div_rem7;

      div_q_s8 <=
        {div_q_s7[WIDTH-5:0], div_digit7};

      div_zero_s8 <= div_zero_s7;

    end

  end

  // ============================================================
  // FINAL OUTPUT MUX
  // ============================================================

  always_comb begin

    // Defaults
    product = {PROD_WIDTH{1'b0}};

    result = simple_result_s8;

    quotient = {WIDTH{1'b0}};
    remainder = {WIDTH{1'b0}};

    carry = simple_carry_s8;
    borrow = simple_borrow_s8;
    zero = simple_zero_s8;
    negative = simple_negative_s8;
    overflow = simple_overflow_s8;

    div_zero = 1'b0;

    valid = valid_s8;

    // ----------------------------------------------------------
    // MUL
    // ----------------------------------------------------------

    if (opcode_s8 == MUL) begin

      product = mul_next_s8;

      result = mul_next_s8[WIDTH-1:0];

      zero =
        (mul_next_s8 == {PROD_WIDTH{1'b0}});

      negative =
        mul_next_s8[WIDTH-1];

      carry = 1'b0;
      borrow = 1'b0;
      overflow = 1'b0;

    end

    // ----------------------------------------------------------
    // DIV
    // ----------------------------------------------------------
    else if (opcode_s8 == DIV) begin
      if (div_zero_s8) begin
        quotient = {WIDTH{1'b0}};
        remainder = {WIDTH{1'b0}};
        result = {WIDTH{1'b0}};
        div_zero = 1'b1;
      end
      else begin
        quotient = {div_q_s8[WIDTH-5:0], div_digit8};
        remainder =  div_rem8[WIDTH-1:0];
        result = {div_q_s8[WIDTH-5:0], div_digit8};
        div_zero = 1'b0;
      end
      carry = 1'b0;
      borrow = 1'b0;
      zero = 1'b0;
      negative = 1'b0;
      overflow = 1'b0;
    end
  end
endmodule
