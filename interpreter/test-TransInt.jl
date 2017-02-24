
using TransInt, Base.Test, Error, Lexer.lex

NumNode = TransInt.NumNode

==(Error.LispError, Error.LispError)


@testset "TransInt" begin
    @test TransInt.parse(5) == NumNode(5)
    @test_throws LispError TransInt.parse("ayyee lmao")
    @test_throws LispError TransInt.parse([])
    @test_throws LispError TransInt.parse([1])
    @test_throws LispError TransInt.parse([1, 2])
    @test_throws LispError TransInt.parse(['a'])

    @test TransInt.parse([:+, 1, 2]) == TransInt.AddNode([NumNode(1), NumNode(2)])
    @test TransInt.parse([:/, 1, 2]) == TransInt.BinOpNode(/, NumNode(1), NumNode(2))
    @test TransInt.parse([:*, 1, 2]) == TransInt.BinOpNode(*, NumNode(1), NumNode(2))
    @test TransInt.parse([:-, 1, 2]) == TransInt.BinOpNode(-, NumNode(1), NumNode(2))
    @test TransInt.parse([:mod, 1, 2]) == TransInt.BinOpNode(mod, NumNode(1), NumNode(2))

    @test TransInt.calc(TransInt.BinOpNode(+, NumNode(1), NumNode(2))) == 3
    @test TransInt.calc(TransInt.BinOpNode(*, NumNode(1), NumNode(2))) == 2
    @test TransInt.calc(TransInt.BinOpNode(-, NumNode(1), NumNode(2))) == -1
    @test TransInt.calc(TransInt.BinOpNode(/, NumNode(1), NumNode(2))) == 0.5
    @test TransInt.calc(TransInt.BinOpNode(mod, NumNode(1), NumNode(2))) == 1

    @test TransInt.calc(NumNode(3)) == 3


    @test TransInt.exec("(+ 1 2)") == 3
    @test TransInt.exec("(- 1 2)") == TransInt.NumVal(-1)
    @test TransInt.exec("(- 1)") == TransInt.NumVal(-1)
    @test TransInt.exec("(+ 1 (+ 4 5))") == 10
    @test TransInt.exec("(+ 1 (* 4 5))") == 21
    @test TransInt.exec("(+ 1 (mod 50 10))") == 1
    @test TransInt.exec("(+ (- 10 5) (* 2 3))") == 11
    @test TransInt.exec("(+ (- 10 5) (* 2 (mod 10 3)))") == 7
    @test_throws LispError TransInt.exec("(collatz -1)")
    @test_throws LispError TransInt.exec("(/ 1 0)")


    ######### ================================================================

    @test_throws LispError TransInt.parse(lex("(with (x 1) x)"))
    @test_throws LispError TransInt.parse(lex("(with ((x 1) (x 1)) 1)"))
    @test_throws LispError TransInt.parse(lex("(lambda (x x) 1)"))
    @test_throws LispError TransInt.parse(lex("(with ((x 10) (x 20)) 50)"))

    @test TransInt.exec("(with ((x 1)) x)") == 1
    @test TransInt.exec("(with ((x 1) (y 5)) (+ x y))") == 6
    @test TransInt.exec("(with ((x 1) (y 5) (z 10)) (+ x (- y z)))") == -4
    @test TransInt.exec("((lambda () (+ 2 2)))") == 4
    # println("=====================================================================================")
    @test TransInt.exec("((lambda (x) (+ 2 x)) 2)") == 4
    # println("=====================================================================================")
    @test TransInt.exec("(if0 (- 3 3) (+ 1 2) (+ 1 1))") == 3
    @test TransInt.exec("(if0 (- 3 2) (+ 1 2) (+ 1 1))") == 2
    @test TransInt.exec("(if0 0 (+ 1 2) (+ 1 1))") == 3
    @test TransInt.exec("(with ((x 2)) (if0 0 (+ 1 x) (+ 1 1)))") == 3
    @test TransInt.exec("((lambda (x y) (+ y x)) 2 2)") == 4
    @test_throws LispError TransInt.exec("((lambda (x y) (+ y x)) 2 2 2 2)")
    @test_throws LispError TransInt.exec("((lambda (x y z) (+ y x)))")
    @test_throws LispError TransInt.exec("(lambda (x y z) (+ y x) asdf fdsa)")
    @test_throws LispError TransInt.exec("((lambda (x y) (+ y x)) asdf fdsa)")
    @test TransInt.exec("((lambda (x) (1)) 5)") == 1
    @test TransInt.exec("(if0 0 ((lambda (x) (1)) 5) (+ 5 6))") == 1
    @test TransInt.exec("(with ((a 5) (b 1)) (if0 0 ((lambda (x y) (- x y)) a b) (+ 5 6)))") == 4
end