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