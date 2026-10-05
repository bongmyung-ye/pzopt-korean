-- pzopt: how the PZ Optimization options tab organises its settings (2026-10-04). Data only, read by
-- pzopt_optimizations_options.lua when it builds the tab (this file loads first: the client files load in name order).
--  groups -> categories -> subcategories. A subcategory lists its keys (`keys`) or takes every key of the tab sections
--  whose title starts with one of `sections`. A key no subcategory claims lands in the "More" subcategory of the
--  category its section maps to in `home` (so a new setting always shows up somewhere).
--  `simple`: the settings the Simple view shows (what a player would change); `expertKeys` / `expertPatterns`: tuning
--  numbers the Everything view adds; the rest is Advanced. `problems`: the "Fix a problem" page.

PzoptSettingsLayout = {
    groups = {
        { id = "perf", title = "Performance", page = 1, colour = { 0.42, 0.80, 0.52 },
          note = "Smoother frames and faster loads. Nothing here changes how the game looks.",
          cats = {
            { id = "smooth", title = "Smoothness and pacing", blurb = "Even frame delivery, variable refresh and input latency.",
              subs = {
                { title = "Frame pacing", keys = { "presentPacing", "limiterSleep", "frameClockSmooth", "borderlessFullscreen" } },
                { title = "Variable refresh", keys = { "vrr", "vrrCap", "macGlCore", "macGlTimerQueries", "macPresent" } },
                { title = "Input latency", keys = { "inputLatch", "keyboardFresh", "reflexSleep", "reflexBoost", "reflexCapFps",
                    "vblankLock", "gpuMaxFrames", "frameStartGate", "vsyncAdaptive", "cursorLatch", "aimHoldMs" } },
              } },
            { id = "drive", title = "Driving", blurb = "The car's stutter and rubber banding, and the world arriving at speed.",
              subs = {
                { title = "Car smoothness", keys = { "vehicleSmooth", "driveCameraLate", "driveLookSmooth", "cameraScreenPixels",
                    "physicsStepHz", "physicsStepMode" } },
                { title = "Chunk streaming", keys = { "parallel", "workers", "loadWorkers", "wake", "chunkHandoffDivisor",
                    "hotsaveStaged", "hotsaveIntervalSec" } },
                { title = "Render distance", keys = { "chunkGridWidth", "chunkGridFollowView" } },
                { title = "Trees while driving", keys = { "driveTreeCutaway", "treeRebakeLazy", "treeRebakeLingerMs",
                    "treeCutawayReach", "treeCutawayReachPx", "treeBakeMaxChunksPerSec" } },
              } },
            { id = "world", title = "World drawing", blurb = "What the chunk pictures hold and how many are drawn in a frame.",
              subs = {
                { title = "What bakes", keys = { "treesInChunkTexture", "treeBakeDirect", "treeBakePass", "treeAppend",
                    "windowsInChunkTexture", "translucentTilesInChunkTexture", "glassTilesPerFrame", "floorDecalsPerFrame", "translucentLightsPerFrame",
                    "curtainDepthNudgePct", "windSpriteSway" } },
                { title = "Bake budgets", keys = { "bakeScheduler", "bakeFrameBudget", "bakeBudgetAdaptive", "occlusionGrantedOnly",
                    "bakeMipLevels", "renderChunkTopUp", "bakeBudget", "rebakeBudget", "rebakeMaxFrames" } },
                { title = "Zoom", keys = { "zoomRetain", "zoomEase", "zoomEaseMs", "zoomRebakeBudget", "zoomPlaceholder", "zoomFrameMs" } },
                { title = "Blood and flies", keys = { "bloodBake", "bloodAppend", "bloodSettleSec", "bloodFadeFix",
                    "bloodRebakeCoalesceMs", "bloodAppendPlants", "bloodAppendVegetation", "fliesToggleFix" } },
                { title = "Sprite buffers", keys = { "persistentVbo", "persistentVboFrameSync", "persistentVboSlots", "vboBatchKb", "vboFastQuads" } },
              } },
            { id = "weather", title = "Lighting, cutaways and weather", blurb = "Light refreshes, see-through walls and roofs, fog, rain and puddles.",
              subs = {
                { title = "Lighting", keys = { "lightInfoChunkGate", "lightInfoOncePerFrame", "lightSwitchCheckFrames", "visBlurReduce",
                    "lightingBudget", "lightingFlush", "lightingRebakeBudget", "lightingRebakeMaxFrames", "lightingRebakeMs",
                    "lightingStrongDelta", "lightingStrongBudget", "lightingStrongFrameMs", "lightingGlobalDeltaPct", "losLightPrefetch" } },
                { title = "Cutaways", keys = { "cutawayFast", "roofHideDebounceFrames", "cutawayRadius", "cutawayVisitPrefilter",
                    "cutawayInvalidateChanged", "gridStackInterval", "occlusionSkipLightingOnly", "visPolyAsync", "translucentOrderCache" } },
                { title = "Fog", keys = { "fogPass", "fogScalePct", "fogMaskFrames", "weatherMaskIdleSkip", "weatherFxScalePct" } },
                { title = "Rain and puddles", keys = { "rainTiles", "puddleCache", "rainSplashesFast", "puddleCacheFrames", "puddleEarlyZ", "puddleVbo" } },
              } },
            { id = "zombies", title = "Zombies and hordes", blurb = "The zombie simulation spread over every core, and cheaper checks.",
              subs = {
                { title = "On other cores", keys = { "animBonesParallel", "actionEvalParallel", "charDrawPrep", "frameThreads",
                    "animatorParallel", "headOnWorker", "animatorPipeline", "animBatchAsync", "guardedCallbacks", "lightingReadParallel",
                    "charDrawThreads", "separateParallel", "skinTransformsPrecompute", "skinPalettePrecompute", "shadowPrep", "aoContextParallel" } },
                { title = "Cheaper checks", keys = { "playerLosFast", "ecsLookupFast", "actionConditionFast", "zombieCullSortFast", "vehicleCull",
                    "zombieSpotFast", "zombieAtlasFast", "separateFast", "edgeTestFast", "sleepCheckMemo", "stateParamMemo",
                    "actionGroupCache", "boneIndexCache", "lazyPose", "modelLockPerInstance", "poolStatsBatched", "actionSnapshotFilter",
                    "emitterParamSkip", "profilerThreadMemo" } },
                { title = "Detail by distance", keys = { "zombieLodDynamic", "zombieSimLodTiles", "zombieSimLodSteps", "zombieCheckSpread",
                    "zombieLodMin3d", "zombieLodMinBlend", "zombieLodUncappedFps" } },
              } },
            { id = "load", title = "Boot and loading", blurb = "From launch to the menu, and from Continue to the world.",
              subs = {
                { title = "Loading screen", keys = { "noLoadingScreen", "resumeShot", "centerFirstLoad", "resumeShotDetail", "noLoadFade",
                    "noIntroWait", "noClickToStart" } },
                { title = "Boot", keys = { "aotCache", "fmodAsync", "preloadAnimSets", "bootPump", "bootFileThreads", "earlyModels",
                    "luaPrecompile", "animClipCache", "packIndex", "scriptParserFast", "itemParamSwitch", "earlyTilePacks" } },
                { title = "Files and textures", keys = { "texCompress", "fileThreads", "fileInflight", "textureBufferMb", "parallelDepthMaps",
                    "loaderCpuFixes", "shaderCache", "mipmapArrays", "tileDefPreload", "skipIdChecks", "voronoiFast" } },
              } },
            { id = "ui", title = "Menus, inventory and map", blurb = "Windows that answer in the frame you click.",
              subs = {
                { title = "Windows", keys = { "uiRetained", "uiRetainedChildren", "uiTickStagger", "uiLuaFast", "hotsaveWarmup" } },
                { title = "Map", keys = { "mapStreetCache", "mapStreetMemo", "mapVisitedFast" } },
                { title = "Lua", keys = { "luaIndexCache", "luaInternConstants", "luaSkipEmpty" } },
              } },
            { id = "system", title = "System, sound and mods", blurb = "Cores and power, the audio mix, other mods, updates.",
              subs = {
                { title = "Cores and power", keys = { "corePlacement", "gpuPstate", "jitSteady", "lightingSyncPark" } },
                { title = "Sound", keys = { "audioLimiter", "audioLimiterCeilingDb", "audioLimiterStereoFold", "soundTickHz",
                    "emitterIdleSkip", "worldSoundCleanupFast", "hearingHoist", "soundZoneCache", "worldSoundFast" } },
                { title = "Mods and multiplayer", keys = { "modProfile", "modCompat", "uiRetainedMods", "luaWorkerGate", "luaChecksumExempt" } },
                { title = "Updates", keys = { "updateCheck", "updatePrefetch", "updateFromWorkshop" } },
              } },
          } },
        { id = "vis", title = "Visuals", page = 2, colour = { 0.98, 0.72, 0.30 }, cards = true,
          note = "Graphics the stock game does not have. Off by default; each card says what it costs.",
          cats = {
            { id = "image", title = "Image quality", blurb = "Upscalers, dynamic resolution, sprite filtering and HDR output.",
              subs = {
                { title = "Upscaling", sections = { "Upscaling" }, dlssButton = true },
                { title = "Dynamic resolution", sections = { "Dynamic resolution" } },
                { title = "Sprite filtering", sections = { "Sprite filtering" } },
                { title = "HDR output", sections = { "HDR output" } },
              } },
            { id = "light", title = "Lighting and shadows", blurb = "Per-pixel light, the real sky's shadows, ambient occlusion and god rays.",
              subs = {
                { title = "Per-pixel lighting", sections = { "Per-pixel lighting", "Light from the torch itself" } },
                { title = "Sun, moon and clouds", sections = { "Sun, moon and cloud shadows" } },
                { title = "Ambient occlusion", sections = { "Ambient occlusion" } },
                { title = "God rays", sections = { "God rays" } },
              } },
            { id = "refl", title = "Reflections and glass", blurb = "Water and puddles, mirrors and windows, car glass, wet blood.",
              subs = {
                { title = "Water and puddles", sections = { "Reflections" } },
                { title = "Mirrors and windows", sections = { "Mirrors and windows" } },
                { title = "Car glass", sections = { "Car glass" } },
                { title = "Wet blood", sections = { "Wet blood" } },
              } },
            { id = "atmos", title = "Atmosphere and detail", blurb = "Darkness and colour grading, foliage sway, relief, zombie outlines.",
              subs = {
                { title = "Darkness and grading", sections = { "Darkness, remembered places" } },
                { title = "Foliage sway", sections = { "Foliage sway" } },
                { title = "Relief", sections = { "Relief" } },
                { title = "Zombie outlines", sections = { "Occluded zombie outlines" } },
              } },
          } },
        { id = "tools", title = "Tools", page = 3, colour = { 0.45, 0.68, 0.98 },
          note = "The performance overlay (F9), its game-thread profiler and the console log.",
          cats = {
            { id = "overlay", title = "Performance overlay", blurb = "Frame times, utilization and what the game thread does, on screen.",
              subs = {
                { title = "Overlay", sections = { "Performance overlay (" } },
                { title = "Fps colour", sections = { "Performance overlay: fps" } },
                { title = "Console log", sections = { "Console log" } },
              } },
          } },
    },

    -- a key no subcategory lists: its section's title prefix -> category id
    home = {
        { "Chunk textures", "world" }, { "Cutaways", "weather" }, { "Entity updates", "zombies" }, { "More game-thread", "zombies" },
        { "Sprite buffers", "world" }, { "Input latency", "smooth" }, { "Menus", "ui" }, { "Mod compat", "system" },
        { "Driving", "drive" }, { "Variable refresh", "smooth" }, { "CPU cores", "system" }, { "Sound", "system" },
        { "Multiplayer", "system" }, { "Updates", "system" }, { "Render distance", "drive" }, { "Chunk streaming", "drive" },
        { "Boot", "load" }, { "World load", "load" },
    },

    simple = { "presentPacing", "vrr", "vrrCap", "inputLatch", "reflexSleep", "cursorLatch", "vehicleSmooth", "driveLookSmooth",
        "chunkGridWidth", "parallel", "driveTreeCutaway", "treesInChunkTexture", "windowsInChunkTexture", "bakeScheduler", "zoomRetain",
        "zoomEase", "persistentVbo", "bloodBake", "lightInfoChunkGate", "cutawayFast", "roofHideDebounceFrames", "fogPass", "rainTiles",
        "puddleCache", "animBonesParallel", "actionEvalParallel", "charDrawPrep", "zombieLodDynamic", "playerLosFast", "noLoadingScreen",
        "resumeShot", "centerFirstLoad", "aotCache", "texCompress", "uiRetained", "mapStreetCache", "luaSkipEmpty", "corePlacement",
        "gpuPstate", "audioLimiter", "modProfile", "updateCheck",
        "upscaler", "upscalerQuality", "dynRes", "dynResFps", "spriteFilter", "hdrAuto", "hdr", "pixelLight", "torchSource",
        "sunShadows", "sunShadowStrengthPct", "moonShadows", "cloudShadows", "ambientOcclusion", "godRays", "godRaysStrengthPct",
        "reflections", "reflectionPuddles", "mirrors", "mirrorsWindows", "carGlass", "carOccupant", "bloodWet", "darknessFloorPct",
        "memoryTint", "colorGrading", "foliageSway", "foliageSwayPct", "relief", "occludedZombieOutlines",
        "overlaySampling", "overlay", "overlayStats", "overlayGraph", "overlayCorner", "overlayFont", "overlayFpsColor", "consoleLog" },

    -- tuning numbers and thread counts (Everything view); names matching expertPatterns count too, on the Performance pages
    expertKeys = { "workers", "loadWorkers", "frameThreads", "charDrawThreads", "bootFileThreads", "fileThreads", "fileInflight",
        "textureBufferMb", "physicsStepHz", "physicsStepMode", "vblankLock", "gpuMaxFrames", "aimHoldMs", "zoomEaseMs",
        "curtainDepthNudgePct", "lightingGlobalDeltaPct", "fogScalePct", "weatherFxScalePct", "macGlTimerQueries", "gameThreadProfileHz",
        "overlayRefreshMs", "overlayGraphHz", "overlayFlameDepth", "overlayTexture" },
    expertPatterns = { "Budget$", "MaxFrames$", "Ms$", "Frames$", "Threads$", "Divisor$", "Hz$", "Kb$", "Mb$", "Slots$", "Delta$",
        "Interval", "Px$", "Steps$", "Tiles$", "Sec$", "Spread$", "PerSec$", "Min3d$", "MinBlend$", "UncappedFps$", "^dev" },

    -- "Fix a problem": what players report, why it happens, the settings that help (wherever they live)
    problems = {
        { title = "Stutter while driving",
          cause = "Chunks arrive faster than their pictures bake, and the car is drawn at its physics steps.",
          why = "At 120 km/h about 50 new chunks a second reach the screen. Stock bakes each chunk's picture in the frame it arrives, and it draws the car and the camera at the last 100 Hz physics step, so the car rubber-bands against the street. These spread the bakes over frames, draw the car between its physics steps and keep trees in the bake. Rosewood town drive at the 240 cap: stock 153 fps (p99 36 ms), with these 235 fps (p99 8 ms).",
          keys = { "vehicleSmooth", "driveLookSmooth", "bakeScheduler", "bakeBudgetAdaptive", "treeRebakeLazy", "treeCutawayReach",
              "parallel", "wake" } },
        { title = "Low fps in a big horde",
          cause = "Stock runs the whole zombie simulation on the game thread.",
          why = "Every zombie's animation, decisions and drawing preparation run one after the other on the game thread, while the other cores idle. These run them on every core and skip checks that cannot change anything. The Louisville horde (about 2,000 zombies), same build with these off and on: 46 to 58 fps.",
          keys = { "animBonesParallel", "actionEvalParallel", "charDrawPrep", "lightingReadParallel", "playerLosFast", "zombieSpotFast",
              "zombieLodDynamic" } },
        { title = "Long boot and loading",
          cause = "Boot work runs one file at a time, and the loading screen waits for everything.",
          why = "Stock parses scripts, animations and textures on one thread at boot and shows a loading screen until the whole cell is ready. These do the boot work on several threads with caches, and enter the world from the centre outwards with the last view on screen meanwhile. Launch to menu 7.4 to 5.0 s, Continue to the world 6.5 to 4.0 s.",
          keys = { "aotCache", "noLoadingScreen", "resumeShot", "centerFirstLoad", "luaPrecompile", "animClipCache", "texCompress" } },
        { title = "Storms, fog and rain are slow",
          cause = "Stock redraws fog rows and every wet square each frame.",
          why = "Heavy fog is drawn as about 190 screen-wide rows per level, and rain re-packs every particle and puddle every frame. These draw fog in one pass, rain as repeated tiles and keep the puddles on the GPU. 120 km/h drive in heavy fog: 220 to 389 fps; thunderstorm: 83 to 131 fps.",
          keys = { "fogPass", "rainTiles", "puddleCache", "puddleVbo", "lightingRebakeBudget" } },
        { title = "Input feels laggy",
          cause = "Input is read early and finished frames queue up for the GPU.",
          why = "Stock reads the keyboard and mouse well before the frame they move is shown, and lets the driver queue frames. These read the newest input when a frame starts, keep the queue short and draw the cursor at the newest mouse position.",
          keys = { "inputLatch", "keyboardFresh", "reflexSleep", "gpuMaxFrames", "cursorLatch" } },
        { title = "Screen tears or judders",
          cause = "Borderless never gets variable refresh, and frames reach the screen unevenly.",
          why = "A borderless window does not count as fullscreen for the desktop, so G-SYNC / FreeSync stay off, and frames reach the screen as soon as they are ready. These make the window count as fullscreen, keep the frame rate inside the display's range and hand frames over at even steps (judder 3.1 to 0.95 ms).",
          keys = { "vrr", "vrrCap", "presentPacing", "borderlessFullscreen" } },
        { title = "Menus and inventory are slow",
          cause = "Every window redraws every frame, with or without a change.",
          why = "An open inventory took the Lua UI from 2 to 12 % of the game thread in stock. These redraw only what changed, the moment you act, and keep the map's labels while the view stays.",
          keys = { "uiRetained", "uiRetainedChildren", "uiTickStagger", "mapStreetCache", "luaSkipEmpty" } },
        { title = "Laptop, Steam Deck or battery",
          cause = "The game's threads land on slow cores and the GPU clock goes up and down.",
          why = "On hybrid CPUs the game thread can end up on an efficient core; small GPUs spend frames at full resolution. These place the threads, hold the GPU clock steady, and render the world smaller when the GPU is the limit. The Low-end presets on the home page set them for you (4-core laptop, 120 km/h drive: 44 to 68 fps).",
          keys = { "corePlacement", "gpuPstate", "dynRes", "upscaler", "upscalerQuality" } },
        { title = "I play with other mods",
          cause = "A mod that patches the same game code can clash with an optimization.",
          why = "PZ Optimization scans the Java mods of each launch and can switch off what they patch. Max performance keeps everything on and reports clashes; Max compatibility switches the affected settings off. The main menu's compatibility check lists what it found.",
          keys = { "modProfile", "modCompat", "uiRetainedMods", "luaWorkerGate" } },
    },
}

-- Korean patch: localize display text without changing the English section-prefix identifiers used by layout matching.
local function pzoptLayoutTr(key, fallback)
    local result = getText(key)
    if result and result ~= key then return result end
    return fallback
end

local PZOPT_LAYOUT_TEXT_KEYS = {
    ["Performance"] = "UI_pzopt_layout_63c9045599",
    ["Smoother frames and faster loads. Nothing here changes how the game looks."] = "UI_pzopt_layout_42709e0997",
    ["Smoothness and pacing"] = "UI_pzopt_layout_3e8aeb5ffb",
    ["Even frame delivery, variable refresh and input latency."] = "UI_pzopt_layout_66e63a052c",
    ["Frame pacing"] = "UI_pzopt_layout_7d91989529",
    ["Variable refresh"] = "UI_pzopt_layout_da70093eb0",
    ["Input latency"] = "UI_pzopt_layout_514a05b433",
    ["Driving"] = "UI_pzopt_layout_5ff69e94e9",
    ["The car's stutter and rubber banding, and the world arriving at speed."] = "UI_pzopt_layout_c5d5030c62",
    ["Car smoothness"] = "UI_pzopt_layout_4d261cad90",
    ["Chunk streaming"] = "UI_pzopt_layout_3d649154c4",
    ["Render distance"] = "UI_pzopt_layout_27d4a46c20",
    ["Trees while driving"] = "UI_pzopt_layout_ab89fb2b37",
    ["World drawing"] = "UI_pzopt_layout_20932e789c",
    ["What the chunk pictures hold and how many are drawn in a frame."] = "UI_pzopt_layout_b6e1486958",
    ["What bakes"] = "UI_pzopt_layout_a565cdb312",
    ["Bake budgets"] = "UI_pzopt_layout_d017a477f4",
    ["Zoom"] = "UI_pzopt_layout_9b3cbed5c4",
    ["Blood and flies"] = "UI_pzopt_layout_c7ffe37ca3",
    ["Sprite buffers"] = "UI_pzopt_layout_a2b2adf084",
    ["Lighting, cutaways and weather"] = "UI_pzopt_layout_c8d4cab0fa",
    ["Light refreshes, see-through walls and roofs, fog, rain and puddles."] = "UI_pzopt_layout_6d553419c0",
    ["Lighting"] = "UI_pzopt_layout_6153deda35",
    ["Cutaways"] = "UI_pzopt_layout_1d39b20337",
    ["Fog"] = "UI_pzopt_layout_bae15ef895",
    ["Rain and puddles"] = "UI_pzopt_layout_f4e6a1503a",
    ["Zombies and hordes"] = "UI_pzopt_layout_582cf6a55f",
    ["The zombie simulation spread over every core, and cheaper checks."] = "UI_pzopt_layout_71fb35bc89",
    ["On other cores"] = "UI_pzopt_layout_24619dd0df",
    ["Cheaper checks"] = "UI_pzopt_layout_dd0695a0bd",
    ["Detail by distance"] = "UI_pzopt_layout_0095e502d0",
    ["Boot and loading"] = "UI_pzopt_layout_b0cb69a08c",
    ["From launch to the menu, and from Continue to the world."] = "UI_pzopt_layout_30ab777fb5",
    ["Loading screen"] = "UI_pzopt_layout_e6a2ee2b98",
    ["Boot"] = "UI_pzopt_layout_42b4d303e8",
    ["Files and textures"] = "UI_pzopt_layout_6fdfc6037b",
    ["Menus, inventory and map"] = "UI_pzopt_layout_053af68d25",
    ["Windows that answer in the frame you click."] = "UI_pzopt_layout_b6ae3f6de1",
    ["Windows"] = "UI_pzopt_layout_26d9c28d78",
    ["Map"] = "UI_pzopt_layout_ab478f3efc",
    ["Lua"] = "UI_pzopt_layout_b083207463",
    ["System, sound and mods"] = "UI_pzopt_layout_d313e45795",
    ["Cores and power, the audio mix, other mods, updates."] = "UI_pzopt_layout_e1d976958f",
    ["Cores and power"] = "UI_pzopt_layout_c924f55b8e",
    ["Sound"] = "UI_pzopt_layout_b4e3efeba1",
    ["Mods and multiplayer"] = "UI_pzopt_layout_41513a63d3",
    ["Updates"] = "UI_pzopt_layout_c76d18079a",
    ["Visuals"] = "UI_pzopt_layout_0f48a4ccae",
    ["Graphics the stock game does not have. Off by default; each card says what it costs."] = "UI_pzopt_layout_3472cc224d",
    ["Image quality"] = "UI_pzopt_layout_2e7dacb51a",
    ["Upscalers, dynamic resolution, sprite filtering and HDR output."] = "UI_pzopt_layout_a107f0fd59",
    ["Upscaling"] = "UI_pzopt_layout_754a68b525",
    ["Dynamic resolution"] = "UI_pzopt_layout_3ae705ce11",
    ["Sprite filtering"] = "UI_pzopt_layout_4c9edcd9b7",
    ["HDR output"] = "UI_pzopt_layout_ccb2cfa540",
    ["Lighting and shadows"] = "UI_pzopt_layout_ff2064c0b6",
    ["Per-pixel light, the real sky's shadows, ambient occlusion and god rays."] = "UI_pzopt_layout_0518e59abf",
    ["Per-pixel lighting"] = "UI_pzopt_layout_ab7d669deb",
    ["Sun, moon and clouds"] = "UI_pzopt_layout_b70e104195",
    ["Ambient occlusion"] = "UI_pzopt_layout_91abdb854b",
    ["God rays"] = "UI_pzopt_layout_320f047484",
    ["Reflections and glass"] = "UI_pzopt_layout_20947ea521",
    ["Water and puddles, mirrors and windows, car glass, wet blood."] = "UI_pzopt_layout_a4b972eb8c",
    ["Water and puddles"] = "UI_pzopt_layout_d9c6c230a8",
    ["Mirrors and windows"] = "UI_pzopt_layout_649ee9d713",
    ["Car glass"] = "UI_pzopt_layout_49d7aad889",
    ["Wet blood"] = "UI_pzopt_layout_554379be73",
    ["Atmosphere and detail"] = "UI_pzopt_layout_24812a0697",
    ["Darkness and colour grading, foliage sway, relief, zombie outlines."] = "UI_pzopt_layout_53783e672f",
    ["Darkness and grading"] = "UI_pzopt_layout_643493d024",
    ["Foliage sway"] = "UI_pzopt_layout_a0f9de034a",
    ["Relief"] = "UI_pzopt_layout_be53bb7449",
    ["Zombie outlines"] = "UI_pzopt_layout_d9dfe6e0f4",
    ["Tools"] = "UI_pzopt_layout_4fa8cc860c",
    ["The performance overlay (F9), its game-thread profiler and the console log."] = "UI_pzopt_layout_61158d5227",
    ["Performance overlay"] = "UI_pzopt_layout_215a0ced92",
    ["Frame times, utilization and what the game thread does, on screen."] = "UI_pzopt_layout_8d516b6576",
    ["Overlay"] = "UI_pzopt_layout_249450cb72",
    ["Fps colour"] = "UI_pzopt_layout_2ce15e7a86",
    ["Console log"] = "UI_pzopt_layout_c1b1faf238",
    ["Stutter while driving"] = "UI_pzopt_layout_7a22e6a73a",
    ["Chunks arrive faster than their pictures bake, and the car is drawn at its physics steps."] = "UI_pzopt_layout_4c0a5608c6",
    ["At 120 km/h about 50 new chunks a second reach the screen. Stock bakes each chunk's picture in the frame it arrives, and it draws the car and the camera at the last 100 Hz physics step, so the car rubber-bands against the street. These spread the bakes over frames, draw the car between its physics steps and keep trees in the bake. Rosewood town drive at the 240 cap: stock 153 fps (p99 36 ms), with these 235 fps (p99 8 ms)."] = "UI_pzopt_layout_4c7403f155",
    ["Low fps in a big horde"] = "UI_pzopt_layout_052198d44c",
    ["Stock runs the whole zombie simulation on the game thread."] = "UI_pzopt_layout_1387f37c70",
    ["Every zombie's animation, decisions and drawing preparation run one after the other on the game thread, while the other cores idle. These run them on every core and skip checks that cannot change anything. The Louisville horde (about 2,000 zombies), same build with these off and on: 46 to 58 fps."] = "UI_pzopt_layout_535b0669c9",
    ["Long boot and loading"] = "UI_pzopt_layout_a57db83145",
    ["Boot work runs one file at a time, and the loading screen waits for everything."] = "UI_pzopt_layout_2810eac84a",
    ["Stock parses scripts, animations and textures on one thread at boot and shows a loading screen until the whole cell is ready. These do the boot work on several threads with caches, and enter the world from the centre outwards with the last view on screen meanwhile. Launch to menu 7.4 to 5.0 s, Continue to the world 6.5 to 4.0 s."] = "UI_pzopt_layout_ddbd13fc6c",
    ["Storms, fog and rain are slow"] = "UI_pzopt_layout_d111ba4f5e",
    ["Stock redraws fog rows and every wet square each frame."] = "UI_pzopt_layout_74aa219f4f",
    ["Heavy fog is drawn as about 190 screen-wide rows per level, and rain re-packs every particle and puddle every frame. These draw fog in one pass, rain as repeated tiles and keep the puddles on the GPU. 120 km/h drive in heavy fog: 220 to 389 fps; thunderstorm: 83 to 131 fps."] = "UI_pzopt_layout_943b28f2e1",
    ["Input feels laggy"] = "UI_pzopt_layout_e6692ed249",
    ["Input is read early and finished frames queue up for the GPU."] = "UI_pzopt_layout_0c6fb5ba8f",
    ["Stock reads the keyboard and mouse well before the frame they move is shown, and lets the driver queue frames. These read the newest input when a frame starts, keep the queue short and draw the cursor at the newest mouse position."] = "UI_pzopt_layout_3230d6ea9b",
    ["Screen tears or judders"] = "UI_pzopt_layout_ae7fff31d0",
    ["Borderless never gets variable refresh, and frames reach the screen unevenly."] = "UI_pzopt_layout_34e4f8e27f",
    ["A borderless window does not count as fullscreen for the desktop, so G-SYNC / FreeSync stay off, and frames reach the screen as soon as they are ready. These make the window count as fullscreen, keep the frame rate inside the display's range and hand frames over at even steps (judder 3.1 to 0.95 ms)."] = "UI_pzopt_layout_19245da951",
    ["Menus and inventory are slow"] = "UI_pzopt_layout_568f844f87",
    ["Every window redraws every frame, with or without a change."] = "UI_pzopt_layout_147180e703",
    ["An open inventory took the Lua UI from 2 to 12 % of the game thread in stock. These redraw only what changed, the moment you act, and keep the map's labels while the view stays."] = "UI_pzopt_layout_211358f3fc",
    ["Laptop, Steam Deck or battery"] = "UI_pzopt_layout_927faa3527",
    ["The game's threads land on slow cores and the GPU clock goes up and down."] = "UI_pzopt_layout_5cb46b3851",
    ["On hybrid CPUs the game thread can end up on an efficient core; small GPUs spend frames at full resolution. These place the threads, hold the GPU clock steady, and render the world smaller when the GPU is the limit. The Low-end presets on the home page set them for you (4-core laptop, 120 km/h drive: 44 to 68 fps)."] = "UI_pzopt_layout_4af7d2732b",
    ["I play with other mods"] = "UI_pzopt_layout_d7fc90abae",
    ["A mod that patches the same game code can clash with an optimization."] = "UI_pzopt_layout_0f5123bd68",
    ["PZ Optimization scans the Java mods of each launch and can switch off what they patch. Max performance keeps everything on and reports clashes; Max compatibility switches the affected settings off. The main menu's compatibility check lists what it found."] = "UI_pzopt_layout_8d4e1fc447",
}

local function pzoptLayoutText(text)
    local key = PZOPT_LAYOUT_TEXT_KEYS[text]
    return key and pzoptLayoutTr(key, text) or text
end

for _, group in ipairs(PzoptSettingsLayout.groups or {}) do
    group.title = pzoptLayoutText(group.title)
    group.note = pzoptLayoutText(group.note)
    for _, cat in ipairs(group.cats or {}) do
        cat.title = pzoptLayoutText(cat.title)
        cat.blurb = pzoptLayoutText(cat.blurb)
        for _, sub in ipairs(cat.subs or {}) do
            sub.title = pzoptLayoutText(sub.title)
        end
    end
end

for _, problem in ipairs(PzoptSettingsLayout.problems or {}) do
    problem.title = pzoptLayoutText(problem.title)
    problem.cause = pzoptLayoutText(problem.cause)
    problem.why = pzoptLayoutText(problem.why)
end
