-- methods for producing each endpoint of the application
local cjson = require "cjson"
local base = require "views.base"

local GoogleApiView = {}

function GoogleApiView.search()
    local session = base.get_session()
    local client = require "clients.google":new()
    local res, err = client:search(ngx.req.get_uri_args())

    if err.error then
        local view = base.get_error_view(err, "error.html", "layout.html")
        view:render()
    else
        local filter        = require "filters.google_search_api":new()
        local parser        = require "parsers.google":new({
            data = res.body,
            filter = filter,
            url = res.url,
        })
        local transformer   = require "transformers.google.json":new({parser = parser})

        ngx.say(cjson.encode(transformer:search()))
    end
end



return GoogleApiView