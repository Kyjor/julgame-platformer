"""
    Comprehensive collection of easing functions for smooth animations.
    All functions take a value x in the range [0, 1] and return an eased value.
"""

# Linear easing (no easing)
linear(x) = x

# Sine easing functions
ease_in_sine(x) = 1 - cos(x * π/2)
ease_out_sine(x) = sin(x * π/2)
ease_in_out_sine(x) = -(cos(π * x) - 1) / 2

# Quadratic easing functions
ease_in_quad(x) = x^2
ease_out_quad(x) = 1 - (1 - x)^2
ease_in_out_quad(x) = x < 0.5 ? 2 * x^2 : 1 - (-2 * x + 2)^2 / 2

# Cubic easing functions
ease_in_cubic(x) = x^3
ease_out_cubic(x) = 1 - (1 - x)^3
ease_in_out_cubic(x) = x < 0.5 ? 4 * x^3 : 1 - (-2 * x + 2)^3 / 2

# Quartic easing functions
ease_in_quart(x) = x^4
ease_out_quart(x) = 1 - (1 - x)^4
ease_in_out_quart(x) = x < 0.5 ? 8 * x^4 : 1 - (-2 * x + 2)^4 / 2

# Quintic easing functions
ease_in_quint(x) = x^5
ease_out_quint(x) = 1 - (1 - x)^5
ease_in_out_quint(x) = x < 0.5 ? 16 * x^5 : 1 - (-2 * x + 2)^5 / 2

# Exponential easing functions
ease_in_expo(x) = x == 0 ? 0 : 2^(10 * (x - 1))
ease_out_expo(x) = x == 1 ? 1 : 1 - 2^(-10 * x)
ease_in_out_expo(x) = begin
    if x == 0
        return 0
    elseif x == 1
        return 1
    elseif x < 0.5
        return 2^(20 * x - 10) / 2
    else
        return (2 - 2^(-20 * x + 10)) / 2
    end
end

# Circular easing functions
ease_in_circ(x) = 1 - sqrt(1 - x^2)
ease_out_circ(x) = sqrt(1 - (x - 1)^2)
ease_in_out_circ(x) = x < 0.5 ? (1 - sqrt(1 - (2 * x)^2)) / 2 : (sqrt(1 - (-2 * x + 2)^2) + 1) / 2

# Back easing functions
const c1 = 1.70158
const c2 = c1 * 1.525
const c3 = c1 + 1

ease_in_back(x) = c3 * x^3 - c1 * x^2
ease_out_back(x) = 1 + c3 * (x - 1)^3 + c1 * (x - 1)^2
ease_in_out_back(x) = x < 0.5 ? ((2 * x)^2 * (c2 + 1) * 2 * x - c2) / 2 : ((2 * x - 2)^2 * (c2 + 1) * (x * 2 - 2) + c2 + 2) / 2

# Elastic easing functions
const c4 = 2 * π / 3
const c5 = 2 * π / 4.5

ease_in_elastic(x) = begin
    if x == 0
        return 0
    elseif x == 1
        return 1
    else
        return -2^(10 * x - 10) * sin((x * 10 - 10.75) * c4)
    end
end

ease_out_elastic(x) = begin
    if x == 0
        return 0
    elseif x == 1
        return 1
    else
        return 2^(-10 * x) * sin((x * 10 - 0.75) * c4) + 1
    end
end

ease_in_out_elastic(x) = begin
    if x == 0
        return 0
    elseif x == 1
        return 1
    elseif x < 0.5
        return -(2^(20 * x - 10) * sin((20 * x - 11.125) * c5)) / 2
    else
        return (2^(-20 * x + 10) * sin((20 * x - 11.125) * c5)) / 2 + 1
    end
end

# Bounce easing functions
ease_out_bounce(x) = begin
    n1 = 7.5625
    d1 = 2.75
    
    if x < 1 / d1
        return n1 * x^2
    elseif x < 2 / d1
        return n1 * (x -= 1.5 / d1) * x + 0.75
    elseif x < 2.5 / d1
        return n1 * (x -= 2.25 / d1) * x + 0.9375
    else
        return n1 * (x -= 2.625 / d1) * x + 0.984375
    end
end

ease_in_bounce(x) = 1 - ease_out_bounce(1 - x)

ease_in_out_bounce(x) = x < 0.5 ? (1 - ease_out_bounce(1 - 2 * x)) / 2 : (1 + ease_out_bounce(2 * x - 1)) / 2
