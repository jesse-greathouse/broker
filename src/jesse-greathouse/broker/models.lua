-- models representing domain objects
local GOOGLE_TOKEN_TYPE = "GOOGLE_TOKEN_TYPE"
local FACEBOOK_TOKEN_TYPE = "FACEBOOK_TOKEN_TYPE"

local function new()
    local models = {
        GOOGLE_TOKEN_TYPE = GOOGLE_TOKEN_TYPE,
        FACEBOOK_TOKEN_TYPE = FACEBOOK_TOKEN_TYPE
    }

    function models.User(u)
        local user = u or {}
        user.full_name = u.full_name or ""
        user.first_name = u.first_name or ""
        user.last_name = u.last_name or ""
        user.avatar_url = u.avatar_url or ""
        user.email = u.email or ""
        return user
    end
    
    function models.Token(t)
        local token = t or {}
        token.id = t.id or ""
        token.type = t.type or nil
        return token
    end

    return models
end

return new()