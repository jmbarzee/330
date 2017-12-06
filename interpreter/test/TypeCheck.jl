using CITypes, Base.Test, Error

import 
	CITypes.type_of_expr
	CITypes.NumType
	CITypes.BoolType
	CITypes.FunType
	CITypes.NListType
# end imports

toe = type_of_expr


@testset "TypeCheck" begin
	@testset "Basic Types" begin
		@test toe("true") == BoolType()
		@test toe("false") == BoolType()
		@test toe("-1") == NumType()
		@test toe("0") == NumType()
		@test toe("1") == NumType()
		@test toe("nempty") == NListType()
		@test toe("(lambda x : number false)") == FunType(NumType(), BoolType())
		@test_throws LispError toe("a")
	end

	@testset "BuiltIn Functions" begin
		@test toe("(+ 1 1)") == NumType()
		@test toe("(- 1 1)") == NumType()
	    @test toe("(iszero 1)") == BoolType()
	    @test toe("(ifb true 1 2)") == NumType()
	    @test toe("(ifb true true false)") == BoolType()
	    @test toe("(ifb true nempty nempty)") == NListType()
	    @test toe("(ifb false 1 2)") == NumType()
	    @test toe("(ifb false true false)") == BoolType()
	    @test toe("(ifb false nempty nempty)") == NListType()
	    @test toe("(with x 5 x)") == NumType()
	    @test toe("(with x false x)") == BoolType()
	    @test toe("(lambda s : number s)") == FunType(NumType(), NumType())
	    @test toe("(lambda s : number false)") == FunType(NumType(), BoolType())
	    @test toe("(lambda s : number nempty)") == FunType(NumType(), NListType())
	    @test toe("(lambda s : (number : boolean) s)") == FunType(FunType(NumType(), BoolType()), FunType(NumType(),BoolType()))
	    @test toe("(lambda s : (number : boolean) false)") == FunType(FunType(NumType(), BoolType()), BoolType())
	    @test toe("(lambda s : (number : boolean) nempty)") == FunType(FunType(NumType(), BoolType()), NListType())
	    @test toe("((lambda s : number s) 5)") == NumType()
	    @test toe("((lambda s : number false) 5)") == BoolType()
	    @test toe("((lambda s : number nempty) 5)") == NListType()
	    @test toe("(nisempty nempty)") == BoolType()
	    @test toe("(nfirst nempty)") == NumType()
	    @test toe("(nrest nempty)") == NListType()
	    @test toe("(ncons 5 nempty)") == NListType()
	end
end
"Finished TypeCheck"