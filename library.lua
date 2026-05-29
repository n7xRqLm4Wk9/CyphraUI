-- [[ LuxwareUI Library | Stabilized + Fixed UX Version ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Luxware = {}
Luxware.__index = Luxware

-- 🔧 FIXED THEME (no more eye-blinding UI)
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Panel = Color3.fromRGB(19, 19, 19),
    Surface = Color3.fromRGB(24, 24, 24),
    SurfaceLight = Color3.fromRGB(32, 32, 32),
    Border = Color3.fromRGB(55, 55, 55),

    Text = Color3.fromRGB(235, 235, 235),
    MutedText = Color3.fromRGB(170, 170, 170),
    SoftText = Color3.fromRGB(200, 200, 200),

    ToggleOn = Color3.fromRGB(90, 170, 120),
    ToggleOff = Color3.fromRGB(45, 45, 45),
}

local function tween(obj, ti, props)
    local t = TweenService:Create(obj, ti, props)
    t:Play()
    return t
end

local TWEEN_FAST = TweenInfo.new(0.12)
local TWEEN = TweenInfo.new(0.2)

local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = obj
    return c
end

local function stroke(obj)
    local s = Instance.new("UIStroke")
    s.Color = Theme.Border
    s.Thickness = 1
    s.Parent = obj
end

local function new(class, props)
    local o = Instance.new(class)
    for k,v in pairs(props) do o[k] = v end
    return o
end

-- FIXED DRAG (stable + no jitter)
local function drag(frame, handle)
    local dragging = false
    local start, startPos

    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            start = i.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end

        local delta = i.Position - start
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- MAIN WINDOW
function Luxware:CreateWindow(opt)
    opt = opt or {}

    local gui = new("ScreenGui", {
        Parent = CoreGui,
        Name = "LuxwareUI",
        ResetOnSpawn = false
    })

    local main = new("Frame", {
        Parent = gui,
        Size = UDim2.new(0, 520, 0, 360),
        Position = UDim2.new(0.5, -260, 0.5, -180),
        BackgroundColor3 = Theme.Background
    })
    corner(main, 10)
    stroke(main)

    local top = new("Frame", {
        Parent = main,
        Size = UDim2.new(1,0,0,40),
        BackgroundColor3 = Theme.Panel
    })

    local title = new("TextLabel", {
        Parent = top,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = opt.Name or "Luxware",
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 15
    })

    local content = new("Frame", {
        Parent = main,
        Size = UDim2.new(1,0,1,-40),
        Position = UDim2.new(0,0,0,40),
        BackgroundTransparency = 1
    })

    drag(main, top)

    -- TAB SYSTEM
    local tabs = {}
    local tabButtons = new("Frame", {
        Parent = content,
        Size = UDim2.new(0,140,1,0),
        BackgroundColor3 = Theme.Panel
    })

    local pages = new("Frame", {
        Parent = content,
        Size = UDim2.new(1,-140,1,0),
        Position = UDim2.new(0,140,0,0),
        BackgroundTransparency = 1
    })

    local function createTab(name)
        local btn = new("TextButton", {
            Parent = tabButtons,
            Size = UDim2.new(1,0,0,30),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Theme.MutedText,
            Font = Enum.Font.Gotham,
            TextSize = 13
        })

        local page = new("ScrollingFrame", {
            Parent = pages,
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Visible = false
        })

        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0,6)

        btn.MouseButton1Click:Connect(function()
            for _,t in ipairs(tabs) do
                t.page.Visible = false
                t.btn.TextColor3 = Theme.MutedText
            end
            page.Visible = true
            btn.TextColor3 = Theme.Text
        end)

        table.insert(tabs, {btn = btn, page = page})

        if #tabs == 1 then
            page.Visible = true
            btn.TextColor3 = Theme.Text
        end

        local api = {}

        function api:Button(txt, cb)
            local b = new("TextButton", {
                Parent = page,
                Size = UDim2.new(1,-10,0,32),
                BackgroundColor3 = Theme.Surface,
                Text = txt,
                TextColor3 = Theme.Text
            })
            corner(b, 6)

            b.MouseButton1Click:Connect(function()
                if cb then cb() end
            end)
        end

        function api:Toggle(txt, cb)
            local state = false

            local holder = new("Frame", {
                Parent = page,
                Size = UDim2.new(1,-10,0,32),
                BackgroundColor3 = Theme.Surface
            })
            corner(holder, 6)

            local label = new("TextLabel", {
                Parent = holder,
                BackgroundTransparency = 1,
                Size = UDim2.new(1,-60,1,0),
                Position = UDim2.new(0,10,0,0),
                Text = txt,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local toggle = new("Frame", {
                Parent = holder,
                Size = UDim2.new(0,36,0,18),
                Position = UDim2.new(1,-46,0.5,-9),
                BackgroundColor3 = Theme.ToggleOff
            })
            corner(toggle, 999)

            local knob = new("Frame", {
                Parent = toggle,
                Size = UDim2.new(0,14,0,14),
                Position = UDim2.new(0,2,0.5,-7),
                BackgroundColor3 = Color3.fromRGB(240,240,240)
            })
            corner(knob, 999)

            holder.InputBegan:Connect(function(i)
                if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                state = not state

                tween(toggle, TWEEN, {
                    BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
                })

                tween(knob, TWEEN, {
                    Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
                })

                if cb then cb(state) end
            end)
        end

        return api
    end

    return {
        Tab = createTab
    }
end

return Luxware
