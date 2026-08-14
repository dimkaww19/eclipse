-- ECLIPSE v2 — Solara V3 Compatible
-- Структура разбита на do..end блоки чтобы не превышать лимит 200 локалов

local function eclipseLog(msg)
    pcall(function() warn("[ECLIPSE] " .. tostring(msg)) end)
end
eclipseLog("Starting...")


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

-- Удаление старого GUI
pcall(function()
    for _, p in ipairs({LocalPlayer:WaitForChild("PlayerGui"), game:GetService("CoreGui")}) do
        local old = p:FindFirstChild("Eclipse_Internal")
        if old then old:Destroy() task.wait(0.1) end
    end
end)

eclipseLog("Services loaded")

-- ========== SHARED STATE ==========
local S = {} -- все состояния в одной таблице
if getgenv then getgenv().S = S end
S.scriptActive = true
S.menuVisible = true
S.isWaitingBind = false
S.connections = {}
S.espEnabled = false
S.espBindKey = nil
S.showHealth = true
S.showDistance = true
S.friendsOnly = false
S.fbEnabled = false
S.fbBindKey = nil
S.wallClipEnabled = false
S.wallClipBindKey = nil
S.afkEnabled = false
S.afkBindKey = nil
S.afkThread = nil
S.antiRecoilEnabled = false
S.antiRecoilStrength = 0.7
S.lastAimCF = nil
S.menuBindKey = nil
S.flyEnabled = false
S.flyFakePart = nil
S.flyBindKey = nil
S.flySpeed = 60
S.flyBV = nil
S.flyBG = nil
S.noclipEnabled = false
S.noclipBindKey = nil
S.noclipOrigCollisions = {}
S.vehSpeedEnabled = false
S.vehSpeedBindKey = nil
S.vehSpeedMult = 2.0
S.vehOrigSpeeds = {}
S.espCache = {}
S.currentTab = "Visuals"
S.speedBoostEnabled = false
S.speedBoostMult = 2
S.speedBoostBindKey = nil
S.jumpBoostEnabled = false
S.jumpBoostMult = 2
S.jumpBoostBindKey = nil
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
        menu_btn = "Кнопка меню", rejoin = "Реджоин", rejoin_btn = "РЕДЖОИН",
        anti_afk = "Анти-АФК", cam_zoom = "Зум камеры",
        auto_tablet = "Авто планшет", scan_interval = "Интервал (сек)",
        tablet_slot = "Слот планшета", taser_tp = "Тазер ТП", taser_btn = "ТАЗЕР",
        tab_farm = "Фарм",
        fov_color = "Цвет круга FOV",
        auto_farm = "Авто фарм", farm_rings = "Колец", farm_status_buy = "Покупаю кольцо", farm_buy_weapons = "Купить оружие", farm_status_sell = "Продаю...", farm_status_launder = "Отмываю...", farm_status_walk = "Лечу к точке...", farm_cycles = "Циклов",
        aimbot = "Аимбот", aim_part = "Часть тела", toggle_btn = "Сменить",
        fov_circle = "Круг FOV", smoothness = "Плавность",
        max_dist = "Макс. дистанция", dist_btn = "Далее",
        wall_check = "Проверка стен", team_check = "Проверка команды",
        target_lock = "Захват цели", prediction = "Предсказание",
        fast_reload = "Быстрая перезарядка", fast_shoot = "Быстрая стрельба",
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
        tab_visuals = "Визуалы", tab_movement = "Движение", tab_misc = "Разное",
        tab_aimbot = "Аимбот", tab_colors = "Цвета", tab_settings = "Настройки", tab_info = "Инфо",
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
        menu_btn = "Menu Button", rejoin = "Rejoin", rejoin_btn = "REJOIN",
        anti_afk = "Anti-AFK", cam_zoom = "Camera Zoom",
        auto_tablet = "Auto Tablet", scan_interval = "Scan Interval (s)",
        tablet_slot = "Tablet Slot", taser_tp = "Taser TP", taser_btn = "TASE",
        tab_farm = "Farm",
        fov_color = "FOV Circle Color",
        auto_farm = "Auto Farm", farm_rings = "Rings", farm_status_buy = "Buying ring", farm_buy_weapons = "Buy Weapons", farm_status_sell = "Selling...", farm_status_launder = "Laundering...", farm_status_walk = "Flying to point...", farm_cycles = "Cycles",
        aimbot = "Aimbot", aim_part = "Aim Part", toggle_btn = "Toggle",
        fov_circle = "FOV Circle", smoothness = "Smoothness",
        max_dist = "Max Distance", dist_btn = "Cycle",
        wall_check = "Wall Check", team_check = "Team Check",
        target_lock = "Target Lock", prediction = "Prediction",
        fast_reload = "Fast Reload", fast_shoot = "Fast Shoot",
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
        tab_visuals = "Visuals", tab_movement = "Movement", tab_misc = "Misc",
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
eclipseLog("FullBright ready")

-- ========== AIMBOT CONFIG ==========
_G.AimbotConfig = _G.AimbotConfig or {
    Enabled = false,
    AimParts = {"Head", "UpperTorso", "HumanoidRootPart", "Torso"},
    SelectedAimPart = 1,
    FOV = 90,
    CircleTransparency = 0.5,
    AimBind = Enum.UserInputType.MouseButton2,
    MaxDistance = 200,
    Smoothness = 0.18,
    WallCheck = false,
    TeamCheck = false,
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
            for _, t in ipairs(player.Backpack:GetChildren()) do
                local tn2 = t.Name:lower()
                for _, kw in ipairs(policeToolKW) do if tn2:find(kw) then return true end end
            end
        end
    end
    return false
end

local function isArmed(player)
    if not player.Character then return false end
    for _, ch in ipairs(player.Character:GetChildren()) do
        if ch:IsA("Tool") then
            local tn = ch.Name:lower()
            for _, kw in ipairs(weaponKW) do if tn:find(kw) then return true end end
        end
    end
    return false
end

local function getPlayerRole(player)
    local friend = false
    pcall(function() friend = LocalPlayer:IsFriendsWith(player.UserId) end)
    if S.friendsOnly and friend then return "Friend", S.ESPColors.Friend end
    if isPolice(player) then return "Police", S.ESPColors.Police end
    if isArmed(player) then return "Armed", S.ESPColors.Armed end
    return "Civilian", S.ESPColors.Civilian
end

-- ========== AIMBOT ФУНКЦИИ ==========
local function getAimPart(char)
    local cfg = _G.AimbotConfig
    local p = char:FindFirstChild(cfg.AimParts[cfg.SelectedAimPart])
    if p then return p end
    for _, n in ipairs(cfg.AimParts) do p = char:FindFirstChild(n) if p then return p end end
    for _, ch in ipairs(char:GetChildren()) do if ch:IsA("BasePart") and ch.Name ~= "Handle" then return ch end end
    return nil
end

local function getHumanoid(char)
    return char:FindFirstChildOfClass("Humanoid")
end

local function isVisible(part)
    if not _G.AimbotConfig.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local f = {}
    if LocalPlayer.Character then table.insert(f, LocalPlayer.Character) end
    params.FilterDescendantsInstances = f
    params.IgnoreWater = true
    local r = WS:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
    if r then return r.Instance:IsDescendantOf(part.Parent) end
    return true
end

local function isValidTarget(player)
    if player == LocalPlayer or not player.Character then return false end
    local cfg = _G.AimbotConfig
    if cfg.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    local h = getHumanoid(player.Character)
    if not h or h.Health <= 0 then return false end
    return getAimPart(player.Character) ~= nil
end

local aimHeld = false
UIS.InputBegan:Connect(function(inp, gpe)
    local b = _G.AimbotConfig.AimBind
    if typeof(b) == "EnumItem" then
        if (b.EnumType == Enum.UserInputType and inp.UserInputType == b) or
           (b.EnumType == Enum.KeyCode and inp.KeyCode == b) then
            aimHeld = true
        end
    end
end)
UIS.InputEnded:Connect(function(inp)
    local b = _G.AimbotConfig.AimBind
    if typeof(b) == "EnumItem" then
        if (b.EnumType == Enum.UserInputType and inp.UserInputType == b) or
           (b.EnumType == Enum.KeyCode and inp.KeyCode == b) then
            aimHeld = false
        end
    end
end)

local function IsBindPressed()
    return aimHeld
end

-- FOV Circle
do
    pcall(function()
        S.FOVCircle = Drawing.new("Circle")
        S.FOVCircle.Visible = false
        S.FOVCircle.Thickness = 1.5
        S.FOVCircle.NumSides = 64
        S.FOVCircle.Filled = false
        S.FOVCircle.Color = Color3.fromRGB(0, 255, 150)
        S.FOVCircle.Radius = _G.AimbotConfig.FOV
        S.FOVCircle.Transparency = 0.5
        S.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end)
end


eclipseLog("Aimbot ready")

-- ========== ESP ФУНКЦИИ ==========
local function removeESPForPlayer(player)
    if player.Character then
        local hl = player.Character:FindFirstChild("ESPHighlight")
        if hl then hl:Destroy() end
        local head = player.Character:FindFirstChild("Head")
        if head then local tag = head:FindFirstChild("NameTag") if tag then tag:Destroy() end end
    end
    S.espCache[player.UserId] = nil
end

local function removeAllESP()
    for _, p in ipairs(Players:GetPlayers()) do removeESPForPlayer(p) end
    S.espCache = {}
end

local function createHighlight(player, color)
    if not S.scriptActive or not S.espEnabled or not player.Character then return end
    local existing = player.Character:FindFirstChild("ESPHighlight")
    if existing then existing.FillColor = color return end
    local h = Instance.new("Highlight")
    h.Name = "ESPHighlight"
    h.FillColor = color
    h.OutlineColor = Color3.fromRGB(255,255,255)
    h.FillTransparency = 0.6
    h.OutlineTransparency = 0.2
    h.Parent = player.Character
end

local function createNameTag(player, color, role)
    if not S.scriptActive or not S.espEnabled or not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    local existing = head:FindFirstChild("NameTag")
    if existing then
        local l = existing:FindFirstChild("TagLabel")
        if l then l.TextColor3 = color end
        local r = existing:FindFirstChild("RoleLabel")
        if r then r.Text = role r.TextColor3 = color end
        return
    end
    local bb = Instance.new("BillboardGui")
    bb.Name = "NameTag"
    bb.Adornee = head
    bb.Size = UDim2.new(0,150,0,38)
    bb.StudsOffset = Vector3.new(0,2.8,0)
    bb.AlwaysOnTop = true
    local rl = Instance.new("TextLabel", bb)
    rl.Name = "RoleLabel"
    rl.Size = UDim2.new(1,0,0,12)
    rl.BackgroundTransparency = 1
    rl.Text = role
    rl.TextColor3 = color
    rl.Font = Enum.Font.GothamBold
    rl.TextSize = 9
    rl.TextStrokeTransparency = 0.3
    local tl = Instance.new("TextLabel", bb)
    tl.Name = "TagLabel"
    tl.Size = UDim2.new(1,0,0,14)
    tl.Position = UDim2.new(0,0,0,12)
    tl.BackgroundTransparency = 1
    tl.TextColor3 = color
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 11
    tl.TextStrokeTransparency = 0.4
    local hpBg = Instance.new("Frame", bb)
    hpBg.Name = "HPBarBg"
    hpBg.Size = UDim2.new(0.7,0,0,4)
    hpBg.Position = UDim2.new(0.15,0,0,28)
    hpBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
    hpBg.BorderSizePixel = 0
    Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0,2)
    local hpFill = Instance.new("Frame", hpBg)
    hpFill.Name = "HPBarFill"
    hpFill.Size = UDim2.new(1,0,1,0)
    hpFill.BackgroundColor3 = Color3.fromRGB(0,255,80)
    hpFill.BorderSizePixel = 0
    Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0,2)
    bb.Parent = head
end

local function setupESPForPlayer(player)
    if player == LocalPlayer or not S.scriptActive or not S.espEnabled or not player.Character then return end
    local role, color = getPlayerRole(player)
    S.espCache[player.UserId] = {role=role, color=color}
    if not S.espRoleFilter[role] then
        local ch = player.Character
        if ch then
            local hl = ch:FindFirstChild("ESPHighlight")
            if hl then hl:Destroy() end
            local head = ch:FindFirstChild("Head")
            if head then
                local nt = head:FindFirstChild("NameTag")
                if nt then nt:Destroy() end
            end
        end
        return
    end
    createHighlight(player, color)
    createNameTag(player, color, role)
end

-- ========== НОТИФИКАЦИИ ==========
local screenGui -- forward declaration

local function showNotification(title, message, color)
    if not screenGui or not screenGui.Parent then return end
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0,220,0,55)
    f.Position = UDim2.new(1,30,1,-70)
    f.BackgroundColor3 = Color3.fromRGB(15,12,22)
    f.Parent = screenGui
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)
    local g = Instance.new("Frame", f)
    g.Size = UDim2.new(0,4,1,0)
    g.BackgroundColor3 = color
    g.BorderSizePixel = 0
    Instance.new("UICorner", g).CornerRadius = UDim.new(0,4)
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1,-20,0,22)
    t.Position = UDim2.new(0,12,0,6)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 12
    t.TextXAlignment = Enum.TextXAlignment.Left
    local m = Instance.new("TextLabel", f)
    m.Size = UDim2.new(1,-20,0,20)
    m.Position = UDim2.new(0,12,0,24)
    m.BackgroundTransparency = 1
    m.Text = message
    m.TextColor3 = Color3.fromRGB(160,155,170)
    m.Font = Enum.Font.Gotham
    m.TextSize = 11
    m.TextXAlignment = Enum.TextXAlignment.Left
    f:TweenPosition(UDim2.new(1,-240,1,-70), "Out", "Quad", 0.25, true)
    task.delay(3, function()
        if not f or not f.Parent then return end
        f:TweenPosition(UDim2.new(1,30,1,-70), "In", "Quad", 0.25, true)
        task.wait(0.25)
        pcall(function() f:Destroy() end)
    end)
end

-- ========== ВСПОМОГАТЕЛЬНЫЕ ==========
local function disableESP() S.espEnabled = false removeAllESP() end
local function enableESP()
    if not S.scriptActive then return end
    S.espEnabled = true
    for _, p in ipairs(Players:GetPlayers()) do setupESPForPlayer(p) end
end
local function toggleFB()
    _G.FullBrightEnabled = not _G.FullBrightEnabled
    S.fbEnabled = _G.FullBrightEnabled
    if _G._applyFullBright then pcall(_G._applyFullBright, _G.FullBrightEnabled) end
end
local function wallClipTP()
    if not S.wallClipEnabled then return end
    local c = LocalPlayer.Character
    if not c then return end
    local r = c:FindFirstChild("HumanoidRootPart")
    if r then r.CFrame = r.CFrame + (r.CFrame.LookVector * 3.5) end
end
local function rejoin()
    if #Players:GetPlayers() <= 1 then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end
local function toggleAFK()
    S.afkEnabled = not S.afkEnabled
    if S.afkEnabled then
        S.afkThread = task.spawn(function()
            while S.afkEnabled and S.scriptActive do
                task.wait(900)
                if not S.afkEnabled then break end
                for i=1,10 do
                    pcall(function()
                        if VirtualUser then VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new())
                        else local hr = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hr then hr.CFrame = hr.CFrame end end
                    end)
                    task.wait(0.2)
                end
            end
        end)
        showNotification(t("anti_afk"), t("on"), Color3.fromRGB(100,200,100))
    else
        S.afkThread = nil
        showNotification(t("anti_afk"), t("off"), Color3.fromRGB(200,100,100))
    end
end

-- FLY (BodyVelocity антигравитация + CFrame движение, скорость под лимит античита)
local function startFly()
    local c = LocalPlayer.Character
    if not c then return end
    local hr = c:FindFirstChild("HumanoidRootPart")
    local hm = c:FindFirstChildOfClass("Humanoid")
    if not hr or not hm then return end
    if hm.SeatPart then hm.Sit = false task.wait(0.1) end
    local fp = Instance.new("Part")
    fp.Size = Vector3.new(8,1.2,8)
    fp.Anchored = true
    fp.CanCollide = true
    fp.Transparency = 1
    fp.Name = "NeonFlyPlatform"
    fp.CFrame = hr.CFrame * CFrame.new(0,-3.5,0)
    fp.Parent = WS
    S.flyFakePart = fp
    S.flyBV = Instance.new("BodyVelocity")
    S.flyBV.MaxForce = Vector3.new(0, math.huge, 0)
    S.flyBV.Velocity = Vector3.zero
    S.flyBV.Parent = hr
end
local function stopFly()
    S.flyEnabled = false
    local c = LocalPlayer.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand = false end
    end
    if S.flyBV then pcall(function() S.flyBV:Destroy() end) S.flyBV = nil end
    if S.flyFakePart then pcall(function() S.flyFakePart:Destroy() end) S.flyFakePart = nil end
end
local function toggleFly()
    S.flyEnabled = not S.flyEnabled
    if S.flyEnabled then startFly() else stopFly() end
    showNotification(t("fly"), S.flyEnabled and t("on") or t("off"), S.flyEnabled and Color3.fromRGB(0,200,255) or Color3.fromRGB(255,80,80))
end

-- NOCLIP
local function restoreCollisions()
    for part, orig in pairs(S.noclipOrigCollisions) do
        if part and part.Parent then pcall(function() part.CanCollide = orig end) end
    end
    S.noclipOrigCollisions = {}
end
local function toggleNoclip()
    S.noclipEnabled = not S.noclipEnabled
    if not S.noclipEnabled then restoreCollisions() end
    showNotification(t("noclip"), S.noclipEnabled and t("on") or t("off"), S.noclipEnabled and Color3.fromRGB(0,200,255) or Color3.fromRGB(255,80,80))
end

-- VEHICLE SPEED
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

eclipseLog("Functions ready")

-- ========== GUI ==========
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
screenGui = Instance.new("ScreenGui")
screenGui.Name = "Eclipse_Internal"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling end)

local guiPlaced = false
pcall(function() if not guiPlaced and gethui then screenGui.Parent = gethui() guiPlaced = true end end)
pcall(function() if not guiPlaced then screenGui.Parent = game:GetService("CoreGui") guiPlaced = true end end)
if not guiPlaced then screenGui.Parent = playerGui end

eclipseLog("GUI placed")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,520,0,480)
mainFrame.Position = UDim2.new(0.5,-260,0.5,-240)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,16,28)
mainFrame.Active = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,12)
S.mainFrame = mainFrame

-- Drag
do
    local dragging, dragStart, startPos = false, nil, nil
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    local dragInput
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
end

-- Header
do
    local hf = Instance.new("Frame", mainFrame)
    hf.Size = UDim2.new(1,0,0,45)
    hf.BackgroundTransparency = 1
    local tl = Instance.new("TextLabel", hf)
    tl.Size = UDim2.new(0,150,1,0)
    tl.Position = UDim2.new(0,15,0,0)
    tl.BackgroundTransparency = 1
    tl.Text = "ECLIPSE"
    tl.TextColor3 = Color3.fromRGB(255,255,255)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 18
    tl.TextXAlignment = Enum.TextXAlignment.Left

    local tgLabel = Instance.new("TextLabel", hf)
    tgLabel.Size = UDim2.new(0,200,1,0)
    tgLabel.Position = UDim2.new(0,130,0,0)
    tgLabel.BackgroundTransparency = 1
    tgLabel.Text = "TG - @eclipse_script"
    tgLabel.TextColor3 = Color3.fromRGB(255,255,255)
    tgLabel.Font = Enum.Font.GothamBold
    tgLabel.TextSize = 13
    tgLabel.TextXAlignment = Enum.TextXAlignment.Left

    local wc = Instance.new("Frame", hf)
    wc.Size = UDim2.new(0,70,0,30)
    wc.Position = UDim2.new(1,-80,0.5,-15)
    wc.BackgroundTransparency = 1

    local closeBtn = Instance.new("TextButton", wc)
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0,26,0,26)
    closeBtn.Position = UDim2.new(1,-28,0.5,-13)
    closeBtn.BackgroundColor3 = Color3.fromRGB(32,24,38)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(180,170,190)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

    local minBtn = Instance.new("TextButton", wc)
    minBtn.Size = UDim2.new(0,26,0,26)
    minBtn.Position = UDim2.new(1,-58,0.5,-13)
    minBtn.BackgroundColor3 = Color3.fromRGB(28,22,36)
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.fromRGB(180,170,190)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 12
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,6)

    minBtn.MouseButton1Click:Connect(function()
        S.menuVisible = not S.menuVisible
        mainFrame.Visible = S.menuVisible
    end)

    closeBtn.MouseButton1Click:Connect(function()
        S.scriptActive = false
        -- отключить все функции
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
        -- убрать FOV круги
        if S.FOVCircle then pcall(function() S.FOVCircle:Remove() end) S.FOVCircle = nil end
        -- убрать threat lines
        for _, line in pairs(S.threatLineCache or {}) do pcall(function() line:Remove() end) end
        S.threatLineCache = {}
        -- убрать name tags (Drawing)
        for _, data in pairs(S.espCache or {}) do
            if data and data.tag then pcall(function() data.tag:Remove() end) end
        end
        -- убрать все ESP хайлайты
        for _, hl in pairs(S.espHighlights or {}) do pcall(function() hl:Destroy() end) end
        S.espHighlights = {}
        for _, hl in pairs(S.carHighlights or {}) do pcall(function() hl:Destroy() end) end
        S.carHighlights = {}
        -- убрать fly платформу
        if S.flyFakePart then pcall(function() S.flyFakePart:Destroy() end) S.flyFakePart = nil end
        if S.flyBV then pcall(function() S.flyBV:Destroy() end) S.flyBV = nil end
        -- отключить все подключения
        for _, c in ipairs(S.connections) do if c and c.Disconnect then pcall(c.Disconnect, c) end end
        S.connections = {}
        -- восстановить скорости машин
        for seat, spd in pairs(S.vehOrigSpeeds or {}) do
            pcall(function() seat.MaxSpeed = spd end)
        end
        S.vehOrigSpeeds = {}
        -- восстановить камеру
        pcall(function() LocalPlayer.CameraMaxZoomDistance = 15 end)
        -- убрать GUI
        screenGui:Destroy()
        -- убрать aimbot config
        _G.AimbotConfig = nil
        eclipseLog("ECLIPSE unloaded")
    end)

    local glow = Instance.new("Frame", mainFrame)
    glow.Size = UDim2.new(1,0,0,3)
    glow.Position = UDim2.new(0,0,0,45)
    glow.BorderSizePixel = 0
    local gr = Instance.new("UIGradient", glow)
    gr.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(168,85,247)), ColorSequenceKeypoint.new(1, Color3.fromRGB(236,72,153))})
    S.glowGradient = gr
end

-- Sidebar + Content
local tabPanels = {}
local tabButtons = {}

do
    local sb = Instance.new("Frame", mainFrame)
    sb.Size = UDim2.new(0,140,1,-48)
    sb.Position = UDim2.new(0,0,0,48)
    sb.BackgroundTransparency = 1
    local sbBg = Instance.new("Frame", sb)
    sbBg.Size = UDim2.new(1,0,1,0)
    sbBg.BackgroundColor3 = Color3.fromRGB(12,10,18)
    sbBg.BorderSizePixel = 0
    Instance.new("UICorner", sbBg).CornerRadius = UDim.new(0,12)
    S.sidebarBg = sbBg

    local tabs = {"Visuals","Movement","Misc","Aimbot","Farm","Colors","Settings","Info"}
    local tabLangKeys = {Visuals="tab_visuals",Movement="tab_movement",Misc="tab_misc",Aimbot="tab_aimbot",Farm="tab_farm",Colors="tab_colors",Settings="tab_settings",Info="tab_info"}
    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton", sb)
        btn.Size = UDim2.new(0,120,0,32)
        btn.Position = UDim2.new(0,10,0,15+(i-1)*38)
        btn.BackgroundColor3 = i==1 and Color3.fromRGB(38,25,60) or Color3.fromRGB(24,20,32)
        btn.Text = "   "..t(tabLangKeys[name])
        btn.TextColor3 = i==1 and Color3.fromRGB(210,180,255) or Color3.fromRGB(140,135,150)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
        tabButtons[name] = btn
        registerLabel(btn, tabLangKeys[name], "   ")
    end

    local cf = Instance.new("Frame", mainFrame)
    cf.Size = UDim2.new(1,-160,1,-65)
    cf.Position = UDim2.new(0,150,0,55)
    cf.BackgroundTransparency = 1

    for _, name in ipairs(tabs) do
        local p = Instance.new("ScrollingFrame", cf)
        p.Size = UDim2.new(1,0,1,0)
        p.BackgroundTransparency = 1
        p.Visible = name == "Visuals"
        p.ScrollBarThickness = 3
        p.ScrollBarImageColor3 = Color3.fromRGB(168,85,247)
        p.CanvasSize = UDim2.new(0,0,0,0)
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
                BackgroundColor3 = a and Color3.fromRGB(38,25,60) or Color3.fromRGB(24,20,32),
                TextColor3 = a and Color3.fromRGB(210,180,255) or Color3.fromRGB(140,135,150)
            }):Play()
        end
    end
    for n, b in pairs(tabButtons) do b.MouseButton1Click:Connect(function() switchTab(n) end) end
end

eclipseLog("GUI structure ready")

-- ========== UI HELPERS ==========
S.rowRegistry = {}
local function makeRow(parent, height)
    local r = Instance.new("Frame", parent)
    r.Size = UDim2.new(1,-10,0,height or 46)
    r.BackgroundColor3 = Color3.fromRGB(30,24,40)
    Instance.new("UICorner", r).CornerRadius = UDim.new(0,8)
    table.insert(S.rowRegistry, r)
    return r
end

local function makeDot(parent)
    local d = Instance.new("Frame", parent)
    d.Size = UDim2.new(0,8,0,8)
    d.Position = UDim2.new(0,15,0.5,-4)
    d.BackgroundColor3 = Color3.fromRGB(90,80,110)
    Instance.new("UICorner", d).CornerRadius = UDim.new(1,0)
    return d
end

local function makeLabel(parent, text, langKey)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(0,120,1,0)
    l.Position = UDim2.new(0,35,0,0)
    l.BackgroundTransparency = 1
    l.Text = langKey and t(langKey) or text
    l.TextColor3 = Color3.fromRGB(235,230,245)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.TextXAlignment = Enum.TextXAlignment.Left
    if langKey then registerLabel(l, langKey) end
    return l
end

local function makeBindBtn(parent)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0,65,0,24)
    b.Position = UDim2.new(1,-120,0.5,-12)
    b.BackgroundColor3 = Color3.fromRGB(45,36,58)
    b.Text = "[ NONE ]"
    b.TextColor3 = Color3.fromRGB(180,150,220)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
    return b
end

local function makeToggle(parent)
    local bg = Instance.new("TextButton", parent)
    bg.Size = UDim2.new(0,44,0,22)
    bg.Position = UDim2.new(1,-55,0.5,-11)
    bg.BackgroundColor3 = Color3.fromRGB(55,46,68)
    bg.Text = ""
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)
    local ball = Instance.new("Frame", bg)
    ball.Size = UDim2.new(0,16,0,16)
    ball.Position = UDim2.new(0,3,0.5,-8)
    ball.BackgroundColor3 = Color3.fromRGB(245,242,250)
    Instance.new("UICorner", ball).CornerRadius = UDim.new(1,0)
    table.insert(S.toggleRegistry, bg)
    return bg, ball
end

local function animateToggle(bg, ball, dot, enabled)
    local activeCol = S.toggleActiveColor or Color3.fromRGB(168,85,247)
    TS:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = enabled and activeCol or Color3.fromRGB(55,46,68)}):Play()
    TS:Create(ball, TweenInfo.new(0.2), {Position = enabled and UDim2.new(0,25,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play()
    if dot then TS:Create(dot, TweenInfo.new(0.2), {BackgroundColor3 = enabled and Color3.fromRGB(0,255,150) or Color3.fromRGB(90,80,110)}):Play() end
end

local function setupBind(btn, setBind)
    btn.MouseButton1Click:Connect(function()
        if S.isWaitingBind then return end
        S.isWaitingBind = true
        btn.Text = "..."
        btn.TextColor3 = Color3.fromRGB(236,72,153)
        local kc
        kc = UIS.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape then
                    setBind(nil)
                    btn.Text = "[ NONE ]"
                else
                    setBind(input.KeyCode)
                    btn.Text = "[ "..input.KeyCode.Name:upper().." ]"
                end
                btn.TextColor3 = Color3.fromRGB(180,150,220)
                S.isWaitingBind = false
                kc:Disconnect()
            end
        end)
    end)
end

local function makeSlider(parent, labelText, min, max, default, color, onChange, displayFn, langKey)
    local row = makeRow(parent, 50)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-20,0,20)
    lbl.Position = UDim2.new(0,10,0,2)
    lbl.BackgroundTransparency = 1
    local curLabel = langKey and t(langKey) or labelText
    lbl.Text = displayFn and (curLabel..": "..displayFn(default)) or (curLabel..": "..default)
    lbl.TextColor3 = Color3.fromRGB(235,230,245)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local back = Instance.new("Frame", row)
    back.Size = UDim2.new(0.9,0,0,6)
    back.Position = UDim2.new(0.05,0,0,28)
    back.BackgroundColor3 = Color3.fromRGB(45,45,55)
    Instance.new("UICorner", back).CornerRadius = UDim.new(0,3)
    local perc0 = (default - min) / (max - min)
    local fill = Instance.new("Frame", back)
    fill.Size = UDim2.new(perc0,0,1,0)
    fill.BackgroundColor3 = color
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,3)
    local knob = Instance.new("TextButton", back)
    knob.Size = UDim2.new(0,14,0,14)
    knob.Position = UDim2.new(perc0,-7,0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.Text = ""
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    local holding = false
    local lastVal = default
    local sliderConn = nil
    knob.MouseButton1Down:Connect(function()
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
                fill.Size = UDim2.new(p,0,1,0)
                knob.Position = UDim2.new(p,-7,0.5,-7)
                local cl = langKey and t(langKey) or labelText
                lbl.Text = displayFn and (cl..": "..displayFn(val)) or (cl..": "..val)
                onChange(val, p)
            end)
        end
    end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then holding = false end end)
    if langKey then
        table.insert(S.langLabels, {obj = lbl, langKey = langKey, isSlider = true, displayFn = displayFn, getVal = function() return lastVal end})
    end
    return row
end

-- ========== ВКЛАДКА VISUALS ==========
do
    local vp = tabPanels["Visuals"]
    local vpLayout = Instance.new("UIListLayout", vp)
    vpLayout.Padding = UDim.new(0,5)
    vpLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local vpOrder = 0
    local function vpNext(obj)
        vpOrder = vpOrder + 1
        obj.LayoutOrder = vpOrder
        return obj
    end

    -- ESP
    local row = makeRow(vp)
    vpNext(row)
    local dot = makeDot(row)
    makeLabel(row, nil, "esp_players")
    local bindB = makeBindBtn(row)
    local tBg, tBall = makeToggle(row)

    local function toggleESP()
        if S.espEnabled then disableESP() else enableESP() end
        animateToggle(tBg, tBall, dot, S.espEnabled)
        showNotification("ESP", S.espEnabled and t("on") or t("off"), S.espEnabled and Color3.fromRGB(0,235,255) or Color3.fromRGB(255,50,50))
        if S._espSubs then for _, sub in ipairs(S._espSubs) do sub.Visible = S.espEnabled end end
    end
    tBg.MouseButton1Click:Connect(toggleESP)
    setupBind(bindB, function(v) S.espBindKey = v end)

    -- ESP Role Filter (inline checkboxes under Player ESP)
    local function makeSmallCheckbox(parent, text, default, callback, langKey)
        local r = Instance.new("Frame", parent); vpNext(r)
        r.Size = UDim2.new(1, 0, 0, 22)
        r.BackgroundTransparency = 1
        local cb = Instance.new("TextButton", r)
        cb.Size = UDim2.new(0, 18, 0, 18)
        cb.Position = UDim2.new(0, 25, 0.5, -9)
        cb.BackgroundColor3 = default and S.menuAccentColor or Color3.fromRGB(40,35,50)
        cb.Text = default and "X" or ""
        cb.TextColor3 = Color3.fromRGB(255,255,255)
        cb.Font = Enum.Font.GothamBold
        cb.TextSize = 11
        Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4)
        local lbl = Instance.new("TextLabel", r)
        lbl.Size = UDim2.new(1, -50, 1, 0)
        lbl.Position = UDim2.new(0, 48, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = langKey and t(langKey) or text
        if langKey then registerLabel(lbl, langKey) end
        lbl.TextColor3 = Color3.fromRGB(200,195,210)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
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
    local fbBind = makeBindBtn(fbRow)
    local fbBg, fbBall = makeToggle(fbRow)
    local function handleFB()
        toggleFB()
        animateToggle(fbBg, fbBall, fbDot, S.fbEnabled)
        showNotification("FullBright", S.fbEnabled and t("on") or t("off"), S.fbEnabled and Color3.fromRGB(168,85,247) or Color3.fromRGB(255,50,50))
    end
    fbBg.MouseButton1Click:Connect(handleFB)
    setupBind(fbBind, function(v) S.fbBindKey = v end)

    -- Hotkeys reference
    S._toggleESP = toggleESP
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

    -- Checkbox helper
    local function makeCheckbox(parent, text, default, callback, langKey)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, 0, 0, 22)
        row.BackgroundTransparency = 1
        vpNext(row)
        local cb = Instance.new("TextButton", row)
        cb.Size = UDim2.new(0, 18, 0, 18)
        cb.Position = UDim2.new(0, 25, 0.5, -9)
        cb.BackgroundColor3 = default and S.menuAccentColor or Color3.fromRGB(40,35,50)
        cb.Text = default and "X" or ""
        cb.TextColor3 = Color3.fromRGB(255,255,255)
        cb.Font = Enum.Font.GothamBold
        cb.TextSize = 11
        Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 4)
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -50, 1, 0)
        lbl.Position = UDim2.new(0, 48, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = langKey and t(langKey) or text
        if langKey then registerLabel(lbl, langKey) end
        lbl.TextColor3 = Color3.fromRGB(200,195,210)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local state = default
        cb.MouseButton1Click:Connect(function()
            state = not state
            cb.Text = state and "X" or ""
            cb.BackgroundColor3 = state and S.menuAccentColor or Color3.fromRGB(40,35,50)
            callback(state)
        end)
        return row
    end

    -- Threat Lines filters
    local tlHeader = Instance.new("TextLabel", vp); vpNext(tlHeader)
    tlHeader.Size = UDim2.new(1, 0, 0, 18)
    tlHeader.BackgroundTransparency = 1
    tlHeader.Text = "   "..t("lines_for")
    tlHeader.TextColor3 = Color3.fromRGB(140,135,155)
    tlHeader.Font = Enum.Font.Gotham
    tlHeader.TextSize = 11
    tlHeader.TextXAlignment = Enum.TextXAlignment.Left
    registerLabel(tlHeader, "lines_for", "   ")
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
    Instance.new("UIListLayout", mp).Padding = UDim.new(0,5)

    -- Wall Clip
    local wRow = makeRow(mp)
    local wDot = makeDot(wRow)
    makeLabel(wRow, nil, "wall_clip")
    local wBind = makeBindBtn(wRow)
    local wBg, wBall = makeToggle(wRow)
    wBg.MouseButton1Click:Connect(function()
        S.wallClipEnabled = not S.wallClipEnabled
        animateToggle(wBg, wBall, wDot, S.wallClipEnabled)
        showNotification(t("wall_clip"), S.wallClipEnabled and t("on") or t("off"), S.wallClipEnabled and Color3.fromRGB(168,85,247) or Color3.fromRGB(255,50,50))
    end)
    setupBind(wBind, function(v) S.wallClipBindKey = v end)

    -- Fly
    local fRow = makeRow(mp)
    local fDot = makeDot(fRow)
    makeLabel(fRow, nil, "fly")
    local fBind = makeBindBtn(fRow)
    local fBg, fBall = makeToggle(fRow)
    local function handleFly() toggleFly() animateToggle(fBg, fBall, fDot, S.flyEnabled) if S._flySpeedRow then S._flySpeedRow.Visible = S.flyEnabled end end
    fBg.MouseButton1Click:Connect(handleFly)
    setupBind(fBind, function(v) S.flyBindKey = v end)
    S._handleFly = handleFly

    -- Fly Speed
    local flySpeedRow = makeSlider(mp, nil, 10, 500, 60, Color3.fromRGB(168,85,247), function(v) S.flySpeed = v end, nil, "fly_speed")
    flySpeedRow.Visible = false
    S._flySpeedRow = flySpeedRow

    -- Noclip
    local nRow = makeRow(mp)
    local nDot = makeDot(nRow)
    makeLabel(nRow, nil, "noclip")
    local nBind = makeBindBtn(nRow)
    local nBg, nBall = makeToggle(nRow)
    local function handleNoclip() toggleNoclip() animateToggle(nBg, nBall, nDot, S.noclipEnabled) end
    nBg.MouseButton1Click:Connect(handleNoclip)
    setupBind(nBind, function(v) S.noclipBindKey = v end)
    S._handleNoclip = handleNoclip

    -- Car Speed
    local vRow = makeRow(mp)
    local vDot = makeDot(vRow)
    makeLabel(vRow, nil, "car_speed")
    local vBind = makeBindBtn(vRow)
    local vBg, vBall = makeToggle(vRow)
    local function handleVeh() toggleVehSpeed() animateToggle(vBg, vBall, vDot, S.vehSpeedEnabled) if S._vehSliderRow then S._vehSliderRow.Visible = S.vehSpeedEnabled end end
    vBg.MouseButton1Click:Connect(handleVeh)
    setupBind(vBind, function(v) S.vehSpeedBindKey = v end)
    S._handleVeh = handleVeh

    -- Speed Multiplier
    local vehSliderRow = makeSlider(mp, nil, 1, 3, 2, Color3.fromRGB(255,200,0), function(v) S.vehSpeedMult = v end, nil, "speed_multi")
    vehSliderRow.Visible = false
    S._vehSliderRow = vehSliderRow

    -- Speed Boost (velocity-based, не трогает WalkSpeed)
    local sbRow = makeRow(mp)
    local sbDot = makeDot(sbRow)
    makeLabel(sbRow, nil, "speed_boost")
    local sbBind = makeBindBtn(sbRow)
    local sbBg, sbBall = makeToggle(sbRow)
    local function handleSpeed()
        S.speedBoostEnabled = not S.speedBoostEnabled
        animateToggle(sbBg, sbBall, sbDot, S.speedBoostEnabled)
        showNotification(t("speed_boost"), S.speedBoostEnabled and ("x"..S.speedBoostMult.." "..t("on")) or t("off"), S.speedBoostEnabled and Color3.fromRGB(0,200,255) or Color3.fromRGB(255,80,80))
        if S._speedSliderRow then S._speedSliderRow.Visible = S.speedBoostEnabled end
    end
    sbBg.MouseButton1Click:Connect(handleSpeed)
    setupBind(sbBind, function(v) S.speedBoostBindKey = v end)
    S._handleSpeed = handleSpeed

    local speedSliderRow = makeSlider(mp, nil, 1, 10, 2, Color3.fromRGB(0,200,255), function(v) S.speedBoostMult = v end, nil, "run_speed")
    speedSliderRow.Visible = false
    S._speedSliderRow = speedSliderRow

    -- Jump Boost (velocity impulse, не трогает JumpPower)
    local jbRow = makeRow(mp)
    local jbDot = makeDot(jbRow)
    makeLabel(jbRow, nil, "high_jump")
    local jbBind = makeBindBtn(jbRow)
    local jbBg, jbBall = makeToggle(jbRow)
    local function handleJump()
        S.jumpBoostEnabled = not S.jumpBoostEnabled
        animateToggle(jbBg, jbBall, jbDot, S.jumpBoostEnabled)
        showNotification(t("high_jump"), S.jumpBoostEnabled and ("x"..S.jumpBoostMult.." "..t("on")) or t("off"), S.jumpBoostEnabled and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,80,80))
        if S._jumpSliderRow then S._jumpSliderRow.Visible = S.jumpBoostEnabled end
    end
    jbBg.MouseButton1Click:Connect(handleJump)
    setupBind(jbBind, function(v) S.jumpBoostBindKey = v end)
    S._handleJump = handleJump

    local jumpSliderRow = makeSlider(mp, nil, 1, 5, 2, Color3.fromRGB(255,200,0), function(v) S.jumpBoostMult = v end, nil, "jump_power")
    jumpSliderRow.Visible = false
    S._jumpSliderRow = jumpSliderRow
end

eclipseLog("Movement tab ready")

-- ========== ВКЛАДКА MISC ==========
do
    local mp = tabPanels["Misc"]
    Instance.new("UIListLayout", mp).Padding = UDim.new(0,5)

    -- Rejoin
    local rRow = makeRow(mp)
    local rl = Instance.new("TextLabel", rRow)
    rl.Size = UDim2.new(0,150,1,0)
    rl.Position = UDim2.new(0,15,0,0)
    rl.BackgroundTransparency = 1
    rl.Text = t("rejoin")
    registerLabel(rl, "rejoin")
    rl.TextColor3 = Color3.fromRGB(235,230,245)
    rl.Font = Enum.Font.GothamBold
    rl.TextSize = 14
    rl.TextXAlignment = Enum.TextXAlignment.Left
    local rb = Instance.new("TextButton", rRow)
    rb.Size = UDim2.new(0,100,0,30)
    rb.Position = UDim2.new(1,-115,0.5,-15)
    rb.BackgroundColor3 = Color3.fromRGB(168,85,247)
    rb.Text = t("rejoin_btn")
    registerLabel(rb, "rejoin_btn")
    rb.TextColor3 = Color3.fromRGB(255,255,255)
    rb.Font = Enum.Font.GothamBold
    rb.TextSize = 13
    Instance.new("UICorner", rb).CornerRadius = UDim.new(0,6)
    rb.MouseButton1Click:Connect(rejoin)

    -- Anti-AFK
    local aRow = makeRow(mp)
    local aDot = makeDot(aRow)
    makeLabel(aRow, nil, "anti_afk")
    local aBind = makeBindBtn(aRow)
    local aBg, aBall = makeToggle(aRow)
    local function handleAFK() toggleAFK() animateToggle(aBg, aBall, aDot, S.afkEnabled) end
    aBg.MouseButton1Click:Connect(handleAFK)
    setupBind(aBind, function(v) S.afkBindKey = v end)
    S._handleAFK = handleAFK

    -- Camera Zoom (дистанция камеры от персонажа)
    local plr = LocalPlayer
    local origMinZoom = plr.CameraMinZoomDistance
    local origMaxZoom = plr.CameraMaxZoomDistance
    makeSlider(mp, nil, 5, 100, math.round(plr.CameraMaxZoomDistance), Color3.fromRGB(168,85,247), function(v)
        plr.CameraMinZoomDistance = 0.5
        plr.CameraMaxZoomDistance = v
    end, nil, "cam_zoom")

    -- Auto Tablet (авто-проверка и ордер)
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

    -- Taser TP (телепорт к ближайшему гражданскому и тазер)
    local ttRow = makeRow(mp)
    local ttDot = makeDot(ttRow)
    makeLabel(ttRow, nil, "taser_tp")
    local ttBind = makeBindBtn(ttRow)
    ttBind.Text = "[ T ]"
    S.taserTPKey = Enum.KeyCode.T
    setupBind(ttBind, function(v) S.taserTPKey = v end)

    local ttBtn = Instance.new("TextButton", ttRow)
    ttBtn.Size = UDim2.new(0, 60, 0, 22)
    ttBtn.Position = UDim2.new(1, -230, 0.5, -11)
    ttBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    ttBtn.Text = t("taser_btn")
    registerLabel(ttBtn, "taser_btn")
    ttBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    ttBtn.Font = Enum.Font.GothamBold
    ttBtn.TextSize = 11
    Instance.new("UICorner", ttBtn).CornerRadius = UDim.new(0, 6)

    local function doTaserTP()
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        -- найти ближайшего гражданского в ~100м
        local bestPlayer, bestDist = nil, 100
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local role = getPlayerRole(p)
                if role == "Civilian" or role == "Armed" then
                    local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if pRoot then
                        local dist = (myRoot.Position - pRoot.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestPlayer = p
                        end
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
        -- телепорт на ~3 studs перед целью
        local targetPos = targetRoot.Position
        local dir = (targetPos - myRoot.Position)
        if dir.Magnitude > 0.1 then dir = dir.Unit end
        local tpTo = targetPos - dir * 3 + Vector3.new(0, 0.5, 0)
        -- пошаговый мини-тп чтобы снизить шанс AntiTp
        local startPos = myRoot.Position
        local totalDist = (tpTo - startPos).Magnitude
        local steps = math.max(1, math.ceil(totalDist / 30))
        for i = 1, steps do
            local alpha = i / steps
            local pos = startPos:Lerp(tpTo, alpha)
            myRoot.CFrame = CFrame.new(pos, targetPos)
            if i < steps then task.wait(0.05) end
        end
        -- повернуться к цели
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
    Instance.new("UIListLayout", fp).Padding = UDim.new(0,5)

    S.autoFarm = false
    S.farmCycles = 0
    S.farmRingCount = 5

    local afRow = makeRow(fp)
    makeDot(afRow)
    makeLabel(afRow, nil, "auto_farm")
    local afBg, afBall = makeToggle(afRow)

    local afStatusLabel = Instance.new("TextLabel", afRow)
    afStatusLabel.Size = UDim2.new(0, 150, 0, 20)
    afStatusLabel.Position = UDim2.new(1, -280, 0.5, -10)
    afStatusLabel.BackgroundTransparency = 1
    afStatusLabel.TextColor3 = Color3.fromRGB(140, 180, 140)
    afStatusLabel.Font = Enum.Font.Gotham
    afStatusLabel.TextSize = 11
    afStatusLabel.TextXAlignment = Enum.TextXAlignment.Right
    afStatusLabel.Text = ""

    makeSlider(fp, nil, 1, 10, 5, Color3.fromRGB(168,85,247), function(v)
        S.farmRingCount = v
    end, nil, "farm_rings")

    local VIM = game:GetService("VirtualInputManager")

    local POINT_BUY = Vector3.new(6820.8, 16.9, 17.0)
    local POINT_SELL = Vector3.new(-195.7, 17.0, 1244.6)
    local POINT_LAUNDER = Vector3.new(6805.8, 18.1, -34.3)
    local WP1 = Vector3.new(6830.9, 17.3, 154.6)
    local WP2 = Vector3.new(-118.4, 17.3, 158.4)
    local WP3 = Vector3.new(-150.0, 17.3, 1266.4)

    local function holdShift(press)
        pcall(function()
            VIM:SendKeyEvent(press, Enum.KeyCode.LeftShift, false, game)
        end)
    end

    local function farmFlyTo(targetPos)
        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local startPos = root.Position
        local dist = (targetPos - startPos).Magnitude
        local steps = math.max(1, math.ceil(dist / 12))
        for i = 1, steps do
            if not S.autoFarm then return end
            root.CFrame = CFrame.new(startPos:Lerp(targetPos, i / steps))
            task.wait(0.03)
        end
    end

    local function flyThrough(points)
        for _, p in ipairs(points) do
            if not S.autoFarm then return end
            afStatusLabel.Text = t("farm_status_walk")
            farmFlyTo(p)
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
        local ring = wbi:FindFirstChild("Fake Diamond Ring")
        if not ring then return false, "no ring" end
        local buyPart = ring:FindFirstChild("Handle")
        if not buyPart then return false, "no handle" end

        local npcF = workspace:FindFirstChild("NPC")
        if not npcF then return false, "no NPC" end
        local seller = npcF:FindFirstChild("Seller3") or npcF:FindFirstChild("Seller") or npcF:FindFirstChild("Seller2")
        if not seller then return false, "no Seller" end
        local sellPart = seller:FindFirstChild("HumanoidRootPart")
        if not sellPart then return false, "no seller root" end

        local lf = workspace:FindFirstChild("LaunderPrompts")
        if not lf then return false, "no LaunderPrompts" end
        local lt = lf:FindFirstChild("LaunderTrigger")
        if not lt then return false, "no LaunderTrigger" end
        local launderPart = lt:FindFirstChild("PromptPart")
        if not launderPart then return false, "no PromptPart" end

        local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return false, "no character" end

        -- 1. Летим к кольцу и покупаем
        holdShift(true)
        farmFlyTo(POINT_BUY)
        holdShift(false)
        if not S.autoFarm then return false end
        task.wait(0.5)
        local bp = buyPart:FindFirstChild("PromptAttachment")
        if bp then bp = bp:FindFirstChild("ProximityPrompt") end
        for i = 1, S.farmRingCount do
            if not S.autoFarm then return false end
            afStatusLabel.Text = t("farm_status_buy") .. " " .. i .. "/" .. S.farmRingCount
            firePromptSafe(bp)
            task.wait(0.8)
        end
        if not S.autoFarm then return false end

        -- 2. Купил -> WP1 -> WP2 -> WP3 -> Продавец
        holdShift(true)
        flyThrough({WP1, WP2, WP3, POINT_SELL})
        holdShift(false)
        if not S.autoFarm then return false end
        task.wait(1)
        afStatusLabel.Text = t("farm_status_sell")
        firePromptSafe(sellPart:FindFirstChild("SellSmuggledGoodsPrompt"))
        task.wait(1)
        if not S.autoFarm then return false end

        -- 3. Продал -> WP3 -> WP2 -> WP1 -> Отмывка
        holdShift(true)
        flyThrough({WP3, WP2, WP1, POINT_LAUNDER})
        holdShift(false)
        if not S.autoFarm then return false end
        task.wait(1)
        afStatusLabel.Text = t("farm_status_launder")
        firePromptSafe(launderPart:FindFirstChild("LaunderBriefcasePrompt"))
        task.wait(1)

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
        TS:Create(afBall, TweenInfo.new(0.2), {Position = on and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
        TS:Create(afBg, TweenInfo.new(0.2), {BackgroundColor3 = on and Color3.fromRGB(168,85,247) or Color3.fromRGB(60,55,70)}):Play()
        if on then
            task.spawn(farmLoop)
        end
    end)

    -- Быстрая покупка оружия
    local weaponHeader = makeRow(fp)
    makeDot(weaponHeader)
    makeLabel(weaponHeader, nil, "farm_buy_weapons")

    local weaponList = {"AK-47", "UZI", "Makarov", "Dragunov", "M249", "PP Bizon", "RPG-7", "Lupara", "C4", "Knife", "Crowbar"}

    local function buyWeapon(weaponName)
        local pp = nil
        for _, folder in ipairs({"WorldBuyableItems", "FreeGun"}) do
            local container = workspace:FindFirstChild(folder)
            if container then
                local item = container:FindFirstChild(weaponName)
                if item then
                    local handle = item:FindFirstChild("Handle")
                    if handle then
                        for _, desc in ipairs(handle:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") then
                                pp = desc
                                break
                            end
                        end
                    end
                end
            end
            if pp then break end
        end
        if not pp then
            showNotification(t("farm_buy_weapons"), weaponName .. " - not found", Color3.fromRGB(255, 80, 80))
            return
        end
        fireproximityprompt(pp)
        task.wait(0.2)
        fireproximityprompt(pp)
        showNotification(t("farm_buy_weapons"), weaponName .. " OK", Color3.fromRGB(100, 200, 100))
    end

    for _, wName in ipairs(weaponList) do
        local wRow = makeRow(fp)
        local wBtn = Instance.new("TextButton", wRow)
        wBtn.Size = UDim2.new(1, -20, 0, 22)
        wBtn.Position = UDim2.new(0, 10, 0.5, -11)
        wBtn.BackgroundColor3 = Color3.fromRGB(35, 28, 50)
        wBtn.TextColor3 = Color3.fromRGB(200, 190, 220)
        wBtn.Font = Enum.Font.GothamMedium
        wBtn.TextSize = 12
        wBtn.Text = wName
        Instance.new("UICorner", wBtn).CornerRadius = UDim.new(0, 6)
        wBtn.MouseButton1Click:Connect(function()
            task.spawn(function() buyWeapon(wName) end)
        end)
    end
end

eclipseLog("Farm tab ready")

-- ========== ВКЛАДКА AIMBOT ==========
do
    local ap = tabPanels["Aimbot"]
    Instance.new("UIListLayout", ap).Padding = UDim.new(0,5)

    -- Aimbot toggle
    local aRow = makeRow(ap)
    local aDot = makeDot(aRow)
    makeLabel(aRow, nil, "aimbot")
    local aBind = makeBindBtn(aRow)
    aBind.Text = "[ MB2 ]"
    local aBg, aBall = makeToggle(aRow)

    local function updateAimVis() animateToggle(aBg, aBall, aDot, _G.AimbotConfig.Enabled) end
    aBg.MouseButton1Click:Connect(function()
        _G.AimbotConfig.Enabled = not _G.AimbotConfig.Enabled
        updateAimVis()
        showNotification(t("aimbot"), _G.AimbotConfig.Enabled and t("on") or t("off"), _G.AimbotConfig.Enabled and Color3.fromRGB(0,255,150) or Color3.fromRGB(255,50,50))
        if S.FOVCircle then pcall(function() S.FOVCircle.Visible = _G.AimbotConfig.Enabled end) end
        if S._aimSubs then for _, sub in ipairs(S._aimSubs) do sub.Visible = _G.AimbotConfig.Enabled end end
    end)

    -- Aim bind
    aBind.MouseButton1Click:Connect(function()
        if S.isWaitingBind then return end
        S.isWaitingBind = true
        aBind.Text = "..."
        aBind.TextColor3 = Color3.fromRGB(236,72,153)
        local kc
        kc = UIS.InputBegan:Connect(function(input, proc)
            if proc then return end
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                _G.AimbotConfig.AimBind = input.KeyCode
                aBind.Text = "[ "..input.KeyCode.Name:upper().." ]"
            elseif input.UserInputType.Name:find("MouseButton") then
                _G.AimbotConfig.AimBind = input.UserInputType
                aBind.Text = "[ "..input.UserInputType.Name:gsub("MouseButton","MB"):upper().." ]"
            else return end
            aBind.TextColor3 = Color3.fromRGB(180,150,220)
            S.isWaitingBind = false
            kc:Disconnect()
        end)
    end)

    local aimSubs = {}

    -- Aim Part
    local apRow = makeRow(ap)
    table.insert(aimSubs, apRow)
    local apLbl = Instance.new("TextLabel", apRow)
    apLbl.Size = UDim2.new(0,150,1,0)
    apLbl.Position = UDim2.new(0,15,0,0)
    apLbl.BackgroundTransparency = 1
    apLbl.Text = t("aim_part")..": "..t("head")
    apLbl.TextColor3 = Color3.fromRGB(235,230,245)
    apLbl.Font = Enum.Font.GothamBold
    apLbl.TextSize = 14
    apLbl.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(S.langLabels, {obj = apLbl, isCustom = true, updateFn = function()
        local cfg = _G.AimbotConfig
        local n = cfg.AimParts[cfg.SelectedAimPart]
        local partNames = {HumanoidRootPart = t("torso"), Head = t("head"), UpperTorso = t("upper_torso"), Torso = t("torso")}
        apLbl.Text = t("aim_part")..": "..(partNames[n] or n)
    end})
    local apBtn = Instance.new("TextButton", apRow)
    apBtn.Size = UDim2.new(0,100,0,30)
    apBtn.Position = UDim2.new(1,-115,0.5,-15)
    apBtn.BackgroundColor3 = Color3.fromRGB(168,85,247)
    apBtn.Text = t("toggle_btn")
    registerLabel(apBtn, "toggle_btn")
    apBtn.TextColor3 = Color3.fromRGB(255,255,255)
    apBtn.Font = Enum.Font.GothamBold
    apBtn.TextSize = 13
    Instance.new("UICorner", apBtn).CornerRadius = UDim.new(0,6)
    apBtn.MouseButton1Click:Connect(function()
        local cfg = _G.AimbotConfig
        cfg.SelectedAimPart = cfg.SelectedAimPart % #cfg.AimParts + 1
        local n = cfg.AimParts[cfg.SelectedAimPart]
        local partNames = {HumanoidRootPart = t("torso"), Head = t("head"), UpperTorso = t("upper_torso"), Torso = t("torso")}
        apLbl.Text = t("aim_part")..": "..(partNames[n] or n)
    end)

    -- Sliders
    table.insert(aimSubs, makeSlider(ap, nil, 10, 360, 90, Color3.fromRGB(168,85,247), function(v)
        _G.AimbotConfig.FOV = v
        if S.FOVCircle then pcall(function() S.FOVCircle.Radius = v end) end
    end, nil, "fov_circle"))
    -- FOV Color picker
    local fovColorRow = makeRow(ap, 38)
    table.insert(aimSubs, fovColorRow)
    local fovColorLbl = Instance.new("TextLabel", fovColorRow)
    fovColorLbl.Size = UDim2.new(0, 120, 1, 0)
    fovColorLbl.Position = UDim2.new(0, 15, 0, 0)
    fovColorLbl.BackgroundTransparency = 1
    fovColorLbl.Text = t("fov_color")
    registerLabel(fovColorLbl, "fov_color")
    fovColorLbl.TextColor3 = Color3.fromRGB(190, 185, 200)
    fovColorLbl.Font = Enum.Font.Gotham
    fovColorLbl.TextSize = 12
    fovColorLbl.TextXAlignment = Enum.TextXAlignment.Left
    local fovColors = {
        Color3.fromRGB(0, 255, 150),
        Color3.fromRGB(255, 50, 50),
        Color3.fromRGB(0, 170, 255),
        Color3.fromRGB(168, 85, 247),
        Color3.fromRGB(255, 200, 0),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 100, 200),
        Color3.fromRGB(0, 255, 255),
    }
    for ci, fc in ipairs(fovColors) do
        local cb = Instance.new("TextButton", fovColorRow)
        cb.Size = UDim2.new(0, 20, 0, 20)
        cb.Position = UDim2.new(0, 140 + (ci - 1) * 26, 0.5, -10)
        cb.BackgroundColor3 = fc
        cb.Text = ""
        Instance.new("UICorner", cb).CornerRadius = UDim.new(1, 0)
        cb.MouseButton1Click:Connect(function()
            if S.FOVCircle then pcall(function() S.FOVCircle.Color = fc end) end
            S.fovGradient = false
        end)
    end

    table.insert(aimSubs, makeSlider(ap, nil, 1, 100, 18, Color3.fromRGB(168,85,247), function(v)
        _G.AimbotConfig.Smoothness = v / 100
    end, nil, "smoothness"))

    -- Max Distance (slider 20-350, >300 = infinity)
    table.insert(aimSubs, makeSlider(ap, nil, 20, 350, 200, Color3.fromRGB(168,85,247), function(v)
        if v > 300 then
            _G.AimbotConfig.MaxDistance = 9999
        else
            _G.AimbotConfig.MaxDistance = v
        end
    end, function(v) return v > 300 and "∞" or (v.."m") end, "max_dist"))

    -- Toggles
    local function makeAimToggle(langKey, key)
        local r = makeRow(ap, 38)
        table.insert(aimSubs, r)
        r.BackgroundColor3 = Color3.fromRGB(26,22,36)
        local l = Instance.new("TextLabel", r)
        l.Size = UDim2.new(0,150,1,0)
        l.Position = UDim2.new(0,15,0,0)
        l.BackgroundTransparency = 1
        l.Text = t(langKey)
        registerLabel(l, langKey)
        l.TextColor3 = Color3.fromRGB(190,185,200)
        l.Font = Enum.Font.Gotham
        l.TextSize = 12
        l.TextXAlignment = Enum.TextXAlignment.Left
        local tb = Instance.new("TextButton", r)
        tb.Size = UDim2.new(0,36,0,18)
        tb.Position = UDim2.new(1,-48,0.5,-9)
        tb.BackgroundColor3 = _G.AimbotConfig[key] and S.toggleActiveColor or Color3.fromRGB(45,40,55)
        tb.Text = ""
        Instance.new("UICorner", tb).CornerRadius = UDim.new(1,0)
        local tbl = Instance.new("Frame", tb)
        tbl.Size = UDim2.new(0,14,0,14)
        tbl.Position = _G.AimbotConfig[key] and UDim2.new(0,19,0.5,-7) or UDim2.new(0,3,0.5,-7)
        tbl.BackgroundColor3 = Color3.fromRGB(245,242,250)
        Instance.new("UICorner", tbl).CornerRadius = UDim.new(1,0)
        table.insert(S.toggleRegistry, tb)
        tb.MouseButton1Click:Connect(function()
            _G.AimbotConfig[key] = not _G.AimbotConfig[key]
            TS:Create(tb, TweenInfo.new(0.2), {BackgroundColor3 = _G.AimbotConfig[key] and S.toggleActiveColor or Color3.fromRGB(45,40,55)}):Play()
            TS:Create(tbl, TweenInfo.new(0.2), {Position = _G.AimbotConfig[key] and UDim2.new(0,19,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
        end)
    end

    makeAimToggle("wall_check", "WallCheck")
    makeAimToggle("team_check", "TeamCheck")
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
    Instance.new("UIListLayout", cp).Padding = UDim.new(0,5)

    local tl = Instance.new("TextLabel", cp)
    tl.Size = UDim2.new(1,-10,0,30)
    tl.BackgroundTransparency = 1
    tl.Text = t("esp_visual_settings")
    registerLabel(tl, "esp_visual_settings")
    tl.TextColor3 = Color3.fromRGB(210,180,255)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 14

    -- ESP Colors (кликабельные пресеты)
    local presetColors = {
        Color3.fromRGB(255,255,255), Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0),
        Color3.fromRGB(0,120,255), Color3.fromRGB(255,255,0), Color3.fromRGB(255,0,255),
        Color3.fromRGB(0,255,255), Color3.fromRGB(255,120,0), Color3.fromRGB(255,80,150),
        Color3.fromRGB(120,255,80), Color3.fromRGB(80,80,255), Color3.fromRGB(200,200,200),
    }
    local roleLangKeys = {Police="role_police",Civilian="role_civilian",Friend="role_friend",Armed="role_armed"}
    for _, roleName in ipairs({"Police","Civilian","Friend","Armed"}) do
        local row = makeRow(cp, 50)
        local prev = Instance.new("Frame", row)
        prev.Name = "Preview"
        prev.Size = UDim2.new(0,18,0,18)
        prev.Position = UDim2.new(0,10,0,4)
        prev.BackgroundColor3 = S.ESPColors[roleName]
        Instance.new("UICorner", prev).CornerRadius = UDim.new(1,0)
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0,100,0,18)
        lbl.Position = UDim2.new(0,34,0,4)
        lbl.BackgroundTransparency = 1
        lbl.Text = t(roleLangKeys[roleName])
        registerLabel(lbl, roleLangKeys[roleName])
        lbl.TextColor3 = Color3.fromRGB(235,230,245)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local colFrame = Instance.new("Frame", row)
        colFrame.Size = UDim2.new(1,-15,0,16)
        colFrame.Position = UDim2.new(0,8,0,28)
        colFrame.BackgroundTransparency = 1
        local colLayout = Instance.new("UIListLayout", colFrame)
        colLayout.FillDirection = Enum.FillDirection.Horizontal
        colLayout.Padding = UDim.new(0,3)
        for _, pc in ipairs(presetColors) do
            local cb = Instance.new("TextButton", colFrame)
            cb.Size = UDim2.new(0,14,0,14)
            cb.BackgroundColor3 = pc
            cb.Text = ""
            Instance.new("UICorner", cb).CornerRadius = UDim.new(1,0)
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
                                        local tl2 = tag:FindFirstChild("TagLabel")
                                        if tl2 then tl2.TextColor3 = pc end
                                        local rl2 = tag:FindFirstChild("RoleLabel")
                                        if rl2 then rl2.TextColor3 = pc end
                                    end
                                end
                            end
                        end
                    end
                end
                showNotification(t("tab_colors"), t(roleLangKeys[roleName]).." "..t("notif_color_upd"), pc)
            end)
        end
    end

    -- ESP Gradient toggle
    local gRow = makeRow(cp)
    local gDot = makeDot(gRow)
    makeLabel(gRow, nil, "esp_gradient")
    local gBg, gBall = makeToggle(gRow)
    gBg.MouseButton1Click:Connect(function()
        S.espGradient = not S.espGradient
        animateToggle(gBg, gBall, gDot, S.espGradient)
        for _, sub in ipairs(gradSubs) do sub.Visible = S.espGradient end
        if not S.espGradient then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hl = player.Character:FindFirstChild("ESPHighlight")
                    if hl then
                        local cached = S.espCache[player.UserId]
                        local col = cached and cached.color or Color3.fromRGB(255,255,255)
                        hl.OutlineColor = Color3.fromRGB(255,255,255)
                        hl.FillColor = col
                    end
                end
            end
        end
    end)

    local gradSubs = {}

    -- Gradient Mode (обводка / заливка)
    local gmRow = makeRow(cp, 38)
    table.insert(gradSubs, gmRow)
    gmRow.BackgroundColor3 = Color3.fromRGB(26,22,36)
    local gmLbl = Instance.new("TextLabel", gmRow)
    gmLbl.Size = UDim2.new(0,150,1,0)
    gmLbl.Position = UDim2.new(0,15,0,0)
    gmLbl.BackgroundTransparency = 1
    gmLbl.Text = t("mode_outline")
    table.insert(S.langLabels, {obj = gmLbl, isCustom = true, updateFn = function()
        gmLbl.Text = S.espGradientMode == "fill" and t("mode_fill") or t("mode_outline")
    end})
    gmLbl.TextColor3 = Color3.fromRGB(190,185,200)
    gmLbl.Font = Enum.Font.Gotham
    gmLbl.TextSize = 12
    gmLbl.TextXAlignment = Enum.TextXAlignment.Left
    local gmBtn = Instance.new("TextButton", gmRow)
    gmBtn.Size = UDim2.new(0,70,0,22)
    gmBtn.Position = UDim2.new(1,-82,0.5,-11)
    gmBtn.BackgroundColor3 = Color3.fromRGB(168,85,247)
    gmBtn.Text = t("switch_btn")
    registerLabel(gmBtn, "switch_btn")
    gmBtn.TextColor3 = Color3.fromRGB(255,255,255)
    gmBtn.Font = Enum.Font.GothamBold
    gmBtn.TextSize = 11
    Instance.new("UICorner", gmBtn).CornerRadius = UDim.new(0,5)
    gmBtn.MouseButton1Click:Connect(function()
        if S.espGradientMode == "outline" then
            S.espGradientMode = "fill"
            gmLbl.Text = t("mode_fill")
        else
            S.espGradientMode = "outline"
            gmLbl.Text = t("mode_outline")
        end
    end)

    -- Gradient per-role toggles
    for _, roleName in ipairs({"Police","Civilian","Friend","Armed"}) do
        local rr = makeRow(cp, 34)
        table.insert(gradSubs, rr)
        rr.BackgroundColor3 = Color3.fromRGB(26,22,36)
        local rl = Instance.new("TextLabel", rr)
        rl.Size = UDim2.new(0,120,1,0)
        rl.Position = UDim2.new(0,15,0,0)
        rl.BackgroundTransparency = 1
        rl.Text = "  "..t(roleLangKeys[roleName])
        registerLabel(rl, roleLangKeys[roleName], "  ")
        rl.TextColor3 = Color3.fromRGB(180,175,200)
        rl.Font = Enum.Font.Gotham
        rl.TextSize = 11
        rl.TextXAlignment = Enum.TextXAlignment.Left
        local rtBg = Instance.new("TextButton", rr)
        rtBg.Size = UDim2.new(0,36,0,18)
        rtBg.Position = UDim2.new(1,-48,0.5,-9)
        rtBg.BackgroundColor3 = S.toggleActiveColor
        rtBg.Text = ""
        Instance.new("UICorner", rtBg).CornerRadius = UDim.new(1,0)
        local rtBall = Instance.new("Frame", rtBg)
        rtBall.Size = UDim2.new(0,14,0,14)
        rtBall.Position = UDim2.new(0,19,0.5,-7)
        rtBall.BackgroundColor3 = Color3.fromRGB(245,242,250)
        Instance.new("UICorner", rtBall).CornerRadius = UDim.new(1,0)
        table.insert(S.toggleRegistry, rtBg)
        rtBg.MouseButton1Click:Connect(function()
            S.espGradientRoles[roleName] = not S.espGradientRoles[roleName]
            TS:Create(rtBg, TweenInfo.new(0.2), {BackgroundColor3 = S.espGradientRoles[roleName] and S.toggleActiveColor or Color3.fromRGB(45,40,55)}):Play()
            TS:Create(rtBall, TweenInfo.new(0.2), {Position = S.espGradientRoles[roleName] and UDim2.new(0,19,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
        end)
    end

    for _, sub in ipairs(gradSubs) do sub.Visible = false end

    -- FOV Circle Gradient
    local fgRow = makeRow(cp)
    local fgDot = makeDot(fgRow)
    makeLabel(fgRow, nil, "fov_gradient")
    local fgBg, fgBall = makeToggle(fgRow)
    fgBg.MouseButton1Click:Connect(function()
        S.fovGradient = not S.fovGradient
        animateToggle(fgBg, fgBall, fgDot, S.fovGradient)
        if not S.fovGradient and S.FOVCircle then
            pcall(function() S.FOVCircle.Color = Color3.fromRGB(0,255,150) end)
        end
    end)

end

eclipseLog("Colors tab ready")

-- ========== ВКЛАДКА SETTINGS ==========
do
    local sp = tabPanels["Settings"]
    Instance.new("UIListLayout", sp).Padding = UDim.new(0,5)

    local mbRow = makeRow(sp)
    makeDot(mbRow)
    makeLabel(mbRow, nil, "menu_btn")
    local mbBind = makeBindBtn(mbRow)
    mbBind.Text = "[ F8 ]"
    setupBind(mbBind, function(v) S.menuBindKey = v end)

    local stl = Instance.new("TextLabel", sp)
    stl.Size = UDim2.new(1,-10,0,30)
    stl.BackgroundTransparency = 1
    stl.Text = t("settings_title")
    stl.TextColor3 = Color3.fromRGB(210,180,255)
    stl.Font = Enum.Font.GothamBold
    stl.TextSize = 14
    registerLabel(stl, "settings_title")

    -- Language toggle
    local langRow = makeRow(sp, 40)
    local langLbl = Instance.new("TextLabel", langRow)
    langLbl.Size = UDim2.new(0,120,1,0)
    langLbl.Position = UDim2.new(0,10,0,0)
    langLbl.BackgroundTransparency = 1
    langLbl.Text = t("language")
    langLbl.TextColor3 = Color3.fromRGB(235,230,245)
    langLbl.Font = Enum.Font.GothamBold
    langLbl.TextSize = 13
    langLbl.TextXAlignment = Enum.TextXAlignment.Left
    registerLabel(langLbl, "language")
    local langBtn = Instance.new("TextButton", langRow)
    langBtn.Size = UDim2.new(0,100,0,28)
    langBtn.Position = UDim2.new(1,-115,0.5,-14)
    langBtn.BackgroundColor3 = Color3.fromRGB(168,85,247)
    langBtn.Text = S.lang == "ru" and "Русский" or "English"
    langBtn.TextColor3 = Color3.fromRGB(255,255,255)
    langBtn.Font = Enum.Font.GothamBold
    langBtn.TextSize = 12
    Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0,6)
    langBtn.MouseButton1Click:Connect(function()
        S.lang = S.lang == "ru" and "en" or "ru"
        langBtn.Text = S.lang == "ru" and "Русский" or "English"
        applyLanguage()
    end)

    local function makeColorPicker(parent, labelText, defaultColor, onChange, customPalette, langKey)
        local row = makeRow(parent, 50)
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0,150,0,18)
        lbl.Position = UDim2.new(0,10,0,4)
        lbl.BackgroundTransparency = 1
        lbl.Text = langKey and t(langKey) or labelText
        if langKey then registerLabel(lbl, langKey) end
        lbl.TextColor3 = Color3.fromRGB(235,230,245)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local preview = Instance.new("Frame", row)
        preview.Size = UDim2.new(0,22,0,22)
        preview.Position = UDim2.new(1,-35,0,2)
        preview.BackgroundColor3 = defaultColor
        Instance.new("UICorner", preview).CornerRadius = UDim.new(1,0)
        local colFrame = Instance.new("Frame", row)
        colFrame.Size = UDim2.new(1,-15,0,16)
        colFrame.Position = UDim2.new(0,8,0,28)
        colFrame.BackgroundTransparency = 1
        local colLayout = Instance.new("UIListLayout", colFrame)
        colLayout.FillDirection = Enum.FillDirection.Horizontal
        colLayout.Padding = UDim.new(0,3)
        local palette = customPalette or {
            Color3.fromRGB(168,85,247), Color3.fromRGB(130,60,200), Color3.fromRGB(100,40,180),
            Color3.fromRGB(236,72,153), Color3.fromRGB(255,80,80), Color3.fromRGB(255,120,0),
            Color3.fromRGB(255,200,0), Color3.fromRGB(0,200,100), Color3.fromRGB(0,200,255),
            Color3.fromRGB(80,80,255), Color3.fromRGB(200,200,200), Color3.fromRGB(255,255,255),
        }
        for _, c in ipairs(palette) do
            local cb = Instance.new("TextButton", colFrame)
            cb.Size = UDim2.new(0,14,0,14)
            cb.BackgroundColor3 = c
            cb.Text = ""
            Instance.new("UICorner", cb).CornerRadius = UDim.new(1,0)
            cb.MouseButton1Click:Connect(function()
                preview.BackgroundColor3 = c
                onChange(c)
            end)
        end
    end

    makeColorPicker(sp, nil, Color3.fromRGB(168,85,247), function(c)
        S.menuAccentColor = c
        for _, p in pairs(tabPanels) do
            pcall(function() p.ScrollBarImageColor3 = c end)
        end
        if S.glowGradient then
            pcall(function()
                S.glowGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, c),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(
                        math.min(255, math.floor(c.R*255*0.9+25)),
                        math.min(255, math.floor(c.G*255*0.5)),
                        math.min(255, math.floor(c.B*255*0.6+100))
                    ))
                })
            end)
        end
        local activeTabName = S.currentTab
        for n, b in pairs(tabButtons) do
            if n == activeTabName then
                local r, g, bl = math.floor(c.R*255*0.25+15), math.floor(c.G*255*0.15+10), math.floor(c.B*255*0.35+20)
                b.BackgroundColor3 = Color3.fromRGB(r, g, bl)
            end
        end
        showNotification(t("tab_settings"), t("notif_menu_color"), c)
    end, nil, "accent_color")

    makeColorPicker(sp, nil, Color3.fromRGB(168,85,247), function(c)
        S.toggleActiveColor = c
        for _, tbg in ipairs(S.toggleRegistry) do
            if tbg and tbg.Parent then
                local ball = tbg:FindFirstChildWhichIsA("Frame")
                if ball then
                    local isOn = ball.Position.X.Offset > 10
                    if isOn then
                        tbg.BackgroundColor3 = c
                    end
                end
            end
        end
        showNotification(t("tab_settings"), t("notif_toggle_color"), c)
    end, nil, "toggle_color")

    local darkPalette = {
        Color3.fromRGB(20,16,28), Color3.fromRGB(30,20,45), Color3.fromRGB(25,30,50),
        Color3.fromRGB(40,20,35), Color3.fromRGB(20,35,40), Color3.fromRGB(35,25,55),
        Color3.fromRGB(45,15,30), Color3.fromRGB(15,30,45), Color3.fromRGB(50,30,60),
        Color3.fromRGB(30,40,55), Color3.fromRGB(55,25,45), Color3.fromRGB(10,10,18),
    }
    local rowPalette = {
        Color3.fromRGB(30,24,40), Color3.fromRGB(40,28,55), Color3.fromRGB(35,35,60),
        Color3.fromRGB(50,30,45), Color3.fromRGB(28,40,50), Color3.fromRGB(45,30,65),
        Color3.fromRGB(55,25,40), Color3.fromRGB(25,38,55), Color3.fromRGB(60,35,70),
        Color3.fromRGB(38,48,65), Color3.fromRGB(65,32,55), Color3.fromRGB(22,22,35),
    }
    makeColorPicker(sp, nil, Color3.fromRGB(20,16,28), function(c)
        if S.mainFrame then S.mainFrame.BackgroundColor3 = c end
        if S.sidebarBg then
            local r, g, b = math.floor(c.R*255*0.6), math.floor(c.G*255*0.6), math.floor(c.B*255*0.65)
            S.sidebarBg.BackgroundColor3 = Color3.fromRGB(r, g, b)
        end
    end, darkPalette, "bg_color")

    makeColorPicker(sp, nil, Color3.fromRGB(30,24,40), function(c)
        for _, row in ipairs(S.rowRegistry) do
            if row and row.Parent then
                row.BackgroundColor3 = c
            end
        end
    end, rowPalette, "row_color")
end

eclipseLog("Settings tab ready")

-- ========== INFO TAB ==========
do
    local ip = tabPanels["Info"]
    local lay = Instance.new("UIListLayout", ip)
    lay.Padding = UDim.new(0, 10)
    lay.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", ip)
    pad.PaddingTop = UDim.new(0, 15)
    pad.PaddingLeft = UDim.new(0, 15)
    pad.PaddingRight = UDim.new(0, 15)

    local title = Instance.new("TextLabel", ip)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "ECLIPSE"
    title.TextColor3 = Color3.fromRGB(168, 85, 247)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 1

    local chLabel = Instance.new("TextLabel", ip)
    chLabel.Size = UDim2.new(1, 0, 0, 22)
    chLabel.BackgroundTransparency = 1
    chLabel.TextColor3 = Color3.fromRGB(200, 190, 220)
    chLabel.Font = Enum.Font.GothamSemibold
    chLabel.TextSize = 14
    chLabel.TextXAlignment = Enum.TextXAlignment.Left
    chLabel.LayoutOrder = 2
    registerLabel(chLabel, "info_channel")

    local linkBox = Instance.new("Frame", ip)
    linkBox.Size = UDim2.new(1, 0, 0, 40)
    linkBox.BackgroundColor3 = Color3.fromRGB(30, 24, 42)
    linkBox.LayoutOrder = 3
    local lbCorner = Instance.new("UICorner", linkBox)
    lbCorner.CornerRadius = UDim.new(0, 6)

    local linkLabel = Instance.new("TextLabel", linkBox)
    linkLabel.Size = UDim2.new(1, -16, 1, 0)
    linkLabel.Position = UDim2.new(0, 8, 0, 0)
    linkLabel.BackgroundTransparency = 1
    linkLabel.Text = "https://t.me/eclipse_script"
    linkLabel.TextColor3 = Color3.fromRGB(130, 170, 255)
    linkLabel.Font = Enum.Font.GothamMedium
    linkLabel.TextSize = 14
    linkLabel.TextXAlignment = Enum.TextXAlignment.Left

    local hintLabel = Instance.new("TextLabel", ip)
    hintLabel.Size = UDim2.new(1, 0, 0, 18)
    hintLabel.BackgroundTransparency = 1
    hintLabel.TextColor3 = Color3.fromRGB(100, 95, 115)
    hintLabel.Font = Enum.Font.Gotham
    hintLabel.TextSize = 11
    hintLabel.TextXAlignment = Enum.TextXAlignment.Left
    hintLabel.LayoutOrder = 4
    registerLabel(hintLabel, "info_copy_hint")
end

eclipseLog("Info tab ready")

-- ========== ХОТКЕИ ==========
table.insert(S.connections, UIS.InputBegan:Connect(function(input, proc)
    if proc or S.isWaitingBind then return end
    local kc = input.KeyCode
    local menuKey = S.menuBindKey or Enum.KeyCode.F8
    if kc == menuKey or (not S.menuBindKey and kc == Enum.KeyCode.Insert) then
        S.menuVisible = not S.menuVisible
        mainFrame.Visible = S.menuVisible
    elseif S.espBindKey and kc == S.espBindKey then S._toggleESP()
    elseif S.fbBindKey and kc == S.fbBindKey then S._handleFB()
    elseif S.wallClipBindKey and kc == S.wallClipBindKey then wallClipTP()
    elseif S.afkBindKey and kc == S.afkBindKey then S._handleAFK()
    elseif S.flyBindKey and kc == S.flyBindKey then S._handleFly()
    elseif S.noclipBindKey and kc == S.noclipBindKey then S._handleNoclip()
    elseif S.vehSpeedBindKey and kc == S.vehSpeedBindKey then S._handleVeh()
    elseif S.speedBoostBindKey and kc == S.speedBoostBindKey then S._handleSpeed()
    elseif S.jumpBoostBindKey and kc == S.jumpBoostBindKey then S._handleJump()
    elseif S.taserTPKey and kc == S.taserTPKey then S._doTaserTP()
    end
end))

-- ========== РЕНДЕР-ЦИКЛЫ ==========
-- Aimbot (mousemoverel)
table.insert(S.connections, RS.RenderStepped:Connect(function()
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

    if not cfg.Enabled then S.lockedTarget = nil return end

    if IsBindPressed() then
        if cfg.TargetLock and S.lockedTarget then
            if not isValidTarget(S.lockedTarget) then S.lockedTarget = nil end
        end
        if not S.lockedTarget or not cfg.TargetLock then
            local best, bestDist = nil, math.huge
            for _, pl in ipairs(Players:GetPlayers()) do
                if isValidTarget(pl) then
                    local ap = getAimPart(pl.Character)
                    if ap then
                        local dist3d = (Camera.CFrame.Position - ap.Position).Magnitude
                        if dist3d <= cfg.MaxDistance then
                            if isVisible(ap) then
                                local pos, onScr = Camera:WorldToViewportPoint(ap.Position)
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
            local ap = getAimPart(S.lockedTarget.Character)
            if ap then
                local pos = ap.Position
                if cfg.Prediction then
                    local vel = Vector3.zero
                    pcall(function() vel = ap.AssemblyLinearVelocity or Vector3.zero end)
                    local dist = (Camera.CFrame.Position - pos).Magnitude
                    pos = pos + vel * cfg.PredictionFactor * (dist / 100)
                end
                local scrPos = Camera:WorldToViewportPoint(pos)
                local dx = scrPos.X - center.X
                local dy = scrPos.Y - center.Y
                mousemoverel(dx * cfg.Smoothness, dy * cfg.Smoothness)
            end
        end
    else
        S.lockedTarget = nil
    end
end))

-- Anti-Recoil (покадровая компенсация, сильнее в ADS)
-- pitch через asin(-LookVector.Y): вверх = отрицательный, вниз = положительный
-- рекоил толкает камеру ВВЕРХ → pitch уменьшается (delta < 0)
-- компенсация: mousemoverel(0, +пиксели) → мышь вниз → камера вниз
do
    local hasMMR = false
    pcall(function() hasMMR = type(mousemoverel) == "function" end)
    RS:BindToRenderStep("NeonAntiRecoil", Enum.RenderPriority.Camera.Value + 20, function()
        if not S.scriptActive then
            pcall(function() RS:UnbindFromRenderStep("NeonAntiRecoil") end)
            return
        end
        if not S.antiRecoilEnabled then
            S.arPrevPitch = nil
            return
        end
        local mb1 = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        local mb2 = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if mb1 then
            local lv = Camera.CFrame.LookVector
            local currentPitch = math.asin(-lv.Y)
            if S.arPrevPitch then
                local delta = currentPitch - S.arPrevPitch
                -- delta < 0 = камера пошла ВВЕРХ (рекоил)
                if delta < -0.0003 then
                    local recoilAmount = -delta -- положительное число
                    local mult = mb2 and 3000 or 1800
                    local px = recoilAmount * mult * S.antiRecoilStrength
                    if hasMMR then
                        mousemoverel(0, px) -- положительное = мышь вниз = компенсация
                    else
                        local pos = Camera.CFrame.Position
                        local yaw = math.atan2(lv.X, lv.Z)
                        local newPitch = currentPitch + recoilAmount * S.antiRecoilStrength
                        local nl = Vector3.new(
                            math.cos(newPitch) * math.sin(yaw),
                            -math.sin(newPitch),
                            math.cos(newPitch) * math.cos(yaw)
                        )
                        Camera.CFrame = CFrame.lookAt(pos, pos + nl, Vector3.new(0,1,0))
                    end
                end
            end
            S.arPrevPitch = math.asin(-Camera.CFrame.LookVector.Y)
        else
            S.arPrevPitch = nil
        end
    end)
    table.insert(S.connections, {Disconnect = function() pcall(function() RS:UnbindFromRenderStep("NeonAntiRecoil") end) end})
end

-- Fly (горизонт через WalkSpeed + MoveTo, вертикаль через BV)
table.insert(S.connections, RS.Heartbeat:Connect(function(dt)
    if not S.scriptActive or not S.flyEnabled then return end
    local c = LocalPlayer.Character
    if not c then return end
    local hr = c:FindFirstChild("HumanoidRootPart")
    local hm = c:FindFirstChildOfClass("Humanoid")
    if not hr or not hm then return end
    local vertDir = 0
    if UIS:IsKeyDown(Enum.KeyCode.Space) then vertDir = 1 end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vertDir = -1 end
    local vSpd = S.flySpeed
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vSpd = vSpd * 1.5 end
    if S.flyBV then
        S.flyBV.Velocity = Vector3.new(0, vertDir * vSpd, 0)
    end
    local hDir = Vector3.zero
    local lv = Camera.CFrame.LookVector
    local rv = Camera.CFrame.RightVector
    local flatLook = Vector3.new(lv.X, 0, lv.Z)
    if flatLook.Magnitude > 0.01 then flatLook = flatLook.Unit end
    local flatRight = Vector3.new(rv.X, 0, rv.Z)
    if flatRight.Magnitude > 0.01 then flatRight = flatRight.Unit end
    if UIS:IsKeyDown(Enum.KeyCode.W) then hDir = hDir + flatLook end
    if UIS:IsKeyDown(Enum.KeyCode.S) then hDir = hDir - flatLook end
    if UIS:IsKeyDown(Enum.KeyCode.A) then hDir = hDir - flatRight end
    if UIS:IsKeyDown(Enum.KeyCode.D) then hDir = hDir + flatRight end
    if hDir.Magnitude > 0.1 then
        hr.CFrame = hr.CFrame + hDir.Unit * vSpd * dt
    end
    if S.flyFakePart then
        S.flyFakePart.CFrame = hr.CFrame * CFrame.new(0,-3.5,0)
    end
end))

-- Noclip (Stepped = before physics)
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

-- Vehicle Speed (BodyVelocity boost)
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
        -- MaxSpeed boost для VehicleSeat
        if seat:IsA("VehicleSeat") then
            if not S.vehOrigSpeeds[seat] then S.vehOrigSpeeds[seat] = seat.MaxSpeed end
            pcall(function() seat.MaxSpeed = S.vehOrigSpeeds[seat] * S.vehSpeedMult end)
        end
        -- BodyVelocity boost в направлении движения
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
                if hv.Magnitude > 1 then
                    dir = hv.Unit
                else
                    dir = pp.CFrame.LookVector * (throttle > 0 and 1 or -1)
                end
                local baseSpeed = math.max(hv.Magnitude, 20)
                local targetSpeed = baseSpeed * S.vehSpeedMult
                vehBV.Velocity = Vector3.new(dir.X * targetSpeed, v.Y, dir.Z * targetSpeed)
            end
        else
            if vehBV and vehBV.Parent then
                vehBV.Velocity = Vector3.new(0, 0, 0)
            end
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
                        hpFill.Size = UDim2.new(hp,0,1,0)
                        hpFill.BackgroundColor3 = hp > 0.5 and Color3.fromRGB(0,255,0) or Color3.fromRGB(255, math.round(255*hp*2), 0)
                    end
                end
            end
        end
    end
end)) end



-- Threat Lines (линии к вооружённым/разыскиваемым гражданским)
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
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                        if onScreen then
                            active[player.UserId] = true
                            local line = S.threatLineCache[player.UserId]
                            if not line then
                                local ok, l = pcall(function()
                                    local li = Drawing.new("Line")
                                    li.Thickness = 1.5
                                    li.Color = Color3.fromRGB(255, 50, 50)
                                    li.Transparency = 0.7
                                    li.Visible = true
                                    return li
                                end)
                                if ok and l then
                                    line = l
                                    S.threatLineCache[player.UserId] = line
                                end
                            end
                            if line then
                                line.From = screenCenter
                                line.To = Vector2.new(pos.X, pos.Y)
                                line.Color = lineColor
                                line.Visible = true
                            end
                        else
                            if S.threatLineCache[player.UserId] then
                                S.threatLineCache[player.UserId].Visible = false
                            end
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

-- Auto Tablet (авто-проверка игроков с апартаментами и выдача ордера)
do
    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("__remotes")
    local tabletFolder = remotes and remotes:FindFirstChild("Tablet")
    local atTimer = 0
    local checkedPlayers = {}
    local atResults = {}
    S.autoTabletResults = atResults

    -- GUI панель результатов на экране
    local atPanel = Instance.new("Frame")
    atPanel.Name = "AutoTabletPanel"
    atPanel.Size = UDim2.new(0, 260, 0, 300)
    atPanel.Position = UDim2.new(1, -270, 0, 60)
    atPanel.BackgroundColor3 = Color3.fromRGB(15, 12, 20)
    atPanel.BackgroundTransparency = 0.15
    atPanel.BorderSizePixel = 0
    atPanel.Visible = false
    atPanel.Parent = screenGui
    Instance.new("UICorner", atPanel).CornerRadius = UDim.new(0, 10)

    local atTitle = Instance.new("TextLabel", atPanel)
    atTitle.Size = UDim2.new(1, 0, 0, 30)
    atTitle.BackgroundTransparency = 1
    atTitle.Text = t("at_title")
    registerLabel(atTitle, "at_title")
    atTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
    atTitle.Font = Enum.Font.GothamBold
    atTitle.TextSize = 14

    local atScroll = Instance.new("ScrollingFrame", atPanel)
    atScroll.Size = UDim2.new(1, -10, 1, -35)
    atScroll.Position = UDim2.new(0, 5, 0, 32)
    atScroll.BackgroundTransparency = 1
    atScroll.BorderSizePixel = 0
    atScroll.ScrollBarThickness = 3
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
            row.Size = UDim2.new(1, 0, 0, 22)
            row.BackgroundTransparency = 1
            row.Font = Enum.Font.Gotham
            row.TextSize = 12
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
            local doors = aptFolder:FindFirstChild("Doors")
            local units = aptFolder:FindFirstChild("Units")
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
        -- ищем дверь по совпадению имени или позиции
        local npName = nameplate.Name
        -- пробуем по имени (Nameplate и Door часто имеют одинаковый индекс/имя)
        local door = doors:FindFirstChild(npName)
        if door then return door end
        -- фоллбэк: ищем ближайшую дверь по позиции
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
                    if dist < closestDist then
                        closestDist = dist
                        closest = d
                    end
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
            for uid3, hl in pairs(doorHighlights) do
                pcall(function() hl:Destroy() end)
                doorHighlights[uid3] = nil
            end
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
        -- авто-экип планшета: нажать слот, подождать, потом убрать
        local slotKey = ({
            [0] = Enum.KeyCode.Zero, [1] = Enum.KeyCode.One, [2] = Enum.KeyCode.Two,
            [3] = Enum.KeyCode.Three, [4] = Enum.KeyCode.Four, [5] = Enum.KeyCode.Five,
            [6] = Enum.KeyCode.Six, [7] = Enum.KeyCode.Seven, [8] = Enum.KeyCode.Eight,
            [9] = Enum.KeyCode.Nine,
        })[S.tabletSlot]
        if slotKey then
            -- проверяем, не держим ли уже планшет
            local myChar = LocalPlayer.Character
            local bp = LocalPlayer:FindFirstChild("Backpack")
            local holding = myChar and myChar:FindFirstChildOfClass("Tool")
            local isTablet = holding and holding.Name:lower():find("tablet")
            if not isTablet then
                -- экипировать планшет
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
        local ownerCount = 0
        if next(apartOwners) then
            targets = apartOwners
            for _ in pairs(apartOwners) do ownerCount = ownerCount + 1 end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    targets[p.UserId] = {player = p, nameplate = nil}
                    ownerCount = ownerCount + 1
                end
            end
        end
        -- показываем панель сразу со статусом сканирования
        atPanel.Visible = true
        local scanning = 0
        for uid, info in pairs(targets) do
            if not checkedPlayers[uid] then
                checkedPlayers[uid] = tick()
                scanning = scanning + 1
                local player = info.player
                local nameplate = info.nameplate
                task.spawn(function()
                    local result = nil
                    local done = false
                    task.spawn(function()
                        local ok2, r = pcall(function()
                            return searchWarrant:InvokeServer(player.Name)
                        end)
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
                        local canIssue = result.CanIssue or false
                        atResults[uid] = {
                            displayName = result.DisplayName or player.DisplayName,
                            wantedLevel = wantedLevel,
                            hasWarrant = hasWarrant,
                            warranted = false,
                        }
                        if wantedLevel > 0 and not hasWarrant then
                            pcall(function()
                                obtainWarrant:InvokeServer(player.Name)
                            end)
                            atResults[uid].warranted = true
                            showNotification(t("auto_tablet"), t("at_warrant_notif")..": "..player.DisplayName.." ("..wantedLevel..")", Color3.fromRGB(255,100,0))
                        end
                        -- подсветка двери wanted игрока
                        if nameplate then
                            highlightDoor(uid, nameplate, wantedLevel > 0)
                        end
                        updateAtPanel()
                    end
                end)
            end
        end
        local now = tick()
        for uid2, t2 in pairs(checkedPlayers) do
            if now - t2 > 60 then
                checkedPlayers[uid2] = nil
                atResults[uid2] = nil
                highlightDoor(uid2, nil, false)
            end
        end
        updateAtPanel()
        -- убрать планшет после сканирования (нажать тот же слот)
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

-- Speed Boost (velocity push в направлении движения)
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

-- Jump Boost (добавить velocity вверх при прыжке)
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

-- Role cache update (every 2s)
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

-- Градиенты (один цикл для всего — оптимизация)
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
                            if S.espGradientMode == "outline" then
                                hl.OutlineColor = gc
                            else
                                hl.FillColor = gc
                            end
                        end
                    end
                end
            end
        end

        carScanTimer = carScanTimer + 0.05
        if S.carESP and carScanTimer >= 3 then
            carScanTimer = 0
            carHue = (carHue + 0.05) % 1
            local found = {}
            for _, obj in ipairs(WS:GetDescendants()) do
                if obj:IsA("VehicleSeat") then
                    local veh = obj:FindFirstAncestorWhichIsA("Model")
                    if veh and veh ~= LocalPlayer.Character and not found[veh] then
                        local partCount = 0
                        local hasWheel = false
                        for _, ch in ipairs(veh:GetDescendants()) do
                            if ch:IsA("BasePart") then
                                partCount = partCount + 1
                                local n = ch.Name:lower()
                                if n:find("wheel") or n:find("tire") or n:find("колес") then hasWheel = true end
                            end
                        end
                        if partCount >= 8 or hasWheel then
                            found[veh] = true
                        end
                    end
                end
            end
            for veh, _ in pairs(found) do
                if not veh:FindFirstChild("NeonCarHL") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "NeonCarHL"
                    hl.FillColor = Color3.fromHSV(carHue, 0.7, 1)
                    hl.OutlineColor = Color3.fromHSV((carHue + 0.3) % 1, 1, 1)
                    hl.FillTransparency = 0.55
                    hl.OutlineTransparency = 0.2
                    hl.Parent = veh
                    S.carESPCache[hl] = true
                end
            end
        end
        if S.carESP then
            carHue = (carHue + 0.002) % 1
            for hl, _ in pairs(S.carESPCache) do
                if hl and hl.Parent then
                    hl.FillColor = Color3.fromHSV(carHue, 0.7, 1)
                    hl.OutlineColor = Color3.fromHSV((carHue + 0.3) % 1, 1, 1)
                else
                    S.carESPCache[hl] = nil
                end
            end
        end
    end
end)

showNotification("ECLIPSE v2", "Border RP Edition загружен", Color3.fromRGB(168,85,247))
eclipseLog("ECLIPSE v2 fully loaded!")
