local RotationAngle, CurrentTick = -45, tick()
        function cooltimeout()
            character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()

            if not character then
                return false
            else
                return character
            end
        end
local PerceptionESP = {}
local ESPObjects = {}

PerceptionESP.PendingCustomEntities = {}

if Maid.ESPContainer then
	Maid.ESPContainer:Destroy()
	Maid.ESPContainer = nil
end

function PerceptionESP.ValidateTarget(Target, Methods)
	if Methods and Methods.ValidateTarget then
		return Methods.ValidateTarget(Target)
	end

	if typeof(Target) == "Instance" then
		return Target:FindFirstChild("HumanoidRootPart") ~= nil
	end

	if typeof(Target) == "table" then
		return Target.HumanoidRootPart ~= nil
	end

	return false
end

function PerceptionESP.GetTargetRootPart(Target, Methods)
	if Methods and Methods.GetRootPart then
		return Methods.GetRootPart(Target)
	end

	if typeof(Target) == "Instance" and Target:FindFirstChild("HumanoidRootPart") then
		return Target.HumanoidRootPart
	end

	if typeof(Target) == "table" and Target.HumanoidRootPart then
		return Target.HumanoidRootPart
	end

	return nil
end

function PerceptionESP.GetTargetHumanoid(Target, Methods)
	if Methods and Methods.GetHumanoid then
		return Methods.GetHumanoid(Target)
	end

	if typeof(Target) == "Instance" and Target:FindFirstChild("Humanoid") then
		return Target.Humanoid
	end

	if typeof(Target) == "table" and Target.Humanoid then
		return Target.Humanoid
	end

	return nil
end

function PerceptionESP.GetTargetName(Target, Methods)
	if Methods and Methods.GetName then
		return Methods.GetName(Target)
	end

	if typeof(Target) == "Instance" then
		if Target:IsA("Player") then
			return Target.Name
		elseif Target:IsA("Model") and Target.Name then
			return Target.Name
		end
	end

	if typeof(Target) == "table" then
		return Target.Name or "Unknown"
	end

	return "Unknown"
end

function PerceptionESP.GetTargetDistance(Origin, Target, Methods)
	if Methods and Methods.GetDistance then
		return Methods.GetDistance(Origin, Target)
	end

	return PerceptionESP.GetDistance(Origin, Target)
end

function PerceptionESP.GetTargetHealth(Target, Methods)
	if Methods and Methods.GetHealth then
		return Methods.GetHealth(Target)
	end

	return PerceptionESP.GetHealth(Target)
end

function PerceptionESP.GetTargetEntityColor(Target, Settings, Methods)
	if Methods and Methods.GetEntityColor then
		return Methods.GetEntityColor(Target, Settings, Methods)
	end

	return PerceptionESP.GetEntityColor(Target, Settings, Methods)
end

function PerceptionESP.GetTargetHeadPosition(Target, Methods)
	if Methods and Methods.GetHeadPosition then
		return Methods.GetHeadPosition(Target)
	end

	return PerceptionESP.GetHeadPosition(Target)
end

function PerceptionESP.GetDistance(Origin, Target)
	if not Origin or not Target then return 0 end

	local OriginPosition
	if typeof(Origin) == "Instance" then
		if Origin:IsA("Model") and Origin:FindFirstChild("HumanoidRootPart") then
			OriginPosition = Origin.HumanoidRootPart.Position
		elseif Origin:IsA("BasePart") then
			OriginPosition = Origin.Position
		else
			return 0
		end
	elseif typeof(Origin) == "Vector3" then
		OriginPosition = Origin
	else
		return 0
	end

	local TargetPosition
	if typeof(Target) == "Instance" then
		if Target:IsA("Model") and Target:FindFirstChild("HumanoidRootPart") then
			TargetPosition = Target.HumanoidRootPart.Position
		elseif Target:IsA("BasePart") then
			TargetPosition = Target.Position
		else
			return 0
		end
	elseif typeof(Target) == "Vector3" then
		TargetPosition = Target
	elseif typeof(Target) == "table" then
		local RootPart = Target.HumanoidRootPart
		if RootPart and typeof(RootPart) == "Instance" then
			TargetPosition = RootPart.Position
		else			
			return 0
		end
	else		
		return 0
	end

	return math.round((OriginPosition - TargetPosition).Magnitude)
end

function PerceptionESP.GetHealth(Entity)
	if not Entity then return "0/0" end

	if typeof(Entity) == "table" then
		if Entity.Humanoid then
			local CurrentHealth = math.round(Entity.Humanoid.Health or 0)
			local MaxHealth = math.round(Entity.Humanoid.MaxHealth or 100)
			return CurrentHealth .. "/" .. MaxHealth
		end
		return "0/0"
	end

	if not Entity:FindFirstChild("Humanoid") then return "0/0" end
	local Humanoid = Entity:FindFirstChild("Humanoid")
	local CurrentHealth = math.round(Humanoid.Health)
	local MaxHealth = math.round(Humanoid.MaxHealth)
	return CurrentHealth .. "/" .. MaxHealth
end

function PerceptionESP.GetEntityColor(Entity, Settings, Methods)
	local EntityName = PerceptionESP.GetTargetName(Entity, Methods)

	if Settings.CustomColors and Settings.CustomColors[EntityName] then
		return Settings.CustomColors[EntityName]
	end

	if typeof(Entity) == "table" then
		local Player = Entity._player
		if Player and Settings.UseTeamColors then
			if Methods and Methods.GetTeamColor then
				return Methods.GetTeamColor(Player) or Settings.DefaultESPColor or Color3.fromRGB(124, 233, 255)
			end

			if Player.Team and Player.Team.TeamColor then
				return Player.Team.TeamColor.Color
			end
		end
		return Settings.DefaultESPColor or Color3.fromRGB(124, 233, 255)
	end

	local Player = Services.Players:GetPlayerFromCharacter(Entity)
	if Player and Settings.UseTeamColors then
		if Methods and Methods.GetTeamColor then
			return Methods.GetTeamColor(Player) or Settings.DefaultESPColor or Color3.fromRGB(124, 233, 255)
		end

		return Player.Team and Player.Team.TeamColor.Color or Settings.DefaultESPColor or Color3.fromRGB(124, 233, 255)
	end

	return Settings.DefaultESPColor or Color3.fromRGB(124, 233, 255)
end

function PerceptionESP.GetHeadPosition(Entity)
	if typeof(Entity) == "table" then
		if Entity.Head and typeof(Entity.Head) == "Instance" then
			return Entity.Head.Position
		elseif Entity.HumanoidRootPart and typeof(Entity.HumanoidRootPart) == "Instance" then
			return Entity.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
		end
		return nil
	end

	if Entity and Entity:FindFirstChild("Head") then
		return Entity.Head.Position
	elseif Entity and Entity:FindFirstChild("HumanoidRootPart") then
		return Entity.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
	end
	return nil
end

function PerceptionESP.GetSkeletonParts(Entity)
	local Parts = {}
	
	if typeof(Entity) == "table" then
		Parts.Head = Entity.Head
		Parts.Torso = Entity.HumanoidRootPart or Entity.Torso or Entity.UpperTorso
		Parts.LeftArm = Entity.LeftUpperArm or Entity["Left Arm"]
		Parts.RightArm = Entity.RightUpperArm or Entity["Right Arm"] 
		Parts.LeftLeg = Entity.LeftUpperLeg or Entity["Left Leg"]
		Parts.RightLeg = Entity.RightUpperLeg or Entity["Right Leg"]
		Parts.LeftForearm = Entity.LeftLowerArm or Entity.LeftHand
		Parts.RightForearm = Entity.RightLowerArm or Entity.RightHand
		Parts.LeftShin = Entity.LeftLowerLeg or Entity.LeftFoot
		Parts.RightShin = Entity.RightLowerLeg or Entity.RightFoot
	else
		Parts.Head = Entity:FindFirstChild("Head")
		Parts.Torso = Entity:FindFirstChild("HumanoidRootPart") or Entity:FindFirstChild("Torso") or Entity:FindFirstChild("UpperTorso")
		Parts.LeftArm = Entity:FindFirstChild("LeftUpperArm") or Entity:FindFirstChild("Left Arm")
		Parts.RightArm = Entity:FindFirstChild("RightUpperArm") or Entity:FindFirstChild("Right Arm")
		Parts.LeftLeg = Entity:FindFirstChild("LeftUpperLeg") or Entity:FindFirstChild("Left Leg") 
		Parts.RightLeg = Entity:FindFirstChild("RightUpperLeg") or Entity:FindFirstChild("Right Leg")
		Parts.LeftForearm = Entity:FindFirstChild("LeftLowerArm") or Entity:FindFirstChild("LeftHand")
		Parts.RightForearm = Entity:FindFirstChild("RightLowerArm") or Entity:FindFirstChild("RightHand")
		Parts.LeftShin = Entity:FindFirstChild("LeftLowerLeg") or Entity:FindFirstChild("LeftFoot")
		Parts.RightShin = Entity:FindFirstChild("RightLowerLeg") or Entity:FindFirstChild("RightFoot")
	end
	
	return Parts
end

function PerceptionESP.CreateSkeletonLine(Parent, Name)
	return PerceptionESP.Create("Frame", {
		Parent = Parent,
		Name = Name,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 1,
		Visible = false
	})
end

function PerceptionESP.RenderSkeletonLine(LineObject, StartPos, EndPos, Color, Thickness, Visible)
	if not Visible then
		LineObject.Visible = false
		return
	end
	
	local StartScreen, StartOnScreen = workspace.CurrentCamera:WorldToScreenPoint(StartPos)
	local EndScreen, EndOnScreen = workspace.CurrentCamera:WorldToScreenPoint(EndPos)
	
	if not (StartOnScreen and EndOnScreen) then
		LineObject.Visible = false
		return
	end
	
	local Distance = (Vector2.new(StartScreen.X, StartScreen.Y) - Vector2.new(EndScreen.X, EndScreen.Y)).Magnitude
	local Angle = math.atan2(EndScreen.Y - StartScreen.Y, EndScreen.X - StartScreen.X)
	
	LineObject.Visible = true
	LineObject.BackgroundColor3 = Color
	LineObject.Position = UDim2.new(0, (StartScreen.X + EndScreen.X) / 2, 0, (StartScreen.Y + EndScreen.Y) / 2)
	LineObject.Size = UDim2.new(0, Distance, 0, Thickness)
	LineObject.Rotation = math.deg(Angle)
end

function PerceptionESP.Create(Class, Properties)
	local Instance = typeof(Class) == "string" and Instance.new(Class) or Class
	for Property, Value in pairs(Properties) do
		Instance[Property] = Value
	end
	return Instance
end

function PerceptionESP.HideESPComponents(TargetName)
	if not ESPObjects[TargetName] then 
		return 
	end

	if ESPObjects[TargetName].SkeletonLines then 
		for _, Line in pairs(ESPObjects[TargetName].SkeletonLines) do
			Line.Visible = false
		end
	end

	ESPObjects[TargetName].Name.Visible = false
	ESPObjects[TargetName].BehindHealthbar.Visible = false
	ESPObjects[TargetName].Healthbar.Visible = false
	ESPObjects[TargetName].Box.Visible = false
	ESPObjects[TargetName].BottomRightDown.Visible = false
	ESPObjects[TargetName].BottomRightSide.Visible = false
	ESPObjects[TargetName].RightSide.Visible = false
	ESPObjects[TargetName].RightTop.Visible = false
	ESPObjects[TargetName].BottomDown.Visible = false
	ESPObjects[TargetName].BottomSide.Visible = false
	ESPObjects[TargetName].LeftSide.Visible = false
	ESPObjects[TargetName].LeftTop.Visible = false
	ESPObjects[TargetName].Tracer.Visible = false
	ESPObjects[TargetName].HeadDot.Visible = false
	ESPObjects[TargetName].Chams.Enabled = false
end

function PerceptionESP.Initialize(Options, Methods)
	Options = Options or {}
	Methods = Methods or {}

	if Maid.MainRenderESP then
		Maid.MainRenderESP:Disconnect()
		Maid.MainRenderESP = nil
	end

	local ESPContainer = PerceptionESP.Create("ScreenGui", {
		Name = "PerceptionESP",
		Parent = gethui(),
		ResetOnSpawn = false
	})

	Maid.ESPContainer = ESPContainer

	ESPObjects = {}

	local function GetTargets()
		if Methods.GetPlayer then
			return Methods.GetPlayer()
		end

		local Targets = {}
		for _, Player in pairs(Services.Players:GetPlayers()) do
			if Player ~= game.Players.LocalPlayer then
				table.insert(Targets, Player.Character)
			end
		end

		if Options.CustomEntities then
			for _, Entity in pairs(Options.CustomEntities) do
				if Entity:IsA("Instance") and Entity:IsA("Model") then
					table.insert(Targets, Entity)
				end
			end
		end

		return Targets
	end

	local function CreateESPObject(Target, TargetName)
		if ESPObjects[TargetName] then return end

		ESPObjects[TargetName] = {
			Name = PerceptionESP.Create("TextLabel", {
				Parent = ESPContainer,
				Position = UDim2.new(0.5, 0, 0, -11),
				Size = UDim2.new(0, 100, 0, 20),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.Code,
				TextSize = 12,
				TextStrokeTransparency = 0,
				TextWrapped = false,
				TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
				RichText = true
			}),

			Box = PerceptionESP.Create("Frame", {
				Parent = ESPContainer,
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.75,
				BorderSizePixel = 0
			}),

			Gradient1 = PerceptionESP.Create("UIGradient", {
				Enabled = true,
				Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(124, 233, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
				}
			}),

			Outline = PerceptionESP.Create("UIStroke", {
				Enabled = true,
				Transparency = 0,
				Color = Color3.fromRGB(255, 255, 255),
				LineJoinMode = Enum.LineJoinMode.Miter
			}),

			Gradient2 = PerceptionESP.Create("UIGradient", {
				Enabled = true,
				Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(124, 233, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
				}
			}),

			Healthbar = PerceptionESP.Create("Frame", {
				Parent = ESPContainer,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0
			}),

			BehindHealthbar = PerceptionESP.Create("Frame", {
				Parent = ESPContainer,
				ZIndex = -1,
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0
			}),

			HealthbarGradient = PerceptionESP.Create("UIGradient", {
				Enabled = true,
				Rotation = -90,
				Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(6, 115, 145)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(9, 172, 217)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 251, 255))
				}
			}),

			Chams = PerceptionESP.Create("Highlight", {
				Parent = ESPContainer,
				FillTransparency = 1,
				OutlineTransparency = 0,
				OutlineColor = Color3.fromRGB(255, 255, 255),
				DepthMode = "AlwaysOnTop"
			}),

			LeftTop = PerceptionESP.Create("Frame", {
				Parent = ESPContainer,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0, 0, 0, 0)
			}),

			LeftSide = PerceptionESP.Create("Frame", {
				Parent = ESPContainer,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0, 0, 0, 0)
			}),

			RightTop = PerceptionESP.Create("Frame", {
				Parent = ESPContainer,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0, 0, 0, 0)
			}),

			RightSide = PerceptionESP.Create("Frame", {
				Parent = ESPContainer,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0, 0, 0, 0)
			}),

			BottomSide = PerceptionESP.Create("Frame", {
				Parent = ESPContainer,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0, 0, 0, 0)
			}),

			BottomDown = PerceptionESP.Create("Frame", {
				Parent = ESPContainer,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0, 0, 0, 0)
			}),

			BottomRightSide = PerceptionESP.Create("Frame", {
				Parent = ESPContainer,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0, 0, 0, 0)
			}),

			BottomRightDown = PerceptionESP.Create("Frame", {
				Parent = ESPContainer,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.new(0, 0, 0, 0)
			}),

			Tracer = PerceptionESP.Create("Frame", {
				Parent = ESPContainer,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				ZIndex = 0
			}),

			HeadDot = PerceptionESP.Create("Frame", {
				Parent = ESPContainer,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.new(0, 5, 0, 5),
				ZIndex = 2
			}),

			HeadDotCorner = PerceptionESP.Create("UICorner", {
				CornerRadius = UDim.new(1, 0)
			}),

			SkeletonLines = {
				HeadToTorso = PerceptionESP.CreateSkeletonLine(ESPContainer, "HeadToTorso"),
				TorsoToLeftArm = PerceptionESP.CreateSkeletonLine(ESPContainer, "TorsoToLeftArm"),
				TorsoToRightArm = PerceptionESP.CreateSkeletonLine(ESPContainer, "TorsoToRightArm"),
				TorsoToLeftLeg = PerceptionESP.CreateSkeletonLine(ESPContainer, "TorsoToLeftLeg"),
				TorsoToRightLeg = PerceptionESP.CreateSkeletonLine(ESPContainer, "TorsoToRightLeg"),
				LeftArmToForearm = PerceptionESP.CreateSkeletonLine(ESPContainer, "LeftArmToForearm"),
				RightArmToForearm = PerceptionESP.CreateSkeletonLine(ESPContainer, "RightArmToForearm"),
				LeftLegToShin = PerceptionESP.CreateSkeletonLine(ESPContainer, "LeftLegToShin"),
				RightLegToShin = PerceptionESP.CreateSkeletonLine(ESPContainer, "RightLegToShin")
			}
		}

		ESPObjects[TargetName].Gradient1.Parent = ESPObjects[TargetName].Box
		ESPObjects[TargetName].Outline.Parent = ESPObjects[TargetName].Box
		ESPObjects[TargetName].Gradient2.Parent = ESPObjects[TargetName].Outline
		ESPObjects[TargetName].HealthbarGradient.Parent = ESPObjects[TargetName].Healthbar
		ESPObjects[TargetName].HeadDotCorner.Parent = ESPObjects[TargetName].HeadDot

		PerceptionESP.HideESPComponents(TargetName)
	end

	if not Methods.GetPlayer then
		Services.Players.PlayerRemoving:Connect(function(Player)
			if ESPObjects[Player.Name] then
				for _, Object in pairs(ESPObjects[Player.Name]) do
					if typeof(Object) == "Instance" then
						Object:Destroy()
					elseif typeof(Object) == "table" then
						for _, SubObject in pairs(Object) do
							if typeof(SubObject) == "Instance" then
								SubObject:Destroy()
							end
						end
					end
				end
				ESPObjects[Player.Name] = nil
			end
		end)
	end

	local Settings = {
		ShowName = Options.ShowName or false,
		ShowHealth = Options.ShowHealth or false,
		ShowDistance = Options.ShowDistance or false,
		ShowHealthbar = Options.ShowHealthbar or false,

		ShowBoxes = Options.ShowBoxes or false,
		ShowChams = Options.ShowChams or false,

		ShowSkeletons = Options.ShowSkeletons or true,
		SkeletonThickness = Options.SkeletonThickness or 1,

		ShowTracers = Options.ShowTracers or false,
		TracerOrigin = Options.TracerOrigin or "Bottom",
		TracerThickness = Options.TracerThickness or 1,

		ShowHeadDots = Options.ShowHeadDots or true,
		HeadDotSize = Options.HeadDotSize or 5,
		BoxLineWidth = Options.BoxLineWidth or 1,

		UseTeamColors = Options.UseTeamColors or false,
		DefaultESPColor = Options.DefaultESPColor or Color3.fromRGB(124, 233, 255),

		FadeOutEnabled = Options.FadeOutEnabled or false,
		TextScaled = Options.TextScaled or false,
		FontSize = Options.FontSize or 12,
		FadeOutDistance = Options.FadeOutDistance or 2500,
		FontType = Options.FontType or "Code",
	}


	Maid.MainRenderESP = Services.RunService.RenderStepped:Connect(function()
		PerceptionESP.CurrentSettings = Settings

		if PerceptionESP.PendingCustomEntities then
			for CustomId, PendingData in pairs(PerceptionESP.PendingCustomEntities) do
				if PendingData.Entity and PendingData.Entity.Parent then
					PerceptionESP.AddCustomEntity(PendingData.Entity, PendingData.Options)
				end
			end

			PerceptionESP.PendingCustomEntities = {}
		end

		ESPContainer.Enabled = true

		local Targets = GetTargets()
		local ProcessedTargets = {}

		local ShouldDebug = true

		for _, Target in pairs(Targets) do
			local TargetName = PerceptionESP.GetTargetName(Target, Methods)
			ProcessedTargets[TargetName] = true

			CreateESPObject(Target, TargetName)

			if not PerceptionESP.ValidateTarget(Target, Methods) then
				PerceptionESP.HideESPComponents(TargetName)
				continue
			end

			local RootPart = PerceptionESP.GetTargetRootPart(Target, Methods)
			if not RootPart then
				PerceptionESP.HideESPComponents(TargetName)
				continue
			end

			local Distance = PerceptionESP.GetTargetDistance(cooltimeout(), Target, Methods) or 0

			local Position, OnScreen = workspace.CurrentCamera:WorldToScreenPoint(RootPart.Position)
			local EntityColor = PerceptionESP.GetTargetEntityColor(Target, Settings, Methods)

			if OnScreen then
				local Humanoid = PerceptionESP.GetTargetHumanoid(Target, Methods)

				if Humanoid then
					local CloseDistance = 60
					local MaxSize = 4.5

					local ScaleFactor = math.clamp(1 - (Distance / CloseDistance), 0, 0.2)
					local AdjustedSize = MaxSize + MaxSize * ScaleFactor

					local Width = AdjustedSize * workspace.CurrentCamera.ViewportSize.Y / (Position.Z * 2)
					local Height = Width * 1.5

					ESPObjects[TargetName].Chams.Adornee = Methods and Methods.SetAdornee and Methods.SetAdornee(Target) or Target
					ESPObjects[TargetName].Chams.Enabled = Settings.ShowChams

					if Settings.UseTeamColors or (Settings.CustomColors and Settings.CustomColors[TargetName]) then
						ESPObjects[TargetName].Chams.FillColor = EntityColor
						ESPObjects[TargetName].Chams.OutlineColor = EntityColor
					else
						ESPObjects[TargetName].Chams.FillColor = Color3.fromRGB(5, 93, 115)
						ESPObjects[TargetName].Chams.OutlineColor = Color3.fromRGB(255, 255, 255)
					end

					local BreathingEffect = math.atan(math.sin(tick() * 2)) * 2 / math.pi
					local TransparencyValue = Settings.FadeOutEnabled and 
						math.clamp(Distance / Settings.FadeOutDistance, 0, 1) or 
						(100 * BreathingEffect * 0.01)

					ESPObjects[TargetName].Chams.FillTransparency = TransparencyValue
					ESPObjects[TargetName].Chams.OutlineTransparency = TransparencyValue

					local BoxVisible = Settings.ShowBoxes
					local BoxColor = EntityColor

					ESPObjects[TargetName].LeftTop.BackgroundColor3 = BoxColor
					ESPObjects[TargetName].LeftTop.Visible = BoxVisible
					ESPObjects[TargetName].LeftTop.Position = UDim2.new(0, Position.X - Width / 2, 0, Position.Y - Height / 2)
					ESPObjects[TargetName].LeftTop.Size = UDim2.new(0, Width / 5, 0, Settings.BoxLineWidth)

					ESPObjects[TargetName].LeftSide.BackgroundColor3 = BoxColor
					ESPObjects[TargetName].LeftSide.Visible = BoxVisible
					ESPObjects[TargetName].LeftSide.Position = UDim2.new(0, Position.X - Width / 2, 0, Position.Y - Height / 2)
					ESPObjects[TargetName].LeftSide.Size = UDim2.new(0, Settings.BoxLineWidth, 0, Height / 5)

					ESPObjects[TargetName].BottomSide.BackgroundColor3 = BoxColor
					ESPObjects[TargetName].BottomSide.Visible = BoxVisible
					ESPObjects[TargetName].BottomSide.Position = UDim2.new(0, Position.X - Width / 2, 0, Position.Y + Height / 2)
					ESPObjects[TargetName].BottomSide.Size = UDim2.new(0, Settings.BoxLineWidth, 0, Height / 5)
					ESPObjects[TargetName].BottomSide.AnchorPoint = Vector2.new(0, 1)

					ESPObjects[TargetName].BottomDown.BackgroundColor3 = BoxColor
					ESPObjects[TargetName].BottomDown.Visible = BoxVisible
					ESPObjects[TargetName].BottomDown.Position = UDim2.new(0, Position.X - Width / 2, 0, Position.Y + Height / 2)
					ESPObjects[TargetName].BottomDown.Size = UDim2.new(0, Width / 5, 0, Settings.BoxLineWidth)
					ESPObjects[TargetName].BottomDown.AnchorPoint = Vector2.new(0, 1)

					ESPObjects[TargetName].RightTop.BackgroundColor3 = BoxColor
					ESPObjects[TargetName].RightTop.Visible = BoxVisible
					ESPObjects[TargetName].RightTop.Position = UDim2.new(0, Position.X + Width / 2, 0, Position.Y - Height / 2)
					ESPObjects[TargetName].RightTop.Size = UDim2.new(0, Width / 5, 0, Settings.BoxLineWidth)
					ESPObjects[TargetName].RightTop.AnchorPoint = Vector2.new(1, 0)

					ESPObjects[TargetName].RightSide.BackgroundColor3 = BoxColor
					ESPObjects[TargetName].RightSide.Visible = BoxVisible
					ESPObjects[TargetName].RightSide.Position = UDim2.new(0, Position.X + Width / 2 - Settings.BoxLineWidth, 0, Position.Y - Height / 2)
					ESPObjects[TargetName].RightSide.Size = UDim2.new(0, Settings.BoxLineWidth, 0, Height / 5)

					ESPObjects[TargetName].BottomRightSide.BackgroundColor3 = BoxColor
					ESPObjects[TargetName].BottomRightSide.Visible = BoxVisible
					ESPObjects[TargetName].BottomRightSide.Position = UDim2.new(0, Position.X + Width / 2, 0, Position.Y + Height / 2)
					ESPObjects[TargetName].BottomRightSide.Size = UDim2.new(0, Settings.BoxLineWidth, 0, Height / 5)
					ESPObjects[TargetName].BottomRightSide.AnchorPoint = Vector2.new(1, 1)

					ESPObjects[TargetName].BottomRightDown.BackgroundColor3 = BoxColor
					ESPObjects[TargetName].BottomRightDown.Visible = BoxVisible
					ESPObjects[TargetName].BottomRightDown.Position = UDim2.new(0, Position.X + Width / 2, 0, Position.Y + Height / 2)
					ESPObjects[TargetName].BottomRightDown.Size = UDim2.new(0, Width / 5, 0, Settings.BoxLineWidth)
					ESPObjects[TargetName].BottomRightDown.AnchorPoint = Vector2.new(1, 1)

					ESPObjects[TargetName].Box.Position = UDim2.new(0, Position.X - Width / 2, 0, Position.Y - Height / 2)
					ESPObjects[TargetName].Box.Size = UDim2.new(0, Width, 0, Height)
					ESPObjects[TargetName].Box.Visible = BoxVisible

					RotationAngle = RotationAngle + (tick() - CurrentTick) * 300 * math.cos(math.pi / 4 * tick() - math.pi / 2)
					ESPObjects[TargetName].Gradient1.Rotation = RotationAngle
					ESPObjects[TargetName].Gradient2.Rotation = RotationAngle

					ESPObjects[TargetName].Gradient1.Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, EntityColor),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
					}

					ESPObjects[TargetName].Gradient2.Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, EntityColor),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
					}

					CurrentTick = tick()

					local Health = Methods.GetHealthBar and Methods.GetHealthBar(Target) or Humanoid.Health / Humanoid.MaxHealth
					ESPObjects[TargetName].Healthbar.Visible = Settings.ShowHealthbar
					ESPObjects[TargetName].Healthbar.Position = UDim2.new(0, Position.X - Width / 2 - 6, 0, Position.Y - Height / 2 + Height * (1 - Health))
					ESPObjects[TargetName].Healthbar.Size = UDim2.new(0, 3, 0, Height * Health)

					local HealthColor = Color3.fromRGB(
						math.floor(255 * (1 - Health)),
						math.floor(255 * Health),
						0
					)

					ESPObjects[TargetName].HealthbarGradient.Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.new(
							math.clamp(HealthColor:lerp(Color3.fromRGB(0, 0, 0), 0.7).R, 0, 1),
							math.clamp(HealthColor:lerp(Color3.fromRGB(0, 0, 0), 0.7).G, 0, 1),
							math.clamp(HealthColor:lerp(Color3.fromRGB(0, 0, 0), 0.7).B, 0, 1)
						)),
						ColorSequenceKeypoint.new(0.5, Color3.new(
							math.clamp(HealthColor.R, 0, 1),
							math.clamp(HealthColor.G, 0, 1),
							math.clamp(HealthColor.B, 0, 1)
						)),
						ColorSequenceKeypoint.new(1, Color3.new(
							math.clamp(HealthColor:lerp(Color3.fromRGB(255, 255, 255), 0.5).R, 0, 1),
							math.clamp(HealthColor:lerp(Color3.fromRGB(255, 255, 255), 0.5).G, 0, 1),
							math.clamp(HealthColor:lerp(Color3.fromRGB(255, 255, 255), 0.5).B, 0, 1)
						))
					}

					ESPObjects[TargetName].BehindHealthbar.Visible = Settings.ShowHealthbar
					ESPObjects[TargetName].BehindHealthbar.Position = UDim2.new(0, Position.X - Width / 2 - 6, 0, Position.Y - Height / 2)
					ESPObjects[TargetName].BehindHealthbar.Size = UDim2.new(0, 3, 0, Height)

					local ScreenSize = workspace.CurrentCamera.ViewportSize
					local TracerOrigin = Vector2.new(ScreenSize.X / 2, ScreenSize.Y)

					if Settings.TracerOrigin == "Center" then
						TracerOrigin = Vector2.new(ScreenSize.X / 2, ScreenSize.Y / 2)
					elseif Settings.TracerOrigin == "Mouse" then
						local UserInputService = Services.UserInputService
						TracerOrigin = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
					end

					local TracerStart = TracerOrigin
					local TracerEnd = Vector2.new(Position.X, Position.Y)
					local TracerDistance = (TracerStart - TracerEnd).Magnitude

					if TracerDistance == 0 then TracerDistance = 0.01 end

					ESPObjects[TargetName].Tracer.Visible = Settings.ShowTracers
					ESPObjects[TargetName].Tracer.BackgroundColor3 = EntityColor
					ESPObjects[TargetName].Tracer.Position = UDim2.new(0, (TracerStart.X + TracerEnd.X) / 2, 0, (TracerStart.Y + TracerEnd.Y) / 2)
					ESPObjects[TargetName].Tracer.Size = UDim2.new(0, Settings.TracerThickness, 0, TracerDistance)

					local Angle = math.atan2(TracerEnd.Y - TracerStart.Y, TracerEnd.X - TracerStart.X)
					ESPObjects[TargetName].Tracer.Rotation = math.deg(Angle) - 90

					if Settings.ShowHeadDots then
						local HeadPosition = PerceptionESP.GetTargetHeadPosition(Target, Methods)
						if HeadPosition then
							local HeadScreenPosition, HeadOnScreen = workspace.CurrentCamera:WorldToScreenPoint(HeadPosition)

							if HeadOnScreen then
								ESPObjects[TargetName].HeadDot.Visible = true
								ESPObjects[TargetName].HeadDot.BackgroundColor3 = EntityColor
								ESPObjects[TargetName].HeadDot.Position = UDim2.new(0, HeadScreenPosition.X, 0, HeadScreenPosition.Y)
								ESPObjects[TargetName].HeadDot.Size = UDim2.new(0, Settings.HeadDotSize, 0, Settings.HeadDotSize)
							else
								ESPObjects[TargetName].HeadDot.Visible = false
							end
						else
							ESPObjects[TargetName].HeadDot.Visible = false
						end
					else
						ESPObjects[TargetName].HeadDot.Visible = false
					end

					if Settings.FadeOutEnabled then
						local Transparency = math.clamp(Distance / Settings.FadeOutDistance, 0, 1)
						ESPObjects[TargetName].Name.TextTransparency = Transparency
						ESPObjects[TargetName].Box.BackgroundTransparency = 0.75 + Transparency * 0.25
						ESPObjects[TargetName].Outline.Transparency = Transparency
						ESPObjects[TargetName].Healthbar.BackgroundTransparency = Transparency
						ESPObjects[TargetName].BehindHealthbar.BackgroundTransparency = Transparency
						ESPObjects[TargetName].LeftTop.BackgroundTransparency = Transparency
						ESPObjects[TargetName].LeftSide.BackgroundTransparency = Transparency
						ESPObjects[TargetName].RightTop.BackgroundTransparency = Transparency
						ESPObjects[TargetName].RightSide.BackgroundTransparency = Transparency
						ESPObjects[TargetName].BottomSide.BackgroundTransparency = Transparency
						ESPObjects[TargetName].BottomDown.BackgroundTransparency = Transparency
						ESPObjects[TargetName].BottomRightSide.BackgroundTransparency = Transparency
						ESPObjects[TargetName].BottomRightDown.BackgroundTransparency = Transparency
						ESPObjects[TargetName].Tracer.BackgroundTransparency = Transparency
						ESPObjects[TargetName].HeadDot.BackgroundTransparency = Transparency
					end

					local NameText = TargetName

					if Settings.ShowHealth then
						NameText = NameText .. " / [" .. PerceptionESP.GetTargetHealth(Target, Methods) .. "]"
					end

					if Settings.ShowDistance then
						NameText = NameText .. " / [" .. Distance .. "]"
					end

					ESPObjects[TargetName].Name.Text = NameText
					ESPObjects[TargetName].Name.Position = UDim2.new(0, Position.X, 0, Position.Y - Height / 2 - 9)
					ESPObjects[TargetName].Name.Visible = Settings.ShowName
					ESPObjects[TargetName].Name.TextScaled = Settings.TextScaled
					ESPObjects[TargetName].Name.TextSize = Settings.FontSize
					ESPObjects[TargetName].Name.Font = Enum.Font[Settings.FontType]

					if Settings.ShowSkeletons then
						local SkeletonParts = PerceptionESP.GetSkeletonParts(Target)
						local SkeletonColor = EntityColor

						for _, Line in pairs(ESPObjects[TargetName].SkeletonLines) do
							Line.Visible = true
						end
						
						if SkeletonParts.Head and SkeletonParts.Torso then
							PerceptionESP.RenderSkeletonLine(
								ESPObjects[TargetName].SkeletonLines.HeadToTorso,
								SkeletonParts.Head.Position,
								SkeletonParts.Torso.Position,
								SkeletonColor,
								Settings.SkeletonThickness,
								true
							)
						end
						
						if SkeletonParts.Torso and SkeletonParts.LeftArm then
							PerceptionESP.RenderSkeletonLine(
								ESPObjects[TargetName].SkeletonLines.TorsoToLeftArm,
								SkeletonParts.Torso.Position,
								SkeletonParts.LeftArm.Position,
								SkeletonColor,
								Settings.SkeletonThickness,
								true
							)
						end
						
						if SkeletonParts.Torso and SkeletonParts.RightArm then
							PerceptionESP.RenderSkeletonLine(
								ESPObjects[TargetName].SkeletonLines.TorsoToRightArm,
								SkeletonParts.Torso.Position,
								SkeletonParts.RightArm.Position,
								SkeletonColor,
								Settings.SkeletonThickness,
								true
							)
						end
						
						if SkeletonParts.Torso and SkeletonParts.LeftLeg then
							PerceptionESP.RenderSkeletonLine(
								ESPObjects[TargetName].SkeletonLines.TorsoToLeftLeg,
								SkeletonParts.Torso.Position,
								SkeletonParts.LeftLeg.Position,
								SkeletonColor,
								Settings.SkeletonThickness,
								true
							)
						end
						
						if SkeletonParts.Torso and SkeletonParts.RightLeg then
							PerceptionESP.RenderSkeletonLine(
								ESPObjects[TargetName].SkeletonLines.TorsoToRightLeg,
								SkeletonParts.Torso.Position,
								SkeletonParts.RightLeg.Position,
								SkeletonColor,
								Settings.SkeletonThickness,
								true
							)
						end
						
						if SkeletonParts.LeftArm and SkeletonParts.LeftForearm then
							PerceptionESP.RenderSkeletonLine(
								ESPObjects[TargetName].SkeletonLines.LeftArmToForearm,
								SkeletonParts.LeftArm.Position,
								SkeletonParts.LeftForearm.Position,
								SkeletonColor,
								Settings.SkeletonThickness,
								true
							)
						end
						
						if SkeletonParts.RightArm and SkeletonParts.RightForearm then
							PerceptionESP.RenderSkeletonLine(
								ESPObjects[TargetName].SkeletonLines.RightArmToForearm,
								SkeletonParts.RightArm.Position,
								SkeletonParts.RightForearm.Position,
								SkeletonColor,
								Settings.SkeletonThickness,
								true
							)
						end
						
						if SkeletonParts.LeftLeg and SkeletonParts.LeftShin then
							PerceptionESP.RenderSkeletonLine(
								ESPObjects[TargetName].SkeletonLines.LeftLegToShin,
								SkeletonParts.LeftLeg.Position,
								SkeletonParts.LeftShin.Position,
								SkeletonColor,
								Settings.SkeletonThickness,
								true
							)
						end
						
						if SkeletonParts.RightLeg and SkeletonParts.RightShin then
							PerceptionESP.RenderSkeletonLine(
								ESPObjects[TargetName].SkeletonLines.RightLegToShin,
								SkeletonParts.RightLeg.Position,
								SkeletonParts.RightShin.Position,
								SkeletonColor,
								Settings.SkeletonThickness,
								true
							)
						end
						
						if Settings.FadeOutEnabled then
							local Transparency = math.clamp(Distance / Settings.FadeOutDistance, 0, 1)
							for _, Line in pairs(ESPObjects[TargetName].SkeletonLines) do
								Line.BackgroundTransparency = Transparency
							end
						end
					else
						if not ESPObjects[TargetName] or not ESPObjects[TargetName].SkeletonLines then 
							return
						end
						
						for _, Line in pairs(ESPObjects[TargetName].SkeletonLines) do
							Line.Visible = false
						end
					end
				end
			else
				PerceptionESP.HideESPComponents(TargetName)
			end
		end

		for ESPName, _ in pairs(ESPObjects) do
			if not ProcessedTargets[ESPName] then
				PerceptionESP.HideESPComponents(ESPName)
			end
		end
	end)

	return {
		UpdateSettings = function(NewSettings)
			for Key, Value in pairs(NewSettings) do
				Settings[Key] = Value
			end
		end,

		GetSettings = function()
			return Settings
		end,

		Disable = function()
			if Maid.MainRenderESP then
				Maid.MainRenderESP:Disconnect()
				Maid.MainRenderESP = nil
			end
			for _, ObjectSet in pairs(ESPObjects) do
				for _, Object in pairs(ObjectSet) do
					if typeof(Object) == "Instance" then
						Object:Destroy()
					elseif typeof(Object) == "table" then
						for _, SubObject in pairs(Object) do
							if typeof(SubObject) == "Instance" then
								SubObject:Destroy()
							end
						end
					end
				end
			end

			if ESPContainer then
				ESPContainer:Destroy()
			end

			ESPObjects = {}
		end,

		SetEntityColor = function(EntityName, Color)
			if not Settings.CustomColors then
				Settings.CustomColors = {}
			end

			Settings.CustomColors[EntityName] = Color
		end,

		ClearEntityColors = function()
			Settings.CustomColors = {}
		end,

		EditFeature = function(FeatureName, Enabled)
			if Settings[FeatureName] ~= nil then
				Settings[FeatureName] = Enabled
			end
		end,

		HighlightEntity = function(EntityName, HighlightColor, Duration)
			if ESPObjects[EntityName] then
				local OriginalColor = Settings.CustomColors and Settings.CustomColors[EntityName] or Settings.DefaultESPColor

				if not Settings.CustomColors then
					Settings.CustomColors = {}
				end
				Settings.CustomColors[EntityName] = HighlightColor or Color3.fromRGB(255, 0, 0)

				if Duration and Duration > 0 then
					task.delay(Duration, function()
						if Settings.CustomColors then
							Settings.CustomColors[EntityName] = OriginalColor
						end
					end)
				end

				return true
			end
			return false
		end,

		GetVisibleEntities = function()
			local Visible = {}
			for EntityName, _ in pairs(ESPObjects) do
				if ESPObjects[EntityName].Box and ESPObjects[EntityName].Box.Visible then
					table.insert(Visible, EntityName)
				end
			end
			return Visible
		end
	}
end
function PerceptionESP.AddCustomEntity(Entity, Options)
    if not Entity or not Entity:IsA("Instance") then
        return false
    end

    Options = Options or {}
    local CustomId = Options.CustomId or Entity:GetFullName() or Entity.Name or tostring(Entity)
    
    local ESPObject = {}
    local RenderConnection
    local IsActive = false
    
    local function CreateESPObjects()
        if IsActive then return end
        
        if not Maid.ESPContainer then
            Maid.ESPContainer = PerceptionESP.Create("ScreenGui", {
                Name = "PerceptionESP",
                Parent = gethui(),
                ResetOnSpawn = false
            })
        end

        if Options.ShowName then
            ESPObject.Name = PerceptionESP.Create("TextLabel", {
                Parent = Maid.ESPContainer,
                Position = UDim2.new(0.5, 0, 0, -11),
                Size = UDim2.new(0, 100, 0, 20),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Code,
                TextSize = 12,
                TextStrokeTransparency = 0,
                TextWrapped = false,
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
                RichText = true
            })
        end

        if Options.ShowBoxes then
            ESPObject.Box = PerceptionESP.Create("Frame", {
                Parent = Maid.ESPContainer,
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0.75,
                BorderSizePixel = 0
            })

            ESPObject.Gradient1 = PerceptionESP.Create("UIGradient", {
                Parent = ESPObject.Box,
                Enabled = true,
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(124, 233, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                }
            })

            ESPObject.Outline = PerceptionESP.Create("UIStroke", {
                Parent = ESPObject.Box,
                Enabled = true,
                Transparency = 0,
                Color = Color3.fromRGB(255, 255, 255),
                LineJoinMode = Enum.LineJoinMode.Miter
            })

            ESPObject.Gradient2 = PerceptionESP.Create("UIGradient", {
                Parent = ESPObject.Outline,
                Enabled = true,
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(124, 233, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                }
            })

            -- Create corner box lines
            ESPObject.LeftTop = PerceptionESP.Create("Frame", {
                Parent = Maid.ESPContainer,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
            ESPObject.LeftSide = PerceptionESP.Create("Frame", {
                Parent = Maid.ESPContainer,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
            ESPObject.RightTop = PerceptionESP.Create("Frame", {
                Parent = Maid.ESPContainer,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
            ESPObject.RightSide = PerceptionESP.Create("Frame", {
                Parent = Maid.ESPContainer,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
            ESPObject.BottomSide = PerceptionESP.Create("Frame", {
                Parent = Maid.ESPContainer,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
            ESPObject.BottomDown = PerceptionESP.Create("Frame", {
                Parent = Maid.ESPContainer,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
            ESPObject.BottomRightSide = PerceptionESP.Create("Frame", {
                Parent = Maid.ESPContainer,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
            ESPObject.BottomRightDown = PerceptionESP.Create("Frame", {
                Parent = Maid.ESPContainer,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
        end

        if Options.ShowHealthbar then
            ESPObject.Healthbar = PerceptionESP.Create("Frame", {
                Parent = Maid.ESPContainer,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0
            })

            ESPObject.BehindHealthbar = PerceptionESP.Create("Frame", {
                Parent = Maid.ESPContainer,
                ZIndex = -1,
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0
            })

            ESPObject.HealthbarGradient = PerceptionESP.Create("UIGradient", {
                Parent = ESPObject.Healthbar,
                Enabled = true,
                Rotation = -90,
                Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(6, 115, 145)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(9, 172, 217)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 251, 255))
                }
            })
        end

        if Options.ShowChams then
            ESPObject.Chams = PerceptionESP.Create("Highlight", {
                Parent = Maid.ESPContainer,
                FillTransparency = 1,
                OutlineTransparency = 0,
                OutlineColor = Color3.fromRGB(255, 255, 255),
                DepthMode = "AlwaysOnTop",
                Adornee = Entity
            })
        end

        if Options.ShowTracers then
            ESPObject.Tracer = PerceptionESP.Create("Frame", {
                Parent = Maid.ESPContainer,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                ZIndex = 0
            })
        end

        if Options.ShowHeadDots then
            ESPObject.HeadDot = PerceptionESP.Create("Frame", {
                Parent = Maid.ESPContainer,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0, 5, 0, 5),
                ZIndex = 2
            })

            ESPObject.HeadDotCorner = PerceptionESP.Create("UICorner", {
                Parent = ESPObject.HeadDot,
                CornerRadius = UDim.new(1, 0)
            })
        end

        if Options.ShowSkeletons then
            ESPObject.SkeletonLines = {
                HeadToTorso = PerceptionESP.CreateSkeletonLine(Maid.ESPContainer, "HeadToTorso"),
                TorsoToLeftArm = PerceptionESP.CreateSkeletonLine(Maid.ESPContainer, "TorsoToLeftArm"),
                TorsoToRightArm = PerceptionESP.CreateSkeletonLine(Maid.ESPContainer, "TorsoToRightArm"),
                TorsoToLeftLeg = PerceptionESP.CreateSkeletonLine(Maid.ESPContainer, "TorsoToLeftLeg"),
                TorsoToRightLeg = PerceptionESP.CreateSkeletonLine(Maid.ESPContainer, "TorsoToRightLeg"),
                LeftArmToForearm = PerceptionESP.CreateSkeletonLine(Maid.ESPContainer, "LeftArmToForearm"),
                RightArmToForearm = PerceptionESP.CreateSkeletonLine(Maid.ESPContainer, "RightArmToForearm"),
                LeftLegToShin = PerceptionESP.CreateSkeletonLine(Maid.ESPContainer, "LeftLegToShin"),
                RightLegToShin = PerceptionESP.CreateSkeletonLine(Maid.ESPContainer, "RightLegToShin")
            }
        end
        
        IsActive = true
    end
    
    local function DestroyESPObjects()
        if not IsActive then return end
        
        for _, Object in pairs(ESPObject) do
            if typeof(Object) == "Instance" then
                Object:Destroy()
            elseif typeof(Object) == "table" then
                for _, SubObject in pairs(Object) do
                    if typeof(SubObject) == "Instance" then
                        SubObject:Destroy()
                    end
                end
            end
        end
        ESPObject = {}
        IsActive = false
    end

    RenderConnection = Services.RunService.RenderStepped:Connect(function()
        if not Entity or not Entity.Parent then
            DestroyESPObjects()
            RenderConnection:Disconnect()
            Maid["CustomESP_" .. CustomId] = nil
            return
        end

        if not IsActive then
            CreateESPObjects()
        end

        -- Get global settings if available, otherwise use defaults
        local Settings = PerceptionESP.CurrentSettings or {
            FontSize = 12,
            FontType = "Code",
            TextScaled = false,
            BoxLineWidth = 1,
            TracerOrigin = "Bottom",
            TracerThickness = 1,
            HeadDotSize = 5,
            SkeletonThickness = 1,
            FadeOutEnabled = false,
            FadeOutDistance = 2500,
            DefaultESPColor = Color3.fromRGB(124, 233, 255)
        }

        local Position, OnScreen = workspace.CurrentCamera:WorldToScreenPoint(Entity.Position)
        
        if OnScreen then
            local Distance = Options.ShowDistance and PerceptionESP.GetDistance(cooltimeout(), Entity) or 0
            local EntityColor = Options.DefaultESPColor or Settings.DefaultESPColor

            local Width, Height = 50, 50
            if Options.ShowBoxes then
                local CloseDistance = 60
                local MaxSize = 4.5
                local ScaleFactor = math.clamp(1 - (Distance / CloseDistance), 0, 0.2)
                local AdjustedSize = MaxSize + MaxSize * ScaleFactor
                Width = AdjustedSize * workspace.CurrentCamera.ViewportSize.Y / (Position.Z * 2)
                Height = Width * 1.5
            end

            -- CHANGED: Use Options.ShowName instead of Settings.ShowName
            if Options.ShowName and ESPObject.Name then
                local NameText = Options.ChosenName or Entity.Name
                if Options.ShowHealth then
                    local Health = PerceptionESP.GetHealth(Entity)
                    NameText = NameText .. " / [" .. Health .. "]"
                end
                if Options.ShowDistance then
                    NameText = NameText .. " / [" .. Distance .. "]"
                end
                ESPObject.Name.Text = NameText
                ESPObject.Name.Position = UDim2.new(0, Position.X, 0, Position.Y - Height / 2 - 9)
                ESPObject.Name.TextSize = Settings.FontSize
                ESPObject.Name.Font = Enum.Font[Settings.FontType]
                ESPObject.Name.TextScaled = Settings.TextScaled
                ESPObject.Name.TextColor3 = EntityColor
                ESPObject.Name.Visible = true -- Always visible when Options.ShowName is true
            end

            -- CHANGED: Use Options.ShowBoxes instead of Settings.ShowBoxes
            if Options.ShowBoxes and ESPObject.Box then
                ESPObject.Box.Position = UDim2.new(0, Position.X - Width / 2, 0, Position.Y - Height / 2)
                ESPObject.Box.Size = UDim2.new(0, Width, 0, Height)
                ESPObject.Box.Visible = true
                
                ESPObject.Gradient1.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, EntityColor),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                }
                ESPObject.Gradient2.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, EntityColor),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                }

                -- Show all corner box elements
                ESPObject.LeftTop.BackgroundColor3 = EntityColor
                ESPObject.LeftTop.Visible = true
                ESPObject.LeftTop.Position = UDim2.new(0, Position.X - Width / 2, 0, Position.Y - Height / 2)
                ESPObject.LeftTop.Size = UDim2.new(0, Width / 5, 0, Settings.BoxLineWidth or 1)

                ESPObject.LeftSide.BackgroundColor3 = EntityColor
                ESPObject.LeftSide.Visible = true
                ESPObject.LeftSide.Position = UDim2.new(0, Position.X - Width / 2, 0, Position.Y - Height / 2)
                ESPObject.LeftSide.Size = UDim2.new(0, Settings.BoxLineWidth or 1, 0, Height / 5)

                ESPObject.RightTop.BackgroundColor3 = EntityColor
                ESPObject.RightTop.Visible = true
                ESPObject.RightTop.Position = UDim2.new(0, Position.X + Width / 2, 0, Position.Y - Height / 2)
                ESPObject.RightTop.Size = UDim2.new(0, Width / 5, 0, Settings.BoxLineWidth or 1)
                ESPObject.RightTop.AnchorPoint = Vector2.new(1, 0)

                ESPObject.RightSide.BackgroundColor3 = EntityColor
                ESPObject.RightSide.Visible = true
                ESPObject.RightSide.Position = UDim2.new(0, Position.X + Width / 2 - (Settings.BoxLineWidth or 1), 0, Position.Y - Height / 2)
                ESPObject.RightSide.Size = UDim2.new(0, Settings.BoxLineWidth or 1, 0, Height / 5)

                ESPObject.BottomSide.BackgroundColor3 = EntityColor
                ESPObject.BottomSide.Visible = true
                ESPObject.BottomSide.Position = UDim2.new(0, Position.X - Width / 2, 0, Position.Y + Height / 2)
                ESPObject.BottomSide.Size = UDim2.new(0, Settings.BoxLineWidth or 1, 0, Height / 5)
                ESPObject.BottomSide.AnchorPoint = Vector2.new(0, 1)

                ESPObject.BottomDown.BackgroundColor3 = EntityColor
                ESPObject.BottomDown.Visible = true
                ESPObject.BottomDown.Position = UDim2.new(0, Position.X - Width / 2, 0, Position.Y + Height / 2)
                ESPObject.BottomDown.Size = UDim2.new(0, Width / 5, 0, Settings.BoxLineWidth or 1)
                ESPObject.BottomDown.AnchorPoint = Vector2.new(0, 1)

                ESPObject.BottomRightSide.BackgroundColor3 = EntityColor
                ESPObject.BottomRightSide.Visible = true
                ESPObject.BottomRightSide.Position = UDim2.new(0, Position.X + Width / 2, 0, Position.Y + Height / 2)
                ESPObject.BottomRightSide.Size = UDim2.new(0, Settings.BoxLineWidth or 1, 0, Height / 5)
                ESPObject.BottomRightSide.AnchorPoint = Vector2.new(1, 1)

                ESPObject.BottomRightDown.BackgroundColor3 = EntityColor
                ESPObject.BottomRightDown.Visible = true
                ESPObject.BottomRightDown.Position = UDim2.new(0, Position.X + Width / 2, 0, Position.Y + Height / 2)
                ESPObject.BottomRightDown.Size = UDim2.new(0, Width / 5, 0, Settings.BoxLineWidth or 1)
                ESPObject.BottomRightDown.AnchorPoint = Vector2.new(1, 1)
            end

            -- CHANGED: Use Options.ShowChams instead of Settings.ShowChams
            if Options.ShowChams and ESPObject.Chams then
                ESPObject.Chams.Enabled = true
                ESPObject.Chams.FillColor = Color3.fromRGB(5, 93, 115)
                ESPObject.Chams.OutlineColor = EntityColor
            end

            -- CHANGED: Use Options.ShowHealthbar instead of Settings.ShowHealthbar
            if Options.ShowHealthbar and ESPObject.Healthbar then
                local Humanoid = PerceptionESP.GetTargetHumanoid(Entity)
                if Humanoid then
                    local Health = Humanoid.Health / Humanoid.MaxHealth
                    ESPObject.Healthbar.Visible = true
                    ESPObject.Healthbar.Position = UDim2.new(0, Position.X - Width / 2 - 6, 0, Position.Y - Height / 2 + Height * (1 - Health))
                    ESPObject.Healthbar.Size = UDim2.new(0, 3, 0, Height * Health)

                    ESPObject.BehindHealthbar.Visible = true
                    ESPObject.BehindHealthbar.Position = UDim2.new(0, Position.X - Width / 2 - 6, 0, Position.Y - Height / 2)
                    ESPObject.BehindHealthbar.Size = UDim2.new(0, 3, 0, Height)
                else
                    ESPObject.Healthbar.Visible = false
                    ESPObject.BehindHealthbar.Visible = false
                end
            end

            -- CHANGED: Use Options.ShowTracers instead of Settings.ShowTracers
            if Options.ShowTracers and ESPObject.Tracer then
                local ScreenSize = workspace.CurrentCamera.ViewportSize
                local TracerOriginPos = Vector2.new(ScreenSize.X / 2, ScreenSize.Y)

                if Settings.TracerOrigin == "Center" then
                    TracerOriginPos = Vector2.new(ScreenSize.X / 2, ScreenSize.Y / 2)
                elseif Settings.TracerOrigin == "Mouse" then
                    local UserInputService = Services.UserInputService
                    TracerOriginPos = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
                end

                local TracerStart = TracerOriginPos
                local TracerEnd = Vector2.new(Position.X, Position.Y)
                local TracerDistance = (TracerStart - TracerEnd).Magnitude

                if TracerDistance == 0 then TracerDistance = 0.01 end

                ESPObject.Tracer.Visible = true
                ESPObject.Tracer.BackgroundColor3 = EntityColor
                ESPObject.Tracer.Position = UDim2.new(0, (TracerStart.X + TracerEnd.X) / 2, 0, (TracerStart.Y + TracerEnd.Y) / 2)
                ESPObject.Tracer.Size = UDim2.new(0, Settings.TracerThickness or 1, 0, TracerDistance)

                local Angle = math.atan2(TracerEnd.Y - TracerStart.Y, TracerEnd.X - TracerStart.X)
                ESPObject.Tracer.Rotation = math.deg(Angle) - 90
            end

            -- CHANGED: Use Options.ShowHeadDots instead of Settings.ShowHeadDots
            if Options.ShowHeadDots and ESPObject.HeadDot then
                local HeadPosition = PerceptionESP.GetTargetHeadPosition(Entity)
                if HeadPosition then
                    local HeadScreenPosition, HeadOnScreen = workspace.CurrentCamera:WorldToScreenPoint(HeadPosition)
                    if HeadOnScreen then
                        ESPObject.HeadDot.Visible = true
                        ESPObject.HeadDot.BackgroundColor3 = EntityColor
                        ESPObject.HeadDot.Position = UDim2.new(0, HeadScreenPosition.X, 0, HeadScreenPosition.Y)
                        ESPObject.HeadDot.Size = UDim2.new(0, Settings.HeadDotSize or 5, 0, Settings.HeadDotSize or 5)
                    else
                        ESPObject.HeadDot.Visible = false
                    end
                else
                    ESPObject.HeadDot.Visible = false
                end
            end

            -- CHANGED: Use Options.ShowSkeletons instead of Settings.ShowSkeletons
            if Options.ShowSkeletons and ESPObject.SkeletonLines then
                local SkeletonParts = PerceptionESP.GetSkeletonParts(Entity)
                
                for _, Line in pairs(ESPObject.SkeletonLines) do
                    Line.Visible = true
                end
                
                -- Render all skeleton connections
                if SkeletonParts.Head and SkeletonParts.Torso then
                    PerceptionESP.RenderSkeletonLine(
                        ESPObject.SkeletonLines.HeadToTorso,
                        SkeletonParts.Head.Position,
                        SkeletonParts.Torso.Position,
                        EntityColor,
                        Settings.SkeletonThickness or 1,
                        true
                    )
                end
                
                if SkeletonParts.Torso and SkeletonParts.LeftArm then
                    PerceptionESP.RenderSkeletonLine(
                        ESPObject.SkeletonLines.TorsoToLeftArm,
                        SkeletonParts.Torso.Position,
                        SkeletonParts.LeftArm.Position,
                        EntityColor,
                        Settings.SkeletonThickness or 1,
                        true
                    )
                end
                
                if SkeletonParts.Torso and SkeletonParts.RightArm then
                    PerceptionESP.RenderSkeletonLine(
                        ESPObject.SkeletonLines.TorsoToRightArm,
                        SkeletonParts.Torso.Position,
                        SkeletonParts.RightArm.Position,
                        EntityColor,
                        Settings.SkeletonThickness or 1,
                        true
                    )
                end
                
                if SkeletonParts.Torso and SkeletonParts.LeftLeg then
                    PerceptionESP.RenderSkeletonLine(
                        ESPObject.SkeletonLines.TorsoToLeftLeg,
                        SkeletonParts.Torso.Position,
                        SkeletonParts.LeftLeg.Position,
                        EntityColor,
                        Settings.SkeletonThickness or 1,
                        true
                    )
                end
                
                if SkeletonParts.Torso and SkeletonParts.RightLeg then
                    PerceptionESP.RenderSkeletonLine(
                        ESPObject.SkeletonLines.TorsoToRightLeg,
                        SkeletonParts.Torso.Position,
                        SkeletonParts.RightLeg.Position,
                        EntityColor,
                        Settings.SkeletonThickness or 1,
                        true
                    )
                end
                
                if SkeletonParts.LeftArm and SkeletonParts.LeftForearm then
                    PerceptionESP.RenderSkeletonLine(
                        ESPObject.SkeletonLines.LeftArmToForearm,
                        SkeletonParts.LeftArm.Position,
                        SkeletonParts.LeftForearm.Position,
                        EntityColor,
                        Settings.SkeletonThickness or 1,
                        true
                    )
                end
                
                if SkeletonParts.RightArm and SkeletonParts.RightForearm then
                    PerceptionESP.RenderSkeletonLine(
                        ESPObject.SkeletonLines.RightArmToForearm,
                        SkeletonParts.RightArm.Position,
                        SkeletonParts.RightForearm.Position,
                        EntityColor,
                        Settings.SkeletonThickness or 1,
                        true
                    )
                end
                
                if SkeletonParts.LeftLeg and SkeletonParts.LeftShin then
                    PerceptionESP.RenderSkeletonLine(
                        ESPObject.SkeletonLines.LeftLegToShin,
                        SkeletonParts.LeftLeg.Position,
                        SkeletonParts.LeftShin.Position,
                        EntityColor,
                        Settings.SkeletonThickness or 1,
                        true
                    )
                end
                
                if SkeletonParts.RightLeg and SkeletonParts.RightShin then
                    PerceptionESP.RenderSkeletonLine(
                        ESPObject.SkeletonLines.RightLegToShin,
                        SkeletonParts.RightLeg.Position,
                        SkeletonParts.RightShin.Position,
                        EntityColor,
                        Settings.SkeletonThickness or 1,
                        true
                    )
                end
            end

            -- Apply fade out if enabled globally (still uses global setting for fade)
            if Settings.FadeOutEnabled then
                local Transparency = math.clamp(Distance / Settings.FadeOutDistance, 0, 1)
                if ESPObject.Name then ESPObject.Name.TextTransparency = Transparency end
                if ESPObject.Box then ESPObject.Box.BackgroundTransparency = 0.75 + Transparency * 0.25 end
                if ESPObject.Outline then ESPObject.Outline.Transparency = Transparency end
                if ESPObject.Healthbar then ESPObject.Healthbar.BackgroundTransparency = Transparency end
                if ESPObject.BehindHealthbar then ESPObject.BehindHealthbar.BackgroundTransparency = Transparency end
                if ESPObject.Tracer then ESPObject.Tracer.BackgroundTransparency = Transparency end
                if ESPObject.HeadDot then ESPObject.HeadDot.BackgroundTransparency = Transparency end
                if ESPObject.SkeletonLines then
                    for _, Line in pairs(ESPObject.SkeletonLines) do
                        Line.BackgroundTransparency = Transparency
                    end
                end
            end

        else
            -- Hide all elements when off screen
            if ESPObject.Name then ESPObject.Name.Visible = false end
            if ESPObject.Box then ESPObject.Box.Visible = false end
            if ESPObject.Healthbar then ESPObject.Healthbar.Visible = false end
            if ESPObject.BehindHealthbar then ESPObject.BehindHealthbar.Visible = false end
            if ESPObject.Tracer then ESPObject.Tracer.Visible = false end
            if ESPObject.HeadDot then ESPObject.HeadDot.Visible = false end
            if ESPObject.Chams then ESPObject.Chams.Enabled = false end
            if ESPObject.LeftTop then ESPObject.LeftTop.Visible = false end
            if ESPObject.LeftSide then ESPObject.LeftSide.Visible = false end
            if ESPObject.RightTop then ESPObject.RightTop.Visible = false end
            if ESPObject.RightSide then ESPObject.RightSide.Visible = false end
            if ESPObject.BottomSide then ESPObject.BottomSide.Visible = false end
            if ESPObject.BottomDown then ESPObject.BottomDown.Visible = false end
            if ESPObject.BottomRightSide then ESPObject.BottomRightSide.Visible = false end
            if ESPObject.BottomRightDown then ESPObject.BottomRightDown.Visible = false end
            if ESPObject.SkeletonLines then
                for _, Line in pairs(ESPObject.SkeletonLines) do
                    Line.Visible = false
                end
            end
        end
    end)

    Maid["CustomESP_" .. CustomId] = RenderConnection
    
    return {
        Disable = function()
            DestroyESPObjects()
            RenderConnection:Disconnect()
            Maid["CustomESP_" .. CustomId] = nil
        end
    }
end

function PerceptionESP.CreateWithFilter(FilterFunction, Options)
	Options = Options or {}

	local ESPController = PerceptionESP.Initialize(Options)
	local OriginalUpdateSettings = ESPController.UpdateSettings

	ESPController.UpdateSettings = function(NewSettings)
		OriginalUpdateSettings(NewSettings)
		if NewSettings.Filter ~= nil then
			FilterFunction = NewSettings.Filter
		end
	end

	ESPController.SetFilter = function(NewFilter)
		FilterFunction = NewFilter
	end

	return ESPController
end

return PerceptionESP
