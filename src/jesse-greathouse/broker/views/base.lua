-- methods for producing each endpoint of the application
local helpers = require "helpers"

local M = {}

local function get_template_name(tpl)
    return string.match(tpl, "([%a|_]+)%.html")
end

function M.get_view(tpl, layout)
    local template = require "resty.template"
    if helpers.is_debug() then
        template.caching(false)
    end

    local view  = template.new(tpl, layout)
    view.page_id = get_template_name(tpl)
    view.qs = helpers.format_query(ngx.req.get_uri_args(), "&")
    view.jsmodel = ""
    return view
end

function M.get_error_view(err, tpl, layout)
    local view = M.get_view(tpl, layout)
    view.title = err.message
    view.error = err
    return view
end

function M.get_session()
    local session = require "resty.session".open()
    session.data.ip = ngx.var.remote_addr
    session:save()
    return session;
end

function M.require_login(session)
    -- If there is no token associated with this session
    -- Force the user to the login screen
    if not session.data.token then
        ngx.redirect('/login')
    end
end

return M