/* Server scheduled bounded creation for registered basic infected.
   [context, roles, center, minRadius, maxRadius, marker, pool, localLimit, trackGarrison]
   -> [success, [group, created units, budget ticket], reason].
   A partial result consumes only the first count(units) roles. The caller owns
   the remaining queue and must not treat a refused spawn as a killed defender. */
params ["_context", "_roles", "_center", "_minimum", "_maximum",
    ["_marker",""], ["_pool","garrison"], ["_localLimit",12], ["_trackGarrison",true,[true]]];
private _empty = [grpNull,[],""];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {[false,_empty,"server_origin_only"]};
if (!canSuspend) exitWith {[false,_empty,"scheduled_required"]};
if !([west] call A3I_fnc_isActive) exitWith {[false,_empty,"inactive"]};
if !(_roles isEqualType [] && {_roles isNotEqualTo []} && {count _roles <= 256}
    && {_marker isEqualType ""} && {_pool in ["garrison","attack","defence","legacy"]})
    exitWith {[false,_empty,"invalid_request"]};
private _definitions = A3A_faction_occ get "loadouts";
private _classes = [];
private _invalid = false;
{
    if !(_x isEqualType "" && {_x find "loadouts_occ_" == 0} && {(_x select [13]) in _definitions}) exitWith {_invalid = true};
    private _definition = A3A_customUnitTypes getVariable [_x,[]];
    if (count _definition < 4) exitWith {_invalid = true};
    private _traits = _definition # 1;
    private _index = _traits findIf {_x # 0 == "baseClass"};
    if (_index == -1) exitWith {_invalid = true};
    private _class = (_traits # _index) # 1;
    if !(_class isEqualType "" && {_class in (A3I_dependencies get "basicClasses")}) exitWith {_invalid = true};
    _classes pushBack _class;
} forEach _roles;
if (_invalid) exitWith {[false,_empty,"unregistered_role"]};
private _allowed = {
    [west] call A3I_fnc_isActive && {_marker == "" || {
        !isNil "sidesX" && {!isNil "spawner"} && {_marker in allMapMarkers}
        && {sidesX getVariable [_marker,sideUnknown] == west}
        && {spawner getVariable [_marker,2] == 0}
    }}
};
if !(call _allowed) exitWith {[false,_empty,"inactive_site"]};
private _reservation = ["reserve",[_context,count _roles,_localLimit]] call A3I_fnc_budget;
if !(_reservation # 0) exitWith {[false,_empty,_reservation # 2]};
(_reservation # 1) params ["_ticket","_granted"];
private _group = createGroup [west,false];
_group setVariable ["A3I_context",_context];
private _units = [];
private _reason = "";
if (isNull _group) then {_reason = "group_limit"} else {
    for "_index" from 0 to (_granted - 1) do {
        if !(call _allowed) exitWith {_reason = "inactive_site"};
        private _class = _classes # _index;
        private _search = [_center,_minimum,_maximum,_class] call A3I_fnc_findSpawnPosition;
        if (_search # 0 isEqualTo []) exitWith {_reason = _search # 1};
        private _position = _search # 0;
        private _unit = objNull;
        // Recheck observers/ownership and bind in the same unscheduled block as
        // creation, so a scheduling pause cannot invalidate the placement check.
        isNil {
            private _hqMarker = missionNamespace getVariable ["respawnTeamPlayer", ""];
            if (!(call _allowed) || {!(_hqMarker in allMapMarkers)}) exitWith {_reason = "inactive_site"};
            private _safety = [_position,_class,call A3I_fnc_spawnObservers,getMarkerPos _hqMarker] call A3I_fnc_positionSafety;
            if !(_safety # 0) exitWith {_reason = _safety # 1};
            private _remaining = ["remaining",[_ticket]] call A3I_fnc_budget;
            if !(_remaining # 0) exitWith {_reason = _remaining # 2};
            _unit = [_group,_roles # _index,_position,[],0,"NONE"] call A3A_fnc_createUnit;
            if (isNull _unit) exitWith {_reason = "creation_failed"};
            private _binding = ["bind",[_ticket,_unit]] call A3I_fnc_budget;
            if !(_binding # 0) exitWith {
                _reason = _binding # 2;
                deleteVehicle _unit;
                _unit = objNull;
            };
            [_unit,_marker,_context] call A3I_fnc_trackAdministrationDefender;
            // Controls use the marker for ownership/activation checks, but their
            // per-visit patrol casualties are not persistent garrison entries.
            [_unit,if (_trackGarrison) then {_marker} else {""},false,_pool] call A3A_fnc_NATOinit;
            if !(_unit getVariable ["A3I_initialized",false]) exitWith {
                _reason = "initialization_failed";
                deleteVehicle _unit;
                _unit = objNull;
            };
            _units pushBack _unit;
        };
        if (isNull _unit) exitWith {};
        sleep 0.05;
    };
};
["close",[_ticket]] call A3I_fnc_budget;
if (_units isEqualTo []) exitWith {
    deleteGroup _group;
    [false,[grpNull,[],_ticket],_reason]
};
_group deleteGroupWhenEmpty true;
if (_reason == "" && {count _units < count _roles}) then {_reason = "partial_capacity"};
[true,[_group,_units,_ticket],_reason]
