--[[
    Swordburst 2 Auto Farm
    By Spencer#0003
]]

shared.settings = {
    mob = "all"; --> Change this to the chosen mob's name if you want to farm a specifc one.
    enabled = true; --> Set to false to disable.
};

repeat wait() until game:IsLoaded();

-- Init

local players = game:GetService("Players");
local replicatedStorage = game:GetService("ReplicatedStorage");
local tweenService = game:GetService("TweenService");
local client = players.LocalPlayer;

local runService = game:GetService("RunService");
local heartbeat = runService.heartbeat;

-- Main Script

local function getClosestMob()
    local distance, mob = math.huge;
    for i, v in next, workspace.Mobs:GetChildren() do
        if (v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Nameplate") and v.PrimaryPart and v.Parent and v:FindFirstChild("Entity") and v.Entity.Health.Value > 0) then
            local distanceFromChar = client:DistanceFromCharacter(v.HumanoidRootPart.Position);
            if (distanceFromChar < distance) then
                if (shared.settings.mob == "all") then
                    distance = distanceFromChar;
                    mob = v;
                elseif (shared.settings.mob == v.Name) then
                    distance = distanceFromChar;
                    mob = v;
                end;
            end;
        end;
    end;

    return mob;
end;

local function getSkill()
    local skill;

    local left = replicatedStorage.Profiles[client.Name].Equip.Left.Value;
    local right = replicatedStorage.Profiles[client.Name].Equip.Right.Value;

    if (left ~= 0 and right ~= 0) then
        skill = "Whirlwind Spin";
    else
        local inventoryId = (left == 0 and right or right == 0 and left);
        local itemName, itemType;

        for i, v in next, replicatedStorage.Profiles[client.Name].Inventory:GetChildren() do
            if (v.Value == inventoryId) then
                itemName = v.Name;
                break;
            end;
        end;

        local item = replicatedStorage.Database.Items:FindFirstChild(itemName);

        if (item) then
            itemType = item:FindFirstChild("Class") and item.Class.Value;
        end;

        if (itemType and itemType == "1HSword") then
            skill = "Sweeping Strike";
        elseif (itemType and itemType == "2HSword") then
            skill = "Downward Smash"
        elseif (itemType and itemType == "Katana") then
            skill = "Leaping Slash";
        else
            skill = "Piercing Dash";
        end;
    end;

    return skill;
end;

local services, crystalForge;
repeat
    for i, v in next, getreg() do
        if (typeof(v) == "table" and rawget(v, "Services")) then
            services = v.Services;
            break;
        end;
    end;

    heartbeat:Wait();
until services;

local rpcKey = getupvalue(services.Combat.Init, 2);

local skill = getSkill();

local function attack(target)
    for i = 1, 4 do
        replicatedStorage.Event:FireServer("Skills", {"UseSkill", skill});
        replicatedStorage.Event:FireServer("Combat", rpcKey, {"Attack", skill, 1, target});
    end;
end;

-- If you complain about this code, go fuck yourself you cunt.

spawn(function()
    while true do
        if (shared.settings.enabled) then
            local mob = getClosestMob();

            if (mob) then
                pcall(function()
                    client.Character.Humanoid:ChangeState(11);
                    tweenService:Create(client.Character.HumanoidRootPart, TweenInfo.new(((client.Character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position)).magnitude / 40), {CFrame = mob.PrimaryPart.CFrame * CFrame.new(0, 20, 0)}):Play();
                end);
            end;
        end;
        wait();
    end;
end);

while true do
    if (shared.settings.enabled) then
        local mob = getClosestMob();
        if (mob and mob:FindFirstChild("HumanoidRootPart") and mob.HumanoidRootPart and (client.Character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).magnitude <= 60) then
            repeat
                attack(mob);
                wait(0.15);
            until not mob or not mob:FindFirstChild("Nameplate") or not mob:FindFirstChild("Healthbar") or not mob:FindFirstChild("Entity");
        end;
    end;
    wait();
end;
