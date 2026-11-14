// Real native civilian loadouts, actor creation, FIA initialization and VIP join.
// An AI rescuer checks the server transaction; connected-player UI/locality is open.
private _savedCiv = missionNamespace getVariable ["A3A_faction_civ",createHashMap];
private _savedReb = missionNamespace getVariable ["A3A_faction_reb",createHashMap];
A3A_enabledDLC = []; loadoutsToGenerate = 1; A3A_hasACE = false;
private _civ = ["\x\a3a\addons\core\Templates\Templates\Vanilla\Vanilla_Civ.sqf",civilian]
    call A3A_fnc_compatibilityLoadFaction;
A3A_faction_reb = createHashMapFromArray [["unitSL","fixture_sl"],["unitSniper","fixture_sniper"],
    ["unitUnarmed","fixture_unarmed"],["faces",_civ get "faces"],["voices",_civ get "voices"]];
A3A_rebelSkillMul = 1; skillFIA = 1; allRifles = ["arifle_MX_F"];
distanceSPWN = 1000;
private _serial = 0;
private _newSurvivor = {
    _serial = _serial + 1;
    createHashMapFromArray [["name","A3I_test_liberation_" + str _serial],["town",_town]]
};
private _waitSurvivorCleanup = {
    params ["_record"];
    private _unit = _record getOrDefault ["vip",objNull];
    private _group = _record getOrDefault ["vipGroup",grpNull];
    private _result = [_record] call A3I_fnc_cleanupLiberationSurvivor;
    private _deadline = diag_tickTime + 8;
    waitUntil {sleep 0.05;(isNull _unit && {isNull _group}) || {diag_tickTime > _deadline}};
    _result # 0 && {isNull _unit} && {isNull _group}
};
["lib_survivor_native_roles_loaded",count (A3A_customUnitTypes getVariable [_civ get "unitVIP",[]]) == 4
    && {count (A3A_customUnitTypes getVariable [_civ get "unitMan",[]]) == 4}] call _check;
private _record = call _newSurvivor;
private _result = [_record] call A3I_fnc_createLiberationSurvivor;
private _vip = _record getOrDefault ["vip",objNull];
sleep 1;
["lib_survivor_real_human",_result # 0 && {alive _vip} && {side group _vip == civilian}
    && {_vip getVariable ["unitType",""] == _civ get "unitVIP"}
    && {isNil {_vip getVariable "WBK_AI_ISZombie"}},[_result,typeOf _vip,str side group _vip]] call _check;
["lib_survivor_native_equipment_and_revive",primaryWeapon _vip == "arifle_MX_F"
    && {handgunWeapon _vip != ""} && {!isNil {_vip getVariable "respawning"}}
    && {!captive _vip} && {isDamageAllowed _vip} && {_vip call A3A_fnc_canFight}
    && {!(_vip getVariable ["spawner",true])},[primaryWeapon _vip,handgunWeapon _vip]] call _check;
private _actors = entities "CAManBase";
_result = [_record] call A3I_fnc_createLiberationSurvivor;
["lib_survivor_creation_idempotent",_result # 0 && {_record get "vip" == _vip}
    && {entities "CAManBase" isEqualTo _actors}] call _check;
[_record] remoteExecCall ["A3I_fnc_cleanupLiberationSurvivor",2]; sleep 0.3;
["lib_survivor_remote_cleanup_refused",alive _vip && {!(_record getOrDefault ["survivorCleaned",false])}] call _check;
private _foreign = createHashMapFromArray [["name","foreign"],["vip",_vip],["vipGroup",group _vip]];
_result = [_foreign] call A3I_fnc_cleanupLiberationSurvivor;
["lib_survivor_foreign_record_refused",!(_result # 0) && {_result # 1 == "ownership"} && {alive _vip}] call _check;
["lib_survivor_cleanup_owned_actor",[_record] call _waitSurvivorCleanup] call _check;
["lib_survivor_cleanup_idempotent",([_record] call A3I_fnc_cleanupLiberationSurvivor) # 0
    && {!(([_record] call A3I_fnc_createLiberationSurvivor) # 0)}] call _check;

private _vipRole = _civ get "unitVIP";
_civ set ["unitVIP",A3A_faction_occ get "unitOfficial"];
_record = call _newSurvivor; _result = [_record] call A3I_fnc_createLiberationSurvivor;
_vip = _record getOrDefault ["vip",objNull];
["lib_survivor_fallback_stays_civilian",_result # 0 && {alive _vip}
    && {_vip getVariable ["unitType",""] == _civ get "unitMan"}
    && {!(typeOf _vip in (A3I_dependencies get "basicClasses"))}] call _check;
[_record] call _waitSurvivorCleanup;
_civ set ["unitVIP",_vipRole];

_record = call _newSurvivor;
_civ set ["attributeCivNonHuman",true];
_result = [_record] call A3I_fnc_createLiberationSurvivor;
["lib_survivor_nonhuman_template_refused",!(_result # 0) && {_result # 1 == "nonhuman_civilians"}
    && {!(_record getOrDefault ["survivorAttempted",false])}] call _check;
_civ set ["attributeCivNonHuman",false];
private _manRole = _civ get "unitMan"; private _workerRole = _civ get "unitWorker";
private _blockedRole = "loadouts_civ_infected_fixture";
A3A_customUnitTypes setVariable [_blockedRole,A3A_customUnitTypes getVariable (A3A_faction_occ get "unitOfficial")];
_civ set ["unitVIP",_blockedRole]; _civ set ["unitMan",""]; _civ set ["unitWorker",""];
_result = [_record] call A3I_fnc_createLiberationSurvivor;
["lib_survivor_infected_role_refused",!(_result # 0) && {_result # 1 == "human_role"}
    && {!(_record getOrDefault ["survivorAttempted",false])}] call _check;
// A special creature is not in the three basic-class dependency allowlist.
// The installed WBK faction must also disqualify a forged civilian role.
private _specialDefinition = +(A3A_customUnitTypes getVariable [_blockedRole,[]]);
_specialDefinition set [1,[["baseClass","WBK_SpecialZombie_Smasher_2"]]];
A3A_customUnitTypes setVariable [_blockedRole,_specialDefinition];
_result = [_record] call A3I_fnc_createLiberationSurvivor;
["lib_survivor_special_infected_role_refused",isClass (configFile >> "CfgVehicles" >> "WBK_SpecialZombie_Smasher_2")
    && {!(_result # 0)} && {_result # 1 == "human_role"}
    && {!(_record getOrDefault ["survivorAttempted",false])}] call _check;
A3A_customUnitTypes setVariable [_blockedRole,nil];
_civ set ["unitVIP",_vipRole]; _civ set ["unitMan",_manRole]; _civ set ["unitWorker",_workerRole];
private _hqPosition = getMarkerPos respawnTeamPlayer;
respawnTeamPlayer setMarkerPos getMarkerPos _town;
_result = [_record] call A3I_fnc_createLiberationSurvivor;
["lib_survivor_bad_placement_has_no_fallback",!(_result # 0) && {_result # 1 == "hq"}
    && {!(_record getOrDefault ["survivorAttempted",false])}] call _check;
respawnTeamPlayer setMarkerPos _hqPosition;
_result = [_record] call A3I_fnc_createLiberationSurvivor;
["lib_survivor_placement_retry",_result # 0 && {alive (_record getOrDefault ["vip",objNull])}] call _check;
// Recover an actor owned before initialization completed, without a ready flag.
_record set ["survivorReady",false];
["lib_survivor_partial_creation_cleanup",[_record] call _waitSurvivorCleanup] call _check;
_record = call _newSurvivor;
_actors = entities "CAManBase";
[_record] remoteExecCall ["A3I_fnc_createLiberationSurvivor",2]; sleep 0.3;
["lib_survivor_remote_create_refused",entities "CAManBase" isEqualTo _actors] call _check;
sidesX setVariable [_town,teamPlayer];
_result = [_record] call A3I_fnc_createLiberationSurvivor;
["lib_survivor_changed_owner_refused",!(_result # 0) && {_result # 1 == "town"}] call _check;
sidesX setVariable [_town,west]; A3I_dependencies set ["available",false];
["lib_survivor_inactive_refused",!(([_record] call A3I_fnc_createLiberationSurvivor) # 0)] call _check;
A3I_dependencies set ["available",true];

_result = [_record] call A3I_fnc_createLiberationSurvivor;
_vip = _record getOrDefault ["vip",objNull];
private _originalGroup = group _vip;
private _rescuerGroup = createGroup [teamPlayer,true];
private _rescuer = _rescuerGroup createUnit ["I_G_Soldier_F",getPosATL _vip vectorAdd [6,0,0],[],0,"NONE"];
private _companion = _rescuerGroup createUnit ["I_G_Soldier_F",getPosATL _vip vectorAdd [10,0,0],[],0,"NONE"];
private _civilGroup = createGroup [civilian,true];
private _civil = _civilGroup createUnit ["C_man_1",getPosATL _vip vectorAdd [8,0,0],[],0,"NONE"];
sleep 0.5;
[_vip,_civil] call A3A_fnc_liberateVIP;
["lib_survivor_native_civilian_recruit_refused",group _vip == _originalGroup] call _check;
[_vip,_rescuer] call A3A_fnc_liberateVIP;
private _deadline = diag_tickTime + 5;
waitUntil {sleep 0.05;group _vip == _rescuerGroup || {diag_tickTime > _deadline}};
["lib_survivor_native_recruit_joins",group _vip == _rescuerGroup && {side _vip == teamPlayer}
    && {_vip call A3A_fnc_canFight}] call _check;
_vip setVariable ["incapacitated",true];
["lib_survivor_native_incapacitation",!(_vip call A3A_fnc_canFight)] call _check;
_vip setVariable ["incapacitated",false];
private _cleaned = [_record] call _waitSurvivorCleanup;
["lib_survivor_cleanup_preserves_rescuer_group",_cleaned && {!isNull _rescuerGroup}
    && {alive _rescuer} && {alive _companion} && {units _rescuerGroup isEqualTo [_rescuer,_companion]}] call _check;
{deleteVehicle _x} forEach [_rescuer,_companion,_civil];
[[_rescuerGroup,_civilGroup]] call A3I_fnc_cleanupGroups;
_deadline = diag_tickTime + 8;
waitUntil {sleep 0.05;(isNull _rescuerGroup && {isNull _civilGroup} && {isNil "A3I_groupCleanupHandle"})
    || {diag_tickTime > _deadline}};
["lib_survivor_all_groups_retired",isNull _rescuerGroup && {isNull _civilGroup}
    && {isNil "A3I_groupCleanupHandle"}
    && {missionNamespace getVariable ["A3I_retiredGroups",[]] isEqualTo []}] call _check;

call compile preprocessFileLineNumbers "liberationHordeChecks.sqf";
call compile preprocessFileLineNumbers "liberationMissionChecks.sqf";
A3A_faction_civ = _savedCiv; A3A_faction_reb = _savedReb;
