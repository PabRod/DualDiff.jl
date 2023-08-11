using DualDiff
using Test

@testset "Dual basics" begin

    z = Dual(2, 1)
    q = Dual(2)

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
    
    u = Dual(4, 1)
    y = Dual(64, 3*4^2)

    @test u^3 == y

    #TODO: fix this
    #q = Dual(3, 1)
    #z = Dual(8, log(2)*2^3)
    #
    #@test 2^q == z

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
    @test sin(Dual(0, 1)) == Dual(0, 1)
    @test cos(Dual(0, 1)) == Dual(1, 0)
    @test tan(Dual(0, 1)) == Dual(0, 1)
    @test exp(Dual(0, 1)) == Dual(1, 1)
end

@testset "Composite functions" begin
    f = x -> exp(cos(x^2))
    df = x -> -2* exp(cos(x^2)) * sin(x^2) * x # Derivative, calculated by hand

    @test f(Dual(0, 1)).dx == df(0)
end

@testset "Defined programatically" begin

    """ Just a code-intense way of expressing a polynomial of 3rd degree"""
    function p(x)
        v = 0
        for n in [0.0, 1.0, 2.0, 3.0]
            v += x^n
        end

        return v
    end

    df = x -> 3x^2 + 2x + 1

    @test p(Dual(3, 1)).dx == df(3) 

end

@testset "Decorator" begin
    f = x -> exp(cos(x^2))
    f = autodifferentiable(f)
    df = x -> -2 * exp(cos(x^2)) * sin(x^2) * x # Derivative, calculated by hand

    @test f(0).dx == df(0)
end