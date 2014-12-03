-- ################################################################################?###################### --
-- #                                                                                                     # --
-- #                                             Sida's Katarina                                         # --
-- #                                                                                                     # --
-- ################################################################################?###################### --
require "Utils"

KatConfig = scriptConfig("Sida's Katarina", "sidaskat")
KatConfig:addParam("active", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
KatConfig:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
KatConfig:addParam("wardJump", "Ward Jump", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
KatConfig:addParam("steal", "Kill Steal", SCRIPT_PARAM_ONOFF, false)
KatConfig:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
KatConfig:addParam("harassMode", "Harass Mode", SCRIPT_PARAM_DOMAINUPDOWN, 2, string.byte("T"), {"Q","Q+W","Q+W+E"})
KatConfig:addParam("useItems", "Use Items", SCRIPT_PARAM_ONOFF, true)
KatConfig:addParam("drawCircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
KatConfig:addParam("autoAttack", "Auto Attack After Combo", SCRIPT_PARAM_ONOFF, true)
KatConfig:permaShow("active")
KatConfig:permaShow("harass")
KatConfig:permaShow("harassMode")


local lastQ = 0
local lastQHit = 0
local lastRDagger = 0
local spinning = false
local target
local lastHotkey = 3
local lastWard = 0

function Run()
	Util__OnTick()
    target = GetWeakEnemy('MAGIC',730)
	
    if GetTickCount() > lastRDagger + 250 then spinning = false end
    if KatConfig.steal and target ~= nil then killSteal() end
    if KatConfig.active then
        if target ~= nil then
		if KatConfig.useItems then UseAllItems(target) end
            if not spinning then
                if GetDistance(target) < 675 then
                    castQ(target) 
                end
                if GetDistance(target) < 375 then
                    castW(target)
                end
                if GetDistance(target) < 700 then
                    castE(target) 
                end
                if GetDistance(target) < 275 then
                    castR(target) 
                end
            end
        end
        if not spinning then
			if target == nil and KatConfig.movement then
				MoveToMouse()
			elseif target ~= nil then
				if KatConfig.autoAttack then
					AttackTarget(target)
				elseif KatConfig.movement then
					MoveToMouse()
				end
			end
        end
    end 
	
	if KatConfig.harass then
		if KatConfig.movement then
			MoveToMouse()
		end
		if target ~= nil then
			if GetDistance(target) < 675 then
				castQ(target) 
			end
			if KatConfig.harassMode > 1 and GetDistance(target) < 375 then
				castW(target)
			end
			if KatConfig.harassMode > 2 and GetDistance(target) < 700 then
				castE(target) 
			end
		end
	end
	
	if KatConfig.wardJump then
		if CanCastSpell("E") and GetDistance(mousePos) <= 600 and GetInventorySlot(2044) ~= nil and GetTickCount() - lastWard > 3000 then
			UseItemLocation(2044, mousePos.x, mousePos.y, mousePos.z)
			lastWard = GetTickCount()
		end
	end
end

function castQ(target)
    if CanCastSpell("Q") then
        CastSpellTarget("Q",target)
        lastQ = GetTickCount()
    end
end

function castW(target)
    if CanCastSpell("W") then
		CastSpellTarget("W",target)
    end
end

function castE(target)
    if CanCastSpell("E") then
        CastSpellTarget("E",target)
    end
end

function castR(target)    
    if IsSpellReady("R") == 1 then
        if not CanCastSpell("Q") and not CanCastSpell("W") and not CanCastSpell("E") then
            CastSpellTarget("R", target)
            spinning = true
        end
    end
end

function killSteal()
    if lastHotkey == 3 then 
        CastHotkey("SPELLE:WEAKENEMY ONESPELLHIT=#((spellq_ready)*(((spellq_level*30)+30+((player_ap*45)/100))-1)+(spelle_ready)*(((spelle_level*25)+15+((player_ap*4)/10))-1)+(spellw_ready)*(((spellw_level*35)+5+((player_ap*25)/100)+((player_ad*6)/10))-1)+(spell4_ready)*(((target_hpmax*15)/100)-1)+(spell3_ready)*(300+((player_ap*4)/10))) RANGE=700 NOSHOW")
        lastHotkey = 1
        return
    elseif lastHotkey == 1 then
        CastHotkey("SPELLW:WEAKENEMY ONESPELLHIT=#((spellq_ready)*(((spellq_level*30)+30+((player_ap*45)/100))-1)+(spelle_ready)*(((spelle_level*25)+15+((player_ap*4)/10))-1)+(spellw_ready)*(((spellw_level*35)+5+((player_ap*25)/100)+((player_ad*6)/10))-1)+(spell4_ready)*(((target_hpmax*15)/100)-1)+(spell3_ready)*(300+((player_ap*4)/10))) RANGE=375 NOSHOW")
        lastHotkey = 2
        return
    elseif lastHotkey == 2 then
        CastHotkey("SPELLQ:WEAKENEMY ONESPELLHIT=#((spellq_ready)*(((spellq_level*30)+30+((player_ap*45)/100))-1)+(spelle_ready)*(((spelle_level*25)+15+((player_ap*4)/10))-1)+(spellw_ready)*(((spellw_level*35)+5+((player_ap*25)/100)+((player_ad*6)/10))-1)+(spell4_ready)*(((target_hpmax*15)/100)-1)+(spell3_ready)*(300+((player_ap*4)/10))) RANGE=675 NOSHOW")
        lastHotkey = 3
        return
    end
end

function OnCreateObj(obj)
	if obj ~= nil then
		if string.find(obj.charName,"katarina_daggered") ~= nil then
			lastQHit = GetTickCount()
		elseif (string.find(obj.charName,"katarina_deathLotus_mis.troy") ~= nil) then
			spinning = true
			lastRDagger = GetTickCount()
		end
		if GetTickCount() - lastWard < 3000 and string.find(obj.name, "Ward") ~= nil 
		and GetDistance(obj, mousePos) < 1000 then
			CastSpellTarget("E", obj)
			printtext(obj.name.."LOL\n")
		end
	end
end

function OnDraw()
    if KatConfig.drawCircles then
		CustomCircle(700,4,3,myHero)
		if target ~= nil then
			CustomCircle(100,4,1,target)
		end
		for i = 1, objManager:GetMaxHeroes()  do
			local enemy = objManager:GetHero(i)
			if (enemy ~= nil and enemy.team ~= myHero.team and enemy.visible == 1 and enemy.invulnerable==0) then
				local qdmg = CanUseSpell("Q")*(30*GetSpellLevel("Q")+30+.45*myHero.ap)
				local wdmg = CanUseSpell("W")*(35*GetSpellLevel("W")+5+.25*myHero.ap+.6)
				local edmg = CanUseSpell("E")*(25*GetSpellLevel("E")+35+.4*myHero.ap)
				if enemy.health < (qdmg+wdmg+edmg) then    
					CustomCircle(100,4,2,enemy)
					DrawTextObject("Murder Him!!!", enemy, Color.Red)					
				end
			end
		end
	end
end

SetTimerCallback("Run")
printtext("\nSida's Katarina")