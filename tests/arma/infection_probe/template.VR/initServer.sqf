// Exercise Ultimate's real loader/creator without starting a campaign or save.
#include "\x\a3a\addons\core\Includes\script_version.hpp"
if (!isServer) exitWith {};
[] spawn {
    private _log = {diag_log format ["[INFECTION_TEMPLATE] %1", _this]};
    private _failures = [];
    private _checks = 0;
    private _check = {
        params ["_name", "_passed", ["_detail", []]];
        _checks = _checks + 1;
        if (!_passed) then {_failures pushBack _name};
        ["check", _name, _passed, _detail] call _log;
    };
    private _expectedDependencies = call compile preprocessFileLineNumbers "expectedDependencies.sqf";
    private _suite = call compile preprocessFileLineNumbers "selectedSuite.sqf";
    ["start", productVersion, worldName, isDedicated, clientOwner, _expectedDependencies,_suite] call _log;
    sleep 3;
    ["addon_registered", isClass (configFile >> "CfgPatches" >> "A3I_core")] call _check;
    ["functions_available", !isNil "A3I_fnc_dependencies" && {!isNil "A3I_fnc_isActive"}] call _check;
    if (isNil "A3I_fnc_dependencies" || {isNil "A3I_fnc_isActive"}) exitWith {
        ["complete", _checks, _failures, 0] call _log;
    };
    private _dependencies = call A3I_fnc_dependencies;
    ["dependency_state", (_dependencies get "available") isEqualTo _expectedDependencies,
        [_dependencies get "missingPatches", _dependencies get "invalidClasses"]] call _check;
    ["passive_without_faction", !(call A3I_fnc_isActive)] call _check;
    private _templateCfg = configFile >> "A3A" >> "Templates" >> "A3I_Infected";
    ["template_registered", isClass _templateCfg] call _check;
    ["template_side", getText (_templateCfg >> "side") == "Occ"] call _check;
    private _required = getArray (_templateCfg >> "requiredAddons");
    private _missing = _required select {!isClass (configFile >> "CfgPatches" >> _x)};
    ["setup_dependency_gate", (_missing isEqualTo []) isEqualTo _expectedDependencies, _missing] call _check;
    private _compat = [configFile >> "CfgPatches" >> "A3I_core"] call A3A_fnc_validateExtenderCompat;
    ["ultimate_version_contract", (_compat get "compatStatus") == 0, [_compat get "compatReason"]] call _check;
    ["ultimate_patch_version", [MAJOR,MINOR,PATCHLVL] isEqualTo [12,4,2], [MAJOR,MINOR,PATCHLVL]] call _check;
    // A forged selection must still be unable to activate when the dependency is absent.
    A3A_faction_occ = createHashMapFromArray [["infectionTemplate", "A3I_Infected"]];
    ["activation_requires_dependencies", (call A3I_fnc_isActive) isEqualTo _expectedDependencies] call _check;
    A3A_faction_occ = createHashMap;
    if (!_expectedDependencies) exitWith {
        ["both_required_patches_absent", count _missing == 2, _missing] call _check;
        ["complete", _checks, _failures, 0] call _log;
        missionNamespace setVariable ["Infection_probeComplete", true, true];
    };

    Occupants = west;
    Invaders = east;
    teamPlayer = independent;
    A3A_customUnitTypes = [true] call A3A_fnc_createNamespace;
    private _faction = [getText (_templateCfg >> "basepath") + "\" + getText (_templateCfg >> "file") + ".sqf", west]
        call A3A_fnc_compatibilityLoadFaction;
    ["active_only_for_occupants", [west] call A3I_fnc_isActive && {!([east] call A3I_fnc_isActive)}
        && {!([independent] call A3I_fnc_isActive)} && {!([civilian] call A3I_fnc_isActive)}] call _check;
    if (_suite in ["administration","reinforcements","roaming","counterattacks","towns"]) exitWith {
        private _suitePath = switch (_suite) do {
            case "administration": {"administrationChecks.sqf"};
            case "reinforcements": {"reinforcementChecks.sqf"};
            case "counterattacks": {"counterattackChecks.sqf"};
            case "towns": {"cityChecks.sqf"};
            default {"roamingChecks.sqf"};
        };
        private _suiteSource = preprocessFileLineNumbers _suitePath;
        diag_log format ["[INFECTION_SUITE] path=%1 characters=%2",_suitePath,count _suiteSource];
        call compile _suiteSource;
        deleteVehicle A3A_customUnitTypes;
        ["complete",_checks,_failures,0] call _log;
        missionNamespace setVariable ["Infection_probeComplete",true,true];
    };
    private _definitions = _faction get "loadouts";
    private _names = keys _definitions;
    _names sort true;
    ["role_count", count _names == 67, [count _names]] call _check;
    private _references = [];
    private _walk = {
        if (_this isEqualType "") exitWith {
            if (_this find "loadouts_occ_" == 0) then {_references pushBackUnique _this};
        };
        if (_this isEqualType []) then {{_x call _walk} forEach _this};
    };
    {_y call _walk} forEach _faction;
    private _missingRoles = _references select {isNil {A3A_customUnitTypes getVariable _x}};
    ["generated_groups_resolve", count _references > 0 && {_missingRoles isEqualTo []}, [count _references, _missingRoles]] call _check;
    private _badDefinitions = _names select {
        private _def = _definitions get _x;
        !((_def # 0) isEqualTo []) || {count (_def # 1) != 1}
            || {((_def # 1) # 0) # 0 != "baseClass"}
            || {!(((_def # 1) # 0) # 2)}
            || {!((((_def # 1) # 0) # 1) in (_dependencies get "basicClasses"))}
    };
    ["prepared_basic_classes_only", _badDefinitions isEqualTo [], _badDefinitions] call _check;
    private _assetKeys = ["flag", "ammobox", "surrenderCrate", "equipmentBox"];
    private _badAssets = _assetKeys select {!isClass (configFile >> "CfgVehicles" >> (_faction get _x))};
    ["assets_resolve", _badAssets isEqualTo [] && {isClass (configFile >> "CfgMarkers" >> (_faction get "flagMarkerType"))}, _badAssets] call _check;
    private _nonEmptyVehicles = (keys _faction) select {
        private _key = toLower _x;
        (_key find "vehicles" == 0 || {_key find "static" == 0} || {_key find "uavs" == 0})
            && {!((_faction get _x) isEqualTo [])} && {!((_faction get _x) isEqualTo "")}
    };
    ["conventional_pools_empty", _nonEmptyVehicles isEqualTo [], _nonEmptyVehicles] call _check;

    call compile preprocessFileLineNumbers "garrisonChecks.sqf";

    private _entitiesBefore = entities [[], [], true, false];
    private _groupsBefore = allGroups;
    private _spawned = 0;
    {
        private _name = _x;
        private _registeredName = "loadouts_occ_" + _name;
        private _expectedClass = ((_definitions get _name) # 1) # 0 # 1;
        private _group = createGroup [west, true];
        private _unit = [_group, _registeredName, [1000,1000,0]] call A3A_fnc_createUnit;
        private _deadline = diag_tickTime + 10;
        waitUntil {sleep 0.1; !isNil {_unit getVariable "WBK_AI_ISZombie"} || {diag_tickTime > _deadline}};
        sleep 0.3;
        private _passed = !isNull _unit && {alive _unit} && {typeOf _unit == _expectedClass}
            && {side group _unit == west} && {local _unit} && {owner _unit == 2}
            && {!isNil {_unit getVariable "WBK_AI_ISZombie"}}
            && {primaryWeapon _unit == ""} && {secondaryWeapon _unit == ""} && {handgunWeapon _unit == ""}
            && {_unit getVariable ["unitType", ""] == _registeredName}
            && {name _unit == "Infected Survivor"};
        ["spawn_" + _name, _passed, [typeOf _unit, str side group _unit, local _unit,
            owner _unit, name _unit, face _unit, speaker _unit, animationState _unit]] call _check;
        ["spawn", _name, _expectedClass, _passed] call _log;
        _spawned = _spawned + 1;
        deleteVehicle _unit;
        sleep 0.1;
        if (count units _group == 0) then {deleteGroup _group};
        sleep 0.2;
    } forEach _names;
    sleep 3;
    private _leftovers = (entities [[], [], true, false]) - _entitiesBefore;
    private _remainingGroups = allGroups - _groupsBefore;
    ["cleanup", _leftovers isEqualTo [] && {_remainingGroups isEqualTo []},
        [_leftovers apply {typeOf _x}, count _remainingGroups]] call _check;
    call compile preprocessFileLineNumbers "combatChecks.sqf";
    call compile preprocessFileLineNumbers "budgetChecks.sqf";
    call compile preprocessFileLineNumbers "spawnChecks.sqf";
    call compile preprocessFileLineNumbers "siteChecks.sqf";
    call compile preprocessFileLineNumbers "controlChecks.sqf";
    call compile preprocessFileLineNumbers "cityChecks.sqf";
    call compile preprocessFileLineNumbers "administrationChecks.sqf";
    call compile preprocessFileLineNumbers "reinforcementChecks.sqf";
    call compile preprocessFileLineNumbers "roamingChecks.sqf";
    call compile preprocessFileLineNumbers "counterattackChecks.sqf";
    deleteVehicle A3A_customUnitTypes;
    ["complete", _checks, _failures, _spawned] call _log;
    missionNamespace setVariable ["Infection_probeComplete", true, true];
};
