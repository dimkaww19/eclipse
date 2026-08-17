local results = ""

local function test(name, func)
    local ok, err = pcall(func)
    local status = ok and "OK" or "FAIL"
    results = results .. name .. ": " .. status .. "\n"
end

test("fireproximityprompt", function() assert(fireproximityprompt ~= nil) end)
test("writefile", function() assert(writefile ~= nil) end)
test("readfile", function() assert(readfile ~= nil) end)
test("Drawing", function() local c = Drawing.new("Circle") c:Remove() end)
test("getgenv", function() assert(getgenv ~= nil) end)
test("hookfunction", function() assert(hookfunction ~= nil) end)
test("hookmetamethod", function() assert(hookmetamethod ~= nil) end)
test("setclipboard", function() assert(setclipboard ~= nil) end)
test("VirtualInputManager", function() assert(game:GetService("VirtualInputManager") ~= nil) end)

local uis = game:GetService("UserInputService")
results = results .. "TouchEnabled: " .. tostring(uis.TouchEnabled) .. "\n"
local cam = workspace.CurrentCamera
results = results .. "Screen: " .. tostring(math.floor(cam.ViewportSize.X)) .. "x" .. tostring(math.floor(cam.ViewportSize.Y)) .. "\n"

local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "DeltaTest"
local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 350, 0, 300)
frame.Position = UDim2.new(0.5, -175, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(20, 18, 30)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "DELTA TEST"
title.TextColor3 = Color3.fromRGB(168, 85, 247)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local lbl = Instance.new("TextLabel", frame)
lbl.Size = UDim2.new(1, -20, 1, -60)
lbl.Position = UDim2.new(0, 10, 0, 35)
lbl.BackgroundTransparency = 1
lbl.Text = results
lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
lbl.Font = Enum.Font.Code
lbl.TextSize = 13
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.TextYAlignment = Enum.TextYAlignment.Top

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
