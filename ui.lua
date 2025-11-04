
local XenithLibrary = {
	Options = {},
	Folder = "XenithHubSettings",
	TabSettings = {},
	Unloaded = false,
	WindowState = nil,
	InitializedGlobalSettings = false,
	Tabs = {},
	Notifications = {}
}

local CentralTheme = {

	Background = Color3.fromRGB(18, 18, 20),
	Surface = Color3.fromRGB(25, 25, 28),
	SurfaceHover = Color3.fromRGB(30, 30, 34),
	Border = Color3.fromRGB(45, 45, 50),

	Primary = Color3.fromRGB(88, 166, 255),
	PrimaryHover = Color3.fromRGB(108, 186, 255),
	PrimaryActive = Color3.fromRGB(68, 146, 235),

	Success = Color3.fromRGB(82, 196, 26),
	Warning = Color3.fromRGB(250, 173, 20),
	Danger = Color3.fromRGB(245, 54, 92),
	Info = Color3.fromRGB(24, 144, 255),

	TextPrimary = Color3.fromRGB(240, 240, 242),
	TextSecondary = Color3.fromRGB(160, 160, 165),
	TextTertiary = Color3.fromRGB(100, 100, 105),
	TextDisabled = Color3.fromRGB(80, 80, 85),

	CornerRadius = 4,
	SmallRadius = 2,
	BorderThickness = 1,
	Padding = 12,
	SmallPadding = 8,
	LargePadding = 16
}

local UILibraryUtility = {}

function UILibraryUtility:CreateInstance(ClassName, Properties)
	local Instance = Instance.new(ClassName)
	if Properties then
		for Property, Value in pairs(Properties) do
			if Property ~= "Parent" then
				Instance[Property] = Value
			end
		end
		if Properties.Parent then
			Instance.Parent = Properties.Parent
		end
	end
	return Instance
end

function UILibraryUtility:CreateFrame(Properties)
	return self:CreateInstance("Frame", Properties)
end

function UILibraryUtility:CreateTextLabel(Properties)
	return self:CreateInstance("TextLabel", Properties)
end

function UILibraryUtility:CreateTextButton(Properties)
	return self:CreateInstance("TextButton", Properties)
end

function UILibraryUtility:CreateImageLabel(Properties)
	return self:CreateInstance("ImageLabel", Properties)
end

function UILibraryUtility:CreateImageButton(Properties)
	return self:CreateInstance("ImageButton", Properties)
end

function UILibraryUtility:CreateScrollingFrame(Properties)
	return self:CreateInstance("ScrollingFrame", Properties)
end

function UILibraryUtility:CreateUICorner(CornerRadius, Parent)
	return self:CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, CornerRadius or CentralTheme.CornerRadius),
		Parent = Parent
	})
end

function UILibraryUtility:CreateUIStroke(Properties, Parent)
	Properties = Properties or {}
	Properties.Parent = Parent
	return self:CreateInstance("UIStroke", Properties)
end

function UILibraryUtility:CreateUIPadding(PaddingLeft, PaddingRight, PaddingTop, PaddingBottom, Parent)
	return self:CreateInstance("UIPadding", {
		PaddingLeft = UDim.new(0, PaddingLeft),
		PaddingRight = UDim.new(0, PaddingRight),
		PaddingTop = UDim.new(0, PaddingTop),
		PaddingBottom = UDim.new(0, PaddingBottom),
		Parent = Parent
	})
end

function UILibraryUtility:CreateUIListLayout(Properties, Parent)
	Properties = Properties or {}
	Properties.SortOrder = Properties.SortOrder or Enum.SortOrder.LayoutOrder
	Properties.Parent = Parent
	return self:CreateInstance("UIListLayout", Properties)
end

function UILibraryUtility:CreateUIGradient(Properties, Parent)
	Properties = Properties or {}
	Properties.Parent = Parent
	return self:CreateInstance("UIGradient", Properties)
end

function UILibraryUtility:ApplyProperties(Instance, Properties)
	for Property, Value in pairs(Properties) do
		Instance[Property] = Value
	end
end

function XenithLibrary:SetupSettings(Settings)
	if XenithLibrary.TabSettings then
		XenithLibrary.TabSettings = nil
	end

	XenithLibrary.TabSettings = {}
	XenithLibrary.TabSettings.InitializeTab = nil
	XenithLibrary.TabSettings.CurrentTab = nil

	if Maid.MenuKeybind ~= nil then
		Maid.MenuKeybind:Disconnect()
	end

	Maid.MenuKeybind = nil
	Maid.TabIndex = 0

	Maid.RegisteredKeybinds = {}
	Maid.HiddenKeybinds = {}

	XenithLibrary.Unloaded = false
	XenithLibrary.InitializedGlobalSettings = false
	XenithLibrary.WindowState = nil
	XenithLibrary.Tabs = {}
	XenithLibrary.Options = {}

	return XenithLibrary
end

function XenithLibrary:Window(Settings)
	local WindowFunctions = {Settings = Settings}
	self:SetupSettings(Settings)

	local ComponentManager = Utility:LoadFile("Xenith/UserInterface/Managers/ComponentManager.lua")
	local TerminalModule = Utility:LoadFile("Xenith/UserInterface/Imports/Terminal/TerminalModule.lua")
	local ThemeColorSchemes = Utility:LoadFile("Xenith/UserInterface/Imports/Themes/ThemeColorSchemes.lua")
	local ThemeTemplates = Utility:LoadFile("Xenith/UserInterface/Imports/Themes/ThemeTemplates.lua")
	local PerformanceModes = Utility:LoadFile("Xenith/UserInterface/Imports/Themes/PerformanceModes.lua")
	local ThemeUtility = Utility:LoadFile("Xenith/UserInterface/Imports/Themes/ThemeUtility.lua")
	local Themes = ThemeUtility:RetrieveThemes(XenithLibrary)

	local ClassParser = {
		["Toggle"] = {
			Save = function(Flag, Data)
				return {
					ClassType = "Toggle",
					Flag = Flag,
					State = Data.State or false,
					Keybind = ComponentManager:CheckFlagKeybind(Flag)
				}
			end,
			Load = function(Flag, Data)
				if XenithLibrary.Options[Flag] then
					if Data.State then
						XenithLibrary.Options[Flag]:UpdateState(Data.State)
					end
					if Data.Keybind then
						ComponentManager.AddFlagKeybind(Flag, Data.Keybind)
					end
				end
			end
		},
		["Button"] = {
			Save = function(Flag, Data)
				return {
					ClassType = "Button",
					Flag = Flag,
					Keybind = ComponentManager:CheckFlagKeybind(Flag)
				}
			end,
			Load = function(Flag, Data)
				if XenithLibrary.Options[Flag] then
					if Data.Keybind then
						ComponentManager.AddFlagKeybind(Flag, Data.Keybind)
					end
				end
			end
		},
		["CheckBox"] = {
			Save = function(Flag, Data)
				return {
					ClassType = "CheckBox",
					Flag = Flag,
					State = Data.State or false
				}
			end,
			Load = function(Flag, Data)
				if XenithLibrary.Options[Flag] and Data.State  then
					XenithLibrary.Options[Flag]:UpdateState(Data.State)
				end
			end
		},
		["Slider"] = {
			Save = function(Flag, Data)
				return {
					ClassType = "Slider",
					Flag = Flag,
					Value = (Data.Value and tostring(Data.Value)) or false
				}
			end,
			Load = function(Flag, Data)
				if XenithLibrary.Options[Flag] and Data.Value then
					XenithLibrary.Options[Flag]:UpdateValue(Data.Value)
				end
			end
		},
		["RangeSlider"] = {
			Save = function(Flag, Data)
				return {
					ClassType = "RangeSlider",
					Flag = Flag,
					Minimum = Data.MinValue,
					Maximum = Data.MaxValue
				}
			end,
			Load = function(Flag, Data)
				if XenithLibrary.Options[Flag] and Data.Minimum and Data.Maximum then
					XenithLibrary.Options[Flag]:UpdateRange(Data.Minimum, Data.Maximum)
				end
			end
		},
		["Input"] = {
			Save = function(Flag, Data)
				return {
					ClassType = "Input",
					Flag = Flag,
					Input = Data.Text
				}
			end,
			Load = function(Flag, Data)
				if XenithLibrary.Options[Flag] and Data.Input and type(Data.Input) == "string" then
					XenithLibrary.Options[Flag]:UpdateText(Data.Input)
				end
			end
		},
		["Keybind"] = {
			Save = function(Flag, Data)
				return {
					ClassType = "Keybind",
					Flag = Flag,
					Bind = Data:GetBind().Name
				}
			end,
			Load = function(Flag, Data)
				if XenithLibrary.Options[Flag] and Data.Bind then
					XenithLibrary.Options[Flag]:Bind(Enum.KeyCode[Data.Bind])
				end
			end
		},
		["Dropdown"] = {
			Save = function(Flag, Data)
				return {
					ClassType = "Dropdown",
					Flag = Flag,
					Selections = Data.Value
				}
			end,
			Load = function(Flag, Data)
				if XenithLibrary.Options[Flag] and Data.Selections then
					XenithLibrary.Options[Flag]:UpdateSelection(Data.Selections)
				end
			end
		},
		["ColorPicker"] = {
			Save = function(Flag, Data)
				return {
					ClassType = "ColorPicker",
					Flag = Flag,
					Color = Utility:Color3ToHex(Data.Color) or nil,
					Alpha = Data.Alpha
				}
			end,
			Load = function(Flag, Data)
				if XenithLibrary.Options[Flag] and Data.Color then
					XenithLibrary.Options[Flag]:SetColor(Utility:HexToColor3(Data.Color))
					if Data.Alpha then
						XenithLibrary.Options[Flag]:SetAlpha(Data.Alpha)
					end
				end
			end
		}
	}

	local XenithLibraryUI = UILibraryUtility:CreateInstance("ScreenGui", {
		Name = "XenithLibraryCentral",
		ResetOnSpawn = false,
		DisplayOrder = 100,
		IgnoreGuiInset = true,
		ScreenInsets = Enum.ScreenInsets.None,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = gethui()
	})

	local ToastContainer = UILibraryUtility:CreateFrame({
		Name = "ToastContainer",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -320, 1, -20),
		Size = UDim2.new(0, 300, 0, 500),
		Parent = XenithLibraryUI
	})

	local ToastLayout = UILibraryUtility:CreateUIListLayout({
		Padding = UDim.new(0, 8),
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder
	}, ToastContainer)

	local Base = UILibraryUtility:CreateFrame({
		Name = "CentralBase",
		Size = UDim2.new(0, Settings.Width or 720, 0, Settings.Height or 480),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CentralTheme.Background,
		BorderSizePixel = CentralTheme.BorderThickness,
		BorderColor3 = CentralTheme.Border,
		Parent = XenithLibraryUI
	})

	local BaseCorner = UILibraryUtility:CreateUICorner(CentralTheme.CornerRadius, Base)

	local TopBar = UILibraryUtility:CreateFrame({
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = CentralTheme.Surface,
		BorderSizePixel = 0,
		Parent = Base
	})

	local TopBarBorder = UILibraryUtility:CreateFrame({
		Name = "Border",
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = CentralTheme.Border,
		BorderSizePixel = 0,
		Parent = TopBar
	})

	local TitleContainer = UILibraryUtility:CreateFrame({
		Name = "TitleContainer",
		Size = UDim2.new(0, 220, 1, 0),
		BackgroundTransparency = 1,
		Parent = TopBar
	})

	UILibraryUtility:CreateUIPadding(CentralTheme.Padding, CentralTheme.Padding, 0, 0, TitleContainer)

	local Title = UILibraryUtility:CreateTextLabel({
		Name = "Title",
		Text = Settings.Title or "Xenith UI",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = CentralTheme.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = TitleContainer
	})

	local TabBar = UILibraryUtility:CreateFrame({
		Name = "TabBar",
		Position = UDim2.new(0, 220, 0, 0),
		Size = UDim2.new(1, -440, 1, 0),
		BackgroundTransparency = 1,
		Parent = TopBar
	})

	local TabBarScroll = UILibraryUtility:CreateScrollingFrame({
		Name = "TabBarScroll",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		Parent = TabBar
	})

	local TabBarLayout = UILibraryUtility:CreateUIListLayout({
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		VerticalAlignment = Enum.VerticalAlignment.Center
	}, TabBarScroll)

	UILibraryUtility:CreateUIPadding(CentralTheme.SmallPadding, CentralTheme.SmallPadding, 0, 0, TabBarScroll)

	local QuickActions = UILibraryUtility:CreateFrame({
		Name = "QuickActions",
		Position = UDim2.new(1, -220, 0, 0),
		Size = UDim2.new(0, 220, 1, 0),
		BackgroundTransparency = 1,
		Parent = TopBar
	})

	local QuickActionsLayout = UILibraryUtility:CreateUIListLayout({
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center
	}, QuickActions)

	UILibraryUtility:CreateUIPadding(CentralTheme.Padding, CentralTheme.Padding, 0, 0, QuickActions)

	local SettingsButton = UILibraryUtility:CreateTextButton({
		Name = "SettingsButton",
		Text = "⚙",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = CentralTheme.TextSecondary,
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = CentralTheme.Surface,
		Parent = QuickActions
	})

	UILibraryUtility:CreateUICorner(CentralTheme.CornerRadius, SettingsButton)

	SettingsButton.MouseEnter:Connect(function()
		Services.TweenService:Create(SettingsButton, TweenInfo.new(0.15), {
			BackgroundColor3 = CentralTheme.SurfaceHover,
			TextColor3 = CentralTheme.TextPrimary
		}):Play()
	end)

	SettingsButton.MouseLeave:Connect(function()
		Services.TweenService:Create(SettingsButton, TweenInfo.new(0.15), {
			BackgroundColor3 = CentralTheme.Surface,
			TextColor3 = CentralTheme.TextSecondary
		}):Play()
	end)

	local MinimizeButton = UILibraryUtility:CreateTextButton({
		Name = "MinimizeButton",
		Text = "−",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = CentralTheme.TextSecondary,
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = CentralTheme.Surface,
		Parent = QuickActions
	})

	UILibraryUtility:CreateUICorner(CentralTheme.CornerRadius, MinimizeButton)

	MinimizeButton.MouseEnter:Connect(function()
		Services.TweenService:Create(MinimizeButton, TweenInfo.new(0.15), {
			BackgroundColor3 = CentralTheme.SurfaceHover,
			TextColor3 = CentralTheme.TextPrimary
		}):Play()
	end)

	MinimizeButton.MouseLeave:Connect(function()
		Services.TweenService:Create(MinimizeButton, TweenInfo.new(0.15), {
			BackgroundColor3 = CentralTheme.Surface,
			TextColor3 = CentralTheme.TextSecondary
		}):Play()
	end)

	local CloseButton = UILibraryUtility:CreateTextButton({
		Name = "CloseButton",
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		TextColor3 = CentralTheme.TextSecondary,
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = CentralTheme.Surface,
		Parent = QuickActions
	})

	UILibraryUtility:CreateUICorner(CentralTheme.CornerRadius, CloseButton)

	CloseButton.MouseEnter:Connect(function()
		Services.TweenService:Create(CloseButton, TweenInfo.new(0.15), {
			BackgroundColor3 = CentralTheme.Danger,
			TextColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
	end)

	CloseButton.MouseLeave:Connect(function()
		Services.TweenService:Create(CloseButton, TweenInfo.new(0.15), {
			BackgroundColor3 = CentralTheme.Surface,
			TextColor3 = CentralTheme.TextSecondary
		}):Play()
	end)

	local Content = UILibraryUtility:CreateFrame({
		Name = "Content",
		Position = UDim2.new(0, 0, 0, 48),
		Size = UDim2.new(1, 0, 1, -48),
		BackgroundColor3 = CentralTheme.Background,
		BorderSizePixel = 0,
		Parent = Base
	})

	local BreadcrumbBar = UILibraryUtility:CreateFrame({
		Name = "BreadcrumbBar",
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = CentralTheme.Surface,
		BorderSizePixel = 0,
		Parent = Content
	})

	local BreadcrumbBorder = UILibraryUtility:CreateFrame({
		Name = "Border",
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = CentralTheme.Border,
		BorderSizePixel = 0,
		Parent = BreadcrumbBar
	})

	local BreadcrumbLayout = UILibraryUtility:CreateUIListLayout({
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		VerticalAlignment = Enum.VerticalAlignment.Center
	}, BreadcrumbBar)

	UILibraryUtility:CreateUIPadding(CentralTheme.Padding, CentralTheme.Padding, 0, 0, BreadcrumbBar)

	local CurrentBreadcrumb = UILibraryUtility:CreateTextLabel({
		Name = "CurrentBreadcrumb",
		Text = "Home",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = CentralTheme.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = BreadcrumbBar
	})

	local CardContainer = UILibraryUtility:CreateScrollingFrame({
		Name = "CardContainer",
		Position = UDim2.new(0, 0, 0, 36),
		Size = UDim2.new(1, 0, 1, -36),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = CentralTheme.Border,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = Content
	})

	local CardLayout = UILibraryUtility:CreateUIListLayout({
		Padding = UDim.new(0, CentralTheme.Padding),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, CardContainer)

	UILibraryUtility:CreateUIPadding(
		CentralTheme.LargePadding,
		CentralTheme.LargePadding,
		CentralTheme.LargePadding,
		CentralTheme.LargePadding,
		CardContainer
	)

	WindowFunctions.Base = Base
	WindowFunctions.TopBar = TopBar
	WindowFunctions.TabBar = TabBarScroll
	WindowFunctions.TabBarLayout = TabBarLayout
	WindowFunctions.Content = Content
	WindowFunctions.CardContainer = CardContainer
	WindowFunctions.BreadcrumbBar = BreadcrumbBar
	WindowFunctions.CurrentBreadcrumb = CurrentBreadcrumb
	WindowFunctions.ToastContainer = ToastContainer
	WindowFunctions.XenithLibraryUI = XenithLibraryUI

	function WindowFunctions:Toast(Message, Type, Duration)
		Type = Type or "Info"
		Duration = Duration or 3

		local TypeColors = {
			Info = CentralTheme.Info,
			Success = CentralTheme.Success,
			Warning = CentralTheme.Warning,
			Error = CentralTheme.Danger
		}

		local Toast = UILibraryUtility:CreateFrame({
			Name = "Toast",
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundColor3 = CentralTheme.Surface,
			BorderSizePixel = 0,
			Parent = ToastContainer
		})

		UILibraryUtility:CreateUICorner(CentralTheme.CornerRadius, Toast)

		local AccentBar = UILibraryUtility:CreateFrame({
			Name = "AccentBar",
			Size = UDim2.new(0, 3, 1, 0),
			BackgroundColor3 = TypeColors[Type] or CentralTheme.Info,
			BorderSizePixel = 0,
			Parent = Toast
		})

		local ToastText = UILibraryUtility:CreateTextLabel({
			Name = "ToastText",
			Text = Message,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = CentralTheme.TextPrimary,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 0),
			Size = UDim2.new(1, -24, 1, 0),
			Parent = Toast
		})

		Toast.Position = UDim2.new(0, 20, 0, 0)
		Toast.BackgroundTransparency = 1
		ToastText.TextTransparency = 1

		Services.TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 0
		}):Play()

		Services.TweenService:Create(ToastText, TweenInfo.new(0.3), {
			TextTransparency = 0
		}):Play()

		task.delay(Duration, function()
			Services.TweenService:Create(Toast, TweenInfo.new(0.2), {
				Position = UDim2.new(0, 20, 0, 0),
				BackgroundTransparency = 1
			}):Play()

			Services.TweenService:Create(ToastText, TweenInfo.new(0.2), {
				TextTransparency = 1
			}):Play()

			task.delay(0.2, function()
				Toast:Destroy()
			end)
		end)
	end

	function WindowFunctions:Tab(Settings)
		local TabFunctions = {Settings = Settings}

		local TabButton = UILibraryUtility:CreateTextButton({
			Name = "TabButton",
			Text = Settings.Name or "Tab",
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextColor3 = CentralTheme.TextSecondary,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Parent = WindowFunctions.TabBarLayout.Parent
		})

		UILibraryUtility:CreateUIPadding(12, 12, 0, 0, TabButton)

		local ActiveIndicator = UILibraryUtility:CreateFrame({
			Name = "ActiveIndicator",
			Size = UDim2.new(1, 0, 0, 2),
			Position = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = CentralTheme.Primary,
			BorderSizePixel = 0,
			Visible = false,
			Parent = TabButton
		})

		local TabContent = UILibraryUtility:CreateScrollingFrame({
			Name = Settings.Name .. "Content",
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.new(0, 0, 0, 36),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = CentralTheme.Border,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false,
			Parent = WindowFunctions.Content
		})

		local TabContentLayout = UILibraryUtility:CreateUIListLayout({
			Padding = UDim.new(0, CentralTheme.Padding),
			SortOrder = Enum.SortOrder.LayoutOrder
		}, TabContent)

		UILibraryUtility:CreateUIPadding(
			CentralTheme.LargePadding,
			CentralTheme.LargePadding,
			CentralTheme.LargePadding,
			CentralTheme.LargePadding,
			TabContent
		)

		TabFunctions.TabButton = TabButton
		TabFunctions.TabContent = TabContent
		TabFunctions.ActiveIndicator = ActiveIndicator

		TabButton.MouseButton1Click:Connect(function()
			TabFunctions:Select()
		end)

		TabButton.MouseEnter:Connect(function()
			if not ActiveIndicator.Visible then
				Services.TweenService:Create(TabButton, TweenInfo.new(0.15), {
					TextColor3 = CentralTheme.TextPrimary
				}):Play()
			end
		end)

		TabButton.MouseLeave:Connect(function()
			if not ActiveIndicator.Visible then
				Services.TweenService:Create(TabButton, TweenInfo.new(0.15), {
					TextColor3 = CentralTheme.TextSecondary
				}):Play()
			end
		end)

		function TabFunctions:Select()

			for _, Child in pairs(WindowFunctions.TabBarLayout.Parent:GetChildren()) do
				if Child:IsA("TextButton") and Child.Name == "TabButton" then
					Child.TextColor3 = CentralTheme.TextSecondary
					if Child:FindFirstChild("ActiveIndicator") then
						Child.ActiveIndicator.Visible = false
					end
				end
			end

			for _, Child in pairs(WindowFunctions.Content:GetChildren()) do
				if Child:IsA("ScrollingFrame") and Child.Name:match("Content$") then
					Child.Visible = false
				end
			end

			TabButton.TextColor3 = CentralTheme.Primary
			ActiveIndicator.Visible = true
			TabContent.Visible = true

			WindowFunctions.CurrentBreadcrumb.Text = Settings.Name or "Home"

			XenithLibrary.TabSettings.CurrentTab = TabContent
		end

		function TabFunctions:Card(Settings)
			local Card = UILibraryUtility:CreateFrame({
				Name = "Card",
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = CentralTheme.Surface,
				BorderSizePixel = 0,
				Parent = TabContent
			})

			UILibraryUtility:CreateUICorner(CentralTheme.CornerRadius, Card)

			local CardLayout = UILibraryUtility:CreateUIListLayout({
				Padding = UDim.new(0, CentralTheme.SmallPadding),
				SortOrder = Enum.SortOrder.LayoutOrder
			}, Card)

			UILibraryUtility:CreateUIPadding(
				CentralTheme.Padding,
				CentralTheme.Padding,
				CentralTheme.Padding,
				CentralTheme.Padding,
				Card
			)

			if Settings.Title then
				local CardTitle = UILibraryUtility:CreateTextLabel({
					Name = "CardTitle",
					Text = Settings.Title,
					Font = Enum.Font.GothamBold,
					TextSize = 14,
					TextColor3 = CentralTheme.TextPrimary,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
					Parent = Card
				})
			end

			return {
				Card = Card,
				Layout = CardLayout
			}
		end

		function TabFunctions:Section(Settings)
			local SectionFunctions = {}

			local Section = UILibraryUtility:CreateFrame({
				Name = "Section",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = CentralTheme.Surface,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				Parent = TabContent
			})

			UILibraryUtility:CreateUICorner(CentralTheme.CornerRadius, Section)

			local SectionLayout = UILibraryUtility:CreateUIListLayout({
				Padding = UDim.new(0, CentralTheme.SmallPadding),
				SortOrder = Enum.SortOrder.LayoutOrder
			}, Section)

			UILibraryUtility:CreateUIPadding(
				CentralTheme.Padding,
				CentralTheme.Padding,
				CentralTheme.Padding,
				CentralTheme.Padding,
				Section
			)

			local ComponentDirectory = "Xenith/UserInterface/Components"
			for Name, Component in pairs(Utility:ListManager(ComponentDirectory)) do
				Utility:LoadFile(Component)({
					Section = Section,
					WindowFunctions = WindowFunctions,
					XenithLibraryUI = XenithLibraryUI,
					XenithLibrary = XenithLibrary,
					SectionFunctions = SectionFunctions,
					Base = Base,
					ComponentManager = ComponentManager,
					TabName = TabFunctions.Settings.Name
				})
			end

			function SectionFunctions:Replication()
				if Settings.Replication then
					local ReplicationGame, ReplicationSection = Settings.Replication.GameDirectory, Settings.Replication.SectionName
					Utility:LoadFile("Games/Game Features/" .. ReplicationGame .. "/" .. ReplicationSection .. ".lua")
					return true
				end
				return false
			end

			function SectionFunctions:DisplayTitle()
				if Settings.DisplayTitle then
					SectionFunctions:Header({Name = Settings.DisplayTitle})
				end
				return Settings.DisplayTitle
			end

			return SectionFunctions
		end

		table.insert(XenithLibrary.Tabs, TabFunctions)

		if #XenithLibrary.Tabs == 1 then
			TabFunctions:Select()
		end

		return TabFunctions
	end

	function WindowFunctions:SaveConfiguration(ConfigName, SilentSave)
		if not isfile or not writefile or not isfolder or not makefolder then
			return false, "File system functions not available."
		end

		if not isfolder(XenithLibrary.Folder) then
			makefolder(XenithLibrary.Folder)
		end

		if not isfolder(XenithLibrary.Folder .. "/settings") then
			makefolder(XenithLibrary.Folder .. "/settings")
		end

		if not isfolder(XenithLibrary.Folder .. "/settings/" .. game.GameId) then
			makefolder(XenithLibrary.Folder .. "/settings/" .. game.GameId)
		end

		local ConfigData = {}

		for OptionKey, OptionTable in pairs(XenithLibrary.Options) do
			if OptionTable.Type then
				local Save = ClassParser[OptionTable.Type] and ClassParser[OptionTable.Type].Save

				if Save then
					ConfigData[OptionKey] = Save(OptionKey, OptionTable)
				end
			end
		end

		local Success, Error = pcall(function()
			writefile(XenithLibrary.Folder .. "/settings/" .. game.GameId .. "/" .. ConfigName .. ".json", Services.HttpService:JSONEncode(ConfigData))
		end)

		if not Success then
			if not SilentSave then
				WindowFunctions:Toast("Failed to save config: " .. tostring(Error), "Error")
			end
			return false, "Failed to save config: " .. tostring(Error)
		end

		if not SilentSave then
			WindowFunctions:Toast("Configuration saved: " .. ConfigName, "Success")
		end

		return true
	end

	function WindowFunctions:LoadConfiguration(ConfigName, SilentLoad)
		if not isfile or not readfile then
			return false, "File system functions not available."
		end

		local ConfigPath = XenithLibrary.Folder .. "/settings/" .. game.GameId .. "/" .. ConfigName .. ".json"

		if not isfile(ConfigPath) then
			if not SilentLoad then
				WindowFunctions:Toast("Config not found: " .. ConfigName, "Warning")
			end
			return false, "Config file not found."
		end

		local Success, ConfigData = pcall(function()
			return Services.HttpService:JSONDecode(readfile(ConfigPath))
		end)

		if not Success then
			if not SilentLoad then
				WindowFunctions:Toast("Failed to load config: " .. tostring(ConfigData), "Error")
			end
			return false, "Failed to load config: " .. tostring(ConfigData)
		end

		for OptionKey, OptionData in pairs(ConfigData) do
			if OptionData.ClassType then
				local Load = ClassParser[OptionData.ClassType] and ClassParser[OptionData.ClassType].Load

				if Load then
					task.spawn(function()
						pcall(function()
							Load(OptionKey, OptionData)
						end)
					end)
				end
			end
		end

		if not SilentLoad then
			WindowFunctions:Toast("Configuration loaded: " .. ConfigName, "Success")
		end

		return true
	end

	function WindowFunctions:DeleteConfiguration(ConfigName)
		if not isfile or not delfile then
			return false, "File system functions not available."
		end

		local ConfigPath = XenithLibrary.Folder .. "/settings/" .. game.GameId .. "/" .. ConfigName .. ".json"

		if not isfile(ConfigPath) then
			WindowFunctions:Toast("Config not found: " .. ConfigName, "Warning")
			return false, "Config file not found."
		end

		local Success, Error = pcall(delfile, ConfigPath)

		if not Success then
			WindowFunctions:Toast("Failed to delete config: " .. tostring(Error), "Error")
			return false, "Unable to delete config file: " .. tostring(Error)
		end

		WindowFunctions:Toast("Configuration deleted: " .. ConfigName, "Success")
		return true
	end

	function WindowFunctions:DeleteAllConfigs()
		local ConfigFolder = XenithLibrary.Folder .. "/settings/" .. game.GameId

		if not isfolder(ConfigFolder) then
			return false, "No configs folder found."
		end

		local Files = listfiles(ConfigFolder)
		local DeletedCount = 0
		local Errors = {}

		for _, FilePath in next, Files do
			if FilePath:match("%.json$") then
				local Success, Error = pcall(delfile, FilePath)
				if Success then
					DeletedCount = DeletedCount + 1
				else
					table.insert(Errors, FilePath .. ": " .. tostring(Error))
				end
			end
		end

		if #Errors > 0 then
			return false, "Deleted " .. DeletedCount .. " configs, but encountered errors: " .. table.concat(Errors, ", ")
		end

		WindowFunctions:Toast("Deleted " .. DeletedCount .. " configurations", "Success")
		return true, "Successfully deleted " .. DeletedCount .. " config(s)."
	end

	function WindowFunctions:RefreshConfigList()
		if not isfolder(XenithLibrary.Folder) or not isfolder(XenithLibrary.Folder .. "/settings") or not isfolder(XenithLibrary.Folder .. "/settings/" .. game.GameId) then
			XenithLibrary:SetFolder("XenithHubSettings")
		end

		local List = listfiles(XenithLibrary.Folder .. "/settings/" .. game.GameId .. "/")

		local Out = {}
		for Index = 1, #List do
			local File = List[Index]
			if File:sub(-5) == ".json" then
				local Pos = File:find(".json", 1, true)
				local Start = Pos

				local Char = File:sub(Pos, Pos)
				while Char ~= "/" and Char ~= "\\" and Char ~= "" do
					Pos = Pos - 1
					Char = File:sub(Pos, Pos)
				end

				if Char == "/" or Char == "\\" then
					local Name = File:sub(Pos + 1, Start - 1)
					if Name ~= "options" then
						table.insert(Out, Name)
					end
				end
			end
		end

		return Out
	end

	function WindowFunctions:GetTheme(ThemeName)
		return Themes[ThemeName]
	end

	function WindowFunctions:GetCurrentTheme()
		return XenithLibrary.CurrentTheme
	end

	function WindowFunctions:SetTheme(ThemeName)
		if Themes[ThemeName] then
			XenithLibrary.CurrentTheme = ThemeName
			WindowFunctions:ApplyCurrentTheme()
			return true
		end
		return false
	end

	function WindowFunctions:ApplyCurrentTheme()
		if not XenithLibrary.CurrentTheme or not Themes[XenithLibrary.CurrentTheme] then
			return
		end

		local ThemeData = Themes[XenithLibrary.CurrentTheme]

		Base.BackgroundColor3 = ThemeData.Background or CentralTheme.Background
		TopBar.BackgroundColor3 = ThemeData.Surface or CentralTheme.Surface

		for _, Child in pairs(CardContainer:GetChildren()) do
			if Child:IsA("Frame") and Child.Name == "Card" then
				Child.BackgroundColor3 = ThemeData.Surface or CentralTheme.Surface
			end
		end

		for _, Tab in pairs(XenithLibrary.Tabs) do
			if Tab.TabContent then
				for _, Section in pairs(Tab.TabContent:GetChildren()) do
					if Section:IsA("Frame") and Section.Name == "Section" then
						Section.BackgroundColor3 = ThemeData.Surface or CentralTheme.Surface
					end
				end
			end
		end
	end

	function WindowFunctions:GetCurrentThemeAttribute(Attribute)
		if not XenithLibrary.CurrentTheme or not Themes[XenithLibrary.CurrentTheme] then
			return nil
		end

		return Themes[XenithLibrary.CurrentTheme][Attribute]
	end

	MinimizeButton.MouseButton1Click:Connect(function()
		WindowFunctions:SetWindowState(not Base.Visible)
	end)

	CloseButton.MouseButton1Click:Connect(function()
		WindowFunctions:Destroy()
	end)

	function WindowFunctions:SetWindowState(State)
		Base.Visible = State
		XenithLibrary.WindowState = State
		return State
	end

	function WindowFunctions:GetWindowState()
		return XenithLibrary.WindowState
	end

	function WindowFunctions:Destroy()
		XenithLibrary.Unloaded = true
		XenithLibraryUI:Destroy()
	end

	local Dragging = false
	local DragInput
	local DragStart
	local StartPos

	local function Update(Input)
		local Delta = Input.Position - DragStart
		Base.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
	end

	TopBar.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = Input.Position
			StartPos = Base.Position

			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	TopBar.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			DragInput = Input
		end
	end)

	Services.UserInputService.InputChanged:Connect(function(Input)
		if Input == DragInput and Dragging then
			Update(Input)
		end
	end)

	XenithLibrary.WindowState = true
	Base.Visible = false
	Base.AnchorPoint = Vector2.new(0.5, 0.5)
	Base.Position = UDim2.fromScale(0.5, 0.5)

	local BaseUIScale = Instance.new("UIScale")
	BaseUIScale.Scale = 0.9
	BaseUIScale.Parent = Base

	task.delay(0.1, function()
		Base.Visible = true

		Services.TweenService:Create(BaseUIScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
	end)

	return WindowFunctions
end

function XenithLibrary:SaveConfig(ConfigName)
	if not isfolder(XenithLibrary.Folder) then
		makefolder(XenithLibrary.Folder)
	end

	if not isfolder(XenithLibrary.Folder .. "/settings") then
		makefolder(XenithLibrary.Folder .. "/settings")
	end

	if not isfolder(XenithLibrary.Folder .. "/settings/" .. game.GameId) then
		makefolder(XenithLibrary.Folder .. "/settings/" .. game.GameId)
	end

	local ConfigData = {}

	for OptionKey, OptionTable in pairs(XenithLibrary.Options) do
		if OptionTable.Type then
			ConfigData[OptionKey] = OptionTable:Get()
		end
	end

	local Success, Error = pcall(function()
		writefile(XenithLibrary.Folder .. "/settings/" .. game.GameId .. "/" .. ConfigName .. ".json",
			Services.HttpService:JSONEncode(ConfigData))
	end)

	if not Success then
		warn("Failed to save config:", Error)
		return false, "Failed to save config: " .. tostring(Error)
	end

	return true
end

function XenithLibrary:LoadConfig(ConfigName)
	local ConfigPath = XenithLibrary.Folder .. "/settings/" .. game.GameId .. "/" .. ConfigName .. ".json"

	if not isfile(ConfigPath) then
		return false, "Config file not found."
	end

	local Success, ConfigData = pcall(function()
		return Services.HttpService:JSONDecode(readfile(ConfigPath))
	end)

	if not Success then
		return false, "Failed to load config: " .. tostring(ConfigData)
	end

	for OptionKey, OptionValue in pairs(ConfigData) do
		if XenithLibrary.Options[OptionKey] then
			task.spawn(function()
				XenithLibrary.Options[OptionKey]:Set(OptionValue)
			end)
		end
	end

	return true
end

function XenithLibrary:DeleteConfig(ConfigName)
	local ConfigPath = XenithLibrary.Folder .. "/settings/" .. game.GameId .. "/" .. ConfigName .. ".json"

	if not isfile(ConfigPath) then
		return false, "Config file not found."
	end

	local Success, Error = pcall(delfile, ConfigPath)

	if not Success then
		return false, "Unable to delete config file: " .. tostring(Error)
	end

	return true
end

function XenithLibrary:DeleteAllConfigs()
	local ConfigFolder = XenithLibrary.Folder .. "/settings/" .. game.GameId

	if not isfolder(ConfigFolder) then
		return false, "No configs folder found."
	end

	local Files = listfiles(ConfigFolder)
	local DeletedCount = 0
	local Errors = {}

	for _, FilePath in next, Files do
		if FilePath:match("%.json$") then
			local Success, Error = pcall(delfile, FilePath)
			if Success then
				DeletedCount = DeletedCount + 1
			else
				table.insert(Errors, FilePath .. ": " .. tostring(Error))
			end
		end
	end

	if #Errors > 0 then
		return false, "Deleted " .. DeletedCount .. " configs, but encountered errors: " .. table.concat(Errors, ", ")
	end

	return true, "Successfully deleted " .. DeletedCount .. " config(s)."
end

function XenithLibrary:RefreshConfigList()
	if not isfolder(XenithLibrary.Folder) or not isfolder(XenithLibrary.Folder .. "/settings") or not isfolder(XenithLibrary.Folder .. "/settings/" .. game.GameId) then
		XenithLibrary:SetFolder("XenithHubSettings")
	end

	local List = listfiles(XenithLibrary.Folder .. "/settings/" .. game.GameId .. "/")

	local Out = {}
	for Index = 1, #List do
		local File = List[Index]
		if File:sub(-5) == ".json" then
			local Pos = File:find(".json", 1, true)
			local Start = Pos

			local Char = File:sub(Pos, Pos)
			while Char ~= "/" and Char ~= "\\" and Char ~= "" do
				Pos = Pos - 1
				Char = File:sub(Pos, Pos)
			end

			if Char == "/" or Char == "\\" then
				local Name = File:sub(Pos + 1, Start - 1)
				if Name ~= "options" then
					table.insert(Out, Name)
				end
			end
		end
	end

	return Out
end

function WindowFunctions:Notification(Settings)
	local NotificationFunctions = {}

	local Notification = UILibraryUtility:CreateFrame({
		Name = "Notification",
		Size = UDim2.new(1, 0, 0, 72),
		BackgroundColor3 = CentralTheme.Surface,
		BorderSizePixel = 0,
		Parent = WindowFunctions.ToastContainer
	})

	UILibraryUtility:CreateUICorner(CentralTheme.CornerRadius, Notification)

	local StatusColors = {
		Info = CentralTheme.Info,
		Success = CentralTheme.Success,
		Warning = CentralTheme.Warning,
		Error = CentralTheme.Danger
	}

	local StatusBar = UILibraryUtility:CreateFrame({
		Name = "StatusBar",
		Size = UDim2.new(0, 4, 1, 0),
		BackgroundColor3 = StatusColors[Settings.Type] or CentralTheme.Info,
		BorderSizePixel = 0,
		Parent = Notification
	})

	local ContentFrame = UILibraryUtility:CreateFrame({
		Name = "ContentFrame",
		Position = UDim2.new(0, 16, 0, 0),
		Size = UDim2.new(1, -48, 1, 0),
		BackgroundTransparency = 1,
		Parent = Notification
	})

	UILibraryUtility:CreateUIPadding(0, 0, CentralTheme.SmallPadding, CentralTheme.SmallPadding, ContentFrame)

	local NotificationTitle = UILibraryUtility:CreateTextLabel({
		Name = "NotificationTitle",
		Text = Settings.Title or "Notification",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = CentralTheme.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Parent = ContentFrame
	})

	local NotificationDescription = UILibraryUtility:CreateTextLabel({
		Name = "NotificationDescription",
		Text = Settings.Description or "",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = CentralTheme.TextSecondary,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 22),
		Size = UDim2.new(1, 0, 1, -22),
		Parent = ContentFrame
	})

	local CloseButton = UILibraryUtility:CreateTextButton({
		Name = "CloseButton",
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = CentralTheme.TextSecondary,
		Position = UDim2.new(1, -32, 0, 0),
		Size = UDim2.fromOffset(32, 32),
		BackgroundTransparency = 1,
		Parent = Notification
	})

	CloseButton.MouseButton1Click:Connect(function()
		NotificationFunctions:Cancel()
	end)

	Notification.Position = UDim2.new(0, 20, 0, 0)
	Notification.BackgroundTransparency = 1
	NotificationTitle.TextTransparency = 1
	NotificationDescription.TextTransparency = 1

	Services.TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 0
	}):Play()

	Services.TweenService:Create(NotificationTitle, TweenInfo.new(0.3), {
		TextTransparency = 0
	}):Play()

	Services.TweenService:Create(NotificationDescription, TweenInfo.new(0.3), {
		TextTransparency = 0
	}):Play()

	local AnimationTask = task.delay(Settings.Lifetime or 4, function()
		NotificationFunctions:Cancel()
	end)

	function NotificationFunctions:UpdateTitle(New)
		NotificationTitle.Text = New
	end

	function NotificationFunctions:UpdateDescription(New)
		NotificationDescription.Text = New
	end

	function NotificationFunctions:Cancel()
		task.cancel(AnimationTask)

		Services.TweenService:Create(Notification, TweenInfo.new(0.2), {
			Position = UDim2.new(0, 20, 0, 0),
			BackgroundTransparency = 1
		}):Play()

		Services.TweenService:Create(NotificationTitle, TweenInfo.new(0.2), {
			TextTransparency = 1
		}):Play()

		Services.TweenService:Create(NotificationDescription, TweenInfo.new(0.2), {
			TextTransparency = 1
		}):Play()

		task.delay(0.2, function()
			Notification:Destroy()
		end)
	end

	return NotificationFunctions
end

return XenithLibrary
