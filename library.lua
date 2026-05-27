--[[
	CyphraUI - Custom Roblox UI Library
	Version 1.2.6
	Pure AMOLED Style (Inspired by 1f8c487b-135c-4f83-b581-f1850a138f50)
	Optimized for Mobile Layouts & Interaction Fixes
--]]

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- ─── Pure AMOLED Theme Configuration ─────────────────────────────────────────
local THEME = {
	Background = Color3.fromRGB(8, 8, 8),       -- Pure pitch dark background
	Surface    = Color3.fromRGB(14, 14, 14),    -- Dark navigation plates
	Card       = Color3.fromRGB(20, 20, 20),    -- Deep element container blocks
	Accent     = Color3.fromRGB(255, 255, 255), -- Clean crisp white features
	Text       = Color3.fromRGB(245, 245, 245), -- Dominant high contrast text
	SubText    = Color3.fromRGB(130, 130, 130), -- Soft gray details
	Stroke     = Color3.fromRGB(26, 26, 26),    -- Flat subtle dividers (No bright outline)
}

local FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function make(class, props, parent)
	local obj = Instance.new(class)
	for k, v in pairs(props) do obj[k] = v end
	if parent then obj.Parent = parent end
	return obj
end

local function addCorner(parent, radius)
	return make("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

local function addStroke(parent, color, thickness)
	return make("UIStroke", {
		Color        = color or THEME.Stroke,
		Thickness    = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, parent)
end

local function addPadding(parent, top, right, bottom, left)
	return make("UIPadding", {
		PaddingTop    = UDim.new(0, top or 6),
		PaddingRight  = UDim.new(0, right or 8),
		PaddingBottom = UDim.new(0, bottom or 6),
		PaddingLeft   = UDim.new(0, left or 8),
	}, parent)
end

-- ─── Dragging Handler Utility ────────────────────────────────────────────────
local function makeDraggable(clickFrame, targetFrame)
	local dragging, dragStart, startPos
	clickFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging  = true
			dragStart = input.Position
			startPos  = targetFrame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			targetFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- ─── Main Framework Initialization ───────────────────────────────────────────
local CyphraUI = {}
CyphraUI.__index = CyphraUI
CyphraUI._flags  = {}

function CyphraUI:CreateWindow(settings)
	local windowName = settings.Name or "CyphraUI"
	local loadTitle  = settings.LoadingTitle or "CyphraUI"
	local loadSub    = settings.LoadingSubtitle or "Loading..."

	local gui = make("ScreenGui", {
		Name           = "CyphraUI",
		ResetOnSpawn   = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not ok then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

	-- Clean Loading Splash Screen
	local loadFrame = make("Frame", {
		Size            = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = THEME.Background,
		BorderSizePixel = 0,
		ZIndex          = 100,
	}, gui)

	local loadTitle_ = make("TextLabel", {
		Size             = UDim2.new(0, 400, 0, 40),
		Position         = UDim2.new(0.5, -200, 0.5, -30),
		BackgroundTransparency = 1,
		Text             = loadTitle,
		TextColor3       = THEME.Text,
		Font             = Enum.Font.GothamBold,
		TextSize         = 22,
		ZIndex           = 101,
	}, loadFrame)

	local loadBarBg = make("Frame", {
		Size             = UDim2.new(0, 200, 0, 3),
		Position         = UDim2.new(0.5, -100, 0.5, 20),
		BackgroundColor3 = THEME.Card,
		BorderSizePixel  = 0,
		ZIndex           = 101,
	}, loadFrame)
	addCorner(loadBarBg, 2)

	local loadBar = make("Frame", {
		Size             = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = THEME.Accent,
		BorderSizePixel  = 0,
		ZIndex           = 102,
	}, loadBarBg)
	addCorner(loadBar, 2)

	task.spawn(function()
		TweenService:Create(loadBar, TweenInfo.new(0.5, Enum.EasingStyle.Quart), { Size = UDim2.new(1, 0, 1, 0) }):Play()
		task.wait(0.6)
		TweenService:Create(loadFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(loadTitle_, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { TextTransparency = 1 }):Play()
		TweenService:Create(loadBarBg, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(loadBar, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
		task.wait(0.2)
		loadFrame:Destroy()
	end)

	-- Main Menu Window Container Frame
	local window = make("Frame", {
		Name             = "Window",
		Size             = UDim2.new(0, 500, 0, 320),
		Position         = UDim2.new(0.5, -250, 0.5, -160),
		BackgroundColor3 = THEME.Background,
		BorderSizePixel  = 0,
	}, gui)
	addCorner(window, 9)
	addStroke(window, THEME.Stroke, 1)

	-- Title Bar Layout Module
	local titleBar = make("Frame", {
		Name             = "TitleBar",
		Size             = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel  = 0,
	}, window)
	local titleCorner = addCorner(titleBar, 9)
	
	local headerFlatten = make("Frame", {
		Size = UDim2.new(1, 0, 0, 10),
		Position = UDim2.new(0, 0, 1, -10),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel = 0,
	}, titleBar)

	local titleLabel = make("TextLabel", {
		Size             = UDim2.new(1, -140, 1, 0),
		Position         = UDim2.new(0, 16, 0, 0),
		BackgroundTransparency = 1,
		Text             = windowName,
		TextColor3       = THEME.Text,
		Font             = Enum.Font.GothamBold,
		TextSize         = 14,
		TextXAlignment   = Enum.TextXAlignment.Left,
	}, titleBar)

	-- Control Panel Actions Layout
	local controlLayout = make("Frame", {
		Size = UDim2.new(0, 70, 1, 0),
		Position = UDim2.new(1, -82, 0, 0),
		BackgroundTransparency = 1,
	}, titleBar)

	local function makeControlBtn(text, xPos, callback)
		local btn = make("TextButton", {
			Size             = UDim2.new(0, 26, 0, 26),
			Position         = UDim2.new(0, xPos, 0.5, -13),
			BackgroundColor3 = THEME.Card,
			Text             = text,
			TextColor3       = THEME.Text,
			Font             = Enum.Font.GothamBold,
			TextSize         = 14,
			BorderSizePixel  = 0,
		}, controlLayout)
		addCorner(btn, 6)
		addStroke(btn, THEME.Stroke, 1)
		
		btn.MouseButton1Click:Connect(callback)
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, FAST, { BackgroundColor3 = THEME.Accent, TextColor3 = THEME.Background }):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, FAST, { BackgroundColor3 = THEME.Card, TextColor3 = THEME.Text }):Play()
		end)
		return btn
	end

	-- Minimize Standalone Toggle Node (With Drag vs Click Detection Fix)
	local floatBtn = make("TextButton", {
		Name             = "CyphraFloatingHub",
		Size             = UDim2.new(0, 50, 0, 50),
		Position         = UDim2.new(0.1, 0, 0.2, 0),
		BackgroundColor3 = THEME.Surface,
		Text             = "UI",
		TextColor3       = THEME.Text,
		Font             = Enum.Font.GothamBold,
		TextSize         = 14,
		BorderSizePixel  = 0,
		Visible          = false,
		ZIndex           = 999,
	}, gui)
	addCorner(floatBtn, 25)
	addStroke(floatBtn, THEME.Accent, 1)

	-- Custom Click vs Drag system for the Floating Button
	local dragActive = false
	local dragStartPos = Vector3.new()
	local totalDragDistance = 0

	floatBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragActive = true
			dragStartPos = input.Position
			totalDragDistance = 0
			local startPos = floatBtn.Position
			
			local changedConnection
			changedConnection = UserInputService.InputChanged:Connect(function(moveInput)
				if not dragActive then changedConnection:Disconnect() return end
				if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
					local delta = moveInput.Position - dragStartPos
					totalDragDistance = delta.Magnitude
					floatBtn.Position = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + delta.X,
						startPos.Y.Scale, startPos.Y.Offset + delta.Y
					)
				end
			end)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if dragActive then
				dragActive = false
				-- Only open the UI if the button wasn't dragged more than 5 pixels
				if totalDragDistance < 5 then
					floatBtn.Visible = false
					window.Visible = true
				end
			end
		end
	end)

	local closeBtn = makeControlBtn("×", 36, function() gui:Destroy() end)
	local minBtn   = makeControlBtn("−", 2, function()
		window.Visible = false
		floatBtn.Visible = true
	end)

	makeDraggable(titleBar, window)

	-- Window Structure Layout Panels
	local sidebar = make("Frame", {
		Size             = UDim2.new(0, 125, 1, -42),
		Position         = UDim2.new(0, 0, 0, 42),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel  = 0,
	}, window)
	
	local sidebarBottomFlatten = make("Frame", {
		Size = UDim2.new(1, 0, 0, 9),
		Position = UDim2.new(0, 0, 1, -9),
		BackgroundColor3 = THEME.Surface,
		BorderSizePixel = 0,
	}, sidebar)

	local content = make("Frame", {
		Size             = UDim2.new(1, -125, 1, -42),
		Position         = UDim2.new(0, 125, 0, 42),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}, window)

	local borderLine = make("Frame", {
		Size             = UDim2.new(0, 1, 1, -42),
		Position         = UDim2.new(0, 125, 0, 42),
		BackgroundColor3 = THEME.Stroke,
		BorderSizePixel  = 0,
	}, window)

	make("UIListLayout", {
		SortOrder       = Enum.SortOrder.LayoutOrder,
		Padding         = UDim.new(0, 4),
		FillDirection   = Enum.FillDirection.Vertical,
	}, sidebar)
	addPadding(sidebar, 8, 8, 8, 8)

	local windowObj = { _gui = gui, _tabs = {} }

	local notifContainer = make("Frame", {
		Size             = UDim2.new(0, 240, 1, 0),
		Position         = UDim2.new(1, -250, 0, 0),
		BackgroundTransparency = 1,
	}, gui)
	make("UIListLayout", {
		SortOrder       = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding         = UDim.new(0, 6),
	}, notifContainer)
	addPadding(notifContainer, 12, 12, 12, 12)

	-- ── Tab Creation Logic ──
	function windowObj:CreateTab(name)
		local isFirst = #self._tabs == 0

		local tabBtn = make("TextButton", {
			Size             = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = isFirst and THEME.Card or Color3.fromRGB(0,0,0),
			BackgroundTransparency = isFirst and 0 or 1,
			Text             = name,
			TextColor3       = isFirst and THEME.Text or THEME.SubText,
			Font             = Enum.Font.GothamSemibold,
			TextSize         = 12,
			BorderSizePixel  = 0,
			LayoutOrder      = #self._tabs + 1,
		}, sidebar)
		addCorner(tabBtn, 5)

		local page = make("ScrollingFrame", {
			Size             = UDim2.new(1, 0, 1, 0), -- Fills full content box space perfectly
			BackgroundTransparency = 1,
			BorderSizePixel  = 0,
			ScrollBarThickness = 0,
			Visible          = isFirst,
			CanvasSize       = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, content)

		make("UIListLayout", {
			SortOrder     = Enum.SortOrder.LayoutOrder,
			Padding       = UDim.new(0, 6),
			FillDirection = Enum.FillDirection.Vertical,
		}, page)
		addPadding(page, 12, 12, 12, 12)

		local tabObj = { _page = page, _btn = tabBtn, _window = self, _order = 0 }
		table.insert(self._tabs, tabObj)

		tabBtn.MouseButton1Click:Connect(function()
			for _, t in ipairs(self._window._tabs) do
				local active = (t == tabObj)
				t._page.Visible = active
				TweenService:Create(t._btn, FAST, {
					BackgroundColor3       = active and THEME.Card or Color3.fromRGB(0,0,0),
					BackgroundTransparency = active and 0 or 1,
					TextColor3             = active and THEME.Text or THEME.SubText,
				}):Play()
			end
		end)

		local function newCard(height)
			tabObj._order += 1
			local card = make("Frame", {
				Size             = UDim2.new(1, 0, 0, height),
				BackgroundColor3 = THEME.Surface,
				BorderSizePixel  = 0,
				LayoutOrder      = tabObj._order,
			}, page)
			addCorner(card, 6)
			addStroke(card, THEME.Stroke, 1)
			return card
		end

		function tabObj:CreateSection(name)
			tabObj._order += 1
			local sect = make("Frame", {
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundTransparency = 1,
				LayoutOrder = tabObj._order,
			}, page)
			make("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = name:upper(),
				TextColor3 = THEME.SubText,
				Font = Enum.Font.GothamBold,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, sect)
		end

		function tabObj:CreateToggle(settings)
			local name = settings.Name or "Toggle"
			local current = settings.CurrentValue or false
			local flag = settings.Flag
			local cb = settings.Callback or function() end

			if flag and CyphraUI._flags[flag] ~= nil then current = CyphraUI._flags[flag] end
			local card = newCard(38)

			make("TextLabel", {
				Size             = UDim2.new(1, -60, 1, 0),
				Position         = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text             = name,
				TextColor3       = THEME.Text,
				Font = Enum.Font.Gotham,
				TextSize         = 13,
				TextXAlignment   = Enum.TextXAlignment.Left,
			}, card)

			local pill = make("Frame", {
				Size             = UDim2.new(0, 32, 0, 16),
				Position         = UDim2.new(1, -44, 0.5, -8),
				BackgroundColor3 = current and THEME.Accent or THEME.Card,
				BorderSizePixel  = 0,
			}, card)
			addCorner(pill, 8)

			local knob = make("Frame", {
				Size             = UDim2.new(0, 12, 0, 12),
				Position         = current and UDim2.new(0, 18, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
				BackgroundColor3 = current and THEME.Background or THEME.SubText,
				BorderSizePixel  = 0,
			}, pill)
			addCorner(knob, 6)

			local tObj = { CurrentValue = current }
			if flag then CyphraUI._flags[flag] = current end

			local btn = make("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }, card)
			btn.MouseButton1Click:Connect(function()
				tObj.CurrentValue = not tObj.CurrentValue
				if flag then CyphraUI._flags[flag] = tObj.CurrentValue end
				local active = tObj.CurrentValue
				TweenService:Create(pill, FAST, { BackgroundColor3 = active and THEME.Accent or THEME.Card }):Play()
				TweenService:Create(knob, FAST, { 
					Position = active and UDim2.new(0, 18, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
					BackgroundColor3 = active and THEME.Background or THEME.SubText
				}):Play()
				pcall(cb, active)
			end)
			return tObj
		end

		function tabObj:CreateSlider(settings)
			local name = settings.Name or "Slider"
			local range = settings.Range or {0, 100}
			local min_v, max_v = range[1], range[2]
			local inc = settings.Increment or 1
			local current = math.clamp(settings.CurrentValue or min_v, min_v, max_v)
			local flag = settings.Flag
			local cb = settings.Callback or function() end

			if flag and CyphraUI._flags[flag] ~= nil then current = CyphraUI._flags[flag] end
			local card = newCard(46)

			make("TextLabel", {
				Size             = UDim2.new(1, -80, 0, 20),
				Position         = UDim2.new(0, 12, 0, 4),
				BackgroundTransparency = 1,
				Text             = name,
				TextColor3       = THEME.Text,
				Font = Enum.Font.Gotham,
				TextSize         = 13,
				TextXAlignment   = Enum.TextXAlignment.Left,
			}, card)

			local valLabel = make("TextLabel", {
				Size             = UDim2.new(0, 60, 0, 20),
				Position         = UDim2.new(1, -72, 0, 4),
				BackgroundTransparency = 1,
				Text             = tostring(current),
				TextColor3       = THEME.SubText,
				Font             = Enum.Font.Code,
				TextSize         = 12,
				TextXAlignment   = Enum.TextXAlignment.Right,
			}, card)

			local track = make("Frame", {
				Size             = UDim2.new(1, -24, 0, 4),
				Position         = UDim2.new(0, 12, 0, 30),
				BackgroundColor3 = THEME.Card,
				BorderSizePixel  = 0,
			}, card)
			addCorner(track, 2)

			local fill = make("Frame", {
				Size             = UDim2.new((current - min_v) / (max_v - min_v), 0, 1, 0),
				BackgroundColor3 = THEME.Accent,
				BorderSizePixel  = 0,
			}, track)
			addCorner(fill, 2)

			local sObj = { CurrentValue = current }
			if flag then CyphraUI._flags[flag] = current end

			local moveActive = false
			local function parseInput(input)
				local xPos  = track.AbsolutePosition.X
				local scale = math.clamp((input.Position.X - xPos) / track.AbsoluteSize.X, 0, 1)
				local val   = min_v + scale * (max_v - min_v)
				if inc > 0 then val = math.round((val - min_v) / inc) * inc + min_v end
				val = math.clamp(val, min_v, max_v)
				
				sObj.CurrentValue = val
				if flag then CyphraUI._flags[flag] = val end
				valLabel.Text = tostring(val)
				fill.Size = UDim2.new((val - min_v) / (max_v - min_v), 0, 1, 0)
				pcall(cb, val)
			end

			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					moveActive = true parseInput(input)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if moveActive and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					parseInput(input)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					moveActive = false
				end
			end)
			return sObj
		end

		function tabObj:CreateButton(settings)
			local name = settings.Name or "Button"
			local cb = settings.Callback or function() end

			tabObj._order += 1
			local btn = make("TextButton", {
				Size             = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = THEME.Card,
				Text             = name,
				TextColor3       = THEME.Text,
				Font             = Enum.Font.GothamSemibold,
				TextSize         = 13,
				BorderSizePixel  = 0,
				LayoutOrder      = tabObj._order,
			}, page)
			addCorner(btn, 6)
			addStroke(btn, THEME.Stroke, 1)

			btn.MouseEnter:Connect(function() TweenService:Create(btn, FAST, { BackgroundColor3 = THEME.Stroke }):Play() end)
			btn.MouseLeave:Connect(function() TweenService:Create(btn, FAST, { BackgroundColor3 = THEME.Card }):Play() end)
			btn.MouseButton1Click:Connect(function() pcall(cb) end)
		end

		function tabObj:CreateDropdown(settings)
			local name = settings.Name or "Dropdown"
			local options = settings.Options or {}
			local current = settings.CurrentOption or ""
			local flag = settings.Flag
			local cb = settings.Callback or function() end

			if flag and CyphraUI._flags[flag] ~= nil then current = CyphraUI._flags[flag] end
			tabObj._order += 1

			local wrap = make("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundTransparency = 1,
				LayoutOrder = tabObj._order,
			}, page)

			local head = make("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = THEME.Surface, BorderSizePixel = 0 }, wrap)
			addCorner(head, 6)
			addStroke(head, THEME.Stroke, 1)

			make("TextLabel", {
				Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1, Text = name, TextColor3 = THEME.Text,
				Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
			}, head)

			local sLabel = make("TextLabel", {
				Size = UDim2.new(0.5, -12, 1, 0), Position = UDim2.new(0.5, 0, 0, 0),
				BackgroundTransparency = 1, Text = (current == "" and "Select" or current) .. "  ▼",
				TextColor3 = THEME.SubText, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
			}, head)

			local list = make("ScrollingFrame", {
				Size = UDim2.new(1, 0, 0, math.clamp(#options * 26, 26, 130)), Position = UDim2.new(0, 0, 0, 40),
				BackgroundColor3 = THEME.Card, BorderSizePixel = 0, Visible = false, ZIndex = 10,
				ScrollBarThickness = 2, ScrollBarImageColor3 = THEME.Stroke, CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y
			}, wrap)
			addCorner(list, 6)
			addStroke(list, THEME.Stroke, 1)
			make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, list)

			local dObj = { CurrentOption = current }
			local expanded = false

			for i, opt in ipairs(options) do
				local oBtn = make("TextButton", {
					Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1,
					Text = opt, TextColor3 = THEME.Text, Font = Enum.Font.Gotham, TextSize = 12,
					LayoutOrder = i, ZIndex = 11,
				}, list)
				
				oBtn.MouseEnter:Connect(function() oBtn.BackgroundTransparency = 0.95 oBtn.BackgroundColor3 = THEME.Surface end)
				oBtn.MouseLeave:Connect(function() oBtn.BackgroundTransparency = 1 end)
				
				oBtn.MouseButton1Click:Connect(function()
					dObj.CurrentOption = opt
					if flag then CyphraUI._flags[flag] = opt end
					sLabel.Text = opt .. "  ▼"
					expanded = false list.Visible = false
					wrap.Size = UDim2.new(1, 0, 0, 36)
					pcall(cb, opt)
				end)
			end

			local click = make("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }, head)
			click.MouseButton1Click:Connect(function()
				expanded = not expanded
				list.Visible = expanded
				wrap.Size = expanded and UDim2.new(1, 0, 0, 42 + math.clamp(#options * 26, 26, 130)) or UDim2.new(1, 0, 0, 36)
				sLabel.Text = (dObj.CurrentOption == "" and "Select" or dObj.CurrentOption) .. (expanded and "  ▲" or "  ▼")
			end)
			return dObj
		end

		return tabObj
	end

	function windowObj:Notify(settings)
		local title = settings.Title or "Notification"
		local text  = settings.Content or ""
		
		local notif = make("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = THEME.Surface, BorderSizePixel = 0 }, notifContainer)
		addCorner(notif, 6)
		addStroke(notif, THEME.Stroke, 1)

		make("TextLabel", {
			Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0, 10, 0, 4),
			BackgroundTransparency = 1, Text = title, TextColor3 = THEME.Text,
			Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
		}, notif)

		make("TextLabel", {
			Size = UDim2.new(1, -16, 0, 16), Position = UDim2.new(0, 10, 0, 22),
			BackgroundTransparency = 1, Text = text, TextColor3 = THEME.SubText,
			Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
		}, notif)

		task.delay(settings.Duration or 3, function()
			TweenService:Create(notif, FAST, { BackgroundTransparency = 1 }):Play()
			task.wait(0.15) notif:Destroy()
		end)
	end

	return windowObj
end

return CyphraUI
