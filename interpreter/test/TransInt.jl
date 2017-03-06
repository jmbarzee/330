using Terp, Base.Test, Error

import 
	Terp.OWL,
	Terp.NumNode,
	Terp.IdNode,
	Terp.AddNode,
	Terp.BinOpNode,
	Terp.UnOpNode,
	Terp.WithNode,
	Terp.If0Node,
	Terp.AndNode,
	Terp.FunDefNode,
	Terp.FunAppNode,

	Terp.parse,
	Terp.interp,
	Terp.analyze,
	Terp.exec,
	Terp.calc,

	Terp.mtEnv,
	Terp.CEnvironment,

    Terp.NumVal,
    Terp.ClosureVal
# end imports


@testset "TransInt" begin
	@testset "Parsing" begin
		@testset "Reserved Words" begin
			@testset "Simple Ids" begin
				@test_throws LispError parse([:and])
			end
			@testset "With Ids" begin
				@test_throws LispError  parse([:with, [[:and, 1]], 1])
			end
			@testset "Lambda Ids" begin
				@test_throws LispError  parse([[:lambda, [:and], 1], 2])
			end
		end
		@testset "Plus" begin
			@test_throws LispError parse([:+])
			@test_throws LispError parse([:+, 1])
			@test parse([:+, 1, 2]) == AddNode([NumNode(1), NumNode(2)])
			@test parse([:+, 1, 2, 3]) == AddNode([NumNode(1), NumNode(2), NumNode(3)])
			@test parse([:+, 1, 2, 3, 4]) == AddNode([NumNode(1), NumNode(2), NumNode(3), NumNode(4)])
			@test_throws LispError parse([:+, :a])
			@test parse([:+, :a, :b]) == AddNode([IdNode(:a), IdNode(:b)])
			@test parse([:+, :a, :b, :c]) == AddNode([IdNode(:a), IdNode(:b), IdNode(:c)])
			@test parse([:+, :a, :b, :c, :d]) == AddNode([IdNode(:a), IdNode(:b), IdNode(:c), IdNode(:d)])
		end
		@testset "And" begin
			@test_throws LispError parse([:and])
			@test_throws LispError parse([:and, 1])
			@test parse([:and, 1, 2]) == AndNode([NumNode(1), NumNode(2)])
			@test parse([:and, 1, 2, 3]) == AndNode([NumNode(1), NumNode(2), NumNode(3)])
			@test parse([:and, 1, 2, 3, 4]) == AndNode([NumNode(1), NumNode(2), NumNode(3), NumNode(4)])
			@test_throws LispError parse([:and, :a])
			@test parse([:and, :a, :b]) == AndNode([IdNode(:a), IdNode(:b)])
			@test parse([:and, :a, :b, :c]) == AndNode([IdNode(:a), IdNode(:b), IdNode(:c)])
			@test parse([:and, :a, :b, :c, :d]) == AndNode([IdNode(:a), IdNode(:b), IdNode(:c), IdNode(:d)])
		end 
	end
	@testset "Analyze" begin
		@testset "Numbers" begin
			@test analyze(NumNode(5)) == NumNode(5)
		end 
		@testset "Plus" begin
			@test analyze(AddNode([NumNode(1), NumNode(2)])) == BinOpNode(+, NumNode(1), NumNode(2))
			@test analyze(AddNode([NumNode(1), NumNode(2), NumNode(3)])) ==  BinOpNode(+, NumNode(1), BinOpNode(+, NumNode(2), NumNode(3)))
			@test analyze(AddNode([NumNode(1), NumNode(2), NumNode(3), NumNode(4)])) == BinOpNode(+, NumNode(1), BinOpNode(+, NumNode(2), BinOpNode(+, NumNode(3), NumNode(4))))
		end 
		@testset "Minus" begin
			@test analyze(UnOpNode(-, NumNode(1))) == UnOpNode(-, NumNode(1))
			@test analyze(BinOpNode(-, NumNode(1), NumNode(2))) == BinOpNode(-, NumNode(1), NumNode(2))
		end 
		@testset "Multiply" begin
			@test analyze(BinOpNode(*, NumNode(1), NumNode(2))) == BinOpNode(*, NumNode(1), NumNode(2))
		end 
		@testset "Divide" begin
			@test analyze(BinOpNode(/, NumNode(1), NumNode(2))) == BinOpNode(/, NumNode(1), NumNode(2))
		end 
		@testset "Mod" begin
			@test analyze(BinOpNode(mod, NumNode(1), NumNode(2))) == BinOpNode(mod, NumNode(1), NumNode(2))
		end 
		@testset "If0" begin
			@test analyze(If0Node(NumNode(1), NumNode(2), NumNode(3))) == If0Node(NumNode(1), NumNode(2), NumNode(3))
		end 
		@testset "And" begin
			@test analyze(AndNode([NumNode(1), NumNode(2)])) == If0Node(NumNode(1), NumNode(0), If0Node(NumNode(2), NumNode(0), NumNode(1)))
			@test analyze(AndNode([NumNode(1), NumNode(2), NumNode(3)])) == If0Node(NumNode(1), NumNode(0), If0Node(NumNode(2), NumNode(0), If0Node(NumNode(3), NumNode(0), NumNode(1))))
			@test analyze(AndNode([NumNode(1), NumNode(2), NumNode(3), NumNode(4)])) == If0Node(NumNode(1), NumNode(0), If0Node(NumNode(2), NumNode(0), If0Node(NumNode(3), NumNode(0), If0Node(NumNode(4), NumNode(0), NumNode(1)))))
		end 
		@testset "With" begin
			@test analyze(WithNode(Dict{Symbol,OWL}(), NumNode(1))) == FunAppNode(FunDefNode(Symbol[],NumNode(1)),OWL[])
			@test analyze(WithNode(Dict(:a => NumNode(2)),NumNode(1))) == FunAppNode(FunDefNode(Symbol[:a],NumNode(1)),OWL[NumNode(2)])
			@test analyze(WithNode(Dict(:a => NumNode(2),:b => NumNode(3)),NumNode(1))) == FunAppNode(FunDefNode(Symbol[:a, :b],NumNode(1)),OWL[NumNode(2), NumNode(3)])
			@test analyze(WithNode(Dict(:a => NumNode(2)),IdNode(:a))) == FunAppNode(FunDefNode(Symbol[:a],IdNode(:a)),OWL[NumNode(2)])
			@test analyze(WithNode(Dict(:a => NumNode(2),:b => NumNode(3)),IdNode(:b))) == FunAppNode(FunDefNode(Symbol[:a, :b],IdNode(:b)),OWL[NumNode(2), NumNode(3)])
		end 
		@testset "Lambda Def" begin
			@test analyze(FunDefNode(Symbol[], NumNode(1))) == FunDefNode(Symbol[], NumNode(1))
			@test analyze(FunDefNode([:a], NumNode(1))) == FunDefNode([:a], NumNode(1))
			@test analyze(FunDefNode([:a, :b], NumNode(1))) == FunDefNode([:a, :b], NumNode(1))
			@test analyze(FunDefNode([:a], IdNode(:a))) == FunDefNode([:a], IdNode(:a))
			@test analyze(FunDefNode([:a, :b], IdNode(:b))) == FunDefNode([:a, :b], IdNode(:b))
		end 
		@testset "Lambda Call" begin
			@test analyze(FunAppNode(FunDefNode(Symbol[], NumNode(1)), OWL[])) == FunAppNode(FunDefNode(Symbol[], NumNode(1)), OWL[])
			@test analyze(FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])) == FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])
			@test analyze(FunAppNode(FunDefNode([:a, :b], NumNode(1)), [NumNode(2), NumNode(3)])) == FunAppNode(FunDefNode([:a, :b], NumNode(1)), [NumNode(2), NumNode(3)])
			@test analyze(FunAppNode(FunDefNode([:a], IdNode(:a)), [NumNode(2)])) == FunAppNode(FunDefNode([:a], IdNode(:a)), [NumNode(2)])
			@test analyze(FunAppNode(FunDefNode([:a, :b], IdNode(:b)), [NumNode(2), NumNode(3)])) == FunAppNode(FunDefNode([:a, :b], IdNode(:b)), [NumNode(2), NumNode(3)])
		end
	end
end
"Finished TransInt"