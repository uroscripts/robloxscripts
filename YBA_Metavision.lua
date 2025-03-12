local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TS = game:GetService("TweenService")
local MetaActivated = false
local Enemies = {}
local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")

local function FXBillCreate(Object)
	if Object:FindFirstChild(Object.Name.."Billboard") then
		return
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Parent = Object
	billboard.Adornee = Object
	billboard.Size = UDim2.new(10, 0, 10, 0)
	billboard.Name = Object.Name.."Billboard"
	billboard.LightInfluence = 0
	billboard.Brightness = 2
	billboard.AlwaysOnTop = true
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Parent = billboard
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Size = UDim2.new(1, 0, 0.1, 0)
	textLabel.Position = UDim2.new(0.5, 0, 0.1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextScaled = true
	textLabel.Text = Object.Name
	textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	textLabel.FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json")
	
	local imgLabel = Instance.new("ImageLabel")
	imgLabel.Parent = billboard
	imgLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imgLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	imgLabel.Size = UDim2.new(0.7, 0, 0.7, 0)
	imgLabel.BackgroundTransparency = 1
	imgLabel.Image = "rbxassetid://105536873849014"
end

-- Функция для создания BillboardGui
local function createBillboard(parent, name, size, offset)
	local bill = Instance.new("BillboardGui")
	bill.Parent = parent
	bill.Name = name
	bill.Size = size
	bill.StudsOffset = offset
	bill.AlwaysOnTop = true

	local label = Instance.new("TextLabel")
	label.Parent = bill
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Position = UDim2.new(0.5, 0, 0.5, 0)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.TextScaled = true
	label.FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json")

	return bill, label
end

-- Функция для создания Highlight
local function createHighlight(parent)
	local highlight = Instance.new("Highlight")
	highlight.Parent = parent
	highlight.Name = "ESPHighlight"
	highlight.FillTransparency = 0.2
	highlight.OutlineTransparency = 0
	highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.Enabled = true
	return highlight
end

-- Включение / выключение Metavision
UIS.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.RightShift and not gameProcessed then
		if not MetaActivated then
			local metacc = Instance.new("ColorCorrectionEffect")
			metacc.Parent = Lighting
			metacc.Name = "Metavision"

			TS:Create(metacc, TweenInfo.new(0.2), {
				Saturation = -0.2,
				Brightness = -0.15,
				Contrast = -0.3,
				TintColor = Color3.fromRGB(49, 122, 255)
			}):Play()
			
			MetaActivated = true
			
			if HRP.Parent:FindFirstChild("MetaHL") then return end
			local HL = Instance.new("Highlight")
			HL.Parent = HRP.Parent
			HL.Name = "MetaHL"
			HL.FillColor = Color3.fromRGB(161, 242, 255)
			HL.OutlineColor = Color3.fromRGB(34, 63, 255)
		else
			local metacc = Lighting:FindFirstChild("Metavision")
			if metacc then
				TS:Create(metacc, TweenInfo.new(0.2), {
					Saturation = 0,
					Brightness = 0,
					Contrast = 0,
					TintColor = Color3.fromRGB(255, 255, 255)
				}):Play()

				task.wait(0.2)
				metacc:Destroy()
			end
			
			if HRP.Parent:FindFirstChild("MetaHL") then
				HRP.Parent:FindFirstChild("MetaHL"):Destroy()
			end
			
			MetaActivated = false
		end
	end
end)

-- Основной цикл обновления Metavision
task.spawn(function()
	while task.wait() do
		if MetaActivated then
			TS:Create(workspace.CurrentCamera, TweenInfo.new(0.2), { FieldOfView = 100 }):Play()

			for _, enemy in ipairs(Enemies) do
				task.spawn(function()
					if not enemy.Parent then return end
					local head, hrp = enemy:FindFirstChild("Head"), enemy:FindFirstChild("HumanoidRootPart")
					if not (head and hrp) then return end
					
					-- Информация о блоке
					local infoBill = head:FindFirstChild("Info") or createBillboard(head, "Info", UDim2.new(4, 0, 2, 0), Vector3.new(0, 3, 0))
					local label = infoBill:FindFirstChild("TextLabel")

					if enemy:FindFirstChild("Blocking_Capacity") then
						local blockValue = enemy.Blocking_Capacity.Value
						label.Text = blockValue > 0 and ("Blocking: " .. tostring(blockValue)) or ""
					else
						label.Text = ""
					end

					infoBill.Enabled = true

					-- Информация о здоровье
					local healthBill = hrp:FindFirstChild("CharInfo") or createBillboard(hrp, "CharInfo", UDim2.new(4, 0, 4, 0), Vector3.new(-3, 1, 0))
					healthBill:FindFirstChild("TextLabel").Text = "Health: " ..math.floor(enemy.Health.Value)
					healthBill.Enabled = true

					-- Подсветка
					local highlight = enemy:FindFirstChild("ESPHighlight") or createHighlight(enemy)
					highlight.Enabled = true
				end)
			end
		else
			TS:Create(workspace.CurrentCamera, TweenInfo.new(0.2), { FieldOfView = 70 }):Play()

			for _, enemy in ipairs(Enemies) do
				if enemy.Parent then
					local infoBill = enemy:FindFirstChild("Head") and enemy.Head:FindFirstChild("Info")
					if infoBill then infoBill.Enabled = false end

					local healthBill = enemy:FindFirstChild("HumanoidRootPart") and enemy.HumanoidRootPart:FindFirstChild("CharInfo")
					if healthBill then healthBill.Enabled = false end

					local highlight = enemy:FindFirstChild("ESPHighlight")
					if highlight then highlight.Enabled = false end
				end
			end
		end
	end
end)

-- Добавление врагов в список при их появлении
workspace.Living.ChildAdded:Connect(function(child)
	if child:IsA("Model") and child:FindFirstChild("Humanoid") and not child:GetAttribute("Money") and child ~= Player.Character then
		table.insert(Enemies, child)

		child.Humanoid.Died:Connect(function()
			local index = table.find(Enemies, child)
			if index then
				table.remove(Enemies, index)
			end
		end)
	end
end)

workspace.IgnoreInstances.ChildAdded:Connect(function(child)
	if MetaActivated == false then return end
	if child:IsA("Model") or child:IsA("Part") then
		if child.Name == "Model" or child.Name == "Part" or child.Name == "Fog" or child.Name == "SpeedLines"..Char.Name or child.Name == "GroundShockwave" then
			return
		end
		FXBillCreate(child)
	end
end)

Player.CharacterAdded:Connect(function(newChar)
	Char = newChar
	HRP = Char:WaitForChild("HumanoidRootPart") -- Обновляем HRP для работы с новым персонажем
	if MetaActivated == true then
		if HRP.Parent:FindFirstChild("MetaHL") then return end
		local HL = Instance.new("Highlight")
		HL.Parent = HRP.Parent
		HL.Name = "MetaHL"
		HL.FillColor = Color3.fromRGB(161, 242, 255)
		HL.OutlineColor = Color3.fromRGB(34, 63, 255)
	end
end)


for _, model in workspace.Living:GetChildren() do
	if model:IsA("Model") and model:FindFirstChild("Humanoid") and not model:GetAttribute("Money") and model ~= Player.Character then
		table.insert(Enemies, model)
		model.Humanoid.Died:Connect(function()
			local index = table.find(Enemies, model)
			if index then
				table.remove(Enemies, index)
			end
		end)
	end
end

