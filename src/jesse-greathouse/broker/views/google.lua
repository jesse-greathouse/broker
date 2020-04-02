-- methods for producing each endpoint of the application
local base = require "views.base"

local GoogleView = {}

local function get_google_view(res, tpl, layout, filter)
    local parser        = require "parsers.google"
    local view          = base.get_view(tpl, layout)
    local parse         = parser:new({
        data = res.body,
        filter = filter,
    });
    view.jsmodel        = parse:get_jsmodel()
    view.meta           = parse:get_meta()
    view.head_js        = parse:get_head_js()
    view.head_style     = parse:get_head_style()
    view.header_js      = parse:get_header_js()
    view.noscript       = parse:get_noscript()
    view.title          = parse:get_title()
    view.search_form    = parse:get_search_form()
    return parse, view
end

function GoogleView.index()
    local session = base.get_session()
    local GoogleClient = require "clients.google"
    local client = GoogleClient:new()
    local res, err = client:home(ngx.req.get_uri_args())

    if err.error then
        local view = base.get_error_view(err, "error.html", "layout.html")
        view:render()
    else
        local filter = require "filters.google":new()
        local parse, view = get_google_view(res, "google.html", "layout.html", filter)
        view.body = parse:get_body()
        view:render()
    end
end

function GoogleView.search()
    local session = base.get_session()
    local GoogleClient = require "clients.google"
    local client = GoogleClient:new()
    local res, err = client:search(ngx.req.get_uri_args())

    if err.error then
        local view = base.get_error_view(err, "error.html", "layout.html")
        view:render()
    else
        local filter        = require "filters.google_search":new()
        local parse, view   = get_google_view(res, "google_search.html", "layout.html", filter)
        view.footer_js      = parse:get_footer_js()
        view.main           = parse:get_main()
        view:render()
    end
end

function GoogleView.image_search()
    local session = base.get_session()
    local GoogleClient = require "clients.google"
    local client = GoogleClient:new()
    local res, err = client:search(ngx.req.get_uri_args())

    if err.error then
        local view =  base.get_error_view(err, "error.html", "layout.html")
        view:render()
    else
        local filter        = require "filters.google_image_search":new()
        local parse, view   = get_google_view(res, "google_image_search.html", "layout.html", filter)
        view.body           = parse:get_body()
        view:render()
    end
end

return GoogleView