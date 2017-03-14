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
	Terp.MatNode,
	Terp.MatOpNode,
	Terp.MatSaveNode,
	Terp.MatLoadNode,
	Terp.RenderTextNode,

	Terp.emboss,
	Terp.drop_shadow,
	Terp.inner_shadow,

	Terp.parse,
	Terp.interp,
	Terp.analyze,
	Terp.exec,
	Terp.calc,

	Terp.mtEnv,
	Terp.CEnvironment,

    Terp.NumVal,
    Terp.ClosureVal,
    Terp.MatrixVal
# end imports

function normArr(num)
	if num == 1
		return Array{Float32}([0 1; 3 4])
	elseif num == 2
		return Array{Float32}([5 6; 8 9])
	elseif num == 3
		return Array{Float32}([-1 -2; -4 -5])
	else 
		return Array{Float32}([0 0; 0 0])
	end
end

@testset "HPInt" begin
	@testset "Parsing" begin
		@testset "Reserved Words" begin
			@testset "Simple Ids" begin
				@test_throws LispError parse([:simple_load])
				@test_throws LispError parse([:simple_save])
				@test_throws LispError parse([:render_text])
				@test_throws LispError parse([:emboss])
				@test_throws LispError parse([:drop_shadow])
				@test_throws LispError parse([:inner_shadow])
				@test_throws LispError parse([:min])
				@test_throws LispError parse([:max])
			end
			@testset "With Ids" begin
				@test_throws LispError  parse([:with, [[:simple_load, 1]], 1])
				@test_throws LispError  parse([:with, [[:simple_save, 1]], 1])
				@test_throws LispError  parse([:with, [[:render_text, 1]], 1])
				@test_throws LispError  parse([:with, [[:emboss, 1]], 1])
				@test_throws LispError  parse([:with, [[:drop_shadow, 1]], 1])
				@test_throws LispError  parse([:with, [[:inner_shadow, 1]], 1])
				@test_throws LispError  parse([:with, [[:min, 1]], 1])
				@test_throws LispError  parse([:with, [[:max, 1]], 1])
			end
			@testset "Lambda Ids" begin
				@test_throws LispError  parse([[:lambda, [:simple_save], 1], 2])
				@test_throws LispError  parse([[:lambda, [:simple_load], 1], 2])
				@test_throws LispError  parse([[:lambda, [:render_text], 1], 2])
				@test_throws LispError  parse([[:lambda, [:emboss], 1], 2])
				@test_throws LispError  parse([[:lambda, [:drop_shadow], 1], 2])
				@test_throws LispError  parse([[:lambda, [:inner_shadow], 1], 2])
				@test_throws LispError  parse([[:lambda, [:min], 1], 2])
				@test_throws LispError  parse([[:lambda, [:max], 1], 2])
			end
		end
		@testset "Matrix" begin
			@test parse(normArr(1)) == MatNode(normArr(1))
			@test parse(normArr(2)) == MatNode(normArr(2))
			@test parse(normArr(3)) == MatNode(normArr(3))
		end 
		@testset "Plus" begin
			@test parse([:+, normArr(1), normArr(2)]) == AddNode([MatNode(normArr(1)), MatNode(normArr(2))])
			@test parse([:+, normArr(1), normArr(2), normArr(3)]) == AddNode([MatNode(normArr(1)), MatNode(normArr(2)), MatNode(normArr(3))])
			@test parse([:+, normArr(1), normArr(2), normArr(3), normArr(4)]) == AddNode([MatNode(normArr(1)), MatNode(normArr(2)), MatNode(normArr(3)), MatNode(normArr(4))])
			@test parse([:+, 1, normArr(2)]) == AddNode([NumNode(1), MatNode(normArr(2))])
			@test parse([:+, normArr(1), 2]) == AddNode([MatNode(normArr(1)), NumNode(2)])
			@test parse([:+, :a, normArr(2)]) == AddNode([IdNode(:a), MatNode(normArr(2))])
			@test parse([:+, normArr(1), :a]) == AddNode([MatNode(normArr(1)), IdNode(:a)])
		end
		@testset "Minus" begin
			@test parse([:-, normArr(1)]) == UnOpNode(-, MatNode(normArr(1)))
			@test parse([:-, normArr(1), normArr(2)]) == BinOpNode(.-, MatNode(normArr(1)), MatNode(normArr(2)))
			@test parse([:-, 1, normArr(2)]) == BinOpNode(.-, NumNode(1), MatNode(normArr(2)))
			@test parse([:-, normArr(1), 2]) == BinOpNode(.-, MatNode(normArr(1)), NumNode(2))
			@test parse([:-, :a, normArr(2)]) == BinOpNode(.-, IdNode(:a), MatNode(normArr(2)))
			@test parse([:-, normArr(1), :a]) == BinOpNode(.-, MatNode(normArr(1)), IdNode(:a))
		end 
		@testset "Multiply" begin
			@test parse([:*, normArr(1), normArr(2)]) == BinOpNode(.*, MatNode(normArr(1)), MatNode(normArr(2)))
			@test parse([:*, 1, normArr(2)]) == BinOpNode(.*, NumNode(1), MatNode(normArr(2)))
			@test parse([:*, normArr(1), 2]) == BinOpNode(.*, MatNode(normArr(1)), NumNode(2))
			@test parse([:*, :a, normArr(2)]) == BinOpNode(.*, IdNode(:a), MatNode(normArr(2)))
			@test parse([:*, normArr(1), :a]) == BinOpNode(.*, MatNode(normArr(1)), IdNode(:a))
		end 
		@testset "Divide" begin
			@test parse([:/, normArr(1), normArr(2)]) == BinOpNode(./, MatNode(normArr(1)), MatNode(normArr(2)))
			@test parse([:/, 1, normArr(2)]) == BinOpNode(./, NumNode(1), MatNode(normArr(2)))
			@test parse([:/, normArr(1), 2]) == BinOpNode(./, MatNode(normArr(1)), NumNode(2))
			@test parse([:/, :a, normArr(2)]) == BinOpNode(./, IdNode(:a), MatNode(normArr(2)))
			@test parse([:/, normArr(1), :a]) == BinOpNode(./, MatNode(normArr(1)), IdNode(:a))
		end 
		@testset "simple_load" begin
			@test_throws LispError parse([:simple_load])
			@test parse([:simple_load, "path_to_file"]) == MatLoadNode("path_to_file")
			@test_throws LispError parse([:simple_load, "path_to_file", "p2"])
			@test_throws LispError parse([:simple_load, 0])
			@test_throws LispError parse([:simple_load, :id])
			@test_throws LispError parse([:simple_load, normArr(1)])
		end 
		@testset "simple_save" begin
			@test_throws LispError parse([:simple_save])
			@test_throws LispError parse([:simple_save, 0])
			@test_throws LispError parse([:simple_save, :id])
			@test parse([:simple_save, normArr(1), "path_to_file"]) == MatSaveNode(MatNode(normArr(1)),"path_to_file")
			@test_throws LispError parse([:simple_save, normArr(1), "path_to_file", "p2"])
			@test_throws LispError parse([:simple_save, normArr(1), 0, "path_to_file"])
			@test_throws LispError parse([:simple_save, normArr(1), :id, "path_to_file"])
		end 
		@testset "render_text" begin
			@test_throws LispError parse([:render_text])
			@test_throws LispError parse([:render_text, "text_to_render", 1])
			@test parse([:render_text, "text_to_render", 1, 2]) == RenderTextNode("text_to_render",NumNode(1),NumNode(2))
			@test_throws LispError parse([:render_text, "text_to_render", 1, 2, 3])
			@test_throws LispError parse([:render_text, "text_to_render", :a])
			@test parse([:render_text, "text_to_render", :a, :b]) == RenderTextNode("text_to_render",IdNode(:a),IdNode(:b))
			@test_throws LispError parse([:render_text, "text_to_render", :a, :b, :c])
		end 
		@testset "emboss" begin
			@test_throws LispError parse([:emboss])
			@test parse([:emboss, 1]) == MatOpNode(emboss, NumNode(1))
			@test parse([:emboss, :a]) == MatOpNode(emboss, IdNode(:a))
			@test parse([:emboss, normArr(1)]) == MatOpNode(emboss, MatNode(normArr(1)))
			@test_throws LispError parse([:emboss, 1, 2])
			@test_throws LispError parse([:emboss, :a, :b])
			@test_throws LispError parse([:emboss, normArr(1), normArr(2)])
		end 
		@testset "drop_shadow" begin
			@test_throws LispError parse([:drop_shadow])
			@test parse([:drop_shadow, 1]) == MatOpNode(drop_shadow, NumNode(1))
			@test parse([:drop_shadow, :a]) == MatOpNode(drop_shadow, IdNode(:a))
			@test parse([:drop_shadow, normArr(1)]) == MatOpNode(drop_shadow, MatNode(normArr(1)))
			@test_throws LispError parse([:drop_shadow, 1, 2])
			@test_throws LispError parse([:drop_shadow, :a, :b])
			@test_throws LispError parse([:drop_shadow, normArr(1), normArr(2)])
		end 
		@testset "inner_shadow" begin
			@test_throws LispError parse([:inner_shadow])
			@test parse([:inner_shadow, 1]) == MatOpNode(inner_shadow, NumNode(1))
			@test parse([:inner_shadow, :a]) == MatOpNode(inner_shadow, IdNode(:a))
			@test parse([:inner_shadow, normArr(1)]) == MatOpNode(inner_shadow, MatNode(normArr(1)))
			@test_throws LispError parse([:inner_shadow, 1, 2])
			@test_throws LispError parse([:inner_shadow, :a, :b])
			@test_throws LispError parse([:inner_shadow, normArr(1), normArr(2)])
		end 
		@testset "min" begin
			@test_throws LispError parse([:min])
			@test_throws LispError parse([:min, 1])
			@test parse([:min, 1, 2]) == BinOpNode(min, NumNode(1) , NumNode(2))
			@test_throws LispError parse([:min, 1, 2, 3])
			@test_throws LispError parse([:min, :a])
			@test parse([:min, :a, :b]) == BinOpNode(min, IdNode(:a) , IdNode(:b))
			@test_throws LispError parse([:min, :a, :b, :c])
			@test_throws LispError parse([:min, normArr(1)])
			@test parse([:min, normArr(1), normArr(2)]) == BinOpNode(min, MatNode(normArr(1)) , MatNode(normArr(2)))
			@test_throws LispError parse([:min, normArr(1), normArr(2), normArr(3)])
			@test parse([:min, 1, normArr(2)]) == BinOpNode(min, NumNode(1), MatNode(normArr(2)))
			@test parse([:min, normArr(1), 2]) == BinOpNode(min, MatNode(normArr(1)), NumNode(2))
			@test parse([:min, :a, normArr(2)]) == BinOpNode(min, IdNode(:a), MatNode(normArr(2)))
			@test parse([:min, normArr(1), :a]) == BinOpNode(min, MatNode(normArr(1)), IdNode(:a))
		end 
		@testset "max" begin
			@test_throws LispError parse([:max])
			@test_throws LispError parse([:max, 1])
			@test parse([:max, 1, 2]) == BinOpNode(max, NumNode(1) , NumNode(2))
			@test_throws LispError parse([:max, 1, 2, 3])
			@test_throws LispError parse([:max, :a])
			@test parse([:max, :a, :b]) == BinOpNode(max, IdNode(:a) , IdNode(:b))
			@test_throws LispError parse([:max, :a, :b, :c])
			@test_throws LispError parse([:max, normArr(1)])
			@test parse([:max, normArr(1), normArr(2)]) == BinOpNode(max, MatNode(normArr(1)) , MatNode(normArr(2)))
			@test_throws LispError parse([:max, normArr(1), normArr(2), normArr(3)])
			@test parse([:max, 1, normArr(2)]) == BinOpNode(max, NumNode(1), MatNode(normArr(2)))
			@test parse([:max, normArr(1), 2]) == BinOpNode(max, MatNode(normArr(1)), NumNode(2))
			@test parse([:max, :a, normArr(2)]) == BinOpNode(max, IdNode(:a), MatNode(normArr(2)))
			@test parse([:max, normArr(1), :a]) == BinOpNode(max, MatNode(normArr(1)), IdNode(:a))
		end
	end
	@testset "Analyze" begin
		@testset "Matrix" begin
			@test analyze(MatNode(normArr(1))) == MatNode(normArr(1))
			@test analyze(MatNode(normArr(2))) == MatNode(normArr(2))
			@test analyze(MatNode(normArr(3))) == MatNode(normArr(3))
		end 
		@testset "Plus" begin
			@test analyze(AddNode([MatNode(normArr(1)), MatNode(normArr(2))])) == BinOpNode(.+, MatNode(normArr(1)), MatNode(normArr(2)))
			@test analyze(AddNode([MatNode(normArr(1)), MatNode(normArr(2)), MatNode(normArr(3))])) == BinOpNode(.+, MatNode(normArr(1)), BinOpNode(.+, MatNode(normArr(2)), MatNode(normArr(3))))
			@test analyze(AddNode([MatNode(normArr(1)), MatNode(normArr(2)), MatNode(normArr(3)), MatNode(normArr(4))])) == BinOpNode(.+, MatNode(normArr(1)), BinOpNode(.+, MatNode(normArr(2)), BinOpNode(.+, MatNode(normArr(3)), MatNode(normArr(4)))))
			@test analyze(AddNode([NumNode(1), MatNode(normArr(2))])) == BinOpNode(.+, NumNode(1), MatNode(normArr(2)))
			@test analyze(AddNode([MatNode(normArr(1)), NumNode(2)])) == BinOpNode(.+, MatNode(normArr(1)), NumNode(2))
			@test analyze(AddNode([IdNode(:a), MatNode(normArr(2))])) == BinOpNode(.+, IdNode(:a), MatNode(normArr(2)))
			@test analyze(AddNode([MatNode(normArr(1)), IdNode(:a)])) == BinOpNode(.+, MatNode(normArr(1)), IdNode(:a))
		end
		@testset "Minus" begin
			@test analyze(UnOpNode(.-, MatNode(normArr(1)))) == UnOpNode(.-, MatNode(normArr(1)))
			@test analyze(BinOpNode(.-, MatNode(normArr(1)), MatNode(normArr(2)))) == BinOpNode(.-, MatNode(normArr(1)), MatNode(normArr(2)))
			@test analyze(BinOpNode(.-, NumNode(1), MatNode(normArr(2)))) == BinOpNode(.-, NumNode(1), MatNode(normArr(2)))
			@test analyze(BinOpNode(.-, MatNode(normArr(1)), NumNode(2))) == BinOpNode(.-, MatNode(normArr(1)), NumNode(2))
			@test analyze(BinOpNode(.-, IdNode(:a), MatNode(normArr(2)))) == BinOpNode(.-, IdNode(:a), MatNode(normArr(2)))
			@test analyze(BinOpNode(.-, MatNode(normArr(1)), IdNode(:a))) == BinOpNode(.-, MatNode(normArr(1)), IdNode(:a))
		end 
		@testset "Multiply" begin
			@test analyze(BinOpNode(.*, MatNode(normArr(1)), MatNode(normArr(2)))) == BinOpNode(.*, MatNode(normArr(1)), MatNode(normArr(2)))
			@test analyze(BinOpNode(.*, NumNode(1), MatNode(normArr(2)))) == BinOpNode(.*, NumNode(1), MatNode(normArr(2)))
			@test analyze(BinOpNode(.*, MatNode(normArr(1)), NumNode(2))) == BinOpNode(.*, MatNode(normArr(1)), NumNode(2))
			@test analyze(BinOpNode(.*, IdNode(:a), MatNode(normArr(2)))) == BinOpNode(.*, IdNode(:a), MatNode(normArr(2)))
			@test analyze(BinOpNode(.*, MatNode(normArr(1)), IdNode(:a))) == BinOpNode(.*, MatNode(normArr(1)), IdNode(:a))
		end 
		@testset "Divide" begin
			@test analyze(BinOpNode(./, MatNode(normArr(1)), MatNode(normArr(2)))) == BinOpNode(./, MatNode(normArr(1)), MatNode(normArr(2)))
			@test analyze(BinOpNode(./, NumNode(1), MatNode(normArr(2)))) == BinOpNode(./, NumNode(1), MatNode(normArr(2)))
			@test analyze(BinOpNode(./, MatNode(normArr(1)), NumNode(2))) == BinOpNode(./, MatNode(normArr(1)), NumNode(2))
			@test analyze(BinOpNode(./, IdNode(:a), MatNode(normArr(2)))) == BinOpNode(./, IdNode(:a), MatNode(normArr(2)))
			@test analyze(BinOpNode(./, MatNode(normArr(1)), IdNode(:a))) == BinOpNode(./, MatNode(normArr(1)), IdNode(:a))
		end 
		@testset "simple_load" begin
			@test analyze(MatLoadNode("path_to_file")) == MatLoadNode("path_to_file")
		end 
		@testset "simple_save" begin
			@test analyze(MatSaveNode(MatNode(normArr(1)),"path_to_file")) == MatSaveNode(MatNode(normArr(1)),"path_to_file")
		end 
		@testset "render_text" begin
			@test analyze(RenderTextNode("text_to_render",NumNode(1),NumNode(2))) == RenderTextNode("text_to_render",NumNode(1),NumNode(2))
			@test analyze(RenderTextNode("text_to_render",IdNode(:a),IdNode(:b))) == RenderTextNode("text_to_render",IdNode(:a),IdNode(:b))
		end 
		@testset "emboss" begin
			@test analyze(MatOpNode(emboss, NumNode(1))) == MatOpNode(emboss, NumNode(1))
			@test analyze(MatOpNode(emboss, IdNode(:a))) == MatOpNode(emboss, IdNode(:a))
			@test analyze(MatOpNode(emboss, MatNode(normArr(1)))) == MatOpNode(emboss, MatNode(normArr(1)))
		end 
		@testset "drop_shadow" begin
			@test analyze(MatOpNode(drop_shadow, NumNode(1))) == MatOpNode(drop_shadow, NumNode(1))
			@test analyze(MatOpNode(drop_shadow, IdNode(:a))) == MatOpNode(drop_shadow, IdNode(:a))
			@test analyze(MatOpNode(drop_shadow, MatNode(normArr(1)))) == MatOpNode(drop_shadow, MatNode(normArr(1)))
		end 
		@testset "inner_shadow" begin
			@test analyze(MatOpNode(inner_shadow, NumNode(1))) == MatOpNode(inner_shadow, NumNode(1))
			@test analyze(MatOpNode(inner_shadow, IdNode(:a))) == MatOpNode(inner_shadow, IdNode(:a))
			@test analyze(MatOpNode(inner_shadow, MatNode(normArr(1)))) == MatOpNode(inner_shadow, MatNode(normArr(1)))
		end
		@testset "min" begin
			@test analyze(BinOpNode(min, NumNode(1) , NumNode(2))) == BinOpNode(min, NumNode(1) , NumNode(2))
			@test analyze(BinOpNode(min, IdNode(:a) , IdNode(:b))) == BinOpNode(min, IdNode(:a) , IdNode(:b))
			@test analyze(BinOpNode(min, MatNode(normArr(1)) , MatNode(normArr(2)))) == BinOpNode(min, MatNode(normArr(1)) , MatNode(normArr(2)))
			@test analyze(BinOpNode(min, NumNode(1), MatNode(normArr(2)))) == BinOpNode(min, NumNode(1), MatNode(normArr(2)))
			@test analyze(BinOpNode(min, MatNode(normArr(1)), NumNode(2))) == BinOpNode(min, MatNode(normArr(1)), NumNode(2))
			@test analyze(BinOpNode(min, IdNode(:a), MatNode(normArr(2)))) == BinOpNode(min, IdNode(:a), MatNode(normArr(2)))
			@test analyze(BinOpNode(min, MatNode(normArr(1)), IdNode(:a))) == BinOpNode(min, MatNode(normArr(1)), IdNode(:a))
		end 
		@testset "max" begin
			@test analyze(BinOpNode(max, NumNode(1) , NumNode(2))) == BinOpNode(max, NumNode(1) , NumNode(2))
			@test analyze(BinOpNode(max, IdNode(:a) , IdNode(:b))) == BinOpNode(max, IdNode(:a) , IdNode(:b))
			@test analyze(BinOpNode(max, MatNode(normArr(1)) , MatNode(normArr(2)))) == BinOpNode(max, MatNode(normArr(1)) , MatNode(normArr(2)))
			@test analyze(BinOpNode(max, NumNode(1), MatNode(normArr(2)))) == BinOpNode(max, NumNode(1), MatNode(normArr(2)))
			@test analyze(BinOpNode(max, MatNode(normArr(1)), NumNode(2))) == BinOpNode(max, MatNode(normArr(1)), NumNode(2))
			@test analyze(BinOpNode(max, IdNode(:a), MatNode(normArr(2)))) == BinOpNode(max, IdNode(:a), MatNode(normArr(2)))
			@test analyze(BinOpNode(max, MatNode(normArr(1)), IdNode(:a))) == BinOpNode(max, MatNode(normArr(1)), IdNode(:a))
		end
	end
	@testset "Calc" begin
		@testset "Matrix" begin
			@test calc(MatNode(normArr(1))) == MatrixVal(normArr(1))
			@test calc(MatNode(normArr(2))) == MatrixVal(normArr(2))
			@test calc(MatNode(normArr(3))) == MatrixVal(normArr(3))
		end 
		@testset "Plus" begin
			@test calc(BinOpNode(.+, MatNode(normArr(1)), MatNode(normArr(2)))) == MatrixVal(normArr(1) .+ normArr(2))
			@test calc(BinOpNode(.+, MatNode(normArr(1)), BinOpNode(.+, MatNode(normArr(2)), MatNode(normArr(3))))) == MatrixVal(normArr(1) .+ normArr(2) .+ normArr(3))
			@test calc(BinOpNode(.+, MatNode(normArr(1)), BinOpNode(.+, MatNode(normArr(2)), BinOpNode(.+, MatNode(normArr(3)), MatNode(normArr(4)))))) == MatrixVal(normArr(1) .+ normArr(2) .+ normArr(3) .+ normArr(4))
			@test calc(BinOpNode(.+, NumNode(1), MatNode(normArr(2)))) == MatrixVal(1 .+ normArr(2))
			@test calc(BinOpNode(.+, MatNode(normArr(1)), NumNode(2))) == MatrixVal(normArr(1) .+ 2)
			@test_throws LispError calc(BinOpNode(.+, IdNode(:a), MatNode(normArr(2))))
			@test_throws LispError calc(BinOpNode(.+, MatNode(normArr(1)), IdNode(:a)))
		end
		@testset "Minus" begin
			@test calc(UnOpNode(-, MatNode(normArr(1)))) == MatrixVal(-normArr(1))
			@test calc(BinOpNode(.-, MatNode(normArr(1)), MatNode(normArr(2)))) == MatrixVal(normArr(1) .- normArr(2))
			@test calc(BinOpNode(.-, NumNode(1), MatNode(normArr(2)))) == MatrixVal(1 .- normArr(2))
			@test calc(BinOpNode(.-, MatNode(normArr(1)), NumNode(2))) == MatrixVal(normArr(1) .- 2)
			@test_throws LispError calc(BinOpNode(.-, IdNode(:a), MatNode(normArr(2))))
			@test_throws LispError calc(BinOpNode(.-, MatNode(normArr(1)), IdNode(:a)))
		end 
		@testset "Multiply" begin
			@test calc(BinOpNode(.*, MatNode(normArr(1)), MatNode(normArr(2)))) == MatrixVal(normArr(1) .* normArr(2))
			@test calc(BinOpNode(.*, NumNode(2), MatNode(normArr(2)))) == MatrixVal(2 .* normArr(2))
			@test calc(BinOpNode(.*, MatNode(normArr(1)), NumNode(2))) == MatrixVal(2 .* normArr(1))
			@test_throws LispError calc(BinOpNode(.*, IdNode(:a), MatNode(normArr(2))))
			@test_throws LispError calc(BinOpNode(.*, MatNode(normArr(1)), IdNode(:a)))
		end 
		@testset "Divide" begin
			@test calc(BinOpNode(./, MatNode(normArr(1)), MatNode(normArr(2)))) == MatrixVal(normArr(1) ./ normArr(2))
			@test calc(BinOpNode(./, NumNode(1), MatNode(normArr(2)))) == MatrixVal(1 ./ normArr(2))
			@test calc(BinOpNode(./, MatNode(normArr(1)), NumNode(2))) == MatrixVal(normArr(1) ./ 2)
			@test_throws LispError calc(BinOpNode(./, IdNode(:a), MatNode(normArr(2))))
			@test_throws LispError calc(BinOpNode(./, MatNode(normArr(1)), IdNode(:a)))
		end 
		@testset "simple_load" begin
			@test_throws LispError calc(MatLoadNode("path_to_file"))
		end 
		@testset "simple_save" begin
			@test_throws LispError calc(MatSaveNode(NumNode(1),"path_to_file"))
			@test_throws LispError calc(MatSaveNode(IdNode(:a),"path_to_file"))
		end 
		@testset "render_text" begin
			@test_throws LispError calc(RenderTextNode("text_to_render",IdNode(:a),IdNode(:b)))
		end 
		@testset "emboss" begin
			@test_throws LispError calc(MatOpNode(emboss, NumNode(1)))
			@test_throws LispError calc(MatOpNode(emboss, IdNode(:a)))
		end 
		@testset "drop_shadow" begin
			@test_throws LispError calc(MatOpNode(drop_shadow, NumNode(1)))
			@test_throws LispError calc(MatOpNode(drop_shadow, IdNode(:a)))
		end 
		@testset "inner_shadow" begin
			@test_throws LispError calc(MatOpNode(inner_shadow, NumNode(1)))
			@test_throws LispError calc(MatOpNode(inner_shadow, IdNode(:a)))
		end
		@testset "min" begin
			@test calc(BinOpNode(min, NumNode(1) , NumNode(2))) == NumVal(1)
			@test_throws LispError calc(BinOpNode(min, IdNode(:a) , IdNode(:b)))
			@test calc(BinOpNode(min, MatNode(normArr(1)) , MatNode(normArr(2)))) == MatrixVal(normArr(1))
			@test calc(BinOpNode(min, NumNode(1), MatNode(normArr(2)))) == MatrixVal(Float32[1.0 1.0; 1.0 1.0])
			@test calc(BinOpNode(min, MatNode(normArr(1)), NumNode(2))) == MatrixVal(Float32[0.0 1.0; 2.0 2.0])
			@test_throws LispError calc(BinOpNode(min, IdNode(:a), MatNode(normArr(2))))
			@test_throws LispError calc(BinOpNode(min, MatNode(normArr(1)), IdNode(:a)))
		end 
		@testset "max" begin
			@test calc(BinOpNode(max, NumNode(1) , NumNode(2))) == NumVal(2)
			@test_throws LispError calc(BinOpNode(max, IdNode(:a) , IdNode(:b)))
			@test calc(BinOpNode(max, MatNode(normArr(1)) , MatNode(normArr(2)))) == MatrixVal(normArr(2))
			@test calc(BinOpNode(max, NumNode(1), MatNode(normArr(2)))) == MatrixVal(normArr(2))
			@test calc(BinOpNode(max, MatNode(normArr(1)), NumNode(2))) == MatrixVal(Float32[2.0 2.0; 3.0 4.0])
			@test_throws LispError calc(BinOpNode(max, IdNode(:a), MatNode(normArr(2))))
			@test_throws LispError calc(BinOpNode(max, MatNode(normArr(1)), IdNode(:a)))
		end
	end
	@testset "Wingate's Tests" begin
		@test exec("(with ((cat (simple_load \"./test/images/cat_256.png\"))) (simple_save cat \"./test/images/output.png\"))")
		@test exec("(with ((cat (simple_load \"./test/images/cat_256.png\"))) (simple_save (emboss cat) \"./test/images/output1.png\"))")
		@test exec("(with ((cat (simple_load \"./test/images/cat_256.png\"))) (simple_save (inner_shadow cat) \"./test/images/output2.png\"))")
		@test exec("(with ((cat (simple_load \"./test/images/cat_256.png\"))) (simple_save (drop_shadow cat) \"./test/images/output3.png\"))")
		@test exec("(with ((cat (simple_load \"./test/images/cat_256.png\"))) (simple_save (max 0.5 cat) \"./test/images/output4.png\"))")
		@test exec("(with ((cat (simple_load \"./test/images/cat_256.png\"))) (simple_save (min 0.5 cat) \"./test/images/output5.png\"))")
		@test exec("(with ((cat (simple_load \"./test/images/cat_256.png\"))) (simple_save (- 1 cat) \"./test/images/output6.png\"))")
		@test exec("(with ((cat (simple_load \"./test/images/cat_256.png\"))) (simple_save (+ cat cat) \"./test/images/output7.png\"))")
		@test exec("(with ((cat (simple_load \"./test/images/cat_256.png\"))) (simple_save (- cat cat) \"./test/images/output8.png\"))")
		@test exec("(with ((cat (simple_load \"./test/images/cat_256.png\"))) (simple_save (min (render_text \"CAT\" 40 230) cat) \"./test/images/output9.png\"))")
		@test exec("(with ((cat (simple_load \"./test/images/cat_256.png\"))) (simple_save (* (- 1 cat) cat) \"./test/images/output.png\"))")
		@test  exec(
			"(with (
				(base_img (render_text \"Hello\" 25 100))
			    (swirl (simple_load \"./test/images/swirl_256.png\"))
			    )
			    (with ((ds (drop_shadow base_img)))
			        (with ((tmp4 (+ (* (+ (min ds base_img) (- 1 base_img)) base_img) (* (- 1 base_img) swirl) )))
			            (with ((tmp5 (- 1 (emboss tmp4)))
			                    (base_img2 (render_text \"world!\" 5 200)))
			                (with ((is (inner_shadow base_img2)))
			                    (with ((tmp6 (max base_img2 (* (- 1 base_img2) is) )))
			                        (with ( (output (min tmp5 tmp6 )) )
			                            (simple_save output \"./test/images/swirl_output.png\")
			                        )
			                    )
			                )
			            )
			        )
			    )
			)"
		)
	end
end
@test "Finished HPInt"