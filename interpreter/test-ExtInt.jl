
using ExtInt, Base.Test, Error, Lexer.lex

NumNode = ExtInt.NumNode

==(Error.LispError, Error.LispError)


@testset "ExtInt" begin
    @test ExtInt.parse(5) == NumNode(5)
    @test_throws LispError ExtInt.parse("ayyee lmao")
    @test_throws LispError ExtInt.parse([])
    @test_throws LispError ExtInt.parse([1])
    @test_throws LispError ExtInt.parse([1, 2])
    @test_throws LispError ExtInt.parse(['a'])

    @test ExtInt.parse([:+, 1, 2]) == ExtInt.AddNode([NumNode(1), NumNode(2)])
    @test ExtInt.parse([:/, 1, 2]) == ExtInt.BinOpNode(/, NumNode(1), NumNode(2))
    @test ExtInt.parse([:*, 1, 2]) == ExtInt.BinOpNode(*, NumNode(1), NumNode(2))
    @test ExtInt.parse([:-, 1, 2]) == ExtInt.BinOpNode(-, NumNode(1), NumNode(2))
    @test ExtInt.parse([:mod, 1, 2]) == ExtInt.BinOpNode(mod, NumNode(1), NumNode(2))

    @test ExtInt.calc(ExtInt.BinOpNode(+, NumNode(1), NumNode(2))) == 3
    @test ExtInt.calc(ExtInt.BinOpNode(*, NumNode(1), NumNode(2))) == 2
    @test ExtInt.calc(ExtInt.BinOpNode(-, NumNode(1), NumNode(2))) == -1
    @test ExtInt.calc(ExtInt.BinOpNode(/, NumNode(1), NumNode(2))) == 0.5
    @test ExtInt.calc(ExtInt.BinOpNode(mod, NumNode(1), NumNode(2))) == 1

    @test ExtInt.calc(NumNode(3)) == 3


    @test ExtInt.exec("(+ 1 2)") == 3
    @test ExtInt.exec("(- 1 2)") == ExtInt.NumVal(-1)
    @test ExtInt.exec("(- 1)") == ExtInt.NumVal(-1)
    @test ExtInt.exec("(+ 1 (+ 4 5))") == 10
    @test ExtInt.exec("(+ 1 (* 4 5))") == 21
    @test ExtInt.exec("(+ 1 (mod 50 10))") == 1
    @test ExtInt.exec("(+ (- 10 5) (* 2 3))") == 11
    @test ExtInt.exec("(+ (- 10 5) (* 2 (mod 10 3)))") == 7
    @test_throws LispError ExtInt.exec("(collatz -1)")
    @test_throws LispError ExtInt.exec("(/ 1 0)")


    ######### ================================================================

    @test_throws LispError ExtInt.parse(lex("(with (x 1) x)"))
    @test_throws LispError ExtInt.parse(lex("(with ((x 1) (x 1)) 1)"))
    @test_throws LispError ExtInt.parse(lex("(lambda (x x) 1)"))
    @test_throws LispError ExtInt.parse(lex("(with ((x 10) (x 20)) 50)"))

    @test ExtInt.exec("(with ((x 1)) x)") == 1
    @test ExtInt.exec("(with ((x 1) (y 5)) (+ x y))") == 6
    @test ExtInt.exec("(with ((x 1) (y 5) (z 10)) (+ x (- y z)))") == -4
    @test ExtInt.exec("((lambda () (+ 2 2)))") == 4
    # println("=====================================================================================")
    @test ExtInt.exec("((lambda (x) (+ 2 x)) 2)") == 4
    # println("=====================================================================================")
    @test ExtInt.exec("(if0 (- 3 3) (+ 1 2) (+ 1 1))") == 3
    @test ExtInt.exec("(if0 (- 3 2) (+ 1 2) (+ 1 1))") == 2
    @test ExtInt.exec("(if0 0 (+ 1 2) (+ 1 1))") == 3
    @test ExtInt.exec("(with ((x 2)) (if0 0 (+ 1 x) (+ 1 1)))") == 3
    @test ExtInt.exec("((lambda (x y) (+ y x)) 2 2)") == 4
    @test_throws LispError ExtInt.exec("((lambda (x y) (+ y x)) 2 2 2 2)")
    @test_throws LispError ExtInt.exec("((lambda (x y z) (+ y x)))")
    @test_throws LispError ExtInt.exec("(lambda (x y z) (+ y x) asdf fdsa)")
    @test_throws LispError ExtInt.exec("((lambda (x y) (+ y x)) asdf fdsa)")
    @test ExtInt.exec("((lambda (x) (1)) 5)") == 1
    @test ExtInt.exec("(if0 0 ((lambda (x) (1)) 5) (+ 5 6))") == 1
    @test ExtInt.exec("(with ((a 5) (b 1)) (if0 0 ((lambda (x y) (- x y)) a b) (+ 5 6)))") == 4
end