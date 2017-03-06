module TestTerp

function testAll()
	testRud()
	testExt()
	testTrans()
	testHP()
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
end