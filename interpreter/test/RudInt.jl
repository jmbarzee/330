using Terp, Base.Test, Error

import 
	Terp.OWL,
	Terp.NumNode,
	Terp.IdNode,
	Terp.BinOpNode,
	Terp.UnOpNode,
	Terp.WithNode,

	Terp.parse,
	Terp.interp,
	Terp.exec,
	Terp.calc,

	Terp.mtEnv,
	Terp.CEnvironment,

    Terp.NumVal
# end imports

@testset "RudInt" begin
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
			end
		end 
		@testset "Ids" begin
			@test parse(:a) == IdNode(:a)
			@test parse(:b) == IdNode(:b)
		end 
		@testset "Numbers" begin
			@test parse(5) == NumNode(5)
			@test parse(0) == NumNode(0)
			@test parse(-1) == NumNode(-1)
		end 
		@testset "Plus" begin
			@test_throws LispError parse([:+])
			@test_throws LispError parse([:+, 1])
			#====== Lines commented out because functionality was broken intentionally with TransInt =====#
			#@test parse([:+, 1, 2]) == BinOpNode(:+, [NumNode(1), NumNode(2)])
			#@test_throws LispError  parse([:+, 1, 2, 3]) == AddNode([NumNode(1), NumNode(2), NumNode(3)])
			#@test_throws LispError  parse([:+, 1, 2, 3, 4]) == AddNode([NumNode(1), NumNode(2), NumNode(3), NumNode(4)])
			@test_throws LispError parse([:+, :a])
			#@test parse([:+, :a, :b]) == BinOpNode(:+, [IdNode(:a), IdNode(:b)])
			#@test_throws LispError  parse([:+, :a, :b, :c]) == AddNode([IdNode(:a), IdNode(:b), IdNode(:c)])
			#@test_throws LispError  parse([:+, :a, :b, :c, :d]) == AddNode([IdNode(:a), IdNode(:b), IdNode(:c), IdNode(:d)])
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
	end
	@testset "Calc" begin
		@testset "Numbers" begin
			@test calc(NumNode(5)) == NumVal(5)
		end 
		@testset "Plus" begin
			@test calc(BinOpNode(+, NumNode(1), NumNode(2))) == NumVal(3)
			@test calc(BinOpNode(+, NumNode(1), BinOpNode(+, NumNode(2), NumNode(3)))) == NumVal(6)
			@test calc(BinOpNode(+, NumNode(1), BinOpNode(+, NumNode(2), BinOpNode(+, NumNode(3), NumNode(4))))) == NumVal(10)
		end 
		@testset "Minus" begin
			@test calc(UnOpNode(-, NumNode(1))) == NumVal(-1)
			@test calc(UnOpNode(-, NumNode(1))) == NumVal(-1)
			@test calc(BinOpNode(-, NumNode(1), NumNode(2))) == NumVal(-1)
			@test calc(BinOpNode(-, NumNode(1), NumNode(2))) == NumVal(-1)
		end 
		@testset "Multiply" begin
			@test calc(BinOpNode(*, NumNode(1), NumNode(2))) == NumVal(2)
			@test calc(BinOpNode(*, NumNode(1), NumNode(2))) == NumVal(2)
		end 
		@testset "Divide" begin
			@test calc(BinOpNode(/, NumNode(1), NumNode(2))) == NumVal(1/2)
			@test calc(BinOpNode(/, NumNode(1), NumNode(2))) == NumVal(1/2)
			@test_throws LispError calc(BinOpNode(/, NumNode(1), NumNode(0)))
		end 
		@testset "Mod" begin
			@test calc(BinOpNode(mod, NumNode(1), NumNode(2))) == NumVal(1)
			@test calc(BinOpNode(mod, NumNode(1), NumNode(2))) == NumVal(1)
			@test_throws LispError calc(BinOpNode(mod, NumNode(1), NumNode(0)))
		end
	end
end
"Finished RudInt"