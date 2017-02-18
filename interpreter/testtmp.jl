
push!(LOAD_PATH, ".")

using RudInt

using Base.Test

function lexParse(str)
  RudInt.parse(Lexer.lex(str))
end

function parseInter(str)
  RudInt.calc(lexParse(str))
end

function removeNL(str)
  replace(string(str), "\n", "")
end

function clean(f, param)
  try
    return removeNL(f(param))
  catch Y
    return Y
  end
end

println( clean( lexParse, "( - 5 )" ))
println("************")
println( clean( lexParse, " - 5 " ))
