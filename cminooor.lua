--------------------------------------------------
-- SERVICES
--------------------------------------------------

local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local HttpService=game:GetService("HttpService")

local player=Players.LocalPlayer

--------------------------------------------------
-- TELEPORT AUTO EXECUTE
--------------------------------------------------

if queue_on_teleport then
	queue_on_teleport(game:HttpGet("https://raw.githubusercontent.com/deebee003/deebee003.github.io/refs/heads/main/cminooor.lua"))
elseif syn and syn.queue_on_teleport then
	syn.queue_on_teleport(game:HttpGet("https://raw.githubusercontent.com/deebee003/deebee003.github.io/refs/heads/main/cminooor.lua"))
end

--------------------------------------------------
-- MODULES
--------------------------------------------------

local modules={
	{name="Phase",enabled=false,bind=nil},
	{name="Fly",enabled=false,bind=nil},
	{name="Speed",enabled=false,bind=nil},
	{name="LongJump",enabled=false,bind=nil},
	{name="Backtrack",enabled=false,bind=nil},
	{name="GodMode",enabled=false,bind=nil}
}

--------------------------------------------------
-- BIND SAVE SYSTEM
--------------------------------------------------

local bindFile="adminpanel_binds.json"

local function saveBinds()

	local data={}

	for _,m in pairs(modules) do
		if m.bind then
			data[m.name]=m.bind.Name
		end
	end

	writefile(bindFile,HttpService:JSONEncode(data))

end

local function loadBinds()

	if not isfile(bindFile) then return end

	local data=HttpService:JSONDecode(readfile(bindFile))

	for _,m in pairs(modules) do

		if data[m.name] then
			m.bind=Enum.KeyCode[data[m.name]]
		end

	end

end

loadBinds()

--------------------------------------------------
-- CHARACTER
--------------------------------------------------

local character=player.Character or player.CharacterAdded:Wait()
local humanoid=character:WaitForChild("Humanoid")
local root=character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)

	character=char
	humanoid=char:WaitForChild("Humanoid")
	root=char:WaitForChild("HumanoidRootPart")

end)

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui=Instance.new("ScreenGui")
gui.Parent=player.PlayerGui
gui.ResetOnSpawn=false

local main=Instance.new("Frame")
main.Size=UDim2.new(0,220,0,260)
main.Position=UDim2.new(0.5,-110,0.5,-130)
main.BackgroundColor3=Color3.fromRGB(20,20,20)
main.Visible=false
main.Active=true
main.Draggable=true
main.Parent=gui

--------------------------------------------------
-- MOBILE BUTTON
--------------------------------------------------

local mobileButton=Instance.new("TextButton")
mobileButton.Size=UDim2.new(0,60,0,60)
mobileButton.Position=UDim2.new(1,-70,1,-70)
mobileButton.BackgroundColor3=Color3.fromRGB(120,80,255)
mobileButton.Text="≡"
mobileButton.TextSize=30
mobileButton.Parent=gui

mobileButton.MouseButton1Click:Connect(function()
	main.Visible=not main.Visible
end)

--------------------------------------------------
-- MODULE BUTTONS
--------------------------------------------------

local container=Instance.new("Frame")
container.Size=UDim2.new(1,0,1,0)
container.BackgroundTransparency=1
container.Parent=main

local buttons={}
local bindingModule=nil

for i,m in ipairs(modules) do

	local b=Instance.new("TextButton")
	b.Size=UDim2.new(1,-10,0,30)
	b.Position=UDim2.new(0,5,0,(i-1)*32)
	b.BackgroundColor3=Color3.fromRGB(30,30,30)

	if m.bind then
		b.Text=m.name.." ["..m.bind.Name.."]"
	else
		b.Text=m.name.." [OFF]"
	end

	b.TextColor3=Color3.new(1,1,1)
	b.Parent=container

	buttons[m]=b

--------------------------------------------------
-- LEFT CLICK
--------------------------------------------------

	b.MouseButton1Click:Connect(function()

		if m.name=="LongJump" then

			local vel=Instance.new("BodyVelocity")
			vel.MaxForce=Vector3.new(1e9,1e9,1e9)
			vel.Velocity=(root.CFrame.LookVector*120)+Vector3.new(0,60,0)
			vel.Parent=root
			Debris:AddItem(vel,0.3)
			return

		end

		m.enabled=not m.enabled

		b.Text=m.name.." ["..(m.enabled and "ON" or "OFF").."]"

	end)

--------------------------------------------------
-- RIGHT CLICK BIND
--------------------------------------------------

	b.MouseButton2Click:Connect(function()

		b.Text=m.name.." [Press Key]"
		bindingModule=m

	end)

end

--------------------------------------------------
-- KEY INPUT
--------------------------------------------------

UIS.InputBegan:Connect(function(input,gp)

	if gp then return end

--------------------------------------------------
-- SET BIND
--------------------------------------------------

	if bindingModule and input.UserInputType==Enum.UserInputType.Keyboard then

		bindingModule.bind=input.KeyCode

		buttons[bindingModule].Text =
			bindingModule.name.." ["..input.KeyCode.Name.."]"

		saveBinds()

		bindingModule=nil
		return

	end

--------------------------------------------------
-- RUN BINDS
--------------------------------------------------

	for _,m in pairs(modules) do

		if m.bind and input.KeyCode==m.bind then

			if m.name=="LongJump" then

				local vel=Instance.new("BodyVelocity")
				vel.MaxForce=Vector3.new(1e9,1e9,1e9)
				vel.Velocity=(root.CFrame.LookVector*120)+Vector3.new(0,60,0)
				vel.Parent=root
				Debris:AddItem(vel,0.3)

			else

				m.enabled=not m.enabled

			end

		end

	end

--------------------------------------------------
-- PC GUI TOGGLE
--------------------------------------------------

	if input.KeyCode==Enum.KeyCode.G then
		main.Visible=not main.Visible
	end

end)

--------------------------------------------------
-- VARIABLES
--------------------------------------------------

local flyVelocity
local phaseParts={}
local backtrackSizes={}
local lastHealth=humanoid.Health

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	if not root then return end

--------------------------------------------------
-- PHASE
--------------------------------------------------

if modules[1].enabled then

	for _,part in pairs(workspace:GetPartBoundsInBox(root.CFrame,Vector3.new(4,6,4))) do

		if part:IsA("BasePart") and not part:IsDescendantOf(character) then

			if not phaseParts[part] then
				phaseParts[part]=part.CanCollide
			end

			part.CanCollide=false

		end

	end

else

	for p,state in pairs(phaseParts) do
		if p and p.Parent then
			p.CanCollide=state
		end
	end

	table.clear(phaseParts)

end

--------------------------------------------------
-- FLY (MoveDirection)
--------------------------------------------------

if modules[2].enabled then

	if not flyVelocity then

		flyVelocity=Instance.new("BodyVelocity")
		flyVelocity.MaxForce=Vector3.new(1e9,1e9,1e9)
		flyVelocity.Parent=root

	end

	local dir=humanoid.MoveDirection

	if dir.Magnitude>0 then
		flyVelocity.Velocity=dir*80
	else
		flyVelocity.Velocity=Vector3.zero
	end

else

	if flyVelocity then
		flyVelocity:Destroy()
		flyVelocity=nil
	end

end

--------------------------------------------------
-- SPEED
--------------------------------------------------

if modules[3].enabled then

	local dir=humanoid.MoveDirection

	if dir.Magnitude>0 then
		root.CFrame=root.CFrame+dir*2
	end

end

--------------------------------------------------
-- BACKTRACK
--------------------------------------------------

if modules[5].enabled then

	for _,plr in pairs(Players:GetPlayers()) do

		if plr~=player and plr.Character then

			local hrp=plr.Character:FindFirstChild("HumanoidRootPart")

			if hrp then

				if not backtrackSizes[hrp] then
					backtrackSizes[hrp]=hrp.Size
				end

				hrp.Size=backtrackSizes[hrp]*1.1

			end

		end

	end

else

	for part,size in pairs(backtrackSizes) do
		if part and part.Parent then
			part.Size=size
		end
	end

	table.clear(backtrackSizes)

end

--------------------------------------------------
-- GOD MODE
--------------------------------------------------

if modules[6].enabled then

	if humanoid.Health<lastHealth then

		local enemyClose=false

		for _,plr in pairs(Players:GetPlayers()) do

			if plr~=player and plr.Character then

				local hrp=plr.Character:FindFirstChild("HumanoidRootPart")

				if hrp then
					if (hrp.Position-root.Position).Magnitude<=10 then
						enemyClose=true
						break
					end
				end

			end

		end

		if enemyClose then

			root.CFrame=root.CFrame+Vector3.new(0,30,0)

			task.delay(2,function()

				root.Anchored=true
				task.wait(0.2)
				root.Anchored=false

			end)

		end

	end

	lastHealth=humanoid.Health

end

end)
