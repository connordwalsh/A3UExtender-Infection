// Uses the setup/cleanup helpers in majorLifecycleChecks. Native zone counting
// and capture decision run; the final ownership transaction remains recorded.
private _launch = {
    params [["_delay",300],["_strength",1],["_target",_town]];
    call _reset;
    private _request = [_target,_source,_strength,_delay] call A3I_fnc_startMajorAttack;
    if !(_request # 0) exitWith {
        diag_log format ["[INFECTION_MAJOR_FIXTURE] launch refused: %1",_request]; createHashMap
    };
    private _record = A3I_majorAttacks get A3I_majorGlobalOwner;
    [{_record get "taskRegistered"}] call _wait;
    _record
};
_job = [] call _launch;
if (count _job == 0) exitWith {};
sidesX setVariable [_source,east]; [_job] call _waitJob;
["major_source_loss_cancels",_job get "outcome" == "cancelled" && {A3A_resourcesAttackOcc == 1}
    && {!(_job getOrDefault ["rewarded",false])}] call _check;
_job = [] call _launch;
if (count _job == 0) exitWith {};
sidesX setVariable [_town,east]; [_job] call _waitJob;
["major_third_party_target_cancels",_job get "outcome" == "cancelled" && {A3A_resourcesAttackOcc == 1}] call _check;
_job = [] call _launch;
if (count _job == 0) exitWith {};
A3A_faction_occ set ["infectionTemplate",""]; [_job] call _waitJob;
["major_faction_loss_cancels",_job get "outcome" == "cancelled" && {A3A_resourcesAttackOcc == 1}] call _check;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
_job = [] call _launch;
if (count _job == 0) exitWith {};
A3I_dependencies set ["available",false]; [_job] call _waitJob;
["major_dependency_loss_cancels",_job get "outcome" == "cancelled" && {A3A_resourcesAttackOcc == 1}] call _check;
A3I_dependencies set ["available",true];
_job = [] call _launch;
if (count _job == 0) exitWith {};
A3I_majorGlobalOwner = "fixture_foreign_owner"; [_job] call _waitJob;
["major_foreign_global_claim_preserved",_job get "outcome" == "cancelled"
    && {bigAttackInProgress} && {A3I_majorGlobalOwner == "fixture_foreign_owner"}
    && {forcedSpawn isEqualTo []} && {A3A_resourcesAttackOcc == 1}] call _check;
A3I_majorGlobalOwner = nil; bigAttackInProgress = false;
_job = [] call _launch;
if (count _job == 0) exitWith {};
forcedSpawn pushBack _town; _job set ["emptyDeadline",time - 1]; [_job] call _waitJob;
["major_foreign_forced_entry_preserved",forcedSpawn isEqualTo [_town] && {!bigAttackInProgress}] call _check;
forcedSpawn = [];

call _reset; A3A_recentDamageOcc = [[4000,4500,60]];
_rejected = [_town,_source,1,0] call A3I_fnc_startMajorAttack;
["major_combat_source_refused_at_launch",!(_rejected # 0) && {A3A_resourcesAttackOcc == 1}] call _check;
call _reset; [4,4] call _setLimits;
_job = [0,1] call _launch;
if (count _job == 0) exitWith {};
[{count (_job get "units") == 4}] call _wait;
private _combatUnits = +(_job get "units");
{_x enableSimulationGlobal false} forEach _combatUnits;
// Represent the last four attackers, with no remaining reserve; deaths are real.
_job set ["planned",4]; _job set ["queue",[]]; _job set ["creditRemaining",0];
{_x setDamage 1} forEach (_combatUnits select [0,3]); sleep 1.3;
["major_exact_quarter_keeps_fighting",_job get "outcome" == "pending"
    && {{alive _x} count _combatUnits == 1}] call _check;
(_combatUnits # 3) setDamage 1;
[{_job get "settled"}] call _wait;
[{(A3A_tasksData findIf {_x # 0 == _job get "taskId" && {_x # 2 == "SUCCEEDED"}}) != -1}] call _wait;
["major_real_defeat_task_succeeds",_job get "outcome" == "defeated" && {_job getOrDefault ["rewarded",false]}
    && {(A3A_tasksData findIf {_x # 0 == _job get "taskId" && {_x # 2 == "SUCCEEDED"}}) != -1}
    && {A3A_resourcesAttackOcc == -239}] call _check;
private _moneyBefore = A3A_resourcesAttackOcc;
[_job] call A3I_fnc_finishMajorAttack;
["major_settlement_once",A3A_resourcesAttackOcc == _moneyBefore] call _check;
[_job] call _waitJob;
{deleteVehicle _x} forEach _combatUnits;

// Petros is a fixture actor, without the campaign's death/relocation handlers.
private _hqGroup = createGroup [teamPlayer,true];
petros = _hqGroup createUnit ["I_G_officer_F",getMarkerPos "Synd_HQ",[],0,"NONE"];
petros enableSimulationGlobal false;
_job = [300,1,"Synd_HQ"] call _launch;
if (count _job == 0) exitWith {deleteVehicle petros; deleteGroup _hqGroup};
["major_hq_charge_and_flags",A3A_resourcesAttackOcc == -399 && {HQAttackInProgress}
    && {_job get "hq"} && {_job get "taskType" == "DEF_HQ"}] call _check;
private _oldHQ = getMarkerPos "Synd_HQ";
"Synd_HQ" setMarkerPos (_oldHQ vectorAdd [1000,0,0]);
[_job] call _waitJob;
["major_moved_hq_cancels",_job get "outcome" == "hq_moved" && {A3A_resourcesAttackOcc == 1}
    && {!HQAttackInProgress} && {!(_job getOrDefault ["rewarded",false])}] call _check;
"Synd_HQ" setMarkerPos _oldHQ;
[4,2] call _setLimits;
_job = [0,1,"Synd_HQ"] call _launch;
if (count _job == 0) exitWith {deleteVehicle petros; deleteGroup _hqGroup};
[{count (_job get "units") == 2}] call _wait;
petros setDamage 1;
[{_job get "settled"}] call _wait;
[{(A3A_tasksData findIf {_x # 0 == _job get "taskId" && {_x # 2 == "FAILED"}}) != -1}] call _wait;
["major_petros_death_fails_task",_job get "outcome" == "petros_killed"
    && {!(_job getOrDefault ["rewarded",false])}
    && {(A3A_tasksData findIf {_x # 0 == _job get "taskId" && {_x # 2 == "FAILED"}}) != -1}] call _check;
[_job] call _waitJob;
["major_hq_cleanup_keeps_fixed_cost",A3A_resourcesAttackOcc == -399 && {!HQAttackInProgress}
    && {!bigAttackInProgress}] call _check;
deleteVehicle petros; petros = objNull; sleep 0.1; deleteGroup _hqGroup;

// Native capture needs physical arrivals and all saved defenders represented.
// The transaction endpoint then flips ownership; its broader campaign effects
// are outside this isolated fixture.
call _reset; [4,4] call _setLimits;
A3I_test_nativeZoneCheck = true; A3I_test_applyMarkerChange = true;
zoneChecksMutex = createHashMap; A3A_diameterExtendedCaptureArea = 0;
server setVariable [_town,[10,0,40,60]];
private _defenderGroup = createGroup [teamPlayer,true];
private _defender = _defenderGroup createUnit ["I_G_Soldier_F",_position,[],0,"NONE"];
_defender enableSimulationGlobal false; _defender setVariable ["markerX",_town];
garrison setVariable [_town,[_role,_role]];
_job = [0,1] call _launch;
if (count _job == 0) exitWith {deleteVehicle _defender; deleteGroup _defenderGroup};
spawner setVariable [_town,0]; A3I_test_zones = [];
[{count (_job get "units") == 4}] call _wait;
sleep 1.2;
["major_capture_requires_arrival",A3I_test_zones isEqualTo [] && {sidesX getVariable _town == teamPlayer}] call _check;
{
    _x enableSimulationGlobal false;
    _x setPosATL (_position vectorAdd [2 + _forEachIndex * 2,3,0]);
} forEach (_job get "units");
sleep 1.2;
["major_unspawned_defenders_block_capture",A3I_test_zones isEqualTo []
    && {sidesX getVariable _town == teamPlayer}] call _check;
garrison setVariable [_town,[_role]];
[{sidesX getVariable _town == west}] call _wait;
["major_native_capture_decision",sidesX getVariable _town == west && {A3I_test_zones isNotEqualTo []}
    && {(A3I_test_originals findIf {_x # 0 == "originalMarkerChange" && {_x # 1 isEqualTo [west,_town]}}) != -1}] call _check;
deleteVehicle _defender; sleep 0.1; deleteGroup _defenderGroup;
[{_job get "settled"}] call _wait;
[{(A3A_tasksData findIf {_x # 0 == _job get "taskId" && {_x # 2 == "FAILED"}}) != -1}] call _wait;
["major_town_loss_fails_defence_task",_job get "outcome" == "captured"
    && {!(_job getOrDefault ["rewarded",false])}
    && {(A3A_tasksData findIf {_x # 0 == _job get "taskId" && {_x # 2 == "FAILED"}}) != -1}] call _check;
[_job] call _waitJob;
spawner setVariable [_town,2];
[{isNil "A3I_sites" || {!(_town in A3I_sites)}},8] call _wait;
A3I_test_nativeZoneCheck = false; A3I_test_applyMarkerChange = false;
["major_town_capture_preserves_politics",server getVariable _town isEqualTo [10,0,40,60]] call _check;
server setVariable [_town,+_targetTownData];
