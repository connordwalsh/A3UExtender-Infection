// Standalone development mission. It never starts or edits an Antistasi save.
if (!isServer) exitWith {};

[] spawn {
    private _log = { diag_log format ["[INFECTION_PROBE] %1", _this]; };
    ["start", productVersion, worldName, isDedicated, clientOwner] call _log;
    private _candidates = call compile preprocessFileLineNumbers "candidates.sqf";
    private _failures = [];

    // Allow CBA settings to finish initializing before observing the mod.
    sleep 3;
    private _settingNames = (allVariables missionNamespace) select {
        private _name = toLower _x;
        (_name find "wbk_" == 0) && {(_name find "zomb" >= 0) || {_name find "corrupt" >= 0}}
    };
    _settingNames sort true;
    {
        private _value = missionNamespace getVariable _x;
        if (typeName _value in ["BOOL", "SCALAR", "STRING"]) then {
            ["setting", _x, _value] call _log;
        };
    } forEach _settingNames;

    {
        private _class = _x;
        private _cfg = configFile >> "CfgVehicles" >> _class;
        if (!isClass _cfg) then {
            _failures pushBack [_class, "missing class"];
            ["missing", _class] call _log;
            continue;
        };
        private _parents = [];
        private _parent = inheritsFrom _cfg;
        while {!isNull _parent} do {
            _parents pushBack configName _parent;
            _parent = inheritsFrom _parent;
        };
        private _moves = getText (_cfg >> "moves");
        ["class", _class, getNumber (_cfg >> "side"), getNumber (_cfg >> "scope"),
            getText (_cfg >> "model"), _moves,
            getText (configFile >> _moves >> "skeletonName"),
            _parents, configSourceAddonList _cfg] call _log;

        private _entitiesBefore = entities [[], [], true, false];
        private _group = createGroup [west, true];
        private _unit = _group createUnit [_class, [1000,1000,0], [], 0, "NONE"];
        private _deadline = diag_tickTime + 10;
        waitUntil {
            sleep 0.1;
            !isNil {_unit getVariable "WBK_AI_ISZombie"} || {diag_tickTime > _deadline}
        };
        // Smasher uses numeric 0 for WBK_AI_ISZombie; test existence, not truthiness.
        private _initialized = !isNil {_unit getVariable "WBK_AI_ISZombie"};
        sleep 5;
        ["spawn", _class, typeOf _unit, str side group _unit, local _unit, owner _unit,
            alive _unit, _initialized, _unit getVariable ["WBK_AI_ISZombie", "absent"],
            primaryWeapon _unit, secondaryWeapon _unit, handgunWeapon _unit,
            animationState _unit, count (_unit getVariable ["WBK_AI_AttachedHandlers", []])
        ] call _log;
        if (isNull _unit || {!alive _unit} || {!_initialized} || {!local _unit}
            || {side group _unit != west}) then {
            _failures pushBack [_class, "spawn/init/side/locality check failed"];
        };
        deleteVehicle _unit;
        deleteGroup _group;
        sleep 3;
        private _remaining = (entities [[], [], true, false]) - _entitiesBefore;
        ["afterDelete", _class, _remaining apply {typeOf _x}, count allGroups] call _log;
    } forEach _candidates;

    ["complete", count _candidates, _failures] call _log;
    missionNamespace setVariable ["Infection_probeComplete", true, true];
    // Remain available for a human to inspect the world/logs. No self-restart.
};
