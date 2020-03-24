-- methods for producing each endpoint of the application
local adapters = require "adapters"
local template = require "resty.template"
local cjson = require "cjson"
local helpers = require "helpers"

local function new()
    local views = {}

    local function get_session()
        local session = require "resty.session".open()
        session.data.ip = ngx.var.remote_addr
        session:save()
        return session;
    end

    local function require_login(session)
        -- If there is no token associated with this session
        -- Force the user to the login screen
        if not session.data.token then
            ngx.redirect('/login')
        end
    end

    local function get_view(tpl, layout)
        if helpers.is_debug() then
            template.caching(false)
        end

        local view  = template.new(tpl, layout)
        return view
    end

    function views.index()
        local session = get_session()
        local view = get_view("index.html", "layout.html")

        -- Dress the view
        view.title      = "Broker | Home"
        view:render()
    end

    function views.login()
        require "resty.session".start()
        get_session()
        local view      = get_view("login.html", "layout.html")
        view.title      = "BROKER | Login"
        view:render()
    end

    function views.logout()
        local session       = get_session()
        local models        = require "models"
        local view          = get_view("logout.html", "layout.html")

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

    function views.google_auth()
        local session  = get_session()
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
            session.data.user = adapters.google_user(args)
            session.data.token = adapters.google_token(args)
            session:save()
        end

        ngx.say(cjson.encode(response))
    end

    function views.facebook_auth()
        local session  = get_session()
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
            session.data.user = adapters.facebook_user(args)
            session.data.token = adapters.facebook_token(args)
            session:save()
        end

        ngx.say(cjson.encode(response))
    end

    return views
end

return new()
