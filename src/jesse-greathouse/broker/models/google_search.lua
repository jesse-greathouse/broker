local summarry = require "models.google_search_summarry"
local helpers = require "helpers"

--
-- class GoogleSearch
--
local GoogleSearch = {}

local function get_new_summarry()
    return summarry:new()
end

local defaults = {
    query               = "",
    url                 = "",
    start               = 0,
    summarry            = get_new_summarry,
    results             = {},
    related_searches    = {},
}

function GoogleSearch:new(o)
    o = o or {}
    o = helpers.model_set_defaults(o, defaults)
    self.__index = self
    setmetatable(o, self)
    return o
end

return GoogleSearch