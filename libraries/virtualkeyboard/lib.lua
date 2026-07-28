local lib = {}

local LIB_ID = "virtualkeyboard"

local function config(key)
    return Kristal.getLibConfig(LIB_ID, key)
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function distance_squared(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return dx * dx + dy * dy
end

local function is_android()
    return love.system and love.system.getOS and love.system.getOS() == "Android"
end

local function get_number(key, default, minimum)
    local value = tonumber(config(key))
    if not value then
        return default
    end
    if minimum then
        value = math.max(minimum, value)
    end
    return value
end

local function button_layout()
    return {
        {key = "left", kind = "arrow", x = 60, y = 375},
        {key = "right", kind = "arrow", x = 156, y = 375},
        {key = "up", kind = "arrow", x = 108, y = 327},
        {key = "down", kind = "arrow", x = 108, y = 423},
        {key = "z", kind = "button", x = 525, y = 370},
        {key = "x", kind = "button", x = 585, y = 320},
        {key = "c", kind = "button", x = 585, y = 420}
    }
end

local function action_button_layout()
    return {
        {key = "z", kind = "button", x = 525, y = 370},
        {key = "x", kind = "button", x = 585, y = 320},
        {key = "c", kind = "button", x = 585, y = 420}
    }
end

local function release_button(self, button)
    if not button.touch_id then
        return
    end

    self:emit_key(button.key, false)
    button.touch_id = nil
    button.pressed = false
end

local function reset_joystick(self)
    local joystick = self.joystick
    if not joystick then
        return
    end

    joystick.touch_id = nil
    joystick.handle_x = joystick.x
    joystick.handle_y = joystick.y
    self:set_joystick_mapping({})
end

function lib:emit_key(key, pressed)
    local was_pressed = self.virtual_keys[key] == true
    if was_pressed == pressed then
        return
    end

    self.virtual_keys[key] = pressed

    -- Feed Kristal directly so a touch is handled in the same event pass as a
    -- physical key. Fall back to LÖVE events when the library is used outside
    -- a fully initialized Kristal state.
    if Input and Input.onKeyPressed and Input.onKeyReleased then
        if pressed then
            Input.onKeyPressed(key, false)
        else
            Input.onKeyReleased(key)
        end
    elseif love.event then
        if pressed then
            love.event.push("keypressed", key, key, false)
        else
            love.event.push("keyreleased", key, key)
        end
    end
end

function lib:load_image(path)
    self.image_cache = self.image_cache or {}
    if self.image_cache[path] then
        return self.image_cache[path]
    end

    local full_path = self.info.path .. "/assets/" .. path
    local ok, image = pcall(love.graphics.newImage, full_path)
    if not ok then
        print("[virtualkeyboard] Could not load " .. full_path .. ": " .. tostring(image))
        return nil
    end

    image:setFilter("nearest", "nearest")
    self.image_cache[path] = image
    return image
end

function lib:make_button(data)
    local scale = get_number("button_scale", 3, 0.5)
    local normal_path = "buttons/" .. data.kind .. "-" .. data.key .. ".png"
    local pressed_path = "buttons/" .. data.kind .. "-" .. data.key .. "1.png"
    local normal = self:load_image(normal_path)
    local pressed = self:load_image(pressed_path)

    if not normal or not pressed then
        return nil
    end

    return {
        key = data.key,
        x = data.x,
        y = data.y,
        radius = get_number("button_radius", 44, 1),
        scale = scale,
        normal = normal,
        pressed_image = pressed,
        touch_id = nil,
        pressed = false
    }
end

function lib:build_layout()
    self.buttons = {}
    self.joystick = nil

    local layout = config("layout")
    if layout == "joystick" then
        local joystick_scale = get_number("joystick_scale", 2.5, 0.5)
        self.joystick = {
            x = 105,
            y = 375,
            radius = get_number("joystick_radius", 90, 1),
            max_radius = 54 * joystick_scale,
            deadzone = clamp(get_number("joystick_deadzone", 0.35, 0), 0, 0.95),
            scale = joystick_scale,
            container = self:load_image("joystick/joystick-container.png"),
            handle = self:load_image("joystick/joystick-handle.png"),
            touch_id = nil,
            handle_x = 105,
            handle_y = 375,
            mapping = {}
        }

        if not self.joystick.container or not self.joystick.handle then
            self.joystick = nil
        end

        for _, data in ipairs(action_button_layout()) do
            local button = self:make_button(data)
            if button then
                table.insert(self.buttons, button)
            end
        end
    else
        for _, data in ipairs(button_layout()) do
            local button = self:make_button(data)
            if button then
                table.insert(self.buttons, button)
            end
        end
    end
end

function lib:set_joystick_mapping(mapping)
    local joystick = self.joystick
    if not joystick then
        return
    end

    local previous = joystick.mapping or {}
    joystick.mapping = mapping
    for _, key in ipairs({"up", "down", "left", "right"}) do
        if (previous[key] == true) ~= (mapping[key] == true) then
            self:emit_key(key, mapping[key] == true)
        end
    end
end

function lib:update_joystick()
    local joystick = self.joystick
    if not joystick or not joystick.touch_id then
        return
    end

    local touch = self.touches[joystick.touch_id]
    if not touch then
        reset_joystick(self)
        return
    end

    local dx = touch.x - joystick.x
    local dy = touch.y - joystick.y
    local distance = math.sqrt(dx * dx + dy * dy)
    local handle_distance = math.min(distance, joystick.max_radius)

    if distance > 0 then
        joystick.handle_x = joystick.x + (dx / distance) * handle_distance
        joystick.handle_y = joystick.y + (dy / distance) * handle_distance
    else
        joystick.handle_x = joystick.x
        joystick.handle_y = joystick.y
    end

    local mapping = {}
    if distance > joystick.radius * joystick.deadzone then
        local horizontal = math.abs(dx) / distance
        local vertical = math.abs(dy) / distance
        if horizontal >= joystick.deadzone then
            mapping.left = dx < 0
            mapping.right = dx > 0
        end
        if vertical >= joystick.deadzone then
            mapping.up = dy < 0
            mapping.down = dy > 0
        end
    end
    self:set_joystick_mapping(mapping)
end

function lib:screen_to_game(x, y)
    if Input and Input.getMousePosition then
        return Input.getMousePosition(x, y)
    end

    local scale = Kristal.getGameScale()
    local offset_x, offset_y = Kristal.getSideOffsets()
    return (x - offset_x) / scale, (y - offset_y) / scale
end

function lib:press_button(button, touch_id)
    if button.touch_id then
        return
    end

    button.touch_id = touch_id
    button.pressed = true
    self:emit_key(button.key, true)
end

function lib:assign_touch(touch_id, touch)
    if not self.visible then
        return
    end

    if self.joystick and not self.joystick.touch_id then
        if distance_squared(touch.x, touch.y, self.joystick.x, self.joystick.y)
            <= self.joystick.radius * self.joystick.radius then
            self.joystick.touch_id = touch_id
            self:update_joystick()
            return
        end
    end

    for _, button in ipairs(self.buttons) do
        if distance_squared(touch.x, touch.y, button.x, button.y)
            <= button.radius * button.radius then
            self:press_button(button, touch_id)
            return
        end
    end
end

function lib:touch_pressed(touch_id, x, y)
    local game_x, game_y = self:screen_to_game(x, y)
    local touch = {x = game_x, y = game_y}
    self.touches[touch_id] = touch
    self:assign_touch(touch_id, touch)
end

function lib:touch_moved(touch_id, x, y)
    local touch = self.touches[touch_id]
    if not touch then
        return
    end

    touch.x, touch.y = self:screen_to_game(x, y)

    if self.joystick and self.joystick.touch_id == touch_id then
        self:update_joystick()
    end

    for _, button in ipairs(self.buttons) do
        if button.touch_id == touch_id
            and distance_squared(touch.x, touch.y, button.x, button.y)
                > button.radius * button.radius then
            release_button(self, button)
        end
    end
end

function lib:touch_released(touch_id, x, y)
    self:touch_moved(touch_id, x, y)

    for _, button in ipairs(self.buttons) do
        if button.touch_id == touch_id then
            release_button(self, button)
        end
    end
    if self.joystick and self.joystick.touch_id == touch_id then
        reset_joystick(self)
    end

    self.touches[touch_id] = nil
end

function lib:release_all()
    self.virtual_keys = self.virtual_keys or {}
    for _, button in ipairs(self.buttons or {}) do
        release_button(self, button)
    end
    if self.joystick then
        reset_joystick(self)
    end
    self.touches = {}

    local pressed_keys = {}
    for key, pressed in pairs(self.virtual_keys or {}) do
        if pressed then
            table.insert(pressed_keys, key)
        end
    end
    for _, key in ipairs(pressed_keys) do
        self:emit_key(key, false)
    end
end

function lib:setVisible(visible)
    visible = visible == true
    if self.visible == visible then
        return self.visible
    end

    if not visible then
        self:release_all()
    end
    self.visible = visible
    return self.visible
end

function lib:isVisible()
    return self.enabled == true and self.visible == true
end

function lib:toggle()
    return self:setVisible(not self.visible)
end

function lib:install_hooks()
    if self.hooks_installed or not HookSystem then
        return
    end

    self.hooks_installed = true
    local owner = self

    if love.keyboard and type(love.keyboard.isDown) == "function" then
        HookSystem.hook(love.keyboard, "isDown", function(orig, key, ...)
            if owner.virtual_keys[key] then
                return true
            end
            return orig(key, ...)
        end)
    end

    HookSystem.hook(love, "touchpressed", function(orig, touch_id, x, y, dx, dy, pressure)
        local result = orig(touch_id, x, y, dx, dy, pressure)
        owner:touch_pressed(touch_id, x, y, pressure)
        return result
    end)

    HookSystem.hook(love, "touchmoved", function(orig, touch_id, x, y, dx, dy, pressure)
        local result = orig(touch_id, x, y, dx, dy, pressure)
        owner:touch_moved(touch_id, x, y, pressure)
        return result
    end)

    HookSystem.hook(love, "touchreleased", function(orig, touch_id, x, y, dx, dy, pressure)
        local result = orig(touch_id, x, y, dx, dy, pressure)
        owner:touch_released(touch_id, x, y, pressure)
        return result
    end)

    HookSystem.hook(love, "focus", function(orig, focused, ...)
        local result = orig(focused, ...)
        if not focused then
            owner:release_all()
        end
        return result
    end)
end

function lib:onKeyPressed(key, is_repeat)
    local toggle_key = config("toggle_key")
    if self.enabled and not is_repeat and type(toggle_key) == "string"
        and toggle_key ~= "" and key == toggle_key then
        self:toggle()
        return true
    end
end

function lib:postDraw()
    if not self:isVisible() then
        return
    end

    local alpha = clamp(get_number("opacity", 0.78, 0), 0, 1)
    love.graphics.push("all")
    love.graphics.origin()

    if self.joystick then
        local joystick = self.joystick
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.draw(
            joystick.container,
            joystick.x,
            joystick.y,
            0,
            joystick.scale,
            joystick.scale,
            joystick.container:getWidth() / 2,
            joystick.container:getHeight() / 2
        )
        love.graphics.draw(
            joystick.handle,
            joystick.handle_x,
            joystick.handle_y,
            0,
            joystick.scale,
            joystick.scale,
            joystick.handle:getWidth() / 2,
            joystick.handle:getHeight() / 2
        )
    end

    for _, button in ipairs(self.buttons) do
        local image = button.pressed and button.pressed_image or button.normal
        love.graphics.setColor(1, 1, 1, button.pressed and math.min(1, alpha + 0.12) or alpha)
        love.graphics.draw(
            image,
            button.x,
            button.y,
            0,
            button.scale,
            button.scale,
            image:getWidth() / 2,
            image:getHeight() / 2
        )
    end

    love.graphics.pop()
end

function lib:init()
    self.enabled = config("enabled") ~= false
        and (config("only_android") ~= true or is_android())
    self.visible = config("show_on_start") ~= false
    self.virtual_keys = {}
    self.touches = {}
    self.buttons = {}

    if not self.enabled then
        return
    end

    self:build_layout()
    if #self.buttons == 0 and not self.joystick then
        self.enabled = false
        print("[virtualkeyboard] No controls could be loaded; library disabled")
        return
    end
    self:install_hooks()
end

function lib:unload()
    self:release_all()
    self.enabled = false
    self.visible = false
    self.buttons = {}
    self.joystick = nil
    self.image_cache = nil
end

function lib:cleanup()
    self:release_all()
end

if Registry and Registry.registerGlobal then
    Registry.registerGlobal("VirtualKeyboard", lib)
end

return lib
