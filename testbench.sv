module tb #(parameter WIDTH=4); 
  logic [(2*WIDTH)-1:0] product;
  logic [WIDTH-1:0] A,B,result,quotient,remainder; 
  logic [4:0] opcode; 
  logic carry,borrow,zero,negative,overflow,div_zero; 
  integer self_test_count = 0, self_pass_count =0, self_fail_count =0;
  integer random_test_count = 0, random_pass_count =0, random_fail_count =0;
  ALU #(.WIDTH(WIDTH)) dut(
    .A(A),
    .B(B),
    .opcode(opcode),
    .result(result),
    .product(product),
    .quotient(quotient),
    .remainder(remainder),
    .carry(carry),
    .borrow(borrow),
    .zero(zero),
    .negative(negative),
    .overflow(overflow),
    .div_zero(div_zero)
  ); 
  initial begin 
    $dumpfile("a.vcd"); 
    $dumpvars(0,tb); 
    $monitor($time," A=%b B=%b opcode=%b result=%b product=%b quotient=%b remainder=%b carry=%b borrow=%b zero=%b negative=%b overflow=%b div_zero=%b ",A,B,opcode,result,product,quotient,remainder,carry,borrow,zero,negative,overflow,div_zero); 

    // Monitor-based

    // 1. ADD : opcode = 00000
    // Normal addition
    A=4'b0011; 
    B=4'b0010; 
    opcode=5'b00000; 
    #1;
    // Carry + Zero
    A=4'b1111; 
    B=4'b0001; 
    opcode=5'b00000; 
    #1;
    // Signed positive overflow
    A=4'b0111; 
    B=4'b0001; 
    opcode=5'b00000; 
    #1;
    // Signed negative overflow
    A=4'b1000; 
    B=4'b1000; 
    opcode=5'b00000; 
    #1;
    // 2. SUB : opcode = 00001
    // Normal subtraction
    A=4'b0100; 
    B=4'b0010; 
    opcode=5'b00001; 
    #1;
    // Borrow
    A=4'b0010; 
    B=4'b0100; 
    opcode=5'b00001; 
    #1;
    // Result zero
    A=4'b0101; 
    B=4'b0101; 
    opcode=5'b00001; 
    #1;
    // Signed overflow +7 - (-1) = +8
    A=4'b0111; 
    B=4'b1111; 
    opcode=5'b00001; 
    #1;
    // 3. AND : opcode = 00010
    // Normal AND
    A=4'b1100; 
    B=4'b1010; 
    opcode=5'b00010; 
    #1;
    // Zero result
    A=4'b1010; 
    B=4'b0101; 
    opcode=5'b00010; 
    #1;
    // 4. OR : opcode = 00011
    // Normal OR
    A=4'b0100; 
    B=4'b0011; 
    opcode=5'b00011; 
    #1;
    // Negative result
    A=4'b1000; 
    B=4'b0001; 
    opcode=5'b00011; 
    #1;
    // 5. XOR : opcode = 00100
    // Normal XOR
    A=4'b1100; 
    B=4'b1010; 
    opcode=5'b00100; 
    #1;
    // Zero result
    A=4'b1111; 
    B=4'b1111; 
    opcode=5'b00100; 
    #1;
    // 6. NOT_A : opcode = 00101
    // Normal NOT
    A=4'b0110; 
    B=4'b0000; 
    opcode=5'b00101; 
    #1;
    // Result becomes zero
    A=4'b1111; 
    B=4'b0000; 
    opcode=5'b00101; 
    #1;
    // 7. RIGHT_SHIFT : opcode = 00110
    // Normal right shift
    A=4'b1100; 
    B=4'b0010; 
    opcode=5'b00110; 
    #1;
    // Shift until zero
    A=4'b1000; 
    B=4'b0011; 
    opcode=5'b00110; 
    #1;
    // 8. LEFT_SHIFT : opcode = 00111
    // Normal left shift
    A=4'b0011; 
    B=4'b0001; 
    opcode=5'b00111; 
    #1;
    // Negative result
    A=4'b0100; 
    B=4'b0001; 
    opcode=5'b00111; 
    #1;
    // 9. ARITHMETIC_RIGHT_SHIFT : opcode = 01000
    // Positive number
    A=4'b0100; 
    B=4'b0010; 
    opcode=5'b01000; 
    #1;
    // Negative number - arithmetic shift preserves sign
    A=4'b1100; 
    B=4'b0010; 
    opcode=5'b01000; 
    #1;
    // 10. INC_A : opcode = 01001
    // Normal increment
    A=4'b0100; 
    B=4'b0000; 
    opcode=5'b01001; 
    #1;
    // Carry + Zero
    A=4'b1111; 
    B=4'b0000; 
    opcode=5'b01001; 
    #1;
    // Signed overflow
    A=4'b0111; 
    B=4'b0000; 
    opcode=5'b01001; 
    #1;
    // 11. DEC_A : opcode = 01010
    // Normal decrement
    A=4'b0101; 
    B=4'b0000; 
    opcode=5'b01010; 
    #1;
    // Borrow + Negative
    A=4'b0000; 
    B=4'b0000; 
    opcode=5'b01010; 
    #1;
    // Signed overflow
    A=4'b1000; 
    B=4'b0000; 
    opcode=5'b01010; 
    #1;
    // 12. NAND : opcode = 01011
    // Normal NAND
    A=4'b0101; 
    B=4'b0011; 
    opcode=5'b01011; 
    #1;
    // Zero-input combination
    A=4'b1111; 
    B=4'b1111; 
    opcode=5'b01011; 
    #1;
    // 13. NOR : opcode = 01100
    // Normal NOR
    A=4'b1100; 
    B=4'b1010; 
    opcode=5'b01100; 
    #1;
    // Zero result
    A=4'b1111; 
    B=4'b0000; 
    opcode=5'b01100; 
    #1;
    // 14. XNOR : opcode = 01101
    // Normal XNOR
    A=4'b0101; 
    B=4'b0010; 
    opcode=5'b01101; 
    #1;
    // All bits equal -> all 1
    A=4'b1010; 
    B=4'b1010; 
    opcode=5'b01101; 
    #1;
    // 15. SLT : opcode = 01110
    // Signed: -3 < +2 -> result = 1
    A=4'b1101; 
    B=4'b0010; 
    opcode=5'b01110; 
    #1;
    // Signed: +3 < +2 is false -> result = 0
    A=4'b0011; 
    B=4'b0010; 
    opcode=5'b01110; 
    #1;
    // 16. PASS_B : opcode = 01111
    // Normal pass
    A=4'b0111; 
    B=4'b0010; 
    opcode=5'b01111; 
    #1;
    // Pass negative value
    A=4'b0011; 
    B=4'b1000; 
    opcode=5'b01111; 
    #1;
    // 17. MUL : opcode = 10000
    // Normal multiplication: 7 × 10 = 70
    A=4'b0111;  
    B=4'b1010;  
    opcode=5'b10000;  
    #1; 
    // Maximum 4-bit values: 15 × 15 = 225
    A=4'b1111;  
    B=4'b1111;  
    opcode=5'b10000;  
    #1; 
    // Multiplication by zero: 15 × 0 = 0
    A=4'b1111;  
    B=4'b0000;  
    opcode=5'b10000;  
    #1; 
    // 18. DIV : opcode = 10001
    // Dividend smaller than divisor: 6 / 10 = 0, remainder = 6
    A=4'b0110;  
    B=4'b1010;  
    opcode=5'b10001;  
    #1; 
    // Exact division: 15 / 15 = 1, remainder = 0
    A=4'b1111;  
    B=4'b1111;  
    opcode=5'b10001;  
    #1; 
    // Division by zero: 13 / 0 → div_zero = 1
    A=4'b1101;  
    B=4'b0000;  
    opcode=5'b10001;  
    #1; 
    // Zero dividend: 0 / 15 = 0, remainder = 0
    A=4'b0000;  
    B=4'b1111;  
    opcode=5'b10001;  
    #1; 
    // Both dividend and divisor zero: 0 / 0 → div_zero = 1
    A=4'b0000;  
    B=4'b0000;  
    opcode=5'b10001;  
    #1; 
    // Division with remainder: 14 / 10 = 1, remainder = 4
    A=4'b1110;  
    B=4'b1010;  
    opcode=5'b10001;  
    #1;
 
	// Self-checking
    
    // CORRECT SELF-CHECKING TESTS

    // ADD: 15 + 1 = 0, carry = 1, zero = 1
    self_test(4'b1111,4'b0001,5'b00000,4'b0000,1'b1,1'b0,1'b1,1'b0,1'b0);
    // ADD: 7 + 1 = 1000, signed overflow
    self_test(4'b0111,4'b0001,5'b00000,4'b1000,1'b0,1'b0,1'b0,1'b1,1'b1);
    // ADD: -8 + -8 = 0, carry = 1, signed overflow
    self_test(4'b1000,4'b1000,5'b00000,4'b0000,1'b1,1'b0,1'b1,1'b0,1'b1);
    // SUB: 2 - 4 = 1110, borrow = 1
    self_test(4'b0010,4'b0100,5'b00001,4'b1110,1'b0,1'b1,1'b0,1'b1,1'b0);
    // LEFT SHIFT: 0100 << 1 = 1000
    self_test(4'b0100,4'b0001,5'b00111,4'b1000,1'b0,1'b0,1'b0,1'b1,1'b0);
    // SUB: 5 - 5 = 0, zero = 1
    self_test(4'b0101,4'b0101,5'b00001,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // SUB: 7 - (-1) = 8, borrow = 1, signed overflow
    self_test(4'b0111,4'b1111,5'b00001,4'b1000,1'b0,1'b1,1'b0,1'b1,1'b1);
    // INC: 15 + 1 = 0, carry = 1, zero = 1
    self_test(4'b1111,4'b0000,5'b01001,4'b0000,1'b1,1'b0,1'b1,1'b0,1'b0);
    // XOR: 1111 ^ 1111 = 0, zero = 1
    self_test(4'b1111,4'b1111,5'b00100,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // INC: 7 + 1 = 1000, signed overflow
    self_test(4'b0111,4'b0000,5'b01001,4'b1000,1'b0,1'b0,1'b0,1'b1,1'b1);
    // DEC: 0 - 1 = 1111, borrow = 1, negative = 1
    self_test(4'b0000,4'b0000,5'b01010,4'b1111,1'b0,1'b1,1'b0,1'b1,1'b0);
    // SLT signed: -3 < +2 = true
    self_test(4'b1101,4'b0010,5'b01110,4'b0001,1'b0,1'b0,1'b0,1'b0,1'b0);
    // AND: 1100 & 1010 = 1000, negative = 1
    self_test(4'b1100,4'b1010,5'b00010,4'b1000,1'b0,1'b0,1'b0,1'b1,1'b0);
    // AND: 1111 & 0000 = 0000, zero = 1
    self_test(4'b1111,4'b0000,5'b00010,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // OR: 1100 | 1010 = 1110, negative = 1
    self_test(4'b1100,4'b1010,5'b00011,4'b1110,1'b0,1'b0,1'b0,1'b1,1'b0);
    // OR: 0000 | 0000 = 0000, zero = 1
    self_test(4'b0000,4'b0000,5'b00011,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // NOT_A: ~0101 = 1010, negative = 1
    self_test(4'b0101,4'b0000,5'b00101,4'b1010,1'b0,1'b0,1'b0,1'b1,1'b0);
    // NOT_A: ~1111 = 0000, zero = 1
    self_test(4'b1111,4'b0000,5'b00101,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // RIGHT_SHIFT: 1100 >> 2 = 0011, logical shift
    self_test(4'b1100,4'b0010,5'b00110,4'b0011,1'b0,1'b0,1'b0,1'b0,1'b0);
    // RIGHT_SHIFT: 1000 >> 1 = 0100, zero-fill from left
    self_test(4'b1000,4'b0001,5'b00110,4'b0100,1'b0,1'b0,1'b0,1'b0,1'b0);
    // ARITHMETIC_RIGHT_SHIFT: 1100 >>> 2 = 1111, sign extension
    self_test(4'b1100,4'b0010,5'b01000,4'b1111,1'b0,1'b0,1'b0,1'b1,1'b0);
    // ARITHMETIC_RIGHT_SHIFT: 0100 >>> 2 = 0001, positive number
    self_test(4'b0100,4'b0010,5'b01000,4'b0001,1'b0,1'b0,1'b0,1'b0,1'b0);
    // NAND: ~(1100 & 1010) = ~1000 = 0111
    self_test(4'b1100,4'b1010,5'b01011,4'b0111,1'b0,1'b0,1'b0,1'b0,1'b0);
    // NAND: ~(1111 & 1111) = 0000, zero = 1
    self_test(4'b1111,4'b1111,5'b01011,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // NOR: ~(1100 | 1010) = ~1110 = 0001
    self_test(4'b1100,4'b1010,5'b01100,4'b0001,1'b0,1'b0,1'b0,1'b0,1'b0);
    // NOR: ~(0000 | 0000) = 1111, negative = 1
    self_test(4'b0000,4'b0000,5'b01100,4'b1111,1'b0,1'b0,1'b0,1'b1,1'b0);
    // XNOR: ~(0101 ^ 0010) = ~0111 = 1000, negative = 1
    self_test(4'b0101,4'b0010,5'b01101,4'b1000,1'b0,1'b0,1'b0,1'b1,1'b0);
    // XNOR: ~(1010 ^ 1010) = 1111, negative = 1
    self_test(4'b1010,4'b1010,5'b01101,4'b1111,1'b0,1'b0,1'b0,1'b1,1'b0);
    // PASS_B: result should be equal to B = 0010
    self_test(4'b0111,4'b0010,5'b01111,4'b0010,1'b0,1'b0,1'b0,1'b0,1'b0);
    // PASS_B: result should be equal to B = 1000, negative = 1
    self_test(4'b0011,4'b1000,5'b01111,4'b1000,1'b0,1'b0,1'b0,1'b1,1'b0);
    // RIGHT_SHIFT: shift by 0 -> A unchanged
    self_test(4'b1011,4'b0000,5'b00110,4'b1011,1'b0,1'b0,1'b0,1'b1,1'b0);
    // RIGHT_SHIFT: shift by 1
    self_test(4'b1011,4'b0001,5'b00110,4'b0101,1'b0,1'b0,1'b0,1'b0,1'b0);
    // RIGHT_SHIFT: shift by WIDTH-1 = 3
    self_test(4'b1011,4'b0011,5'b00110,4'b0001,1'b0,1'b0,1'b0,1'b0,1'b0);
    // RIGHT_SHIFT: shift by WIDTH = 4 -> result becomes zero
    self_test(4'b1011,4'b0100,5'b00110,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // RIGHT_SHIFT: shift greater than WIDTH -> result becomes zero
    self_test(4'b1011,4'b0101,5'b00110,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // ARITHMETIC_RIGHT_SHIFT: shift by 0 -> A unchanged
    self_test(4'b1100,4'b0000,5'b01000,4'b1100,1'b0,1'b0,1'b0,1'b1,1'b0);
    // ARITHMETIC_RIGHT_SHIFT: negative number shifted by 1 -> sign extension
    self_test(4'b1100,4'b0001,5'b01000,4'b1110,1'b0,1'b0,1'b0,1'b1,1'b0);
    // ARITHMETIC_RIGHT_SHIFT: negative number shifted by WIDTH-1
    self_test(4'b1100,4'b0011,5'b01000,4'b1111,1'b0,1'b0,1'b0,1'b1,1'b0);
    // ARITHMETIC_RIGHT_SHIFT: negative number shifted by WIDTH
    self_test(4'b1100,4'b0100,5'b01000,4'b1111,1'b0,1'b0,1'b0,1'b1,1'b0);
    // ARITHMETIC_RIGHT_SHIFT: negative number shifted greater than WIDTH
    self_test(4'b1100,4'b0101,5'b01000,4'b1111,1'b0,1'b0,1'b0,1'b1,1'b0);
    // ARITHMETIC_RIGHT_SHIFT: positive number shifted by 1
    self_test(4'b0100,4'b0001,5'b01000,4'b0010,1'b0,1'b0,1'b0,1'b0,1'b0);
    // ARITHMETIC_RIGHT_SHIFT: positive number shifted by WIDTH-1
    self_test(4'b0100,4'b0011,5'b01000,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // ARITHMETIC_RIGHT_SHIFT: positive number shifted by WIDTH
    self_test(4'b0100,4'b0100,5'b01000,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // LEFT_SHIFT: shift by 0 -> A unchanged
    self_test(4'b0011,4'b0000,5'b00111,4'b0011,1'b0,1'b0,1'b0,1'b0,1'b0);
    // LEFT_SHIFT: shift by 1
    self_test(4'b0011,4'b0001,5'b00111,4'b0110,1'b0,1'b0,1'b0,1'b0,1'b0);
    // LEFT_SHIFT: shift by WIDTH-1
    self_test(4'b0011,4'b0011,5'b00111,4'b1000,1'b0,1'b0,1'b0,1'b1,1'b0);
    // LEFT_SHIFT: shift by WIDTH -> zero
    self_test(4'b0011,4'b0100,5'b00111,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // LEFT_SHIFT: shift greater than WIDTH -> zero
    self_test(4'b0011,4'b0101,5'b00111,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // INC: -1 + 1 = 0
    self_test(4'b1111,4'b0000,5'b01001,4'b0000,1'b1,1'b0,1'b1,1'b0,1'b0);
    // INC: -8 + 1 = -7
    self_test(4'b1000,4'b0000,5'b01001,4'b1001,1'b0,1'b0,1'b0,1'b1,1'b0);
    // INC: -2 + 1 = -1
    self_test(4'b1110,4'b0000,5'b01001,4'b1111,1'b0,1'b0,1'b0,1'b1,1'b0);
    // DEC: 1 - 1 = 0
    self_test(4'b0001,4'b0000,5'b01010,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // DEC: -1 - 1 = -2
    self_test(4'b1111,4'b0000,5'b01010,4'b1110,1'b0,1'b0,1'b0,1'b1,1'b0);
    // DEC: -8 - 1 = +7, signed overflow
    self_test(4'b1000,4'b0000,5'b01010,4'b0111,1'b0,1'b0,1'b0,1'b0,1'b1);
    // SLT signed: -8 < +7 = true
    self_test(4'b1000,4'b0111,5'b01110,4'b0001,1'b0,1'b0,1'b0,1'b0,1'b0);
    // SLT signed: +7 < -8 = false
    self_test(4'b0111,4'b1000,5'b01110,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // SLT signed: -8 < -1 = true
    self_test(4'b1000,4'b1111,5'b01110,4'b0001,1'b0,1'b0,1'b0,1'b0,1'b0);
    // SLT signed: -1 < -8 = false
    self_test(4'b1111,4'b1000,5'b01110,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // SLT signed: same numbers -> false
    self_test(4'b1000,4'b1000,5'b01110,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // ADD: -8 + -1 = 0111, signed overflow
    self_test(4'b1000,4'b1111,5'b00000,4'b0111,1'b1,1'b0,1'b0,1'b0,1'b1);
    // ADD: +7 + +7 = 1110, signed overflow
    self_test(4'b0111,4'b0111,5'b00000,4'b1110,1'b0,1'b0,1'b0,1'b1,1'b1);
    // ADD: -8 + +7 = -1, no overflow
    self_test(4'b1000,4'b0111,5'b00000,4'b1111,1'b0,1'b0,1'b0,1'b1,1'b0);
    // ADD: -1 + +1 = 0, no overflow
    self_test(4'b1111,4'b0001,5'b00000,4'b0000,1'b1,1'b0,1'b1,1'b0,1'b0);
    // SUB: -8 - 1 = +7, signed overflow
    self_test(4'b1000,4'b0001,5'b00001,4'b0111,1'b0,1'b0,1'b0,1'b0,1'b1);
    // SUB: +7 - (-1) = -8, no overflow
    self_test(4'b0111,4'b1000,5'b00001,4'b1111,1'b0,1'b1,1'b0,1'b1,1'b1);
    // SUB: -8 - (-1) = -7, no overflow
    self_test(4'b1000,4'b1111,5'b00001,4'b1001,1'b0,1'b1,1'b0,1'b1,1'b0);
    // SUB: 0 - 0 = 0
    self_test(4'b0000,4'b0000,5'b00001,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
	
    // INCORRECT SELF-CHECKING TESTS

    // WRONG: 15 + 1 should give 0000, not 0001
    self_test(4'b1111,4'b0001,5'b00000,4'b0001,1'b1,1'b0,1'b0,1'b0,1'b0);
    // WRONG: 7 + 1 should give 1000, not 1001
    self_test(4'b0111,4'b0001,5'b00000,4'b1001,1'b0,1'b0,1'b0,1'b1,1'b1);
    // WRONG: 1000 + 1000 should have carry = 1
    self_test(4'b1000,4'b1000,5'b00000,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b1);
    // WRONG: 2 - 4 should have borrow = 1
    self_test(4'b0010,4'b0100,5'b00001,4'b1110,1'b0,1'b0,1'b0,1'b1,1'b0);
    // WRONG: -3 < +2 should give 0001, not 0000
    self_test(4'b1101,4'b0010,5'b01110,4'b0000,1'b0,1'b0,1'b0,1'b0,1'b0);
    // WRONG: 5 - 5 should give 0000, not 0001
    self_test(4'b0101,4'b0101,5'b00001,4'b0001,1'b0,1'b0,1'b0,1'b0,1'b0);
    // WRONG: 7 - (-1) causes signed overflow = 1
    self_test(4'b0111,4'b1111,5'b00001,4'b1000,1'b0,1'b1,1'b0,1'b1,1'b0);
    // WRONG: 15 + 1 should have carry = 1
    self_test(4'b1111,4'b0000,5'b01001,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // WRONG: 7 + 1 causes signed overflow = 1
    self_test(4'b0111,4'b0000,5'b01001,4'b1000,1'b0,1'b0,1'b0,1'b1,1'b0);
    // WRONG: 3 < 2 is false, so result should be 0000; zero should be 1
    self_test(4'b0011,4'b0010,5'b01110,4'b0001,1'b0,1'b0,1'b0,1'b1,1'b0);
    // WRONG: 0 - 1 should have borrow = 1
    self_test(4'b0000,4'b0000,5'b01010,4'b1111,1'b0,1'b0,1'b0,1'b1,1'b0);
    // WRONG: 1010 & 0101 = 0000, so zero should be 1
    self_test(4'b1010,4'b0101,5'b00010,4'b0000,1'b0,1'b0,1'b0,1'b0,1'b0);
    // WRONG: -3 < +2 is true, so SLT should give 0001
    self_test(4'b1101,4'b0010,5'b01110,4'b0000,1'b0,1'b0,1'b0,1'b0,1'b0);
    // WRONG: 1100 & 1010 should give 1000, not 1010
    self_test(4'b1100,4'b1010,5'b00010,4'b1010,1'b0,1'b0,1'b0,1'b1,1'b0);
    // WRONG: 1111 & 0000 gives 0000, so zero should be 1, not 0
    self_test(4'b1111,4'b0000,5'b00010,4'b0000,1'b0,1'b0,1'b0,1'b0,1'b0);
    // WRONG: 1100 | 1010 should give 1110, not 1100
    self_test(4'b1100,4'b1010,5'b00011,4'b1100,1'b0,1'b0,1'b0,1'b1,1'b0);
    // WRONG: 0000 | 0000 gives 0000, so negative should be 0, not 1
    self_test(4'b0000,4'b0000,5'b00011,4'b0000,1'b0,1'b0,1'b1,1'b1,1'b0);
    // WRONG: ~0101 should give 1010, not 0101
    self_test(4'b0101,4'b0000,5'b00101,4'b0101,1'b0,1'b0,1'b0,1'b0,1'b0);
    // WRONG: ~1111 gives 0000, so zero should be 1, not 0
    self_test(4'b1111,4'b0000,5'b00101,4'b0000,1'b0,1'b0,1'b0,1'b0,1'b0);
    // WRONG: 1100 >> 2 should give 0011, not 1100
    self_test(4'b1100,4'b0010,5'b00110,4'b1100,1'b0,1'b0,1'b0,1'b1,1'b0);
    // WRONG: 1000 >> 1 gives 0100, so negative should be 0, not 1
    self_test(4'b1000,4'b0001,5'b00110,4'b0100,1'b0,1'b0,1'b0,1'b1,1'b0);
    // WRONG: 1100 >>> 2 should give 1111, not 0011
    self_test(4'b1100,4'b0010,5'b01000,4'b0011,1'b0,1'b0,1'b0,1'b0,1'b0);
    // WRONG: shift operations do not set overflow in this ALU, so overflow should be 0, not 1
    self_test(4'b0100,4'b0010,5'b01000,4'b0001,1'b0,1'b0,1'b0,1'b0,1'b1);
    // WRONG: ~(1100 & 1010) should give 0111, not 1000
    self_test(4'b1100,4'b1010,5'b01011,4'b1000,1'b0,1'b0,1'b0,1'b1,1'b0);
    // WRONG: ~(1111 & 1111) gives 0000, so zero should be 1, not 0
    self_test(4'b1111,4'b1111,5'b01011,4'b0000,1'b0,1'b0,1'b0,1'b0,1'b0);
    // WRONG: ~(1100 | 1010) should give 0001, not 0000
    self_test(4'b1100,4'b1010,5'b01100,4'b0000,1'b0,1'b0,1'b1,1'b0,1'b0);
    // WRONG: ~(0000 | 0000) gives 1111, so negative should be 1, not 0
    self_test(4'b0000,4'b0000,5'b01100,4'b1111,1'b0,1'b0,1'b0,1'b0,1'b0);
    // WRONG: ~(0101 ^ 0010) should give 1000, not 0111
    self_test(4'b0101,4'b0010,5'b01101,4'b0111,1'b0,1'b0,1'b0,1'b0,1'b0);
    // WRONG: 1010 XNOR 1010 gives 1111, so zero should be 0, not 1
    self_test(4'b1010,4'b1010,5'b01101,4'b1111,1'b0,1'b0,1'b1,1'b1,1'b0);
    // WRONG: PASS_B should give B = 0010, not A = 0111
    self_test(4'b0111,4'b0010,5'b01111,4'b0111,1'b0,1'b0,1'b0,1'b0,1'b0);
    // WRONG: PASS_B gives B = 1000, so negative should be 1, not 0
    self_test(4'b0011,4'b1000,5'b01111,4'b1000,1'b0,1'b0,1'b0,1'b0,1'b0);
    
    // CORRECT MUL SELF-CHECKING TESTS

    // MUL: 7 × 10 = 70 = 01000110
    self_mul_test(4'b0111, 4'b1010, 5'b10000, 8'b01000110);
    // MUL: 15 × 15 = 225 = 11100001
    self_mul_test(4'b1111, 4'b1111, 5'b10000, 8'b11100001);
    // MUL: 15 × 0 = 0 = 00000000
    self_mul_test(4'b1111, 4'b0000, 5'b10000, 8'b00000000);
    
    // INCORRECT MUL SELF-CHECKING TESTS

    // WRONG: 7 × 10 should give 01000110, not 01000111
    self_mul_test(4'b0111, 4'b1010, 5'b10000, 8'b01000111);
    // WRONG: 15 × 15 should give 11100001, not 11100000
    self_mul_test(4'b1111, 4'b1111, 5'b10000, 8'b11100000);
    // WRONG: 15 × 0 should give 00000000, not 00000001
    self_mul_test(4'b1111, 4'b0000, 5'b10000, 8'b00000001);
    
    // CORRECT DIV SELF-CHECKING TESTS

    // DIV: 6 / 10 = 0, remainder = 6
    self_div_test(4'b0110, 4'b1010, 5'b10001,4'b0000, 4'b0110, 1'b0);
    // DIV: 15 / 15 = 1, remainder = 0
    self_div_test(4'b1111, 4'b1111, 5'b10001,4'b0001, 4'b0000, 1'b0);
    // DIV: 13 / 0 → division by zero
    self_div_test(4'b1101, 4'b0000, 5'b10001,4'b0000, 4'b0000, 1'b1);
    // DIV: 0 / 15 = 0, remainder = 0
    self_div_test(4'b0000, 4'b1111, 5'b10001,4'b0000, 4'b0000, 1'b0);
    // DIV: 0 / 0 → division by zero
    self_div_test(4'b0000, 4'b0000, 5'b10001,4'b0000, 4'b0000, 1'b1);
    // DIV: 14 / 10 = 1, remainder = 4
    self_div_test(4'b1110, 4'b1010, 5'b10001,4'b0001, 4'b0100, 1'b0);
    
    // INCORRECT DIV SELF-CHECKING TESTS
    
    // WRONG: 6 / 10 gives quotient 0000 and remainder 0110, not quotient 0001
    self_div_test(4'b0110, 4'b1010, 5'b10001,4'b0001, 4'b0110, 1'b0);
    // WRONG: 15 / 15 gives quotient 0001 and remainder 0000, not quotient 0000
    self_div_test(4'b1111, 4'b1111, 5'b10001,4'b0000, 4'b0000, 1'b0);
    // WRONG: 13 / 0 must set div_zero = 1
    self_div_test(4'b1101, 4'b0000, 5'b10001,4'b0000, 4'b0000, 1'b0);
    // WRONG: 0 / 15 gives remainder 0000, not remainder 0001
    self_div_test(4'b0000, 4'b1111, 5'b10001,4'b0000, 4'b0001, 1'b0);
    // WRONG: 0 / 0 must set div_zero = 1
    self_div_test(4'b0000, 4'b0000, 5'b10001,4'b0000, 4'b0000, 1'b0);
    // WRONG: 14 / 10 gives quotient 0001 and remainder 0100, not remainder 0011
    self_div_test(4'b1110, 4'b1010, 5'b10001,4'b0001, 4'b0011, 1'b0);
    
    repeat (200) begin
        random_test;
    end
    repeat (50) begin
        random_mul_test;
    end
    repeat (50) begin
        random_div_test;
    end
    repeat (100) begin
        random_add_sub_test;
    end
    $display("SELF-CHECKING TEST SUMMARY | TOTAL TESTS : %0d | PASSED : %0d | FAILED : %0d | ",self_test_count,self_pass_count,self_fail_count);
    
    $display("RANDOM-CHECKING TEST SUMMARY | TOTAL TESTS : %0d | PASSED : %0d | FAILED : %0d | ",random_test_count,random_pass_count,random_fail_count);
    
    #5 $finish; 
  end 

  task self_mul_test (
    input logic [WIDTH-1:0] test_A,
    input logic [WIDTH-1:0] test_B,
    input logic [4:0] test_opcode,
    input logic [(2*WIDTH)-1:0] expected_product
);
    begin
      self_test_count = self_test_count + 1;
      A = test_A;
      B = test_B;
      opcode = test_opcode;
      #1;

      if (product == expected_product) begin
        self_pass_count = self_pass_count + 1;
        $display("SELF MUL TEST %0d PASS | A=%b B=%b OPCODE=%b | PRODUCT=%b",
                 self_test_count, test_A, test_B, test_opcode, product);
      end
      else begin
        self_fail_count = self_fail_count + 1;
        $display("SELF MUL TEST %0d FAIL | A=%b B=%b OPCODE=%b | ACTUAL: PRODUCT=%b | EXPECTED: PRODUCT=%b",
                 self_test_count, test_A, test_B, test_opcode, product, expected_product);
      end
    end
  endtask
  
  task self_div_test (
    input logic [WIDTH-1:0] test_A,
    input logic [WIDTH-1:0] test_B,
    input logic [4:0] test_opcode,
  	input logic [WIDTH-1:0] expected_quotient,expected_remainder,
  	input logic expected_div_zero
);
    begin
      self_test_count = self_test_count + 1;
      A = test_A;
      B = test_B;
      opcode = test_opcode;
      #1;
      if ((quotient == expected_quotient) && (remainder == expected_remainder) && (div_zero == expected_div_zero)) begin
        self_pass_count = self_pass_count+1;
        $display("SELF TEST %0d PASS | A=%b B=%b OPCODE=%b | QUOTIENT=%b REMAINDER=%b DIV_ZERO=%b |",self_test_count,test_A,test_B,test_opcode,quotient,remainder,div_zero);
      end
      else begin
        self_fail_count =self_fail_count +1;
        $display("SELF TEST %0d FAIL | A=%b B=%b OPCODE=%b | ACTUAL: QUOTIENT=%b REMAINDER=%b DIV_ZERO=%b | EXPECTED: QUOTIENT=%b REMAINDER=%b DIV_ZERO=%b ",self_test_count,test_A,test_B,test_opcode,quotient,remainder,div_zero,expected_quotient,expected_remainder,expected_div_zero);
      end
	end
  endtask
  
  task self_test (
    input logic [WIDTH-1:0] test_A,
    input logic [WIDTH-1:0] test_B,
    input logic [4:0] test_opcode,

    input logic [WIDTH-1:0] expected_result,
    input logic expected_carry,
    input logic expected_borrow,
    input logic expected_zero,
    input logic expected_negative,
    input logic expected_overflow
);
    begin
      self_test_count = self_test_count + 1;
      A = test_A;
      B = test_B;
      opcode = test_opcode;
      #1;
      if ((result == expected_result) && (carry == expected_carry) && (borrow == expected_borrow) && (zero == expected_zero) && (negative == expected_negative) && (overflow == expected_overflow)) begin
        self_pass_count = self_pass_count+1;
        $display("SELF TEST %0d PASS | A=%b B=%b OPCODE=%b | RESULT=%b | CARRY=%b BORROW=%b ZERO=%b NEGATIVE=%b OVERFLOW=%b",self_test_count,test_A,test_B,test_opcode,result,carry,borrow,zero,negative,overflow);
      end
      else begin
        self_fail_count =self_fail_count +1;
        $display("SELF TEST %0d FAIL | A=%b B=%b OPCODE=%b | ACTUAL: RESULT=%b CARRY=%b BORROW=%b ZERO=%b NEGATIVE=%b OVERFLOW=%b | EXPECTED: RESULT=%b CARRY=%b BORROW=%b ZERO=%b NEGATIVE=%b OVERFLOW=%b",self_test_count,test_A,test_B,test_opcode,result,carry,borrow,zero,negative,overflow,expected_result, expected_carry,expected_borrow,expected_zero,expected_negative,expected_overflow);
      end
	end
  endtask
  task random_test (); 
    logic [WIDTH-1:0] expected_result; 
    logic expected_negative; 
    begin 
        random_test_count = random_test_count + 1; 
        // Generate random inputs
        A = $urandom_range(0, (2**WIDTH)-1); 
        B = $urandom_range(0, (2**WIDTH)-1); 
        // Generate random opcode
        do begin 
            opcode = $urandom_range(0, 15); 
      	end while ((opcode == 5'b00000) ||   // ADD
                   (opcode == 5'b00001) ||   // SUB
                   (opcode == 5'b01001) ||   // INC_A
                   (opcode == 5'b01010));    // DEC_A
        // Default expected values
        expected_result = '0; 
        expected_negative = 1'b0; 
        case(opcode) 
            5'b00010: begin // AND
                expected_result = A & B; 
            end 
            5'b00011: begin // OR
                expected_result = A | B; 
            end 
            5'b00100: begin // XOR
                expected_result = A ^ B; 
            end 
            5'b00101: begin // NOT_A
                expected_result = ~A; 
            end 
            5'b00110: begin // RIGHT_SHIFT
                expected_result = A >> B; 
            end 
            5'b00111: begin // LEFT_SHIFT
                expected_result = A << B; 
            end 
            5'b01000: begin // ARITHMETIC_RIGHT_SHIFT
                expected_result = $signed(A) >>> B; 
            end 
            5'b01011: begin // NAND
                expected_result = ~(A & B); 
            end 
            5'b01100: begin // NOR
                expected_result = ~(A | B); 
            end 
            5'b01101: begin // XNOR
                expected_result = ~(A ^ B); 
            end 
            5'b01110: begin // SLT
                if ($signed(A) < $signed(B)) 
                    expected_result = 1; 
                else 
                    expected_result = 0; 
            end 
            5'b01111: begin // PASS_B
                expected_result = B; 
            end 
        endcase 
        expected_negative = expected_result[WIDTH-1]; 
        #1; 
        if ((result == expected_result) && 
            (negative == expected_negative)) begin 
            random_pass_count = random_pass_count + 1; 
            $display("RANDOM TEST %0d PASS | A=%b B=%b OPCODE=%b | RESULT=%b | NEGATIVE=%b",random_test_count, A, B, opcode, result, negative); 
        end 
        else begin 
            random_fail_count = random_fail_count + 1; 
            $display("RANDOM TEST %0d FAIL | A=%b B=%b OPCODE=%b | ACTUAL: RESULT=%b NEGATIVE=%b | EXPECTED: RESULT=%b NEGATIVE=%b",random_test_count, A, B, opcode,result, negative,expected_result, expected_negative); 
        end 
    end 
endtask
  task random_mul_test ();  
  	logic [(2*WIDTH)-1:0] expected_product; 
    begin 
        random_test_count = random_test_count + 1; 
        A = $urandom_range(0, (2**WIDTH)-1); 
        B = $urandom_range(0, (2**WIDTH)-1); 
        opcode = 5'b10000; 
      	expected_product = A*B;     
        #1; 
      if (product == expected_product)begin 
            random_pass_count = random_pass_count + 1; 
        $display("RANDOM TEST %0d PASS | A=%b B=%b OPCODE=%b | PRODUCT=%b ",random_test_count, A, B, opcode, product); 
        end 
        else begin 
            random_fail_count = random_fail_count + 1; 
          $display("RANDOM TEST %0d FAIL | A=%b B=%b OPCODE=%b | ACTUAL: PRODUCT=%b | EXPECTED: PRODUCT=%b",random_test_count, A, B, opcode,product,expected_product); 
        end 
    end 
endtask
  task random_div_test ();  
  	logic [WIDTH-1:0] expected_quotient,expected_remainder;
  	logic expected_div_zero;
    begin 
        random_test_count = random_test_count + 1; 
        A = $urandom_range(0, (2**WIDTH)-1); 
        B = $urandom_range(0, (2**WIDTH)-1); 
        opcode = 5'b10001; 
      	expected_div_zero = 1'b0;
      	expected_quotient  = '0;
expected_remainder = '0;
      	if (B == 0) begin // Division by zero
          expected_div_zero = 1'b1;
        end
        else begin
          expected_quotient  = A / B;
          expected_remainder = A % B;
        end
        #1; 
        if ((quotient == expected_quotient) && (remainder == expected_remainder) && (div_zero == expected_div_zero)) begin
          random_pass_count = random_pass_count + 1; 
          $display("RANDOM TEST %0d PASS | A=%b B=%b OPCODE=%b | QUOTIENT=%b REMAINDER=%b DIV_ZERO=%b |",random_test_count,A,B,opcode,quotient,remainder,div_zero);
        end 
        else begin 
            random_fail_count = random_fail_count + 1; 
          	$display("RANDOM TEST %0d FAIL | A=%b B=%b OPCODE=%b | ACTUAL: QUOTIENT=%b REMAINDER=%b DIV_ZERO=%b | EXPECTED: QUOTIENT=%b REMAINDER=%b DIV_ZERO=%b ",random_test_count,A,B,opcode,quotient,remainder,div_zero,expected_quotient,expected_remainder,expected_div_zero);
        end 
    end 
endtask
  task random_add_sub_test ();  
    logic [WIDTH-1:0] expected_result;
    logic expected_carry, expected_borrow,expected_zero, expected_negative, expected_overflow;
    begin 
        random_test_count = random_test_count + 1; 
        A = $urandom_range(0, (2**WIDTH)-1); 
        B = $urandom_range(0, (2**WIDTH)-1); 
        case ($urandom_range(0,3))
            0: opcode = 5'b00000;  // ADD
            1: opcode = 5'b00001;  // SUB
            2: opcode = 5'b01001;  // INC_A
            3: opcode = 5'b01010;  // DEC_A
        endcase
        expected_result   = '0;
        expected_carry    = 1'b0;
        expected_borrow   = 1'b0;
        expected_zero     = 1'b0;
        expected_negative = 1'b0;
        expected_overflow = 1'b0;
        case(opcode)
            5'b00000: begin // ADD
              {expected_carry, expected_result} = {1'b0,A} + {1'b0,B};
              expected_overflow = (~A[WIDTH-1] & ~B[WIDTH-1] & expected_result[WIDTH-1]) | ( A[WIDTH-1] &  B[WIDTH-1] & ~expected_result[WIDTH-1]);
            end
            5'b00001: begin // SUB
                expected_result = A - B;
                expected_borrow = (A < B);
                expected_overflow = (~A[WIDTH-1] & B[WIDTH-1] & expected_result[WIDTH-1]) | ( A[WIDTH-1] & ~B[WIDTH-1] & ~expected_result[WIDTH-1]);
            end
            5'b01001: begin // INC_A
                {expected_carry, expected_result} = {1'b0,A} + {{WIDTH{1'b0}},1'b1};
                expected_overflow = (~A[WIDTH-1] & expected_result[WIDTH-1]);
            end
            5'b01010: begin // DEC_A
                expected_result = A - 1;
                expected_borrow = (A < 1);
                expected_overflow = (A[WIDTH-1] & ~expected_result[WIDTH-1]);
            end
        endcase
        expected_zero     = (expected_result == '0);
        expected_negative = expected_result[WIDTH-1];
        #1;
        if ((result == expected_result) && (carry == expected_carry) && (borrow == expected_borrow) && (zero == expected_zero) && (negative == expected_negative) && (overflow == expected_overflow)) begin
            random_pass_count = random_pass_count + 1;
            $display( "RANDOM TEST %0d PASS | A=%b B=%b OPCODE=%b | RESULT=%b | CARRY=%b BORROW=%b ZERO=%b NEGATIVE=%b OVERFLOW=%b", random_test_count, A, B, opcode, result, carry, borrow, zero, negative, overflow );
        end
        else begin
            random_fail_count = random_fail_count + 1;
            $display( "RANDOM TEST %0d FAIL | A=%b B=%b OPCODE=%b | ACTUAL: RESULT=%b CARRY=%b BORROW=%b ZERO=%b NEGATIVE=%b OVERFLOW=%b | EXPECTED: RESULT=%b CARRY=%b BORROW=%b ZERO=%b NEGATIVE=%b OVERFLOW=%b", random_test_count, A, B, opcode, result, carry, borrow, zero, negative, overflow, expected_result, expected_carry, expected_borrow, expected_zero, expected_negative, expected_overflow );
        end 
    end
endtask
endmodule
