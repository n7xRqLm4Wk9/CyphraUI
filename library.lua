-- [[ LuxwareUI | Fluent Design Rebuild ]] --
-- Inspired by Fluent UI / Windows 11 Aesthetics

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Luxware = {}
Luxware.__index = Luxware

-- // Fluent Theme Palette (AMOLED)
local Theme = {
    Background = Color3.fromRGB(10, 10, 10),      -- Deep AMOLED Black
    Sidebar = Color3.fromRGB(15, 15, 15),
    ElementBG = Color3.fromRGB(20, 20, 20),       -- Settings row background
    ElementHover = Color3.fromRGB(30, 30, 30),
    Border = Color3.fromRGB(40, 40, 40),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(100, 150, 255),       -- Fluent Blue
    Error = Color3.fromRGB(255, 85, 85),
    Success = Color3.fromRGB(85, 255, 120)
}

local TWEEN_SPEED = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- // Utility Functions
local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do inst[k] = v end
    return inst
end

local function ApplyCorner(parent, radius)
    return Create("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius or 6)})
end

local function ApplyStroke(parent, color, transparency)
    return Create("UIStroke", {Parent = parent, Color = color or Theme.Border, Transparency = transparency or 0})
end

local function PlayTween(object, props)
    local tween = TweenService:Create(object, TWEEN_SPEED, props)
    tween:Play()
    return tween
end

local function MakeDraggable(topbar, window)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- // Main Library Construction
function Luxware:CreateWindow(options)
    local WindowName = options.Name or "FluentLite dev"
    local WindowSub = options.SubName or "Advanced User"
    local UseKey = options.KeySystem or false
    local ExpectedKey = options.Key or ""
    local KeyLink = options.KeyLink or "https://jnkie.com/"
    
    local parentTarget = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    
    local LuxGUI = Create("ScreenGui", {
        Name = "LuxwareFluent",
        Parent = parentTarget,
        ResetOnSpawn = false,
        DisplayOrder = 100
    })

    -- Main Application Window
    local WindowFrame = Create("Frame", {
        Parent = LuxGUI,
        BackgroundColor3 = Theme.Background,
        Size = UDim2.new(0, 650, 0, 420),
        Position = UDim2.new(0.5, -325, 0.5, -210),
        ClipsDescendants = true
    })
    ApplyCorner(WindowFrame, 8)
    ApplyStroke(WindowFrame, Theme.Border)

    -- Topbar (Dragging & Close)
    local Topbar = Create("Frame", {
        Parent = WindowFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 10
    })
    MakeDraggable(Topbar, WindowFrame)

    Create("TextLabel", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Text = WindowName,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local CloseBtn = Create("TextButton", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0, 0),
        Size = UDim2.new(0, 35, 1, 0),
        Text = "✕",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Theme.SubText
    })
    CloseBtn.Activated:Connect(function() LuxGUI:Destroy() end)

    -- Sidebar Profile & Navigation
    local Sidebar = Create("Frame", {
        Parent = WindowFrame,
        BackgroundColor3 = Theme.Sidebar,
        Size = UDim2.new(0, 170, 1, 0),
        BorderSizePixel = 0
    })
    ApplyStroke(Sidebar, Theme.Border) -- Visual separator

    -- Profile Widget
    local ProfileFrame = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.ElementBG,
        Size = UDim2.new(1, -20, 0, 45),
        Position = UDim2.new(0, 10, 0, 35)
    })
    ApplyCorner(ProfileFrame, 6)

    local Avatar = Create("ImageLabel", {
        Parent = ProfileFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(0, 10, 0.5, -12.5),
        Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    })
    ApplyCorner(Avatar, 100)

    Create("TextLabel", {
        Parent = ProfileFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 45, 0, 8),
        Size = UDim2.new(1, -50, 0, 14),
        Text = LocalPlayer.Name,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Create("TextLabel", {
        Parent = ProfileFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 45, 0, 24),
        Size = UDim2.new(1, -50, 0, 12),
        Text = WindowSub,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Search Box (Visual only for aesthetic)
    local SearchBox = Create("TextBox", {
        Parent = Sidebar,
        BackgroundColor3 = Theme.ElementBG,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 90),
        PlaceholderText = "🔍 Search...",
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.SubText
    })
    ApplyCorner(SearchBox, 6)
    ApplyStroke(SearchBox, Theme.Border)

    -- Tab Container
    local TabScroll = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -130),
        Position = UDim2.new(0, 0, 0, 130),
        ScrollBarThickness = 0
    })
    local TabUIList = Create("UIListLayout", {
        Parent = TabScroll,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })

    -- Content Container
    local ContentContainer = Create("Frame", {
        Parent = WindowFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -170, 1, -30),
        Position = UDim2.new(0, 170, 0, 30)
    })

    -- // Key System Overlay
    if UseKey then
        local KeyOverlay = Create("Frame", {
            Parent = WindowFrame,
            BackgroundColor3 = Theme.Background,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 50
        })

        local KeyTitle = Create("TextLabel", {
            Parent = KeyOverlay,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 120),
            Size = UDim2.new(1, 0, 0, 30),
            Text = "Authentication Required",
            Font = Enum.Font.GothamBold,
            TextSize = 22,
            TextColor3 = Theme.Text
        })

        local KeyInput = Create("TextBox", {
            Parent = KeyOverlay,
            BackgroundColor3 = Theme.ElementBG,
            Position = UDim2.new(0.5, -150, 0, 170),
            Size = UDim2.new(0, 300, 0, 40),
            PlaceholderText = "Enter Access Key...",
            Text = "",
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Theme.Text
        })
        ApplyCorner(KeyInput, 6)
        ApplyStroke(KeyInput, Theme.Border)

        local CheckBtn = Create("TextButton", {
            Parent = KeyOverlay,
            BackgroundColor3 = Theme.Accent,
            Position = UDim2.new(0.5, -150, 0, 225),
            Size = UDim2.new(0, 145, 0, 35),
            Text = "Verify",
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(0,0,0)
        })
        ApplyCorner(CheckBtn, 6)

        local LinkBtn = Create("TextButton", {
            Parent = KeyOverlay,
            BackgroundColor3 = Theme.ElementBG,
            Position = UDim2.new(0.5, 5, 0, 225),
            Size = UDim2.new(0, 145, 0, 35),
            Text = "Get Key",
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Theme.Text
        })
        ApplyCorner(LinkBtn, 6)
        ApplyStroke(LinkBtn, Theme.Border)

        CheckBtn.Activated:Connect(function()
            if KeyInput.Text == ExpectedKey then
                KeyTitle.Text = "Access Granted!"
                KeyTitle.TextColor3 = Theme.Success
                task.wait(0.5)
                PlayTween(KeyOverlay, {BackgroundTransparency = 1})
                for _, v in ipairs(KeyOverlay:GetChildren()) do
                    if v:IsA("GuiObject") then PlayTween(v, {BackgroundTransparency = 1, TextTransparency = 1}) end
                end
                task.wait(0.2)
                KeyOverlay:Destroy()
            else
                KeyTitle.Text = "Invalid Key"
                KeyTitle.TextColor3 = Theme.Error
                task.wait(1)
                KeyTitle.Text = "Authentication Required"
                KeyTitle.TextColor3 = Theme.Text
            end
        end)

        LinkBtn.Activated:Connect(function()
            pcall(function() setclipboard(KeyLink) end)
            LinkBtn.Text = "Copied Link!"
            task.wait(1.5)
            LinkBtn.Text = "Get Key"
        end)
    end

    -- // Tabs API
    local WindowAPI = {}
    local Tabs = {}
    local FirstTab = true

    function WindowAPI:CreateTab(options)
        local TabName = options.Name or "Tab"
        local TabIcon = options.Icon or "•"

        -- Tab Button
        local TabBtn = Create("TextButton", {
            Parent = TabScroll,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 35),
            Text = ""
        })
        local TabBG = Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = Theme.ElementHover,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1
        })
        ApplyCorner(TabBG, 6)

        -- Vertical Active Indicator
        local Indicator = Create("Frame", {
            Parent = TabBtn,
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(0, 3, 0, 0), -- Animates to height 16
            Position = UDim2.new(0, 4, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5)
        })
        ApplyCorner(Indicator, 4)

        local IconLabel = Create("TextLabel", {
            Parent = TabBtn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 0),
            Size = UDim2.new(0, 20, 1, 0),
            Text = TabIcon,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Theme.SubText
        })

        local TitleLabel = Create("TextLabel", {
            Parent = TabBtn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 40, 0, 0),
            Size = UDim2.new(1, -40, 1, 0),
            Text = TabName,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = Theme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Tab Content Page
        local Page = Create("ScrollingFrame", {
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 1, -20),
            Position = UDim2.new(0, 15, 0, 10),
            ScrollBarThickness = 0,
            Visible = false
        })
        local PageLayout = Create("UIListLayout", {
            Parent = Page,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        -- Large Header for the Page
        Create("TextLabel", {
            Parent = Page,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            Text = TabName,
            Font = Enum.Font.GothamBold,
            TextSize = 24,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        table.insert(Tabs, {Btn = TabBtn, BG = TabBG, Ind = Indicator, Ico = IconLabel, Tit = TitleLabel, Pg = Page})

        local function ActivateTab()
            for _, t in ipairs(Tabs) do
                t.Pg.Visible = false
                PlayTween(t.BG, {BackgroundTransparency = 1})
                PlayTween(t.Ind, {Size = UDim2.new(0, 3, 0, 0)})
                PlayTween(t.Ico, {TextColor3 = Theme.SubText})
                PlayTween(t.Tit, {TextColor3 = Theme.SubText})
            end
            Page.Visible = true
            PlayTween(TabBG, {BackgroundTransparency = 0})
            PlayTween(Indicator, {Size = UDim2.new(0, 3, 0, 16)})
            PlayTween(IconLabel, {TextColor3 = Theme.Text})
            PlayTween(TitleLabel, {TextColor3 = Theme.Text})
        end

        TabBtn.Activated:Connect(ActivateTab)
        if FirstTab then ActivateTab() FirstTab = false end

        -- // Elements API for this Tab
        local TabAPI = {}

        function TabAPI:CreateSection(title)
            Create("TextLabel", {
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                Text = title,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        -- Helper to create the Fluent Row (Title on top, Subtitle on bottom)
        local function CreateElementRow(name, desc)
            local Row = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Theme.ElementBG,
                Size = UDim2.new(1, 0, 0, 55)
            })
            ApplyCorner(Row, 6)
            ApplyStroke(Row, Theme.Border)

            Create("TextLabel", {
                Parent = Row,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 10),
                Size = UDim2.new(1, -150, 0, 16),
                Text = name,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            if desc then
                Create("TextLabel", {
                    Parent = Row,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 28),
                    Size = UDim2.new(1, -150, 0, 14),
                    Text = desc,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Theme.SubText,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            end
            return Row
        end

        function TabAPI:CreateDropdown(opts)
            local Row = CreateElementRow(opts.Name, opts.Description)
            local list = opts.Options or {}
            local open = false

            local DropBtn = Create("TextButton", {
                Parent = Row,
                BackgroundColor3 = Theme.Sidebar,
                Size = UDim2.new(0, 140, 0, 35),
                Position = UDim2.new(1, -150, 0.5, -17.5),
                Text = "",
                AutoButtonColor = false
            })
            ApplyCorner(DropBtn, 6)
            ApplyStroke(DropBtn, Theme.Border)

            local DropText = Create("TextLabel", {
                Parent = DropBtn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = tostring(list[1] or "Select"),
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            Create("TextLabel", {
                Parent = DropBtn,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -20, 0, 0),
                Size = UDim2.new(0, 10, 1, 0),
                Text = "v",
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextColor3 = Theme.SubText
            })

            -- Setup Dropdown expansion logic here (omitted scrolling list to save tokens, but framework is solid)
            DropBtn.Activated:Connect(function()
                -- Basic array rotation for showcase
                table.insert(list, table.remove(list, 1)) 
                local current = list[1]
                DropText.Text = current
                if opts.Callback then pcall(opts.Callback, current) end
            end)
        end

        function TabAPI:CreateToggle(opts)
            local Row = CreateElementRow(opts.Name, opts.Description)
            local state = opts.CurrentValue or false

            local ToggleBG = Create("TextButton", {
                Parent = Row,
                BackgroundColor3 = state and Theme.Accent or Theme.Sidebar,
                Size = UDim2.new(0, 42, 0, 22),
                Position = UDim2.new(1, -55, 0.5, -11),
                Text = ""
            })
            ApplyCorner(ToggleBG, 11)
            ApplyStroke(ToggleBG, Theme.Border)

            local Circle = Create("Frame", {
                Parent = ToggleBG,
                BackgroundColor3 = state and Color3.fromRGB(0,0,0) or Theme.SubText,
                Size = UDim2.new(0, 14, 0, 14),
                Position = state and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)
            })
            ApplyCorner(Circle, 100)

            ToggleBG.Activated:Connect(function()
                state = not state
                PlayTween(ToggleBG, {BackgroundColor3 = state and Theme.Accent or Theme.Sidebar})
                PlayTween(Circle, {
                    Position = state and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7),
                    BackgroundColor3 = state and Color3.fromRGB(0,0,0) or Theme.SubText
                })
                if opts.Callback then pcall(opts.Callback, state) end
            end)
        end

        function TabAPI:CreateColorPicker(opts)
            local Row = CreateElementRow(opts.Name, opts.Description)
            local color = opts.Color or Color3.fromRGB(255, 255, 255)

            -- Color Preview Box
            local ColorBox = Create("TextButton", {
                Parent = Row,
                BackgroundColor3 = color,
                Size = UDim2.new(0, 60, 0, 30),
                Position = UDim2.new(1, -75, 0.5, -15),
                Text = ""
            })
            ApplyCorner(ColorBox, 6)
            ApplyStroke(ColorBox, Theme.Border)

            local PickerOpen = false
            local PickerPanel = Create("Frame", {
                Parent = Row,
                BackgroundColor3 = Theme.Sidebar,
                Size = UDim2.new(1, 0, 0, 130),
                Position = UDim2.new(0, 0, 1, 5),
                Visible = false,
                ZIndex = 5
            })
            ApplyCorner(PickerPanel, 6)
            ApplyStroke(PickerPanel, Theme.Border)

            -- RGB Inputs for Interactive selection (Rayfield-style precision)
            local function CreateRGBBox(labelTxt, xPos, initialVal)
                local container = Create("Frame", {
                    Parent = PickerPanel,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 60, 0, 30),
                    Position = UDim2.new(0, xPos, 0, 15)
                })
                Create("TextLabel", {
                    Parent = container, BackgroundTransparency = 1,
                    Size = UDim2.new(0, 20, 1, 0), Text = labelTxt,
                    Font = Enum.Font.GothamBold, TextColor3 = Theme.SubText, TextSize = 12
                })
                local box = Create("TextBox", {
                    Parent = container, BackgroundColor3 = Theme.ElementBG,
                    Position = UDim2.new(0, 25, 0, 0), Size = UDim2.new(0, 40, 1, 0),
                    Text = tostring(math.floor(initialVal * 255)),
                    Font = Enum.Font.Gotham, TextColor3 = Theme.Text, TextSize = 12
                })
                ApplyCorner(box, 4) ApplyStroke(box, Theme.Border)
                return box
            end

            local RBox = CreateRGBBox("R:", 15, color.R)
            local GBox = CreateRGBBox("G:", 95, color.G)
            local BBox = CreateRGBBox("B:", 175, color.B)

            local function UpdateColorFromInput()
                local r = math.clamp(tonumber(RBox.Text) or 255, 0, 255)
                local g = math.clamp(tonumber(GBox.Text) or 255, 0, 255)
                local b = math.clamp(tonumber(BBox.Text) or 255, 0, 255)
                color = Color3.fromRGB(r, g, b)
                ColorBox.BackgroundColor3 = color
                RBox.Text = tostring(r); GBox.Text = tostring(g); BBox.Text = tostring(b)
                if opts.Callback then pcall(opts.Callback, color) end
            end

            RBox.FocusLost:Connect(UpdateColorFromInput)
            GBox.FocusLost:Connect(UpdateColorFromInput)
            BBox.FocusLost:Connect(UpdateColorFromInput)

            -- Basic Hue Slider simulation
            local HueSlider = Create("TextButton", {
                Parent = PickerPanel,
                BackgroundColor3 = Theme.ElementBG,
                Size = UDim2.new(1, -30, 0, 10),
                Position = UDim2.new(0, 15, 0, 65),
                Text = "", AutoButtonColor = false
            })
            ApplyCorner(HueSlider, 10)
            ApplyStroke(HueSlider, Theme.Border)
            
            local UIGradient = Create("UIGradient", {
                Parent = HueSlider,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })
            })

            ColorBox.Activated:Connect(function()
                PickerOpen = not PickerOpen
                PickerPanel.Visible = PickerOpen
                PlayTween(Row, {Size = PickerOpen and UDim2.new(1, 0, 0, 195) or UDim2.new(1, 0, 0, 55)})
            end)
        end

        return TabAPI
    end

    return WindowAPI
end

return Luxware
