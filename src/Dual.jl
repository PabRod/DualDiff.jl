export Dual

""" Structure representing a Dual DualNumber """
struct Dual <: Number
    x::Real
    dx::Real

    """ Default constructor """
    function Dual(x::Real, dx::Real=0)::Dual
        new(x, dx)
    end

end

## Redefine base operators

## Comparers
import Base: ==, !=, >, >=, <, <=

==(self::Dual, other::Dual) = (self.x == other.x) && (self.dx == other.dx)
>(self::Dual, other::Dual) = self.x > other.x
>=(self::Dual, other::Dual) = self.x >= other.x
<(self::Dual, other::Dual) = self.x < other.x
<=(self::Dual, other::Dual) = self.x <= other.x

## Algebraic operators
import Base: +, -, *, /, \, ^

-(z::Dual) = Dual(-z.x, -z.dx)

function +(self::Union{Integer,Dual}, other::Union{Integer,Dual})::Dual
    self, other = Dual(self), Dual(other) # Coerce into Dual
    return Dual(self.x + other.x, self.dx + other.dx)
end

function -(self::Union{Integer,Dual}, other::Union{Integer,Dual})::Dual
    self, other = Dual(self), Dual(other) # Coerce into Dual
    return self + (-other)
end

function *(self::Union{Integer, Dual}, other::Union{Integer, Dual})::Dual
    self, other = Dual(self), Dual(other) # Coerce into Dual
    y = self.x * other.x
    dy = self.dx * other.x + self.x * other.dx
    return Dual(y, dy)
end

function /(self::Union{Integer, Dual}, other::Union{Integer, Dual})::Dual
    self, other = Dual(self), Dual(other) # Coerce into Dual
    y = self.x / other.x
    dy = (self.dx * other.x - self.x * other.dx) / (other.x)^2
    return Dual(y, dy)
end

function \(self::Dual, other::Dual)::Dual
    return other / self
end

function ^(self::Union{Integer, Dual}, other::Dual)::Dual
    self = Dual(self)
    y = self.x^other.x
    if other.dx == 0 # This corresponds to the case u(x)^k
        dy = other.x * self.x^(other.x - 1) * self.dx
    else # This corresponds to the more general case u(x)^v(x), but involves a logarithm that turns complex for negative numbers
        dy = other.x * self.x^(other.x - 1) * self.dx + self.x^other.x * log(self.x) * other.dx
    end
    return Dual(y, dy)
end