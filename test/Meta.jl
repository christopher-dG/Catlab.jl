module TestMeta

using Base.Test
using Catlab.Meta

strip_all(expr) = strip_lines(expr, recurse=true)
parse_fun(expr) = parse_function(strip_all(expr))

# Function generation
@test (generate_function(JuliaFunction(:(f(x,y)))) ==
       strip_all(:(function f(x,y) end)))
@test (generate_function(JuliaFunction(:(f(x::Int,y::Int)), :Int)) ==
       strip_all(:(function f(x::Int,y::Int)::Int end)))
@test (generate_function(JuliaFunction(:(f(x)), :Bool, :(isnull(x)))) ==
       strip_all(:(function f(x)::Bool isnull(x) end)))
@test (generate_function(JuliaFunction(:(f(x)), :Bool, :(isnull(x)), "Is null")) ==
       strip_all(quote
       """Is null"""
       function f(x)::Bool
         isnull(x)
       end
     end).args[1])

# Function parsing
@test_throws ParseError parse_fun(:(f(x,y)))
@test (parse_fun(:(function f(x,y) x end)) == 
       JuliaFunction(:(f(x,y)), Nullable(), quote x end))

@test parse_fun((quote
  """ My docstring
  """
  function f(x,y) x end
end).args[1]) == JuliaFunction(:(f(x,y)), Nullable(), quote x end, " My docstring\n")

@test (parse_fun(:(function f(x::Int,y::Int)::Int x end)) == 
       JuliaFunction(:(f(x::Int,y::Int)), :Int, quote x end))

@test (parse_fun(:(f(x,y) = x)) == 
       JuliaFunction(:(f(x,y)), Nullable(), quote x end))

sig = JuliaFunctionSig(:f, [:Int,:Int])
@test parse_function_sig(:(f(x::Int,y::Int))) == sig
@test parse_function_sig(:(f(::Int,::Int))) == sig
@test parse_function_sig(:(f(x,y))) == JuliaFunctionSig(:f, [:Any,:Any])

# Type transformations
bindings = Dict((:r => :R, :s => :S, :t => :T))
@test replace_symbols(bindings, :(foo(x::r,y::s)::t)) == :(foo(x::R,y::S)::T)
@test replace_symbols(bindings, :(foo(xs::Vararg{r}))) == :(foo(xs::Vararg{R}))

end
