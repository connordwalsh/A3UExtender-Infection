// Test fixture: sequential, isolated observations of the installed mod defaults.
// No Antistasi campaign or Infection gameplay functions are invoked.
if (!isServer) exitWith {};

[] spawn {
    private _log = { diag_log format ["[INFECTION_BEHAVIOR] %1", _this]; };
    private _classes = call compile preprocessFileLineNumbers "candidates.sqf";
    private _scenarios = call compile preprocessFileLineNumbers "scenarios.sqf";
    private _abort = false;
    private _completed = 0;
    west setFriend [independent, 0];
    independent setFriend [west, 0];
    west setFriend [east, 0];
    east setFriend [west, 0];
    // Deliberately leave CIV relations and every WebKnight setting unchanged.
    probeObserver allowDamage false;
    probeObserver setCaptive true;
    removeAllWeapons probeObserver;
    sleep 3;
    ["start", productVersion, worldName, isDedicated, clientOwner,
        [west getFriend independent, west getFriend east, west getFriend civilian,
         civilian getFriend west], _classes, _scenarios] call _log;
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
        if (_abort) exitWith {};
        {
            if (_abort) exitWith {};
            _x params ["_scenario", "_duration"];
            private _entitiesBefore = entities [[], [], true, false];
            private _groupsBefore = +allGroups;
            ["begin", _class, _scenario, _duration] call _log;
            private _infectedGroup = createGroup [west, true];
            private _unit = _infectedGroup createUnit [_class, [1000,1000,0], [], 0, "NONE"];
            _unit setDir 0;
            private _deadline = diag_tickTime + 10;
            waitUntil {
                sleep 0.1;
                !isNil {_unit getVariable "WBK_AI_ISZombie"} || {diag_tickTime > _deadline}
            };
            if (isNull _unit || {isNil {_unit getVariable "WBK_AI_ISZombie"}}) then {
                ["invalid", _class, _scenario, "Prepared-class initialization failed"] call _log;
                _abort = true;
            };
            // Let prepared-class initialization's delayed doMove/switchMove finish.
            sleep 2;
            private _target = objNull;
            private _vehicle = objNull;
            private _targetGroup = grpNull;
            private _targetPos = [1000,1006,0];
            private _targetSide = independent;
            private _targetClass = "I_Soldier_F";
            if (_scenario == "east_unarmed") then { _targetSide = east; _targetClass = "O_Soldier_F"; };
            if (_scenario == "civilian") then { _targetSide = civilian; _targetClass = "C_man_1"; };
            if (_scenario == "independent_survivor") then { _targetClass = "C_man_1"; };
            if (_scenario == "rifle_combat") then { _targetPos = [1000,1025,0]; };

            if !(_scenario in ["waypoint", "empty_vehicle"]) then {
                _targetGroup = createGroup [_targetSide, true];
                _target = _targetGroup createUnit [_targetClass, _targetPos, [], 0, "NONE"];
                // createUnit can retain the configured class side until explicitly joined.
                [_target] joinSilent _targetGroup;
                _target setDir 180;
                _target setUnitPos "UP";
                _target disableAI "PATH";
                if (_scenario != "rifle_combat") then {
                    removeAllWeapons _target;
                    _target disableAI "TARGET";
                    _target disableAI "AUTOTARGET";
                    _targetGroup setCombatMode "BLUE";
                } else {
                    _target setSkill 1;
                    _targetGroup setCombatMode "RED";
                    _targetGroup setBehaviourStrong "COMBAT";
                    _target reveal [_unit, 4];
                    _target doTarget _unit;
                    _target doFire _unit;
                };
            };
            if (_scenario in ["empty_vehicle", "occupied_vehicle"]) then {
                _vehicle = createVehicle ["C_Offroad_01_F", _targetPos, [], 0, "NONE"];
                _vehicle setDir 90;
                _vehicle setFuel 0;
                if (_scenario == "occupied_vehicle") then { _target moveInDriver _vehicle; };
            };
            private _destination = [1000,1020,0];
            if (_scenario == "waypoint") then {
                private _waypoint = _infectedGroup addWaypoint [_destination, 0];
                _waypoint setWaypointType "MOVE";
                _waypoint setWaypointCompletionRadius 2;
            };
            private _viewTarget = if (isNull _vehicle) then {_target} else {_vehicle};
            missionNamespace setVariable ["Infection_behaviorView", [_class, _scenario, _unit, _viewTarget, "running"], true];
            private _startPos = getPosATL _unit;
            private _initialHP = _unit getVariable ["WBK_SynthHP", -1];
            ["setup", _class, _scenario, str side group _unit, local _unit, owner _unit,
                typeOf _target, str side group _target, typeOf _vehicle,
                _startPos, _destination, _initialHP] call _log;
            private _started = diag_tickTime;
            private _minDistance = 1e6;
            private _maxTargetDamage = 0;
            private _maxVehicleDamage = 0;
            private _maxUnitDamage = 0;
            private _minHP = _initialHP;
            private _acquired = false;
            private _samples = 0;
            private _maxNewEntities = 0;
            while {diag_tickTime - _started < _duration && {!_abort}} do {
                private _observedEnemy = _unit findNearestEnemy _unit;
                if (!isNull _target) then {
                    _minDistance = _minDistance min (_unit distance _target);
                    _maxTargetDamage = _maxTargetDamage max damage _target;
                    if (_observedEnemy == _target || {!isNull _vehicle && {_observedEnemy == _vehicle}}) then { _acquired = true; };
                };
                if (!isNull _vehicle) then { _maxVehicleDamage = _maxVehicleDamage max damage _vehicle; };
                _maxUnitDamage = _maxUnitDamage max damage _unit;
                _minHP = _minHP min (_unit getVariable ["WBK_SynthHP", -1]);
                private _newEntities = (entities [[], [], true, false]) - _entitiesBefore;
                _maxNewEntities = _maxNewEntities max count _newEntities;
                if (count _newEntities > 24) then {
                    ["abort", _class, _scenario, "Fixture entity guard exceeded", count _newEntities] call _log;
                    _abort = true;
                };
                ["sample", _class, _scenario, diag_tickTime - _started,
                    getPosATL _unit, animationState _unit, alive _unit, damage _unit,
                    _unit getVariable ["WBK_SynthHP", -1],
                    typeOf _observedEnemy, isNull _target, alive _target, damage _target,
                    str side group _target, damage _vehicle, count _newEntities, diag_fps] call _log;
                _samples = _samples + 1;
                sleep 1;
            };
            ["result", _class, _scenario, _samples, _acquired, _minDistance,
                _maxTargetDamage, _maxVehicleDamage, _maxUnitDamage, _initialHP, _minHP,
                alive _unit, alive _target, str side group _target,
                _unit distance2D _startPos, _unit distance2D _destination,
                _maxNewEntities, local _unit, owner _unit] call _log;
            missionNamespace setVariable ["Infection_behaviorView", [_class, _scenario, _unit, _viewTarget, "cleanup"], true];
            // This standalone mission owns all new test actors and mod helpers.
            // Never delete a connected observer or objects that preceded this trial.
            private _toDelete = (entities [[], [], true, false]) - _entitiesBefore;
            {
                if (!isPlayer _x && {_x isKindOf "CAManBase"} && {vehicle _x != _x}) then {
                    vehicle _x deleteVehicleCrew _x;
                };
            } forEach _toDelete;
            { if (!isPlayer _x) then { deleteVehicle _x; }; } forEach _toDelete;
            sleep 0.1;
            { if (count units _x == 0) then { deleteGroup _x; }; } forEach (allGroups - _groupsBefore);
            sleep 5;
            private _remaining = ((entities [[], [], true, false]) - _entitiesBefore) select {!isPlayer _x};
            private _remainingGroups = allGroups - _groupsBefore;
            ["cleanup", _class, _scenario, _remaining apply {typeOf _x}, count _remainingGroups] call _log;
            if (count _remaining > 0 || {count _remainingGroups > 0}) then {
                ["abort", _class, _scenario, "Delayed entities/groups would contaminate the next trial"] call _log;
                _abort = true;
            };
            _completed = _completed + 1;
        } forEach _scenarios;
    } forEach _classes;
    ["complete", _completed, count _classes * count _scenarios, _abort] call _log;
    missionNamespace setVariable ["Infection_behaviorView", ["Batch finished", "Review log evidence", objNull, objNull, if (_abort) then {"ABORTED"} else {"COMPLETE"}], true];
};
