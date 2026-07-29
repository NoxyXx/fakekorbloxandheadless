--[[
    FAKE KORBLOX + HEADLESS (Lokalny skrypt)
    Działa tylko na Twoim ekranie. Inni gracze widzą Cię normalnie.
    Obsługuje R6 i R15.
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ID assetów dla efektów
local HEADLESS_MESH_ID = "rbxassetid://1095708"        -- Niewidzialna głowa
local KORBLOX_MESH_ID = "rbxassetid://101851696"       -- Noga Korblox
local KORBLOX_TEXTURE_ID = "rbxassetid://101851254"    -- Tekstura nogi
local DARK_GREY = Color3.fromRGB(64, 64, 64)           -- Kolor nogi

-- Funkcja usuwająca decal twarzy
local function removeFace(head)
    local face = head:FindFirstChild("face")
    if face then face:Destroy() end
end

-- Funkcja nakładająca efekt Headless
local function applyHeadless(head)
    if not head then return end
    head.Transparency = 1
    head.CanCollide = false
    removeFace(head)

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = HEADLESS_MESH_ID
    mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
    mesh.Parent = head

    head:GetPropertyChangedSignal("Transparency"):Connect(function()
        if head.Transparency ~= 1 then head.Transparency = 1 end
    end)
    head.ChildAdded:Connect(function(child)
        if child.Name == "face" and child:IsA("Decal") then child:Destroy() end
    end)
end

-- Funkcja nakładająca efekt Korblox (R6)
local function applyKorbloxR6(char)
    local rightLeg = char:FindFirstChild("Right Leg")
    if not rightLeg then return end

    for _, child in ipairs(rightLeg:GetChildren()) do
        if child:IsA("SpecialMesh") or child:IsA("CharacterMesh") then
            child:Destroy()
        end
    end

    rightLeg.Color = DARK_GREY
    rightLeg:GetPropertyChangedSignal("Color"):Connect(function()
        if rightLeg.Color ~= DARK_GREY then rightLeg.Color = DARK_GREY end
    end)

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = KORBLOX_MESH_ID
    mesh.TextureId = KORBLOX_TEXTURE_ID
    mesh.Scale = Vector3.new(1, 1, 1)
    mesh.Parent = rightLeg
end

-- Funkcja nakładająca efekt Korblox (R15)
local function applyKorbloxR15(char)
    local ru = char:FindFirstChild("RightUpperLeg")
    local rl = char:FindFirstChild("RightLowerLeg")
    local rf = char:FindFirstChild("RightFoot")

    if ru and rl and rf then
        rl.Transparency = 1
        rf.Transparency = 1
        ru.MeshId = "rbxassetid://902942096"
        ru.TextureId = "rbxassetid://902843398"
        ru.Color = Color3.new(1, 1, 1)
        ru.Transparency = 0
    end
end

-- Główna funkcja aplikująca efekty
local function applyEffects()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local head = char:FindFirstChild("Head")
    if head then applyHeadless(head) end

    if hum.RigType == Enum.HumanoidRigType.R15 then
        applyKorbloxR15(char)
    else
        applyKorbloxR6(char)
    end
end

-- Uruchom przy odrodzeniu i co 0.5s (na wypadek resetu)
player.CharacterAdded:Connect(applyEffects)
task.spawn(function()
    while true do
        if player.Character then applyEffects() end
        task.wait(0.5)
    end
end)
