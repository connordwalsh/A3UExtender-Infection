// Standalone diagnostic. No Infection campaign code or production specials.
if (!isServer) exitWith {};
A3I_lifecycleRecords = createHashMap;
A3I_fnc_lifecycleSnapshot = {
    params ["_unit"];
    private _hp = _unit getVariable ["WBK_SynthHP",-1];
    if !(_hp isEqualType 0) then {_hp = -1};
    [isNull _unit,alive _unit,local _unit,owner _unit,damage _unit,_hp]
};
A3I_fnc_lifecycleEvent = {
    params ["_unit","_event"];
    private _key = _unit getVariable ["A3I_lifecycleTrial",""];
    private _record = A3I_lifecycleRecords getOrDefault [_key,createHashMap];
    if (count _record == 0) exitWith {};
    private _entry = [_event,diag_tickTime - (_record get "started"),
        _record get "phase",[_unit] call A3I_fnc_lifecycleSnapshot];
    (_record get "events") pushBack _entry;
    diag_log format ["[INFECTION_LIFECYCLE] %1",["event",_record get "class",_record get "scenario",_entry]];
};
[] spawn {
    private _log = {diag_log format ["[INFECTION_LIFECYCLE] %1",_this]};
    private _classes = call compile preprocessFileLineNumbers "candidates.sqf";
    private _scenarios = call compile preprocessFileLineNumbers "scenarios.sqf";
    private _abort = false;
    private _completed = 0;
    west setFriend [independent,0]; independent setFriend [west,0];
    probeObserver allowDamage false; probeObserver setCaptive true;
    removeAllWeapons probeObserver;
    sleep 3;
    ["start",productVersion,worldName,isDedicated,clientOwner,_classes,_scenarios] call _log;
    {
        private _class = _x;
        if (_abort) exitWith {};
        {
            if (_abort) exitWith {};
            _x params ["_scenario","_duration"];
            private _before = entities [[],[],true,false];
            private _groupsBefore = +allGroups;
            private _key = _class + ":" + _scenario;
            private _record = createHashMapFromArray [["class",_class],["scenario",_scenario],
                ["started",diag_tickTime],["phase","initializing"],["events",[]]];
            A3I_lifecycleRecords set [_key,_record];
            ["begin",_class,_scenario,_duration] call _log;
            private _group = createGroup [west,true];
            private _unit = _group createUnit [_class,[1000,1000,0],[],0,"NONE"];
            _unit setVariable ["A3I_lifecycleTrial",_key];
            _unit addEventHandler ["Killed",{[_this # 0,"Killed"] call A3I_fnc_lifecycleEvent}];
            _unit addEventHandler ["Deleted",{[_this # 0,"Deleted"] call A3I_fnc_lifecycleEvent}];
            private _deadline = diag_tickTime + 10;
            waitUntil {sleep 0.1; !isNil {_unit getVariable "WBK_AI_ISZombie"}
                || {isNull _unit} || {diag_tickTime >= _deadline}};
            sleep 2;
            private _valid = !isNull _unit && {alive _unit} && {local _unit}
                && {owner _unit == 2} && {side group _unit == west}
                && {!isNil {_unit getVariable "WBK_AI_ISZombie"}};
            ["setup",_class,_scenario,_valid,[_unit] call A3I_fnc_lifecycleSnapshot] call _log;
            if (!_valid) then {_abort = true};
            private _target = objNull;
            _record set ["phase","trial"];
            if (!_abort) then {
                switch (_scenario) do {
                    case "delete_alive": {deleteVehicle _unit};
                    case "forced_death": {_unit setDamage 1};
                    case "rifle_combat": {
                        private _targetGroup = createGroup [independent,true];
                        _target = _targetGroup createUnit ["I_Soldier_F",[1000,1025,0],[],0,"NONE"];
                        _target setDir 180; _target setUnitPos "UP"; _target disableAI "PATH";
                        _target setSkill 1; _targetGroup setCombatMode "RED";
                        _targetGroup setBehaviourStrong "COMBAT";
                        _target reveal [_unit,4]; _target doTarget _unit; _target doFire _unit;
                    };
                };
            };
            private _until = diag_tickTime + _duration;
            private _samples = 0;
            while {diag_tickTime < _until && {!_abort}} do {
                private _new = (entities [[],[],true,false]) - _before;
                ["sample",_class,_scenario,[_unit] call A3I_fnc_lifecycleSnapshot,
                    [_target] call A3I_fnc_lifecycleSnapshot,count _new] call _log;
                _samples = _samples + 1;
                if (count _new > 24) then {
                    ["abort",_class,_scenario,"entity_limit",count _new] call _log;
                    _abort = true;
                };
                sleep 0.5;
            };
            ["result",_class,_scenario,_samples,[_unit] call A3I_fnc_lifecycleSnapshot,
                +(_record get "events")] call _log;
            // Cleanup is tagged separately so its deletion never looks like combat.
            _record set ["phase","cleanup"];
            {if (!isPlayer _x) then {deleteVehicle _x}}
                forEach ((entities [[],[],true,false]) - _before);
            sleep 0.2;
            {if (units _x isEqualTo []) then {deleteGroup _x}} forEach (allGroups - _groupsBefore);
            sleep 5;
            private _left = ((entities [[],[],true,false]) - _before) select {!isPlayer _x};
            private _groups = allGroups - _groupsBefore;
            ["cleanup",_class,_scenario,_left apply {typeOf _x},count _groups,
                [_unit] call A3I_fnc_lifecycleSnapshot,+(_record get "events")] call _log;
            if (_left isNotEqualTo [] || {_groups isNotEqualTo []}) then {
                ["abort",_class,_scenario,"cleanup_leftovers",count _left] call _log;
                _abort = true;
            };
            _record set ["phase","finished"];
            _completed = _completed + 1;
        } forEach _scenarios;
    } forEach _classes;
    ["complete",_completed,_abort] call _log;
    missionNamespace setVariable ["Infection_probeComplete",true,true];
};
