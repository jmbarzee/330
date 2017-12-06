module TestTerp

function testAll()
	testRud()
	testExt()
	testTrans()
	testHP()
    testType()
end

function testRud() 
	include("./test/RudInt.jl")
end
function testExt()
	include("./test/ExtInt.jl")
end
function testTrans()
	include("./test/TransInt.jl")
end
function testHP()
	include("./test/HPInt.jl")
end
function testType()
    include("./test/TypeCheck.jl")
end
end