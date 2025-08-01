--// Services
local Players     = cloneref(game:GetService("Players"))
local RunService  = cloneref(game:GetService("RunService"))
local TextService = game:GetService("TextService")
local Teams       = game:GetService("Teams")

local ESPLibrary = {}

-- Configuration settings
ESPLibrary.Settings = {
    Enabled = false,
    FontSize = 24,
    Box = {
        Enabled = false,
        ShowCorners = false,
        ShowSides = false,
        UseTeamColor = false,
        DefaultColor = Color3.fromRGB(0, 200, 200)
    },
    Text = {
        ShowName = false,
        ShowHealth = false,
        ShowDistance = false,
        UseTeamColor = false,
        DefaultColor = Color3.new(1, 1, 1)
    },
    Highlight = {
        Enabled = false,
        UseTeamColor = false,
        DefaultFillColor = Color3.fromRGB(100, 100, 100),
        DefaultOutlineColor = Color3.fromRGB(0, 200, 200)
    }
}

ESPLibrary.ExistantPlayers = {}
ESPLibrary.RunningThreads = {}
ESPLibrary.XenithESP = nil

---------------------------------------------------------------------------------------------------
-- Helper Functions
---------------------------------------------------------------------------------------------------
function ESPLibrary.CreateInstance(className, props)
    if typeof(className) ~= "string" then return end
    local inst = Instance.new(className)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

function ESPLibrary.GetTeamColor(player)
    if player.Team and player.Team.TeamColor then
        return player.Team.TeamColor.Color
    end
    return ESPLibrary.Settings.Box.DefaultColor
end

function ESPLibrary.LerpColorSequence(a, b, alpha)
    local keys = {}
    for i = 1, #a.Keypoints do
        local ak, bk = a.Keypoints[i], b.Keypoints[i]
        keys[i] = ColorSequenceKeypoint.new(ak.Time, ak.Value:Lerp(bk.Value, alpha))
    end
    return ColorSequence.new(keys)
end

---------------------------------------------------------------------------------------------------
-- Batch toggle implementations (unchanged)
---------------------------------------------------------------------------------------------------
-- ... *[keep all of your ToggleESP, ToggleBox, ToggleCorners, ToggleSides, etc. exactly as-is]*

---------------------------------------------------------------------------------------------------
-- Update colors/text helpers
---------------------------------------------------------------------------------------------------
-- ... *[keep UpdateAllColors, UpdateAllText, UpdatePlayerColors, UpdatePlayerText exactly as-is]*

---------------------------------------------------------------------------------------------------
-- Per-frame updater (NEW!)
---------------------------------------------------------------------------------------------------
function ESPLibrary:UpdateOne(plr, data)
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not self.Settings.Enabled or not hrp then
        data.MainFrame.Visible = false
        if data.NameLabel then data.NameLabel.Visible = false end
        return
    end

    -- world → screen
    local cam = workspace.CurrentCamera
    local screenPt, onScreen = cam:WorldToScreenPoint(hrp.Position)
    if not onScreen then
        data.MainFrame.Visible = false
        data.NameLabel.Visible = false
        return
    end

    -- show & position frame
    data.MainFrame.Visible = true
    data.MainFrame.Position = UDim2.new(0, screenPt.X, 0, screenPt.Y)

    -- scale box with distance
    local dist      = (cam.CFrame.Position - hrp.Position).Magnitude
    local scaleFact = math.clamp(1 - (dist/60), 0, .2)
    local sizeBase  = 4.5 + 4.5 * scaleFact
    local w         = sizeBase * cam.ViewportSize.Y / (screenPt.Z * 1.7)
    local h         = w * 1.5
    data.MainFrame.Size      = UDim2.new(0, w, 0, h)

    -- update text & color
    self:UpdatePlayerText(plr, data)
    self:UpdatePlayerColors(plr, data)

    -- position text above
    local textOffsetY = -h/2 - 10
    data.NameLabel.Position = UDim2.new(0, screenPt.X, 0, screenPt.Y + textOffsetY)

    -- text sizing
    local lbl = data.NameLabel
    local sf = math.clamp(30 / math.max(dist,0.1), .5, 1.5)
    local bounds = TextService:GetTextSize(lbl.Text, self.Settings.FontSize, lbl.Font, Vector2.new(1e5,1e5))
    lbl.Size     = UDim2.new(0, math.clamp(bounds.X*sf,120,240),
                             0, math.clamp(bounds.Y*sf,24,48))
    lbl.TextSize = 24 * sf
end

---------------------------------------------------------------------------------------------------
-- Build all UI bits + chams for one player
---------------------------------------------------------------------------------------------------
function ESPLibrary.CreateESPComponents(plr)
    if ESPLibrary.ExistantPlayers[plr] then return end
    ESPLibrary.ExistantPlayers[plr] = {}
    local data = ESPLibrary.ExistantPlayers[plr]

    -- Main container
    local frame = ESPLibrary.CreateInstance("Frame", {
        Parent               = ESPLibrary.XenithESP,
        Name                 = plr.Name.."_ESP",
        BackgroundColor3     = Color3.fromRGB(0,0,0),
        BackgroundTransparency = ESPLibrary.Settings.Box.Enabled and 0.8 or 1,
        AnchorPoint          = Vector2.new(0.5,0.5),
        Size                 = UDim2.new(0,180,0,250),
        Visible              = true,
    })
    data.MainFrame = frame
    ESPLibrary.CreateInstance("UICorner", {Parent = frame, CornerRadius = UDim.new(0,1)})

    -- Frame stroke
    local frameStroke = ESPLibrary.CreateInstance("UIStroke", {
        Parent    = frame,
        Color     = ESPLibrary.Settings.Box.UseTeamColor and ESPLibrary.GetTeamColor(plr) or ESPLibrary.Settings.Box.DefaultColor,
        Thickness = 1,
        Transparency = ESPLibrary.Settings.Box.Enabled and 0 or 1,
    })
    data.FrameStroke = frameStroke

    -- Box gradient
    local boxGrad = ESPLibrary.CreateInstance("UIGradient", {
        Parent = frame,
        Color  = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200,0,0)),
        }
    })
    data.UIGradientMainFrame = boxGrad

    local corners = {
        { "CornerTL", UDim2.new(0.015,0,0.010,0), UDim2.new(0,0,0,0), Vector2.new(0,0) },
        { "CornerBL", UDim2.new(0.015,0,0.010,0), UDim2.new(0,0,1,0), Vector2.new(0,1) },
        { "CornerTR", UDim2.new(0.015,0,0.010,0), UDim2.new(1,0,0,0), Vector2.new(1,0) },
        { "CornerBR", UDim2.new(0.015,0,0.010,0), UDim2.new(1,0,1,0), Vector2.new(1,1) },
    }
    for _, info in ipairs(corners) do
        local name, size, pos, anchor = unpack(info)
        local box = ESPLibrary.CreateInstance("Frame", {
            Parent            = frame,
            Name              = name,
            Size              = size,
            Position          = pos,
            AnchorPoint       = anchor,
            ZIndex            = 3,
            BackgroundColor3  = ESPLibrary.Settings.Box.UseTeamColor and ESPLibrary.GetTeamColor(plr) or ESPLibrary.Settings.Box.DefaultColor,
            Visible           = ESPLibrary.Settings.Box.ShowCorners and ESPLibrary.Settings.Box.Enabled,
        })
        ESPLibrary.CreateInstance("UIStroke", {Parent = box, Color = Color3.new(0,0,0), Thickness = 0.6})
        data[name] = box
    end

    -- Side bars
    local sides = {
        { "SideTL_H", UDim2.new(0.1,0,0.01,0), UDim2.new(0,0,0,0), Vector2.new(0,0) },
        { "SideTL_V", UDim2.new(0.01,0,0.1,0), UDim2.new(0,0,0,0), Vector2.new(0,0) },
        { "SideTR_H", UDim2.new(0.1,0,0.01,0), UDim2.new(1,0,0,0), Vector2.new(1,0) },
        { "SideTR_V", UDim2.new(0.01,0,0.1,0), UDim2.new(1,0,0,0), Vector2.new(1,0) },
        { "SideBL_H", UDim2.new(0.1,0,0.01,0), UDim2.new(0,0,1,0), Vector2.new(0,1) },
        { "SideBL_V", UDim2.new(0.01,0,0.1,0), UDim2.new(0,0,1,0), Vector2.new(0,1) },
        { "SideBR_H", UDim2.new(0.1,0,0.01,0), UDim2.new(1,0,1,0), Vector2.new(1,1) },
        { "SideBR_V", UDim2.new(0.01,0,0.1,0), UDim2.new(1,0,1,0), Vector2.new(1,1) },
    }
    for _, info in ipairs(sides) do
        local name, size, pos, anchor = unpack(info)
        local bar = ESPLibrary.CreateInstance("Frame", {
            Parent            = frame,
            Name              = name,
            Size              = size,
            Position          = pos,
            AnchorPoint       = anchor,
            ZIndex            = 2,
            BackgroundColor3  = ESPLibrary.Settings.Box.UseTeamColor and ESPLibrary.GetTeamColor(plr) or ESPLibrary.Settings.Box.DefaultColor,
            Visible           = ESPLibrary.Settings.Box.ShowSides and ESPLibrary.Settings.Box.Enabled,
        })
        ESPLibrary.CreateInstance("UIStroke", {Parent = bar, Color = Color3.new(0,0,0), Thickness = 0.6})
        data[name] = bar
    end
    -- Text label + gradient
    local nameLabel = ESPLibrary.CreateInstance("TextLabel", {
        Parent                 = ESPLibrary.XenithESP,
        Name                   = plr.Name.."_TextLabel",
        BackgroundTransparency = 1,
        Text                   = "",
        TextColor3             = Color3.fromRGB(255,255,255),
        TextStrokeTransparency = 0.6,
        Font                   = Enum.Font.Code,
        TextWrapped            = false,
        TextScaled             = false,
        AutomaticSize          = Enum.AutomaticSize.None,
        AnchorPoint            = Vector2.new(0.5,1),
        Position               = UDim2.new(0.5,0,0.5,0),
        ZIndex                 = 10,
        Visible                = false,
    })
    data.NameLabel = nameLabel

    local textGrad = ESPLibrary.CreateInstance("UIGradient", {
        Parent = nameLabel,
        Color  = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
        }
    })
    data.TextGradient = textGrad

    -- Highlight
    local highlight = ESPLibrary.CreateInstance("Highlight", {
        Parent            = workspace,
        Adornee           = plr.Character or nil,
        FillColor         = ESPLibrary.Settings.Highlight.UseTeamColor and ESPLibrary.GetTeamColor(plr) or ESPLibrary.Settings.Highlight.DefaultFillColor,
        OutlineColor      = ESPLibrary.Settings.Highlight.UseTeamColor and ESPLibrary.GetTeamColor(plr) or ESPLibrary.Settings.Highlight.DefaultOutlineColor,
        FillTransparency  = 0.4,
        OutlineTransparency = 0.2,
        Enabled           = ESPLibrary.Settings.Highlight.Enabled,
    })
    data.Highlight = highlight

    -- When character respawns, re-adorn and restart loop
    plr.CharacterAdded:Connect(function(char)
        -- update highlight
        highlight.Adornee = char

        -- clean up old render thread
        if ESPLibrary.RunningThreads[plr] then
            ESPLibrary.RunningThreads[plr]:Disconnect()
            ESPLibrary.RunningThreads[plr] = nil
        end

        -- kick off fresh loop
        ESPLibrary.RunningThreads[plr] = RunService.RenderStepped:Connect(function()
            ESPLibrary:UpdateOne(plr, data)
        end)
    end)

    -- Also handle CharacterRemoving to hide things immediately
    plr.CharacterRemoving:Connect(function()
        data.MainFrame.Visible = false
        data.NameLabel.Visible = false
    end)

    -- If they already have a character, start immediately
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        ESPLibrary.RunningThreads[plr] = RunService.RenderStepped:Connect(function()
            ESPLibrary:UpdateOne(plr, data)
        end)
    end
end

function ESPLibrary.DeleteESPComponents(plr)
    local data = ESPLibrary.ExistantPlayers[plr]
    if not data then return end
    if data.MainFrame then data.MainFrame:Destroy() end
    if data.NameLabel then data.NameLabel:Destroy() end
    if data.Highlight then data.Highlight:Destroy() end
    if ESPLibrary.RunningThreads[plr] then
        ESPLibrary.RunningThreads[plr]:Disconnect()
        ESPLibrary.RunningThreads[plr] = nil
    end
    ESPLibrary.ExistantPlayers[plr] = nil
end

---------------------------------------------------------------------------------------------------
-- Render ESP for a player
---------------------------------------------------------------------------------------------------
function ESPLibrary.RenderESP(plr)
    local data = ESPLibrary.ExistantPlayers[plr]
    if not data then return end
    local chr = plr.Character
    if not chr then return end
    local hrp = chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    data.RootPart = hrp

    ESPLibrary.RunningThreads[plr] = RunService.RenderStepped:Connect(function()
        if not ESPLibrary.Settings.Enabled then
            data.MainFrame.Visible = false
            data.NameLabel.Visible = false
            return
        end
        
        local cam, frame = workspace.CurrentCamera, data.MainFrame
        local screenPt, onScreen = cam:WorldToScreenPoint(hrp.Position)
        if not onScreen then 
            frame.Visible = false
            data.NameLabel.Visible = false
            return 
        end
        
        frame.Visible = true
        frame.Position = UDim2.new(0, screenPt.X, 0, screenPt.Y)

        -- box sizing
        local dist      = (cam.CFrame.Position - hrp.Position).Magnitude
        local scaleFact = math.clamp(1 - (dist/60), 0, .2)
        local sizeBase  = 4.5 + 4.5 * scaleFact
        local w         = sizeBase * cam.ViewportSize.Y / (screenPt.Z * 1.7)
        local h         = w * 1.5
        frame.Size      = UDim2.new(0, w, 0, h)

        -- Update text
        ESPLibrary:UpdatePlayerText(plr, data)
        
        -- Position text label independently above the player
        local textOffsetY = -h/2 - 10 -- Position above the box
        data.NameLabel.Position = UDim2.new(0, screenPt.X, 0, screenPt.Y + textOffsetY)
        
        -- text sizing
        local lbl = data.NameLabel
        local sf = math.clamp(30 / math.max(dist,0.1), .5, 1.5)
        local bounds = TextService:GetTextSize(lbl.Text, ESPLibrary.Settings.FontSize, lbl.Font, Vector2.new(1e5,1e5))
        lbl.Size     = UDim2.new(0, math.clamp(bounds.X*sf,120,240),
                                 0, math.clamp(bounds.Y*sf,24,48))
        lbl.TextSize = 24 * sf
    end)
end

---------------------------------------------------------------------------------------------------
-- Initialize everything
---------------------------------------------------------------------------------------------------
function ESPLibrary.InitializeESP()
    local old = gethui():FindFirstChild("XenithESP")
    if old then old:Destroy() end
    ESPLibrary.XenithESP       = ESPLibrary.CreateInstance("ScreenGui", {
        Parent = gethui(), Name = "XenithESP", Enabled = ESPLibrary.Settings.Enabled
    })
    ESPLibrary.ExistantPlayers = {}
    ESPLibrary.RunningThreads  = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer then
            ESPLibrary.CreateESPComponents(p)
            ESPLibrary.RenderESP(p)
        end
    end
    Players.PlayerAdded:Connect(function(p)
        if p ~= Players.LocalPlayer then
            ESPLibrary.CreateESPComponents(p)
            ESPLibrary.RenderESP(p)
        end
    end)
    Players.PlayerRemoving:Connect(function(p)
        if p ~= Players.LocalPlayer then
            ESPLibrary.DeleteESPComponents(p)
        end
    end)
end


-- Main toggles
function ESPLibrary:Enable()
    self:ToggleESP(true)
end

function ESPLibrary:Disable()
    self:ToggleESP(false)
end

-- Box controls
function ESPLibrary:ShowBox()
    self:ToggleBox(true)
end

function ESPLibrary:HideBox()
    self:ToggleBox(false)
end

function ESPLibrary:ShowCorners()
    self:ToggleCorners(true)
end

function ESPLibrary:HideCorners()
    self:ToggleCorners(false)
end

function ESPLibrary:ShowSides()
    self:ToggleSides(true)
end

function ESPLibrary:HideSides()
    self:ToggleSides(false)
end

-- Text controls
function ESPLibrary:ShowName()
    self:ToggleName(true)
end

function ESPLibrary:HideName()
    self:ToggleName(false)
end

function ESPLibrary:ShowHealth()
    self:ToggleHealth(true)
end

function ESPLibrary:HideHealth()
    self:ToggleHealth(false)
end

function ESPLibrary:ShowDistance()
    self:ToggleDistance(true)
end

function ESPLibrary:HideDistance()
    self:ToggleDistance(false)
end

function ESPLibrary:SetFontSize(VALUE)
    ESPLibrary.Settings.FontSize = VALUE
end

-- Team color controls
function ESPLibrary:UseTeamColors()
    self:ToggleBoxTeamColor(true)
    self:ToggleTextTeamColor(true)
    self:ToggleHighlightTeamColor(true)
end

function ESPLibrary:UseDefaultColors()
    self:ToggleBoxTeamColor(false)
    self:ToggleTextTeamColor(false)
    self:ToggleHighlightTeamColor(false)
end

-- Highlight controls
function ESPLibrary:ShowHighlight()
    self:ToggleHighlight(true)
end

function ESPLibrary:HideHighlight()
    self:ToggleHighlight(false)
end
-- Initialize on load
ESPLibrary.InitializeESP()

return ESPLibrary
