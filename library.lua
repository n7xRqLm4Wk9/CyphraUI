-- [[ LuxwareUI Framework | Mobile & PC Universal Edition ]] --

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CurrentCamera = Workspace.CurrentCamera

local Luxware = {}
Luxware.__index = Luxware

-- // Fluid Dark AMOLED Color Palette
local Theme = {
    Background = Color3.fromRGB(11, 11, 11),
    Sidebar = Color3.fromRGB(14, 14, 14),
    ElementBG = Color3.fromRGB(18, 18, 18),
    ElementHover = Color3.fromRGB(26, 26, 26),
    Border = Color3.fromRGB(32, 32, 32),
    Text = Color3.fromRGB(245, 245, 245),
    SubText = Color3.fromRGB(140, 140, 140),
    Accent = Color3.fromRGB(90, 140, 250),
    KeyIcon = Color3.fromRGB(230, 125, 45), -- Clean key accent color
}

local TWEEN_SPEED = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- // Framework Generation Helpers
local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do inst[k] = v end
    return inst
end

local function ApplyCorner(parent, radius)
    return Create("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius or 8)})
end

local function ApplyStroke(parent, color, transparency)
    return Create("UIStroke", {
        Parent = parent,
        Color = color or Theme.Border,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
end

local function PlayTween(object, props)
    local tween = TweenService:Create(object, TWEEN_SPEED, props)
    tween:Play()
    return tween
end

-- // Seamless Mobile & PC Dragging Architecture
local function MakeDraggable(dragHandle, targetFrame)
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- // Primary Window Builder
function Luxware:CreateWindow(options)
    local WindowName = options.Name or "Luxware"
    local WindowSub = options.SubName or "Advanced User"
    local UseKey = options.KeySystem or false
    local ExpectedKey = options.Key or ""
    local KeyLink = options.KeyLink or "https://jnkie.com/"

    local TargetUI = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

    local ScreenGui = Create("ScreenGui", {
        Name = "LuxwareUniversal",
        Parent = TargetUI,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Responsive Window Frame Setup
    local WindowFrame = Create("Frame", {
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, math.min(600, CurrentCamera.ViewportSize.X - 20), 0, math.min(380, CurrentCamera.ViewportSize.Y - 20)),
        ClipsDescendants = true,
        Visible = not UseKey -- Hidden until verified if KeySystem is active
    })
    ApplyCorner(WindowFrame, 10)
    ApplyStroke(WindowFrame, Theme.Border)

    -- Window Drag Handle & Header Topbar
    local Topbar = Create("Frame", {
        Parent = WindowFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 35),
        ZIndex = 10
    })
    MakeDraggable(Topbar, WindowFrame)

    Create("TextLabel", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 250, 1, 0),
        Text = WindowName,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local CloseBtn = Create("TextButton", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -40, 0, 0),
        Size = UDim2.new(0, 40, 1, 0),
        Text = "✕",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = Theme.SubText
    })
    CloseBtn.Activated:Connect(function() ScreenGui:Destroy() end)

    -- Navigation Sidebar Layout
    local Sidebar = Create("Frame", {
        Parent = WindowFrame,
        BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(0, 160, 1, 0),
        Position = UDim2.new(0, 0, 0, 0)
    })
    ApplyCorner(Sidebar, 10)
    ApplyStroke(Sidebar, Theme.Border)

    -- Profile Indicator Widget
    local ProfileFrame = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.ElementBG,
        Size = UDim2.new(1, -16, 0, 42),
        Position = UDim2.new(0, 8, 0, 45)
    })
    ApplyCorner(ProfileFrame, 6)

    local Avatar = Create("ImageLabel", {
        Parent = ProfileFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 8, 0.5, -12),
        Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    })
    ApplyCorner(Avatar, 100)

    Create("TextLabel", {
        Parent = ProfileFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 38, 0, 7),
        Size = UDim2.new(1, -42, 0, 14),
        Text = LocalPlayer.DisplayName,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Create("TextLabel", {
        Parent = ProfileFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 38, 0, 21),
        Size = UDim2.new(1, -42, 0, 12),
        Text = WindowSub,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Functional Navigation Area
    local TabScroll = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -100),
        Position = UDim2.new(0, 0, 0, 95),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    local TabUIList = Create("UIListLayout", {
        Parent = TabScroll,
        Padding = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })

    local ContentContainer = Create("Frame", {
        Parent = WindowFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -165, 1, -40),
        Position = UDim2.new(0, 165, 0, 40)
    })

    -- ============================================================================
    -- EXACT KEY SYSTEM REPLICATION (Image 1000106352.jpg)
    -- ============================================================================
    if UseKey then
        local KeyWindow = Create("Frame", {
            Parent = ScreenGui,
            BackgroundColor3 = Theme.Background,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 360, 0, 250),
            ZIndex = 100
        })
        ApplyCorner(KeyWindow, 8)
        ApplyStroke(KeyWindow, Theme.Border)

        local KeyTopbar = Create("Frame", {
            Parent = KeyWindow,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 35)
        })
        MakeDraggable(KeyTopbar, KeyWindow)

        local KeyClose = Create("TextButton", {
            Parent = KeyTopbar,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -35, 0, 0),
            Size = UDim2.new(0, 35, 1, 0),
            Text = "✕",
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextColor3 = Theme.SubText
        })
        KeyClose.Activated:Connect(function() ScreenGui:Destroy() end)

        -- Centered Header Elements
        Create("TextLabel", {
            Parent = KeyWindow,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 25),
            Size = UDim2.new(1, 0, 0, 30),
            Text = "Key System",
            Font = Enum.Font.GothamMedium,
            TextSize = 20,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Center
        })

        -- Subtitle Container with standard key emoji integration
        local Subtitle = Create("TextLabel", {
            Parent = KeyWindow,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 58),
            Size = UDim2.new(1, 0, 0, 20),
            Text = "🔑 Enter Key To Access The Script",
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Center
        })

        -- Large Styled Input Box
        local KeyInput = Create("TextBox", {
            Parent = KeyWindow,
            BackgroundColor3 = Theme.Sidebar,
            Position = UDim2.new(0, 25, 0, 100),
            Size = UDim2.new(1, -50, 0, 48),
            PlaceholderText = "Enter Key...",
            Text = "",
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Theme.Text,
            PlaceholderColor3 = Theme.SubText,
            ClearTextOnFocus = false
        })
        ApplyCorner(KeyInput, 6)
        ApplyStroke(KeyInput, Theme.Border)

        -- Action Buttons Placement Block
        local GetBtn = Create("TextButton", {
            Parent = KeyWindow,
            BackgroundColor3 = Theme.Sidebar,
            Position = UDim2.new(0, 25, 0, 170),
            Size = UDim2.new(0, 145, 0, 40),
            Text = "Get Key",
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Theme.Text
        })
        ApplyCorner(GetBtn, 6)
        ApplyStroke(GetBtn, Theme.Border)

        local CheckBtn = Create("TextButton", {
            Parent = KeyWindow,
            BackgroundColor3 = Theme.Sidebar,
            Position = UDim2.new(1, -170, 0, 170),
            Size = UDim2.new(0, 145, 0, 40),
            Text = "Check Key",
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Theme.Text
        })
        ApplyCorner(CheckBtn, 6)
        ApplyStroke(CheckBtn, Theme.Border)

        -- Key Function Integrations
        CheckBtn.Activated:Connect(function()
            if KeyInput.Text == ExpectedKey then
                Subtitle.Text = "Access Verified Successfully!"
                Subtitle.TextColor3 = Color3.fromRGB(85, 255, 120)
                task.wait(0.4)
                KeyWindow:Destroy()
                WindowFrame.Visible = true
            else
                Subtitle.Text = "❌ Verification Failed. Retrying..."
                Subtitle.TextColor3 = Color3.fromRGB(255, 85, 85)
                task.wait(1.2)
                Subtitle.Text = "🔑 Enter Key To Access The Script"
                Subtitle.TextColor3 = Theme.SubText
            end
        end)

        GetBtn.Activated:Connect(function()
            pcall(function() setclipboard(KeyLink) end)
            GetBtn.Text = "Copied to Clipboard!"
            task.wait(1.5)
            GetBtn.Text = "Get Key"
        end)
    end

    -- ============================================================================
    -- CORE SIDEBAR NAVIGATION CONTROLS
    -- ============================================================================
    local WindowAPI = {}
    local Tabs = {}
    local IsFirstTab = true

    function WindowAPI:CreateTab(tabOpts)
        local TabName = tabOpts.Name or "Tab"
        local TabIcon = tabOpts.Icon or "•"

        local TabBtn = Create("TextButton", {
            Parent = TabScroll,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -12, 0, 32),
            Text = ""
        })
        local TabBG = Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = Theme.ElementHover,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1
        })
        ApplyCorner(TabBG, 5)

        local ActiveMarker = Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 3, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5)
        })
        ApplyCorner(ActiveMarker, 4)

        local Label = Create("TextLabel", {
            Parent = TabBtn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -12, 1, 0),
            Text = TabIcon .. "  " .. TabName,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Responsive Workspace Page
        local Page = Create("ScrollingFrame", {
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 1, -10),
            Position = UDim2.new(0, 5, 0, 5),
            ScrollBarThickness = 0,
            Visible = false
        })
        local PageLayout = Create("UIListLayout", {
            Parent = Page,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
        end)

        table.insert(Tabs, {Btn = TabBtn, BG = TabBG, Marker = ActiveMarker, Txt = Label, Pg = Page})

        local function SwitchToThisTab()
            for _, t in ipairs(Tabs) do
                t.Pg.Visible = false
                PlayTween(t.BG, {BackgroundTransparency = 1})
                PlayTween(t.Marker, {Size = UDim2.new(0, 3, 0, 0)})
                PlayTween(t.Txt, {TextColor3 = Theme.SubText})
            end
            Page.Visible = true
            PlayTween(TabBG, {BackgroundTransparency = 0})
            PlayTween(ActiveMarker, {Size = UDim2.new(0, 3, 0, 14)})
            PlayTween(Label, {TextColor3 = Theme.Text})
        end

        TabBtn.Activated:Connect(SwitchToThisTab)
        if IsFirstTab then SwitchToThisTab() IsFirstTab = false end

        -- ============================================================================
        -- SYSTEM COMPONENT CREATION MODULES
        -- ============================================================================
        local TabAPI = {}

        function TabAPI:CreateSection(title)
            local SectionLabel = Create("TextLabel", {
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                Text = title,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        local function CreateElementRow(name, desc)
            local RowFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Theme.ElementBG,
                Size = UDim2.new(1, 0, 0, 50)
            })
            ApplyCorner(RowFrame, 6)
            ApplyStroke(RowFrame, Theme.Border)

            Create("TextLabel", {
                Parent = RowFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 8),
                Size = UDim2.new(1, -160, 0, 16),
                Text = name,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            if desc then
                Create("TextLabel", {
                    Parent = RowFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 24),
                    Size = UDim2.new(1, -160, 0, 14),
                    Text = desc,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = Theme.SubText,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            return RowFrame
        end

        function TabAPI:CreateDropdown(opts)
            local Row = CreateElementRow(opts.Name, opts.Description)
            local list = opts.Options or {}

            local MainBox = Create("TextButton", {
                Parent = Row,
                BackgroundColor3 = Theme.Sidebar,
                Size = UDim2.new(0, 130, 0, 30),
                Position = UDim2.new(1, -140, 0.5, -15),
                Text = ""
            })
            ApplyCorner(MainBox, 5)
            ApplyStroke(MainBox, Theme.Border)

            local DisplayText = Create("TextLabel", {
                Parent = MainBox,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -25, 1, 0),
                Text = tostring(list[1] or "Select..."),
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            MainBox.Activated:Connect(function()
                table.insert(list, table.remove(list, 1))
                local nextSelection = list[1]
                DisplayText.Text = nextSelection
                if opts.Callback then pcall(opts.Callback, nextSelection) end
            end)
        end

        function TabAPI:CreateToggle(opts)
            local Row = CreateElementRow(opts.Name, opts.Description)
            local enabled = opts.CurrentValue or false

            local Switch = Create("TextButton", {
                Parent = Row,
                BackgroundColor3 = enabled and Theme.Accent or Theme.Sidebar,
                Size = UDim2.new(0, 38, 0, 20),
                Position = UDim2.new(1, -52, 0.5, -10),
                Text = ""
            })
            ApplyCorner(Switch, 10)
            ApplyStroke(Switch, Theme.Border)

            local Ball = Create("Frame", {
                Parent = Switch,
                BackgroundColor3 = enabled and Color3.fromRGB(0,0,0) or Theme.SubText,
                Size = UDim2.new(0, 12, 0, 12),
                Position = enabled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
            })
            ApplyCorner(Ball, 100)

            Switch.Activated:Connect(function()
                enabled = not enabled
                PlayTween(Switch, {BackgroundColor3 = enabled and Theme.Accent or Theme.Sidebar})
                PlayTween(Ball, {
                    Position = enabled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
                    BackgroundColor3 = enabled and Color3.fromRGB(0,0,0) or Theme.SubText
                })
                if opts.Callback then pcall(opts.Callback, enabled) end
            end)
        end

        function TabAPI:CreateColorPicker(opts)
            local Row = CreateElementRow(opts.Name, opts.Description)
            local selectedColor = opts.Color or Color3.fromRGB(255, 255, 255)

            local ChannelBlock = Create("TextButton", {
                Parent = Row,
                BackgroundColor3 = selectedColor,
                Size = UDim2.new(0, 50, 0, 26),
                Position = UDim2.new(1, -64, 0.5, -13),
                Text = ""
            })
            ApplyCorner(ChannelBlock, 5)
            ApplyStroke(ChannelBlock, Theme.Border)

            local OpenState = false
            local ExpandPanel = Create("Frame", {
                Parent = Row,
                BackgroundColor3 = Theme.Sidebar,
                Size = UDim2.new(1, 0, 0, 110),
                Position = UDim2.new(0, 0, 1, 4),
                Visible = false,
                ZIndex = 8
            })
            ApplyCorner(ExpandPanel, 6)
            ApplyStroke(ExpandPanel, Theme.Border)

            local function SetupBoxField(tag, offset, initVal)
                local Wrap = Create("Frame", {Parent = ExpandPanel, BackgroundTransparency = 1, Size = UDim2.new(0, 55, 0, 28), Position = UDim2.new(0, offset, 0, 12)})
                Create("TextLabel", {Parent = Wrap, BackgroundTransparency = 1, Size = UDim2.new(0, 16, 1, 0), Text = tag, Font = Enum.Font.GothamBold, TextColor3 = Theme.SubText, TextSize = 11})
                local Box = Create("TextBox", {Parent = Wrap, BackgroundColor3 = Theme.ElementBG, Position = UDim2.new(0, 18, 0, 0), Size = UDim2.new(0, 36, 1, 0), Text = tostring(math.floor(initVal * 255)), Font = Enum.Font.Gotham, TextColor3 = Theme.Text, TextSize = 11})
                ApplyCorner(Box, 4) ApplyStroke(Box, Theme.Border)
                return Box
            end

            local RField = SetupBoxField("R:", 15, selectedColor.R)
            local GField = SetupBoxField("G:", 80, selectedColor.G)
            local BField = SetupBoxField("B:", 145, selectedColor.B)

            local function EvaluateInputMatrix()
                local r = math.clamp(tonumber(RField.Text) or 255, 0, 255)
                local g = math.clamp(tonumber(GField.Text) or 255, 0, 255)
                local b = math.clamp(tonumber(BField.Text) or 255, 0, 255)
                selectedColor = Color3.fromRGB(r, g, b)
                ChannelBlock.BackgroundColor3 = selectedColor
                if opts.Callback then pcall(opts.Callback, selectedColor) end
            end

            RField.FocusLost:Connect(EvaluateInputMatrix)
            GField.FocusLost:Connect(EvaluateInputMatrix)
            BField.FocusLost:Connect(EvaluateInputMatrix)

            ChannelBlock.Activated:Connect(function()
                OpenState = not OpenState
                ExpandPanel.Visible = OpenState
                Row.Size = OpenState and UDim2.new(1, 0, 0, 165) or UDim2.new(1, 0, 0, 50)
            end)
        end

        return TabAPI
    end

    return WindowAPI
end

return Luxware
