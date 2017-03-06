using Terp, Base.Test, Error

import 
    Terp.OWL,
    Terp.NumNode,
    Terp.IdNode,
    Terp.BinOpNode,
    Terp.UnOpNode,
    Terp.WithNode,
    Terp.If0Node,
    Terp.FunDefNode,
    Terp.FunAppNode,

    Terp.parse,
    Terp.interp,
    Terp.exec,
    Terp.calc,

    Terp.mtEnv,
    Terp.CEnvironment,

    Terp.NumVal,
    Terp.ClosureVal
# end imports


@testset "ExtInt" begin
    @testset "Parsing" begin
        @testset "Reserved Words" begin
            @testset "Simple Ids" begin
                @test_throws LispError parse([:with])
                @test_throws LispError parse([:lambda])
            end
            @testset "With Ids" begin
                @test_throws LispError  parse([:with, [[:+, 1]], 1])
                @test_throws LispError  parse([:with, [[:-, 1]], 1])
                @test_throws LispError  parse([:with, [[:*, 1]], 1])
                @test_throws LispError  parse([:with, [[:/, 1]], 1])
                @test_throws LispError  parse([:with, [[:mod, 1]], 1])
                @test_throws LispError  parse([:with, [[:collatz, 1]], 1])
                @test_throws LispError  parse([:with, [[:with, 1]], 1])
                @test_throws LispError  parse([:with, [[:lambda, 1]], 1])
            end
            @testset "Lambda Ids" begin
                @test_throws LispError  parse([[:lambda, [:+], 1], 2])
                @test_throws LispError  parse([[:lambda, [:-], 1], 2])
                @test_throws LispError  parse([[:lambda, [:*], 1], 2])
                @test_throws LispError  parse([[:lambda, [:/], 1], 2])
                @test_throws LispError  parse([[:lambda, [:mod], 1], 2])
                @test_throws LispError  parse([[:lambda, [:collatz], 1], 2])
                @test_throws LispError  parse([[:lambda, [:if0], 1], 2])
                @test_throws LispError  parse([[:lambda, [:with], 1], 2])
                @test_throws LispError  parse([[:lambda, [:lambda], 1], 2])
            end
        end
        @testset "If0" begin
            @test_throws LispError parse([:if0])
            @test_throws LispError parse([:if0, 1])
            @test_throws LispError parse([:if0, 1, 2])
            @test parse([:if0, 1, 2, 3]) == If0Node(NumNode(1), NumNode(2), NumNode(3))
            @test_throws LispError parse([:if0, 1, 2, 3, 4])
            @test_throws LispError parse([:if0, 1, 2, 3, 4, 5])
            @test_throws LispError parse([:if0, :a])
            @test_throws LispError parse([:if0, :a, :b])
            @test parse([:if0, :a, :b, :c]) == If0Node(IdNode(:a), IdNode(:b), IdNode(:c))
            @test_throws LispError parse([:if0, :a, :b, :c, :d])
        end
        @testset "With" begin
            @test_throws LispError parse([:with])
            @test_throws LispError parse([:with, 1])
            @test_throws LispError parse([:with, 1, 2])
            @test_throws LispError parse([:with, 1, 2, 3])
            @test_throws LispError parse([:with, :a])
            @test_throws LispError parse([:with, :a, :b])
            @test_throws LispError parse([:with, :a, :b, :c])
            @test parse([:with, [], 1]) == WithNode(Dict{Symbol,OWL}(), NumNode(1))
            @test parse([:with, [[:a, 2]], 1]) == WithNode(Dict(:a => NumNode(2)),NumNode(1))
            @test parse([:with, [[:a, 2], [:b, 3]], 1]) == WithNode(Dict(:a => NumNode(2),:b => NumNode(3)),NumNode(1))
            @test parse([:with, [[:a, 2]], :a]) == WithNode(Dict(:a => NumNode(2)),IdNode(:a))
            @test parse([:with, [[:a, 2], [:b, 3]], :b]) == WithNode(Dict(:a => NumNode(2),:b => NumNode(3)),IdNode(:b))
        end 
        @testset "Lambda Def" begin
            @test_throws LispError parse([:lambda])
            @test_throws LispError parse([:lambda, 1])
            @test_throws LispError parse([:lambda, 1, 2])
            @test_throws LispError parse([:lambda, 1, 2, 3])
            @test_throws LispError parse([:lambda, :a])
            @test_throws LispError parse([:lambda, :a, :b])
            @test_throws LispError parse([:lambda, :a, :b, :c])
            @test parse([:lambda, [], 1]) == FunDefNode(Symbol[], NumNode(1))
            @test parse([:lambda, [:a], 1]) == FunDefNode([:a], NumNode(1))
            @test parse([:lambda, [:a, :b], 1]) == FunDefNode([:a, :b], NumNode(1))
            @test parse([:lambda, [:a], :a]) == FunDefNode([:a], IdNode(:a))
            @test parse([:lambda, [:a, :b], :b]) == FunDefNode([:a, :b], IdNode(:b))
        end 
        @testset "Lambda Call" begin
            @test_throws LispError parse([[:lambda, [], 1], 2])
            @test_throws LispError parse([[:lambda, [:a], 1], 2, 3])
            @test_throws LispError parse([[:lambda, [:a, :b], 1], 2, 3, 4])
            @test_throws LispError parse([[:lambda, [:a], 1]])
            @test_throws LispError parse([[:lambda, [:a, :b], 1], 2])
            @test parse([[:lambda, [], 1]]) == FunAppNode(FunDefNode(Symbol[],NumNode(1)),OWL[])
            @test parse([[:lambda, [:a], 1], 2]) == FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])
            @test parse([[:lambda, [:a, :b], 1], 2, 3]) == FunAppNode(FunDefNode([:a, :b], NumNode(1)), [NumNode(2), NumNode(3)])
            @test parse([[:lambda, [:a], :a], 2]) == FunAppNode(FunDefNode([:a], IdNode(:a)), [NumNode(2)])
            @test parse([[:lambda, [:a, :b], :b], 2, 3]) == FunAppNode(FunDefNode([:a, :b], IdNode(:b)), [NumNode(2), NumNode(3)])
        end
    end
    @testset "Calc" begin
        @testset "If0" begin
            @test calc(analyze(If0Node(NumNode(1), NumNode(2), NumNode(3)))) == NumVal(3)
            @test calc(If0Node(NumNode(1), NumNode(2), NumNode(3))) == NumVal(3)
        end 
        @testset "With" begin
            @test calc(analyze(WithNode(Dict{Symbol,OWL}(), NumNode(1)))) == NumVal(1)
            @test calc(FunAppNode(FunDefNode(Symbol[],NumNode(1)),OWL[])) == NumVal(1)
            @test calc(analyze(WithNode(Dict(:a => NumNode(2)),NumNode(1)))) == NumVal(1)
            @test calc(FunAppNode(FunDefNode(Symbol[:a],NumNode(1)),OWL[NumNode(2)])) == NumVal(1)
            @test calc(analyze(WithNode(Dict(:a => NumNode(2),:b => NumNode(3)),NumNode(1)))) == NumVal(1)
            @test calc(FunAppNode(FunDefNode(Symbol[:a, :b],NumNode(1)),OWL[NumNode(2), NumNode(3)])) == NumVal(1)
            @test calc(analyze(WithNode(Dict(:a => NumNode(2)),IdNode(:a)))) == NumVal(2)
            @test calc(FunAppNode(FunDefNode(Symbol[:a],IdNode(:a)),OWL[NumNode(2)])) == NumVal(2)
            @test calc(analyze(WithNode(Dict(:a => NumNode(2),:b => NumNode(3)),IdNode(:b)))) == NumVal(3)
            @test calc(FunAppNode(FunDefNode(Symbol[:a, :b],IdNode(:b)),OWL[NumNode(2), NumNode(3)])) == NumVal(3)
        end 
        @testset "Lambda Def" begin
            @test calc(analyze(FunDefNode(Symbol[], NumNode(1)))) == ClosureVal(Symbol[],NumNode(1),mtEnv())
            @test calc(FunDefNode(Symbol[], NumNode(1))) == ClosureVal(Symbol[],NumNode(1),mtEnv())
            @test calc(analyze(FunDefNode([:a], NumNode(1)))) == ClosureVal([:a],NumNode(1),mtEnv())
            @test calc(FunDefNode([:a], NumNode(1))) == ClosureVal([:a],NumNode(1),mtEnv())
            @test calc(analyze(FunDefNode([:a, :b], NumNode(1)))) == ClosureVal([:a, :b],NumNode(1),mtEnv())
            @test calc(FunDefNode([:a, :b], NumNode(1))) == ClosureVal([:a, :b],NumNode(1),mtEnv())
            @test calc(analyze(FunDefNode([:a], IdNode(:a)))) == ClosureVal([:a],IdNode(:a),mtEnv())
            @test calc(FunDefNode([:a], IdNode(:a))) == ClosureVal([:a],IdNode(:a),mtEnv())
            @test calc(analyze(FunDefNode([:a, :b], IdNode(:b)))) == ClosureVal([:a, :b],IdNode(:b),mtEnv())
            @test calc(FunDefNode([:a, :b], IdNode(:b))) == ClosureVal([:a, :b],IdNode(:b),mtEnv())
        end
        @testset "Lambda Call" begin
            @test calc(analyze(FunAppNode(FunDefNode(Symbol[], NumNode(1)), OWL[]))) == NumVal(1)
            @test calc(FunAppNode(FunDefNode(Symbol[], NumNode(1)), OWL[])) == NumVal(1)
            @test calc(analyze(FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)]))) == NumVal(1)
            @test calc(FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)]))  == NumVal(1)
            @test calc(analyze(FunAppNode(FunDefNode([:a, :b], NumNode(1)), [NumNode(2), NumNode(3)]))) == NumVal(1)
            @test calc(FunAppNode(FunDefNode([:a, :b], NumNode(1)), [NumNode(2), NumNode(3)])) == NumVal(1)
            @test calc(analyze(FunAppNode(FunDefNode([:a], IdNode(:a)), [NumNode(2)]))) == NumVal(2)
            @test calc(FunAppNode(FunDefNode([:a], IdNode(:a)), [NumNode(2)])) == NumVal(2)
            @test calc(analyze(FunAppNode(FunDefNode([:a, :b], IdNode(:b)), [NumNode(2), NumNode(3)]))) == NumVal(3)
            @test calc(FunAppNode(FunDefNode([:a, :b], IdNode(:b)), [NumNode(2), NumNode(3)])) == NumVal(3)
        end
    end
    @testset "Failed from ExtInt" begin
        #=8. 1 point. Your parser didn't throw a LispError when too many arguments were given to a unary operator
    20. 1 point. Your parser didn't throw a LispError when a key word was used as a binding name
    51. 2 point. Your calc didn't evaluate a funDef bound to an id and then applied later correctly
    62. 2 point. Your calc failed to handle passing closures between functions
    63. 2 point. Your calc failed to calculate a curry function properly
    64. 2 point. Your calc failed to calculate a complex expression using lambdas. with. and if0
    =#
        @test exec("(with ((fun (lambda (a) a))) (fun 1))") == NumVal(1)
        #=@test exec("(with ((myfun (lambda (a b) (+ a b))) (curry (lambda (func) (lambda (arg1) (lambda (arg2) (func arg1 arg2))))))(curry myfun 1))") == NumVal(1)
        WithNode(
            Dict(
                :curry => FunDefNode([:func],
                    FunDefNode([:arg1],
                        FunDefNode([:arg2],
                            FunAppNode(IdNode(:func),
                                OWL[IdNode(:arg1),IdNode(:arg2)]
                            )
                        )
                    )
                ),
                :myfun => FunDefNode([:a,:b],
                    AddNode(OWL[IdNode(:a),IdNode(:b)])
                )),
            FunAppNode(
                IdNode(:curry),
                OWL[IdNode(:myfun),NumNode(1)]
            )
        )=#
    end
    @testset "Derek's Tests" begin
        @test interp("(with () 1)") == WithNode(Dict{Symbol,OWL}(), NumNode(1))
        @test interp("(with ((a 2)) 1)") == WithNode(Dict(:a => NumNode(2)), NumNode(1))
        @test interp("(with ((a 2)(b 3)) 1)") == WithNode(Dict(:a => NumNode(2),:b => NumNode(3)), NumNode(1))
        

        @test calc(BinOpNode(+, NumNode(1), NumNode(2))) == 3
        @test calc(BinOpNode(*, NumNode(1), NumNode(2))) == 2
        @test calc(BinOpNode(-, NumNode(1), NumNode(2))) == -1
        @test calc(BinOpNode(/, NumNode(1), NumNode(2))) == 0.5
        @test calc(BinOpNode(mod, NumNode(1), NumNode(2))) == 1

        @test calc(NumNode(3)) == 3


        @test exec("(+ 1 2)") == 3
        @test exec("(- 1 2)") == NumVal(-1)
        @test exec("(- 1)") == NumVal(-1)
        @test exec("(+ 1 (+ 4 5))") == 10
        @test exec("(+ 1 (* 4 5))") == 21
        @test exec("(+ 1 (mod 50 10))") == 1
        @test exec("(+ (- 10 5) (* 2 3))") == 11
        @test exec("(+ (- 10 5) (* 2 (mod 10 3)))") == 7
        @test_throws LispError exec("(collatz -1)")
        @test_throws LispError exec("(/ 1 0)")


        ######### ================================================================

        @test_throws LispError interp("(with (x 1) x)")
        @test_throws LispError interp("(with ((x 1) (x 1)) 1)")
        @test_throws LispError interp("(lambda (x x) 1)")
        @test_throws LispError interp("(with ((x 10) (x 20)) 50)")

        @test exec("(with ((x 1)) x)") == 1
        @test exec("(with ((x 1) (y 5)) (+ x y))") == 6
        @test exec("(with ((x 1) (y 5) (z 10)) (+ x (- y z)))") == -4
        @test exec("((lambda () (+ 2 2)))") == 4
        # println("=====================================================================================")
        @test exec("((lambda (x) (+ 2 x)) 2)") == 4
        # println("=====================================================================================")
        @test exec("(if0 (- 3 3) (+ 1 2) (+ 1 1))") == 3
        @test exec("(if0 (- 3 2) (+ 1 2) (+ 1 1))") == 2
        @test exec("(if0 0 (+ 1 2) (+ 1 1))") == 3
        @test exec("(with ((x 2)) (if0 0 (+ 1 x) (+ 1 1)))") == 3
        @test exec("((lambda (x y) (+ y x)) 2 2)") == 4
        @test_throws LispError exec("((lambda (x y) (+ y x)) 2 2 2 2)")
        @test_throws LispError exec("((lambda (x y z) (+ y x)))")
        @test_throws LispError exec("(lambda (x y z) (+ y x) asdf fdsa)")
        @test_throws LispError exec("((lambda (x y) (+ y x)) asdf fdsa)")
        @test exec("((lambda (x) 1) 5)") == 1
        @test exec("(if0 0 ((lambda (x) 1) 5) (+ 5 6))") == 1
        @test exec("(with ((a 5) (b 1)) (if0 0 ((lambda (x y) (- x y)) a b) (+ 5 6)))") == 4
    end
end
"Finished ExtInt"