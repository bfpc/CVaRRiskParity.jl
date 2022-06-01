# CVaRRiskParity

CVaRRiskParity is a package designed to calculate long-only weights for
CV@R Risk Parity and Risk Budgeting portfolios,
given arbitrary simulations of relative losses of each asset.

Currently, it implements a cutting plane algorithm
with dedicated initialization for numerical stability and performance,
allowing for several thousand simulations.
It also implements two stochastic gradient algorithms,
taking samples from a user-defined function that allows for
arbitrary distributions.
One is based on the Lagrangian reformulation of the problem,
while the other is a projected version into the feasible domain.

# Simple usage

We generate a simple $3 \times 10$ matrix of simulations,
and evaluate the 0.9-CV@R risk parity portfolio (`B = ones`).

```julia
using Random: MersenneTwister
using CVaRRiskParity

rng = MersenneTwister(1)

# Parameters
d    = 3  # dimension
nsim = 10 # Nb of simulations

B = ones(d)
alpha = 0.90
relative_losses = randn(rng, d, nsim)

status, w = cvar_rbp(B, alpha, relative_losses)
@assert status == 0
@assert isapprox(w, [0.2280, 0.2706, 0.5014]; atol=1e-4)
```

# Example using JuliaCall from R
