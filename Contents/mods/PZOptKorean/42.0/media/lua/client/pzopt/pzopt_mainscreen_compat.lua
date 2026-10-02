local function pzoptTr(key, fallback)
    local result = getText(key)
    if result and result ~= key then return result end
    return fallback
end

-- pzopt: the main menu's "PZ Optimization mod compatibility check" dialog (2026-10-02).
--  What pzopt.ModCompat found at this launch, one block per jar file it read (the -javaagent jars and every jar of the
--  enabled mods): the mod it belongs to, each place of a class we ship that it patches (a method we edited, an unedited
--  one, or a class named without a method), and what that changed: the settings switched off (tab label, and the
--  player's own choice where it overrides the check), "tested together", or nothing. The menu item itself is added by
--  pzopt_mainscreen_update.lua (one column of pzopt items between Credits and Exit); this file is the dialog.
--  Controller: A / B close, the D-pad scrolls, like the update dialog.

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local PAD = 12
local BTN_HGT = math.max(25, FONT_HGT_SMALL + 3 * 2)
local MAX_HITS = 40 -- per jar; a library jar can name hundreds of our classes

local WHITE = " <RGB:1,1,1> "
local GREY = " <RGB:0.65,0.65,0.65> "
local GREEN = " <RGB:0.6,1,0.6> "
local AMBER = " <RGB:1,0.85,0.45> "
local RED = " <RGB:1,0.6,0.6> "
local SP = " <SPACE> " -- the panel drops the space between two colour runs of one line

local function perf()
    return getPerformance()
end

-- the rich text panel reads < > as tags
local function esc(s)
    return (tostring(s or ""):gsub("[<>]", ""))
end

local function split(line)
    local out = {}
    for field in (line .. "\t"):gmatch("([^\t]*)\t") do
        table.insert(out, field)
    end
    return out
end

local function keyList(s)
    local out = {}
    for k in (s or ""):gmatch("[^,]+") do
        table.insert(out, k)
    end
    return out
end

-- getPzoptModCompatDetails (pzopt.ModCompat.details): scan / problem / mod / jar / hit lines
local function parse(text)
    local d = { mode = "auto", ms = "0", enabled = 0, problems = {}, mods = {}, jars = {} }
    for line in (text or ""):gmatch("[^\n]+") do
        local f = split(line)
        if f[1] == "scan" then
            d.mode, d.ms, d.enabled = f[2], f[3], tonumber(f[4]) or 0
        elseif f[1] == "problem" then
            table.insert(d.problems, f[2])
        elseif f[1] == "mod" then
            d.mods[f[2]] = { agent = f[3] == "agent", status = f[4], keys = keyList(f[5]) }
        elseif f[1] == "jar" then
            table.insert(d.jars, { source = f[2], name = f[3], path = f[4], hits = {} })
        elseif f[1] == "hit" then
            local jar = d.jars[#d.jars]
            if jar and jar.source == f[2] and jar.name == f[3] then
                table.insert(jar.hits, { where = f[4], kind = f[5], how = f[6], keys = keyList(f[7]) })
            end
        end
    end
    return d
end

-- "Label (key)" with the tab section, and the player's own choice where it beats the check
local function settingText(key)
    local label, section
    if PzoptOptionLabel then label, section = PzoptOptionLabel(key) end
    local t = label and (esc(label) .. SP .. GREY .. "(" .. key .. (section and (", " .. esc(section)) or "") .. ")") or key
    local saved = perf():getPzoptOptionSaved(key)
    local pinned = perf():getPzoptOptionPinnedBy(key)
    if pinned ~= "" then
        t = t .. SP .. AMBER .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_6bcc833bb0", "- pinned by ") .. esc(pinned) .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_707806f316", ", which wins")
    elseif saved ~= "" then
        t = t .. SP .. AMBER .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_3880fad68c", "- your choice in Options (") .. esc(saved) .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_98ee964fd2", ") wins")
    end
    return t
end

local function contains(list, v)
    for _, x in ipairs(list) do
        if x == v then return true end
    end
    return false
end

-- the jar's folder inside its mod ("42/media/java"), or the whole folder for an agent outside the mods
local function jarFolder(path, name)
    local dir = (path or ""):gsub("\\", "/"):sub(1, -(#name + 2))
    return dir:match("/mods/[^/]+/(.+)$") or dir
end

local function jarBlock(jar, mod)
    local where = jarFolder(jar.path, jar.name)
    local b = " <LINE> <H2> " .. esc(jar.name) .. " <TEXT> <LINE> " .. GREY
        .. (mod.agent and (pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_a9d7b9d704", "Java agent (-javaagent)") .. (jar.source ~= jar.name and (pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_b7c27f6df3", " of the mod ") .. esc(jar.source)) or ""))
            or (pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_b5620f5979", "Mod ") .. esc(jar.source)))
        .. (where ~= "" and (pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_9932768ef2", ", folder ") .. esc(where)) or "") .. " <LINE> "
    if #jar.hits == 0 then
        return b .. WHITE .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_a0ed4fe0f1", "Patches no class PZ Optimization ships: nothing changed. <LINE> ")
    end
    if mod.status == "ok" then
        b = b .. GREEN .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_4887f59fdf", "Tested together with PZ Optimization: every setting stays as you chose. <LINE> ")
    elseif mod.status == "report" then
        b = b .. AMBER .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_76d60e5eed", "Nothing switched off (Java mods: report, the max performance default). <LINE> ")
    end
    for i, h in ipairs(jar.hits) do
        if i > MAX_HITS then
            b = b .. GREY .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_e15cede051", "... and ") .. (#jar.hits - MAX_HITS) .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_fa03bb20da", " more (Zomboid/pzopt/mod-compat.txt lists them all) <LINE> ")
            break
        end
        b = b .. WHITE .. " - " .. esc(h.where) .. SP .. GREY .. "(" .. esc(h.how) .. ") <LINE> "
        if h.kind == "edited" then
            local off = {}
            for _, k in ipairs(h.keys) do
                if mod.status == "off" and contains(mod.keys, k) then
                    table.insert(off, k)
                end
            end
            if #off > 0 then
                for _, k in ipairs(off) do
                    b = b .. " <INDENT:24> " .. AMBER .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_3e8a6a05ee", "switched off:") .. SP .. WHITE .. settingText(k) .. " <LINE> "
                end
            elseif mod.status == "report" and #h.keys > 0 then
                for _, k in ipairs(h.keys) do
                    b = b .. " <INDENT:24> " .. GREY .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_4efaba53ab", "max compatibility would switch off:") .. SP .. WHITE .. settingText(k) .. " <LINE> "
                end
            elseif mod.status == "ok" then
                b = b .. " <INDENT:24> " .. GREY .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_ffe376c3dc", "a method PZ Optimization changed; known to work with it <LINE> ")
            else
                b = b .. " <INDENT:24> " .. GREY .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_9ff44556f6", "a method PZ Optimization changed that holds no setting: left as is <LINE> ")
            end
        elseif h.kind == "stock" then
            b = b .. " <INDENT:24> " .. GREY .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_ff544c6da7", "a method PZ Optimization left as the game ships it: nothing changed <LINE> ")
        else
            b = b .. " <INDENT:24> " .. GREY .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_2b954c8f48", "the class is named, no method of ours found: nothing changed <LINE> ")
        end
        b = b .. " <INDENT:0> "
    end
    return b
end

-- Keys switched off for a mod that none of its patched methods holds: an off: rule of Zomboid/pzopt/mod-compat.ini.
local function ruleBlock(source, mod, jars)
    if mod.status ~= "off" then return "" end
    local held = {}
    for _, jar in ipairs(jars) do
        if jar.source == source then
            for _, h in ipairs(jar.hits) do
                for _, k in ipairs(h.keys) do held[k] = true end
            end
        end
    end
    local b = ""
    for _, k in ipairs(mod.keys) do
        if not held[k] then
            b = b .. " <INDENT:24> " .. WHITE .. settingText(k) .. " <LINE> <INDENT:0> "
        end
    end
    if b == "" then return "" end
    return AMBER .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_a2db831939", "Also switched off for ") .. esc(source) .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_4384801c50", " by Zomboid/pzopt/mod-compat.ini: <LINE> ") .. b
end

local function body()
    local d = parse(perf():getPzoptModCompatDetails())
    local t = ""
    if d.mode == "off" then
        return pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_bd524127c1", "The check is off (Options > Optimizations > Mod compatibility > Java mods: off), so no mod was read at this launch. ")
            .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_132b12dfc8", "Set it to auto and restart the game to see what your mods change.")
    end
    local switched = {}
    for _, mod in pairs(d.mods) do
        if mod.status == "off" then
            for _, k in ipairs(mod.keys) do switched[k] = true end
        end
    end
    local nSwitched = 0
    for _ in pairs(switched) do nSwitched = nSwitched + 1 end
    local lastOf = {}
    for i, jar in ipairs(d.jars) do lastOf[jar.source] = i end

    t = t .. string.format(pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_447fff96b2", "Checked at this launch in %s ms: enabled mods %d, Java files (.jar) read %d. <LINE> "), esc(d.ms), d.enabled, #d.jars)
    if nSwitched > 0 then
        t = t .. AMBER .. string.format(pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_6e2cde8c74", "Settings switched off at this launch: %d. This lets a mod meet the game code its author tested."), nSwitched)
            .. SP .. WHITE .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_40da8017a8", "Your own choice in Options wins over this check. <LINE> ")
    elseif #d.jars > 0 then
        t = t .. GREEN .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_06e6d02239", "No setting is switched off. <LINE> ") .. WHITE
    end
    if d.mode == "report" and #d.jars > 0 then
        t = t .. AMBER .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_537dace022", "Java mods are only listed (report): nothing is switched off. Max compatibility switches off what they patch. <LINE> ") .. WHITE
    end
    for _, p in ipairs(d.problems) do
        t = t .. RED .. esc(p) .. " <LINE> " .. WHITE
    end
    if #d.jars == 0 then
        t = t .. " <LINE> " .. WHITE .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_11eae23867", "No enabled mod carries Java code and the game runs without a Java agent: nothing to switch off. ")
            .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_1e544af109", "For mods made of Lua, scripts and textures the choice above decides one thing: ")
            .. (perf():getPzoptOption("uiRetainedMods") == "true"
                and pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_923b6e408a", "windows a mod draws in are reused like the game's own (max performance; a mod's display can lag by up to a second). ")
                or pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_e27e28722b", "windows a mod draws in are redrawn at the game's own rate (max compatibility). "))
            .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_3bb6c8a451", "Mod Lua reached from helper threads runs on the game thread with either choice. <LINE> ")
    end
    for i, jar in ipairs(d.jars) do
        local mod = d.mods[jar.source] or { status = "none", keys = {} }
        t = t .. jarBlock(jar, mod)
        if lastOf[jar.source] == i then t = t .. ruleBlock(jar.source, mod, d.jars) end
    end
    t = t .. " <LINE> " .. GREY .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_2e7b652878", "Full report: Zomboid/pzopt/mod-compat.txt and console.txt. Changes to the enabled mods apply on the next launch.")
    return t
end

PzoptCompatDialog = ISPanelJoypad:derive("PzoptCompatDialog")
PzoptCompatDialog.instance = nil

function PzoptCompatDialog:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.85 }
    o.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    o.moveWithMouse = true
    return o
end

-- --- the choice: max performance (default) or max compatibility (Config key modProfile) ---------------------------

local PROFILE_KEY = "modProfile"
local PROFILE_FOLLOWERS = { "modCompat", "uiRetainedMods" } -- their defaults follow modProfile (Config)
local PROFILE_NAMES = { performance = pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_6e0c0a64f8", "Max performance"), compatibility = pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_608bf41caf", "Max compatibility") }

-- the value since this launch, the one the next launch reads, and what pins it ("" = the player decides)
local function profileState()
    local p = perf()
    local now = p:getPzoptOption(PROFILE_KEY)
    local saved = p:getPzoptOptionSaved(PROFILE_KEY)
    local nextValue = saved ~= "" and saved or p:getPzoptOptionDefault(PROFILE_KEY)
    return now, nextValue, p:getPzoptOptionPinnedBy(PROFILE_KEY)
end

function PzoptCompatDialog:choose(value)
    local _, nextValue, pinned = profileState()
    if pinned ~= "" or value == nextValue then return end
    local p = perf()
    -- the default is stored as no line (a later build's default then applies); the two settings it sets go back to
    -- following it, so the choice is the whole of it
    p:setPzoptOption(PROFILE_KEY, value == p:getPzoptOptionDefault(PROFILE_KEY) and "" or value)
    for _, k in ipairs(PROFILE_FOLLOWERS) do
        if p:getPzoptOptionSaved(k) ~= "" then p:setPzoptOption(k, "") end
    end
    PzoptLogInfo("[pzopt] mod compatibility: " .. value .. " chosen for the next launch")
    getSoundManager():playUISound("UIActivateMainMenuItem")
    self:syncProfile()
end

-- button colours, the status line and the Restart button follow the saved choice. Fresh colour tables every time and no
-- ISButton:setEnable: it restores the colours it saw first by writing into the button's tables. A pinned key ignores
-- clicks (choose) and says so in the status line.
function PzoptCompatDialog:syncProfile()
    local now, nextValue, pinned = profileState()
    for value, btn in pairs(self.profileButtons) do
        local on = value == nextValue
        btn.backgroundColor = on and { r = 0.16, g = 0.42, b = 0.22, a = 1 } or { r = 0, g = 0, b = 0, a = 1 }
        btn.borderColor = { r = 1, g = 1, b = 1, a = on and 0.9 or 0.4 }
    end
    local pending = now ~= nextValue
    if pinned ~= "" then
        self.profileStatus = pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_738a643657", "Pinned by ") .. pinned .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_09bdd1f2ad", " on this install")
    elseif pending then
        self.profileStatus = pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_2d36848533", "Running now: ") .. (PROFILE_NAMES[now] or now) .. pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_1c645deddb", ". Applies after a restart.")
    else
        self.profileStatus = pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_51b5dad041", "In use since this launch.")
    end
    self.restart:setVisible(pending and pinned == "")
    self:syncJoypadButtons()
end

function PzoptCompatDialog:onRestart()
    local ok, started = pcall(function() return perf():pzoptRestartGame() end)
    if not ok or not started then
        print("[pzopt] mod compatibility: could not start the restart helper, quitting only")
    end
    self:close()
    MainScreen.instance:quitToDesktop()
end

function PzoptCompatDialog:createChildren()
    ISPanelJoypad.createChildren(self)
    local rowY = PAD + FONT_HGT_MEDIUM + PAD
    self.profileButtons = {}
    local x = PAD
    for _, value in ipairs({ "performance", "compatibility" }) do
        local title = PROFILE_NAMES[value] .. (value == perf():getPzoptOptionDefault(PROFILE_KEY) and pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_f1aeec6a94", " (default)") or "")
        local w = math.max(150, getTextManager():MeasureStringX(UIFont.Small, title) + 24)
        local btn = ISButton:new(x, rowY, w, BTN_HGT, title, self, function(dlg) dlg:choose(value) end)
        btn:initialise()
        btn:instantiate()
        btn.tooltip = value == "performance"
            and pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_3e147a4a17", "Java mods are checked and listed here but switch nothing off; windows a mod draws in are reused like the game's own (a mod's display can lag by up to a second).")
            or pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_75567253ad", "The settings a Java mod patches are switched off so the mod meets the game code its author tested; windows a mod draws in are redrawn at the game's own rate.")
        self:addChild(btn)
        self.profileButtons[value] = btn
        x = x + w + PAD
    end
    self.profileStatusX = x
    local rw = math.max(130, getTextManager():MeasureStringX(UIFont.Small, pzoptTr("UI_pzopt_text_pzopt_mainscreen_update_1ed1fa61c6", "Restart game")) + 24)
    self.restart = ISButton:new(self.width - PAD - rw, rowY, rw, BTN_HGT, pzoptTr("UI_pzopt_text_pzopt_mainscreen_update_1ed1fa61c6", "Restart game"), self, PzoptCompatDialog.onRestart)
    self.restart:initialise()
    self.restart:instantiate()
    self.restart:enableAcceptColor()
    self:addChild(self.restart)

    local textTop = rowY + BTN_HGT + PAD
    local textHgt = self.height - textTop - PAD - BTN_HGT - PAD
    self.text = ISRichTextPanel:new(PAD, textTop, self.width - PAD * 2, textHgt)
    self.text:initialise()
    self.text.background = false
    self.text.clip = true
    self.text.autosetheight = false
    self.text.marginLeft = 0
    self.text.marginTop = 0
    self.text.marginRight = 0
    self.text:addScrollBars()
    self:addChild(self.text)
    local ok, t = pcall(body)
    if not ok then
        print("[pzopt] mod compatibility check: " .. tostring(t))
        t = pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_795262bbf3", "The check's result could not be read; see Zomboid/pzopt/mod-compat.txt.")
    end
    self.text.text = t
    self.text:paginate()
    -- the panel shrinks to the text (a short result is a small dialog), at most the height it was opened with
    local fit = math.min(textHgt, self.text:getScrollHeight() + 4)
    if fit < textHgt then
        self.text:setHeight(fit)
        self:setHeight(self.height - (textHgt - fit))
        self:setY((getCore():getScreenHeight() - self.height) / 2)
    end

    local w = math.max(110, getTextManager():MeasureStringX(UIFont.Small, pzoptTr("UI_pzopt_text_mainscreen_update_0a92d59cc3", "Close")) + 24)
    self.close_ = ISButton:new((self.width - w) / 2, self.height - PAD - BTN_HGT, w, BTN_HGT, pzoptTr("UI_pzopt_text_mainscreen_update_0a92d59cc3", "Close"), self, PzoptCompatDialog.close)
    self.close_:initialise()
    self.close_:instantiate()
    self:addChild(self.close_)
    self:syncProfile()
end

function PzoptCompatDialog:prerender()
    ISPanelJoypad.prerender(self)
    self:drawText(pzoptTr("UI_pzopt_text_pzopt_mainscreen_compat_fdde45138d", "PZ Optimization mod compatibility check"), PAD, PAD, 1, 1, 1, 1, UIFont.Medium)
    if self.profileStatus then
        local a = self.restart:isVisible() and 1 or 0.65
        self:drawText(self.profileStatus, self.profileStatusX, PAD + FONT_HGT_MEDIUM + PAD + (BTN_HGT - FONT_HGT_SMALL) / 2,
            a, a, a * (self.restart:isVisible() and 0.6 or 1), 1, UIFont.Small)
    end
end

-- Controller: X = Max performance, Y = Max compatibility, A = Restart game while a new choice waits for one (else
-- Close), B = Close; the D-pad scrolls.
function PzoptCompatDialog:syncJoypadButtons()
    if not self.joyfocus or not self.close_ then return end
    self:setISButtonForX(self.profileButtons.performance)
    self:setISButtonForY(self.profileButtons.compatibility)
    if self.restart:isVisible() then
        self.close_:clearJoypadButton()
        self:setISButtonForA(self.restart)
    else
        self.restart:clearJoypadButton()
        self:setISButtonForA(self.close_)
    end
end

function PzoptCompatDialog:onGainJoypadFocus(joypadData)
    ISPanelJoypad.onGainJoypadFocus(self, joypadData)
    self.joypadButtons = {}
    self:syncJoypadButtons()
end

function PzoptCompatDialog:onLoseJoypadFocus(joypadData)
    ISPanelJoypad.onLoseJoypadFocus(self, joypadData)
    self.ISButtonA = nil
    self.ISButtonX = nil
    self.ISButtonY = nil
    for _, b in ipairs({ self.close_, self.restart, self.profileButtons.performance, self.profileButtons.compatibility }) do
        b:clearJoypadButton()
    end
end

function PzoptCompatDialog:onJoypadDown(button, joypadData)
    if button == Joypad.BButton then
        self:close()
        return
    end
    ISPanelJoypad.onJoypadDown(self, button, joypadData)
end

function PzoptCompatDialog:onJoypadDirUp(joypadData)
    self.text:setYScroll(self.text:getYScroll() + 18 * 3)
end

function PzoptCompatDialog:onJoypadDirDown(joypadData)
    self.text:setYScroll(self.text:getYScroll() - 18 * 3)
end

function PzoptCompatDialog:onKeyRelease(key)
    if key == Keyboard.KEY_ESCAPE then
        self:close()
        return true
    end
end

function PzoptCompatDialog:close()
    self:setVisible(false)
    self:removeFromUIManager()
    PzoptCompatDialog.instance = nil
    local ms = MainScreen.instance
    if ms and ms.bottomPanel then
        ms.bottomPanel:setVisible(true)
    end
    -- the controller's focus goes back to the menu, then onto the item that opened the dialog
    local joypadData = self.joyfocus
    if joypadData and joypadData.focus == self then
        joypadData.focus = self.prevFocus
        updateJoypadFocus(joypadData)
        if ms and joypadData.focus == ms and ms.joyfocus and ms.pzoptCompatOption then
            if ms:setJoypadFocus(ms.pzoptCompatOption, joypadData) then
                ms:updateBottomPanelButtons()
            end
        end
    end
end

function PzoptCompatDialog.show()
    if PzoptCompatDialog.instance then
        PzoptCompatDialog.instance:close()
    end
    -- the height is the most it may take (createChildren fits it to the text); never past the screen
    local sw, sh = getCore():getScreenWidth(), getCore():getScreenHeight()
    local width = math.min(sw - 40, math.max(760, math.min(1100, math.floor(sw * 0.4))))
    local height = math.min(sh - 40, math.max(620, math.floor(sh * 0.7)))
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2
    local dlg = PzoptCompatDialog:new(x, y, width, height)
    dlg:initialise()
    dlg:addToUIManager()
    dlg:setAlwaysOnTop(true)
    dlg:bringToTop()
    PzoptCompatDialog.instance = dlg
    MainScreen.instance.bottomPanel:setVisible(false)
    local joypadData = JoypadState.getMainMenuJoypad()
    if joypadData then
        dlg.prevFocus = joypadData.focus
        joypadData.focus = dlg
        updateJoypadFocus(joypadData)
    end
end
