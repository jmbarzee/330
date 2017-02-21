
push!(LOAD_PATH, ".")

using RudInt

using Base.Test

function lexParse(str)
  RudInt.parse(Lexer.lex(str))
end

function parseInter(str)
  RudInt.calc(lexParse(str))
end

function removeNL(str)
  replace(string(str), "\n", "")
end

function clean(f, param)
  try
    return removeNL(f(param))
  catch Y
    return Y
  end
end

@testset "parse" begin
  @testset "operators" begin
    @testset "uniary" begin
      @testset "negate" begin
        @test string( clean( lexParse, "(-5)" )) == string( Error.LispError("Unrecognized Type") )
        @test string( clean( lexParse, "(- 5)" )) == string( RudInt.UnOpNode(-,RudInt.NumNode(5)) )
        @test string( clean( lexParse, "( - 5 )" )) == string( RudInt.UnOpNode(-,RudInt.NumNode(5)) )
      end
      @testset "collatz" begin
        @test string( clean( lexParse, "(collatz5)" )) == string( RudInt.IdNode(:collatz5) )
        @test string( clean( lexParse, "(collatz 5)" )) == string( RudInt.UnOpNode(RudInt.collatz,RudInt.NumNode(5)) )
        @test string( clean( lexParse, "( collatz 5 )" )) == string( RudInt.UnOpNode(RudInt.collatz,RudInt.NumNode(5)) )
      end
    end
    @testset "binary" begin
      @testset "add" begin
        @test string( clean( lexParse, "(+51)" )) == string( Error.LispError("Unrecognized Type") )
        @test string( clean( lexParse, "(+5 1)" )) == string( Error.LispError("Unrecognized Type") )
        @test string( clean( lexParse, "(+ 51)" )) == string( Error.LispError("Improper number of arguments") )
        @test string( clean( lexParse, "(+ 5 1)" )) == string( RudInt.BinOpNode(+,RudInt.NumNode(5),RudInt.NumNode(1)) )
        @test string( clean( lexParse, "( + 5 1 )" )) == string( RudInt.BinOpNode(+,RudInt.NumNode(5),RudInt.NumNode(1)) )
      end
      @testset "subtract" begin
        @test string( clean( lexParse, "(-51)" )) == string( Error.LispError("Unrecognized Type") )
        @test string( clean( lexParse, "(-5 1)" )) == string( Error.LispError("Unrecognized Type") )
        @test string( clean( lexParse, "(- 5 1)" )) == string( RudInt.BinOpNode(-,RudInt.NumNode(5),RudInt.NumNode(1)) )
        @test string( clean( lexParse, "( - 5 1 )" )) == string( RudInt.BinOpNode(-,RudInt.NumNode(5),RudInt.NumNode(1)) )
      end
      @testset "multiply" begin
        @test string( clean( lexParse, "(*51)" )) == string( Error.LispError("Incomplete Expression: *51") )
        @test string( clean( lexParse, "(*5 1)" )) == string( Error.LispError("Incomplete Expression: *5") )
        @test string( clean( lexParse, "(* 51)" )) == string( Error.LispError("No matching uinary op") )
        @test string( clean( lexParse, "(* 5 1)" )) == string( RudInt.BinOpNode(*,RudInt.NumNode(5),RudInt.NumNode(1)) )
        @test string( clean( lexParse, "( * 5 1 )" )) == string( RudInt.BinOpNode(*,RudInt.NumNode(5),RudInt.NumNode(1)) )
      end
      @testset "divide" begin
        @test string( clean( lexParse, "(/51)" )) == string( Error.LispError("Incomplete Expression: /51") )
        @test string( clean( lexParse, "(/5 1)" )) == string( Error.LispError("Incomplete Expression: /5") )
        @test string( clean( lexParse, "(/ 51)" )) == string( Error.LispError("No matching uinary op") )
        @test string( clean( lexParse, "(/ 5 1)" )) == string( RudInt.BinOpNode(/,RudInt.NumNode(5),RudInt.NumNode(1)) )
        @test string( clean( lexParse, "( / 5 1 )" )) == string( RudInt.BinOpNode(/,RudInt.NumNode(5),RudInt.NumNode(1)) )
      end
      @testset "modulus" begin
        @test string( clean( lexParse, "(%51)" )) == string( Error.LispError("Incomplete Expression: %51") )
        @test string( clean( lexParse, "(%5 1)" )) == string( Error.LispError("Incomplete Expression: %5") )
        @test string( clean( lexParse, "(% 51)" )) == string( Error.LispError("No matching uinary op") )
        @test string( clean( lexParse, "(% 5 1)" )) == string( RudInt.BinOpNode(mod,RudInt.NumNode(5),RudInt.NumNode(1)) )
        @test string( clean( lexParse, "( % 5 1 )" )) == string( RudInt.BinOpNode(mod,RudInt.NumNode(5),RudInt.NumNode(1)) )
      end
    end
  end

  @testset "nesting" begin
    @testset "uinary" begin
      @testset "negate" begin
        @test string( clean( lexParse  , "(- (- (- 5)))" )) == string( RudInt.UnOpNode(-,RudInt.UnOpNode(-,RudInt.UnOpNode(-,RudInt.NumNode(5)))) )
        @test string( clean( lexParse  , "( - ( - ( - 5 ) ) )" )) == string( RudInt.UnOpNode(-,RudInt.UnOpNode(-,RudInt.UnOpNode(-,RudInt.NumNode(5)))) )
      end
      @testset "collatz" begin
        @test string( clean( lexParse  , "(collatz (collatz (collatz 5)))" )) == string( RudInt.UnOpNode(RudInt.collatz,RudInt.UnOpNode(RudInt.collatz,RudInt.UnOpNode(RudInt.collatz,RudInt.NumNode(5)))) )
        @test string( clean( lexParse  , "( collatz ( collatz ( collatz 5 ) ) )" )) == string( RudInt.UnOpNode(RudInt.collatz,RudInt.UnOpNode(RudInt.collatz,RudInt.UnOpNode(RudInt.collatz,RudInt.NumNode(5)))) )
      end
    end
    @testset "binary" begin
      @testset "add" begin
        @test string( clean( lexParse  , "(+ 1 (+ 1 1))" )) == string( RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse  , "(+ (+ 1 1) 1)" )) == string( RudInt.BinOpNode(+,RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.NumNode(1)) )
        @test string( clean( lexParse  , "(+ (+ 1 1) (+ 1 1))" )) == string( RudInt.BinOpNode(+,RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse  , "(+ (+ 1 1) (+ (+ 1 1) (+ 1 1)))" )) == string( RudInt.BinOpNode(+,RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(+,RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1)))) )
        @test string( clean( lexParse  , "(+ (+ (+ 1 1) (+ 1 1)) (+ 1 1))" )) == string( RudInt.BinOpNode(+,RudInt.BinOpNode(+,RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse  , "(+ (+ (+ 1 1) (+ 1 1)) (+ (+ 1 1) (+ 1 1)))" )) == string( RudInt.BinOpNode(+,RudInt.BinOpNode(+,RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(+,RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1)))) )
        @test string( clean( lexParse  , "(+ (+ 1 (+ 1 1)) (+ 1 (+ 1 1)))" )) == string( RudInt.BinOpNode(+,RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.BinOpNode(+,RudInt.NumNode(1),RudInt.NumNode(1)))) )
      end
      @testset "subtract" begin
        @test string( clean( lexParse, "(- 1 (-  1 1))" )) == string( RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse, "(- (- 1 1) 1)" )) == string( RudInt.BinOpNode(- ,RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.NumNode(1)) )
        @test string( clean( lexParse, "(- (- 1 1) (- 1 1))" )) == string( RudInt.BinOpNode(- ,RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse, "(- (- 1 1) (- (- 1 1) (- 1 1)))" )) == string( RudInt.BinOpNode(- ,RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(- ,RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.NumNode(1)))) )
        @test string( clean( lexParse, "(- (- (- 1 1) (- 1 1)) (- 1 1))" )) == string( RudInt.BinOpNode(- ,RudInt.BinOpNode(- ,RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse, "(- (- (- 1 1) (- 1 1)) (- (- 1 1) (- 1 1)))" )) == string( RudInt.BinOpNode(- ,RudInt.BinOpNode(- ,RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(- ,RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(- ,RudInt.NumNode(1),RudInt.NumNode(1)))) )
        @test string( clean( lexParse, "(- (- 1 (- 1 1)) (- 1 (- 1 1)))" )) == string( RudInt.BinOpNode(-,RudInt.BinOpNode(-,RudInt.NumNode(1),RudInt.BinOpNode(-,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(-,RudInt.NumNode(1),RudInt.BinOpNode(-,RudInt.NumNode(1),RudInt.NumNode(1)))) )
      end
      @testset "multiply" begin
        @test string( clean( lexParse, "(* 1 (* 1 1))" )) == string( RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse, "(* (* 1 1) 1)" )) == string( RudInt.BinOpNode(* ,RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.NumNode(1)) )
        @test string( clean( lexParse, "(* (* 1 1) (* 1 1))" )) == string( RudInt.BinOpNode(* ,RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse, "(* (* 1 1) (* (* 1 1) (* 1 1)))" )) == string( RudInt.BinOpNode(* ,RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(* ,RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.NumNode(1)))) )
        @test string( clean( lexParse, "(* (* (* 1 1) (* 1 1)) (* 1 1))" )) == string( RudInt.BinOpNode(* ,RudInt.BinOpNode(* ,RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse, "(* (* (* 1 1) (* 1 1)) (* (* 1 1) (* 1 1)))" )) == string( RudInt.BinOpNode(* ,RudInt.BinOpNode(* ,RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(* ,RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(* ,RudInt.NumNode(1),RudInt.NumNode(1)))) )
        @test string( clean( lexParse, "(* (* 1 (* 1 1)) (* 1 (* 1 1)))" )) == string( RudInt.BinOpNode(*,RudInt.BinOpNode(*,RudInt.NumNode(1),RudInt.BinOpNode(*,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(*,RudInt.NumNode(1),RudInt.BinOpNode(*,RudInt.NumNode(1),RudInt.NumNode(1)))) )
      end
      @testset "divide" begin
        @test string( clean( lexParse, "(/ 1 (/ 1 1))" )) == string( RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse, "(/ (/ 1 1) 1)" )) == string( RudInt.BinOpNode(/ ,RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.NumNode(1)) )
        @test string( clean( lexParse, "(/ (/ 1 1) (/ 1 1))" )) == string( RudInt.BinOpNode(/ ,RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse, "(/ (/ 1 1) (/ (/ 1 1) (/ 1 1)))" )) == string( RudInt.BinOpNode(/ ,RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(/ ,RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.NumNode(1)))) )
        @test string( clean( lexParse, "(/ (/ (/ 1 1) (/ 1 1)) (/ 1 1))" )) == string( RudInt.BinOpNode(/ ,RudInt.BinOpNode(/ ,RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse, "(/ (/ (/ 1 1) (/ 1 1)) (/ (/ 1 1) (/ 1 1)))" )) == string( RudInt.BinOpNode(/ ,RudInt.BinOpNode(/ ,RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(/ ,RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(/ ,RudInt.NumNode(1),RudInt.NumNode(1)))) )
        @test string( clean( lexParse, "(/ (/ 1 (/ 1 1)) (/ 1 (/ 1 1)))" )) == string( RudInt.BinOpNode(/,RudInt.BinOpNode(/,RudInt.NumNode(1),RudInt.BinOpNode(/,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(/,RudInt.NumNode(1),RudInt.BinOpNode(/,RudInt.NumNode(1),RudInt.NumNode(1)))) )
      end
      @testset "modulus" begin
        @test string( clean( lexParse, "(% 1 (% 1 1))" )) == string( RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse, "(% (% 1 1) 1)" )) == string( RudInt.BinOpNode(mod,RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.NumNode(1)) )
        @test string( clean( lexParse, "(% (% 1 1) (% 1 1))" )) == string( RudInt.BinOpNode(mod,RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse, "(% (% 1 1) (% (% 1 1) (% 1 1)))" )) == string( RudInt.BinOpNode(mod,RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(mod,RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1)))) )
        @test string( clean( lexParse, "(% (% (% 1 1) (% 1 1)) (% 1 1))" )) == string( RudInt.BinOpNode(mod,RudInt.BinOpNode(mod,RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1))) )
        @test string( clean( lexParse, "(% (% (% 1 1) (% 1 1)) (% (% 1 1) (% 1 1)))" )) == string( RudInt.BinOpNode(mod,RudInt.BinOpNode(mod,RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(mod,RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1)),RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1)))) )
        @test string( clean( lexParse, "(% (% 1 (% 1 1)) (% 1 (% 1 1)))" )) == string( RudInt.BinOpNode(mod,RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1))),RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.BinOpNode(mod,RudInt.NumNode(1),RudInt.NumNode(1)))) )
      end
    end
  end
end

@testset "calc" begin
  @testset "operators" begin
    @testset "uniary" begin
      @testset "negate" begin
        @test string( clean( parseInter , "(-5)" )) == string( Error.LispError("No matching op") )
        @test string( clean( parseInter , "(- 5)" )) == string( -5 )
        @test string( clean( parseInter , "( - 5 )" )) == string( -5 )
      end
      @testset "collatz" begin
        @test string( clean( parseInter , "(collatz5)" )) == string( Error.LispError("No matching op") )
        @test string( clean( parseInter , "(collatz 5)" )) == string( 5 )
        @test string( clean( parseInter , "( collatz 5 )" )) == string( 5 )
      end
    end
    @testset "binary" begin
      @testset "add" begin
        @test string( clean( parseInter , "(+51)" )) == string( Error.LispError("No matching op") )
        @test string( clean( parseInter , "(+5 1)" )) == string( Error.LispError("No matching uinary op") )
        @test string( clean( parseInter , "(+ 51)" )) == string( Error.LispError("No matching uinary op") )
        @test string( clean( parseInter , "(+ 5 1)" )) == string( 6 )
        @test string( clean( parseInter , "( + 5 1 )" )) == string( 6 )
      end
      @testset "subtract" begin
        @test string( clean( parseInter , "(-51)" )) == string( Error.LispError("No matching op") )
        @test string( clean( parseInter , "(-5 1)" )) == string( Error.LispError("No matching uinary op") )
        @test string( clean( parseInter , "(- 5 1)" )) == string( 4 )
        @test string( clean( parseInter , "( - 5 1 )" )) == string( 4 )
      end
      @testset "multiply" begin
        @test string( clean( parseInter , "(*51)" )) == string( Error.LispError("Incomplete Expression: *51") )
        @test string( clean( parseInter , "(*5 1)" )) == string( Error.LispError("Incomplete Expression: *5") )
        @test string( clean( parseInter , "(* 51)" )) == string( Error.LispError("No matching uinary op") )
        @test string( clean( parseInter , "(* 5 1)" )) == string( 5 )
        @test string( clean( parseInter , "( * 5 1 )" )) == string( 5 )
      end
      @testset "divide" begin
        @test string( clean( parseInter , "(/51)" )) == string( Error.LispError("Incomplete Expression: /51") )
        @test string( clean( parseInter , "(/5 1)" )) == string( Error.LispError("Incomplete Expression: /5") )
        @test string( clean( parseInter , "(/ 51)" )) == string( Error.LispError("No matching uinary op") )
        @test string( clean( parseInter , "(/ 5 1)" )) == string( 5.0 )
        @test string( clean( parseInter , "( / 5 1 )" )) == string( 5.0 )
      end
      @testset "modulus" begin
        @test string( clean( parseInter , "(%51)" )) == string( Error.LispError("Incomplete Expression: %51") )
        @test string( clean( parseInter , "(%5 1)" )) == string( Error.LispError("Incomplete Expression: %5") )
        @test string( clean( parseInter , "(% 51)" )) == string( Error.LispError("No matching uinary op") )
        @test string( clean( parseInter , "(% 5 1)" )) == string( 0 )
        @test string( clean( parseInter , "( % 5 1 )" )) == string( 0 )
      end
    end
  end

  @testset "nesting" begin
    @testset "uinary" begin
      @testset "negate" begin
        @test string( clean( parseInter , "(- (- (- 5)))" )) == string( -5 )
        @test string( clean( parseInter , "( - ( - ( - 5 ) ) )" )) == string( -5 )
      end
      @testset "collatz" begin
        @test string( clean( parseInter , "(collatz (collatz (collatz 5)))" )) == string( 5 )
        @test string( clean( parseInter , "( collatz ( collatz ( collatz 5 ) ) )" )) == string( 5 )
      end
    end
    @testset "binary" begin
      @testset "add" begin
        @test string( clean( parseInter , "(+ 1 (+ 1 1))" )) == string( 3 )
        @test string( clean( parseInter , "(+ (+ 1 1) 1)" )) == string( 3 )
        @test string( clean( parseInter , "(+ (+ 1 1) (+ 1 1))" )) == string( 4 )
        @test string( clean( parseInter , "(+ (+ 1 1) (+ (+ 1 1) (+ 1 1)))" )) == string( 6 )
        @test string( clean( parseInter , "(+ (+ (+ 1 1) (+ 1 1)) (+ 1 1))" )) == string( 6 )
        @test string( clean( parseInter , "(+ (+ (+ 1 1) (+ 1 1)) (+ (+ 1 1) (+ 1 1)))" )) == string( 8 )
        @test string( clean( parseInter , "(+ (+ 1 (+ 1 1)) (+ 1 (+ 1 1)))" )) == string( 6 )
      end
      @testset "subtract" begin
        @test string( clean( parseInter , "(- 1 (-  1 1))" )) == string( 1 )
        @test string( clean( parseInter , "(- (- 1 1) 1)" )) == string( -1 )
        @test string( clean( parseInter , "(- (- 1 1) (- 1 1))" )) == string( 0 )
        @test string( clean( parseInter , "(- (- 1 1) (- (- 1 1) (- 1 1)))" )) == string( 0 )
        @test string( clean( parseInter , "(- (- (- 1 1) (- 1 1)) (- 1 1))" )) == string( 0 )
        @test string( clean( parseInter , "(- (- (- 1 1) (- 1 1)) (- (- 1 1) (- 1 1)))" )) == string( 0 )
        @test string( clean( parseInter , "(- (- 1 (- 1 1)) (- 1 (- 1 1)))" )) == string( 0 )
      end
      @testset "multiply" begin
        @test string( clean( parseInter , "(* 1 (* 1 1))" )) == string( 1 )
        @test string( clean( parseInter , "(* (* 1 1) 1)" )) == string( 1 )
        @test string( clean( parseInter , "(* (* 1 1) (* 1 1))" )) == string( 1 )
        @test string( clean( parseInter , "(* (* 1 1) (* (* 1 1) (* 1 1)))" )) == string( 1 )
        @test string( clean( parseInter , "(* (* (* 1 1) (* 1 1)) (* 1 1))" )) == string( 1 )
        @test string( clean( parseInter , "(* (* (* 1 1) (* 1 1)) (* (* 1 1) (* 1 1)))" )) == string( 1 )
        @test string( clean( parseInter , "(* (* 1 (* 1 1)) (* 1 (* 1 1)))" )) == string( 1 )
      end
      @testset "divide" begin
        @test string( clean( parseInter , "(/ 1 (/ 1 1))" )) == string( 1.0 )
        @test string( clean( parseInter , "(/ (/ 1 1) 1)" )) == string( 1.0 )
        @test string( clean( parseInter , "(/ (/ 1 1) (/ 1 1))" )) == string( 1.0 )
        @test string( clean( parseInter , "(/ (/ 1 1) (/ (/ 1 1) (/ 1 1)))" )) == string( 1.0 )
        @test string( clean( parseInter , "(/ (/ (/ 1 1) (/ 1 1)) (/ 1 1))" )) == string( 1.0 )
        @test string( clean( parseInter , "(/ (/ (/ 1 1) (/ 1 1)) (/ (/ 1 1) (/ 1 1)))" )) == string( 1.0 )
        @test string( clean( parseInter , "(/ (/ 1 (/ 1 1)) (/ 1 (/ 1 1)))" )) == string( 1.0 )
      end
      @testset "modulus" begin
        @test string( clean( parseInter , "(% 1 (% 1 1))" )) == string( Error.LispError("NO") )
        @test string( clean( parseInter , "(% (% 1 1) 1)" )) == string( 0 )
        @test string( clean( parseInter , "(% (% 1 1) (% 1 1))" )) == string( Error.LispError("NO") )
        @test string( clean( parseInter , "(% (% 1 1) (% (% 1 1) (% 1 1)))" )) == string( Error.LispError("NO") )
        @test string( clean( parseInter , "(% (% (% 1 1) (% 1 1)) (% 1 1))" )) == string( Error.LispError("NO") )
        @test string( clean( parseInter , "(% (% (% 1 1) (% 1 1)) (% (% 1 1) (% 1 1)))" )) == string( Error.LispError("NO") )
        @test string( clean( parseInter , "(% (% 1 (% 1 1)) (% 1 (% 1 1)))" )) == string( Error.LispError("NO") )
      end
    end
  end
end
