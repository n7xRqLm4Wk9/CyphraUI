-- ██╗     ██╗   ██╗██╗  ██╗██╗    ██╗ █████╗ ██████╗ ███████╗██╗   ██╗██╗
-- ██║     ██║   ██║╚██╗██╔╝██║    ██║██╔══██╗██╔══██╗██╔════╝██║   ██║██║
-- ██║     ██║   ██║ ╚███╔╝ ██║ █╗ ██║███████║██████╔╝█████╗  ██║   ██║██║
-- ██║     ██║   ██║ ██╔██╗ ██║███╗██║██╔══██║██╔══██╗██╔══╝  ██║   ██║██║
-- ███████╗╚██████╔╝██╔╝ ██╗╚███╔███╔╝██║  ██║██║  ██║███████╗╚██████╔╝██║
-- ╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝
-- LuxwareUI v1.0.0 | Premium Roblox UI Library
-- Inspired by Rayfield | Mobile + PC Support

local LuxwareUI = {}
LuxwareUI.__index = LuxwareUI

-- ============================================================
-- SERVICES
-- ============================================================
local Players            = game:GetService("Players")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local HttpService        = game:GetService("HttpService")
local CoreGui            = game:GetService("CoreGui")
local StarterGui         = game:GetService("StarterGui")

-- ============================================================
-- CONSTANTS & THEME
-- ============================================================
local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

local Theme = {
    Background      = Color3.fromRGB(13,  13,  18),
    Surface         = Color3.fromRGB(18,  18,  25),
    SurfaceLight    = Color3.fromRGB(24,  24,  34),
    Border          = Color3.fromRGB(40,  40,  58),
    BorderGlow      = Color3.fromRGB(80,  80, 120),
    Accent          = Color3.fromRGB(100, 90, 255),
    AccentLight     = Color3.fromRGB(130, 120, 255),
    AccentDim       = Color3.fromRGB(60,  55, 160),
    Text            = Color3.fromRGB(240, 240, 255),
    TextDim         = Color3.fromRGB(140, 140, 165),
    TextFaint       = Color3.fromRGB(80,  80, 105),
    Success         = Color3.fromRGB(80,  210, 130),
    Error           = Color3.fromRGB(255, 80,  80),
    Warning         = Color3.fromRGB(255, 185, 50),
    ToggleOn        = Color3.fromRGB(100, 90, 255),
    ToggleOff       = Color3.fromRGB(50,  50,  70),
    Slider          = Color3.fromRGB(100, 90, 255),
    DropdownArrow   = Color3.fromRGB(140, 140, 165),
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local function Tween(obj, info, props)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

local function QuickTween(obj, t, props)
    return Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
end

local function SpringTween(obj, t, props)
    return Tween(obj, TweenInfo.new(t, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props)
end

local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function MakeCorner(radius, parent)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
end

local function MakePadding(t, b, l, r, parent)
    return Create("UIPadding", {
        PaddingTop    = UDim.new(0, t),
        PaddingBottom = UDim.new(0, b),
        PaddingLeft   = UDim.new(0, l),
        PaddingRight  = UDim.new(0, r),
        Parent        = parent
    })
end

local function MakeStroke(thickness, color, transparency, parent)
    return Create("UIStroke", {
        Thickness     = thickness,
        Color         = color,
        Transparency  = transparency or 0,
        Parent        = parent
    })
end

local function HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    return Color3.new(r, g, b)
end

local function RGBtoHSV(c)
    local r, g, b = c.R, c.G, c.B
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local d   = max - min
    local h, s, v = 0, 0, max
    if max ~= 0 then s = d / max end
    if d ~= 0 then
        if max == r then h = (g - b) / d % 6
        elseif max == g then h = (b - r) / d + 2
        else h = (r - g) / d + 4
        end
        h = h / 6
    end
    return h, s, v
end

local function IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- ============================================================
-- DRAGGING (works on Frame, supports mobile)
-- ============================================================
local function MakeDraggable(handle, frame)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        frame.Position = newPos
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- ============================================================
-- KEY SYSTEM
-- ============================================================
function LuxwareUI:KeySystem(config)
    config = config or {}
    local Title    = config.Title    or "Key System"
    local SubTitle = config.SubTitle or "Enter your key to access the script"
    local Key      = config.Key      or ""
    local Link     = config.GrabKey  or ""
    local Callback = config.Callback or function() end

    -- Saved key check
    local savedKey = ""
    pcall(function()
        if syn and syn.protect_gui then
            local ok, val = pcall(readfile, "LuxwareUI_" .. Title .. ".key")
            if ok and val == Key then savedKey = val end
        end
    end)
    if savedKey == Key and Key ~= "" then
        Callback(true)
        return
    end

    local ScreenGui = Create("ScreenGui", {
        Name             = "LuxwareKeySystem",
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        DisplayOrder     = 999,
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer.PlayerGui end

    -- Overlay
    local Overlay = Create("Frame", {
        Size            = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.4,
        Parent          = ScreenGui,
    })

    -- Card
    local CardSize = IsMobile() and UDim2.fromOffset(320, 280) or UDim2.fromOffset(420, 300)
    local Card = Create("Frame", {
        Size             = CardSize,
        Position         = UDim2.fromScale(0.5, 0.5),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Surface,
        Parent           = ScreenGui,
    })
    MakeCorner(16, Card)
    MakeStroke(1.5, Theme.Accent, 0.3, Card)

    -- Glow
    Create("ImageLabel", {
        Size             = UDim2.fromOffset(500, 200),
        Position         = UDim2.new(0.5, 0, 0, -60),
        AnchorPoint      = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Image            = "rbxassetid://4996891970",
        ImageColor3      = Theme.Accent,
        ImageTransparency = 0.75,
        ScaleType        = Enum.ScaleType.Fit,
        Parent           = Card,
    })

    MakePadding(24, 24, 28, 28, Card)

    -- Icon + Title
    local TitleFrame = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent           = Card,
    })
    Create("TextLabel", {
        Text             = "🔑  " .. Title,
        Font             = Enum.Font.GothamBold,
        TextSize         = 20,
        TextColor3       = Theme.Text,
        TextXAlignment   = Enum.TextXAlignment.Center,
        Size             = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent           = TitleFrame,
    })

    Create("TextLabel", {
        Text             = SubTitle,
        Font             = Enum.Font.Gotham,
        TextSize         = 13,
        TextColor3       = Theme.TextDim,
        TextXAlignment   = Enum.TextXAlignment.Center,
        TextWrapped      = true,
        Size             = UDim2.new(1, 0, 0, 28),
        Position         = UDim2.new(0, 0, 0, 46),
        BackgroundTransparency = 1,
        Parent           = Card,
    })

    -- Input Box
    local InputBox = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 44),
        Position         = UDim2.new(0, 0, 0, 86),
        BackgroundColor3 = Theme.SurfaceLight,
        Parent           = Card,
    })
    MakeCorner(10, InputBox)
    MakeStroke(1, Theme.Border, 0, InputBox)
    MakePadding(0, 0, 12, 12, InputBox)

    local TextInput = Create("TextBox", {
        PlaceholderText  = "Enter key here...",
        PlaceholderColor3 = Theme.TextFaint,
        Text             = "",
        Font             = Enum.Font.Gotham,
        TextSize         = 14,
        TextColor3       = Theme.Text,
        ClearTextOnFocus = false,
        Size             = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent           = InputBox,
    })
    TextInput.Focused:Connect(function()
        QuickTween(InputBox, 0.2, { BackgroundColor3 = Theme.SurfaceLight })
        QuickTween(InputBox:FindFirstChildOfClass("UIStroke"), 0.2, { Color = Theme.Accent })
    end)
    TextInput.FocusLost:Connect(function()
        QuickTween(InputBox:FindFirstChildOfClass("UIStroke"), 0.2, { Color = Theme.Border })
    end)

    -- Status label
    local StatusLabel = Create("TextLabel", {
        Text             = "",
        Font             = Enum.Font.Gotham,
        TextSize         = 12,
        TextColor3       = Theme.TextDim,
        TextXAlignment   = Enum.TextXAlignment.Center,
        Size             = UDim2.new(1, 0, 0, 18),
        Position         = UDim2.new(0, 0, 0, 140),
        BackgroundTransparency = 1,
        Parent           = Card,
    })

    -- Buttons
    local BtnFrame = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 44),
        Position         = UDim2.new(0, 0, 0, 166),
        BackgroundTransparency = 1,
        Parent           = Card,
    })
    Create("UIListLayout", {
        FillDirection    = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding          = UDim.new(0, 10),
        Parent           = BtnFrame,
    })

    local function MakeBtn(text, accent)
        local btn = Create("TextButton", {
            Text             = text,
            Font             = Enum.Font.GothamBold,
            TextSize         = 14,
            TextColor3       = accent and Theme.Text or Theme.TextDim,
            Size             = UDim2.new(0.45, 0, 1, 0),
            BackgroundColor3 = accent and Theme.Accent or Theme.SurfaceLight,
            AutoButtonColor  = false,
            Parent           = BtnFrame,
        })
        MakeCorner(10, btn)
        btn.MouseEnter:Connect(function()
            QuickTween(btn, 0.15, { BackgroundColor3 = accent and Theme.AccentLight or Theme.Border })
        end)
        btn.MouseLeave:Connect(function()
            QuickTween(btn, 0.15, { BackgroundColor3 = accent and Theme.Accent or Theme.SurfaceLight })
        end)
        return btn
    end

    local GetKeyBtn   = MakeBtn("Get Key",   false)
    local CheckKeyBtn = MakeBtn("Check Key", true)

    GetKeyBtn.MouseButton1Click:Connect(function()
        if Link ~= "" then
            setclipboard(Link)
            StatusLabel.Text      = "Link copied to clipboard!"
            StatusLabel.TextColor3 = Theme.Warning
        end
    end)

    CheckKeyBtn.MouseButton1Click:Connect(function()
        local entered = TextInput.Text
        if entered == Key then
            StatusLabel.Text       = "✓ Access granted!"
            StatusLabel.TextColor3  = Theme.Success
            pcall(function() writefile("LuxwareUI_" .. Title .. ".key", Key) end)
            task.wait(0.8)
            QuickTween(Card, 0.3, { BackgroundTransparency = 1 })
            QuickTween(Overlay, 0.3, { BackgroundTransparency = 1 })
            task.wait(0.35)
            ScreenGui:Destroy()
            Callback(true)
        else
            StatusLabel.Text       = "✗ Invalid key. Try again."
            StatusLabel.TextColor3  = Theme.Error
            SpringTween(Card, 0.4, { Position = UDim2.new(0.5, 10, 0.5, 0) })
            task.wait(0.05)
            SpringTween(Card, 0.4, { Position = UDim2.fromScale(0.5, 0.5) })
            Callback(false)
        end
    end)

    -- Entry animation
    Card.Size = UDim2.fromOffset(0, 0)
    Card.BackgroundTransparency = 1
    SpringTween(Card, 0.5, { Size = CardSize, BackgroundTransparency = 0 })
end

-- ============================================================
-- MAIN WINDOW
-- ============================================================
function LuxwareUI:CreateWindow(config)
    config = config or {}
    local WindowTitle   = config.Name        or "LuxwareUI"
    local WindowSubtitle = config.LoadingTitle or ""
    local WindowIcon    = config.Icon         or ""
    local ConfigGlobals = config.ConfigurationSaving or {}
    local KeyConfig     = config.KeySystem    or nil

    -- Handle key system first
    if KeyConfig then
        local keyPassed = false
        LuxwareUI:KeySystem({
            Title    = KeyConfig.Title    or WindowTitle .. " Key",
            SubTitle = KeyConfig.SubTitle or "Enter your key to continue",
            Key      = KeyConfig.Key      or "",
            GrabKey  = KeyConfig.GrabKey  or "",
            Callback = function(result) keyPassed = result end,
        })
        -- Wait for key UI to close
        local timeout = 0
        repeat task.wait(0.1); timeout += 0.1 until keyPassed or timeout > 300
        if not keyPassed then return end
    end

    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name           = "LuxwareUI_" .. WindowTitle,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder   = 10,
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer.PlayerGui end

    -- ============================================================
    -- MAIN WINDOW FRAME
    -- ============================================================
    local mobile = IsMobile()
    local WinW = mobile and 340 or 560
    local WinH = mobile and 460 or 520

    local Window = Create("Frame", {
        Name             = "Window",
        Size             = UDim2.fromOffset(WinW, WinH),
        Position         = UDim2.fromScale(0.5, 0.5),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = true,
        Parent           = ScreenGui,
    })
    MakeCorner(14, Window)
    MakeStroke(1.5, Theme.Accent, 0.45, Window)

    -- SIDEBAR
    local SidebarW = mobile and 110 or 140
    local Sidebar = Create("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, SidebarW, 1, 0),
        BackgroundColor3 = Theme.Surface,
        Parent           = Window,
    })
    MakeCorner(0, Sidebar)

    -- Sidebar top branding
    local SideTop = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 68),
        BackgroundTransparency = 1,
        Parent           = Sidebar,
    })
    MakePadding(14, 0, 10, 10, SideTop)

    local BrandLabel = Create("TextLabel", {
        Text             = WindowTitle,
        Font             = Enum.Font.GothamBold,
        TextSize         = mobile and 11 or 13,
        TextColor3       = Theme.Text,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        Size             = UDim2.fromScale(1, 0.6),
        BackgroundTransparency = 1,
        Parent           = SideTop,
    })
    if WindowSubtitle ~= "" then
        Create("TextLabel", {
            Text             = WindowSubtitle,
            Font             = Enum.Font.Gotham,
            TextSize         = 10,
            TextColor3       = Theme.TextDim,
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextWrapped      = true,
            Size             = UDim2.new(1, 0, 0.4, 0),
            Position         = UDim2.fromScale(0, 0.6),
            BackgroundTransparency = 1,
            Parent           = SideTop,
        })
    end

    -- Divider under brand
    Create("Frame", {
        Size             = UDim2.new(1, -20, 0, 1),
        Position         = UDim2.new(0, 10, 0, 68),
        BackgroundColor3 = Theme.Border,
        Parent           = Sidebar,
    })

    -- Tab list
    local TabList = Create("ScrollingFrame", {
        Size             = UDim2.new(1, 0, 1, -80),
        Position         = UDim2.new(0, 0, 0, 76),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent           = Sidebar,
    })
    MakePadding(6, 6, 8, 8, TabList)
    Create("UIListLayout", {
        Padding          = UDim.new(0, 4),
        FillDirection    = Enum.FillDirection.Vertical,
        Parent           = TabList,
    })

    -- CONTENT AREA
    local ContentArea = Create("Frame", {
        Name             = "ContentArea",
        Size             = UDim2.new(1, -SidebarW, 1, 0),
        Position         = UDim2.new(0, SidebarW, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent           = Window,
    })

    -- Title bar in content
    local TitleBar = Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        Parent           = ContentArea,
    })
    MakePadding(0, 0, 14, 46, TitleBar)

    local TabNameLabel = Create("TextLabel", {
        Text             = "",
        Font             = Enum.Font.GothamBold,
        TextSize         = 15,
        TextColor3       = Theme.Text,
        TextXAlignment   = Enum.TextXAlignment.Left,
        Size             = UDim2.fromScale(1, 0.6),
        Position         = UDim2.fromScale(0, 0.2),
        BackgroundTransparency = 1,
        Parent           = TitleBar,
    })

    -- Close Button
    local CloseBtn = Create("TextButton", {
        Text             = "✕",
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        TextColor3       = Theme.TextDim,
        Size             = UDim2.fromOffset(28, 28),
        Position         = UDim2.new(1, -38, 0, 9),
        BackgroundColor3 = Theme.SurfaceLight,
        AutoButtonColor  = false,
        Parent           = ContentArea,
    })
    MakeCorner(8, CloseBtn)
    CloseBtn.MouseEnter:Connect(function()
        QuickTween(CloseBtn, 0.15, { BackgroundColor3 = Theme.Error, TextColor3 = Theme.Text })
    end)
    CloseBtn.MouseLeave:Connect(function()
        QuickTween(CloseBtn, 0.15, { BackgroundColor3 = Theme.SurfaceLight, TextColor3 = Theme.TextDim })
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        QuickTween(Window, 0.3, { Size = UDim2.fromOffset(WinW, 0) })
        task.wait(0.35)
        ScreenGui:Destroy()
    end)

    -- Divider below title
    Create("Frame", {
        Size             = UDim2.new(1, -14, 0, 1),
        Position         = UDim2.new(0, 7, 0, 46),
        BackgroundColor3 = Theme.Border,
        Parent           = ContentArea,
    })

    -- Content scroll
    local ContentScroll = Create("ScrollingFrame", {
        Name             = "ContentScroll",
        Size             = UDim2.new(1, 0, 1, -54),
        Position         = UDim2.new(0, 0, 0, 54),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Parent           = ContentArea,
    })
    MakePadding(6, 10, 10, 10, ContentScroll)
    Create("UIListLayout", {
        Padding          = UDim.new(0, 6),
        FillDirection    = Enum.FillDirection.Vertical,
        Parent           = ContentScroll,
    })

    -- Make window draggable via sidebar top
    MakeDraggable(SideTop, Window)
    MakeDraggable(TitleBar, Window)

    -- Entry animation
    Window.Size = UDim2.fromOffset(WinW, 0)
    Window.BackgroundTransparency = 1
    SpringTween(Window, 0.5, { Size = UDim2.fromOffset(WinW, WinH), BackgroundTransparency = 0 })

    -- ============================================================
    -- WINDOW OBJECT
    -- ============================================================
    local WindowObj       = {}
    WindowObj._tabs       = {}
    WindowObj._activeTab  = nil
    WindowObj._screenGui  = ScreenGui
    WindowObj._window     = Window

    -- ============================================================
    -- TAB CREATION
    -- ============================================================
    function WindowObj:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local TabName  = tabConfig.Name  or "Tab"
        local TabIcon  = tabConfig.Icon  or ""

        -- Tab button
        local TabBtn = Create("TextButton", {
            Name             = "Tab_" .. TabName,
            Text             = "",
            Size             = UDim2.new(1, 0, 0, mobile and 36 or 38),
            BackgroundColor3 = Theme.SurfaceLight,
            BackgroundTransparency = 1,
            AutoButtonColor  = false,
            Parent           = TabList,
        })
        MakeCorner(9, TabBtn)
        MakePadding(0, 0, 8, 8, TabBtn)

        Create("UIListLayout", {
            FillDirection   = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding         = UDim.new(0, 6),
            Parent          = TabBtn,
        })

        if TabIcon ~= "" then
            Create("TextLabel", {
                Text            = TabIcon,
                Font            = Enum.Font.GothamBold,
                TextSize        = 14,
                TextColor3      = Theme.TextDim,
                Size            = UDim2.fromOffset(18, 18),
                BackgroundTransparency = 1,
                Parent          = TabBtn,
            })
        end

        local TabLabel = Create("TextLabel", {
            Text            = TabName,
            Font            = Enum.Font.Gotham,
            TextSize        = mobile and 11 or 12,
            TextColor3      = Theme.TextDim,
            TextXAlignment  = Enum.TextXAlignment.Left,
            TextTruncate    = Enum.TextTruncate.AtEnd,
            Size            = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent          = TabBtn,
        })

        -- Active indicator
        local Indicator = Create("Frame", {
            Size             = UDim2.new(0, 3, 0.6, 0),
            Position         = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            Parent           = TabBtn,
        })
        MakeCorner(4, Indicator)

        -- Tab page (container inside ContentScroll — hidden)
        local TabPage = Create("Frame", {
            Name             = "Page_" .. TabName,
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Visible          = false,
            Parent           = ContentScroll,
        })
        Create("UIListLayout", {
            Padding          = UDim.new(0, 6),
            FillDirection    = Enum.FillDirection.Vertical,
            Parent           = TabPage,
        })

        local function SelectTab()
            -- Deactivate current
            if WindowObj._activeTab then
                local prev = WindowObj._activeTab
                QuickTween(prev._btn, 0.2, { BackgroundTransparency = 1 })
                QuickTween(prev._label, 0.2, { TextColor3 = Theme.TextDim, Font = Enum.Font.Gotham })
                QuickTween(prev._indicator, 0.2, { BackgroundTransparency = 1 })
                prev._page.Visible = false
            end
            -- Activate
            QuickTween(TabBtn, 0.2, { BackgroundTransparency = 0 })
            QuickTween(TabLabel, 0.2, { TextColor3 = Theme.Text })
            TabLabel.Font = Enum.Font.GothamBold
            QuickTween(Indicator, 0.2, { BackgroundTransparency = 0 })
            TabPage.Visible = true
            TabNameLabel.Text = TabName
            WindowObj._activeTab = {
                _btn       = TabBtn,
                _label     = TabLabel,
                _indicator = Indicator,
                _page      = TabPage,
            }
        end

        TabBtn.MouseButton1Click:Connect(SelectTab)
        TabBtn.MouseEnter:Connect(function()
            if WindowObj._activeTab and WindowObj._activeTab._btn ~= TabBtn then
                QuickTween(TabBtn, 0.15, { BackgroundTransparency = 0.7 })
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if WindowObj._activeTab and WindowObj._activeTab._btn ~= TabBtn then
                QuickTween(TabBtn, 0.15, { BackgroundTransparency = 1 })
            end
        end)

        -- Auto-select first tab
        if #WindowObj._tabs == 0 then
            task.defer(SelectTab)
        end
        table.insert(WindowObj._tabs, { _btn = TabBtn, _label = TabLabel, _indicator = Indicator, _page = TabPage })

        -- ============================================================
        -- TAB OBJECT (components)
        -- ============================================================
        local TabObj = {}
        TabObj._page = TabPage

        -- ---- SECTION -----------------------------------------
        function TabObj:CreateSection(name)
            local Section = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent           = TabPage,
            })
            Create("UIListLayout", {
                Padding          = UDim.new(0, 4),
                FillDirection    = Enum.FillDirection.Vertical,
                Parent           = Section,
            })

            local SectionHeader = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                Parent           = Section,
            })
            Create("TextLabel", {
                Text             = (name or "Section"):upper(),
                Font             = Enum.Font.GothamBold,
                TextSize         = 10,
                TextColor3       = Theme.TextFaint,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Size             = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Parent           = SectionHeader,
            })
            Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 1, -1),
                BackgroundColor3 = Theme.Border,
                Parent           = SectionHeader,
            })

            local SectionObj = {}
            SectionObj._container = Section

            -- ---- BUTTON -----------------------------------------
            function SectionObj:CreateButton(cfg)
                cfg = cfg or {}
                local Btn = Create("TextButton", {
                    Name             = "Button",
                    Text             = "",
                    Size             = UDim2.new(1, 0, 0, 40),
                    BackgroundColor3 = Theme.Surface,
                    AutoButtonColor  = false,
                    Parent           = Section,
                })
                MakeCorner(9, Btn)
                MakeStroke(1, Theme.Border, 0.5, Btn)
                MakePadding(0, 0, 14, 14, Btn)

                Create("UIListLayout", {
                    FillDirection   = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding         = UDim.new(0, 8),
                    Parent          = Btn,
                })

                if cfg.Icon then
                    Create("TextLabel", {
                        Text            = cfg.Icon,
                        TextSize        = 14,
                        TextColor3      = Theme.Accent,
                        Size            = UDim2.fromOffset(18, 18),
                        BackgroundTransparency = 1,
                        Parent          = Btn,
                    })
                end

                Create("TextLabel", {
                    Text            = cfg.Name or "Button",
                    Font            = Enum.Font.Gotham,
                    TextSize        = 13,
                    TextColor3      = Theme.Text,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Size            = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Parent          = Btn,
                })

                if cfg.Description then
                    Btn.Size = UDim2.new(1, 0, 0, 52)
                    -- simplified: add sub-label
                end

                Btn.MouseEnter:Connect(function()
                    QuickTween(Btn, 0.15, { BackgroundColor3 = Theme.SurfaceLight })
                end)
                Btn.MouseLeave:Connect(function()
                    QuickTween(Btn, 0.15, { BackgroundColor3 = Theme.Surface })
                end)
                Btn.MouseButton1Click:Connect(function()
                    QuickTween(Btn, 0.08, { BackgroundColor3 = Theme.AccentDim })
                    task.wait(0.1)
                    QuickTween(Btn, 0.15, { BackgroundColor3 = Theme.Surface })
                    if cfg.Callback then cfg.Callback() end
                end)

                local BtnObj = {}
                function BtnObj:Set(newName) end
                return BtnObj
            end

            -- ---- TOGGLE -----------------------------------------
            function SectionObj:CreateToggle(cfg)
                cfg = cfg or {}
                local state = cfg.CurrentValue or false

                local Row = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 44),
                    BackgroundColor3 = Theme.Surface,
                    Parent           = Section,
                })
                MakeCorner(9, Row)
                MakeStroke(1, Theme.Border, 0.5, Row)
                MakePadding(0, 0, 14, 14, Row)

                Create("UIListLayout", {
                    FillDirection   = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding         = UDim.new(0, 8),
                    Parent          = Row,
                })

                if cfg.Icon then
                    Create("TextLabel", {
                        Text            = cfg.Icon,
                        TextSize        = 14,
                        TextColor3      = Theme.Accent,
                        Size            = UDim2.fromOffset(18, 18),
                        BackgroundTransparency = 1,
                        Parent          = Row,
                    })
                end

                local LabelArea = Create("Frame", {
                    Size             = UDim2.new(1, -52, 1, 0),
                    BackgroundTransparency = 1,
                    Parent           = Row,
                })
                Create("TextLabel", {
                    Text            = cfg.Name or "Toggle",
                    Font            = Enum.Font.Gotham,
                    TextSize        = 13,
                    TextColor3      = Theme.Text,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Size            = UDim2.fromScale(1, 0.55),
                    BackgroundTransparency = 1,
                    Parent          = LabelArea,
                })
                if cfg.Description and cfg.Description ~= "" then
                    Create("TextLabel", {
                        Text            = cfg.Description,
                        Font            = Enum.Font.Gotham,
                        TextSize        = 10,
                        TextColor3      = Theme.TextDim,
                        TextXAlignment  = Enum.TextXAlignment.Left,
                        TextWrapped     = true,
                        Size            = UDim2.new(1, 0, 0.45, 0),
                        Position        = UDim2.fromScale(0, 0.55),
                        BackgroundTransparency = 1,
                        Parent          = LabelArea,
                    })
                end

                -- Toggle pill
                local Pill = Create("Frame", {
                    Size             = UDim2.fromOffset(42, 22),
                    AnchorPoint      = Vector2.new(1, 0.5),
                    Position         = UDim2.new(1, 0, 0.5, 0),
                    BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff,
                    Parent           = Row,
                })
                MakeCorner(11, Pill)

                local Knob = Create("Frame", {
                    Size             = UDim2.fromOffset(16, 16),
                    Position         = UDim2.new(state and 1 or 0, state and -19 or 3, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent           = Pill,
                })
                MakeCorner(8, Knob)

                local function UpdateToggle()
                    if state then
                        QuickTween(Pill, 0.2, { BackgroundColor3 = Theme.ToggleOn })
                        QuickTween(Knob, 0.2, { Position = UDim2.new(1, -19, 0.5, -8) })
                    else
                        QuickTween(Pill, 0.2, { BackgroundColor3 = Theme.ToggleOff })
                        QuickTween(Knob, 0.2, { Position = UDim2.new(0, 3, 0.5, -8) })
                    end
                end

                local ClickArea = Create("TextButton", {
                    Text             = "",
                    Size             = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Parent           = Row,
                })
                ClickArea.MouseButton1Click:Connect(function()
                    state = not state
                    UpdateToggle()
                    if cfg.Callback then cfg.Callback(state) end
                    if cfg.Flag and LuxwareUI.Flags then
                        LuxwareUI.Flags[cfg.Flag] = state
                    end
                end)

                local ToggleObj = {}
                function ToggleObj:Set(val)
                    state = val
                    UpdateToggle()
                    if cfg.Callback then cfg.Callback(state) end
                end
                if cfg.Flag then
                    if not LuxwareUI.Flags then LuxwareUI.Flags = {} end
                    LuxwareUI.Flags[cfg.Flag] = state
                end
                return ToggleObj
            end

            -- ---- SLIDER -----------------------------------------
            function SectionObj:CreateSlider(cfg)
                cfg = cfg or {}
                local Min     = cfg.Range and cfg.Range[1] or 0
                local Max     = cfg.Range and cfg.Range[2] or 100
                local Default = cfg.CurrentValue or Min
                local Inc     = cfg.Increment or 1
                local Value   = math.clamp(Default, Min, Max)

                local Row = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 56),
                    BackgroundColor3 = Theme.Surface,
                    Parent           = Section,
                })
                MakeCorner(9, Row)
                MakeStroke(1, Theme.Border, 0.5, Row)
                MakePadding(10, 10, 14, 14, Row)

                local TopRow = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Parent           = Row,
                })
                Create("TextLabel", {
                    Text            = cfg.Name or "Slider",
                    Font            = Enum.Font.Gotham,
                    TextSize        = 13,
                    TextColor3      = Theme.Text,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Size            = UDim2.fromScale(0.7, 1),
                    BackgroundTransparency = 1,
                    Parent          = TopRow,
                })
                local ValueLabel = Create("TextLabel", {
                    Text            = tostring(Value),
                    Font            = Enum.Font.GothamBold,
                    TextSize        = 12,
                    TextColor3      = Theme.Accent,
                    TextXAlignment  = Enum.TextXAlignment.Right,
                    Size            = UDim2.fromScale(0.3, 1),
                    Position        = UDim2.fromScale(0.7, 0),
                    BackgroundTransparency = 1,
                    Parent          = TopRow,
                })

                local Track = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 6),
                    Position         = UDim2.new(0, 0, 1, -6),
                    BackgroundColor3 = Theme.SurfaceLight,
                    Parent           = Row,
                })
                MakeCorner(4, Track)

                local Fill = Create("Frame", {
                    Size             = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0),
                    BackgroundColor3 = Theme.Slider,
                    Parent           = Track,
                })
                MakeCorner(4, Fill)

                local Thumb = Create("Frame", {
                    Size             = UDim2.fromOffset(14, 14),
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    Position         = UDim2.new((Value - Min) / (Max - Min), 0, 0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent           = Track,
                })
                MakeCorner(7, Thumb)
                MakeStroke(2, Theme.Accent, 0, Thumb)

                local dragging = false
                local function UpdateSlider(inputX)
                    local rel  = math.clamp((inputX - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local raw  = Min + (Max - Min) * rel
                    local snap = math.round(raw / Inc) * Inc
                    Value      = math.clamp(snap, Min, Max)
                    local pct  = (Value - Min) / (Max - Min)
                    QuickTween(Fill, 0.05, { Size = UDim2.new(pct, 0, 1, 0) })
                    QuickTween(Thumb, 0.05, { Position = UDim2.new(pct, 0, 0.5, 0) })
                    ValueLabel.Text = tostring(Value)
                    if cfg.Callback then cfg.Callback(Value) end
                    if cfg.Flag and LuxwareUI.Flags then LuxwareUI.Flags[cfg.Flag] = Value end
                end

                Track.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        UpdateSlider(inp.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
                    or inp.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(inp.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                local SliderObj = {}
                function SliderObj:Set(val)
                    Value = math.clamp(val, Min, Max)
                    local pct = (Value - Min) / (Max - Min)
                    Fill.Size   = UDim2.new(pct, 0, 1, 0)
                    Thumb.Position = UDim2.new(pct, 0, 0.5, 0)
                    ValueLabel.Text = tostring(Value)
                end
                if cfg.Flag then
                    if not LuxwareUI.Flags then LuxwareUI.Flags = {} end
                    LuxwareUI.Flags[cfg.Flag] = Value
                end
                return SliderObj
            end

            -- ---- INPUT (TextBox) ---------------------------------
            function SectionObj:CreateInput(cfg)
                cfg = cfg or {}

                local Row = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 54),
                    BackgroundColor3 = Theme.Surface,
                    Parent           = Section,
                })
                MakeCorner(9, Row)
                MakeStroke(1, Theme.Border, 0.5, Row)
                MakePadding(8, 8, 14, 14, Row)

                Create("TextLabel", {
                    Text            = cfg.Name or "Input",
                    Font            = Enum.Font.Gotham,
                    TextSize        = 12,
                    TextColor3      = Theme.TextDim,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Size            = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Parent          = Row,
                })

                local InputFrame = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 26),
                    Position         = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = Theme.SurfaceLight,
                    Parent           = Row,
                })
                MakeCorner(7, InputFrame)
                MakePadding(0, 0, 8, 8, InputFrame)
                MakeStroke(1, Theme.Border, 0, InputFrame)

                local TextBox = Create("TextBox", {
                    PlaceholderText  = cfg.PlaceholderText or "Enter value...",
                    PlaceholderColor3 = Theme.TextFaint,
                    Text             = cfg.CurrentValue or "",
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    TextColor3       = Theme.Text,
                    ClearTextOnFocus = cfg.ClearTextOnFocus ~= false,
                    Size             = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    Parent           = InputFrame,
                })
                TextBox.Focused:Connect(function()
                    QuickTween(InputFrame:FindFirstChildOfClass("UIStroke"), 0.2, { Color = Theme.Accent })
                end)
                TextBox.FocusLost:Connect(function(enter)
                    QuickTween(InputFrame:FindFirstChildOfClass("UIStroke"), 0.2, { Color = Theme.Border })
                    if (enter or not cfg.EnterPressOnly) and cfg.Callback then
                        cfg.Callback(TextBox.Text)
                    end
                    if cfg.Flag and LuxwareUI.Flags then
                        LuxwareUI.Flags[cfg.Flag] = TextBox.Text
                    end
                end)

                local InputObj = {}
                function InputObj:Set(val) TextBox.Text = val end
                return InputObj
            end

            -- ---- DROPDOWN ---------------------------------------
            function SectionObj:CreateDropdown(cfg)
                cfg = cfg or {}
                local Options  = cfg.Options or {}
                local Selected = cfg.CurrentOption or {}
                if type(Selected) == "string" then Selected = { Selected } end
                local MultiSelect = cfg.MultipleOptions or false
                local isOpen = false

                local Wrapper = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent           = Section,
                })
                Create("UIListLayout", {
                    FillDirection   = Enum.FillDirection.Vertical,
                    Parent          = Wrapper,
                })

                local Header = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 44),
                    BackgroundColor3 = Theme.Surface,
                    Parent           = Wrapper,
                })
                MakeCorner(9, Header)
                MakeStroke(1, Theme.Border, 0.5, Header)
                MakePadding(0, 0, 14, 14, Header)

                Create("UIListLayout", {
                    FillDirection   = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding         = UDim.new(0, 6),
                    Parent          = Header,
                })

                Create("TextLabel", {
                    Text            = cfg.Name or "Dropdown",
                    Font            = Enum.Font.Gotham,
                    TextSize        = 13,
                    TextColor3      = Theme.Text,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Size            = UDim2.new(1, -26, 1, 0),
                    BackgroundTransparency = 1,
                    Parent          = Header,
                })

                local SelectedLabel = Create("TextLabel", {
                    Text            = #Selected > 0 and table.concat(Selected, ", ") or "None",
                    Font            = Enum.Font.Gotham,
                    TextSize        = 11,
                    TextColor3      = Theme.TextDim,
                    TextXAlignment  = Enum.TextXAlignment.Right,
                    TextTruncate    = Enum.TextTruncate.AtEnd,
                    Size            = UDim2.new(0.5, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Parent          = Header,
                })

                local Arrow = Create("TextLabel", {
                    Text            = "▾",
                    Font            = Enum.Font.GothamBold,
                    TextSize        = 14,
                    TextColor3      = Theme.DropdownArrow,
                    Size            = UDim2.fromOffset(18, 18),
                    BackgroundTransparency = 1,
                    Parent          = Header,
                })

                -- Dropdown list
                local DropList = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    BackgroundColor3 = Theme.Surface,
                    ClipsDescendants = true,
                    Visible          = false,
                    Parent           = Wrapper,
                    ZIndex           = 5,
                })
                MakeCorner(9, DropList)
                MakeStroke(1, Theme.Border, 0.5, DropList)
                MakePadding(4, 4, 4, 4, DropList)

                local DropScroll = Create("ScrollingFrame", {
                    Size             = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Theme.Accent,
                    CanvasSize       = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent           = DropList,
                    ZIndex           = 6,
                })
                Create("UIListLayout", {
                    Padding         = UDim.new(0, 2),
                    Parent          = DropScroll,
                })

                local optionBtns = {}

                local function RefreshOptions()
                    for _, c in ipairs(DropScroll:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    optionBtns = {}
                    for _, opt in ipairs(Options) do
                        local isSelected = table.find(Selected, opt) ~= nil
                        local OptBtn = Create("TextButton", {
                            Text            = (isSelected and "✓  " or "    ") .. opt,
                            Font            = isSelected and Enum.Font.GothamBold or Enum.Font.Gotham,
                            TextSize        = 12,
                            TextColor3      = isSelected and Theme.Text or Theme.TextDim,
                            TextXAlignment  = Enum.TextXAlignment.Left,
                            Size            = UDim2.new(1, 0, 0, 32),
                            BackgroundColor3 = isSelected and Theme.SurfaceLight or Theme.Surface,
                            AutoButtonColor = false,
                            ZIndex          = 7,
                            Parent          = DropScroll,
                        })
                        MakeCorner(7, OptBtn)
                        MakePadding(0, 0, 10, 10, OptBtn)
                        OptBtn.MouseEnter:Connect(function()
                            QuickTween(OptBtn, 0.1, { BackgroundColor3 = Theme.SurfaceLight })
                        end)
                        OptBtn.MouseLeave:Connect(function()
                            local sel = table.find(Selected, opt) ~= nil
                            QuickTween(OptBtn, 0.1, { BackgroundColor3 = sel and Theme.SurfaceLight or Theme.Surface })
                        end)
                        OptBtn.MouseButton1Click:Connect(function()
                            if MultiSelect then
                                local idx = table.find(Selected, opt)
                                if idx then table.remove(Selected, idx) else table.insert(Selected, opt) end
                            else
                                Selected = { opt }
                                isOpen  = true
                                -- close
                                QuickTween(DropList, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
                                task.wait(0.2)
                                DropList.Visible = false
                                isOpen = false
                            end
                            SelectedLabel.Text = #Selected > 0 and table.concat(Selected, ", ") or "None"
                            RefreshOptions()
                            if cfg.Callback then
                                cfg.Callback(MultiSelect and Selected or Selected[1])
                            end
                            if cfg.Flag and LuxwareUI.Flags then
                                LuxwareUI.Flags[cfg.Flag] = MultiSelect and Selected or Selected[1]
                            end
                        end)
                        table.insert(optionBtns, OptBtn)
                    end
                end
                RefreshOptions()

                local HitArea = Create("TextButton", {
                    Text             = "",
                    Size             = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    ZIndex           = 4,
                    Parent           = Header,
                })
                HitArea.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        local targetH = math.min(#Options * 34 + 8, 180)
                        DropList.Visible = true
                        DropList.Size    = UDim2.new(1, 0, 0, 0)
                        QuickTween(DropList, 0.25, { Size = UDim2.new(1, 0, 0, targetH) })
                        QuickTween(Arrow, 0.2, { Rotation = 180 })
                    else
                        QuickTween(DropList, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
                        QuickTween(Arrow, 0.2, { Rotation = 0 })
                        task.wait(0.22)
                        DropList.Visible = false
                    end
                end)

                local DropObj = {}
                function DropObj:Set(val)
                    if type(val) == "string" then val = { val } end
                    Selected = val
                    SelectedLabel.Text = #Selected > 0 and table.concat(Selected, ", ") or "None"
                    RefreshOptions()
                end
                function DropObj:Refresh(newOpts)
                    Options = newOpts
                    RefreshOptions()
                end
                return DropObj
            end

            -- ---- COLOR PICKER -----------------------------------
            function SectionObj:CreateColorPicker(cfg)
                cfg = cfg or {}
                local defaultColor = cfg.Color or Color3.fromRGB(255, 100, 100)
                local h, s, v     = RGBtoHSV(defaultColor)
                local currentColor = defaultColor
                local pickerOpen   = false

                local Row = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 44),
                    BackgroundColor3 = Theme.Surface,
                    Parent           = Section,
                })
                MakeCorner(9, Row)
                MakeStroke(1, Theme.Border, 0.5, Row)
                MakePadding(0, 0, 14, 14, Row)

                Create("UIListLayout", {
                    FillDirection   = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding         = UDim.new(0, 10),
                    Parent          = Row,
                })

                Create("TextLabel", {
                    Text            = cfg.Name or "Color Picker",
                    Font            = Enum.Font.Gotham,
                    TextSize        = 13,
                    TextColor3      = Theme.Text,
                    Size            = UDim2.new(1, -44, 1, 0),
                    BackgroundTransparency = 1,
                    Parent          = Row,
                })

                local Swatch = Create("Frame", {
                    Size             = UDim2.fromOffset(28, 28),
                    BackgroundColor3 = currentColor,
                    Parent           = Row,
                })
                MakeCorner(6, Swatch)
                MakeStroke(2, Theme.Border, 0, Swatch)

                -- Picker popup
                local PickerFrame = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    BackgroundColor3 = Theme.SurfaceLight,
                    ClipsDescendants = true,
                    Visible          = false,
                    Parent           = Section,
                })
                MakeCorner(9, PickerFrame)
                MakeStroke(1, Theme.Border, 0.5, PickerFrame)
                MakePadding(12, 12, 12, 12, PickerFrame)

                -- SV canvas
                local SVCanvas = Create("ImageLabel", {
                    Size             = UDim2.new(1, 0, 0, 140),
                    Image            = "rbxassetid://4155801252",
                    BackgroundColor3 = HSVtoRGB(h, 1, 1),
                    Parent           = PickerFrame,
                })
                MakeCorner(7, SVCanvas)

                -- White gradient overlay
                Create("ImageLabel", {
                    Size             = UDim2.fromScale(1, 1),
                    Image            = "rbxassetid://4155801252",
                    BackgroundTransparency = 1,
                    ImageColor3      = Color3.fromRGB(255, 255, 255),
                    Parent           = SVCanvas,
                })

                -- SV Cursor
                local SVCursor = Create("Frame", {
                    Size             = UDim2.fromOffset(14, 14),
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    Position         = UDim2.new(s, 0, 1 - v, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    ZIndex           = 3,
                    Parent           = SVCanvas,
                })
                MakeCorner(7, SVCursor)
                MakeStroke(2, Color3.fromRGB(0, 0, 0), 0, SVCursor)

                -- Hue bar
                local HueBar = Create("ImageLabel", {
                    Size             = UDim2.new(1, 0, 0, 18),
                    Position         = UDim2.new(0, 0, 0, 150),
                    Image            = "rbxassetid://4155801252",
                    Parent           = PickerFrame,
                })
                MakeCorner(5, HueBar)

                -- Hue gradient
                local HueGrad = Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,  0,   0)),
                        ColorSequenceKeypoint.new(0.167,Color3.fromRGB(255, 255,  0)),
                        ColorSequenceKeypoint.new(0.333,Color3.fromRGB(0,   255,  0)),
                        ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0,   255, 255)),
                        ColorSequenceKeypoint.new(0.667,Color3.fromRGB(0,    0,  255)),
                        ColorSequenceKeypoint.new(0.833,Color3.fromRGB(255,  0,  255)),
                        ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,  0,   0)),
                    }),
                    Parent = HueBar,
                })

                local HueCursor = Create("Frame", {
                    Size             = UDim2.new(0, 6, 1, 4),
                    AnchorPoint      = Vector2.new(0.5, 0.5),
                    Position         = UDim2.new(h, 0, 0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    ZIndex           = 3,
                    Parent           = HueBar,
                })
                MakeCorner(3, HueCursor)
                MakeStroke(1.5, Color3.fromRGB(50, 50, 50), 0, HueCursor)

                -- Preview + hex
                local PreviewRow = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 30),
                    Position         = UDim2.new(0, 0, 0, 178),
                    BackgroundTransparency = 1,
                    Parent           = PickerFrame,
                })
                Create("UIListLayout", {
                    FillDirection   = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding         = UDim.new(0, 8),
                    Parent          = PreviewRow,
                })
                local Preview = Create("Frame", {
                    Size             = UDim2.fromOffset(28, 28),
                    BackgroundColor3 = currentColor,
                    Parent           = PreviewRow,
                })
                MakeCorner(6, Preview)
                MakeStroke(1.5, Theme.Border, 0, Preview)

                local HexBox = Create("TextBox", {
                    Text             = string.format("#%02X%02X%02X", math.floor(currentColor.R*255), math.floor(currentColor.G*255), math.floor(currentColor.B*255)),
                    Font             = Enum.Font.Code,
                    TextSize         = 13,
                    TextColor3       = Theme.Text,
                    ClearTextOnFocus = false,
                    Size             = UDim2.new(1, -36, 1, 0),
                    BackgroundColor3 = Theme.Background,
                    Parent           = PreviewRow,
                })
                MakeCorner(7, HexBox)
                MakePadding(0, 0, 8, 8, HexBox)

                local function Apply()
                    currentColor = HSVtoRGB(h, s, v)
                    SVCanvas.BackgroundColor3 = HSVtoRGB(h, 1, 1)
                    SVCursor.Position         = UDim2.new(s, 0, 1 - v, 0)
                    HueCursor.Position        = UDim2.new(h, 0, 0.5, 0)
                    Preview.BackgroundColor3  = currentColor
                    Swatch.BackgroundColor3   = currentColor
                    HexBox.Text               = string.format("#%02X%02X%02X",
                        math.floor(currentColor.R*255),
                        math.floor(currentColor.G*255),
                        math.floor(currentColor.B*255))
                    if cfg.Callback then cfg.Callback(currentColor) end
                    if cfg.Flag and LuxwareUI.Flags then LuxwareUI.Flags[cfg.Flag] = currentColor end
                end

                -- SV drag
                local svDrag = false
                SVCanvas.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        svDrag = true
                        local rel = inp.Position - SVCanvas.AbsolutePosition
                        s = math.clamp(rel.X / SVCanvas.AbsoluteSize.X, 0, 1)
                        v = 1 - math.clamp(rel.Y / SVCanvas.AbsoluteSize.Y, 0, 1)
                        Apply()
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if svDrag and (inp.UserInputType == Enum.UserInputType.MouseMovement
                    or inp.UserInputType == Enum.UserInputType.Touch) then
                        local rel = inp.Position - SVCanvas.AbsolutePosition
                        s = math.clamp(rel.X / SVCanvas.AbsoluteSize.X, 0, 1)
                        v = 1 - math.clamp(rel.Y / SVCanvas.AbsoluteSize.Y, 0, 1)
                        Apply()
                    end
                end)

                -- Hue drag
                local hueDrag = false
                HueBar.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        hueDrag = true
                        h = math.clamp((inp.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                        Apply()
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if hueDrag and (inp.UserInputType == Enum.UserInputType.MouseMovement
                    or inp.UserInputType == Enum.UserInputType.Touch) then
                        h = math.clamp((inp.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                        Apply()
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        svDrag = false; hueDrag = false
                    end
                end)

                -- Hex input
                HexBox.FocusLost:Connect(function()
                    local hex = HexBox.Text:gsub("#", "")
                    if #hex == 6 then
                        local r = tonumber(hex:sub(1,2), 16)
                        local g = tonumber(hex:sub(3,4), 16)
                        local b = tonumber(hex:sub(5,6), 16)
                        if r and g and b then
                            currentColor = Color3.fromRGB(r, g, b)
                            h, s, v = RGBtoHSV(currentColor)
                            Apply()
                        end
                    end
                end)

                local SwatchBtn = Create("TextButton", {
                    Text             = "",
                    Size             = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    ZIndex           = 2,
                    Parent           = Swatch,
                })
                SwatchBtn.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    if pickerOpen then
                        PickerFrame.Visible = true
                        PickerFrame.Size    = UDim2.new(1, 0, 0, 0)
                        QuickTween(PickerFrame, 0.25, { Size = UDim2.new(1, 0, 0, 218) })
                    else
                        QuickTween(PickerFrame, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
                        task.wait(0.22)
                        PickerFrame.Visible = false
                    end
                end)

                local CPObj = {}
                function CPObj:Set(color)
                    currentColor = color
                    h, s, v = RGBtoHSV(color)
                    Apply()
                end
                return CPObj
            end

            -- ---- LABEL ------------------------------------------
            function SectionObj:CreateLabel(cfg)
                cfg = cfg or {}
                local Lbl = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = Theme.Surface,
                    Parent           = Section,
                })
                MakeCorner(9, Lbl)
                MakeStroke(1, Theme.Border, 0.7, Lbl)
                MakePadding(0, 0, 14, 14, Lbl)

                local Txt = Create("TextLabel", {
                    Text            = cfg.Text or "Label",
                    Font            = Enum.Font.Gotham,
                    TextSize        = 13,
                    TextColor3      = Theme.TextDim,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    TextWrapped     = true,
                    Size            = UDim2.fromScale(1, 1),
                    BackgroundTransparency = 1,
                    Parent          = Lbl,
                })

                local LblObj = {}
                function LblObj:Set(text) Txt.Text = text end
                return LblObj
            end

            -- ---- KEYBIND ----------------------------------------
            function SectionObj:CreateKeybind(cfg)
                cfg = cfg or {}
                local currentKey = cfg.CurrentKeybind or "None"
                local listening  = false

                local Row = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 44),
                    BackgroundColor3 = Theme.Surface,
                    Parent           = Section,
                })
                MakeCorner(9, Row)
                MakeStroke(1, Theme.Border, 0.5, Row)
                MakePadding(0, 0, 14, 14, Row)

                Create("UIListLayout", {
                    FillDirection   = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding         = UDim.new(0, 8),
                    Parent          = Row,
                })

                Create("TextLabel", {
                    Text            = cfg.Name or "Keybind",
                    Font            = Enum.Font.Gotham,
                    TextSize        = 13,
                    TextColor3      = Theme.Text,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Size            = UDim2.new(1, -80, 1, 0),
                    BackgroundTransparency = 1,
                    Parent          = Row,
                })

                local KeyPill = Create("TextButton", {
                    Text            = "[" .. currentKey .. "]",
                    Font            = Enum.Font.GothamBold,
                    TextSize        = 11,
                    TextColor3      = Theme.Accent,
                    Size            = UDim2.fromOffset(72, 26),
                    BackgroundColor3 = Theme.SurfaceLight,
                    AutoButtonColor = false,
                    Parent          = Row,
                })
                MakeCorner(6, KeyPill)
                MakeStroke(1, Theme.Accent, 0.5, KeyPill)

                KeyPill.MouseButton1Click:Connect(function()
                    listening = true
                    KeyPill.Text      = "..."
                    KeyPill.TextColor3 = Theme.Warning
                end)

                UserInputService.InputBegan:Connect(function(inp, gp)
                    if listening and not gp then
                        if inp.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = inp.KeyCode.Name
                            listening  = false
                            KeyPill.Text       = "[" .. currentKey .. "]"
                            KeyPill.TextColor3 = Theme.Accent
                            if cfg.Callback then cfg.Callback(inp.KeyCode) end
                        end
                    elseif not listening and inp.KeyCode.Name == currentKey and not gp then
                        if cfg.HoldToInteract then
                            -- hold logic
                        else
                            if cfg.Callback then cfg.Callback(inp.KeyCode) end
                        end
                    end
                end)

                local KBObj = {}
                function KBObj:Set(key)
                    currentKey    = key
                    KeyPill.Text  = "[" .. key .. "]"
                end
                return KBObj
            end

            -- ---- MODULE CONFIGURATION ---------------------------
            function SectionObj:CreateModuleConfig(cfg)
                cfg = cfg or {}
                local isOpen = false

                local Wrapper = Create("Frame", {
                    Size             = UDim2.new(1, 0, 0, 0),
                    AutomaticSize    = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent           = Section,
                })
                Create("UIListLayout", {
                    FillDirection   = Enum.FillDirection.Vertical,
                    Parent          = Wrapper,
                })

                local Header = Create("TextButton", {
                    Text            = "",
                    Size            = UDim2.new(1, 0, 0, 44),
                    BackgroundColor3 = Theme.Surface,
                    AutoButtonColor = false,
                    Parent          = Wrapper,
                })
                MakeCorner(9, Header)
                MakeStroke(1, Theme.Accent, 0.5, Header)
                MakePadding(0, 0, 14, 14, Header)

                Create("UIListLayout", {
                    FillDirection   = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding         = UDim.new(0, 8),
                    Parent          = Header,
                })
                Create("TextLabel", {
                    Text            = "⚙  " .. (cfg.Name or "Module Config"),
                    Font            = Enum.Font.GothamBold,
                    TextSize        = 13,
                    TextColor3      = Theme.AccentLight,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    Size            = UDim2.new(1, -26, 1, 0),
                    BackgroundTransparency = 1,
                    Parent          = Header,
                })
                local Arr = Create("TextLabel", {
                    Text            = "▾",
                    Font            = Enum.Font.GothamBold,
                    TextSize        = 14,
                    TextColor3      = Theme.Accent,
                    Size            = UDim2.fromOffset(18, 18),
                    BackgroundTransparency = 1,
                    Parent          = Header,
                })

                local Inner = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 0),
                    BackgroundColor3 = Theme.SurfaceLight,
                    ClipsDescendants = true,
                    Parent          = Wrapper,
                })
                MakeCorner(9, Inner)
                MakeStroke(1, Theme.Border, 0.5, Inner)
                MakePadding(8, 8, 10, 10, Inner)
                Create("UIListLayout", {
                    Padding         = UDim.new(0, 4),
                    FillDirection   = Enum.FillDirection.Vertical,
                    Parent          = Inner,
                })

                -- Provide a sub-section API within the config panel
                local subSection = { _container = Inner }
                -- Inherit all element creation from SectionObj
                for k, fn in pairs(SectionObj) do
                    if k ~= "CreateModuleConfig" then
                        subSection[k] = function(_, c)
                            local orig = c and c.Parent
                            if c then c._parentOverride = Inner end
                            return fn(subSection, c)
                        end
                    end
                end

                Header.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        local children = Inner:GetChildren()
                        local count    = 0
                        for _, c in ipairs(children) do
                            if c:IsA("GuiObject") and not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
                                count += 1
                            end
                        end
                        local targetH = math.max(count * 50, 80)
                        QuickTween(Inner, 0.25, { Size = UDim2.new(1, 0, 0, targetH) })
                        QuickTween(Arr, 0.2, { Rotation = 180 })
                    else
                        QuickTween(Inner, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
                        QuickTween(Arr, 0.2, { Rotation = 0 })
                    end
                end)

                return subSection
            end

            return SectionObj
        end

        return TabObj
    end

    -- ============================================================
    -- NOTIFICATIONS
    -- ============================================================
    function WindowObj:Notify(cfg)
        cfg = cfg or {}
        local title    = cfg.Title   or "Notification"
        local content  = cfg.Content or ""
        local duration = cfg.Duration or 4
        local ntype    = cfg.Type    or "info"-- info | success | error | warning

        local color = ({ info = Theme.Accent, success = Theme.Success, error = Theme.Error, warning = Theme.Warning })[ntype] or Theme.Accent

        -- Notification container (shared)
        local notifParent = ScreenGui:FindFirstChild("NotifStack")
        if not notifParent then
            notifParent = Create("Frame", {
                Name             = "NotifStack",
                Size             = UDim2.new(0, 280, 1, 0),
                Position         = UDim2.new(1, -290, 0, 0),
                BackgroundTransparency = 1,
                Parent           = ScreenGui,
            })
            Create("UIListLayout", {
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                FillDirection    = Enum.FillDirection.Vertical,
                Padding          = UDim.new(0, 8),
                Parent           = notifParent,
            })
            MakePadding(0, 14, 0, 0, notifParent)
        end

        local Card = Create("Frame", {
            Size             = UDim2.new(1, 0, 0, 70),
            BackgroundColor3 = Theme.Surface,
            BackgroundTransparency = 1,
            Parent           = notifParent,
        })
        MakeCorner(10, Card)
        MakeStroke(1.5, color, 0.3, Card)
        MakePadding(10, 10, 14, 14, Card)

        -- Accent bar
        Create("Frame", {
            Size             = UDim2.new(0, 3, 1, -20),
            Position         = UDim2.new(0, 0, 0, 10),
            BackgroundColor3 = color,
            Parent           = Card,
        })

        Create("TextLabel", {
            Text            = title,
            Font            = Enum.Font.GothamBold,
            TextSize        = 13,
            TextColor3      = Theme.Text,
            TextXAlignment  = Enum.TextXAlignment.Left,
            Size            = UDim2.new(1, -12, 0, 20),
            Position        = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Parent          = Card,
        })
        Create("TextLabel", {
            Text            = content,
            Font            = Enum.Font.Gotham,
            TextSize        = 12,
            TextColor3      = Theme.TextDim,
            TextXAlignment  = Enum.TextXAlignment.Left,
            TextWrapped     = true,
            Size            = UDim2.new(1, -12, 1, -24),
            Position        = UDim2.new(0, 12, 0, 24),
            BackgroundTransparency = 1,
            Parent          = Card,
        })

        -- Progress bar
        local ProgTrack = Create("Frame", {
            Size             = UDim2.new(1, -12, 0, 2),
            Position         = UDim2.new(0, 12, 1, -4),
            BackgroundColor3 = Theme.Border,
            Parent           = Card,
        })
        MakeCorner(2, ProgTrack)
        local ProgFill = Create("Frame", {
            Size             = UDim2.fromScale(1, 1),
            BackgroundColor3 = color,
            Parent           = ProgTrack,
        })
        MakeCorner(2, ProgFill)

        QuickTween(Card, 0.3, { BackgroundTransparency = 0 })
        Tween(ProgFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(0, 1) })
        task.delay(duration, function()
            QuickTween(Card, 0.3, { BackgroundTransparency = 1 })
            task.wait(0.35)
            Card:Destroy()
        end)
    end

    -- ============================================================
    -- DIALOG
    -- ============================================================
    function WindowObj:Dialog(cfg)
        cfg = cfg or {}
        local title   = cfg.Title   or "Dialog"
        local content = cfg.Content or ""
        local buttons = cfg.Buttons or { { Title = "OK", Callback = function() end } }

        local Overlay = Create("Frame", {
            Size             = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            ZIndex           = 20,
            Parent           = ScreenGui,
        })

        local Card = Create("Frame", {
            Size             = UDim2.fromOffset(340, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            Position         = UDim2.fromScale(0.5, 0.5),
            AnchorPoint      = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Surface,
            ZIndex           = 21,
            Parent           = ScreenGui,
        })
        MakeCorner(14, Card)
        MakeStroke(1.5, Theme.Accent, 0.4, Card)
        MakePadding(20, 20, 24, 24, Card)

        Create("UIListLayout", {
            FillDirection   = Enum.FillDirection.Vertical,
            Padding         = UDim.new(0, 10),
            Parent          = Card,
        })

        Create("TextLabel", {
            Text            = title,
            Font            = Enum.Font.GothamBold,
            TextSize        = 16,
            TextColor3      = Theme.Text,
            TextXAlignment  = Enum.TextXAlignment.Left,
            Size            = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            ZIndex          = 22,
            Parent          = Card,
        })
        Create("TextLabel", {
            Text            = content,
            Font            = Enum.Font.Gotham,
            TextSize        = 13,
            TextColor3      = Theme.TextDim,
            TextXAlignment  = Enum.TextXAlignment.Left,
            TextWrapped     = true,
            Size            = UDim2.new(1, 0, 0, 0),
            AutomaticSize   = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            ZIndex          = 22,
            Parent          = Card,
        })

        local BtnRow = Create("Frame", {
            Size            = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            ZIndex          = 22,
            Parent          = Card,
        })
        Create("UIListLayout", {
            FillDirection   = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding         = UDim.new(0, 8),
            Parent          = BtnRow,
        })

        for i, btnCfg in ipairs(buttons) do
            local isAccent = (i == #buttons)
            local Btn = Create("TextButton", {
                Text            = btnCfg.Title or "OK",
                Font            = Enum.Font.GothamBold,
                TextSize        = 13,
                TextColor3      = Theme.Text,
                Size            = UDim2.fromOffset(90, 36),
                BackgroundColor3 = isAccent and Theme.Accent or Theme.SurfaceLight,
                AutoButtonColor = false,
                ZIndex          = 23,
                Parent          = BtnRow,
            })
            MakeCorner(9, Btn)
            Btn.MouseButton1Click:Connect(function()
                QuickTween(Card, 0.25, { BackgroundTransparency = 1 })
                QuickTween(Overlay, 0.25, { BackgroundTransparency = 1 })
                task.wait(0.28)
                Card:Destroy(); Overlay:Destroy()
                if btnCfg.Callback then btnCfg.Callback() end
            end)
        end

        SpringTween(Card, 0.4, { BackgroundTransparency = 0 })
    end

    -- ============================================================
    -- DESTROY
    -- ============================================================
    function WindowObj:Destroy()
        QuickTween(Window, 0.3, { Size = UDim2.fromOffset(WinW, 0), BackgroundTransparency = 1 })
        task.wait(0.35)
        ScreenGui:Destroy()
    end

    return WindowObj
end

-- ============================================================
-- THEME CUSTOMIZATION
-- ============================================================
function LuxwareUI:SetTheme(customTheme)
    for k, v in pairs(customTheme) do
        Theme[k] = v
    end
end

-- Global flags table
LuxwareUI.Flags = {}

return LuxwareUI
