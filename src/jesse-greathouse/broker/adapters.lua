-- adapters for conforming objects to models
local models = require "models"

local function new()
    local adapters = {}

    function adapters.google_user(r)
        local map = {
            full_name   = r.name,
            first_name  = r.given_name,
            last_name   = r.family_name,
            avatar_url  = r.image_url,
            email       = r.email
        }

        local user = models.User(map)
        return user
    end

    function adapters.google_token(r)
        local map = {
            id = r.id_token,
            type = models.GOOGLE_TOKEN_TYPE
        }
        local token = models.Token(map)
        return token;
    end

    function adapters.facebook_user(r)
        local map = {
            full_name   = r.name,
            first_name  = r.first_name,
            last_name   = r.last_name,
            avatar_url  = r.image_url,
            email       = r.email
        }

        local user = models.User(map)
        return user
    end

    function adapters.facebook_token(r)
        local map = {
            id = r.id_token,
            type = models.FACEBOOK_TOKEN_TYPE
        }
        local token = models.Token(map)
        return token;
    end

    return adapters
end

return new()