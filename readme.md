# LuxwareUI — Premium Roblox UI Library

> A sleek, mobile-ready Roblox UI library with a Rayfield-compatible API.  
> Supports PC, tablet, and phone. Dark AMOLED aesthetic, accent glow, smooth animations.

---

## 📦 Installation

### Method 1 — loadstring (recommended)
```lua
local LuxwareUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourrepo/LuxwareUI/main/library.lua"))()
```

### Method 2 — Local file
Place `library.lua` in your executor's workspace and use:
```lua
local LuxwareUI = loadfile("library.lua")()
-- or
local LuxwareUI = require("library")
```

---

## 🪟 Creating a Window

```lua
local Window = LuxwareUI:CreateWindow({
    Name          = "My Script",          -- Title shown in sidebar
    LoadingTitle  = "v1.0.0",            -- Subtitle under the title
    Icon          = "",                   -- Optional emoji/icon
    ConfigurationSaving = {
        Enabled   = true,
        FolderName = "MyScript",
        FileName   = "Config",
    },
    -- Optional: attach a key system
    KeySystem     = {
        Title    = "My Script Key",
        SubTitle = "Enter your key to continue",
        Key      = "mySecretKey123",
        GrabKey  = "https://linkvertise.com/yourlink",  -- copied to clipboard
    },
})
```

---

## 📁 Creating a Tab

```lua
local Tab = Window:CreateTab({
    Name = "Main",
    Icon = "🏠",   -- optional emoji
})
```

---

## 📂 Creating a Section

```lua
local Section = Tab:CreateSection("Combat")
```

---

## 🔘 Button

```lua
Section:CreateButton({
    Name        = "Click Me",
    Description = "Does something cool",   -- optional
    Icon        = "⚡",                    -- optional emoji
    Callback    = function()
        print("Button clicked!")
    end,
})
```

---

## ✅ Toggle

```lua
local Toggle = Section:CreateToggle({
    Name         = "God Mode",
    Description  = "Enables invincibility",
    Icon         = "🛡️",
    CurrentValue = false,
    Flag         = "GodMode",             -- accessible via LuxwareUI.Flags.GodMode
    Callback     = function(value)
        print("Toggle:", value)
    end,
})

-- Programmatically set:
Toggle:Set(true)
```

---

## 🎚️ Slider

```lua
local Slider = Section:CreateSlider({
    Name         = "Walk Speed",
    Range        = { 16, 500 },
    Increment    = 1,
    CurrentValue = 16,
    Flag         = "WalkSpeed",
    Callback     = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end,
})

-- Programmatically set:
Slider:Set(100)
```

---

## 📝 Input (TextBox)

```lua
local Input = Section:CreateInput({
    Name            = "Custom Name",
    PlaceholderText = "Enter your name...",
    CurrentValue    = "",
    EnterPressOnly  = true,              -- only fires callback on Enter
    ClearTextOnFocus = true,
    Flag            = "PlayerName",
    Callback        = function(text)
        print("Input:", text)
    end,
})

-- Programmatically set:
Input:Set("NewName")
```

---

## 📋 Dropdown

```lua
local Dropdown = Section:CreateDropdown({
    Name          = "Select Team",
    Options       = { "Red", "Blue", "Green", "Yellow" },
    CurrentOption = "Red",              -- default selected (string or table for multi)
    MultipleOptions = false,            -- set true for multi-select
    Flag          = "Team",
    Callback      = function(selected)
        print("Selected:", selected)    -- string if single, table if multi
    end,
})

-- Programmatically set:
Dropdown:Set("Blue")

-- Refresh options dynamically:
Dropdown:Refresh({ "Alpha", "Beta", "Gamma" })
```

### Multi-select example
```lua
local Multi = Section:CreateDropdown({
    Name            = "Active Modules",
    Options         = { "Aimbot", "ESP", "Speed", "Flight" },
    CurrentOption   = { "Speed" },
    MultipleOptions = true,
    Callback        = function(selected)
        -- selected is a table: { "Speed", "Flight" }
        for _, v in ipairs(selected) do print(v) end
    end,
})
```

---

## 🎨 Color Picker

```lua
local Picker = Section:CreateColorPicker({
    Name     = "ESP Color",
    Color    = Color3.fromRGB(255, 100, 100),  -- default color
    Flag     = "ESPColor",
    Callback = function(color)
        print(color)   -- Color3 value
    end,
})

-- Programmatically set:
Picker:Set(Color3.fromRGB(0, 200, 255))
```

Click the **color swatch** to open the picker.  
- Drag in the **SV canvas** to change saturation/brightness  
- Drag the **hue bar** to change hue  
- Type a **hex code** directly (e.g. `#FF6464`)

---

## ⌨️ Keybind

```lua
local KB = Section:CreateKeybind({
    Name           = "Toggle UI",
    CurrentKeybind = "RightShift",
    HoldToInteract = false,
    Flag           = "ToggleKey",
    Callback       = function(keyCode)
        print("Key pressed:", keyCode)
    end,
})

-- Programmatically set:
KB:Set("F")
```

Click the **pill button** then press any key to bind.

---

## 🏷️ Label

```lua
local Lbl = Section:CreateLabel({
    Text = "This is a read-only label.",
})

-- Update text:
Lbl:Set("Updated text!")
```

---

## ⚙️ Module Configuration (inline config panel)

A collapsible configuration panel that can contain any element — great for per-module settings.

```lua
local Config = Section:CreateModuleConfig({
    Name = "ESP Settings",
})

-- Add elements inside the config panel:
Config:CreateToggle({
    Name     = "Show Names",
    Callback = function(v) print("Names:", v) end,
})
Config:CreateColorPicker({
    Name     = "Name Color",
    Color    = Color3.fromRGB(255, 255, 255),
    Callback = function(c) print("Color:", c) end,
})
Config:CreateSlider({
    Name     = "Max Distance",
    Range    = { 10, 1000 },
    Increment = 10,
    Callback = function(v) print("Dist:", v) end,
})
```

---

## 🔔 Notifications

```lua
Window:Notify({
    Title    = "Script Loaded",
    Content  = "LuxwareUI initialized successfully.",
    Duration = 4,
    Type     = "success",  -- "info" | "success" | "error" | "warning"
})
```

---

## 💬 Dialog (Modal)

```lua
Window:Dialog({
    Title   = "Confirm Action",
    Content = "Are you sure you want to reset all settings?",
    Buttons = {
        {
            Title    = "Cancel",
            Callback = function()
                print("Cancelled")
            end,
        },
        {
            Title    = "Confirm",
            Callback = function()
                print("Confirmed — resetting settings")
            end,
        },
    },
})
```

---

## 🔑 Key System (standalone)

Use the key system independently without a full window:

```lua
LuxwareUI:KeySystem({
    Title    = "My Script",
    SubTitle = "Enter your key to access",
    Key      = "LUXWARE-2024-ABC",
    GrabKey  = "https://linkvertise.com/yourlink",
    Callback = function(passed)
        if passed then
            print("Access granted!")
        else
            print("Wrong key.")
        end
    end,
})
```

The key is saved locally so users only need to enter it once per executor session.

---

## 🎨 Custom Theme

Override any theme value before creating your window:

```lua
LuxwareUI:SetTheme({
    Accent      = Color3.fromRGB(255, 80, 120),   -- hot pink
    AccentLight = Color3.fromRGB(255, 120, 160),
    AccentDim   = Color3.fromRGB(160, 40, 80),
    Background  = Color3.fromRGB(8, 8, 12),
})
```

### Available theme keys
| Key | Description |
|-----|-------------|
| `Background` | Main window background |
| `Surface` | Panel/card backgrounds |
| `SurfaceLight` | Hover/input backgrounds |
| `Border` | Default border color |
| `Accent` | Primary accent (buttons, highlights) |
| `AccentLight` | Lighter accent for hover |
| `AccentDim` | Darker accent for pressed states |
| `Text` | Primary text |
| `TextDim` | Secondary text |
| `TextFaint` | Placeholder/hint text |
| `Success` | Green for success states |
| `Error` | Red for error states |
| `Warning` | Yellow for warning states |

---

## 🏴 Flags (Global State)

Any element with a `Flag` field updates `LuxwareUI.Flags` automatically:

```lua
-- After creating elements with Flag = "WalkSpeed" etc.
print(LuxwareUI.Flags.WalkSpeed)    -- current slider value
print(LuxwareUI.Flags.GodMode)      -- current toggle state
print(LuxwareUI.Flags.ESPColor)     -- current Color3
```

---

## 📱 Mobile Support

LuxwareUI **automatically detects** mobile (touch) devices and:
- Scales the window to a narrower layout
- Shrinks font sizes and padding for smaller screens
- All drag/slider/color-picker interactions support **touch input**
- Dropdowns and toggles work with tap

No extra configuration needed.

---

## 🗑️ Destroying the Window

```lua
Window:Destroy()
```

---

## 💡 Full Example Script

```lua
local LuxwareUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourrepo/LuxwareUI/main/library.lua"))()

local Window = LuxwareUI:CreateWindow({
    Name         = "Luxware Hub",
    LoadingTitle = "Premium Suite v1.0",
})

local MainTab = Window:CreateTab({ Name = "Main", Icon = "🏠" })
local VisTab  = Window:CreateTab({ Name = "Visuals", Icon = "👁" })
local MiscTab = Window:CreateTab({ Name = "Misc", Icon = "⚙️" })

-- Main
local CombatSection = MainTab:CreateSection("Combat")

CombatSection:CreateToggle({
    Name     = "Aimbot",
    Flag     = "Aimbot",
    Callback = function(v) print("Aimbot:", v) end,
})

CombatSection:CreateSlider({
    Name      = "FOV",
    Range     = { 10, 360 },
    Increment = 5,
    CurrentValue = 90,
    Flag      = "AimbotFOV",
    Callback  = function(v) print("FOV:", v) end,
})

local AimbotConfig = CombatSection:CreateModuleConfig({ Name = "Aimbot Config" })
AimbotConfig:CreateToggle({ Name = "Silent Aim",   Callback = function(v) end })
AimbotConfig:CreateDropdown({
    Name    = "Hit Part",
    Options = { "Head", "Torso", "LeftArm", "RightArm" },
    CurrentOption = "Head",
    Callback = function(v) print("Targeting:", v) end,
})

-- Visuals
local ESPSection = VisTab:CreateSection("ESP")

ESPSection:CreateToggle({
    Name     = "Player ESP",
    Flag     = "PlayerESP",
    Callback = function(v) print("ESP:", v) end,
})

ESPSection:CreateColorPicker({
    Name     = "ESP Color",
    Color    = Color3.fromRGB(255, 100, 100),
    Flag     = "ESPColor",
    Callback = function(c) print("Color:", c) end,
})

-- Misc
local MiscSection = MiscTab:CreateSection("Utilities")

MiscSection:CreateButton({
    Name     = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end,
})

MiscSection:CreateKeybind({
    Name           = "Toggle UI",
    CurrentKeybind = "RightShift",
    Flag           = "UIKey",
    Callback       = function(key)
        print("Toggling UI with", key)
    end,
})

Window:Notify({
    Title    = "Luxware Hub",
    Content  = "Loaded successfully. Enjoy!",
    Duration = 5,
    Type     = "success",
})
```

---

## 📄 License

LuxwareUI is provided for educational and personal use.  
Do not redistribute as your own work.

---

*LuxwareUI v1.0.0 — Built for quality, speed, and mobile-first experience.*
