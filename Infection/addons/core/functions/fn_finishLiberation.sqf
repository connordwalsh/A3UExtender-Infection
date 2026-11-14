// Internal once-only native townBattle settlement. The town-change prefix is
// adapted from Ultimate 12.4.2 cityChangeSide (see THIRD_PARTY_LICENSES.txt).
// Its post-sleep maintenance is dispatched separately by the watchdog so a
// stopped scheduled worker cannot replay ownership, support or faction rewards.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_finishLiberation,_this] call CBA_fnc_directCall};
if (_record get "settled") exitWith {true};
private _outcome = _record get "outcome";
if (_outcome == "pending") then {_outcome = "interrupted"};
if (_outcome == "won") then {
    // Check again in this same atomic transaction before any rewards or capture.
    _record set ["outcome","pending"];
    _outcome = [_record] call A3I_fnc_liberationOutcome;
    if (_outcome == "pending") then {_outcome = "cancelled"};
};
_record set ["outcome",_outcome];
// Native resourcesFIA waits on this lock. Defer rather than spin unscheduled.
if (_outcome == "won" && {missionNamespace getVariable ["resourcesIsChanging",false]}) exitWith {false};
private _name = _record get "name";
private _taskExists = (missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 0 == _name};
if (_taskExists == -1) then {_outcome = "cancelled"; _record set ["outcome",_outcome]};
_record set ["settled",true];
_record set ["taskDeleteAt",time + 60];
{
    if (_y getOrDefault ["mission",""] == _name && {_y getOrDefault ["purpose",""] == "liberation"}) then {
        _y set ["outcome",if (_outcome == "won") then {"defended"} else {
            if (_outcome in ["survivor_lost","expired"]) then {_outcome} else {"cancelled"}
        }];
        _y set ["queue",[]]; _y set ["creditRemaining",0];
    };
} forEach (missionNamespace getVariable ["A3I_majorAttacks",createHashMap]);
if !(_outcome in ["won","survivor_lost","expired"]) exitWith {
    if (_taskExists != -1) then {
        [_name,"CANCELED"] call BIS_fnc_taskSetState;
        [_name,"townBattle",0] call A3A_fnc_taskDelete;
    } else {[_name] call BIS_fnc_deleteTask};
    _record set ["taskDeleted",true]; _record set ["taskDeleteAt",time];
    true
};
private _town = _record get "town";
private _position = _record get "position";
private _won = _outcome == "won";
[_name,"townBattle",["FAILED","SUCCEEDED"] select _won] call A3A_fnc_taskSetState;
if (!_won && {!(_record get "recruited")}) exitWith {
    [10,-10,_town,false] spawn A3A_fnc_citySupportChange;
    true
};
{
    private _distance = getMarkerPos _x distance2D _position;
    if (_distance > 3000) then {continue};
    private _support = linearConversion [0,3000,_distance,[-20,10] select _won,0,true];
    [0,_support,_x,false] spawn A3A_fnc_citySupportChange;
} forEach citiesX;
private _population = _record get "population";
if (!_won) exitWith {
    [0,-20,_town,false] spawn A3A_fnc_citySupportChange;
    [-4 * _population * A3A_balancePlayerScale,west,"attack"] call A3A_fnc_addEnemyResources;
    true
};
// Same immediate territory transaction as native cityChangeSide's Rebel branch.
["TaskSucceeded",["",format [localize "STR_notifiers_city_joined",_town,A3A_faction_reb get "name"]]]
    remoteExec ["BIS_fnc_showNotification",teamPlayer];
sidesX setVariable [_town,teamPlayer,true];
[Occupants,10,60] remoteExec ["A3A_fnc_addAggression",2];
garrison setVariable [_town,[],true];
[_town] call A3A_fnc_mrkUpdate;
[-10,10,_town,false] spawn A3A_fnc_citySupportChange;
if (milAdministrationsX isNotEqualTo [] && {A3A_milAdministrations isNotEqualTo []}) then {
    private _adminMarker = [milAdministrationsX,_town] call BIS_fnc_nearestPosition;
    if (_adminMarker isEqualType "" && {getMarkerPos _adminMarker distance2D _position < 800}) then {
        private _building = [A3A_milAdministrations,_adminMarker] call BIS_fnc_nearestPosition;
        if (!isNull _building) then {[_building,"CAPTURE"] call SCRT_fnc_location_removeMilAdmin};
    };
};
_record set ["cityMaintenanceAt",time + 5];
// Native townBattle pays after cityChangeSide's delayed tier check. The watchdog
// completes that phase even when this scheduled worker has already stopped.
true
