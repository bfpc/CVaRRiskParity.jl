# Copyright (C) 2021 - 2022 Bernardo Freitas Paulo da Costa
#
# This file is part of CVaRRiskParity.jl.
#
# CVaRRiskParity.jl is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# CVaRRiskParity.jl is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# CVaRRiskParity.jl. If not, see <https://www.gnu.org/licenses/>.

"""
    CVaR(α)

The conditional value at risk (CV@R) for a random variable Z.

Computes the expectation of the outcomes above the α quantile.
α must be in `[0,1]`; if `α=0`, this is equivalent to the Expectation.

CV@R is also known as average value at risk (AV@R) and expected shortfall (ES).
"""
struct CVaR <: AbstractRiskMeasure
    α::Float64
    function CVaR(α::Float64)
        if !(0 <= α <= 1)
            throw(ArgumentError("Quantile α must be in [0,1]. ($(α) given)."))
        end
        return new(α)
    end
end

function value_function(measure::CVaR, w::Vector, losses::Array{Float64,2})
    β = 1 - measure.α

    n = size(losses, 2)
    realized_losses = losses' * w
    acc_events = 0
    acc_value = 0.0
    for i in sortperm(realized_losses, rev=true)
        acc_events >= n*β && break
        cur_weight = min(1, n*β - acc_events)
        acc_events += 1
        acc_value  += cur_weight * realized_losses[i]
    end
    return acc_value / β
end


"""
    Entropic(γ)

The entropic risk of a random variable Z: 1/γ log E[ exp(γZ) ]
"""
struct Entropic <: AbstractRiskMeasure
    γ::Float64
    function Entropic(γ::Float64)
        if γ <= 0
            throw(ArgumentError("Scale γ must be positive. ($(γ) given)."))
        end
        return new(γ)
    end
end

function value_function(measure::Entropic, w::Vector, losses::Array{Float64,2})
    n = size(losses, 2)
    curmax = -Inf
    for i = 1:n
        li = @view losses[:,i]
        curmax = max(curmax, li'w)
    end

    acc = 0.0
    for i = 1:n
        li = @view losses[:,i]
        acc += exp(measure.γ * (li'w - curmax))
    end
    return curmax + log(acc)/measure.γ
end


"""
    WorstCase()

The worst-case scenario.
"""
struct WorstCase <: AbstractRiskMeasure end

function value_function(measure::WorstCase, w::Vector, losses::Array{Float64,2})
    n = size(losses, 2)
    curmax = -Inf
    for i = 1:n
        li = @view losses[:,i]
        curmax = max(curmax, li'w)
    end
    return curmax
end


