__precompile__(false)

module Julianda

# TODO: Expand the structs with full JSON info (Can be found on the definitions page of oanda)
# TODO: Add full DocStrings
# TODO: Replace if statements with try catch

include("Order.jl")
include("Position.jl")
include("Trade.jl")
include("Account.jl")
include("Config.jl")
include("Instrument.jl")
include("Transaction.jl")
include("Pricing.jl")

end
