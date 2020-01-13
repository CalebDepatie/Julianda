module Position
using JSON3, HTTP

"Individual data for positions (A Long or Short)"
mutable struct posData
    pl # The profit / Loss
    resettablePL # Profit / Loss since last reset
    units # Number of units in the trade
    unrealizedPL # Unrealized profit / loss of position

    posData() = new()
end

"Detailed Position struct from Oanda"
mutable struct position
    instrument # The instrument
    # I have both of the following to enable people with hedging enabled
    long::posData # Data for a Long trade on the position
    short::posData # Data for a Short trade on the position
    pl # The profit / loss for this position
    resettablePL # The profit / loss since last reset for this position
    unrealizedPL # The total unrealised profit / loss for this position

    position() = new()
end

"Top layer for positions endpoint"
mutable struct positionTopLayer
    positions::Vector{position}

    positionTopLayer() = new()
end

"Coerce a given Position into its proper types (Used internally)"
function coercePos(pos::position)
    pos.long.pl = parse(Float32, pos.long.pl)
    pos.long.resettablePL = parse(Float32, pos.long.resettablePL)
    pos.long.units = parse(Int32, pos.long.units)
    pos.long.unrealizedPL = parse(Float32, pos.long.unrealizedPL)

    pos.short.pl = parse(Float32, pos.short.pl)
    pos.short.resettablePL = parse(Float32, pos.short.resettablePL)
    pos.short.units = parse(Int32, pos.short.units)
    pos.short.unrealizedPL = parse(Float32, pos.short.unrealizedPL)

    pos.pl = parse(Float32, pos.pl)
    pos.resettablePL = parse(Float32, pos.resettablePL)
    pos.unrealizedPL = parse(Float32, pos.unrealizedPL)

    return pos
end

# Declaring JSON3 struct types
JSON3.StructType(::Type{Position.position}) = JSON3.Mutable()
JSON3.StructType(::Type{Position.positionTopLayer}) = JSON3.Mutable()
JSON3.StructType(::Type{Position.posData}) = JSON3.Mutable()

"""
    listPositions(config)

Returns a list of current positions
"""
function listPositions(config)
    r = HTTP.request("GET", string("https://", config.hostname,
                    "/v3/accounts/", config.account, "/positions"),
    ["Authorization" => string("Bearer ", config.token),
    "Accept-Datetime-Format" => config.datetime])
    if r.status != 200
        println(r.status)
    end
    data = JSON3.read(r.body, positionTopLayer)
    data = data.positions

    temp = Vector{position}()
    for pos in data
        pos = coercePos(pos)
        push!(temp, pos)
    end

    return temp
end

end
