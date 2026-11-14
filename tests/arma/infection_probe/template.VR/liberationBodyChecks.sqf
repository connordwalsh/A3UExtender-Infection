// Real native civilian/Rebel loadouts, basic WBK corpses and blood objects.
// Rendering, looting/reanimation over long play and client locality are NOT_RUN.
private _bodySavedReb = A3A_faction_reb;
// Native initVarCommon detection used by the full Rebel-template loader.
A3A_hasACEMedical = isClass (configFile >> "CfgSounds" >> "ACE_heartbeat_fast_3");
A3A_hasTFAR = isClass (configFile >> "CfgPatches" >> "task_force_radio");
A3A_hasTFARBeta = isClass (configFile >> "CfgPatches" >> "tfar_static_radios");
if (A3A_hasTFARBeta) then {A3A_hasTFAR = false};
startWithLongRangeRadio = false;
A3A_faction_reb = ["\x\a3a\addons\core\Templates\Templates\Vanilla\Vanilla_Reb_FIA.sqf",teamPlayer]
    call A3A_fnc_compatibilityLoadFaction;
private _categories = call A3I_fnc_liberationBodyRoles;
private _allRoles = []; {_allRoles append _x} forEach _categories;
private _civilRole = _allRoles select {_x # 0 == "civ"};
private _rebelRole = _allRoles select {_x # 0 == "reb"};
private _infectedRole = _allRoles select {_x # 0 == "occ"};
["lib_body_native_role_categories",count _categories == 3 && {count _civilRole == 2}
    && {count _rebelRole == 7} && {count _infectedRole == 6},_categories apply {count _x}] call _check;
_civilRole = _civilRole param [0,[]]; _rebelRole = _rebelRole param [0,[]];
_infectedRole = _infectedRole param [0,[]];
private _record = call _newSurvivor;
private _position = getMarkerPos _town;
private _result = [_record,["invalid",0,0],_civilRole] call A3I_fnc_createLiberationBody;
["lib_body_invalid_position_refused",!(_result # 0) && {isNil {_record get "sceneBodyGroups"}}] call _check;
private _hqPosition = getMarkerPos respawnTeamPlayer;
respawnTeamPlayer setMarkerPos _position;
_result = [_record,_position,_civilRole] call A3I_fnc_createLiberationBody;
["lib_body_hq_refused",!(_result # 0) && {_result # 1 == "hq"}
    && {isNil {_record get "sceneBodyGroups"}}] call _check;
respawnTeamPlayer setMarkerPos _hqPosition;
_result = [_record,_position,["civ","unregistered","C_man_1"]] call A3I_fnc_createLiberationBody;
["lib_body_arbitrary_role_refused",!(_result # 0) && {_result # 1 == "role"}
    && {isNil {_record get "sceneBodyGroups"}}] call _check;

private _civilMan = A3A_faction_civ get "unitMan";
private _civilWorker = A3A_faction_civ get "unitWorker";
A3A_faction_civ set ["unitMan",["invalid"]]; A3A_faction_civ set ["unitWorker","missing"];
_categories = call A3I_fnc_liberationBodyRoles;
["lib_body_malformed_roles_filtered",(_categories findIf {(_x # 0 # 0) == "civ"}) == -1
    && {count _categories == 2}] call _check;
private _special = "loadouts_civ_scene_special_fixture";
private _definition = +(A3A_customUnitTypes getVariable [_civilMan,[]]);
_definition set [1,[["baseClass","WBK_SpecialZombie_Smasher_2",true]]];
A3A_customUnitTypes setVariable [_special,_definition];
A3A_faction_civ set ["unitMan",_special];
_categories = call A3I_fnc_liberationBodyRoles;
_result = [_record,_position,["civ",_special,"WBK_SpecialZombie_Smasher_2"]] call A3I_fnc_createLiberationBody;
["lib_body_special_creature_refused",(_categories findIf {(_x # 0 # 0) == "civ"}) == -1
    && {!(_result # 0)} && {_result # 1 == "role"}
    && {isNil {_record get "sceneBodyGroups"}}] call _check;
A3A_faction_civ set ["unitMan",_civilMan]; A3A_faction_civ set ["unitWorker",_civilWorker];
A3A_customUnitTypes setVariable [_special,nil];

A3I_test_sceneBodiesCreated = [];
private _createdHandler = addMissionEventHandler ["EntityCreated",{A3I_test_sceneBodiesCreated pushBack (_this # 0)}];
[_record,_position,_civilRole] remoteExecCall ["A3I_fnc_createLiberationBody",2]; sleep 0.3;
removeMissionEventHandler ["EntityCreated",_createdHandler];
["lib_body_remote_creation_refused",A3I_test_sceneBodiesCreated isEqualTo []
    && {isNil {_record get "sceneBodyGroups"}}] call _check;

private _beforeBudget = ["stats",[]] call A3I_fnc_budget;
private _beforeResources = [missionNamespace getVariable ["A3A_resourcesDefenceOcc",0],
    missionNamespace getVariable ["A3A_resourcesAttackOcc",0]];
_result = [_record,_position,_civilRole] call A3I_fnc_createLiberationBody;
private _bodies = _record getOrDefault ["sceneBodies",[]];
private _bloods = _record getOrDefault ["sceneBlood",[]];
private _groups = _record getOrDefault ["sceneBodyGroups",[]];
["lib_body_real_civilian_corpse",_result # 0 && {count _bodies == 1}
    && {!isNull (_bodies # 0)} && {!alive (_bodies # 0)}
    && {(_bodies # 0) getVariable ["unitType",""] == _civilRole # 1}
    && {count _groups == 1} && {side (_groups # 0) == civilian},_result] call _check;
["lib_body_real_blood_owned",count _bloods == 1 && {!isNull (_bloods # 0)}
    && {(_bloods # 0) getVariable ["A3I_sceneBodyId",""] == _record get "name"}
    && {(_bloods # 0) distance2D (_bodies # 0) < 1}] call _check;
_result = [_record,_position,_civilRole] call A3I_fnc_createLiberationBody;
["lib_body_occupied_position_refused",!(_result # 0) && {count _bodies == 1}
    && {count _groups == 1} && {count _bloods == 1},_result] call _check;
_result = [_record,_position vectorAdd [12,0,0],_rebelRole] call A3I_fnc_createLiberationBody;
// Native FIA scene roles are unarmed until FIAinit equips living fighters.
// Scene corpses use createUnit alone, so compare the actual supplied loadout.
private _rebelLoadout = (A3A_customUnitTypes getVariable (_rebelRole # 1)) # 0 # 0;
["lib_body_native_rebel_equipment",_result # 0 && {count _bodies == 2}
    && {!alive (_bodies # 1)} && {uniform (_bodies # 1) == _rebelLoadout # 3 # 0}
    && {primaryWeapon (_bodies # 1) == ((_rebelLoadout # 0) param [0,""])}
    && {"ItemMap" in assignedItems (_bodies # 1)}
    && {(_bodies # 1) getVariable ["unitType",""] == _rebelRole # 1}] call _check;
_result = [_record,_position vectorAdd [24,0,0],_infectedRole] call A3I_fnc_createLiberationBody;
sleep 3;
["lib_body_basic_infected_stays_dead",_result # 0 && {count _bodies == 3}
    && {!isNull (_bodies # 2)} && {!alive (_bodies # 2)}
    && {typeOf (_bodies # 2) in (A3I_dependencies get "basicClasses")}
    && {isNil {(_bodies # 2) getVariable "WBK_AI_ISZombie"}}
    && {isNil {(_bodies # 2) getVariable "A3I_budgetTicket"}},_result] call _check;
["lib_body_no_campaign_cost",(["stats",[]] call A3I_fnc_budget) isEqualTo _beforeBudget
    && {[missionNamespace getVariable ["A3A_resourcesDefenceOcc",0],
        missionNamespace getVariable ["A3A_resourcesAttackOcc",0]] isEqualTo _beforeResources}] call _check;
[_record] remoteExecCall ["A3I_fnc_cleanupLiberationBodies",2]; sleep 0.3;
["lib_body_remote_cleanup_refused",(_bodies findIf {isNull _x}) == -1
    && {!(_record getOrDefault ["sceneBodiesRetired",false])}] call _check;
private _foreign = createHashMapFromArray [["name","foreign"],["sceneBodies",_bodies],
    ["sceneBodyGroups",_groups],["sceneBlood",_bloods]];
_result = [_foreign] call A3I_fnc_cleanupLiberationBodies;
["lib_body_foreign_cleanup_refused",!(_result # 0) && {_result # 1 == "ownership"}
    && {(_bodies findIf {isNull _x}) == -1}] call _check;
private _ownedObjects = _bodies + _bloods;
private _ownedGroups = +_groups;
_result = [_record] call A3I_fnc_cleanupLiberationBodies;
private _deadline = diag_tickTime + 8;
waitUntil {sleep 0.05;((_ownedObjects findIf {!isNull _x}) == -1
    && {(_ownedGroups findIf {!isNull _x}) == -1}) || {diag_tickTime > _deadline}};
["lib_body_exact_cleanup",_result # 0 && {count _ownedObjects == 6} && {count _ownedGroups == 3}
    && {(_ownedObjects findIf {!isNull _x}) == -1} && {(_ownedGroups findIf {!isNull _x}) == -1}
    && {_record get "sceneBodies" isEqualTo []} && {_record get "sceneBlood" isEqualTo []}] call _check;
["lib_body_retirement_idempotent",([_record] call A3I_fnc_cleanupLiberationBodies) # 0
    && {!(([_record,_position,_civilRole] call A3I_fnc_createLiberationBody) # 0)}] call _check;
// Recover the registration boundary after group ownership, before a body exists.
_record = call _newSurvivor;
private _partialGroup = createGroup [civilian,false];
_partialGroup setVariable ["A3I_sceneBodyId",_record get "name"];
_record set ["sceneBodyGroups",[_partialGroup]];
_result = [_record] call A3I_fnc_cleanupLiberationBodies;
_deadline = diag_tickTime + 8;
waitUntil {sleep 0.05;isNull _partialGroup || {diag_tickTime > _deadline}};
["lib_body_partial_creation_cleanup",_result # 0 && {isNull _partialGroup}] call _check;
A3A_faction_reb = _bodySavedReb;
