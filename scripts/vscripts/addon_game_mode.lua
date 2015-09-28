--[[
Dota PvP game mode
]]
LOADED = false

startx = 1840
starty = -392
blocksize = 256
height = 352+64
BOARDSIZE = 8


print( "Dota PvP game mode loaded." )

TURN = DOTA_TEAM_GOODGUYS -- radiant gets first move (Radiant advantage icefrog nerf pls)

units = {}
units[DOTA_TEAM_GOODGUYS] = {}
units[DOTA_TEAM_BADGUYS] = {}


if Addon == nil then
	Addon = class({})
end

--------------------------------------------------------------------------------
-- ACTIVATE
--------------------------------------------------------------------------------
function Activate()
    GameRules.Addon = Addon()
    GameRules.Addon:InitGameMode()
end

function Precache( context )
    PrecacheResource("model_folder", "models/heroes/wraith_king", context) 
    PrecacheResource("model_folder", "models/heroes/queenofpain", context) 
    PrecacheResource("model_folder", "models/heroes/tiny_04", context) 
    PrecacheResource("model_folder", "models/heroes/meepo", context) 
    PrecacheResource("model_folder", "models/heroes/omniknight", context) 
    PrecacheResource("model_folder", "models/heroes/chaos_knight", context) 
    PrecacheResource("model_folder", "models/heroes/crystal_maiden", context) 
    PrecacheResource("model_folder", "models/heroes/rubick", context) 
    PrecacheResource("model_folder", "models/heroes/abaddon", context) 
    PrecacheResource("model_folder", "models/props_structures/", context) 
    --PrecacheResource("model_folder", "models/props_structures/", context) 
    --PrecacheResource("model_folder", "models/props_structures/", context) 
    --PrecacheResource("model_folder", "models/props_structures/", context) 
    --PrecacheResource("model_folder", "models/heroes/queenofpain", context) 
end

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------
function Addon:InitGameMode()
	local GameMode = GameRules:GetGameModeEntity()
	
	-- Init stats
	require('lib.statcollection')
	statcollection.addStats({
        modID = '096be9c142cb29c522f14f04e29ff681'
		})
	
	Addon:_initVars()

	-- Enable the standard Dota PvP game rules
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( true )
	GameRules:SetSameHeroSelectionEnabled( true )
    GameRules:SetGoldPerTick(0)
    GameRules:SetPostGameTime(10.0)
	
	-- Register Think
	GameMode:SetContextThink( "Addon:GameThink", function() return self:GameThink() end, 0.25 )
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(Addon, 'onPlayerLoad'), self)
    ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(Addon, 'onPreGame'), self)
    GameMode:SetCameraDistanceOverride( 1800.0 )
    

    Convars:RegisterCommand('spawn_dire_units', function(name)
        -- Check if the server ran it
        print("test_mode command entered")
        if Convars:GetInt('sv_cheats')~= 1 then
            print("sv_cheats 1 required")
            return 
        end
        print("Test units spawned")  
        GetAddon().DEBUG = true
        local client = Convars:GetCommandClient()
        local hero = client:GetAssignedHero() 
        local ply = hero:GetOwnerEntity() 
 
        team = DOTA_TEAM_BADGUYS

        PrintTable(hero)

        self.units[60] = Addon:CreateUnitByNameFixed('npc_dota_hero_skeleton_king', self.boardPos[60], false, ply, ply, team)
        self.units[59] = Addon:CreateUnitByNameFixed('npc_chess_queen', self.boardPos[59], false, ply, ply, team)
        self.units[56] = Addon:CreateUnitByNameFixed('npc_chess_castle', self.boardPos[56], false, ply, ply, team)
        self.units[63] = Addon:CreateUnitByNameFixed('npc_chess_castle', self.boardPos[63], false, ply, ply, team)
        self.units[62] = Addon:CreateUnitByNameFixed('npc_chess_knight', self.boardPos[62], false, ply, ply, team)
        self.units[57] = Addon:CreateUnitByNameFixed('npc_chess_knight', self.boardPos[57], false, ply, ply, team)
        self.units[58] = Addon:CreateUnitByNameFixed('npc_chess_bishop', self.boardPos[58], false, ply, ply, team)
        self.units[61] = Addon:CreateUnitByNameFixed('npc_chess_bishop', self.boardPos[61], false, ply, ply, team)

        self.units[55] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[55], false, ply, ply, team)
        self.units[54] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[54], false, ply, ply, team)
        self.units[53] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[53], false, ply, ply, team)
        self.units[52] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[52], false, ply, ply, team)
        self.units[51] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[51], false, ply, ply, team)
        self.units[50] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[50], false, ply, ply, team)
        self.units[49] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[49], false, ply, ply, team)
        self.units[48] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[48], false, ply, ply, team)

        GetAddon().DEBUG = true

        for i=63-15, 63 do
            if self.units[i] ~= nil then
                self.units[i]:SetAngles(0, -90, 0)
                table.insert(units[DOTA_TEAM_BADGUYS], self.units[i])
            end
        end
    end, 'Spawn test units for dire.', 0)
end

function Addon:onPreGame(keys)
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
        GameRules:SendCustomMessage("<font color='#00FF00'>Radiant\'s</font> turn to move", 0, 0)
    end
end

function Addon:_initVars()
    self.DEBUG = false

    -- Create a mapping from board position 0-63 to map co-ords
    self.units = {}
    self.boardPos = {}
    for y=0, 7 do
        posy = starty+y*blocksize
        for x=0,7 do
            posx = startx+x*blocksize
            self.boardPos[8*y+x] = Vector(posx, posy, height)
        end
    end

end

function GetAddon()
    return GameRules.Addon
end

--------------------------------------------------------------------------------
function Addon:GameThink()
    if GameRules:State_Get() <=  DOTA_GAMERULES_STATE_HERO_SELECTION then
        return 0.25
    end
    for k,v in pairs(self.units) do
        if v ~= nil then
            if v:GetOrigin() ~= self.boardPos[k] then
                v:MoveToPosition(self.boardPos[k]) 
            end
            --[[if v:GetTeam()==DOTA_TEAM_GOODGUYS then
                v:SetAngles(0, 90, 0)
            else 
                v:SetAngles(0, -90, 0)
            end]]
            v:SetOrigin(self.boardPos[k]) 
        end
    end
	return 0.25
end

-- Wrapper to fix valve breaking being able to pass unit owners directly T_T
function  Addon:CreateUnitByNameFixed( unit, pos, UNUSED1, ply, UNUSED2, team)
	print("---- Creating Unit ----")
    local unit = CreateUnitByName(unit, pos, false, ply, ply, team)
	PrintTable( unit )
	PrintTable( ply )
	unit.vOwner =  ply
	if pli ~= nil then
		unit:SetControllableByPlayer( ply:GetPlayerID(), true )
	end
	return unit
end

function Addon:onPlayerLoad(keys)
    print("Function: onPlayerLoad")
	PrintTable(keys)
    local hero = EntIndexToHScript(keys.heroindex) --[[Returns:handle
    Turn an entity index integer to an HScript representing that entity's script instance.
    ]]
    local ply = hero:GetOwnerEntity() 
    print(ply)
    local playerID = ply:GetPlayerID()
    PlayerResource:SetGold(playerID, 0, false)

    --if playerID == -1 then
     --   ply:SetTeam(DOTA_TEAM_GOODGUYS)
    --  print("AUTO ASSIGN TO RADIANT"
    --end
    --local hero = CreateHeroForPlayer('npc_dota_hero_skeleton_king', ply)
	print("Upgrading Skeleton King move ability")
    hero:UpgradeAbility(hero:GetAbilityByIndex(0))

    local team = nil
	print("Spawning Radiant Units")
    if ply:GetTeam()==DOTA_TEAM_GOODGUYS then
        team = DOTA_TEAM_GOODGUYS
        self.units[4] = hero
		print("Creating Radiant Queen")
        self.units[3] = Addon:CreateUnitByNameFixed('npc_chess_queen', self.boardPos[3], false, ply, ply, team)
        print("----")
        local cur = self.units[3]
        while cur ~= nil do
        cur = cur:NextMovePeer()
        if cur ~= nil and cur:GetClassname() ~= "" and cur:GetClassname() == "dota_item_wearable" then
        print(cur:GetClassname())  -- also can use cur:GetName()
      --table.insert(wearables, cur)
        end
        end
        print("----")
        self.units[0] = Addon:CreateUnitByNameFixed('npc_chess_castle', self.boardPos[0], false, ply, ply, team)
        self.units[7] = Addon:CreateUnitByNameFixed('npc_chess_castle', self.boardPos[7], false, ply, ply, team)
        self.units[1] = Addon:CreateUnitByNameFixed('npc_chess_knight', self.boardPos[1], false, ply, ply, team)
        self.units[6] = Addon:CreateUnitByNameFixed('npc_chess_knight', self.boardPos[6], false, ply, ply, team)
        self.units[2] = Addon:CreateUnitByNameFixed('npc_chess_bishop', self.boardPos[2], false, ply, ply, team)
        self.units[5] = Addon:CreateUnitByNameFixed('npc_chess_bishop', self.boardPos[5], false, ply, ply, team)

        -- Pawns
        self.units[8] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[8], false, ply, ply, team)
        self.units[9] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[9], false, ply, ply, team)
        self.units[10] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[10], false, ply, ply, team)
        self.units[11] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[11], false, ply, ply, team)
        self.units[12] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[12], false, ply, ply, team)
        self.units[13] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[13], false, ply, ply, team)
        self.units[14] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[14], false, ply, ply, team)
        self.units[15] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[15], false, ply, ply, team)

        for i=0, 15 do
            if self.units[i] ~= nil and self.units[i] ~= hero then
                self.units[i]:SetControllableByPlayer(hero:GetPlayerOwnerID(), true)
                self.units[i]:SetAngles(0, 90, 0)
                table.insert(units[DOTA_TEAM_GOODGUYS], self.units[i])
            end
        end
    end
	print("Done spawning radiant units")

	print("Spawning Dire Units")
    if ply:GetTeam() == DOTA_TEAM_BADGUYS or self.DEBUG then
        team = DOTA_TEAM_BADGUYS
        self.units[60] = hero
        self.units[59] = Addon:CreateUnitByNameFixed('npc_chess_queen', self.boardPos[59], false, ply, ply, team)
        self.units[56] = Addon:CreateUnitByNameFixed('npc_chess_castle', self.boardPos[56], false, ply, ply, team)
        self.units[63] = Addon:CreateUnitByNameFixed('npc_chess_castle', self.boardPos[63], false, ply, ply, team)
        self.units[62] = Addon:CreateUnitByNameFixed('npc_chess_knight', self.boardPos[62], false, ply, ply, team)
        self.units[57] = Addon:CreateUnitByNameFixed('npc_chess_knight', self.boardPos[57], false, ply, ply, team)
        self.units[58] = Addon:CreateUnitByNameFixed('npc_chess_bishop', self.boardPos[58], false, ply, ply, team)
        self.units[61] = Addon:CreateUnitByNameFixed('npc_chess_bishop', self.boardPos[61], false, ply, ply, team)

        self.units[55] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[55], false, ply, ply, team)
        self.units[54] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[54], false, ply, ply, team)
        self.units[53] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[53], false, ply, ply, team)
        self.units[52] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[52], false, ply, ply, team)
        self.units[51] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[51], false, ply, ply, team)
        self.units[50] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[50], false, ply, ply, team)
        self.units[49] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[49], false, ply, ply, team)
        self.units[48] = Addon:CreateUnitByNameFixed('npc_chess_pawn', self.boardPos[48], false, ply, ply, team)

        for i=63-15, 63 do
            if self.units[i] ~= nil and self.units[i] ~= hero then
                self.units[i]:SetControllableByPlayer(hero:GetPlayerOwnerID(), true)
                self.units[i]:SetAngles(0, -90, 0)
                table.insert(units[DOTA_TEAM_BADGUYS], self.units[i])
            end
        end
    end
	print("Done spawning dire units")

    if self.DEBUG then
        team = DOTA_TEAM_BADGUYS
        self.units[60] = Addon:CreateUnitByNameFixed('npc_dota_hero_skeleton_king', self.boardPos[60], false, nil, nil, team)
    end
    LOADED = true
end

function toboardPos(x, y)
    local xpart = 0
    local ypart = 0
    for i=0, 7 do
        if math.abs(x-(startx+blocksize*i))<=blocksize/2 then
            xpart = i
        end
    end
    for i=0, 7 do
        if math.abs(y-(starty+blocksize*i))<=blocksize/2 then
            ypart = i
        end
    end
    return ypart*8+xpart
end

function relToBoardPos(relX, relY)
    return 8*relY + relX
end

function BoardPosToVect(b)
    return Vector(b%8, math.floor(b/8))
end

function isValidMove(boardPos, x2, y2, UnitName, team)
    -- Board pos is map co-ordinates
    -- x,y are board co-ordinates
    if x2 < startx-blocksize/2 or x2 > startx+7*blocksize+blocksize/2 or y2 < starty-blocksize/2 or y2 > starty+7*blocksize + blocksize/2 then
        return false
    end
	
	-- TODO: Make this not so WTF is going on
	
    -- check if there is a unit in the path
    boardPos2 = toboardPos(x2, y2)
    local absDiff = math.abs(boardPos2-boardPos)

    local pos =  BoardPosToVect(boardPos)
    x2 =    BoardPosToVect(boardPos2).x -- too lazy to fix all the x2 and stuff bellow to vect.x, vect.y
    y2 =    BoardPosToVect(boardPos2).y

    -- these are very hacky :(
    if UnitName=='npc_dota_hero_skeleton_king' then
        if false==(absDiff == 8  or absDiff == 9 or
            ((boardPos2 == boardPos+7 or boardPos2 == boardPos-1) and boardPos%8 ~= 0) or 
            ((boardPos2 == boardPos-7 or boardPos2 == boardPos+1) and boardPos%8 ~= 7)) then
            
            return false
        end

    end

    print(pos)
    print(x2.." "..y2)

    if UnitName == 'npc_chess_pawn' then
        -- jump left/right to attack
        if ((x2 == pos.x + 1 and y2 == pos.y + 1) or (x2 == pos.x -1 and y2 == pos.y + 1)) and not (team==DOTA_TEAM_GOODGUYS  and GetAddon().units[relToBoardPos(x2, y2)] ~= nil) then
            print(1)
            return false
        end
        if ((x2 == pos.x + 1 and y2 == pos.y - 1) or (x2 == pos.x -1 and y2 == pos.y - 1)) and not (team==DOTA_TEAM_BADGUYS  and GetAddon().units[relToBoardPos(x2, y2)] ~= nil) then
            print(2)
            return false
        end

        -- 1 move up/down
        if ((x2 == pos.x and y2 == pos.y+1)) and not (team==DOTA_TEAM_GOODGUYS and GetAddon().units[relToBoardPos(x2, y2)] == nil) then
            print(3)
            return false
        end
        if ((x2 == pos.x and y2 == pos.y - 1)) and  not (team==DOTA_TEAM_BADGUYS and GetAddon().units[relToBoardPos(x2, y2)] == nil) then
            print(4)
            return false
        end
        if (x2 == pos.x and y2 == pos.y - 2 and  team==DOTA_TEAM_BADGUYS and (GetAddon().units[relToBoardPos(x2, y2+1)] ~= nil or GetAddon().units[relToBoardPos(x2, y2)] ~= nil or  48 > boardPos or boardPos > 55)) then
            print(5)
            return false
        end
        if  (x2 == pos.x and y2 == pos.y + 2 and  team==DOTA_TEAM_GOODGUYS and (GetAddon().units[relToBoardPos(x2, y2-1)] ~= nil or GetAddon().units[relToBoardPos(x2, y2)] ~= nil or  8 > boardPos or boardPos > 15)) then
            print(6)
            return false
        end
        if  (team==DOTA_TEAM_GOODGUYS and not ((x2 == pos.x and y2 == pos.y + 2) or (x2 == pos.x and y2 == pos.y+1) or (x2 == pos.x + 1 and y2 == pos.y + 1) or (x2 == pos.x -1 and y2 == pos.y + 1))) then
            return false
        end
        if  (team==DOTA_TEAM_BADGUYS and not ((x2 == pos.x and y2 == pos.y - 2) or (x2 == pos.x and y2 == pos.y-1) or (x2 == pos.x + 1 and y2 == pos.y - 1) or (x2 == pos.x -1 and y2 == pos.y - 1))) then
            return false
        end
    end


    if UnitName == 'npc_chess_castle' then
        if (pos.x ~= x2 and pos.y ~= y2) then 
            return false
        end
        if pos.y == y2 then
            for i=math.min(pos.x, x2)+1, math.max(pos.x, x2)-1 do
                
                if i ~= pos.x and GetAddon().units[relToBoardPos(i, pos.y)] ~= nil then
                    return false
                end
            end
        end
        if pos.x == x2 then
            for i=math.min(pos.y, y2)+1, math.max(pos.y, y2)-1 do
                if i ~= pos.y and GetAddon().units[relToBoardPos(pos.x, i)] ~= nil then
                    return false
                end
            end
        end
    end

    if UnitName == 'npc_chess_bishop' then
        if (pos.x == x2 or pos.y == y2) then
            return false
        end
        if (math.abs(pos.x-x2) ~= math.abs(pos.y-y2)) then
            return false
        end
        -- Check collision
        local dx = x2-pos.x
        local dy = y2-pos.y

        for i=1, math.abs(dx)-1 do

            if (dx > 0 and dy > 0) and GetAddon().units[relToBoardPos(pos.x+i, pos.y+i)] ~= nil then
                return false
            end
            if (dx < 0 and dy > 0) and GetAddon().units[relToBoardPos(pos.x-i, pos.y+i)] ~= nil then
                return false
            end
            if (dx < 0 and dy < 0) and GetAddon().units[relToBoardPos(pos.x-i, pos.y-i)] ~= nil then
                return false
            end
            if (dx > 0 and dy < 0) and GetAddon().units[relToBoardPos(pos.x+i, pos.y-i)] ~= nil then
                return false
            end
        end
    end

    if UnitName == 'npc_chess_knight' then
        print(pos.x-x2.."--"..pos.y-y2)
        if (math.abs(pos.x-x2) == 2 and math.abs(pos.y-y2) == 1 or math.abs(pos.x-x2) ==1 and math.abs(pos.y-y2) ==2)==false then
            return false
        end
    end

    if UnitName == 'npc_chess_queen' then
        local dx = x2-pos.x
        local dy = y2-pos.y
        if (math.abs(pos.x-x2) ~= math.abs(pos.y-y2) and (pos.x ~= x2 and pos.y ~= y2)) then
            return false
        end
		
		-- Collision detect
        for i=1, math.abs(dx)-1 do

            if (dx > 0 and dy > 0) and GetAddon().units[relToBoardPos(pos.x+i, pos.y+i)] ~= nil then
                return false
            end
            if (dx < 0 and dy > 0) and GetAddon().units[relToBoardPos(pos.x-i, pos.y+i)] ~= nil then
                return false
            end
            if (dx < 0 and dy < 0) and GetAddon().units[relToBoardPos(pos.x-i, pos.y-i)] ~= nil then
                return false
            end
            if (dx > 0 and dy < 0) and GetAddon().units[relToBoardPos(pos.x+i, pos.y-i)] ~= nil then
                return false
            end
        end
        if pos.y == y2 then
            for i=math.min(pos.x, x2)+1, math.max(pos.x, x2)-1 do
                
                if i ~= pos.x and GetAddon().units[relToBoardPos(i, pos.y)] ~= nil then
                    return false
                end
            end
        end
        if pos.x == x2 then
            for i=math.min(pos.y, y2)+1, math.max(pos.y, y2)-1 do
                if i ~= pos.y and GetAddon().units[relToBoardPos(pos.x, i)] ~= nil then
                    return false
                end
            end
        end
    end

    if pos.x == x2 and pos.y == y2 then
        return false
    end 

    if GetAddon().units[boardPos2] ~= nil and GetAddon().units[boardPos2]:GetTeam() == team then
        return false
    end

    return true 
end

function isInCheck( team )
	-- Get the king's position
    local king = getKing(team)
    local enemyTeam = nil
    if team == DOTA_TEAM_GOODGUYS then
        enemyTeam = DOTA_TEAM_BADGUYS
    else
        enemyTeam = DOTA_TEAM_GOODGUYS
    end

    local enemyUnits = units[enemyTeam]
    while i <= #t
        if 
    end
		
end

function  isCheckMated( team )
    
end

function removeObjectFromArray( t, object )
    table.remove(t, indexOfObject(t, object))
end

function indexOfObject( t, object )
    local i = 1
    local size = #t
    while i <= size
        if table[i] == object then
            return i
        end
        i = i + 1 
    end
    return -1
end

function getKing( team )
    local table = units[team]
    local i = 1
    local size = #t
    while i <= size
        if table[i]:GetUnitName == 'npc_dota_hero_skeleton_king' then
            return table[i]
        end
        i = i + 1 
    end
end


function MoveTo( keys )
    print("Function: MoveTo")
    local ply = keys.caster:GetOwnerEntity() 

    local team = ply:GetTeam()
    if TURN ~= team and GetAddon().DEBUG == false then
        Say(ply, "It's not my turn yet!", false)
        return
    end

    local v0 = keys.attacker:GetOrigin()
    local v = keys.target_points[1]
    if isValidMove(toboardPos(v0.x, v0.y), v.x, v.y,  keys.attacker:GetUnitName(),  ply:GetTeam()) then
        
		-- Check if attacking
        print(GetAddon().units[toboardPos(v.x, v.y)]==nil)
        if GetAddon().units[toboardPos(v.x, v.y)] ~= nil then
		
			
            local enemy = GetAddon().units[toboardPos(v.x, v.y)]
            local enemyTeam = enemy:GetTeam()
            enemy:Kill(keys.attacker:GetAbilityByIndex(0), keys.attacker)
            removeObjectFromArray(units[team], enemyTeam)

			-- Win condition
            if enemy:GetUnitName() == 'npc_dota_hero_skeleton_king' then
                GameRules:SetGameWinner(keys.attacker:GetTeam())
                GameRules:SetPostGameTime(0.0)
                GameRules:Defeated()
            end
        end
        GetAddon().units[toboardPos(v.x, v.y)] = keys.attacker
        GetAddon().units[toboardPos(v0.x, v0.y)] = nil
        keys.attacker:SetOrigin(GetAddon().boardPos[toboardPos(v.x, v.y)])

    else 
        return
    end



    local point = keys.target_points
    if TURN == DOTA_TEAM_BADGUYS then
        TURN = DOTA_TEAM_GOODGUYS
        GameRules:SendCustomMessage("<font color='#00FF00'>Radiant\'s</font> turn to move", 0, 0)

    else
        TURN = DOTA_TEAM_BADGUYS
        GameRules:SendCustomMessage("<font color='#FF0000'>Dire\'s</font> turn to move", 0, 0)
    end
end

function  upgrade( keys )
    PrintTable(keys)
end

function PrintTable(t, indent, done)
    --print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..":")
                PrintTable (value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done [value] = true
                print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
                else
                    print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
                end
            end
        end
    end
end