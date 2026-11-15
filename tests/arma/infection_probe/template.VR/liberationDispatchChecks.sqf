// Native political transaction and direct mission entry. The whole ten-minute
// resourcecheck loop and connected-player proximity remain separate acceptance.
A3I_test_liberationDelegation = [];
["lib_dispatch_endpoints_registered",
    getText (configFile >> "CfgFunctions" >> "A3A" >> "init" >> "resourcecheck" >> "file")
        == "\x\a3i\addons\core\overrides\fn_resourcecheck.sqf"
    && {getText (configFile >> "CfgFunctions" >> "A3A" >> "CREATE" >> "townBattle" >> "file")
        == "\x\a3i\addons\core\overrides\fn_townBattle.sqf"}] call _check;
[east,_town,"foreign_origin",14] call A3A_fnc_townBattle;
["lib_dispatch_other_side_delegates",A3I_test_liberationDelegation isEqualTo
    [["townBattle",[east,_town,"foreign_origin",14]]]] call _check;
private _factionId = A3A_faction_occ get "infectionTemplate";
A3A_faction_occ set ["infectionTemplate","ordinary"];
[] call A3A_fnc_resourcecheck;
[west,_town,"ordinary_origin"] call A3A_fnc_townBattle;
["lib_dispatch_inactive_delegates",["resourcecheck",[]] in A3I_test_liberationDelegation
    && {["townBattle",[west,_town,"ordinary_origin"]] in A3I_test_liberationDelegation}] call _check;
A3A_faction_occ set ["infectionTemplate",_factionId];
call _resetMission;
sidesX setVariable [_source,Invaders];
[_town] remoteExec ["A3I_fnc_requestLiberation",2]; sleep 0.3;
["lib_dispatch_remote_campaign_refused",sidesX getVariable _town == west
    && {A3A_tasksData isEqualTo []}] call _check;
private _result = [A3I_fnc_requestLiberation,[_town]] call CBA_fnc_directCall;
["lib_dispatch_unscheduled_campaign_refused",!(_result # 0) && {sidesX getVariable _town == west}] call _check;
private _townData = +(A3A_townData get _town);
A3A_townData set [_town,[100,0,80,10]];
_result = [_town] call A3I_fnc_requestLiberation;
["lib_dispatch_low_support_no_flip",!(_result # 0) && {sidesX getVariable _town == west}] call _check;
A3A_townData set [_town,["bad",0,20,80]];
_result = [_town] call A3I_fnc_requestLiberation;
["lib_dispatch_invalid_data_no_flip",!(_result # 0) && {sidesX getVariable _town == west}] call _check;
A3A_townData set [_town,_townData];
private _savedDestroyed = missionNamespace getVariable ["destroyedSites",[]];
destroyedSites = [_town];
_result = [_town] call A3I_fnc_requestLiberation;
["lib_dispatch_destroyed_town_no_flip",!(_result # 0) && {sidesX getVariable _town == west}] call _check;
destroyedSites = _savedDestroyed;
private _savedNav = NavGrid; NavGrid = nil;
_result = [_town] call A3I_fnc_requestLiberation;
["lib_dispatch_missing_navigation_no_flip",!(_result # 0) && {sidesX getVariable _town == west}] call _check;
NavGrid = _savedNav;
private _savedHQ = respawnTeamPlayer; respawnTeamPlayer = "missing_hq";
_result = [_town] call A3I_fnc_requestLiberation;
["lib_dispatch_missing_hq_no_flip",!(_result # 0) && {sidesX getVariable _town == west}] call _check;
respawnTeamPlayer = _savedHQ;
townSkirmishes = [_town];
_result = [_town] call A3I_fnc_requestLiberation;
["lib_dispatch_existing_claim_no_flip",!(_result # 0) && {sidesX getVariable _town == west}
    && {townSkirmishes isEqualTo [_town]}] call _check;
townSkirmishes = [];
bigAttackInProgress = true; A3I_majorGlobalOwner = "foreign";
_result = [_town] call A3I_fnc_requestLiberation;
["lib_dispatch_busy_attack_no_flip",!(_result # 0) && {sidesX getVariable _town == west}
    && {bigAttackInProgress} && {A3I_majorGlobalOwner == "foreign"}] call _check;
bigAttackInProgress = false; A3I_majorGlobalOwner = nil;
["foreign_dispatch_task","townBattle","CREATED"] call A3A_fnc_taskUpdate;
_result = [_town] call A3I_fnc_requestLiberation;
["lib_dispatch_existing_task_no_flip",!(_result # 0) && {sidesX getVariable _town == west}
    && {count A3A_tasksData == 1}] call _check;
["foreign_dispatch_task","townBattle",0] call A3A_fnc_taskDelete;
[{!("townBattle" in A3A_activeTasks)}] call _wait;
private _beforeActors = entities "CAManBase";
_result = [_town] call A3I_fnc_requestLiberation;
["lib_dispatch_missing_source_peaceful",_result isEqualTo [true,"peaceful"]
    && {sidesX getVariable _town == teamPlayer} && {garrison getVariable _town isEqualTo []}
    && {tierWar == 8} && {[-10,10,_town,false] in A3I_test_support}] call _check;
["lib_dispatch_peaceful_no_mission_rewards",server getVariable "hr" == 100
    && {server getVariable "resourcesFIA" == 0} && {A3A_tasksData isEqualTo []}
    && {count A3I_liberations == 0} && {entities "CAManBase" isEqualTo _beforeActors}
    && {!bigAttackInProgress} && {forcedSpawn isEqualTo []}] call _check;
private _supportCalls = +A3I_test_support;
_result = [_town] call A3I_fnc_requestLiberation;
["lib_dispatch_repeat_peaceful_refused",!(_result # 0)
    && {A3I_test_support isEqualTo _supportCalls} && {sidesX getVariable _town == teamPlayer}] call _check;
call _resetMission; sidesX setVariable [_source,Invaders];
[west,_town,"distant_origin"] call A3A_fnc_townBattle;
["lib_dispatch_direct_no_source_no_flip",sidesX getVariable _town == west
    && {count A3I_liberations == 0} && {A3A_tasksData isEqualTo []}] call _check;
call _resetMission;
[west,_town,"distant_origin"] call A3A_fnc_townBattle;
private _parents = values A3I_liberations;
private _mission = _parents param [0,createHashMap];
[{_mission getOrDefault ["taskRegistered",false]}] call _wait;
["lib_dispatch_direct_nearby_parent",count _parents == 1
    && {_mission get "source" == _source} && {_mission get "town" == _town}
    && {[_mission] call _taskState == "CREATED"}] call _check;
_mission set ["outcome","cancelled"]; [_mission] call _retireMission;
call _resetMission;
_result = [_town] call A3I_fnc_requestLiberation;
_parents = values A3I_liberations; _mission = _parents param [0,createHashMap];
[{_mission getOrDefault ["taskRegistered",false]}] call _wait;
["lib_dispatch_reachable_campaign_parent",_result isEqualTo [true,"started"]
    && {count _parents == 1} && {sidesX getVariable _town == west}
    && {[_mission] call _taskState == "CREATED"}] call _check;
_result = [_town] call A3I_fnc_requestLiberation;
["lib_dispatch_pending_no_flip",!(_result # 0) && {count A3I_liberations == 1}
    && {sidesX getVariable _town == west}] call _check;
_mission set ["outcome","cancelled"]; [_mission] call _retireMission;
