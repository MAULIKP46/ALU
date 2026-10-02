module tb #(parameter WIDTH = 32);

  localparam int PIPELINE_LATENCY = 8;

  // ============================================================
  // CLOCK / RESET
  // ============================================================

  logic clk;
  logic reset;

  // ============================================================
  // ALU INPUTS
  // ============================================================

  logic [WIDTH-1:0] A;
  logic [WIDTH-1:0] B;
  logic [4:0] opcode;

  // ============================================================
  // ALU OUTPUTS
  // ============================================================

  logic [(2*WIDTH)-1:0] product;
  logic [WIDTH-1:0] result;
  logic [WIDTH-1:0] quotient;
  logic [WIDTH-1:0] remainder;

  logic carry;
  logic borrow;
  logic zero;
  logic negative;
  logic overflow;
  logic div_zero;
  logic valid;

  // ============================================================
  // TEST COUNTERS
  // ============================================================

  integer self_test_count   = 0;
  integer self_pass_count   = 0;
  integer self_fail_count   = 0;

  integer random_test_count = 0;
  integer random_pass_count = 0;
  integer random_fail_count = 0;

  // ============================================================
  // ALU INSTANCE
  // ============================================================

  ALU #(
    .WIDTH(WIDTH),
    .PIPELINE_STAGES(PIPELINE_LATENCY)
  ) dut (
    .clk(clk),
    .reset(reset),

    .A(A),
    .B(B),
    .opcode(opcode),

    .product(product),
    .result(result),
    .quotient(quotient),
    .remainder(remainder),

    .carry(carry),
    .borrow(borrow),
    .zero(zero),
    .negative(negative),
    .overflow(overflow),
    .div_zero(div_zero),

    .valid(valid)
  );

  // ============================================================
  // CLOCK
  // ============================================================

  initial begin
    clk = 1'b0;

    forever
      #5 clk = ~clk;
  end

  // ============================================================
  // WAVEFORM
  // ============================================================

  initial begin
    $dumpfile("a.vcd");
    $dumpvars(0, tb);
  end

  // ============================================================
  // RANDOM VALUE GENERATOR
  //
  // WIDTH = 32 for the current ALU 4.0_32 experiment.
  // ============================================================

  function automatic [WIDTH-1:0] random_value;
    begin
      random_value = $urandom;
    end
  endfunction

  // ============================================================
  // WAIT FOR PIPELINE RESULT
  //
  // Input is applied on a falling edge.
  // The next rising edge enters pipeline stage 0.
  // After PIPELINE_LATENCY rising edges, output is checked.
  // ============================================================

  task automatic wait_for_result;
    begin

      repeat (PIPELINE_LATENCY)
        @(posedge clk);

      #1;

    end
  endtask

  // ============================================================
  // RESET
  // ============================================================

  task automatic reset_dut;
    begin

      reset = 1'b1;

      A      = '0;
      B      = '0;
      opcode = '0;

      repeat (2)
        @(posedge clk);

      reset = 1'b0;

      @(posedge clk);
      #1;

    end
  endtask

  // ============================================================
  // NORMAL SELF TEST
  // ============================================================

  task automatic self_test(
    input logic [WIDTH-1:0] test_A,
    input logic [WIDTH-1:0] test_B,
    input logic [4:0]       test_opcode,

    input logic [WIDTH-1:0] expected_result,

    input logic expected_carry,
    input logic expected_borrow,
    input logic expected_zero,
    input logic expected_negative,
    input logic expected_overflow
  );

    begin

      self_test_count = self_test_count + 1;

      @(negedge clk);

      A      = test_A;
      B      = test_B;
      opcode = test_opcode;

      wait_for_result;

      if (
        valid &&
        result   == expected_result &&
        carry    == expected_carry &&
        borrow   == expected_borrow &&
        zero     == expected_zero &&
        negative == expected_negative &&
        overflow == expected_overflow
      ) begin

        self_pass_count = self_pass_count + 1;

        $display(
          "SELF %0d PASS | A=%h B=%h OPCODE=%b | RESULT=%h C=%b B=%b Z=%b N=%b O=%b",
          self_test_count,
          test_A,
          test_B,
          test_opcode,
          result,
          carry,
          borrow,
          zero,
          negative,
          overflow
        );

      end
      else begin

        self_fail_count = self_fail_count + 1;

        $display(
          "SELF %0d FAIL | A=%h B=%h OPCODE=%b | ACT=%h C=%b B=%b Z=%b N=%b O=%b V=%b | EXP=%h C=%b B=%b Z=%b N=%b O=%b",
          self_test_count,
          test_A,
          test_B,
          test_opcode,
          result,
          carry,
          borrow,
          zero,
          negative,
          overflow,
          valid,
          expected_result,
          expected_carry,
          expected_borrow,
          expected_zero,
          expected_negative,
          expected_overflow
        );

      end

    end

  endtask

  // ============================================================
  // MULTIPLICATION SELF TEST
  // ============================================================

  task automatic self_mul_test(
    input logic [WIDTH-1:0] test_A,
    input logic [WIDTH-1:0] test_B,
    input logic [(2*WIDTH)-1:0] expected_product
  );

    begin

      self_test_count = self_test_count + 1;

      @(negedge clk);

      A      = test_A;
      B      = test_B;
      opcode = 5'b10000;

      wait_for_result;

      if (
        valid &&
        product == expected_product
      ) begin

        self_pass_count = self_pass_count + 1;

        $display(
          "SELF MUL %0d PASS | A=%h B=%h | PRODUCT=%h",
          self_test_count,
          test_A,
          test_B,
          product
        );

      end
      else begin

        self_fail_count = self_fail_count + 1;

        $display(
          "SELF MUL %0d FAIL | A=%h B=%h | ACT=%h | EXP=%h",
          self_test_count,
          test_A,
          test_B,
          product,
          expected_product
        );

      end

    end

  endtask

  // ============================================================
  // DIVISION SELF TEST
  // ============================================================

  task automatic self_div_test(
    input logic [WIDTH-1:0] test_A,
    input logic [WIDTH-1:0] test_B,
    input logic [WIDTH-1:0] expected_quotient,
    input logic [WIDTH-1:0] expected_remainder,
    input logic expected_div_zero
  );

    begin

      self_test_count = self_test_count + 1;

      @(negedge clk);

      A      = test_A;
      B      = test_B;
      opcode = 5'b10001;

      wait_for_result;

      if (
        valid &&
        quotient == expected_quotient &&
        remainder == expected_remainder &&
        div_zero == expected_div_zero
      ) begin

        self_pass_count = self_pass_count + 1;

        $display(
          "SELF DIV %0d PASS | A=%h B=%h | Q=%h R=%h DIV0=%b",
          self_test_count,
          test_A,
          test_B,
          quotient,
          remainder,
          div_zero
        );

      end
      else begin

        self_fail_count = self_fail_count + 1;

        $display(
          "SELF DIV %0d FAIL | A=%h B=%h | ACT Q=%h R=%h D=%b | EXP Q=%h R=%h D=%b",
          self_test_count,
          test_A,
          test_B,
          quotient,
          remainder,
          div_zero,
          expected_quotient,
          expected_remainder,
          expected_div_zero
        );

      end

    end

  endtask

  // ============================================================
  // RANDOM LOGICAL TEST
  //
  // Tests:
  // AND
  // OR
  // XOR
  // NOT
  // LSR
  // LSL
  // ASR
  // NAND
  // NOR
  // XNOR
  // SLT
  // PASS_B
  // ============================================================

  task automatic random_logic_test;

    logic [WIDTH-1:0] random_A;
    logic [WIDTH-1:0] random_B;

    logic [WIDTH-1:0] expected_result;

    logic expected_carry;
    logic expected_borrow;
    logic expected_zero;
    logic expected_negative;
    logic expected_overflow;

    begin

      random_test_count = random_test_count + 1;

      @(negedge clk);

      random_A = random_value();
      random_B = random_value();

      A = random_A;
      B = random_B;

      case ($urandom_range(0,11))
        0:  opcode = 5'b00010;
        1:  opcode = 5'b00011;
        2:  opcode = 5'b00100;
        3:  opcode = 5'b00101;
        4:  opcode = 5'b00110;
        5:  opcode = 5'b00111;
        6:  opcode = 5'b01000;
        7:  opcode = 5'b01011;
        8:  opcode = 5'b01100;
        9:  opcode = 5'b01101;
        10: opcode = 5'b01110;
        11: opcode = 5'b01111;
    endcase
      // Defaults
      expected_result   = '0;
      expected_carry    = 1'b0;
      expected_borrow   = 1'b0;
      expected_overflow = 1'b0;

      case (opcode)

        // AND
        5'b00010:
          expected_result = random_A & random_B;

        // OR
        5'b00011:
          expected_result = random_A | random_B;

        // XOR
        5'b00100:
          expected_result = random_A ^ random_B;

        // NOT A
        5'b00101:
          expected_result = ~random_A;

        // LOGICAL RIGHT SHIFT
        5'b00110:
          expected_result = random_A >> random_B;

        // LEFT SHIFT
        5'b00111:
          expected_result = random_A << random_B;

        // ARITHMETIC RIGHT SHIFT
        5'b01000:
          expected_result = $signed(random_A) >>> random_B;

        // NAND
        5'b01011:
          expected_result = ~(random_A & random_B);

        // NOR
        5'b01100:
          expected_result = ~(random_A | random_B);

        // XNOR
        5'b01101:
          expected_result = ~(random_A ^ random_B);

        // SLT
        //
        // ALU uses unsigned comparison:
        // A < B
        //
        5'b01110:
          expected_result =
            ($signed(random_A) < $signed(random_B))
            ? {{(WIDTH-1){1'b0}},1'b1}
            : '0;

        // PASS B
        5'b01111:
          expected_result = random_B;

        default:
          expected_result = '0;

      endcase

      expected_zero     = (expected_result == '0);
      expected_negative = expected_result[WIDTH-1];

      wait_for_result;

      if (
        valid &&
        result   == expected_result &&
        carry    == expected_carry &&
        borrow   == expected_borrow &&
        zero     == expected_zero &&
        negative == expected_negative &&
        overflow == expected_overflow
      ) begin

        random_pass_count = random_pass_count + 1;

      end
      else begin

        random_fail_count = random_fail_count + 1;

        $display(
          "RANDOM LOGIC FAIL %0d | A=%h B=%h OP=%b | ACT=%h C=%b B=%b Z=%b N=%b O=%b | EXP=%h C=%b B=%b Z=%b N=%b O=%b",
          random_test_count,
          random_A,
          random_B,
          opcode,
          result,
          carry,
          borrow,
          zero,
          negative,
          overflow,
          expected_result,
          expected_carry,
          expected_borrow,
          expected_zero,
          expected_negative,
          expected_overflow
        );

      end

    end

  endtask

  // ============================================================
  // RANDOM MULTIPLICATION TEST
  // ============================================================

  task automatic random_mul_test;

    logic [WIDTH-1:0] random_A;
    logic [WIDTH-1:0] random_B;

    logic [(2*WIDTH)-1:0] expected_product;

    begin

      random_test_count = random_test_count + 1;

      @(negedge clk);

      random_A = random_value();
      random_B = random_value();

      A      = random_A;
      B      = random_B;
      opcode = 5'b10000;

      expected_product = random_A * random_B;

      wait_for_result;

      if (
        valid &&
        product == expected_product
      ) begin

        random_pass_count = random_pass_count + 1;

      end
      else begin

        random_fail_count = random_fail_count + 1;

        $display(
          "RANDOM MUL FAIL %0d | A=%h B=%h | ACT=%h | EXP=%h",
          random_test_count,
          random_A,
          random_B,
          product,
          expected_product
        );

      end

    end

  endtask

  // ============================================================
  // RANDOM DIVISION TEST
  // ============================================================

  task automatic random_div_test;

    logic [WIDTH-1:0] random_A;
    logic [WIDTH-1:0] random_B;

    logic [WIDTH-1:0] expected_quotient;
    logic [WIDTH-1:0] expected_remainder;

    logic expected_div_zero;

    begin

      random_test_count = random_test_count + 1;

      @(negedge clk);

      random_A = random_value();
      random_B = random_value();

      A      = random_A;
      B      = random_B;
      opcode = 5'b10001;

      if (random_B == '0) begin

        expected_quotient  = '0;
        expected_remainder = '0;
        expected_div_zero  = 1'b1;

      end
      else begin

        expected_quotient  = random_A / random_B;
        expected_remainder = random_A % random_B;
        expected_div_zero  = 1'b0;

      end

      wait_for_result;

      if (
        valid &&
        quotient == expected_quotient &&
        remainder == expected_remainder &&
        div_zero == expected_div_zero
      ) begin

        random_pass_count = random_pass_count + 1;

      end
      else begin

        random_fail_count = random_fail_count + 1;

        $display(
          "RANDOM DIV FAIL %0d | A=%h B=%h | ACT Q=%h R=%h D=%b | EXP Q=%h R=%h D=%b",
          random_test_count,
          random_A,
          random_B,
          quotient,
          remainder,
          div_zero,
          expected_quotient,
          expected_remainder,
          expected_div_zero
        );

      end

    end

  endtask

  // ============================================================
  // RANDOM ADD / SUB / INC / DEC
  // ============================================================

  task automatic random_arithmetic_test;

    logic [WIDTH-1:0] random_A;
    logic [WIDTH-1:0] random_B;

    logic [WIDTH-1:0] expected_result;

    logic expected_carry;
    logic expected_borrow;
    logic expected_zero;
    logic expected_negative;
    logic expected_overflow;

    logic [WIDTH:0] temp;

    integer selected_operation;

    begin

      random_test_count = random_test_count + 1;

      @(negedge clk);

      random_A = random_value();
      random_B = random_value();

      A = random_A;
      B = random_B;

      selected_operation = $urandom_range(0,3);

      case (selected_operation)

        0:
          opcode = 5'b00000; // ADD

        1:
          opcode = 5'b00001; // SUB

        2:
          opcode = 5'b01001; // INC

        3:
          opcode = 5'b01010; // DEC

      endcase

      // Default flags
      expected_result   = '0;
      expected_carry    = 1'b0;
      expected_borrow   = 1'b0;
      expected_overflow = 1'b0;

      case (opcode)

        // ======================================================
        // ADD
        // ======================================================

        5'b00000: begin

          temp =
            {1'b0,random_A} +
            {1'b0,random_B};

          expected_result = temp[WIDTH-1:0];

          expected_carry = temp[WIDTH];

          expected_overflow =
            (~random_A[WIDTH-1] &
             ~random_B[WIDTH-1] &
              expected_result[WIDTH-1]) |

            ( random_A[WIDTH-1] &
              random_B[WIDTH-1] &
             ~expected_result[WIDTH-1]);

        end

        // ======================================================
        // SUB
        // ======================================================

        5'b00001: begin

          expected_result = random_A - random_B;

          expected_borrow =
            (random_A < random_B);

          expected_overflow =
            (~random_A[WIDTH-1] &
              random_B[WIDTH-1] &
              expected_result[WIDTH-1]) |

            ( random_A[WIDTH-1] &
             ~random_B[WIDTH-1] &
             ~expected_result[WIDTH-1]);

        end

        // ======================================================
        // INC A
        // ======================================================

        5'b01001: begin

          temp =
            {1'b0,random_A} +
            {{WIDTH{1'b0}},1'b1};

          expected_result = temp[WIDTH-1:0];

          expected_carry = temp[WIDTH];

          // Signed overflow:
          //
          // Positive maximum + 1
          // becomes negative.
          //
          expected_overflow =
            (~random_A[WIDTH-1] &
              expected_result[WIDTH-1]);

        end

        // ======================================================
        // DEC A
        // ======================================================

        5'b01010: begin

          expected_result =
            random_A - {{(WIDTH-1){1'b0}},1'b1};

          expected_borrow =
            (random_A == '0);

          // Signed overflow:
          //
          // Most-negative value - 1
          // becomes positive.
          //
          expected_overflow =
            (random_A[WIDTH-1] &
             ~expected_result[WIDTH-1]);

        end

      endcase

      expected_zero =
        (expected_result == '0);

      expected_negative =
        expected_result[WIDTH-1];

      wait_for_result;

      if (
        valid &&
        result   == expected_result &&
        carry    == expected_carry &&
        borrow   == expected_borrow &&
        zero     == expected_zero &&
        negative == expected_negative &&
        overflow == expected_overflow
      ) begin

        random_pass_count = random_pass_count + 1;

      end
      else begin

        random_fail_count = random_fail_count + 1;

        $display(
          "RANDOM ARITH FAIL %0d | A=%h B=%h OP=%b | ACT=%h C=%b B=%b Z=%b N=%b O=%b | EXP=%h C=%b B=%b Z=%b N=%b O=%b",
          random_test_count,
          random_A,
          random_B,
          opcode,
          result,
          carry,
          borrow,
          zero,
          negative,
          overflow,
          expected_result,
          expected_carry,
          expected_borrow,
          expected_zero,
          expected_negative,
          expected_overflow
        );

      end

    end

  endtask

  // ============================================================
  // MAIN TEST SEQUENCE
  // ============================================================

  initial begin

    A      = '0;
    B      = '0;
    opcode = '0;
    reset  = 1'b0;

    // ----------------------------------------------------------
    // RESET
    // ----------------------------------------------------------

    reset_dut;

    // ==========================================================
    // 1. ADD
    // ==========================================================

    self_test(
      32'h00000003,
      32'h00000002,
      5'b00000,
      32'h00000005,
      1'b0,
      1'b0,
      1'b0,
      1'b0,
      1'b0
    );

    // ADD unsigned carry
    //
    // FFFFFFFF + 1 = 00000000
    //

    self_test(
      32'hFFFFFFFF,
      32'h00000001,
      5'b00000,
      32'h00000000,
      1'b1,
      1'b0,
      1'b1,
      1'b0,
      1'b0
    );

    // ADD signed overflow
    //
    // 7FFFFFFF + 1 = 80000000
    //

    self_test(
      32'h7FFFFFFF,
      32'h00000001,
      5'b00000,
      32'h80000000,
      1'b0,
      1'b0,
      1'b0,
      1'b1,
      1'b1
    );

    // ==========================================================
    // 2. SUB
    // ==========================================================

    self_test(
      32'h00000004,
      32'h00000002,
      5'b00001,
      32'h00000002,
      1'b0,
      1'b0,
      1'b0,
      1'b0,
      1'b0
    );

    // SUB borrow
    //
    // 2 - 4 = FFFFFFFE
    //

    self_test(
      32'h00000002,
      32'h00000004,
      5'b00001,
      32'hFFFFFFFE,
      1'b0,
      1'b1,
      1'b0,
      1'b1,
      1'b0
    );

    // SUB zero

    self_test(
      32'h00000005,
      32'h00000005,
      5'b00001,
      32'h00000000,
      1'b0,
      1'b0,
      1'b1,
      1'b0,
      1'b0
    );

    // ==========================================================
    // 3. AND
    // ==========================================================

    self_test(
      32'h0000000C,
      32'h0000000A,
      5'b00010,
      32'h00000008,
      1'b0,
      1'b0,
      1'b0,
      1'b0,
      1'b0
    );

    // ==========================================================
    // 4. OR
    // ==========================================================

    self_test(
      32'h0000000C,
      32'h0000000A,
      5'b00011,
      32'h0000000E,
      1'b0,
      1'b0,
      1'b0,
      1'b0,
      1'b0
    );

    // ==========================================================
    // 5. XOR
    // ==========================================================

    self_test(
      32'h0000000C,
      32'h0000000A,
      5'b00100,
      32'h00000006,
      1'b0,
      1'b0,
      1'b0,
      1'b0,
      1'b0
    );

    // ==========================================================
    // 6. NOT
    //
    // ~00000005 = FFFFFFFA
    // ==========================================================

    self_test(
      32'h00000005,
      32'h00000000,
      5'b00101,
      32'hFFFFFFFA,
      1'b0,
      1'b0,
      1'b0,
      1'b1,
      1'b0
    );

    // ==========================================================
    // 7. RIGHT SHIFT
    // ==========================================================

    self_test(
      32'h0000000C,
      32'h00000002,
      5'b00110,
      32'h00000003,
      1'b0,
      1'b0,
      1'b0,
      1'b0,
      1'b0
    );

    // ==========================================================
    // 8. LEFT SHIFT
    // ==========================================================

    self_test(
      32'h00000003,
      32'h00000001,
      5'b00111,
      32'h00000006,
      1'b0,
      1'b0,
      1'b0,
      1'b0,
      1'b0
    );

    // ==========================================================
    // 9. ARITHMETIC RIGHT SHIFT
    //
    // 12 >>> 2 = 3
    // ==========================================================

    self_test(
      32'h0000000C,
      32'h00000002,
      5'b01000,
      32'h00000003,
      1'b0,
      1'b0,
      1'b0,
      1'b0,
      1'b0
    );

    // ==========================================================
    // 10. INC
    //
    // 15 + 1 = 16
    // ==========================================================

    self_test(
      32'h0000000F,
      32'h00000000,
      5'b01001,
      32'h00000010,
      1'b0,
      1'b0,
      1'b0,
      1'b0,
      1'b0
    );

    // ==========================================================
    // 11. DEC
    //
    // 0 - 1 = FFFFFFFF
    // ==========================================================

    self_test(
      32'h00000000,
      32'h00000000,
      5'b01010,
      32'hFFFFFFFF,
      1'b0,
      1'b1,
      1'b0,
      1'b1,
      1'b0
    );

    // ==========================================================
    // 12. NAND
    //
    // ~(C & A) = ~8 = FFFFFFF7
    // ==========================================================

    self_test(
      32'h0000000C,
      32'h0000000A,
      5'b01011,
      32'hFFFFFFF7,
      1'b0,
      1'b0,
      1'b0,
      1'b1,
      1'b0
    );

    // ==========================================================
    // 13. NOR
    //
    // ~(C | A) = ~E = FFFFFFF1
    // ==========================================================

    self_test(
      32'h0000000C,
      32'h0000000A,
      5'b01100,
      32'hFFFFFFF1,
      1'b0,
      1'b0,
      1'b0,
      1'b1,
      1'b0
    );

    // ==========================================================
    // 14. XNOR
    //
    // ~(5 ^ 2) = ~7 = FFFFFFF8
    // ==========================================================

    self_test(
      32'h00000005,
      32'h00000002,
      5'b01101,
      32'hFFFFFFF8,
      1'b0,
      1'b0,
      1'b0,
      1'b1,
      1'b0
    );

    // ==========================================================
    // 15. SLT
    //
    // 13 < 2 = FALSE
    // ==========================================================

    self_test(
      32'h0000000D,
      32'h00000002,
      5'b01110,
      32'h00000000,
      1'b0,
      1'b0,
      1'b1,
      1'b0,
      1'b0
    );

    // 2 < 13 = TRUE

    self_test(
      32'h00000002,
      32'h0000000D,
      5'b01110,
      32'h00000001,
      1'b0,
      1'b0,
      1'b0,
      1'b0,
      1'b0
    );

    // ==========================================================
    // 16. PASS B
    // ==========================================================

    self_test(
      32'h00000007,
      32'h00000002,
      5'b01111,
      32'h00000002,
      1'b0,
      1'b0,
      1'b0,
      1'b0,
      1'b0
    );

    // ==========================================================
    // MULTIPLICATION
    // ==========================================================

    self_mul_test(
      32'h00000007,
      32'h0000000A,
      64'h0000000000000046
    );

    self_mul_test(
      32'h0000000F,
      32'h0000000F,
      64'h00000000000000E1
    );

    self_mul_test(
      32'h0000000F,
      32'h00000000,
      64'h0000000000000000
    );

    // ==========================================================
    // DIVISION
    // ==========================================================

    self_div_test(
      32'h00000006,
      32'h0000000A,
      32'h00000000,
      32'h00000006,
      1'b0
    );

    self_div_test(
      32'h0000000F,
      32'h0000000F,
      32'h00000001,
      32'h00000000,
      1'b0
    );

    self_div_test(
      32'h0000000D,
      32'h00000000,
      32'h00000000,
      32'h00000000,
      1'b1
    );

    self_div_test(
      32'h0000000E,
      32'h0000000A,
      32'h00000001,
      32'h00000004,
      1'b0
    );

    // ==========================================================
    // RANDOM LOGICAL TESTS
    // 100 tests
    // ==========================================================

    repeat (100)
      random_logic_test;

    // ==========================================================
    // RANDOM MULTIPLICATION
    // 50 tests
    // ==========================================================

    repeat (50)
      random_mul_test;

    // ==========================================================
    // RANDOM DIVISION
    // 50 tests
    // ==========================================================

    repeat (50)
      random_div_test;

    // ==========================================================
    // RANDOM ADD / SUB / INC / DEC
    // 100 tests
    // ==========================================================

    repeat (100)
      random_arithmetic_test;

    // ==========================================================
    // SUMMARY
    // ==========================================================

    $display("");
    $display("==========================================================");
    $display("              ALU 4.0 PIPELINED TEST SUMMARY");
    $display("==========================================================");

    $display(
      "SELF TESTS   : TOTAL=%0d PASSED=%0d FAILED=%0d",
      self_test_count,
      self_pass_count,
      self_fail_count
    );

    $display(
      "RANDOM TESTS : TOTAL=%0d PASSED=%0d FAILED=%0d",
      random_test_count,
      random_pass_count,
      random_fail_count
    );

    $display("==========================================================");

    if (
      self_fail_count == 0 &&
      random_fail_count == 0
    ) begin

      $display("");
      $display("******************************************************");
      $display("              ALL TESTS PASSED");
      $display("******************************************************");
      $display("");

    end
    else begin

      $display("");
      $display("******************************************************");
      $display("              SOME TESTS FAILED");
      $display("******************************************************");
      $display("");

    end

    #20;

    $finish;

  end

endmodule