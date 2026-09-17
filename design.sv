module ALU #(parameter WIDTH=64)(
  input logic [WIDTH-1:0] A,B,
  input logic [4:0] opcode,
  output logic [(2*WIDTH)-1:0] product,
  output logic [WIDTH-1:0] result,quotient,remainder,
  output logic carry,borrow,zero,negative,overflow,div_zero
);
  localparam ADD  = 5'b00000;
  localparam SUB  = 5'b00001;
  localparam AND  = 5'b00010;
  localparam OR   = 5'b00011;
  localparam XOR  = 5'b00100;
  localparam NOT_A = 5'b00101;
  localparam RIGHT_SHIFT=5'b00110;
  localparam LEFT_SHIFT=5'b00111;
  localparam ARITHMETIC_RIGHT_SHIFT=5'b01000;
  localparam INC_A =5'b01001;
  localparam DEC_A =5'b01010;
  localparam NAND = 5'b01011;
  localparam NOR = 5'b01100;
  localparam XNOR= 5'b01101;
  localparam SLT= 5'b01110;
  localparam PASS_B=5'b01111;
  localparam MUL=5'b10000;
  localparam DIV=5'b10001;
  logic [(2*WIDTH)-1:0] shift_A;
  logic [WIDTH:0] temp_remainder;
  logic [WIDTH-1:0] shift_B;
  integer i;
  always_comb begin
    result   = '0;
    product  = '0;
    quotient = '0;
    remainder = '0;
    carry    = 1'b0;
    borrow   = 1'b0;
    div_zero = 1'b0;
    i              = 0;
    shift_A         = '0;
    shift_B         = '0;
    temp_remainder  = '0;
    case(opcode)
      ADD:begin //ADDITION
        {carry,result} = {1'b0,A} + {1'b0,B};
      end
      SUB:begin //SUBTRACT
        result = A - B;
        borrow = (A < B);
      end
      AND:begin //AND
        result=A&B;
      end
      OR:begin //OR
        result=A|B;
      end
      XOR:begin //XOR
        result=A^B;
      end
      NOT_A:begin //NOT_A
        result=~A;
      end
      RIGHT_SHIFT:begin //RIGHT_SHIFT
        result=A>>B;
      end
      LEFT_SHIFT:begin //LEFT_SHIFT
        result=A<<B;
      end
      ARITHMETIC_RIGHT_SHIFT:begin //ARITHMETIC_RIGHT_SHIFT
        result=$signed(A)>>>B;
      end
      INC_A:begin //INC_A
        {carry,result} = {1'b0,A} + {{WIDTH{1'b0}},1'b1};
      end
      DEC_A:begin //DEC_A
        result = A - 1;
    	borrow = (A < 1);
      end
      NAND:begin //NAND
        result=~(A&B);
      end
      NOR:begin //NOR
        result=~(A|B);
      end
      XNOR:begin //XNOR
        result=~(A^B);
      end
      SLT:begin //SLT
        if ($signed(A) < $signed(B))
            result = 1;
        else
            result = 0;
      end
      PASS_B:begin //PASS_B
        result=B;
      end
      MUL:begin // MUL: result is not used; full product is available in product
        // product=A*B; 
        shift_A = {{WIDTH{1'b0}}, A};
		shift_B=B;
        for(i=0;i<WIDTH;i=i+1)begin
          if(shift_B[0] == 1)
        	product = product + shift_A;
          shift_A = shift_A << 1;
          shift_B = shift_B >> 1;
        end
      end
      DIV:begin //DIV: result is not used; quotient and remainder are separate outputs
        if (B == 0) begin // Division by zero
          div_zero = 1'b1;
        end
        else begin
          //quotient  = A / B;
          //remainder = A % B;
          temp_remainder = '0;
          quotient = '0;
          for (i = WIDTH-1; i >= 0; i = i-1) begin
              temp_remainder = (temp_remainder << 1) | A[i];
              if (temp_remainder >= B) begin
                  temp_remainder = temp_remainder - B;
                  quotient[i] = 1'b1;
              end
              else begin
                  quotient[i] = 1'b0;
              end
          end
          remainder = temp_remainder[WIDTH-1:0];
        end
      end
    endcase
  end
  assign zero =(result == '0);
  assign negative = result[WIDTH-1];
  assign overflow =
    // ADD overflow
    ((opcode == ADD) && ((A[WIDTH-1] & B[WIDTH-1] & ~result[WIDTH-1]) | (~A[WIDTH-1] & ~B[WIDTH-1] & result[WIDTH-1])))
    ||
    // SUB overflow
    ((opcode == SUB) && ((~A[WIDTH-1] & B[WIDTH-1] & result[WIDTH-1]) | (A[WIDTH-1] & ~B[WIDTH-1] & ~result[WIDTH-1])))
    ||
    // INC overflow
    ((opcode == INC_A) && (~A[WIDTH-1] & result[WIDTH-1]))
    ||
    // DEC overflow
    ((opcode == DEC_A) && (A[WIDTH-1] & ~result[WIDTH-1]));
endmodule
