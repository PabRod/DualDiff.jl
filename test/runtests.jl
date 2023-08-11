using DualDiff
using Test


"""
    _testfactory(f, df, xs = [0.0, 1.0])

    f: a function of x
    df: its exact derivative, computed manually
    xs: values to be tested
    approx: use isapprox instead of ==

    Many of the tests involve checking that the automatic derivative
    is correct. This auxiliary method simplifies the task
"""
function _testfactory(f, df; xs = LinRange(-2, 2, 10), approx=false)
    f = autodifferentiable(f)

    for x in xs
        if approx
            @test isapprox(f(x).dx, df(x))
        else
            @test f(x).dx == df(x)
        end
    end

end

@testset "Dual basics" begin

    z = Dual(2, 1)
    q = Dual(2)
    v = Dual(3, 0)

    ## Test  constructor
    @test z.x == 2
    @test z.dx == 1
    @test q.x == 2
    @test q.dx == 0
    @test Dual(z) == z

    ## Test equality operator
    @test z == Dual(2, 1)
    @test z != Dual(2, 0)
    @test z != Dual(0, 1)
    @test z < v

end

@testset "Dual addition" begin

    u = Dual(2, 1)
    v = Dual(1, 0)
    y = Dual(3, 1)

    @test u == +u
    @test y == u + v
    @test y == v + u

end

@testset "Dual subtraction" begin

    u = Dual(2, 1)
    v = Dual(1, 0)
    y = Dual(1, 1)

    @test u - v == y
    @test v - u == -y

end

@testset "Dual multiplication" begin

    u = Dual(2, 1)
    v = Dual(3, 0)
    y = Dual(6, 3)
   
    @test u * v == y
    @test v * u == y

end

@testset "Dual division" begin
    
    u = Dual(4, 1)
    v = Dual(2, 2)

    @test u / v == Dual(4 / 2, 
                        (2*1 - 2*4)/2^2)
    
    @test v / u == Dual(2 / 4, 
                        (4*2 - 2)/4^2)
end

@testset "Dual powers" begin

    # Dual^Number
    u = Dual(4, 1)
    y = Dual(64, 3*4^2)

    @test u^3 == y

    # Number^Dual
    q = Dual(3, 1)
    z = Dual(8, log(2)*2^3)
    
    @test 2^q == z

    # Dual^Dual
    @test u^q == Dual(4^3, 4^3 * log(4) + 3*4^(3-1))

end

@testset "Algebraic functions" begin

    u = Dual(4, 1)

    P = x -> 2*x^3 - 5*x + 1
    Q = x -> x^2 - 1
    PQ = x -> P(x) * Q(x)
    PQi = x -> P(x) / Q(x)

    # References (calculated manually)
    dP = x -> 6*x^2 - 5
    dQ = x -> 2*x

    @test P(u).dx == dP(u).x
    @test Q(u).dx == dQ(u).x
    @test PQ(u).dx == P(u).dx * Q(u).x + P(u).x * Q(u).dx # Product rule
    @test PQi(u).dx == (P(u).dx * Q(u).x - P(u).x * Q(u).dx) / Q(u).x^2 # Quotient rule
    @test P(Q(u)).dx == dP(Q(u).x) * dQ(u).x * u.dx # Chain rule

end

@testset "Transcendent functions" begin
    _testfactory(sin, cos)
    _testfactory(cos, x -> -sin(x))
    _testfactory(tan, x -> 1 / cos(x)^2)
    _testfactory(exp, exp)
end

@testset "Composite functions" begin
    _testfactory(
        x -> exp(cos(x^2)),
        x -> -2 * exp(cos(x^2)) * sin(x^2) * x,
        approx = true
    )
end

@testset "Defined programatically" begin

    """ Just a code-intense way of expressing a polynomial of 3rd degree"""
    function p(x)
        v = 0
        for n in [0, 1, 2, 3]
            v += x^n
        end

        return v
    end

    _testfactory(p, x -> 3x^2 + 2x + 1)

end

@testset "Decorator" begin
    _testfactory(
        x -> exp(cos(x^2)),
        x -> -2 * exp(cos(x^2)) * sin(x^2) * x,
        approx = true
    )
end