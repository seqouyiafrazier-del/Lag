-- LaggerScript.lua
-- Makes other players lag/stutter while keeping local player smooth

local lagger = {}

-- Configuration
local LAG_INTENSITY = 0.3  -- Lower = more aggressive lag (0.1 = really stuttery)
local STIFF_NESS = 0.95    -- How "rock-like" the stiffness is (1.0 = max)
local UPDATE_INTERVAL = 0.05 -- How often to apply lag effects

-- Internal variables
local otherPlayers = {}
local lastUpdateTime = 0
local isLocalPlayer = false

-- Initialize the lagger
function lagger:Start()
    -- Find all players in the scene
    local players = FindObjectsOfType(GameObject.FindWithTag("Player") or {})
    
    for _, player in ipairs(players) do
        if player == self:GetComponent("Transform") then
            isLocalPlayer = true
        else
            table.insert(otherPlayers, player)
        end
    end
    
    self:GetComponent("Timer"):Start(UPDATE_INTERVAL, true)
end

-- Apply stiffness and lag effects
function lagger:Update()
    if isLocalPlayer then
        -- Local player stays smooth
        return
    end
    
    local currentTime = Time.time
    local deltaTime = currentTime - lastUpdateTime
    
    if deltaTime < UPDATE_INTERVAL then
        return
    end
    
    lastUpdateTime = currentTime
    
    -- Apply lag to each other player
    for _, player in ipairs(otherPlayers) do
        local transform = player.transform
        
        -- METHOD 1: Create stutter effect by freezing movement
        if math.random() > STIFF_NESS * 0.8 then
            -- Freeze the player in place briefly (stiff as rock)
            transform.position = transform.position
            transform.rotation = transform.rotation
        end
        
        -- METHOD 2: Add random position jitter (makes them look laggy)
        if math.random() > 0.7 then
            local jitter = Vector3(
                math.random(-0.1, 0.1) * LAG_INTENSITY,
                math.random(-0.1, 0.1) * LAG_INTENSITY * 0.5,
                math.random(-0.1, 0.1) * LAG_INTENSITY
            )
            transform.position = transform.position + jitter
        end
        
        -- METHOD 3: Delay their movement updates
        local rigidbody = player:GetComponent("Rigidbody")
        if rigidbody then
            -- Simulate network lag by slowing physics
            rigidbody.velocity = rigidbody.velocity * (1 - math.random() * LAG_INTENSITY)
            
            -- Freeze rigidbody briefly (stiff as rock)
            if math.random() > STIFF_NESS * 0.7 then
                rigidbody.velocity = Vector3.zero
                rigidbody.angularVelocity = Vector3.zero
            end
        end
        
        -- METHOD 4: Animation stutter
        local animator = player:GetComponent("Animator")
        if animator then
            -- Slow down their animations randomly
            animator.speed = math.max(0.1, 1 - math.random() * LAG_INTENSITY * 2)
        end
    end
    
    -- Debug visualization (optional)
    if math.random() > 0.95 then
        Debug.Log("Lag applied to " .. #otherPlayers .. " players")
    end
end

-- Optional: Create visual feedback for the lagger
function lagger:OnPlayerTriggered(otherPlayer)
    if otherPlayer.tag == "Player" and otherPlayer ~= self:GetComponent("Transform") then
        -- Add extra lag when they come near
        local extraStiffness = 0.9
        if math.random() > 0.5 then
            otherPlayer.transform.position = otherPlayer.transform.position
            Debug.Log("Extra stiffness applied to nearby player")
        end
    end
end

return lagger
