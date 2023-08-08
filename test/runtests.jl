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