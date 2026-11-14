/* Server scheduled bounded creation for registered basic infected.
   [context, roles, center, minRadius, maxRadius, marker, pool, localLimit,
    trackGarrison, eligibility={}, prepay=false, majorDebtToken=""]
   -> [success, [group, created units, budget ticket], reason].
   A partial result consumes only the first count(units) roles. The caller owns
   the remaining queue and must not treat a refused spawn as a killed defender. */
params ["_context", "_roles", "_center", "_minimum", "_maximum",
    ["_marker",""], ["_pool","garrison"], ["_localLimit",12], ["_trackGarrison",true,[true]],
    ["_eligibility",{true},[{}]], ["_prepay",false,[true]], ["_majorDebtToken","",[""]]];
private _empty = [grpNull,[],""];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {[false,_empty,"server_origin_only"]};
if (!canSuspend) exitWith {[false,_empty,"scheduled_required"]};
if !([west] call A3I_fnc_isActive) exitWith {[false,_empty,"inactive"]};
if !(_roles isEqualType [] && {_roles isNotEqualTo []} && {count _roles <= 256}
    && {_marker isEqualType ""} && {_pool in ["garrison","attack","defence","legacy"]}
    && {!_prepay || {_pool in ["attack","defence"]}}
    && {_majorDebtToken == "" || {_prepay && {_pool == "attack"}}})
    exitWith {[false,_empty,"invalid_request"]};
// Only a live server-owned major job grants bounded actor credit. Ordinary
// support and reinforcement callers retain the existing affordability checks.
private _debtRecord = (missionNamespace getVariable ["A3I_majorAttacks",createHashMap])
    getOrDefault [_majorDebtToken,createHashMap];
private _mayBorrow = {
    _majorDebtToken != "" && {_debtRecord getOrDefault ["context",""] == _context}
    && {missionNamespace getVariable ["A3I_majorGlobalOwner",""] == _majorDebtToken}
    && {_debtRecord getOrDefault ["outcome",""] == "pending"}
    && {_debtRecord getOrDefault ["creditRemaining",0] >= 1}
    && {!scriptDone (_debtRecord getOrDefault ["script",scriptNull])}
};
if (_majorDebtToken != "" && {!(call _mayBorrow)}) exitWith {[false,_empty,"credit"]};
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
    [west] call A3I_fnc_isActive && {call _eligibility} && {_marker == "" || {
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
private _site = (missionNamespace getVariable ["A3I_sites",createHashMap]) getOrDefault [_marker,createHashMap];
private _town = _site getOrDefault ["kind",""] == "City" && {_site getOrDefault ["context",""] == _context};
private _townAnchor = [];
if (isNull _group) then {_reason = "group_limit"} else {
    for "_index" from 0 to (_granted - 1) do {
        if !(call _allowed) exitWith {_reason = "inactive_site"};
        private _class = _classes # _index;
        private _search = if (_town) then {
            [_marker,_class,_townAnchor,_site get "townRoads"] call A3I_fnc_findCitySpawnPosition
        } else {[_center,_minimum,_maximum,_class] call A3I_fnc_findSpawnPosition};
        if (_search # 0 isEqualTo []) exitWith {_reason = _search # 1};
        private _position = _search # 0;
        private _unit = objNull;
        // Recheck observers/ownership and bind in the same unscheduled block as
        // creation, so a scheduling pause cannot invalidate the placement check.
        isNil {
            private _hqMarker = missionNamespace getVariable ["respawnTeamPlayer", ""];
            if (!(call _allowed) || {!(_hqMarker in allMapMarkers)}) exitWith {_reason = "inactive_site"};
            if (_town && {!(_position inArea _marker)}) exitWith {_reason = "town_bounds"};
            private _safety = [_position,_class,call A3I_fnc_spawnObservers,getMarkerPos _hqMarker] call A3I_fnc_positionSafety;
            if !(_safety # 0) exitWith {_reason = _safety # 1};
            private _remaining = ["remaining",[_ticket]] call A3I_fnc_budget;
            if !(_remaining # 0) exitWith {_reason = _remaining # 2};
            private _resourceName = ["A3A_resourcesDefenceOcc","A3A_resourcesAttackOcc"] select (_pool == "attack");
            private _funds = missionNamespace getVariable [_resourceName,0];
            if (_prepay && {!(_funds isEqualType 0 && {finite _funds}
                && {if (_majorDebtToken == "") then {_funds >= 10} else {call _mayBorrow}})})
                exitWith {_reason = "resources"};
            _unit = [_group,_roles # _index,_position,[],0,"NONE"] call A3A_fnc_createUnit;
            if (isNull _unit) exitWith {_reason = "creation_failed"};
            private _binding = ["bind",[_ticket,_unit]] call A3I_fnc_budget;
            if !(_binding # 0) exitWith {
                _reason = _binding # 2;
                deleteVehicle _unit;
                _unit = objNull;
            };
            if (_prepay) then {
                // Unit creation may run another addon's synchronous callbacks.
                // Recheck funds before payment, even inside this atomic section.
                _funds = missionNamespace getVariable [_resourceName,0];
                if !(_funds isEqualType 0 && {finite _funds}
                    && {if (_majorDebtToken == "") then {_funds >= 10} else {call _mayBorrow}}) exitWith {
                    _reason = "resources";
                    deleteVehicle _unit;
                    _unit = objNull;
                };
                [-10,west,_pool] call A3A_fnc_addEnemyResources;
                _unit setVariable ["A3I_reinforcementPaid",true];
                if (_majorDebtToken != "") then {
                    _debtRecord set ["creditRemaining",(_debtRecord get "creditRemaining") - 1];
                    _debtRecord set ["paidActors",(_debtRecord getOrDefault ["paidActors",0]) + 1];
                };
            };
            if (isNull _unit) exitWith {};
            [_unit,_marker,_context] call A3I_fnc_trackAdministrationDefender;
            // Controls use the marker for ownership/activation checks, but their
            // per-visit patrol casualties are not persistent garrison entries.
            [_unit,if (_trackGarrison) then {_marker} else {""},false,_pool] call A3A_fnc_NATOinit;
            if !(_unit getVariable ["A3I_initialized",false]) exitWith {
                _reason = "initialization_failed";
                if (_prepay) then {[10,west,_pool] call A3A_fnc_addEnemyResources};
                if (_majorDebtToken != "") then {
                    _debtRecord set ["creditRemaining",(_debtRecord get "creditRemaining") + 1];
                    _debtRecord set ["paidActors",(_debtRecord get "paidActors") - 1];
                };
                deleteVehicle _unit;
                _unit = objNull;
            };
            _units pushBack _unit;
            if (_town) then {
                _unit setVariable ["A3I_spawnPosition",+_position];
                if (_townAnchor isEqualTo []) then {
                    _townAnchor = +_position;
                    _group setVariable ["A3I_patrolCenter",+_position];
                };
            };
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
