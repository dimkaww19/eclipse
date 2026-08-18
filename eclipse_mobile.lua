-- ECLIPSE v2 Mobile — Delta Executor (Android)
-- Адаптировано для экранов ~748x360

local function eclipseLog(msg)
    pcall(function() warn("[ECLIPSE-M] " .. tostring(msg)) end)
end
eclipseLog("Starting mobile...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local RepStorage = game:GetService("ReplicatedStorage")
local VirtualUser = nil
pcall(function() VirtualUser = game:GetService("VirtualUser") end)
local WS = game:GetService("Workspace")
local Camera = WS.CurrentCamera

pcall(function()
    for _, p in ipairs({LocalPlayer:WaitForChild("PlayerGui"), game:GetService("CoreGui")}) do
        local old = p:FindFirstChild("Eclipse_Internal")
        if old then old:Destroy() task.wait(0.1) end
    end
end)

eclipseLog("Services loaded")

-- ========== SHARED STATE ==========
local S = {}
if getgenv then getgenv().S = S end
S.scriptActive = true
S.menuVisible = false
S.isWaitingBind = false
S.connections = {}
S.espEnabled = false
S.showHealth = true
S.showDistance = true
S.friendsOnly = false
S.fbEnabled = false
S.wallClipEnabled = false
S.afkEnabled = false
S.afkThread = nil
S.antiRecoilEnabled = false
S.antiRecoilStrength = 0.7
S.lastAimCF = nil
S.flyEnabled = false
S.flyFakePart = nil
S.flySpeed = 60
S.flyBV = nil
S.flyBG = nil
S.noclipEnabled = false
S.noclipOrigCollisions = {}
S.vehSpeedEnabled = false
S.vehSpeedMult = 2.0
S.vehOrigSpeeds = {}
S.espCache = {}
S.currentTab = "Visuals"
S.speedBoostEnabled = false
S.speedBoostMult = 2
S.jumpBoostEnabled = false
S.jumpBoostMult = 2
S.origWalkSpeed = 16
S.origJumpPower = 50
S.espGradient = false
S.espGradientMode = "outline"
S.espGradientRoles = {Police=true, Civilian=true, Friend=true, Armed=true}
S.fovGradient = false
S.carESP = false
S.carESPCache = {}
S.lockedTarget = nil
S.FOVCircle = nil
S.threatLines = false
S.threatLineCache = {}
S.threatLineArmed = true
S.threatLineWanted = true
S.threatLinePolice = false
S.espRoleFilter = {Police = true, Civilian = true, Friend = true, Armed = true}
S.autoTablet = false
S.autoTabletInterval = 5
S.tabletSlot = 6
S.taserTP = false
S.lang = "ru"
S.langLabels = {}
S.toggleRegistry = {}
S.menuAccentColor = Color3.fromRGB(168,85,247)
S.toggleActiveColor = Color3.fromRGB(168,85,247)

S.ESPColors = {
    Police = Color3.fromRGB(0, 120, 255),
    Civilian = Color3.fromRGB(255, 255, 255),
    Friend = Color3.fromRGB(0, 255, 120),
    Armed = Color3.fromRGB(255, 60, 60),
}

-- ========== ПЕРЕВОДЫ ==========
local L = {
    ru = {
        esp_players = "ESP Игроков", fullbright = "FullBright", esp_cars = "ESP Машин",
        threat_lines = "Линии угроз", armed = "Вооружённые", wanted = "Разыскиваемые",
        police_lines = "Полиция", police = "Полиция", civilian = "Гражданские",
        friends = "Друзья", armed_filter = "Вооружённые",
        wall_clip = "Сквозь стены", fly = "Полёт", noclip = "Ноклип",
        car_speed = "Скорость авто", speed_boost = "Ускорение", high_jump = "Высокий прыжок",
        fly_speed = "Скорость полёта", speed_multi = "Множитель скорости",
        run_speed = "Скорость бега", jump_power = "Сила прыжка",
        rejoin = "Реджоин", rejoin_btn = "РЕДЖОИН",
        anti_afk = "Анти-АФК", cam_zoom = "Зум камеры",
        auto_tablet = "Авто планшет", scan_interval = "Интервал (сек)",
        tablet_slot = "Слот планшета", taser_tp = "Тазер ТП", taser_btn = "ТАЗЕР",
        tab_farm = "Фарм",
        fov_color = "Цвет круга FOV",
        auto_farm = "Авто фарм", farm_rings = "Контрабанда", farm_status_buy = "Покупаю", farm_status_sell = "Продаю...", farm_status_launder = "Отмываю...", farm_status_walk = "Лечу к точке...", farm_cycles = "Циклов",
        aimbot = "Аимбот", aim_part = "Часть тела", toggle_btn = "Сменить",
        fov_circle = "Круг FOV", smoothness = "Плавность",
        max_dist = "Макс. дистанция", dist_btn = "Далее",
        wall_check = "Проверка стен", team_check = "Проверка команды",
        target_lock = "Захват цели", prediction = "Предсказание",
        anti_recoil = "Анти-отдача", recoil_comp = "Компенсация %",
        esp_visual_settings = "Настройки ESP и визуалов",
        esp_gradient = "Градиент ESP", fov_gradient = "Градиент FOV",
        mode_outline = "Режим: Обводка", mode_fill = "Режим: Заливка", switch_btn = "Сменить",
        role_police = "Полиция", role_civilian = "Гражданский",
        role_friend = "Друг", role_armed = "Вооружённый",
        settings_title = "Настройки интерфейса",
        accent_color = "Цвет акцента меню", toggle_color = "Цвет тумблеров",
        bg_color = "Цвет фона", row_color = "Цвет элементов",
        language = "Язык", lang_ru = "Русский", lang_en = "English",
        on = "ВКЛ", off = "ВЫКЛ",
        notif_scanning = "Сканирование...", notif_remotes_nf = "Ремоуты не найдены",
        notif_no_target = "Цель не найдена", notif_color_upd = "обновлён",
        notif_menu_color = "Цвет меню обновлён", notif_toggle_color = "Цвет тумблеров обновлён",
        at_title = "АВТО ПЛАНШЕТ", at_timeout = "Таймаут",
        at_wanted = "Розыск", at_warrant = "ОРДЕР", at_clean = "Чисто",
        at_warrant_notif = "ОРДЕР",
        head = "Голова", upper_torso = "Грудь", torso = "Торс",
        lines_for = "Линии для:",
        tab_visuals = "Визуалы", tab_movement = "Движ.", tab_misc = "Разное",
        tab_aimbot = "Аимбот", tab_colors = "Цвета", tab_settings = "Настр.", tab_info = "Инфо",
        info_channel = "Телеграм канал:", info_link = "Ссылка: https://t.me/eclipse_script", info_copy_hint = "Скопируй ссылку и открой в браузере",
    },
    en = {
        esp_players = "Player ESP", fullbright = "FullBright", esp_cars = "Car ESP",
        threat_lines = "Threat Lines", armed = "Armed", wanted = "Wanted",
        police_lines = "Police", police = "Police", civilian = "Civilian",
        friends = "Friends", armed_filter = "Armed",
        wall_clip = "Wall Clip", fly = "Fly", noclip = "Noclip",
        car_speed = "Car Speed", speed_boost = "Speed Boost", high_jump = "High Jump",
        fly_speed = "Fly Speed", speed_multi = "Speed Multi",
        run_speed = "Run Speed", jump_power = "Jump Power",
        rejoin = "Rejoin", rejoin_btn = "REJOIN",
        anti_afk = "Anti-AFK", cam_zoom = "Camera Zoom",
        auto_tablet = "Auto Tablet", scan_interval = "Scan Interval (s)",
        tablet_slot = "Tablet Slot", taser_tp = "Taser TP", taser_btn = "TASE",
        tab_farm = "Farm",
        fov_color = "FOV Circle Color",
        auto_farm = "Auto Farm", farm_rings = "Contraband", farm_status_buy = "Buying", farm_status_sell = "Selling...", farm_status_launder = "Laundering...", farm_status_walk = "Flying to point...", farm_cycles = "Cycles",
        aimbot = "Aimbot", aim_part = "Aim Part", toggle_btn = "Toggle",
        fov_circle = "FOV Circle", smoothness = "Smoothness",
        max_dist = "Max Distance", dist_btn = "Cycle",
        wall_check = "Wall Check", team_check = "Team Check",
        target_lock = "Target Lock", prediction = "Prediction",
        anti_recoil = "Anti-Recoil", recoil_comp = "Recoil Comp %",
        esp_visual_settings = "ESP & Visual Settings",
        esp_gradient = "ESP Gradient", fov_gradient = "FOV Gradient",
        mode_outline = "Mode: Outline", mode_fill = "Mode: Fill", switch_btn = "Switch",
        role_police = "Police", role_civilian = "Civilian",
        role_friend = "Friend", role_armed = "Armed",
        settings_title = "Interface Settings",
        accent_color = "Menu Accent Color", toggle_color = "Toggle Color",
        bg_color = "Background Color", row_color = "Element Color",
        language = "Language", lang_ru = "Русский", lang_en = "English",
        on = "ON", off = "OFF",
        notif_scanning = "Scanning players...", notif_remotes_nf = "Remotes not found",
        notif_no_target = "No target found", notif_color_upd = "updated",
        notif_menu_color = "Menu color updated", notif_toggle_color = "Toggle color updated",
        at_title = "AUTO TABLET", at_timeout = "Timeout",
        at_wanted = "Wanted Lvl", at_warrant = "WARRANT", at_clean = "Clean",
        at_warrant_notif = "WARRANT",
        head = "Head", upper_torso = "UpperTorso", torso = "Torso",
        lines_for = "Lines for:",
        tab_visuals = "Visuals", tab_movement = "Move", tab_misc = "Misc",
        tab_aimbot = "Aimbot", tab_colors = "Colors", tab_settings = "Settings", tab_info = "Info",
        info_channel = "Telegram channel:", info_link = "Link: https://t.me/eclipse_script", info_copy_hint = "Copy the link and open in browser",
    },
}

local function t(key)
    local lang = S.lang or "ru"
    return L[lang] and L[lang][key] or L.ru[key] or key
end

local function registerLabel(obj, key, prefix, suffix)
    table.insert(S.langLabels, {obj = obj, key = key, prefix = prefix or "", suffix = suffix or ""})
end

local function applyLanguage()
    for _, entry in ipairs(S.langLabels) do
        if entry.obj and entry.obj.Parent then
            if entry.isCustom and entry.updateFn then
                entry.updateFn()
            elseif entry.isSlider then
                local val = entry.getVal()
                local cl = t(entry.langKey)
                entry.obj.Text = entry.displayFn and (cl..": "..entry.displayFn(val)) or (cl..": "..val)
            else
                entry.obj.Text = entry.prefix .. t(entry.key) .. entry.suffix
            end
        end
    end
end

-- ========== FULLBRIGHT ==========
do
    if not _G.FullBrightExecuted then
        _G.FullBrightEnabled = false
        _G.NormalLightingSettings = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
            Ambient = Lighting.Ambient
        }
        local function applyFB(on)
            if on then
                Lighting.Brightness = 1
                Lighting.ClockTime = 12
                Lighting.FogEnd = 786543
                Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            else
                local n = _G.NormalLightingSettings
                Lighting.Brightness = n.Brightness
                Lighting.ClockTime = n.ClockTime
                Lighting.FogEnd = n.FogEnd
                Lighting.GlobalShadows = n.GlobalShadows
                Lighting.Ambient = n.Ambient
            end
        end
        _G._applyFullBright = applyFB
        pcall(function() applyFB(true) end)
        _G.FullBrightEnabled = false
        pcall(function() applyFB(false) end)
    end
    _G.FullBrightExecuted = true
end

-- ========== AIMBOT CONFIG ==========
_G.AimbotConfig = _G.AimbotConfig or {
    Enabled = false,
    AimParts = {"Head", "UpperTorso", "HumanoidRootPart", "Torso"},
    SelectedAimPart = 1,
    FOV = 90,
    CircleTransparency = 0.5,
    AimBind = Enum.UserInputType.Touch,
    MaxDistance = 50,
    Smoothness = 0.18,
    WallCheck = false,
    TeamCheck = true,
    TargetLock = true,
    Prediction = true,
    PredictionFactor = 0.08,
    ShowFOVCircle = true,
    IsRunning = true,
}

-- ========== ДЕТЕКЦИЯ РОЛЕЙ ==========
local policeKW = {"police","полиц","cop","sheriff","шериф","officer","офицер","patrol","патруль","swat","fbi","фбр","dea","dps","highway","trooper","marshal","leo","department","pd","lspd","bcso","sahp","security","охран","guard"}
local policeToolKW = {"badge","значок","звезда","star","handcuffs","наручники","cuffs","taser","тазер","radio","рация","baton","дубинка","bodycam","камера"}
local weaponKW = {"gun","pistol","rifle","shotgun","smg","ar15","ak","glock","m4","m16","deagle","revolver","sniper","knife","нож","пистолет","автомат","винтовка","дробовик","weapon","firearm"}

local function isPolice(player)
    if player.Team then
        local tn = player.Team.Name:lower()
        for _, kw in ipairs(policeKW) do if tn:find(kw) then return true end end
    end
    if player.Character then
        for _, ch in ipairs(player.Character:GetChildren()) do
            local cn = ch.Name:lower()
            for _, kw in ipairs(policeToolKW) do if cn:find(kw) then return true end end
        end
        if player:FindFirstChild("Backpack") then
            for _, tool in ipairs(player.Backpack:GetChildren()) do
                local tn = tool.Name:lower()
                for _, kw in ipairs(policeToolKW) do if tn:find(kw) then return true end end
            end
        end
    end
    return false
end

local function isArmed(player)
    if not player.Character then return false end
    for _, ch in ipairs(player.Character:GetChildren()) do
        if ch:IsA("Tool") then
            local cn = ch.Name:lower()
            for _, kw in ipairs(weaponKW) do if cn:find(kw) then return true end end
        end
    end
    return false
end

local function isFriend(player)
    local ok, result = pcall(function() return LocalPlayer:IsFriendsWith(player.UserId) end)
    return ok and result
end

local function getPlayerRole(player)
    if isFriend(player) then return "Friend", S.ESPColors.Friend end
    if isPolice(player) then return "Police", S.ESPColors.Police end
    if isArmed(player) then return "Armed", S.ESPColors.Armed end
    return "Civilian", S.ESPColors.Civilian
end

local function getHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

-- ========== NOTIFICATIONS ==========
local notifContainer
do
    local nc = Instance.new("Frame")
    nc.Name = "NotifContainer"
    nc.Size = UDim2.new(0, 200, 0, 200)
    nc.Position = UDim2.new(0.5, -100, 0, 5)
    nc.BackgroundTransparency = 1
    notifContainer = nc
end

local function showNotification(title, msg, color)
    pcall(function()
        local f = Instance.new("Frame", notifContainer)
        f.Size = UDim2.new(1, 0, 0, 28)
        f.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
        f.BackgroundTransparency = 0.15
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        local tl = Instance.new("TextLabel", f)
        tl.Size = UDim2.new(1, -8, 1, 0)
        tl.Position = UDim2.new(0, 4, 0, 0)
        tl.BackgroundTransparency = 1
        tl.Text = title .. ": " .. msg
        tl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 10
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.TextTruncate = Enum.TextTruncate.AtEnd
        task.delay(2.5, function() pcall(function() f:Destroy() end) end)
    end)
end

-- ========== ESP ==========
local function setupESPForPlayer(player)
    if player == LocalPlayer or not player.Character then return end
    local role, color = getPlayerRole(player)
    if not S.espRoleFilter[role] then
        local oldHL = player.Character:FindFirstChild("ESPHighlight")
        if oldHL then oldHL:Destroy() end
        return
    end
    S.espCache[player.UserId] = {role = role, color = color}
    local hl = player.Character:FindFirstChild("ESPHighlight")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "ESPHighlight"
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.Parent = player.Character
    end
    hl.FillColor = color
    hl.OutlineColor = color
    local head = player.Character:FindFirstChild("Head")
    if head then
        local existingTag = head:FindFirstChild("NameTag")
        if existingTag then existingTag:Destroy() end
        local bb = Instance.new("BillboardGui")
        bb.Name = "NameTag"
        bb.Size = UDim2.new(0, 120, 0, 36)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true
        bb.Parent = head
        local label = Instance.new("TextLabel", bb)
        label.Name = "TagLabel"
        label.Size = UDim2.new(1, 0, 0, 14)
        label.BackgroundTransparency = 1
        label.Text = player.DisplayName
        label.TextColor3 = color
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextStrokeTransparency = 0.5
        local hpBg = Instance.new("Frame", bb)
        hpBg.Name = "HPBarBg"
        hpBg.Size = UDim2.new(0.8, 0, 0, 3)
        hpBg.Position = UDim2.new(0.1, 0, 0, 16)
        hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        hpBg.BorderSizePixel = 0
        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)
        local hpFill = Instance.new("Frame", hpBg)
        hpFill.Name = "HPBarFill"
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        hpFill.BorderSizePixel = 0
        Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)
    end
end

local function enableESP()
    S.espEnabled = true
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then setupESPForPlayer(p) end
    end
end

local function disableESP()
    S.espEnabled = false
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("ESPHighlight")
            if hl then hl:Destroy() end
            local head = p.Character:FindFirstChild("Head")
            if head then
                local tag = head:FindFirstChild("NameTag")
                if tag then tag:Destroy() end
            end
        end
    end
    S.espCache = {}
end

local function removeESPForPlayer(player)
    if player.Character then
        local hl = player.Character:FindFirstChild("ESPHighlight")
        if hl then hl:Destroy() end
        local head = player.Character:FindFirstChild("Head")
        if head then
            local tag = head:FindFirstChild("NameTag")
            if tag then tag:Destroy() end
        end
    end
    S.espCache[player.UserId] = nil
end

-- ========== ФУНКЦИИ ==========
local function toggleFB()
    S.fbEnabled = not S.fbEnabled
    _G.FullBrightEnabled = S.fbEnabled
    pcall(_G._applyFullBright, S.fbEnabled)
end

local function rejoin()
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId) end)
end

local function toggleAFK()
    S.afkEnabled = not S.afkEnabled
    if S.afkEnabled then
        S.afkThread = task.spawn(function()
            while S.afkEnabled and S.scriptActive do
                pcall(function()
                    if VirtualUser then VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.zero) end
                end)
                task.wait(60)
            end
        end)
    end
end

local function startFly()
    local c = LocalPlayer.Character
    if not c then return end
    local hr = c:FindFirstChild("HumanoidRootPart")
    local hm = c:FindFirstChildOfClass("Humanoid")
    if not hr or not hm then return end
    S.flyEnabled = true
    local fp = Instance.new("Part")
    fp.Size = Vector3.new(6, 1, 6)
    fp.Transparency = 1
    fp.Anchored = true
    fp.CanCollide = true
    fp.CFrame = hr.CFrame * CFrame.new(0, -3.5, 0)
    fp.Parent = WS
    S.flyFakePart = fp
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hr
    S.flyBV = bv
    hm.PlatformStand = false
    showNotification(t("fly"), t("on"), Color3.fromRGB(168,85,247))
end

local function stopFly()
    S.flyEnabled = false
    if S.flyFakePart then pcall(function() S.flyFakePart:Destroy() end) S.flyFakePart = nil end
    if S.flyBV then pcall(function() S.flyBV:Destroy() end) S.flyBV = nil end
    showNotification(t("fly"), t("off"), Color3.fromRGB(255,50,50))
end

local function toggleFly()
    if S.flyEnabled then stopFly() else startFly() end
end

local function toggleNoclip()
    S.noclipEnabled = not S.noclipEnabled
    if not S.noclipEnabled then
        for part, val in pairs(S.noclipOrigCollisions) do
            pcall(function() part.CanCollide = val end)
        end
        S.noclipOrigCollisions = {}
    end
    showNotification(t("noclip"), S.noclipEnabled and t("on") or t("off"), S.noclipEnabled and Color3.fromRGB(168,85,247) or Color3.fromRGB(255,50,50))
end

local function restoreCollisions()
    for part, val in pairs(S.noclipOrigCollisions) do
        pcall(function() part.CanCollide = val end)
    end
    S.noclipOrigCollisions = {}
end

local function toggleVehSpeed()
    S.vehSpeedEnabled = not S.vehSpeedEnabled
    if not S.vehSpeedEnabled then
        for seat, spd in pairs(S.vehOrigSpeeds) do
            if seat and seat.Parent then pcall(function() seat.MaxSpeed = spd end) end
        end
        S.vehOrigSpeeds = {}
    end
    showNotification(t("car_speed"), S.vehSpeedEnabled and ("x"..S.vehSpeedMult.." "..t("on")) or t("off"), S.vehSpeedEnabled and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,80,80))
end

local function wallClipTP()
    local c = LocalPlayer.Character
    if not c then return end
    local hr = c:FindFirstChild("HumanoidRootPart")
    if not hr then return end
    local lv = Camera.CFrame.LookVector
    hr.CFrame = hr.CFrame + lv * 8
    showNotification(t("wall_clip"), "+8 studs", Color3.fromRGB(168,85,247))
end

-- Aimbot helpers
S._aimHeld = false

local function IsBindPressed()
    return S._aimHeld
end

local function isValidTarget(player)
    if not player or player == LocalPlayer or not player.Character then return false end
    local hum = getHumanoid(player.Character)
    if not hum or hum.Health <= 0 then return false end
    local cfg = _G.AimbotConfig
    if cfg.TeamCheck and player.Team == LocalPlayer.Team then return false end
    return true
end

local function getAimPart(character)
    if not character then return nil end
    local cfg = _G.AimbotConfig
    local partName = cfg.AimParts[cfg.SelectedAimPart]
    return character:FindFirstChild(partName) or character:FindFirstChild("HumanoidRootPart")
end

local function isVisible(part)
    if not _G.AimbotConfig.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local ray = Ray.new(origin, dir)
    local hit = WS:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit == nil or hit:IsDescendantOf(part.Parent)
end

eclipseLog("Functions ready")

-- ========== GUI ==========
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Eclipse_Internal"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling end)

local guiPlaced = false
pcall(function() if not guiPlaced and gethui then screenGui.Parent = gethui() guiPlaced = true end end)
pcall(function() if not guiPlaced then screenGui.Parent = game:GetService("CoreGui") guiPlaced = true end end)
if not guiPlaced then screenGui.Parent = playerGui end

notifContainer.Parent = screenGui

-- ========== MENU BUTTON (image) ==========
local MENU_IMAGE_ID = "rbxassetid://70510223806673"

local floatBtn = Instance.new("TextButton", screenGui)
floatBtn.Size = UDim2.new(0, 46, 0, 46)
floatBtn.Position = UDim2.new(0, 8, 0.5, -23)
floatBtn.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
floatBtn.BackgroundTransparency = 0.1
floatBtn.Text = ""
floatBtn.Active = true
floatBtn.ZIndex = 100
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)

local floatStroke = Instance.new("UIStroke", floatBtn)
floatStroke.Color = Color3.fromRGB(168, 85, 247)
floatStroke.Thickness = 2

local floatImg = Instance.new("ImageLabel", floatBtn)
floatImg.Size = UDim2.new(0, 36, 0, 36)
floatImg.Position = UDim2.new(0.5, -18, 0.5, -18)
floatImg.BackgroundTransparency = 1
floatImg.Image = MENU_IMAGE_ID
floatImg.ZIndex = 101
Instance.new("UICorner", floatImg).CornerRadius = UDim.new(1, 0)

do
    local dragging, dragStart, startPos = false, nil, nil
    local dragThreshold = 10
    local wasDrag = false
    floatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            wasDrag = false
            dragStart = input.Position
            startPos = floatBtn.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = input.Position - dragStart
            if d.Magnitude > dragThreshold then wasDrag = true end
            floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dragging and not wasDrag then
                S.menuVisible = not S.menuVisible
                S.mainFrame.Visible = S.menuVisible
            end
            dragging = false
        end
    end)
end

-- ========== AIM BUTTON ==========
S.aimMode = "toggle" -- "toggle" или "hold"

local aimBtn = Instance.new("TextButton", screenGui)
aimBtn.Size = UDim2.new(0, 52, 0, 52)
aimBtn.Position = UDim2.new(1, -62, 0.5, -80)
aimBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
aimBtn.BackgroundTransparency = 0.2
aimBtn.Text = ""
aimBtn.Active = true
aimBtn.Visible = false
aimBtn.ZIndex = 100
Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(1, 0)

local aimStroke = Instance.new("UIStroke", aimBtn)
aimStroke.Color = Color3.fromRGB(255, 50, 50)
aimStroke.Thickness = 2

-- crosshair icon
local aimCrossV = Instance.new("Frame", aimBtn)
aimCrossV.Size = UDim2.new(0, 2, 0, 20)
aimCrossV.Position = UDim2.new(0.5, -1, 0.5, -10)
aimCrossV.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
aimCrossV.ZIndex = 101
local aimCrossH = Instance.new("Frame", aimBtn)
aimCrossH.Size = UDim2.new(0, 20, 0, 2)
aimCrossH.Position = UDim2.new(0.5, -10, 0.5, -1)
aimCrossH.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
aimCrossH.ZIndex = 101
local aimCircle = Instance.new("Frame", aimBtn)
aimCircle.Size = UDim2.new(0, 14, 0, 14)
aimCircle.Position = UDim2.new(0.5, -7, 0.5, -7)
aimCircle.BackgroundTransparency = 1
aimCircle.ZIndex = 101
Instance.new("UICorner", aimCircle).CornerRadius = UDim.new(1, 0)
local aimCircleStroke = Instance.new("UIStroke", aimCircle)
aimCircleStroke.Color = Color3.fromRGB(255, 50, 50)
aimCircleStroke.Thickness = 1.5

local aimLabel = Instance.new("TextLabel", aimBtn)
aimLabel.Size = UDim2.new(1, 0, 0, 12)
aimLabel.Position = UDim2.new(0, 0, 1, 2)
aimLabel.BackgroundTransparency = 1
aimLabel.Text = "AIM"
aimLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
aimLabel.Font = Enum.Font.GothamBold
aimLabel.TextSize = 9
aimLabel.ZIndex = 100

local function updateAimBtnVisual()
    local on = S._aimHeld
    aimStroke.Color = on and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    aimLabel.TextColor3 = on and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    aimCrossV.BackgroundColor3 = on and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    aimCrossH.BackgroundColor3 = on and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    aimCircleStroke.Color = on and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    aimLabel.Text = on and "AIM ON" or "AIM"
end

-- Toggle mode: tap to toggle
aimBtn.MouseButton1Click:Connect(function()
    if S.aimMode == "toggle" then
        S._aimHeld = not S._aimHeld
        updateAimBtnVisual()
    end
end)

-- Hold mode: hold to aim
aimBtn.MouseButton1Down:Connect(function()
    if S.aimMode == "hold" then
        S._aimHeld = true
        updateAimBtnVisual()
    end
end)
aimBtn.MouseButton1Up:Connect(function()
    if S.aimMode == "hold" then
        S._aimHeld = false
        updateAimBtnVisual()
    end
end)

-- Drag
do
    local dragging, dragStart, startPos = false, nil, nil
    local dragThreshold = 15
    local wasDrag = false
    aimBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            wasDrag = false
            dragStart = input.Position
            startPos = aimBtn.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            if d.Magnitude > dragThreshold then
                wasDrag = true
                aimBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ========== MAIN FRAME ==========
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 320)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
mainFrame.Active = true
mainFrame.ClipsDescendants = true
mainFrame.Visible = false
mainFrame.ZIndex = 50
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
S.mainFrame = mainFrame

-- Drag (touch-compatible)
do
    local dragging, dragStart, startPos = false, nil, nil
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    local dragInput
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- Header
do
    local hf = Instance.new("Frame", mainFrame)
    hf.Size = UDim2.new(1, 0, 0, 34)
    hf.BackgroundTransparency = 1
    hf.ZIndex = 51
    local tl = Instance.new("TextLabel", hf)
    tl.Size = UDim2.new(0, 120, 1, 0)
    tl.Position = UDim2.new(0, 10, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = "ECLIPSE"
    tl.TextColor3 = Color3.fromRGB(255, 255, 255)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 15
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 51

    local mobileLabel = Instance.new("TextLabel", hf)
    mobileLabel.Size = UDim2.new(0, 50, 1, 0)
    mobileLabel.Position = UDim2.new(0, 90, 0, 0)
    mobileLabel.BackgroundTransparency = 1
    mobileLabel.Text = "mobile"
    mobileLabel.TextColor3 = Color3.fromRGB(168, 85, 247)
    mobileLabel.Font = Enum.Font.GothamBold
    mobileLabel.TextSize = 11
    mobileLabel.TextXAlignment = Enum.TextXAlignment.Left
    mobileLabel.ZIndex = 51

    local tgLink = Instance.new("TextLabel", hf)
    tgLink.Size = UDim2.new(0, 150, 1, 0)
    tgLink.Position = UDim2.new(0, 145, 0, 0)
    tgLink.BackgroundTransparency = 1
    tgLink.Text = "t.me/eclipse_script"
    tgLink.TextColor3 = Color3.fromRGB(130, 170, 255)
    tgLink.Font = Enum.Font.GothamMedium
    tgLink.TextSize = 9
    tgLink.TextXAlignment = Enum.TextXAlignment.Left
    tgLink.ZIndex = 51

    local closeBtn = Instance.new("TextButton", hf)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
    closeBtn.BackgroundColor3 = Color3.fromRGB(32, 24, 38)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(180, 170, 190)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 11
    closeBtn.ZIndex = 52
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

    local minBtn = Instance.new("TextButton", hf)
    minBtn.Size = UDim2.new(0, 24, 0, 24)
    minBtn.Position = UDim2.new(1, -58, 0.5, -12)
    minBtn.BackgroundColor3 = Color3.fromRGB(28, 22, 36)
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.fromRGB(180, 170, 190)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 11
    minBtn.ZIndex = 52
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

    minBtn.MouseButton1Click:Connect(function()
        S.menuVisible = false
        mainFrame.Visible = false
    end)

    closeBtn.MouseButton1Click:Connect(function()
        S.scriptActive = false
        pcall(disableESP)
        if _G.FullBrightEnabled then _G.FullBrightEnabled = false S.fbEnabled = false pcall(_G._applyFullBright, false) end
        S.afkEnabled = false
        S.espEnabled = false
        S.speedBoostEnabled = false
        S.jumpBoostEnabled = false
        S.antiRecoilEnabled = false
        if S.flyEnabled then pcall(stopFly) S.flyEnabled = false end
        if S.noclipEnabled then S.noclipEnabled = false pcall(restoreCollisions) end
        if S.vehSpeedEnabled then pcall(toggleVehSpeed) end
        if S.FOVCircle then pcall(function() S.FOVCircle:Remove() end) S.FOVCircle = nil end
        for _, line in pairs(S.threatLineCache or {}) do pcall(function() line:Remove() end) end
        S.threatLineCache = {}
        for _, data in pairs(S.espCache or {}) do
            if data and data.tag then pcall(function() data.tag:Remove() end) end
        end
        for _, c in ipairs(S.connections) do if c and c.Disconnect then pcall(c.Disconnect, c) end end
        S.connections = {}
        for seat, spd in pairs(S.vehOrigSpeeds or {}) do pcall(function() seat.MaxSpeed = spd end) end
        S.vehOrigSpeeds = {}
        pcall(function() LocalPlayer.CameraMaxZoomDistance = 15 end)
        if S.flyFakePart then pcall(function() S.flyFakePart:Destroy() end) S.flyFakePart = nil end
        if S.flyBV then pcall(function() S.flyBV:Destroy() end) S.flyBV = nil end
        screenGui:Destroy()
        _G.AimbotConfig = nil
        eclipseLog("ECLIPSE Mobile unloaded")
    end)

    local glow = Instance.new("Frame", mainFrame)
    glow.Size = UDim2.new(1, 0, 0, 2)
    glow.Position = UDim2.new(0, 0, 0, 34)
    glow.BorderSizePixel = 0
    glow.ZIndex = 51
    local gr = Instance.new("UIGradient", glow)
    gr.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(168,85,247)), ColorSequenceKeypoint.new(1, Color3.fromRGB(236,72,153))})
    S.glowGradient = gr
end

-- ========== TAB BAR (horizontal) ==========
local tabPanels = {}
local tabButtons = {}

do
    local tabBar = Instance.new("ScrollingFrame", mainFrame)
    tabBar.Size = UDim2.new(1, 0, 0, 30)
    tabBar.Position = UDim2.new(0, 0, 0, 36)
    tabBar.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
    tabBar.BorderSizePixel = 0
    tabBar.ScrollBarThickness = 0
    tabBar.ScrollingDirection = Enum.ScrollingDirection.X
    tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    pcall(function() tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X end)
    tabBar.ZIndex = 51

    local tabLayout = Instance.new("UIListLayout", tabBar)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local tabs = {"Visuals","Movement","Misc","Aimbot","Farm","Colors","Settings","Info"}
    local tabLangKeys = {Visuals="tab_visuals",Movement="tab_movement",Misc="tab_misc",Aimbot="tab_aimbot",Farm="tab_farm",Colors="tab_colors",Settings="tab_settings",Info="tab_info"}

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(0, 58, 1, -4)
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(38, 25, 60) or Color3.fromRGB(24, 20, 32)
        btn.Text = t(tabLangKeys[name])
        btn.TextColor3 = i == 1 and Color3.fromRGB(210, 180, 255) or Color3.fromRGB(140, 135, 150)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.LayoutOrder = i
        btn.ZIndex = 52
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        tabButtons[name] = btn
        registerLabel(btn, tabLangKeys[name])
    end

    local cf = Instance.new("Frame", mainFrame)
    cf.Size = UDim2.new(1, -10, 1, -72)
    cf.Position = UDim2.new(0, 5, 0, 68)
    cf.BackgroundTransparency = 1
    cf.ZIndex = 50

    for _, name in ipairs(tabs) do
        local p = Instance.new("ScrollingFrame", cf)
        p.Size = UDim2.new(1, 0, 1, 0)
        p.BackgroundTransparency = 1
        p.Visible = name == "Visuals"
        p.ScrollBarThickness = 2
        p.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
        p.CanvasSize = UDim2.new(0, 0, 0, 0)
        p.ZIndex = 50
        pcall(function() p.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
        tabPanels[name] = p
    end

    local function switchTab(tabName)
        S.currentTab = tabName
        for n, p in pairs(tabPanels) do
            p.Visible = n == tabName
            if n == tabName then pcall(function() p.CanvasPosition = Vector2.new(0, 0) end) end
        end
        for n, b in pairs(tabButtons) do
            local a = n == tabName
            TS:Create(b, TweenInfo.new(0.2), {
                BackgroundColor3 = a and Color3.fromRGB(38, 25, 60) or Color3.fromRGB(24, 20, 32),
                TextColor3 = a and Color3.fromRGB(210, 180, 255) or Color3.fromRGB(140, 135, 150)
            }):Play()
        end
    end
    for n, b in pairs(tabButtons) do b.MouseButton1Click:Connect(function() switchTab(n) end) end
end

eclipseLog("GUI structure ready")

-- ========== UI HELPERS (mobile) ==========
S.rowRegistry = {}
local function makeRow(parent, height)
    local r = Instance.new("Frame", parent)
    r.Size = UDim2.new(1, -6, 0, height or 38)
    r.BackgroundColor3 = Color3.fromRGB(30, 24, 40)
    r.ZIndex = 50
    Instance.new("UICorner", r).CornerRadius = UDim.new(0, 7)
    table.insert(S.rowRegistry, r)
    return r
end

local function makeDot(parent)
    local d = Instance.new("Frame", parent)
    d.Size = UDim2.new(0, 6, 0, 6)
    d.Position = UDim2.new(0, 10, 0.5, -3)
    d.BackgroundColor3 = Color3.fromRGB(90, 80, 110)
    d.ZIndex = 51
    Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
    return d
end

local function makeLabel(parent, text, langKey)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(0, 110, 1, 0)
    l.Position = UDim2.new(0, 24, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = langKey and t(langKey) or text
    l.TextColor3 = Color3.fromRGB(235, 230, 245)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 51
    if langKey then registerLabel(l, langKey) end
    return l
end

local function makeToggle(parent)
    local bg = Instance.new("TextButton", parent)
    bg.Size = UDim2.new(0, 38, 0, 18)
    bg.Position = UDim2.new(1, -48, 0.5, -9)
    bg.BackgroundColor3 = Color3.fromRGB(55, 46, 68)
    bg.Text = ""
    bg.ZIndex = 52
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local ball = Instance.new("Frame", bg)
    ball.Size = UDim2.new(0, 14, 0, 14)
    ball.Position = UDim2.new(0, 2, 0.5, -7)
    ball.BackgroundColor3 = Color3.fromRGB(245, 242, 250)
    ball.ZIndex = 53
    Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)
    table.insert(S.toggleRegistry, bg)
    return bg, ball
end

local function animateToggle(bg, ball, dot, enabled)
    local activeCol = S.toggleActiveColor or Color3.fromRGB(168, 85, 247)
    TS:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = enabled and activeCol or Color3.fromRGB(55, 46, 68)}):Play()
    TS:Create(ball, TweenInfo.new(0.2), {Position = enabled and UDim2.new(0, 22, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
    if dot then TS:Create(dot, TweenInfo.new(0.2), {BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(90, 80, 110)}):Play() end
end

local function makeSlider(parent, labelText, min, max, default, color, onChange, displayFn, langKey)
    local row = makeRow(parent, 44)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -10, 0, 16)
    lbl.Position = UDim2.new(0, 8, 0, 2)
    lbl.BackgroundTransparency = 1
    local curLabel = langKey and t(langKey) or labelText
    lbl.Text = displayFn and (curLabel..": "..displayFn(default)) or (curLabel..": "..default)
    lbl.TextColor3 = Color3.fromRGB(235, 230, 245)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 51
    local back = Instance.new("Frame", row)
    back.Size = UDim2.new(0.92, 0, 0, 6)
    back.Position = UDim2.new(0.04, 0, 0, 24)
    back.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    back.ZIndex = 51
    Instance.new("UICorner", back).CornerRadius = UDim.new(0, 3)
    local perc0 = (default - min) / (max - min)
    local fill = Instance.new("Frame", back)
    fill.Size = UDim2.new(perc0, 0, 1, 0)
    fill.BackgroundColor3 = color
    fill.ZIndex = 52
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
    local knob = Instance.new("TextButton", back)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(perc0, -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Text = ""
    knob.ZIndex = 53
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local holding = false
    local lastVal = default
    local sliderConn = nil

    local function startSlide()
        holding = true
        if not sliderConn then
            sliderConn = RS.Heartbeat:Connect(function()
                if not holding then
                    if sliderConn then sliderConn:Disconnect() sliderConn = nil end
                    return
                end
                local mx = UIS:GetMouseLocation().X
                local sx = back.AbsolutePosition.X
                local sw = back.AbsoluteSize.X
                local p = math.clamp((mx - sx) / sw, 0, 1)
                local val = math.round(p * (max - min) + min)
                lastVal = val
                fill.Size = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, -8, 0.5, -8)
                local cl = langKey and t(langKey) or labelText
                lbl.Text = displayFn and (cl..": "..displayFn(val)) or (cl..": "..val)
                onChange(val, p)
            end)
        end
    end

    knob.MouseButton1Down:Connect(startSlide)
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then startSlide() end
    end)
    back.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            startSlide()
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            holding = false
        end
    end)
    if langKey then
        table.insert(S.langLabels, {obj = lbl, langKey = langKey, isSlider = true, displayFn = displayFn, getVal = function() return lastVal end})
    end
    return row
end

-- ========== ВКЛАДКА VISUALS ==========
do
    local vp = tabPanels["Visuals"]
    local vpLayout = Instance.new("UIListLayout", vp)
    vpLayout.Padding = UDim.new(0, 4)
    vpLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local vpOrder = 0
    local function vpNext(obj) vpOrder = vpOrder + 1 obj.LayoutOrder = vpOrder return obj end

    local row = makeRow(vp)
    vpNext(row)
    local dot = makeDot(row)
    makeLabel(row, nil, "esp_players")
    local tBg, tBall = makeToggle(row)
    local function toggleESP()
        if S.espEnabled then disableESP() else enableESP() end
        animateToggle(tBg, tBall, dot, S.espEnabled)
        showNotification("ESP", S.espEnabled and t("on") or t("off"), S.espEnabled and Color3.fromRGB(0,235,255) or Color3.fromRGB(255,50,50))
        if S._espSubs then for _, sub in ipairs(S._espSubs) do sub.Visible = S.espEnabled end end
    end
    tBg.MouseButton1Click:Connect(toggleESP)
    S._toggleESP = toggleESP

    local function makeSmallCheckbox(parent, text, default, callback, langKey)
        local r = Instance.new("Frame", parent); vpNext(r)
        r.Size = UDim2.new(1, 0, 0, 20)
        r.BackgroundTransparency = 1
        r.ZIndex = 50
        local cb = Instance.new("TextButton", r)
        cb.Size = UDim2.new(0, 16, 0, 16)
        cb.Position = UDim2.new(0, 20, 0.5, -8)
        cb.BackgroundColor3 = default and S.menuAccentColor or Color3.fromRGB(40,35,50)
        cb.Text = default and "X" or ""
        cb.TextColor3 = Color3.fromRGB(255,255,255)
        cb.Font = Enum.Font.GothamBold
        cb.TextSize = 10
        cb.ZIndex = 52
        Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 3)
        local lbl = Instance.new("TextLabel", r)
        lbl.Size = UDim2.new(1, -42, 1, 0)
        lbl.Position = UDim2.new(0, 40, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = langKey and t(langKey) or text
        if langKey then registerLabel(lbl, langKey) end
        lbl.TextColor3 = Color3.fromRGB(200,195,210)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 51
        local state = default
        cb.MouseButton1Click:Connect(function()
            state = not state
            cb.Text = state and "X" or ""
            cb.BackgroundColor3 = state and S.menuAccentColor or Color3.fromRGB(40,35,50)
            callback(state)
        end)
        return r
    end

    local function refreshESPInline()
        if S.espEnabled then
            for _, p in ipairs(Players:GetPlayers()) do setupESPForPlayer(p) end
        end
    end
    local espSubs = {
        makeSmallCheckbox(vp, nil, true, function(v) S.espRoleFilter.Police = v; refreshESPInline() end, "police"),
        makeSmallCheckbox(vp, nil, true, function(v) S.espRoleFilter.Civilian = v; refreshESPInline() end, "civilian"),
        makeSmallCheckbox(vp, nil, true, function(v) S.espRoleFilter.Friend = v; refreshESPInline() end, "friends"),
        makeSmallCheckbox(vp, nil, true, function(v) S.espRoleFilter.Armed = v; refreshESPInline() end, "armed_filter"),
    }
    for _, sub in ipairs(espSubs) do sub.Visible = false end
    S._espSubs = espSubs

    -- FullBright
    local fbRow = makeRow(vp); vpNext(fbRow)
    local fbDot = makeDot(fbRow)
    makeLabel(fbRow, nil, "fullbright")
    local fbBg, fbBall = makeToggle(fbRow)
    local function handleFB()
        toggleFB()
        animateToggle(fbBg, fbBall, fbDot, S.fbEnabled)
        showNotification("FullBright", S.fbEnabled and t("on") or t("off"), S.fbEnabled and Color3.fromRGB(168,85,247) or Color3.fromRGB(255,50,50))
    end
    fbBg.MouseButton1Click:Connect(handleFB)
    S._handleFB = handleFB


    -- Threat Lines
    local tlRow = makeRow(vp); vpNext(tlRow)
    local tlDot = makeDot(tlRow)
    makeLabel(tlRow, nil, "threat_lines")
    local tlBg, tlBall = makeToggle(tlRow)
    tlBg.MouseButton1Click:Connect(function()
        S.threatLines = not S.threatLines
        animateToggle(tlBg, tlBall, tlDot, S.threatLines)
        if not S.threatLines then
            for _, line in pairs(S.threatLineCache) do pcall(function() line:Remove() end) end
            S.threatLineCache = {}
        end
        if S._tlSubs then for _, sub in ipairs(S._tlSubs) do sub.Visible = S.threatLines end end
    end)

    local function makeCheckbox(parent, text, default, callback, langKey)
        local cRow = Instance.new("Frame", parent)
        cRow.Size = UDim2.new(1, 0, 0, 20)
        cRow.BackgroundTransparency = 1
        cRow.ZIndex = 50
        vpNext(cRow)
        local cb = Instance.new("TextButton", cRow)
        cb.Size = UDim2.new(0, 16, 0, 16)
        cb.Position = UDim2.new(0, 20, 0.5, -8)
        cb.BackgroundColor3 = default and S.menuAccentColor or Color3.fromRGB(40,35,50)
        cb.Text = default and "X" or ""
        cb.TextColor3 = Color3.fromRGB(255,255,255)
        cb.Font = Enum.Font.GothamBold
        cb.TextSize = 10
        cb.ZIndex = 52
        Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 3)
        local lbl = Instance.new("TextLabel", cRow)
        lbl.Size = UDim2.new(1, -42, 1, 0)
        lbl.Position = UDim2.new(0, 40, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = langKey and t(langKey) or text
        if langKey then registerLabel(lbl, langKey) end
        lbl.TextColor3 = Color3.fromRGB(200,195,210)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 51
        local state = default
        cb.MouseButton1Click:Connect(function()
            state = not state
            cb.Text = state and "X" or ""
            cb.BackgroundColor3 = state and S.menuAccentColor or Color3.fromRGB(40,35,50)
            callback(state)
        end)
        return cRow
    end

    local tlHeader = Instance.new("TextLabel", vp); vpNext(tlHeader)
    tlHeader.Size = UDim2.new(1, 0, 0, 16)
    tlHeader.BackgroundTransparency = 1
    tlHeader.Text = "  "..t("lines_for")
    tlHeader.TextColor3 = Color3.fromRGB(140,135,155)
    tlHeader.Font = Enum.Font.Gotham
    tlHeader.TextSize = 10
    tlHeader.TextXAlignment = Enum.TextXAlignment.Left
    tlHeader.ZIndex = 51
    registerLabel(tlHeader, "lines_for", "  ")
    local tlSubs = {tlHeader}
    tlSubs[#tlSubs+1] = makeCheckbox(vp, nil, true, function(v) S.threatLineArmed = v end, "armed")
    tlSubs[#tlSubs+1] = makeCheckbox(vp, nil, true, function(v) S.threatLineWanted = v end, "wanted")
    tlSubs[#tlSubs+1] = makeCheckbox(vp, nil, false, function(v) S.threatLinePolice = v end, "police_lines")
    for _, sub in ipairs(tlSubs) do sub.Visible = false end
    S._tlSubs = tlSubs
end

eclipseLog("Visuals tab ready")

-- ========== ВКЛАДКА MOVEMENT ==========
do
    local mp = tabPanels["Movement"]
    Instance.new("UIListLayout", mp).Padding = UDim.new(0, 4)

    -- Wall Clip
    local wRow = makeRow(mp)
    local wDot = makeDot(wRow)
    makeLabel(wRow, nil, "wall_clip")
    local wBg, wBall = makeToggle(wRow)
    wBg.MouseButton1Click:Connect(function()
        S.wallClipEnabled = not S.wallClipEnabled
        animateToggle(wBg, wBall, wDot, S.wallClipEnabled)
        showNotification(t("wall_clip"), S.wallClipEnabled and t("on") or t("off"), S.wallClipEnabled and Color3.fromRGB(168,85,247) or Color3.fromRGB(255,50,50))
    end)

    -- Fly
    local fRow = makeRow(mp)
    local fDot = makeDot(fRow)
    makeLabel(fRow, nil, "fly")
    local fBg, fBall = makeToggle(fRow)
    local function handleFly() toggleFly() animateToggle(fBg, fBall, fDot, S.flyEnabled) if S._flySpeedRow then S._flySpeedRow.Visible = S.flyEnabled end end
    fBg.MouseButton1Click:Connect(handleFly)
    S._handleFly = handleFly

    local flySpeedRow = makeSlider(mp, nil, 10, 500, 60, Color3.fromRGB(168,85,247), function(v) S.flySpeed = v end, nil, "fly_speed")
    flySpeedRow.Visible = false
    S._flySpeedRow = flySpeedRow

    -- Noclip
    local nRow = makeRow(mp)
    local nDot = makeDot(nRow)
    makeLabel(nRow, nil, "noclip")
    local nBg, nBall = makeToggle(nRow)
    local function handleNoclip() toggleNoclip() animateToggle(nBg, nBall, nDot, S.noclipEnabled) end
    nBg.MouseButton1Click:Connect(handleNoclip)
    S._handleNoclip = handleNoclip

    -- Car Speed
    local vRow = makeRow(mp)
    local vDot = makeDot(vRow)
    makeLabel(vRow, nil, "car_speed")
    local vBg, vBall = makeToggle(vRow)
    local function handleVeh() toggleVehSpeed() animateToggle(vBg, vBall, vDot, S.vehSpeedEnabled) if S._vehSliderRow then S._vehSliderRow.Visible = S.vehSpeedEnabled end end
    vBg.MouseButton1Click:Connect(handleVeh)
    S._handleVeh = handleVeh

    local vehSliderRow = makeSlider(mp, nil, 1, 3, 2, Color3.fromRGB(255,200,0), function(v) S.vehSpeedMult = v end, nil, "speed_multi")
    vehSliderRow.Visible = false
    S._vehSliderRow = vehSliderRow

    -- Speed Boost
    local sbRow = makeRow(mp)
    local sbDot = makeDot(sbRow)
    makeLabel(sbRow, nil, "speed_boost")
    local sbBg, sbBall = makeToggle(sbRow)
    local function handleSpeed()
        S.speedBoostEnabled = not S.speedBoostEnabled
        animateToggle(sbBg, sbBall, sbDot, S.speedBoostEnabled)
        showNotification(t("speed_boost"), S.speedBoostEnabled and ("x"..S.speedBoostMult.." "..t("on")) or t("off"), S.speedBoostEnabled and Color3.fromRGB(0,200,255) or Color3.fromRGB(255,80,80))
        if S._speedSliderRow then S._speedSliderRow.Visible = S.speedBoostEnabled end
    end
    sbBg.MouseButton1Click:Connect(handleSpeed)
    S._handleSpeed = handleSpeed

    local speedSliderRow = makeSlider(mp, nil, 1, 10, 2, Color3.fromRGB(0,200,255), function(v) S.speedBoostMult = v end, nil, "run_speed")
    speedSliderRow.Visible = false
    S._speedSliderRow = speedSliderRow

    -- Jump Boost
    local jbRow = makeRow(mp)
    local jbDot = makeDot(jbRow)
    makeLabel(jbRow, nil, "high_jump")
    local jbBg, jbBall = makeToggle(jbRow)
    local function handleJump()
        S.jumpBoostEnabled = not S.jumpBoostEnabled
        animateToggle(jbBg, jbBall, jbDot, S.jumpBoostEnabled)
        showNotification(t("high_jump"), S.jumpBoostEnabled and ("x"..S.jumpBoostMult.." "..t("on")) or t("off"), S.jumpBoostEnabled and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,80,80))
        if S._jumpSliderRow then S._jumpSliderRow.Visible = S.jumpBoostEnabled end
    end
    jbBg.MouseButton1Click:Connect(handleJump)
    S._handleJump = handleJump

    local jumpSliderRow = makeSlider(mp, nil, 1, 5, 2, Color3.fromRGB(255,200,0), function(v) S.jumpBoostMult = v end, nil, "jump_power")
    jumpSliderRow.Visible = false
    S._jumpSliderRow = jumpSliderRow
end

eclipseLog("Movement tab ready")

-- ========== ВКЛАДКА MISC ==========
do
    local mp = tabPanels["Misc"]
    Instance.new("UIListLayout", mp).Padding = UDim.new(0, 4)

    -- Rejoin
    local rRow = makeRow(mp)
    local rl = Instance.new("TextLabel", rRow)
    rl.Size = UDim2.new(0, 120, 1, 0)
    rl.Position = UDim2.new(0, 10, 0, 0)
    rl.BackgroundTransparency = 1
    rl.Text = t("rejoin")
    registerLabel(rl, "rejoin")
    rl.TextColor3 = Color3.fromRGB(235,230,245)
    rl.Font = Enum.Font.GothamBold
    rl.TextSize = 12
    rl.TextXAlignment = Enum.TextXAlignment.Left
    rl.ZIndex = 51
    local rb = Instance.new("TextButton", rRow)
    rb.Size = UDim2.new(0, 80, 0, 26)
    rb.Position = UDim2.new(1, -90, 0.5, -13)
    rb.BackgroundColor3 = Color3.fromRGB(168,85,247)
    rb.Text = t("rejoin_btn")
    registerLabel(rb, "rejoin_btn")
    rb.TextColor3 = Color3.fromRGB(255,255,255)
    rb.Font = Enum.Font.GothamBold
    rb.TextSize = 11
    rb.ZIndex = 52
    Instance.new("UICorner", rb).CornerRadius = UDim.new(0, 5)
    rb.MouseButton1Click:Connect(rejoin)

    -- Anti-AFK
    local aRow = makeRow(mp)
    local aDot = makeDot(aRow)
    makeLabel(aRow, nil, "anti_afk")
    local aBg, aBall = makeToggle(aRow)
    local function handleAFK() toggleAFK() animateToggle(aBg, aBall, aDot, S.afkEnabled) end
    aBg.MouseButton1Click:Connect(handleAFK)
    S._handleAFK = handleAFK

    -- Camera Zoom
    local plr = LocalPlayer
    makeSlider(mp, nil, 5, 100, math.round(plr.CameraMaxZoomDistance), Color3.fromRGB(168,85,247), function(v)
        plr.CameraMinZoomDistance = 0.5
        plr.CameraMaxZoomDistance = v
    end, nil, "cam_zoom")

    -- Auto Tablet
    local atRow = makeRow(mp)
    local atDot = makeDot(atRow)
    makeLabel(atRow, nil, "auto_tablet")
    local atBg, atBall = makeToggle(atRow)
    local atIntervalRow = makeSlider(mp, nil, 3, 15, 5, Color3.fromRGB(255,200,0), function(v) S.autoTabletInterval = v end, nil, "scan_interval")
    local atSlotRow = makeSlider(mp, nil, 0, 9, 6, Color3.fromRGB(255,200,0), function(v) S.tabletSlot = v end, nil, "tablet_slot")
    atIntervalRow.Visible = false
    atSlotRow.Visible = false
    atBg.MouseButton1Click:Connect(function()
        S.autoTablet = not S.autoTablet
        animateToggle(atBg, atBall, atDot, S.autoTablet)
        atIntervalRow.Visible = S.autoTablet
        atSlotRow.Visible = S.autoTablet
        if S.autoTablet then
            showNotification(t("auto_tablet"), t("notif_scanning"), Color3.fromRGB(255,200,0))
        else
            showNotification(t("auto_tablet"), t("off"), Color3.fromRGB(255,80,80))
        end
    end)

    -- Taser TP
    local ttRow = makeRow(mp)
    makeDot(ttRow)
    makeLabel(ttRow, nil, "taser_tp")
    local ttBtn = Instance.new("TextButton", ttRow)
    ttBtn.Size = UDim2.new(0, 60, 0, 22)
    ttBtn.Position = UDim2.new(1, -70, 0.5, -11)
    ttBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    ttBtn.Text = t("taser_btn")
    registerLabel(ttBtn, "taser_btn")
    ttBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    ttBtn.Font = Enum.Font.GothamBold
    ttBtn.TextSize = 10
    ttBtn.ZIndex = 52
    Instance.new("UICorner", ttBtn).CornerRadius = UDim.new(0, 5)

    local function doTaserTP()
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local bestPlayer, bestDist = nil, 100
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local role = getPlayerRole(p)
                if role == "Civilian" or role == "Armed" then
                    local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if pRoot then
                        local dist = (myRoot.Position - pRoot.Position).Magnitude
                        if dist < bestDist then bestDist = dist bestPlayer = p end
                    end
                end
            end
        end
        if not bestPlayer or not bestPlayer.Character then
            showNotification(t("taser_tp"), t("notif_no_target"), Color3.fromRGB(255,80,80))
            return
        end
        local targetRoot = bestPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        local targetPos = targetRoot.Position
        local dir = (targetPos - myRoot.Position)
        if dir.Magnitude > 0.1 then dir = dir.Unit end
        local tpTo = targetPos - dir * 3 + Vector3.new(0, 0.5, 0)
        local startPos = myRoot.Position
        local totalDist = (tpTo - startPos).Magnitude
        local steps = math.max(1, math.ceil(totalDist / 30))
        for i = 1, steps do
            local alpha = i / steps
            local pos = startPos:Lerp(tpTo, alpha)
            myRoot.CFrame = CFrame.new(pos, targetPos)
            if i < steps then task.wait(0.05) end
        end
        myRoot.CFrame = CFrame.lookAt(myRoot.Position, targetPos)
        showNotification(t("taser_tp"), "→ "..bestPlayer.DisplayName.." ("..math.floor(bestDist).."m)", Color3.fromRGB(255,200,0))
    end
    S._doTaserTP = doTaserTP
    ttBtn.MouseButton1Click:Connect(doTaserTP)
end

eclipseLog("Misc tab ready")

-- ========== ВКЛАДКА FARM ==========
do
    local fp = tabPanels["Farm"]
    Instance.new("UIListLayout", fp).Padding = UDim.new(0, 4)

    S.autoFarm = false
    S.farmCycles = 0
    S.farmRingCount = 5

    local POINT_BUY = Vector3.new(6805.8, 17.5, 23.9)
    local POINT_SELL = Vector3.new(-197.9, 17.2, 1244.4)
    local POINT_LAUNDER = Vector3.new(6806.9, 17.5, -33.8)
    local WP1 = Vector3.new(6848.5, 17.3, 26.6)
    local WP2 = Vector3.new(6842.7, 17.3, 155.8)
    local WP3 = Vector3.new(-137.1, 17.3, 162.3)
    local WP4 = Vector3.new(-149.0, 17.3, 1261.8)
    local WP5 = Vector3.new(-203.1, 17.3, 1257.1)

    local afRow = makeRow(fp)
    makeDot(afRow)
    makeLabel(afRow, nil, "auto_farm")
    local afBg, afBall = makeToggle(afRow)

    local afStatusLabel = Instance.new("TextLabel", afRow)
    afStatusLabel.Size = UDim2.new(0, 120, 0, 16)
    afStatusLabel.Position = UDim2.new(1, -220, 0.5, -8)
    afStatusLabel.BackgroundTransparency = 1
    afStatusLabel.TextColor3 = Color3.fromRGB(140, 180, 140)
    afStatusLabel.Font = Enum.Font.Gotham
    afStatusLabel.TextSize = 9
    afStatusLabel.TextXAlignment = Enum.TextXAlignment.Right
    afStatusLabel.Text = ""
    afStatusLabel.ZIndex = 51

    makeSlider(fp, nil, 1, 10, 5, Color3.fromRGB(168,85,247), function(v)
        S.farmRingCount = v
    end, nil, "farm_rings")

    local VIM = game:GetService("VirtualInputManager")

    local function holdShift(press)
        pcall(function()
            VIM:SendKeyEvent(press, Enum.KeyCode.LeftShift, false, game)
        end)
    end

    local allWaypoints = {POINT_BUY, WP1, WP2, WP3, WP4, WP5, POINT_SELL, POINT_LAUNDER}

    local function findClosestWP(pos)
        local best, bestD = 1, math.huge
        for i, wp in ipairs(allWaypoints) do
            local d = (pos - wp).Magnitude
            if d < bestD then best = i bestD = d end
        end
        return best
    end

    local function farmFlyTo(targetPos)
        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local startPos = root.Position
        local dist = (targetPos - startPos).Magnitude
        local steps = math.max(1, math.ceil(dist / 19))
        for i = 1, steps do
            if not S.autoFarm then return end
            local expected = startPos:Lerp(targetPos, i / steps)
            root.CFrame = CFrame.new(expected)
            task.wait(0.05)
            local actual = root.Position
            if (actual - expected).Magnitude > 30 then
                afStatusLabel.Text = "Anti-cheat fix..."
                task.wait(1)
                return "rollback"
            end
        end
        return nil
    end

    local function flyThrough(points)
        for idx, p in ipairs(points) do
            if not S.autoFarm then return end
            afStatusLabel.Text = t("farm_status_walk")
            local result = farmFlyTo(p)
            if result == "rollback" then
                local cwp = findClosestWP(game.Players.LocalPlayer.Character.HumanoidRootPart.Position)
                local closestPos = allWaypoints[cwp]
                farmFlyTo(closestPos)
                task.wait(0.5)
                farmFlyTo(p)
            end
            task.wait(0.1)
        end
    end

    local function firePromptSafe(prompt)
        if not prompt then return end
        fireproximityprompt(prompt)
        task.wait(0.5)
        fireproximityprompt(prompt)
    end

    local function doFarmCycle()
        local wbi = workspace:FindFirstChild("WorldBuyableItems")
        if not wbi then return false, "no WorldBuyableItems" end
        local mona = wbi:FindFirstChild("Mona Lisa Painting", true)
        if not mona then return false, "no Mona Lisa" end
        local buyPart = mona:FindFirstChild("MonaLisaPaint") or mona
        local bp = buyPart:FindFirstChild("PromptAttachment")
        if bp then bp = bp:FindFirstChild("ProximityPrompt") end

        local npcF = workspace:FindFirstChild("NPC")
        if not npcF then return false, "no NPC" end
        local seller = npcF:FindFirstChild("Seller3") or npcF:FindFirstChild("Seller") or npcF:FindFirstChild("Seller2")
        if not seller then return false, "no Seller" end
        local sellPart = seller:FindFirstChild("HumanoidRootPart")
        if not sellPart then return false, "no seller root" end

        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return false, "no character" end

        holdShift(true)
        farmFlyTo(POINT_BUY)
        holdShift(false)
        if not S.autoFarm then return false end
        task.wait(0.5)
        for i = 1, S.farmRingCount do
            if not S.autoFarm then return false end
            afStatusLabel.Text = t("farm_status_buy") .. " " .. i .. "/" .. S.farmRingCount
            firePromptSafe(bp)
            task.wait(0.8)
        end
        if not S.autoFarm then return false end

        holdShift(true)
        flyThrough({WP1, WP2, WP3, WP4, WP5, POINT_SELL})
        holdShift(false)
        if not S.autoFarm then return false end
        task.wait(0.5)
        afStatusLabel.Text = t("farm_status_sell")
        for attempt = 1, 5 do
            if not S.autoFarm then return false end
            for _, d in ipairs(workspace:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Name:find("Sell") then
                    fireproximityprompt(d)
                end
            end
            task.wait(1)
        end
        if not S.autoFarm then return false end

        holdShift(true)
        flyThrough({WP5, WP4, WP3, WP2, WP1, POINT_BUY, POINT_LAUNDER})
        holdShift(false)
        if not S.autoFarm then return false end
        task.wait(0.5)
        afStatusLabel.Text = t("farm_status_launder")
        for attempt = 1, 5 do
            if not S.autoFarm then return false end
            for _, d in ipairs(workspace:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Name:find("Launder") then
                    fireproximityprompt(d)
                end
            end
            task.wait(1)
        end

        return true
    end

    local function farmLoop()
        S.farmCycles = 0
        while S.autoFarm and S.scriptActive do
            local ok, farmErr = doFarmCycle()
            if ok then
                S.farmCycles = S.farmCycles + 1
                afStatusLabel.Text = t("farm_cycles") .. ": " .. S.farmCycles
                task.wait(0.5)
            elseif farmErr then
                afStatusLabel.Text = "Error: " .. farmErr
                task.wait(2)
            end
        end
        holdShift(false)
        afStatusLabel.Text = ""
    end

    afBg.MouseButton1Click:Connect(function()
        S.autoFarm = not S.autoFarm
        local on = S.autoFarm
        TS:Create(afBall, TweenInfo.new(0.2), {Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
        TS:Create(afBg, TweenInfo.new(0.2), {BackgroundColor3 = on and Color3.fromRGB(168,85,247) or Color3.fromRGB(60,55,70)}):Play()
        if on then
            task.spawn(farmLoop)
        end
    end)
end

eclipseLog("Farm tab ready")

-- ========== ВКЛАДКА AIMBOT ==========
do
    local ap = tabPanels["Aimbot"]
    Instance.new("UIListLayout", ap).Padding = UDim.new(0, 4)

    local aRow = makeRow(ap)
    local aDot = makeDot(aRow)
    makeLabel(aRow, nil, "aimbot")
    local aBg, aBall = makeToggle(aRow)

    local function updateAimVis() animateToggle(aBg, aBall, aDot, _G.AimbotConfig.Enabled) end
    aBg.MouseButton1Click:Connect(function()
        _G.AimbotConfig.Enabled = not _G.AimbotConfig.Enabled
        updateAimVis()
        showNotification(t("aimbot"), _G.AimbotConfig.Enabled and t("on") or t("off"), _G.AimbotConfig.Enabled and Color3.fromRGB(0,255,150) or Color3.fromRGB(255,50,50))
        if S.FOVCircle then pcall(function() S.FOVCircle.Visible = _G.AimbotConfig.Enabled end) end
        if S._aimSubs then for _, sub in ipairs(S._aimSubs) do sub.Visible = _G.AimbotConfig.Enabled end end
        aimBtn.Visible = _G.AimbotConfig.Enabled
        if not _G.AimbotConfig.Enabled then
            S._aimHeld = false
            updateAimBtnVisual()
        end
    end)

    local aimSubs = {}

    -- Aim Part
    local apRow = makeRow(ap)
    table.insert(aimSubs, apRow)
    local apLbl = Instance.new("TextLabel", apRow)
    apLbl.Size = UDim2.new(0, 130, 1, 0)
    apLbl.Position = UDim2.new(0, 10, 0, 0)
    apLbl.BackgroundTransparency = 1
    apLbl.Text = t("aim_part")..": "..t("head")
    apLbl.TextColor3 = Color3.fromRGB(235,230,245)
    apLbl.Font = Enum.Font.GothamBold
    apLbl.TextSize = 11
    apLbl.TextXAlignment = Enum.TextXAlignment.Left
    apLbl.ZIndex = 51
    table.insert(S.langLabels, {obj = apLbl, isCustom = true, updateFn = function()
        local cfg = _G.AimbotConfig
        local n = cfg.AimParts[cfg.SelectedAimPart]
        local partNames = {HumanoidRootPart = t("torso"), Head = t("head"), UpperTorso = t("upper_torso"), Torso = t("torso")}
        apLbl.Text = t("aim_part")..": "..(partNames[n] or n)
    end})
    local apBtn = Instance.new("TextButton", apRow)
    apBtn.Size = UDim2.new(0, 70, 0, 24)
    apBtn.Position = UDim2.new(1, -80, 0.5, -12)
    apBtn.BackgroundColor3 = Color3.fromRGB(168,85,247)
    apBtn.Text = t("toggle_btn")
    registerLabel(apBtn, "toggle_btn")
    apBtn.TextColor3 = Color3.fromRGB(255,255,255)
    apBtn.Font = Enum.Font.GothamBold
    apBtn.TextSize = 11
    apBtn.ZIndex = 52
    Instance.new("UICorner", apBtn).CornerRadius = UDim.new(0, 5)
    apBtn.MouseButton1Click:Connect(function()
        local cfg = _G.AimbotConfig
        cfg.SelectedAimPart = cfg.SelectedAimPart % #cfg.AimParts + 1
        local n = cfg.AimParts[cfg.SelectedAimPart]
        local partNames = {HumanoidRootPart = t("torso"), Head = t("head"), UpperTorso = t("upper_torso"), Torso = t("torso")}
        apLbl.Text = t("aim_part")..": "..(partNames[n] or n)
    end)

    table.insert(aimSubs, makeSlider(ap, nil, 10, 360, 90, Color3.fromRGB(168,85,247), function(v)
        _G.AimbotConfig.FOV = v
        if S.FOVCircle then pcall(function() S.FOVCircle.Radius = v end) end
    end, nil, "fov_circle"))

    table.insert(aimSubs, makeSlider(ap, nil, 1, 100, 18, Color3.fromRGB(168,85,247), function(v)
        _G.AimbotConfig.Smoothness = v / 100
    end, nil, "smoothness"))

    table.insert(aimSubs, makeSlider(ap, nil, 20, 100, 50, Color3.fromRGB(168,85,247), function(v)
        _G.AimbotConfig.MaxDistance = v
    end, function(v) return v.."m" end, "max_dist"))

    local function makeAimToggle(langKey, key)
        local r = makeRow(ap, 32)
        table.insert(aimSubs, r)
        r.BackgroundColor3 = Color3.fromRGB(26,22,36)
        local l = Instance.new("TextLabel", r)
        l.Size = UDim2.new(0,130,1,0)
        l.Position = UDim2.new(0,10,0,0)
        l.BackgroundTransparency = 1
        l.Text = t(langKey)
        registerLabel(l, langKey)
        l.TextColor3 = Color3.fromRGB(190,185,200)
        l.Font = Enum.Font.Gotham
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 51
        local tb = Instance.new("TextButton", r)
        tb.Size = UDim2.new(0,32,0,16)
        tb.Position = UDim2.new(1,-42,0.5,-8)
        tb.BackgroundColor3 = _G.AimbotConfig[key] and S.toggleActiveColor or Color3.fromRGB(45,40,55)
        tb.Text = ""
        tb.ZIndex = 52
        Instance.new("UICorner", tb).CornerRadius = UDim.new(1,0)
        local tbl = Instance.new("Frame", tb)
        tbl.Size = UDim2.new(0,12,0,12)
        tbl.Position = _G.AimbotConfig[key] and UDim2.new(0,17,0.5,-6) or UDim2.new(0,3,0.5,-6)
        tbl.BackgroundColor3 = Color3.fromRGB(245,242,250)
        tbl.ZIndex = 53
        Instance.new("UICorner", tbl).CornerRadius = UDim.new(1,0)
        table.insert(S.toggleRegistry, tb)
        tb.MouseButton1Click:Connect(function()
            _G.AimbotConfig[key] = not _G.AimbotConfig[key]
            TS:Create(tb, TweenInfo.new(0.2), {BackgroundColor3 = _G.AimbotConfig[key] and S.toggleActiveColor or Color3.fromRGB(45,40,55)}):Play()
            TS:Create(tbl, TweenInfo.new(0.2), {Position = _G.AimbotConfig[key] and UDim2.new(0,17,0.5,-6) or UDim2.new(0,3,0.5,-6)}):Play()
        end)
    end

    -- AIM mode (toggle/hold)
    local amRow = makeRow(ap, 38)
    table.insert(aimSubs, amRow)
    amRow.BackgroundColor3 = Color3.fromRGB(26,22,36)
    local amLbl = Instance.new("TextLabel", amRow)
    amLbl.Size = UDim2.new(0, 100, 1, 0)
    amLbl.Position = UDim2.new(0, 10, 0, 0)
    amLbl.BackgroundTransparency = 1
    amLbl.Text = "AIM: Toggle"
    amLbl.TextColor3 = Color3.fromRGB(190,185,200)
    amLbl.Font = Enum.Font.Gotham
    amLbl.TextSize = 11
    amLbl.TextXAlignment = Enum.TextXAlignment.Left
    amLbl.ZIndex = 51
    local amBtn = Instance.new("TextButton", amRow)
    amBtn.Size = UDim2.new(0, 70, 0, 22)
    amBtn.Position = UDim2.new(1, -80, 0.5, -11)
    amBtn.BackgroundColor3 = Color3.fromRGB(168,85,247)
    amBtn.Text = "Toggle"
    amBtn.TextColor3 = Color3.fromRGB(255,255,255)
    amBtn.Font = Enum.Font.GothamBold
    amBtn.TextSize = 10
    amBtn.ZIndex = 52
    Instance.new("UICorner", amBtn).CornerRadius = UDim.new(0, 5)
    amBtn.MouseButton1Click:Connect(function()
        if S.aimMode == "toggle" then
            S.aimMode = "hold"
            amBtn.Text = "Hold"
            amLbl.Text = "AIM: Hold"
            S._aimHeld = false
            updateAimBtnVisual()
        else
            S.aimMode = "toggle"
            amBtn.Text = "Toggle"
            amLbl.Text = "AIM: Toggle"
            S._aimHeld = false
            updateAimBtnVisual()
        end
    end)

    makeAimToggle("wall_check", "WallCheck")
    -- TeamCheck always on, no toggle
    makeAimToggle("target_lock", "TargetLock")
    makeAimToggle("prediction", "Prediction")

    -- Anti-Recoil
    local arRow = makeRow(ap)
    table.insert(aimSubs, arRow)
    local arDot = makeDot(arRow)
    makeLabel(arRow, nil, "anti_recoil")
    local arBg, arBall = makeToggle(arRow)
    arBg.MouseButton1Click:Connect(function()
        S.antiRecoilEnabled = not S.antiRecoilEnabled
        animateToggle(arBg, arBall, arDot, S.antiRecoilEnabled)
        showNotification(t("anti_recoil"), S.antiRecoilEnabled and t("on") or t("off"), S.antiRecoilEnabled and Color3.fromRGB(0,255,150) or Color3.fromRGB(255,50,50))
    end)

    table.insert(aimSubs, makeSlider(ap, nil, 5, 100, 70, Color3.fromRGB(168,85,247), function(v)
        S.antiRecoilStrength = v / 100
    end, nil, "recoil_comp"))

    for _, sub in ipairs(aimSubs) do sub.Visible = false end
    S._aimSubs = aimSubs
end

eclipseLog("Aimbot tab ready")

-- ========== ВКЛАДКА COLORS ==========
do
    local cp = tabPanels["Colors"]
    Instance.new("UIListLayout", cp).Padding = UDim.new(0, 4)

    local tl = Instance.new("TextLabel", cp)
    tl.Size = UDim2.new(1, -6, 0, 24)
    tl.BackgroundTransparency = 1
    tl.Text = t("esp_visual_settings")
    registerLabel(tl, "esp_visual_settings")
    tl.TextColor3 = Color3.fromRGB(210,180,255)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 12
    tl.ZIndex = 51

    local presetColors = {
        Color3.fromRGB(255,255,255), Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0),
        Color3.fromRGB(0,120,255), Color3.fromRGB(255,255,0), Color3.fromRGB(255,0,255),
        Color3.fromRGB(0,255,255), Color3.fromRGB(255,120,0), Color3.fromRGB(255,80,150),
        Color3.fromRGB(120,255,80), Color3.fromRGB(80,80,255), Color3.fromRGB(200,200,200),
    }
    local roleLangKeys = {Police="role_police",Civilian="role_civilian",Friend="role_friend",Armed="role_armed"}
    for _, roleName in ipairs({"Police","Civilian","Friend","Armed"}) do
        local row = makeRow(cp, 44)
        local prev = Instance.new("Frame", row)
        prev.Name = "Preview"
        prev.Size = UDim2.new(0, 14, 0, 14)
        prev.Position = UDim2.new(0, 8, 0, 3)
        prev.BackgroundColor3 = S.ESPColors[roleName]
        prev.ZIndex = 52
        Instance.new("UICorner", prev).CornerRadius = UDim.new(1, 0)
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0, 80, 0, 16)
        lbl.Position = UDim2.new(0, 26, 0, 3)
        lbl.BackgroundTransparency = 1
        lbl.Text = t(roleLangKeys[roleName])
        registerLabel(lbl, roleLangKeys[roleName])
        lbl.TextColor3 = Color3.fromRGB(235,230,245)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 51
        local colFrame = Instance.new("Frame", row)
        colFrame.Size = UDim2.new(1, -10, 0, 14)
        colFrame.Position = UDim2.new(0, 6, 0, 24)
        colFrame.BackgroundTransparency = 1
        colFrame.ZIndex = 51
        local colLayout = Instance.new("UIListLayout", colFrame)
        colLayout.FillDirection = Enum.FillDirection.Horizontal
        colLayout.Padding = UDim.new(0, 3)
        for _, pc in ipairs(presetColors) do
            local cb = Instance.new("TextButton", colFrame)
            cb.Size = UDim2.new(0, 14, 0, 14)
            cb.BackgroundColor3 = pc
            cb.Text = ""
            cb.ZIndex = 52
            Instance.new("UICorner", cb).CornerRadius = UDim.new(1, 0)
            cb.MouseButton1Click:Connect(function()
                S.ESPColors[roleName] = pc
                prev.BackgroundColor3 = pc
                if S.espEnabled then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local cached = S.espCache[player.UserId]
                            if cached and cached.role == roleName then
                                cached.color = pc
                                local hl = player.Character:FindFirstChild("ESPHighlight")
                                if hl then hl.FillColor = pc end
                                local head = player.Character:FindFirstChild("Head")
                                if head then
                                    local tag = head:FindFirstChild("NameTag")
                                    if tag then
                                        local lbl2 = tag:FindFirstChild("TagLabel")
                                        if lbl2 then lbl2.TextColor3 = pc end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end

    -- ESP Gradient
    local egRow = makeRow(cp)
    makeDot(egRow)
    makeLabel(egRow, nil, "esp_gradient")
    local egBg, egBall = makeToggle(egRow)
    egBg.MouseButton1Click:Connect(function()
        S.espGradient = not S.espGradient
        animateToggle(egBg, egBall, nil, S.espGradient)
    end)

    -- FOV Gradient
    local fgRow = makeRow(cp)
    makeDot(fgRow)
    makeLabel(fgRow, nil, "fov_gradient")
    local fgBg, fgBall = makeToggle(fgRow)
    fgBg.MouseButton1Click:Connect(function()
        S.fovGradient = not S.fovGradient
        animateToggle(fgBg, fgBall, nil, S.fovGradient)
    end)

    -- Menu Accent Color
    local acRow = makeRow(cp, 44)
    local acLbl = Instance.new("TextLabel", acRow)
    acLbl.Size = UDim2.new(0, 120, 0, 16)
    acLbl.Position = UDim2.new(0, 8, 0, 3)
    acLbl.BackgroundTransparency = 1
    acLbl.Text = t("accent_color")
    registerLabel(acLbl, "accent_color")
    acLbl.TextColor3 = Color3.fromRGB(190, 185, 200)
    acLbl.Font = Enum.Font.Gotham
    acLbl.TextSize = 10
    acLbl.TextXAlignment = Enum.TextXAlignment.Left
    acLbl.ZIndex = 51
    local acFrame = Instance.new("Frame", acRow)
    acFrame.Size = UDim2.new(1, -10, 0, 14)
    acFrame.Position = UDim2.new(0, 6, 0, 24)
    acFrame.BackgroundTransparency = 1
    acFrame.ZIndex = 51
    Instance.new("UIListLayout", acFrame).FillDirection = Enum.FillDirection.Horizontal
    Instance.new("UIListLayout", acFrame).Padding = UDim.new(0, 3)
    for _, mc in ipairs(presetColors) do
        local cb = Instance.new("TextButton", acFrame)
        cb.Size = UDim2.new(0, 14, 0, 14)
        cb.BackgroundColor3 = mc
        cb.Text = ""
        cb.ZIndex = 52
        Instance.new("UICorner", cb).CornerRadius = UDim.new(1, 0)
        cb.MouseButton1Click:Connect(function()
            S.menuAccentColor = mc
            if S.glowGradient then
                S.glowGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, mc), ColorSequenceKeypoint.new(1, Color3.fromRGB(236,72,153))})
            end
            floatStroke.Color = mc
            for _, ch in ipairs(floatBtn:GetChildren()) do
                if ch:IsA("Frame") then ch.BackgroundColor3 = mc end
            end
            showNotification(t("accent_color"), t("notif_color_upd"), mc)
        end)
    end

    -- Toggle Color
    local tcRow = makeRow(cp, 44)
    local tcLbl = Instance.new("TextLabel", tcRow)
    tcLbl.Size = UDim2.new(0, 120, 0, 16)
    tcLbl.Position = UDim2.new(0, 8, 0, 3)
    tcLbl.BackgroundTransparency = 1
    tcLbl.Text = t("toggle_color")
    registerLabel(tcLbl, "toggle_color")
    tcLbl.TextColor3 = Color3.fromRGB(190, 185, 200)
    tcLbl.Font = Enum.Font.Gotham
    tcLbl.TextSize = 10
    tcLbl.TextXAlignment = Enum.TextXAlignment.Left
    tcLbl.ZIndex = 51
    local tcFrame = Instance.new("Frame", tcRow)
    tcFrame.Size = UDim2.new(1, -10, 0, 14)
    tcFrame.Position = UDim2.new(0, 6, 0, 24)
    tcFrame.BackgroundTransparency = 1
    tcFrame.ZIndex = 51
    Instance.new("UIListLayout", tcFrame).FillDirection = Enum.FillDirection.Horizontal
    Instance.new("UIListLayout", tcFrame).Padding = UDim.new(0, 3)
    for _, tc in ipairs(presetColors) do
        local cb = Instance.new("TextButton", tcFrame)
        cb.Size = UDim2.new(0, 14, 0, 14)
        cb.BackgroundColor3 = tc
        cb.Text = ""
        cb.ZIndex = 52
        Instance.new("UICorner", cb).CornerRadius = UDim.new(1, 0)
        cb.MouseButton1Click:Connect(function()
            S.toggleActiveColor = tc
            for _, tbg in ipairs(S.toggleRegistry) do
                if tbg and tbg.Parent then
                    local ball = tbg:FindFirstChildWhichIsA("Frame")
                    if ball and ball.Position.X.Offset > 10 then
                        tbg.BackgroundColor3 = tc
                    end
                end
            end
            showNotification(t("toggle_color"), t("notif_color_upd"), tc)
        end)
    end
end

eclipseLog("Colors tab ready")

-- ========== ВКЛАДКА SETTINGS ==========
do
    local sp = tabPanels["Settings"]
    Instance.new("UIListLayout", sp).Padding = UDim.new(0, 4)

    local tl = Instance.new("TextLabel", sp)
    tl.Size = UDim2.new(1, -6, 0, 24)
    tl.BackgroundTransparency = 1
    tl.Text = t("settings_title")
    registerLabel(tl, "settings_title")
    tl.TextColor3 = Color3.fromRGB(210,180,255)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 12
    tl.ZIndex = 51

    -- Language
    local lRow = makeRow(sp)
    local lLbl = Instance.new("TextLabel", lRow)
    lLbl.Size = UDim2.new(0, 100, 1, 0)
    lLbl.Position = UDim2.new(0, 10, 0, 0)
    lLbl.BackgroundTransparency = 1
    lLbl.Text = t("language")
    registerLabel(lLbl, "language")
    lLbl.TextColor3 = Color3.fromRGB(235,230,245)
    lLbl.Font = Enum.Font.GothamBold
    lLbl.TextSize = 12
    lLbl.TextXAlignment = Enum.TextXAlignment.Left
    lLbl.ZIndex = 51

    local ruBtn = Instance.new("TextButton", lRow)
    ruBtn.Size = UDim2.new(0, 60, 0, 22)
    ruBtn.Position = UDim2.new(1, -130, 0.5, -11)
    ruBtn.BackgroundColor3 = S.lang == "ru" and Color3.fromRGB(168,85,247) or Color3.fromRGB(40,35,50)
    ruBtn.Text = "RU"
    ruBtn.TextColor3 = Color3.fromRGB(255,255,255)
    ruBtn.Font = Enum.Font.GothamBold
    ruBtn.TextSize = 11
    ruBtn.ZIndex = 52
    Instance.new("UICorner", ruBtn).CornerRadius = UDim.new(0, 5)

    local enBtn = Instance.new("TextButton", lRow)
    enBtn.Size = UDim2.new(0, 60, 0, 22)
    enBtn.Position = UDim2.new(1, -65, 0.5, -11)
    enBtn.BackgroundColor3 = S.lang == "en" and Color3.fromRGB(168,85,247) or Color3.fromRGB(40,35,50)
    enBtn.Text = "EN"
    enBtn.TextColor3 = Color3.fromRGB(255,255,255)
    enBtn.Font = Enum.Font.GothamBold
    enBtn.TextSize = 11
    enBtn.ZIndex = 52
    Instance.new("UICorner", enBtn).CornerRadius = UDim.new(0, 5)

    ruBtn.MouseButton1Click:Connect(function()
        S.lang = "ru"
        ruBtn.BackgroundColor3 = Color3.fromRGB(168,85,247)
        enBtn.BackgroundColor3 = Color3.fromRGB(40,35,50)
        applyLanguage()
    end)
    enBtn.MouseButton1Click:Connect(function()
        S.lang = "en"
        enBtn.BackgroundColor3 = Color3.fromRGB(168,85,247)
        ruBtn.BackgroundColor3 = Color3.fromRGB(40,35,50)
        applyLanguage()
    end)
end

eclipseLog("Settings tab ready")

-- ========== ВКЛАДКА INFO ==========
do
    local ip = tabPanels["Info"]
    Instance.new("UIListLayout", ip).Padding = UDim.new(0, 4)

    local chLabel = Instance.new("TextLabel", ip)
    chLabel.Size = UDim2.new(1, 0, 0, 22)
    chLabel.BackgroundTransparency = 1
    chLabel.Text = t("info_channel")
    registerLabel(chLabel, "info_channel")
    chLabel.TextColor3 = Color3.fromRGB(200, 195, 215)
    chLabel.Font = Enum.Font.GothamBold
    chLabel.TextSize = 12
    chLabel.TextXAlignment = Enum.TextXAlignment.Left
    chLabel.ZIndex = 51

    local linkBox = Instance.new("Frame", ip)
    linkBox.Size = UDim2.new(1, 0, 0, 32)
    linkBox.BackgroundColor3 = Color3.fromRGB(30, 24, 42)
    linkBox.ZIndex = 50
    Instance.new("UICorner", linkBox).CornerRadius = UDim.new(0, 6)

    local linkLabel = Instance.new("TextLabel", linkBox)
    linkLabel.Size = UDim2.new(1, -10, 1, 0)
    linkLabel.Position = UDim2.new(0, 5, 0, 0)
    linkLabel.BackgroundTransparency = 1
    linkLabel.Text = "https://t.me/eclipse_script"
    linkLabel.TextColor3 = Color3.fromRGB(130, 170, 255)
    linkLabel.Font = Enum.Font.GothamMedium
    linkLabel.TextSize = 11
    linkLabel.TextXAlignment = Enum.TextXAlignment.Left
    linkLabel.ZIndex = 51

    local copyBtn = Instance.new("TextButton", ip)
    copyBtn.Size = UDim2.new(1, 0, 0, 28)
    copyBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
    copyBtn.Text = "Copy Link"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 11
    copyBtn.ZIndex = 52
    Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 5)
    copyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://t.me/eclipse_script") end)
        showNotification("Link", "Copied!", Color3.fromRGB(0, 255, 150))
    end)

    local hintLabel = Instance.new("TextLabel", ip)
    hintLabel.Size = UDim2.new(1, 0, 0, 16)
    hintLabel.BackgroundTransparency = 1
    hintLabel.Text = t("info_copy_hint")
    registerLabel(hintLabel, "info_copy_hint")
    hintLabel.TextColor3 = Color3.fromRGB(100, 95, 115)
    hintLabel.Font = Enum.Font.Gotham
    hintLabel.TextSize = 9
    hintLabel.TextXAlignment = Enum.TextXAlignment.Left
    hintLabel.ZIndex = 51

    local subLabel = Instance.new("TextLabel", ip)
    subLabel.Size = UDim2.new(1, 0, 0, 28)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = "Подписывайтесь на ТГ, там будут новости и обновления!"
    subLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    subLabel.Font = Enum.Font.GothamBold
    subLabel.TextSize = 10
    subLabel.TextWrapped = true
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.ZIndex = 51
end

eclipseLog("Info tab ready")

-- ========== РЕНДЕР-ЦИКЛЫ ==========
-- FOV Circle
do
    local ok, circle = pcall(function()
        local c = Drawing.new("Circle")
        c.Radius = _G.AimbotConfig.FOV
        c.Color = Color3.fromRGB(0, 255, 150)
        c.Thickness = 1.5
        c.Filled = false
        c.Transparency = _G.AimbotConfig.CircleTransparency
        c.Visible = false
        return c
    end)
    if ok and circle then S.FOVCircle = circle end
end

-- Aimbot (Scriptable camera for mobile)
S._aimWasScriptable = false
RS:BindToRenderStep("EclipseAimbot", Enum.RenderPriority.Camera.Value + 1, function()
    if not S.scriptActive or not _G.AimbotConfig.IsRunning then return end
    local cfg = _G.AimbotConfig
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    if S.FOVCircle then
        pcall(function()
            S.FOVCircle.Position = center
            S.FOVCircle.Radius = cfg.FOV
            S.FOVCircle.Visible = cfg.Enabled and cfg.ShowFOVCircle
        end)
    end
    if not cfg.Enabled then
        if S._aimWasScriptable then
            Camera.CameraType = Enum.CameraType.Custom
            S._aimWasScriptable = false
        end
        S.lockedTarget = nil
        return
    end
    if S._aimHeld then
        if cfg.TargetLock and S.lockedTarget then
            if not isValidTarget(S.lockedTarget) then S.lockedTarget = nil end
        end
        if not S.lockedTarget or not cfg.TargetLock then
            local best, bestDist = nil, math.huge
            for _, pl in ipairs(Players:GetPlayers()) do
                if isValidTarget(pl) then
                    local aPart = getAimPart(pl.Character)
                    if aPart then
                        local dist3d = (Camera.CFrame.Position - aPart.Position).Magnitude
                        if dist3d <= cfg.MaxDistance then
                            if isVisible(aPart) then
                                local pos, onScr = Camera:WorldToViewportPoint(aPart.Position)
                                if onScr then
                                    local sd = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                                    if sd < cfg.FOV and sd < bestDist then best = pl bestDist = sd end
                                end
                            end
                        end
                    end
                end
            end
            S.lockedTarget = best
        end
        if S.lockedTarget and S.lockedTarget.Character then
            local aPart = getAimPart(S.lockedTarget.Character)
            if aPart then
                local pos = aPart.Position
                if cfg.Prediction then
                    local vel = Vector3.zero
                    pcall(function() vel = aPart.AssemblyLinearVelocity or Vector3.zero end)
                    local dist = (Camera.CFrame.Position - pos).Magnitude
                    pos = pos + vel * cfg.PredictionFactor * (dist / 100)
                end
                if not S._aimWasScriptable then
                    Camera.CameraType = Enum.CameraType.Scriptable
                    S._aimWasScriptable = true
                end
                local camPos = Camera.CFrame.Position
                local targetCF = CFrame.new(camPos, pos)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, cfg.Smoothness)
            end
        end
    else
        if S._aimWasScriptable then
            Camera.CameraType = Enum.CameraType.Custom
            S._aimWasScriptable = false
        end
        S.lockedTarget = nil
    end
end)

-- Anti-Recoil
do
    local hasMMR = false
    pcall(function() hasMMR = type(mousemoverel) == "function" end)
    RS:BindToRenderStep("EclipseMobileAntiRecoil", Enum.RenderPriority.Camera.Value + 20, function()
        if not S.scriptActive then
            pcall(function() RS:UnbindFromRenderStep("EclipseMobileAntiRecoil") end)
            return
        end
        if not S.antiRecoilEnabled then S.arPrevPitch = nil return end
        local mb1 = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        if mb1 then
            local lv = Camera.CFrame.LookVector
            local currentPitch = math.asin(-lv.Y)
            if S.arPrevPitch then
                local delta = currentPitch - S.arPrevPitch
                if delta < -0.0003 then
                    local recoilAmount = -delta
                    local mult = 1800
                    local px = recoilAmount * mult * S.antiRecoilStrength
                    if hasMMR then
                        mousemoverel(0, px)
                    else
                        local cPos = Camera.CFrame.Position
                        local yaw = math.atan2(lv.X, lv.Z)
                        local newPitch = currentPitch + recoilAmount * S.antiRecoilStrength
                        local nl = Vector3.new(math.cos(newPitch)*math.sin(yaw), -math.sin(newPitch), math.cos(newPitch)*math.cos(yaw))
                        Camera.CFrame = CFrame.lookAt(cPos, cPos + nl, Vector3.new(0,1,0))
                    end
                end
            end
            S.arPrevPitch = math.asin(-Camera.CFrame.LookVector.Y)
        else
            S.arPrevPitch = nil
        end
    end)
    table.insert(S.connections, {Disconnect = function() pcall(function() RS:UnbindFromRenderStep("EclipseMobileAntiRecoil") end) end})
end

-- Fly
table.insert(S.connections, RS.Heartbeat:Connect(function(dt)
    if not S.scriptActive or not S.flyEnabled then return end
    local c = LocalPlayer.Character
    if not c then return end
    local hr = c:FindFirstChild("HumanoidRootPart")
    local hm = c:FindFirstChildOfClass("Humanoid")
    if not hr or not hm then return end
    local vSpd = S.flySpeed
    if S.flyBV then
        local vertDir = 0
        S.flyBV.Velocity = Vector3.new(0, vertDir * vSpd, 0)
    end
    local hDir = Vector3.zero
    local lv = Camera.CFrame.LookVector
    local flatLook = Vector3.new(lv.X, 0, lv.Z)
    if flatLook.Magnitude > 0.01 then flatLook = flatLook.Unit end
    if hm.MoveDirection.Magnitude > 0.1 then
        hDir = hm.MoveDirection
    end
    if hDir.Magnitude > 0.1 then
        hr.CFrame = hr.CFrame + hDir.Unit * vSpd * dt
    end
    if S.flyFakePart then
        S.flyFakePart.CFrame = hr.CFrame * CFrame.new(0, -3.5, 0)
    end
end))

-- Noclip
do
    local ncParts = {}
    local ncChar = nil
    table.insert(S.connections, RS.Stepped:Connect(function()
        if not S.scriptActive or not S.noclipEnabled then return end
        local c = LocalPlayer.Character
        if not c then return end
        if c ~= ncChar then
            ncChar = c
            ncParts = {}
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then ncParts[#ncParts+1] = p end
            end
        end
        for _, p in ipairs(ncParts) do p.CanCollide = false end
        local hm = c:FindFirstChildOfClass("Humanoid")
        if hm and hm.SeatPart then
            local veh = hm.SeatPart:FindFirstAncestorWhichIsA("Model")
            if veh then
                for _, p in ipairs(veh:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if S.noclipOrigCollisions[p] == nil then S.noclipOrigCollisions[p] = p.CanCollide end
                        p.CanCollide = false
                    end
                end
            end
        end
    end))
end

-- Vehicle Speed
do
    local vehBV = nil
    local lastSeat = nil
    table.insert(S.connections, RS.Heartbeat:Connect(function(dt)
        if not S.scriptActive or not S.vehSpeedEnabled then
            if vehBV then pcall(function() vehBV:Destroy() end) vehBV = nil lastSeat = nil end
            return
        end
        local c = LocalPlayer.Character
        if not c then return end
        local hm = c:FindFirstChildOfClass("Humanoid")
        if not hm or not hm.SeatPart then
            if vehBV then pcall(function() vehBV:Destroy() end) vehBV = nil lastSeat = nil end
            return
        end
        local seat = hm.SeatPart
        local veh = seat:FindFirstAncestorWhichIsA("Model")
        if not veh then return end
        local pp = veh.PrimaryPart or seat
        if seat:IsA("VehicleSeat") then
            if not S.vehOrigSpeeds[seat] then S.vehOrigSpeeds[seat] = seat.MaxSpeed end
            pcall(function() seat.MaxSpeed = S.vehOrigSpeeds[seat] * S.vehSpeedMult end)
        end
        local v = pp.AssemblyLinearVelocity
        local hv = Vector3.new(v.X, 0, v.Z)
        local throttle = 0
        if seat:IsA("VehicleSeat") then throttle = seat.ThrottleFloat or 0 end
        if hv.Magnitude > 1 or math.abs(throttle) > 0.1 then
            if lastSeat ~= seat then
                if vehBV then pcall(function() vehBV:Destroy() end) end
                vehBV = Instance.new("BodyVelocity")
                vehBV.MaxForce = Vector3.new(math.huge, 0, math.huge)
                vehBV.P = 1250
                vehBV.Parent = pp
                lastSeat = seat
            end
            if vehBV and vehBV.Parent then
                local dir
                if hv.Magnitude > 1 then dir = hv.Unit else dir = pp.CFrame.LookVector * (throttle > 0 and 1 or -1) end
                local baseSpeed = math.max(hv.Magnitude, 20)
                local targetSpeed = baseSpeed * S.vehSpeedMult
                vehBV.Velocity = Vector3.new(dir.X * targetSpeed, v.Y, dir.Z * targetSpeed)
            end
        else
            if vehBV and vehBV.Parent then vehBV.Velocity = Vector3.new(0, 0, 0) end
        end
    end))
end

-- ESP Update
do local espTimer = 0
table.insert(S.connections, RS.Heartbeat:Connect(function(dt)
    if not S.scriptActive or not S.espEnabled then return end
    espTimer = espTimer + dt
    if espTimer < 0.1 then return end
    espTimer = 0
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = getHumanoid(player.Character)
            if head and hum then
                local tag = head:FindFirstChild("NameTag")
                local label = tag and tag:FindFirstChild("TagLabel")
                if label then
                    local eRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    local dist = myRoot and eRoot and (myRoot.Position - eRoot.Position).Magnitude or 0
                    local txt = player.DisplayName
                    if S.showDistance then txt = txt.." | "..string.format("%.0f", dist).."m" end
                    if S.showHealth then txt = txt.." | "..math.floor(hum.Health).."hp" end
                    label.Text = txt
                    local cached = S.espCache[player.UserId]
                    if cached then label.TextColor3 = cached.color end
                    local hpFill = tag:FindFirstChild("HPBarBg") and tag.HPBarBg:FindFirstChild("HPBarFill")
                    if hpFill then
                        local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        hpFill.Size = UDim2.new(hp, 0, 1, 0)
                        hpFill.BackgroundColor3 = hp > 0.5 and Color3.fromRGB(0,255,0) or Color3.fromRGB(255, math.round(255*hp*2), 0)
                    end
                end
            end
        end
    end
end)) end

-- Threat Lines
do
    local tlTimer = 0
    table.insert(S.connections, RS.Heartbeat:Connect(function(dt)
        if not S.scriptActive or not S.threatLines then
            if next(S.threatLineCache) then
                for _, line in pairs(S.threatLineCache) do pcall(function() line:Remove() end) end
                S.threatLineCache = {}
            end
            return
        end
        tlTimer = tlTimer + dt
        if tlTimer < 0.05 then return end
        tlTimer = 0
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local active = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local showLine = false
                local lineColor = Color3.fromRGB(255, 50, 50)
                local role = getPlayerRole(player)
                local isPoliceRole = (role == "Police")
                local isCivRole = (role == "Civilian" or role == "Armed")
                if S.threatLineArmed and isArmed(player) then
                    if isCivRole or (isPoliceRole and S.threatLinePolice) then
                        showLine = true
                        lineColor = Color3.fromRGB(255, 50, 50)
                    end
                end
                if S.threatLineWanted then
                    local atEntry = S.autoTabletResults and S.autoTabletResults[player.UserId]
                    if atEntry and atEntry.wantedLevel > 0 then
                        if isCivRole or (isPoliceRole and S.threatLinePolice) then
                            showLine = true
                            lineColor = Color3.fromRGB(255, 200, 0)
                        end
                    end
                end
                if S.threatLinePolice and isPoliceRole and not showLine then
                    showLine = true
                    lineColor = Color3.fromRGB(0, 150, 255)
                end
                if showLine then
                    local pRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if pRoot then
                        local pos, onScreen = Camera:WorldToViewportPoint(pRoot.Position)
                        if onScreen then
                            active[player.UserId] = true
                            local line = S.threatLineCache[player.UserId]
                            if not line then
                                local ok2, l = pcall(function()
                                    local li = Drawing.new("Line")
                                    li.Thickness = 1.5
                                    li.Color = Color3.fromRGB(255, 50, 50)
                                    li.Transparency = 0.7
                                    li.Visible = true
                                    return li
                                end)
                                if ok2 and l then line = l S.threatLineCache[player.UserId] = line end
                            end
                            if line then
                                line.From = screenCenter
                                line.To = Vector2.new(pos.X, pos.Y)
                                line.Color = lineColor
                                line.Visible = true
                            end
                        else
                            if S.threatLineCache[player.UserId] then S.threatLineCache[player.UserId].Visible = false end
                        end
                    end
                end
            end
        end
        for uid, line in pairs(S.threatLineCache) do
            if not active[uid] then
                pcall(function() line:Remove() end)
                S.threatLineCache[uid] = nil
            end
        end
    end))
end

-- Auto Tablet
do
    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("__remotes")
    local tabletFolder = remotes and remotes:FindFirstChild("Tablet")
    local atTimer = 0
    local checkedPlayers = {}
    local atResults = {}
    S.autoTabletResults = atResults

    local atPanel = Instance.new("Frame")
    atPanel.Name = "AutoTabletPanel"
    atPanel.Size = UDim2.new(0, 200, 0, 240)
    atPanel.Position = UDim2.new(1, -210, 0, 50)
    atPanel.BackgroundColor3 = Color3.fromRGB(15, 12, 20)
    atPanel.BackgroundTransparency = 0.15
    atPanel.BorderSizePixel = 0
    atPanel.Visible = false
    atPanel.Parent = screenGui
    Instance.new("UICorner", atPanel).CornerRadius = UDim.new(0, 8)

    local atTitle = Instance.new("TextLabel", atPanel)
    atTitle.Size = UDim2.new(1, 0, 0, 24)
    atTitle.BackgroundTransparency = 1
    atTitle.Text = t("at_title")
    registerLabel(atTitle, "at_title")
    atTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
    atTitle.Font = Enum.Font.GothamBold
    atTitle.TextSize = 11

    local atScroll = Instance.new("ScrollingFrame", atPanel)
    atScroll.Size = UDim2.new(1, -8, 1, -28)
    atScroll.Position = UDim2.new(0, 4, 0, 26)
    atScroll.BackgroundTransparency = 1
    atScroll.BorderSizePixel = 0
    atScroll.ScrollBarThickness = 2
    atScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    atScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", atScroll).Padding = UDim.new(0, 2)

    local function updateAtPanel()
        for _, ch in ipairs(atScroll:GetChildren()) do
            if ch:IsA("TextLabel") then ch:Destroy() end
        end
        local count = 0
        for _, entry in pairs(atResults) do
            count = count + 1
            local row = Instance.new("TextLabel", atScroll)
            row.Size = UDim2.new(1, 0, 0, 18)
            row.BackgroundTransparency = 1
            row.Font = Enum.Font.Gotham
            row.TextSize = 10
            row.TextXAlignment = Enum.TextXAlignment.Left
            if entry.wantedLevel == -1 then
                row.Text = "  ? "..entry.displayName.." — "..t("at_timeout")
                row.TextColor3 = Color3.fromRGB(150, 150, 150)
            elseif entry.wantedLevel > 0 then
                row.Text = "  ! "..entry.displayName.." — "..t("at_wanted").." "..entry.wantedLevel
                row.TextColor3 = Color3.fromRGB(255, 60, 60)
                if entry.warranted then
                    row.Text = row.Text.." "..t("at_warrant")
                    row.TextColor3 = Color3.fromRGB(255, 100, 0)
                end
            else
                row.Text = "  OK "..entry.displayName.." — "..t("at_clean")
                row.TextColor3 = Color3.fromRGB(100, 255, 100)
            end
        end
        atPanel.Visible = S.autoTablet and count > 0
    end

    local doorHighlights = {}
    local function getApartmentOwners()
        local owners = {}
        pcall(function()
            local aptFolder = WS:FindFirstChild("Apartments")
            if not aptFolder then return end
            local nameplates = aptFolder:FindFirstChild("Nameplates")
            if not nameplates then return end
            for _, np in ipairs(nameplates:GetChildren()) do
                for _, ch in ipairs(np:GetDescendants()) do
                    if ch:IsA("TextLabel") then
                        local txt = ch.Text:match("^%s*(.-)%s*$")
                        if txt and txt ~= "" and txt ~= "Unoccupied" then
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p ~= LocalPlayer and (p.Name == txt or p.DisplayName == txt) then
                                    owners[p.UserId] = {player = p, nameplate = np}
                                end
                            end
                        end
                    end
                end
            end
        end)
        return owners
    end

    local function findDoorForNameplate(nameplate)
        local aptFolder = WS:FindFirstChild("Apartments")
        if not aptFolder then return nil end
        local doors = aptFolder:FindFirstChild("Doors")
        if not doors then return nil end
        local door = doors:FindFirstChild(nameplate.Name)
        if door then return door end
        local npPos
        for _, part in ipairs(nameplate:GetDescendants()) do
            if part:IsA("BasePart") then npPos = part.Position break end
        end
        if not npPos then return nil end
        local closest, closestDist = nil, 20
        for _, d in ipairs(doors:GetChildren()) do
            for _, part in ipairs(d:GetDescendants()) do
                if part:IsA("BasePart") then
                    local dist = (part.Position - npPos).Magnitude
                    if dist < closestDist then closestDist = dist closest = d end
                    break
                end
            end
        end
        return closest
    end

    local function highlightDoor(uid, nameplate, wanted)
        if wanted then
            if not doorHighlights[uid] then
                local door = findDoorForNameplate(nameplate)
                if door then
                    local hl = Instance.new("Highlight")
                    hl.Name = "NeonDoorHL"
                    hl.FillColor = Color3.fromRGB(255, 50, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0.1
                    hl.Parent = door
                    doorHighlights[uid] = hl
                end
            end
        else
            if doorHighlights[uid] then
                pcall(function() doorHighlights[uid]:Destroy() end)
                doorHighlights[uid] = nil
            end
        end
    end

    table.insert(S.connections, RS.Heartbeat:Connect(function(dt)
        if not S.scriptActive or not S.autoTablet then
            atPanel.Visible = false
            for uid3, hl in pairs(doorHighlights) do pcall(function() hl:Destroy() end) doorHighlights[uid3] = nil end
            return
        end
        if not tabletFolder then
            pcall(function()
                remotes = game:GetService("ReplicatedStorage"):FindFirstChild("__remotes")
                tabletFolder = remotes and remotes:FindFirstChild("Tablet")
            end)
            if not tabletFolder then return end
        end
        atTimer = atTimer + dt
        if atTimer < S.autoTabletInterval then return end
        atTimer = 0
        local slotKey = ({
            [0] = Enum.KeyCode.Zero, [1] = Enum.KeyCode.One, [2] = Enum.KeyCode.Two,
            [3] = Enum.KeyCode.Three, [4] = Enum.KeyCode.Four, [5] = Enum.KeyCode.Five,
            [6] = Enum.KeyCode.Six, [7] = Enum.KeyCode.Seven, [8] = Enum.KeyCode.Eight,
            [9] = Enum.KeyCode.Nine,
        })[S.tabletSlot]
        if slotKey then
            local myChar = LocalPlayer.Character
            local holding = myChar and myChar:FindFirstChildOfClass("Tool")
            local isTablet = holding and holding.Name:lower():find("tablet")
            if not isTablet then
                pcall(function()
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, slotKey, false, game)
                    task.wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, slotKey, false, game)
                end)
                task.wait(0.3)
            end
        end
        local searchWarrant = tabletFolder:FindFirstChild("SearchWarrantTarget")
        local obtainWarrant = tabletFolder:FindFirstChild("ObtainSearchWarrant")
        if not searchWarrant or not obtainWarrant then
            showNotification(t("auto_tablet"), t("notif_remotes_nf"), Color3.fromRGB(255,80,80))
            return
        end
        local apartOwners = getApartmentOwners()
        local targets = {}
        if next(apartOwners) then
            targets = apartOwners
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then targets[p.UserId] = {player = p, nameplate = nil} end
            end
        end
        atPanel.Visible = true
        for uid, info in pairs(targets) do
            if not checkedPlayers[uid] then
                checkedPlayers[uid] = tick()
                local player = info.player
                local nameplate = info.nameplate
                task.spawn(function()
                    local result = nil
                    local done = false
                    task.spawn(function()
                        local ok2, r = pcall(function() return searchWarrant:InvokeServer(player.Name) end)
                        if ok2 then result = r end
                        done = true
                    end)
                    local waited = 0
                    while not done and waited < 5 do task.wait(0.2) waited = waited + 0.2 end
                    if not done then
                        atResults[uid] = {displayName = player.DisplayName, wantedLevel = -1, hasWarrant = false, warranted = false}
                        updateAtPanel()
                        return
                    end
                    if type(result) == "table" and result.Found then
                        local wantedLevel = result.WantedLevel or 0
                        local hasWarrant = result.HasWarrant or false
                        atResults[uid] = {
                            displayName = result.DisplayName or player.DisplayName,
                            wantedLevel = wantedLevel,
                            hasWarrant = hasWarrant,
                            warranted = false,
                        }
                        if wantedLevel > 0 and not hasWarrant then
                            pcall(function() obtainWarrant:InvokeServer(player.Name) end)
                            atResults[uid].warranted = true
                            showNotification(t("auto_tablet"), t("at_warrant_notif")..": "..player.DisplayName.." ("..wantedLevel..")", Color3.fromRGB(255,100,0))
                        end
                        if nameplate then highlightDoor(uid, nameplate, wantedLevel > 0) end
                        updateAtPanel()
                    end
                end)
            end
        end
        local now = tick()
        for uid2, t2 in pairs(checkedPlayers) do
            if now - t2 > 60 then checkedPlayers[uid2] = nil atResults[uid2] = nil highlightDoor(uid2, nil, false) end
        end
        updateAtPanel()
        if slotKey then
            task.spawn(function()
                task.wait(0.5)
                local myChar2 = LocalPlayer.Character
                local holding2 = myChar2 and myChar2:FindFirstChildOfClass("Tool")
                if holding2 and holding2.Name:lower():find("tablet") then
                    pcall(function()
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, slotKey, false, game)
                        task.wait(0.1)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, slotKey, false, game)
                    end)
                end
            end)
        end
    end))
end

-- Speed Boost
table.insert(S.connections, RS.Heartbeat:Connect(function(dt)
    if not S.scriptActive or not S.speedBoostEnabled then return end
    local c = LocalPlayer.Character
    if not c then return end
    local hr = c:FindFirstChild("HumanoidRootPart")
    local hm = c:FindFirstChildOfClass("Humanoid")
    if not hr or not hm then return end
    if hm.MoveDirection.Magnitude > 0.1 then
        local boost = hm.MoveDirection * (S.speedBoostMult - 1) * 16 * dt * 3
        hr.CFrame = hr.CFrame + boost
    end
end))

-- Jump Boost
do
    local wasOnGround = true
    table.insert(S.connections, RS.Heartbeat:Connect(function()
        if not S.scriptActive or not S.jumpBoostEnabled then return end
        local c = LocalPlayer.Character
        if not c then return end
        local hr = c:FindFirstChild("HumanoidRootPart")
        local hm = c:FindFirstChildOfClass("Humanoid")
        if not hr or not hm then return end
        local onGround = hm.FloorMaterial ~= Enum.Material.Air
        if wasOnGround and not onGround then
            local extraUp = (S.jumpBoostMult - 1) * 35
            hr.Velocity = hr.Velocity + Vector3.new(0, extraUp, 0)
        end
        wasOnGround = onGround
    end))
end

-- Role cache update
task.spawn(function()
    while S.scriptActive do
        task.wait(2)
        if S.espEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local role, color = getPlayerRole(player)
                    S.espCache[player.UserId] = {role=role, color=color}
                    local hl = player.Character:FindFirstChild("ESPHighlight")
                    if hl then hl.FillColor = color end
                end
            end
        end
    end
end)

-- Player handlers
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.3)
        if S.espEnabled and S.scriptActive then setupESPForPlayer(player) end
    end)
end
for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then onPlayerAdded(p) end end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(removeESPForPlayer)

-- Градиенты
task.spawn(function()
    local hue = 0
    local carHue = 0
    local carScanTimer = 0
    while S.scriptActive do
        task.wait(0.05)
        hue = (hue + 0.004) % 1
        if S.fovGradient and S.FOVCircle then
            pcall(function() S.FOVCircle.Color = Color3.fromHSV(hue, 1, 1) end)
        end
        if S.espGradient and S.espEnabled then
            local gc = Color3.fromHSV(hue, 0.8, 1)
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local cached = S.espCache[player.UserId]
                    local role = cached and cached.role or "Civilian"
                    if S.espGradientRoles[role] then
                        local hl = player.Character:FindFirstChild("ESPHighlight")
                        if hl then
                            if S.espGradientMode == "outline" then hl.OutlineColor = gc else hl.FillColor = gc end
                        end
                    end
                end
            end
        end
    end
end)

showNotification("ECLIPSE v2", "Mobile Edition loaded", Color3.fromRGB(168,85,247))
eclipseLog("ECLIPSE v2 Mobile fully loaded!")
