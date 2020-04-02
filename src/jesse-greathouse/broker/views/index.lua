-- methods for producing each endpoint of the application
local cjson = require "cjson"
local helpers = require "helpers"
local base = require "views.base"

local IndexView = {}

function IndexView.index()
    local session = base.get_session()
    local view = base.get_view("index.html", "layout.html")

    -- Dress the view
    view.title      = "Broker | Home"
    view:render()
end

function IndexView.error()
    local view = base.get_view("error.html", "layout.html")

    view.status = ngx.var.status
    view.alert_level, view.message = helpers.get_error_info(view.status)
    if helpers.is_debug() then
        local errlog = require "ngx.errlog"
        view.trace = ""
        local loglines = errlog.get_logs(20)
        for k, v in pairs(loglines) do
            view.trace = view.trace .. v
          end
    end
    view.title      = "Broker | " .. view.status .. " " .. view.message
    view:render()
end

function IndexView.login()
    require "resty.session".start()
    base.get_session()
    local view      = base.get_view("login.html", "layout.html")
    view.title      = "BROKER | Login"
    view:render()
end

function IndexView.logout()
    local session       = base.get_session()
    local models        = require "models"
    local view          = base.get_view("logout.html", "layout.html")

    -- Prevents execution from breaking if the
    -- user lands on /logout without a token
    if not session.data.token then
        session:destroy()
        ngx.redirect('/login')
    end

    view.title          = "BROKER | Logout"
    view.token          = session.data.token
    view.google_type    = models.GOOGLE_TOKEN_TYPE
    view.facebook_type  = models.FACEBOOK_TOKEN_TYPE

    session:destroy()
    view:render()
end

function IndexView.google_auth()
    local session  = base.get_session()
    local response = {
        error = 0
    }
    ngx.req.read_body()
    local args, err = ngx.req.get_post_args()

    if err then
        response.error = 1;
        response.message = err
    elseif next(args) == nil then
        response.error = 1;
        response.message = "failed to get post args"
    else
        response.message = "logged in user"
        -- session.data.user = adapters.google_user(args)
        -- session.data.token = adapters.google_token(args)
        session:save()
    end

    ngx.say(cjson.encode(response))
end

function IndexView.facebook_auth()
    local session  = base.get_session()
    local response = {
        error = 0
    }
    ngx.req.read_body()
    local args, err = ngx.req.get_post_args()

    if err then
        response.error = 1;
        response.message = err
    elseif next(args) == nil then
        response.error = 1;
        response.message = "failed to get post args"
    else
        response.message = "logged in user"
        -- session.data.user = adapters.facebook_user(args)
        -- session.data.token = adapters.facebook_token(args)
        session:save()
    end

    ngx.say(cjson.encode(response))
end

return IndexView