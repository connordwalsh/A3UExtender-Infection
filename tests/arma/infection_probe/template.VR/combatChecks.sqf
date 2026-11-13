// Dedicated contract fixture, called in the parent logger/loaded-faction scope.
// Real loader, creator, events, resources, damage, postmortem and roster updates.
// Task/UI, support and aggression endpoints are recorded, not run as a campaign.
#include "\x\a3a\addons\core\script_component.hpp"
private _combatEntitiesBefore = entities [[], [], true, false];
private _combatGroupsBefore = +allGroups;
private _marker = "a3i_combat_contract";
createMarker [_marker, [1000,1000,0]];
garrison = [true] call A3A_fnc_createNamespace;
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrisonIsChanging = false;
sidesX setVariable [_marker, west];
spawner setVariable [_marker, 0];
A3A_GCThreshold = 600;
GVAR(despawnQueue) = [];
GVAR(despawnerRunning) = nil;
A3A_resourcesAttackOcc = 1000;
A3A_resourcesDefenceOcc = 1000;
A3A_resourcesAttackInv = 1000;
A3A_resourcesDefenceInv = 1000;
A3A_recentDamageOcc = [];
A3A_recentDamageInv = [];
A3A_hasACE = false;
distanceSPWN = 1000;
west setFriend [independent, 0];
independent setFriend [west, 0];
west setFriend [east, 0];
east setFriend [west, 0];
probeObserver allowDamage false;
probeObserver setCaptive true;
removeAllWeapons probeObserver;

// Test-only addon supplies recording endpoints before CfgFunctions compilation.
// Runtime reassignment cannot replace Ultimate's compileFinal functions.
private _endpointConfig = configFile >> "CfgFunctions";
private _endpointContracts = [
    ["A3A", "Base", "citySupportChange"], ["A3A", "Base", "addAggression"],
    ["A3A", "Base", "zoneCheck"], ["A3A", "Missions", "underAttack"],
    ["A3A", "AI", "AIreactOnKill"], ["A3A", "Garrison", "selectVehicleType"],
    ["A3I", "Originals", "originalNATOinit"]
];
private _missingEndpoints = _endpointContracts select {
    getText (_endpointConfig >> (_x # 0) >> (_x # 1) >> (_x # 2) >> "file")
        != ("\x\a3i\tests\contracts\fn_" + (_x # 2) + ".sqf")
};
["combat_test_endpoints", isClass (configFile >> "CfgPatches" >> "A3I_test_contracts")
    && {_missingEndpoints isEqualTo []}, _missingEndpoints] call _check;
A3I_test_support = [];
A3I_test_aggression = [];
A3I_test_zones = [];
A3I_test_attacks = [];
A3I_test_humanReactions = 0;
A3I_test_initEvents = [];
A3I_test_deathEvents = [];
private _initHandler = [CBA_EVENT_SERVER_INIT_AI_UNIT, {A3I_test_initEvents pushBack +_this}] call CBA_fnc_addEventHandler;
private _deathHandler = [CBA_EVENT_SERVER_ENTITY_POSTMORTEM, {A3I_test_deathEvents pushBack +_this}] call CBA_fnc_addEventHandler;
private _new = {
    params [["_role", "militia_Rifleman"], ["_position", [1000,1000,0]]];
    private _group = createGroup [west, true];
    private _unit = [_group, "loadouts_occ_" + _role, _position] call A3A_fnc_createUnit;
    private _deadline = diag_tickTime + 10;
    waitUntil {sleep 0.1; !isNil {_unit getVariable "WBK_AI_AttachedHandlers"} || {diag_tickTime > _deadline}};
    // Prepared-class initialization schedules its initial movement/identity work.
    sleep 0.7;
    _unit
};
private _remove = {
    params ["_unit"];
    private _group = group _unit;
    deleteVehicle _unit;
    sleep 0.5;
    if (count units _group == 0) then {deleteGroup _group};
};
private _resetAccounting = {
    A3A_resourcesAttackOcc = 1000;
    A3A_resourcesDefenceOcc = 1000;
    A3A_recentDamageOcc = [];
    A3I_test_support = [];
    A3I_test_aggression = [];
    A3I_test_zones = [];
    A3I_test_deathEvents = [];
    GVAR(despawnQueue) = [];
    sidesX setVariable [_marker, west];
    garrison setVariable [_marker, ["loadouts_occ_militia_Rifleman", "loadouts_occ_militia_Rifleman"]];
};

["combat_override_registered", getText (configFile >> "CfgFunctions" >> "A3A" >> "CREATE" >> "NATOinit" >> "file")
    == "\x\a3i\addons\core\overrides\fn_NATOinit.sqf"] call _check;
private _control = [] call _new;
private _role = _control getVariable "unitType";
private _savedFaction = A3A_faction_occ;
private _savedAvailability = A3I_dependencies get "available";
private _guards = [[_control] call A3I_fnc_isManagedUnit, !([objNull] call A3I_fnc_isManagedUnit)];
_control setVariable ["unitType", "unrelated_prepared_unit"];
_guards pushBack !([_control] call A3I_fnc_isManagedUnit);
_control setVariable ["unitType", _role];
_control setVariable ["originalSide", east];
_guards pushBack !([_control] call A3I_fnc_isManagedUnit);
_control setVariable ["originalSide", west];
A3I_dependencies set ["available", false];
_guards pushBack !([_control] call A3I_fnc_isManagedUnit);
A3I_dependencies set ["available", _savedAvailability];
A3A_faction_occ = createHashMap;
_guards pushBack !([_control] call A3I_fnc_isManagedUnit);
A3A_faction_occ = _savedFaction;
["combat_guard_scope", _guards findIf {!_x} == -1, _guards] call _check;
// Verify argument-preserving dispatch without pretending to initialize a campaign's human AI.
A3I_test_nativeInitCalls = [];
private _args = [_control, _marker, true, "defence"];
A3A_faction_occ = createHashMap;
_args call A3A_fnc_NATOinit;
A3A_faction_occ = _savedFaction;
_control setVariable ["originalSide", east];
_args call A3A_fnc_NATOinit;
_control setVariable ["originalSide", west];
A3I_dependencies set ["available", false];
_args call A3A_fnc_NATOinit;
A3I_dependencies set ["available", _savedAvailability];
["combat_passthrough", A3I_test_nativeInitCalls isEqualTo [_args, _args, _args], [count A3I_test_nativeInitCalls]] call _check;
[_control] call _remove;

{
    private _unit = [_x + "_Rifleman"] call _new;
    private _wbkHandlers = +(_unit getVariable ["WBK_AI_AttachedHandlers", []]);
    private _hp = _unit getVariable ["WBK_SynthHP", -1];
    private _countBefore = count A3I_test_initEvents;
    [_unit, _marker] call A3A_fnc_NATOinit;
    private _ownHandlers = +(_unit getVariable ["A3I_handlers", []]);
    [_unit, _marker] call A3A_fnc_NATOinit;
    sleep 0.3;
    ["combat_init_" + _x, count _ownHandlers == 3
        && {(_unit getVariable ["A3I_handlers", []]) isEqualTo _ownHandlers}
        && {count A3I_test_initEvents == _countBefore + 1}
        && {count _wbkHandlers > 0 && {(_unit getVariable ["WBK_AI_AttachedHandlers", []]) isEqualTo _wbkHandlers}}
        && {_unit getVariable ["WBK_SynthHP", -1] == _hp}
        && {_unit getVariable ["A3A_resPool", ""] == "garrison"}
        && {!(_unit getVariable ["spawner", true])}
        && {!(_unit getVariable ["canBeIncapacitated", true])}
        && {simulationEnabled _unit} && {weapons _unit isEqualTo []}
        && {name _unit == "Infected Survivor"} && {side group _unit == west},
        [typeOf _unit, _ownHandlers, _wbkHandlers, _hp]] call _check;
    [_unit] call _remove;
} forEach ["militia", "military", "elite"];

private _spawnContracts = [];
spawner setVariable [_marker, 1];
_control = [] call _new;
[_control, _marker] call A3A_fnc_NATOinit;
sleep 0.2;
_spawnContracts pushBack (!simulationEnabled _control && {!(_control getVariable ["spawner",true])});
[_control] call _remove;
_control = [] call _new;
[_control, _marker, true, "defence"] call A3A_fnc_NATOinit;
sleep 0.2;
_spawnContracts pushBack (simulationEnabled _control && {_control getVariable ["spawner",false]}
    && {_control getVariable ["A3A_resPool",""] == "defence"});
[_control] call _remove;
spawner setVariable [_marker, 0];
_control = [] call _new;
[_control] call A3A_fnc_NATOinit;
_spawnContracts pushBack (simulationEnabled _control && {_control getVariable ["spawner",false]}
    && {_control getVariable ["A3A_resPool",""] == "legacy"});
[_control] call _remove;
["combat_init_spawn_contract", _spawnContracts findIf {!_x} == -1, _spawnContracts] call _check;

private _killerGroup = createGroup [independent, true];
private _killer = _killerGroup createUnit ["I_Soldier_F", [2000,2000,0], [], 0, "NONE"];
_killer disableAI "ALL";
private _enemyGroup = createGroup [east, true];
private _enemy = _enemyGroup createUnit ["O_Soldier_F", [2000,2100,0], [], 0, "NONE"];
_enemy disableAI "ALL";
_control = [] call _new;
[_control, _marker] call A3A_fnc_NATOinit;
garrison setVariable [_marker + "_lastAttack", -31];
private _hpBefore = _control getVariable ["WBK_SynthHP", -1];
private _nilReturns = [];
_nilReturns pushBack isNil {[_control, "head", 0.3, _killer] call A3I_fnc_infectedDamageObserved};
_nilReturns pushBack isNil {[_control, "", 0.3, _enemy] call A3I_fnc_infectedDamageObserved};
_nilReturns pushBack isNil {[_control, "", 0.3, _killer] call A3I_fnc_infectedDamageObserved};
_nilReturns pushBack isNil {[_control, "", 0.6, _killer] call A3I_fnc_infectedDamageObserved};
sleep 0.5;
private _attackCount = count A3I_test_attacks;
sidesX setVariable [_marker, independent];
garrison setVariable [_marker + "_lastAttack", -31];
_nilReturns pushBack isNil {[_control, "", 0.9, _killer] call A3I_fnc_infectedDamageObserved};
sleep 0.3;
["combat_damage_observer", _nilReturns findIf {!_x} == -1 && {_attackCount == 1}
    && {count A3I_test_attacks == 1} && {damage _control == 0}
    && {_control getVariable ["WBK_SynthHP", -1] == _hpBefore}, [_nilReturns, A3I_test_attacks]] call _check;
[_control] call _remove;

{
    _x params ["_label", "_pool", "_withMarker", "_rebelKill", "_expectedResources"];
    call _resetAccounting;
    private _unit = [] call _new;
    [_unit, ["", _marker] select _withMarker, true, _pool] call A3A_fnc_NATOinit;
    private _source = [_enemy, _killer] select _rebelKill;
    _unit setDamage [1, false, _source];
    sleep 1;
    [_unit, _source] call A3I_fnc_infectedKilled;
    sleep 0.3;
    private _support = A3I_test_support apply {_x select [0,2]};
    private _expectedSupport = [[-0.25,0], [-1,1]] select _rebelKill;
    private _expectedAggression = [[], [[west,0.5,45]]] select _rebelKill;
    private _rosterCount = [2,1] select _withMarker;
    private _passed = !alive _unit && {_unit getVariable ["A3I_finalized", false]}
        && {isNil {_unit getVariable "spawner"}}
        && {[A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc] isEqualTo _expectedResources}
        && {_support isEqualTo [_expectedSupport]}
        && {A3I_test_aggression isEqualTo _expectedAggression}
        && {count (garrison getVariable _marker) == _rosterCount}
        && {count A3I_test_zones == ([0,1] select _withMarker)}
        && {count A3I_test_deathEvents == 1}
        && {count GVAR(despawnQueue) == 1 && {_unit in GVAR(despawnQueue)}}
        && {count A3A_recentDamageOcc == 1} && {A3I_test_humanReactions == 0};
    [_unit] call _remove;
    _passed = _passed && {[A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc] isEqualTo _expectedResources};
    ["combat_kill_" + _label, _passed,
        [[A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc], _support, A3I_test_aggression,
         count (garrison getVariable _marker), count A3I_test_deathEvents, count A3A_recentDamageOcc]] call _check;
} forEach [
    ["garrison", "garrison", true, true, [1000,1000]],
    ["legacy", "legacy", false, true, [995,995]],
    ["prepaid_attack", "attack", false, true, [1000,1000]],
    ["nonrebel", "garrison", true, false, [1000,1000]]
];

{
    _x params ["_label", "_pool", "_unfit", "_expectedResources", "_expectedRoster"];
    call _resetAccounting;
    private _unit = [] call _new;
    [_unit, _marker, false, _pool] call A3A_fnc_NATOinit;
    if (_unfit) then {_unit setVariable ["incapacitated", true]};
    // Exercise the real engine Deleted EH, not a direct-call substitute.
    [_unit] call _remove;
    ["combat_delete_" + _label,
        [A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc] isEqualTo _expectedResources
        && {count (garrison getVariable _marker) == _expectedRoster}
        && {A3I_test_deathEvents isEqualTo []} && {A3I_test_support isEqualTo []},
        [[A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc], count (garrison getVariable _marker)]] call _check;
} forEach [
    ["attack_refund", "attack", false, [1010,1000], 2],
    ["defence_refund", "defence", false, [1000,1010], 2],
    ["garrison_retains", "garrison", false, [1000,1000], 2],
    ["legacy_retains", "legacy", false, [1000,1000], 2],
    ["unfit_legacy", "legacy", true, [995,995], 1]
];

call _resetAccounting;
_control = [] call _new;
[_control, _marker, false, "attack"] call A3A_fnc_NATOinit;
[_control] call A3I_fnc_infectedDeleted;
[_control] call A3I_fnc_infectedDeleted;
[_control] call _remove;
["combat_delete_duplicate", [A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc] isEqualTo [1010,1000]
    && {count (garrison getVariable _marker) == 2}] call _check;

call _resetAccounting;
_control = [] call _new;
[_control, _marker] call A3A_fnc_NATOinit;
sidesX setVariable [_marker, independent];
_control setDamage [1, false, _killer];
sleep 0.7;
["combat_ownership_race", count (garrison getVariable _marker) == 2 && {A3I_test_zones isEqualTo []}] call _check;
[_control] call _remove;
[_killer] call _remove;
[_enemy] call _remove;

// Real rifle impacts are necessary: setDamage bypasses HandleDamage entirely.
{
    call _resetAccounting;
    private _unit = [_x + "_Rifleman"] call _new;
    [_unit, "", true, "garrison"] call A3A_fnc_NATOinit;
    _unit setDir 0;
    private _rifleGroup = createGroup [independent, true];
    private _rifle = _rifleGroup createUnit ["I_Soldier_F", [1000,1030,0], [], 0, "NONE"];
    _rifle setDir 180;
    _rifle setUnitPos "UP";
    _rifle setSkill 1;
    _rifle disableAI "PATH";
    _rifle allowDamage false;
    _rifle setVariable ["A3I_test_shots", 0];
    _rifle addEventHandler ["Fired", {params ["_unit"]; _unit setVariable ["A3I_test_shots", 1 + (_unit getVariable "A3I_test_shots")]}];
    _rifleGroup setCombatMode "RED";
    _rifleGroup setBehaviourStrong "COMBAT";
    _rifle reveal [_unit,4];
    _rifle doTarget _unit;
    _rifle doFire _unit;
    private _deadline = diag_tickTime + 40;
    private _unconscious = false;
    waitUntil {
        sleep 0.1;
        _unconscious = _unconscious || {_unit getVariable ["incapacitated",false]} || {lifeState _unit == "INCAPACITATED"};
        !alive _unit || {diag_tickTime > _deadline}
    };
    sleep 0.5;
    ["combat_rifle_" + _x, !alive _unit && {!_unconscious}
        && {_unit getVariable ["A3I_finalized",false]} && {count A3I_test_deathEvents == 1}
        && {_rifle getVariable ["A3I_test_shots",0] > 0}
        && {A3I_test_aggression isEqualTo [[west,0.5,45]]},
        [typeOf _unit, alive _unit, damage _unit, _unit getVariable ["WBK_SynthHP",-1],
         _rifle getVariable ["A3I_test_shots",0], _unconscious, count A3I_test_deathEvents]] call _check;
    [_unit] call _remove;
    [_rifle] call _remove;
} forEach ["militia", "military", "elite"];

sleep 3;
[CBA_EVENT_SERVER_INIT_AI_UNIT, _initHandler] call CBA_fnc_removeEventHandler;
[CBA_EVENT_SERVER_ENTITY_POSTMORTEM, _deathHandler] call CBA_fnc_removeEventHandler;
deleteVehicle garrison;
deleteVehicle sidesX;
deleteVehicle spawner;
garrison = nil;
sidesX = nil;
spawner = nil;
deleteMarker _marker;
GVAR(despawnQueue) = [];
private _leftovers = (entities [[], [], true, false]) - _combatEntitiesBefore;
private _groupsLeft = allGroups - _combatGroupsBefore;
["combat_cleanup", _leftovers isEqualTo [] && {_groupsLeft isEqualTo []},
    [_leftovers apply {typeOf _x}, count _groupsLeft]] call _check;
