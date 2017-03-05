
using TransInt, Base.Test, Error, Lexer.lex

OWL = TransInt.OWL
NumNode = TransInt.NumNode
IdNode = TransInt.IdNode
AddNode = TransInt.AddNode
BinOpNode = TransInt.BinOpNode
UnOpNode = TransInt.UnOpNode
WithNode = TransInt.WithNode
If0Node = TransInt.If0Node
AndNode = TransInt.AndNode
FunDefNode = TransInt.FunDefNode
FunAppNode = TransInt.FunAppNode

parse = TransInt.parse
interp = TransInt.interp
analyze = TransInt.analyze
exec = TransInt.exec

mtEnv = TransInt.mtEnv
CEnvironment = TransInt.CEnvironment

==(Error.LispError, Error.LispError)


@testset "Parsing" begin
	@testset "Bad Parses" begin
		@test_throws LispError parse("ayyee lmao")
		@test_throws LispError parse([])
		@test_throws LispError parse([1])
		@test_throws LispError parse([1, 2])
		@test_throws LispError parse(['a'])
	end
	@testset "Reserved Words" begin
		@testset "Simple Ids" begin
			@test_throws LispError parse([:+])
			@test_throws LispError parse([:-])
			@test_throws LispError parse([:*])
			@test_throws LispError parse([:/])
			@test_throws LispError parse([:mod])
			@test_throws LispError parse([:collatz])
			@test_throws LispError parse([:if0])
			@test_throws LispError parse([:with])
			@test_throws LispError parse([:lambda])
			@test_throws LispError parse([:and])
		end
		@testset "With Ids" begin
			@test_throws LispError  parse([:with, [[:+, 1]], 1]) == WithNode(Dict{Symbol,OWL}(), NumNode(1))
			@test_throws LispError  parse([:with, [[:-, 1]], 1]) == WithNode(Dict{Symbol,OWL}(), NumNode(1))
			@test_throws LispError  parse([:with, [[:*, 1]], 1]) == WithNode(Dict{Symbol,OWL}(), NumNode(1))
			@test_throws LispError  parse([:with, [[:/, 1]], 1]) == WithNode(Dict{Symbol,OWL}(), NumNode(1))
			@test_throws LispError  parse([:with, [[:mod, 1]], 1]) == WithNode(Dict{Symbol,OWL}(), NumNode(1))
			@test_throws LispError  parse([:with, [[:collatz, 1]], 1]) == WithNode(Dict{Symbol,OWL}(), NumNode(1))
			@test_throws LispError  parse([:with, [[:if0, 1]], 1]) == WithNode(Dict{Symbol,OWL}(), NumNode(1))
			@test_throws LispError  parse([:with, [[:with, 1]], 1]) == WithNode(Dict{Symbol,OWL}(), NumNode(1))
			@test_throws LispError  parse([:with, [[:lambda, 1]], 1]) == WithNode(Dict{Symbol,OWL}(), NumNode(1))
			@test_throws LispError  parse([:with, [[:and, 1]], 1]) == WithNode(Dict{Symbol,OWL}(), NumNode(1))
		end
		@testset "Lambda Ids" begin
			@test_throws LispError  parse([[:lambda, [:+], 1], 2]) == FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])
			@test_throws LispError  parse([[:lambda, [:-], 1], 2]) == FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])
			@test_throws LispError  parse([[:lambda, [:*], 1], 2]) == FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])
			@test_throws LispError  parse([[:lambda, [:/], 1], 2]) == FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])
			@test_throws LispError  parse([[:lambda, [:mod], 1], 2]) == FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])
			@test_throws LispError  parse([[:lambda, [:collatz], 1], 2]) == FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])
			@test_throws LispError  parse([[:lambda, [:if0], 1], 2]) == FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])
			@test_throws LispError  parse([[:lambda, [:with], 1], 2]) == FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])
			@test_throws LispError  parse([[:lambda, [:lambda], 1], 2]) == FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])
			@test_throws LispError  parse([[:lambda, [:and], 1], 2]) == FunAppNode(FunDefNode([:a], NumNode(1)), [NumNode(2)])
		end

	end 
	@testset "Numbers" begin
		@test parse(5) == NumNode(5)
		@test parse(0) == NumNode(0)
		@test parse(-1) == NumNode(-1)
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
	@testset "Minus" begin
		@test_throws LispError parse([:-])
		@test parse([:-, 1]) == UnOpNode(-, NumNode(1))
		@test parse([:-, 1, 2]) == BinOpNode(-, NumNode(1), NumNode(2))
		@test_throws LispError parse([:-, 1, 2, 3])
		@test_throws LispError parse([:-, 1, 2, 3, 4])
		@test parse([:-, :a]) == UnOpNode(-, IdNode(:a))
		@test parse([:-, :a, :b]) == BinOpNode(-, IdNode(:a), IdNode(:b))
		@test_throws LispError parse([:-, :a, :b, :c])
		@test_throws LispError parse([:-, :a, :b, :c, :d])
	end 
	@testset "Multiply" begin
		@test_throws LispError parse([:*])
		@test_throws LispError parse([:*, 1])
		@test parse([:*, 1, 2]) == BinOpNode(*, NumNode(1), NumNode(2))
		@test_throws LispError parse([:*, 1, 2, 3])
		@test_throws LispError parse([:*, 1, 2, 3, 4])
		@test_throws LispError parse([:*, :a])
		@test parse([:*, :a, :b]) == BinOpNode(*, IdNode(:a), IdNode(:b))
		@test_throws LispError parse([:*, :a, :b, :c])
		@test_throws LispError parse([:*, :a, :b, :c, :d])
	end 
	@testset "Divide" begin
		@test_throws LispError parse([:/])
		@test_throws LispError parse([:/, 1])
		@test parse([:/, 1, 2]) == BinOpNode(/, NumNode(1), NumNode(2))
		@test_throws LispError parse([:/, 1, 2, 3])
		@test_throws LispError parse([:/, 1, 2, 3, 4])
		@test_throws LispError parse([:/, :a])
		@test parse([:/, :a, :b]) == BinOpNode(/, IdNode(:a), IdNode(:b))
		@test_throws LispError parse([:/, :a, :b, :c])
		@test_throws LispError parse([:/, :a, :b, :c, :d])
	end 
	@testset "Mod" begin
		@test_throws LispError parse([:mod])
		@test_throws LispError parse([:mod, 1])
		@test parse([:mod, 1, 2]) == BinOpNode(mod, NumNode(1), NumNode(2))
		@test_throws LispError parse([:mod, 1, 2, 3])
		@test_throws LispError parse([:mod, 1, 2, 3, 4])
		@test_throws LispError parse([:mod, :a])
		@test parse([:mod, :a, :b]) == BinOpNode(mod, IdNode(:a), IdNode(:b))
		@test_throws LispError parse([:mod, :a, :b, :c])
		@test_throws LispError parse([:mod, :a, :b, :c, :d])
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
@testset "Calc" begin
	@testset "Numbers" begin
		@test analyze(NumNode(5)) == NumNode(5)
	end 
	@testset "Plus" begin
		@test calc(analyze(AddNode([NumNode(1), NumNode(2)]))) == NumVal(3)
		@test calc(BinOpNode(+, NumNode(1), NumNode(2))) == NumVal(3)
		@test calc(analyze(AddNode([NumNode(1), NumNode(2), NumNode(3)]))) == NumVal(6)
		@test calc(BinOpNode(+, NumNode(1), BinOpNode(+, NumNode(2), NumNode(3)))) == NumVal(6)
		@test calc(analyze(AddNode([NumNode(1), NumNode(2), NumNode(3), NumNode(4)]))) == NumVal(10)
		@test calc(BinOpNode(+, NumNode(1), BinOpNode(+, NumNode(2), BinOpNode(+, NumNode(3), NumNode(4))))) == NumVal(10)
	end 
	@testset "Minus" begin
		@test calc(analyze(UnOpNode(-, NumNode(1)))) == NumVal(-1)
		@test calc(UnOpNode(-, NumNode(1))) == NumVal(-1)
		@test calc(analyze(BinOpNode(-, NumNode(1), NumNode(2)))) == NumVal(-1)
		@test calc(BinOpNode(-, NumNode(1), NumNode(2))) == NumVal(-1)
	end 
	@testset "Multiply" begin
		@test calc(analyze(BinOpNode(*, NumNode(1), NumNode(2)))) == NumVal(2)
		@test calc(BinOpNode(*, NumNode(1), NumNode(2))) == NumVal(2)
	end 
	@testset "Divide" begin
		@test calc(analyze(BinOpNode(/, NumNode(1), NumNode(2)))) == NumVal(1/2)
		@test calc(BinOpNode(/, NumNode(1), NumNode(2))) == NumVal(1/2)
		@test_throws LispError calc(BinOpNode(/, NumNode(1), NumNode(0)))
	end 
	@testset "Mod" begin
		@test calc(analyze(BinOpNode(mod, NumNode(1), NumNode(2)))) == NumVal(1)
		@test calc(BinOpNode(mod, NumNode(1), NumNode(2))) == NumVal(1)
		@test_throws LispError calc(BinOpNode(mod, NumNode(1), NumNode(0)))
	end 
	@testset "If0" begin
		@test calc(analyze(If0Node(NumNode(1), NumNode(2), NumNode(3)))) == NumVal(3)
		@test calc(If0Node(NumNode(1), NumNode(2), NumNode(3))) == NumVal(3)
	end 
	@testset "And" begin
		@test calc(analyze(AndNode([NumNode(1), NumNode(2)]))) == NumVal(1)
		@test calc(If0Node(NumNode(1), NumNode(0), If0Node(NumNode(2), NumNode(0), NumNode(1)))) == NumVal(1)
		@test calc(analyze(AndNode([NumNode(1), NumNode(2), NumNode(3)]))) == NumVal(1)
		@test calc(If0Node(NumNode(1), NumNode(0), If0Node(NumNode(2), NumNode(0), If0Node(NumNode(3), NumNode(0), NumNode(1))))) == NumVal(1)
		@test calc(analyze(AndNode([NumNode(1), NumNode(2), NumNode(3), NumNode(4)]))) == NumVal(1)
		@test calc(If0Node(NumNode(1), NumNode(0), If0Node(NumNode(2), NumNode(0), If0Node(NumNode(3), NumNode(0), If0Node(NumNode(4), NumNode(0), NumNode(1)))))) == NumVal(1)
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
	@test interp("(with ((a 2)) 1)") == WithNode(Dict(:a => NumNode(2), NumNode(1))
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

	@test_throws LispError parse(lex("(with (x 1) x)"))
	@test_throws LispError parse(lex("(with ((x 1) (x 1)) 1)"))
	@test_throws LispError parse(lex("(lambda (x x) 1)"))
	@test_throws LispError parse(lex("(with ((x 10) (x 20)) 50)"))

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
"Finished"