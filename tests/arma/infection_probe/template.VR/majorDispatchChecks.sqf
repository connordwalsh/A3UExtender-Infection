// Uses the surrounding lifecycle helpers. Real selector, native resource math,
// and inactive markerChange transactions; ordinary faction calls are recorded.
#include "\x\a3a\addons\core\script_component.hpp"
private _resetDispatch = {
    call _reset;
    {
        sidesX setVariable [_x,west]; spawner setVariable [_x,2];
        if !(_x in citiesX) then {server setVariable [_x,0]};
    } forEach _sources;
    A3A_curHQInfoOcc = 0; gameMode = 3; areInvadersDefeated = false;
    sidesX setVariable [_enemySite,Invaders]; spawner setVariable [_enemySite,2];
    garrison setVariable [_enemySite,[]]; garrison setVariable [_town,[]];
    factories pushBackUnique _enemySite;
    A3A_resourcesDefenceInv = 100; A3A_resourcesAttackInv = 100;
    A3A_attackHQProximityMul = 2; aggressionOccupants = 0; aggressionInvaders = 0;
    A3A_balanceResourceRate = 100; A3A_invaderBalanceMul = 10;
    A3A_supportSpends = []; A3A_supportStrikes = [];
    A3A_supportMarkerTypes = [[_enemySite,0,0,1]];
    A3A_test_markerUpdates = []; A3I_test_markerUpdates = [];
    garrisonIsChanging = false; markersChanging = [];
    A3A_faction_inv = createHashMapFromArray [["name","Fixture Invaders"]];
    A3A_faction_reb set ["name","Fixture Rebels"];
    distanceSPWN1 = 1000; distanceSPWN2 = 1000; debug = false;
};
call _resetDispatch;
A3I_test_originals = [];
["major_choose_invader_delegates",[Invaders] call A3A_fnc_chooseAttack
    && {A3I_test_originals isEqualTo [["chooseAttack",[Invaders]]]}] call _check;
["major_find_invader_delegates",[teamPlayer,Invaders] call A3A_fnc_findAttackTargets isEqualTo [["native"],[1]]
    && {A3I_test_originals # 1 isEqualTo ["findAttackTargets",[teamPlayer,Invaders]]}] call _check;
A3A_faction_occ set ["infectionTemplate",""];
["major_choose_inactive_delegates",[west] call A3A_fnc_chooseAttack] call _check;
["major_find_inactive_delegates",[teamPlayer,west] call A3A_fnc_findAttackTargets isEqualTo [["native"],[1]]] call _check;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
A3I_dependencies set ["available",false];
["major_choose_missing_dependencies_delegates",[west] call A3A_fnc_chooseAttack] call _check;
["major_find_missing_dependencies_delegates",[teamPlayer,west] call A3A_fnc_findAttackTargets isEqualTo [["native"],[1]]] call _check;
A3I_dependencies set ["available",true];
A3I_test_originals = [];
["major_find_native_entry_routes_to_walking",[teamPlayer,west] call A3A_fnc_findAttackTargets
    isEqualTo ([teamPlayer] call A3I_fnc_majorAttackTargets) && {A3I_test_originals isEqualTo []}] call _check;
private _result = true; isNil {_result = [west] call A3A_fnc_chooseAttack};
["major_choose_unscheduled_refused",!_result] call _check;
A3A_resourcesAttackOcc = 0;
["major_choose_no_funds_refused",!([west] call A3A_fnc_chooseAttack) && {A3A_resourcesAttackOcc == 0}] call _check;
call _resetDispatch; bigAttackInProgress = true;
["major_choose_foreign_attack_refused",!([west] call A3A_fnc_chooseAttack) && {bigAttackInProgress}
    && {A3A_resourcesAttackOcc == 1}] call _check;
bigAttackInProgress = false;
forcedSpawn = +_sources;
["major_choose_no_walking_origin",!([west] call A3A_fnc_chooseAttack)
    && {A3A_resourcesAttackOcc == 1} && {A3A_tasksData isEqualTo []}] call _check;
forcedSpawn = [];
_result = [west] call A3A_fnc_chooseAttack;
["major_choose_town_is_horde",_result && {!isNil "A3I_majorGlobalOwner"}] call _check;
if (!_result) exitWith {};
_job = A3I_majorAttacks get A3I_majorGlobalOwner;
[{_job get "taskRegistered"}] call _wait;
["major_choose_town_one_fixed_charge",_job get "target" == _town && {_job get "fixedCost" == 200}
    && {A3A_resourcesAttackOcc == -199} && {_job get "paidActors" == 0}
    && {A3I_test_originals isEqualTo []}] call _check;
_job set ["emptyDeadline",time - 1]; [_job] call _waitJob;
call _resetDispatch;
sidesX setVariable [_town,west]; A3A_curHQInfoOcc = 1;
private _hqGroup = createGroup [teamPlayer,true];
petros = _hqGroup createUnit ["I_G_officer_F",getMarkerPos "Synd_HQ",[],0,"NONE"];
petros enableSimulationGlobal false;
_result = [west] call A3A_fnc_chooseAttack;
["major_choose_known_hq_horde",_result && {HQAttackInProgress} && {A3A_resourcesAttackOcc == -399}] call _check;
if (_result) then {
    _job = A3I_majorAttacks get A3I_majorGlobalOwner;
    [{_job get "taskRegistered"}] call _wait;
    _job set ["emptyDeadline",time - 1]; [_job] call _waitJob;
};
deleteVehicle petros; petros = objNull; sleep 0.1; deleteGroup _hqGroup;
call _resetDispatch;
sidesX setVariable [_town,west]; gameMode = 1; spawner setVariable [_enemySite,0];
[0,4] call _setLimits;
_result = [west] call A3A_fnc_chooseAttack;
["major_choose_active_invader_horde",_result && {A3A_resourcesAttackOcc == -399}
    && {A3A_tasksData isEqualTo []}] call _check;
if (_result) then {
    _job = A3I_majorAttacks get A3I_majorGlobalOwner;
    _job set ["emptyDeadline",time - 1]; [_job] call _waitJob;
};
[4,4] call _setLimits;
call _resetDispatch;
private _choice = [_enemySite,_source,1,0,0,8];
private _unchanged = {A3A_resourcesAttackOcc == 1 && {A3A_resourcesDefenceInv == 100}
    && {sidesX getVariable _enemySite == Invaders} && {garrison getVariable _enemySite isEqualTo []}};
["major_sim_malformed_refused",!([[_enemySite,_source]] call A3I_fnc_simulateMajorAttack) && {call _unchanged}] call _check;
A3A_resourcesAttackOcc = 0;
["major_sim_no_funds_refused",!([_choice] call A3I_fnc_simulateMajorAttack)
    && {A3A_resourcesAttackOcc == 0} && {A3A_resourcesDefenceInv == 100}
    && {sidesX getVariable _enemySite == Invaders}] call _check;
A3A_resourcesAttackOcc = 1;
spawner setVariable [_enemySite,0];
["major_sim_active_target_refused",!([_choice] call A3I_fnc_simulateMajorAttack) && {call _unchanged}] call _check;
spawner setVariable [_enemySite,2];
sidesX setVariable [_enemySite,teamPlayer];
["major_sim_rebel_target_refused",!([_choice] call A3I_fnc_simulateMajorAttack)
    && {A3A_resourcesAttackOcc == 1}] call _check;
sidesX setVariable [_enemySite,Invaders];
garrisonIsChanging = true;
["major_sim_busy_garrison_refused",!([_choice] call A3I_fnc_simulateMajorAttack) && {call _unchanged}] call _check;
garrisonIsChanging = false; markersChanging = [_enemySite];
["major_sim_busy_capture_refused",!([_choice] call A3I_fnc_simulateMajorAttack) && {call _unchanged}] call _check;
markersChanging = []; bigAttackInProgress = true;
["major_sim_foreign_attack_refused",!([_choice] call A3I_fnc_simulateMajorAttack) && {call _unchanged}] call _check;
bigAttackInProgress = false;
private _sourcePosition = getMarkerPos _source; _source setMarkerPos [9000,4500,0];
["major_sim_distant_origin_refused",!([_choice] call A3I_fnc_simulateMajorAttack) && {call _unchanged}] call _check;
_source setMarkerPos _sourcePosition;
private _observerGroup = createGroup [teamPlayer,true];
private _observer = _observerGroup createUnit ["I_G_Soldier_F",_position,[],0,"NONE"];
_observer enableSimulationGlobal false; _observer setVariable ["spawner",true];
["major_sim_observed_target_refused",!([_choice] call A3I_fnc_simulateMajorAttack) && {call _unchanged}] call _check;
deleteVehicle _observer; sleep 0.1; deleteGroup _observerGroup;
A3I_test_nativeMarkerChange = false; A3I_test_applyMarkerChange = false;
["major_sim_refused_capture_not_charged",!([_choice] call A3I_fnc_simulateMajorAttack) && {call _unchanged}] call _check;

// Execute the installed native ownership/garrison-line/reinforcement metadata
// branch for every permanent target category; notifications remain server-side.
killZones = [true] call A3A_fnc_createNamespace;
A3I_test_majorEvents = [];
private _event = [CBA_EVENT_SERVER_MARKER_CHANGE,{A3I_test_majorEvents pushBack [+_this,canSuspend]}]
    call CBA_fnc_addEventHandler;
{garrison setVariable [_x + "_preference",[["","","GROUP"]]]} forEach ["Other","Airport","Outpost","MilitaryBase"];
private _categories = ["airportsX","outposts","milbases","factories","resourcesX","seaports"];
_enemySite setMarkerSize [120,120];
{
    private _category = _x;
    call _resetDispatch;
    {missionNamespace setVariable [_x,(missionNamespace getVariable _x) - [_enemySite]]} forEach _categories;
    (missionNamespace getVariable _category) pushBack _enemySite;
    reinforceMarkerOccupants = []; reinforceMarkerInvaders = [[0,_enemySite]];
    canReinforceOccupants = []; canReinforceInvaders = [_enemySite];
    A3I_test_nativeMarkerChange = true;
    private _eventsBefore = count A3I_test_majorEvents;
    _result = [_choice] call A3I_fnc_simulateMajorAttack;
    private _saved = garrison getVariable [_enemySite,[]];
    ["major_sim_native_" + _category,_result && {sidesX getVariable _enemySite == west}
        && {count _saved >= 12} && {count _saved <= (12 max ([_enemySite] call A3A_fnc_garrisonSize))}
        && {(_saved findIf {isNil {A3A_customUnitTypes getVariable _x}}) == -1}
        && {A3A_resourcesDefenceInv == 0}
        && {abs (A3A_resourcesAttackOcc - (1 - 400 - 100 * (0.75 + 2^(-8)))) < 0.001}
        && {count A3I_test_majorEvents == _eventsBefore + 1}
        && {(A3I_test_majorEvents # _eventsBefore) isEqualTo [[_enemySite,west,Invaders],false]}
        && {markersChanging isEqualTo []},[_result,count _saved,A3A_resourcesAttackOcc,A3A_resourcesDefenceInv,
        sidesX getVariable _enemySite,spawner getVariable _enemySite,_source,
        [_source] call A3I_fnc_majorSourceEligible,markersChanging]] call _check;
    // Native markerChange starts a one-second static-cleanup child even when
    // there are no statics. Let it finish before reusing/resetting this marker.
    sleep 1.5;
} forEach _categories;
_enemySite setMarkerSize [50,50];
private _after = [A3A_resourcesAttackOcc,A3A_resourcesDefenceInv,+(garrison getVariable _enemySite)];
["major_sim_capture_cannot_repeat",!([_choice] call A3I_fnc_simulateMajorAttack)
    && {[A3A_resourcesAttackOcc,A3A_resourcesDefenceInv,garrison getVariable _enemySite] isEqualTo _after}] call _check;
["major_sim_town_source_data_preserved",server getVariable _source isEqualTo _sourceTownData
    && {A3I_majorSourceCooldowns get _source > time}] call _check;
{missionNamespace setVariable [_x,(missionNamespace getVariable _x) - [_enemySite]]} forEach _categories;
call _resetDispatch; sidesX setVariable [_town,west]; gameMode = 1;
reinforceMarkerOccupants = []; reinforceMarkerInvaders = [[0,_enemySite]];
canReinforceOccupants = []; canReinforceInvaders = [_enemySite];
_result = [west] call A3A_fnc_chooseAttack;
["major_choose_offscreen_invader_simulated",_result && {sidesX getVariable _enemySite == west}
    && {garrison getVariable _enemySite isNotEqualTo []} && {A3A_resourcesAttackOcc < 0}
    && {count A3I_majorAttacks == 0} && {!bigAttackInProgress} && {forcedSpawn isEqualTo []}
    && {A3A_tasksData isEqualTo []},[_result,sidesX getVariable _enemySite,
    A3A_resourcesAttackOcc,A3A_resourcesDefenceInv,markersChanging,forcedSpawn]] call _check;
sleep 1.5;
call _resetDispatch;
reinforceMarkerOccupants = []; reinforceMarkerInvaders = [[0,_enemySite]];
canReinforceOccupants = []; canReinforceInvaders = [_enemySite];
A3A_resourcesDefenceInv = -50;
_result = [_choice] call A3I_fnc_simulateMajorAttack;
["major_sim_negative_defence_preserved",_result && {A3A_resourcesAttackOcc == -399}
    && {A3A_resourcesDefenceInv == -50} && {sidesX getVariable _enemySite == west}] call _check;
sleep 1.5;
[CBA_EVENT_SERVER_MARKER_CHANGE,_event] call CBA_fnc_removeEventHandler;
A3I_test_nativeMarkerChange = false;
deleteVehicle killZones; sleep 0.1;
["major_sim_no_live_force",((entities [[],[],true,false]) - _before)
    - [sidesX,spawner,garrison,server] isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []}
    && {(["stats"] call A3I_fnc_budget) # 1 select [1,3] isEqualTo [0,0,0]}] call _check;
