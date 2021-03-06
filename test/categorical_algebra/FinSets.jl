module TestFinSets
using Test

using Catlab.Theories
using Catlab.CategoricalAlgebra.ShapeDiagrams, Catlab.CategoricalAlgebra.FinSets

# Category of finite ordinals
#############################

f = FinFunction([1,3,4], 5)
g = FinFunction([1,1,2,2,3], 3)
h = FinFunction([3,1,2], 3)

# Evaluation.
@test map(f, 1:3) == [1,3,4]
@test map(id(FinSet(3)), 1:3) == [1,2,3]
@test map(FinFunction(x -> (x % 3) + 1, 3, 3), 1:3) == [2,3,1]

# Composition and identities.
@test dom(f) == FinSet(3)
@test codom(f) == FinSet(5)
@test compose(f,g) == FinFunction([1,2,2], 3)
@test compose(g,h) == FinFunction([3,3,1,1,2], 3)
@test compose(compose(f,g),h) == compose(f,compose(g,h))
@test force(compose(id(dom(f)),f)) == f
@test force(compose(f,id(codom(f)))) == f

# Limits
########

# Terminal object.
@test terminal(FinSet{Int}) == FinSet(1)

# Binary Product.
span = product(FinSet(2), FinSet(3))
@test apex(span) == FinSet(6)
@test force(left(span)) == FinFunction([1,2,1,2,1,2])
@test force(right(span)) == FinFunction([1,1,2,2,3,3])

# N-ary Product.
cone = product([FinSet(2), FinSet(3)])
@test apex(cone) == FinSet(6)
@test force(leg(cone,1)) == FinFunction([1,2,1,2,1,2])
@test force(leg(cone,2)) == FinFunction([1,1,2,2,3,3])
@test apex(product(FinSet{Int}[])) == FinSet(1)

# Equalizer.
f, g = FinFunction([1,2,3]), FinFunction([3,2,1])
@test equalizer(f,g) == FinFunction([2], 3)
@test equalizer([f,g]) == FinFunction([2], 3)

# Equalizer in case of identical functions.
f = FinFunction([4,2,3,1], 5)
@test equalizer(f,f) == force(id(FinSet(4)))
@test equalizer([f,f]) == force(id(FinSet(4)))

# Equalizer matching nothing.
f, g = id(FinSet(5)), FinFunction([2,3,4,5,1], 5)
@test equalizer(f,g) == FinFunction(Int[], 5)
@test equalizer([f,g]) == FinFunction(Int[], 5)

# Pullback.
span = pullback(Cospan(FinFunction([1,1,3,2],4), FinFunction([1,1,4,2],4)))
@test apex(span) == FinSet(5)
@test force(left(span)) == FinFunction([1,2,1,2,4], 4)
@test force(right(span)) == FinFunction([1,1,2,2,4], 4)

# Pullback from a singleton set: the degenerate case of a product.
span = pullback(Cospan(FinFunction([1,1]), FinFunction([1,1,1])))
@test apex(span) == FinSet(6)
@test force(left(span)) == FinFunction([1,2,1,2,1,2])
@test force(right(span)) == FinFunction([1,1,2,2,3,3])

# Pullback using generic limit interface
f,g = FinFunction([1,1,3,2],4), FinFunction([1,1,4,2],4)
cone = limit(Diagram([FinSet(4),FinSet(4),FinSet(4)], [(1,3,f),(2,3,g)]))
@test apex(cone) == FinSet(5)
@test force(leg(cone,1)) == FinFunction([1,2,1,2,4],4)
@test force(leg(cone,2)) == FinFunction([1,1,2,2,4],4)

# Colimits
##########

# Initial object.
@test initial(FinSet{Int}) == FinSet(0)

# Binary Coproduct.
cospan = coproduct(FinSet(2), FinSet(3))
@test base(cospan) == FinSet(5)
@test left(cospan) == FinFunction([1,2], 5)
@test right(cospan) == FinFunction([3,4,5], 5)

# N-ary Coproduct.
cocone = coproduct([FinSet(2), FinSet(3)])
@test base(cocone) == FinSet(5)
@test leg(cocone,1) == FinFunction([1,2], 5)
@test leg(cocone,2) == FinFunction([3,4,5], 5)
@test base(coproduct(FinSet{Int}[])) == FinSet(0)

# Coequalizer from a singleton set.
f, g = FinFunction([1], 3), FinFunction([3], 3)
@test coequalizer(f,g) == FinFunction([1,2,1], 2)
@test coequalizer([f,g]) == FinFunction([1,2,1], 2)

# Coequalizer in case of identical functions.
f = FinFunction([4,2,3,1], 5)
@test coequalizer(f,f) == force(id(FinSet(5)))
@test coequalizer([f,f]) == force(id(FinSet(5)))

# Coequalizer identifying everything.
f, g = id(FinSet(5)), FinFunction([2,3,4,5,1], 5)
@test coequalizer(f,g) == FinFunction(repeat([1],5))
@test coequalizer([f,g]) == FinFunction(repeat([1],5))

# Pushout from the empty set: the degenerate case of the coproduct.
f, g = FinFunction(Int[], 2), FinFunction(Int[], 3)
cospan = pushout(Span(f,g))
@test base(cospan) == FinSet(5)
@test left(cospan) == FinFunction([1,2], 5)
@test right(cospan) == FinFunction([3,4,5], 5)

# Pushout from a singleton set.
f, g = FinFunction([1], 2), FinFunction([2], 3)
cospan = pushout(Span(f,g))
@test base(cospan) == FinSet(4)
h, k = left(cospan), right(cospan)
@test compose(f,h) == compose(g,k)
@test h == FinFunction([1,2], 4)
@test k == FinFunction([3,1,4], 4)

# Same thing with generic colimit interface
diag = Diagram([FinSet(1),FinSet(2),FinSet(3)],[(1,2,f), (1,3,g)])
cocone = colimit(diag)
@test base(cocone) == FinSet(4)
h, k = leg(cocone,2), leg(cocone,3)
@test compose(f,h) == compose(g,k)
@test h == FinFunction([1,2], 4)
@test k == FinFunction([3,1,4], 4)

# Pushout from a two-element set, with non-injective legs.
f, g = FinFunction([1,1], 2), FinFunction([1,2], 2)
cospan = pushout(Span(f,g))
@test base(cospan) == FinSet(2)
h, k = left(cospan), right(cospan)
@test compose(f,h) == compose(g,k)
@test h == FinFunction([1,2], 2)
@test k == FinFunction([1,1], 2)

# Same thing with generic colimit interface
diag = Diagram([FinSet(2),FinSet(2),FinSet(2)],[(1,2,f),(1,3,g)])
cocone = colimit(diag)
@test base(cocone) == FinSet(2)
h,k = leg(cocone,2), leg(cocone,3)
@test compose(f,h) == compose(g,k)
@test h == FinFunction([1,2], 2)
@test k == FinFunction([1,1], 2)

end
