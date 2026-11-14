// Rebel branch of Ultimate 12.4.2 cityChangeSide, with an atomic full-clear
// transition and delayed maintenance independent of the calling worker.
params [["_city","",[""]]];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}
    || {!([west] call A3I_fnc_isActive)} || {!(_city in citiesX)}
    || {count ([_city] call A3I_fnc_liquidationClaim) == 0}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_liquidationCityCapture,_this] call CBA_fnc_directCall};
private _committed = [_city,teamPlayer,{
    params ["_city"];
    sidesX setVariable [_city,teamPlayer,true];
    garrison setVariable [_city,[],true];
    true
},[_city]] call A3I_fnc_liquidationTransition;
if (!_committed) exitWith {false};
["TaskSucceeded",["",format [localize "STR_notifiers_city_joined",_city,A3A_faction_reb get "name"]]]
    remoteExec ["BIS_fnc_showNotification",teamPlayer];
[Occupants,10,60] remoteExec ["A3A_fnc_addAggression",2];
[_city] call A3A_fnc_mrkUpdate;
[-10,10,_city,false] spawn A3A_fnc_citySupportChange;
if (milAdministrationsX isNotEqualTo [] && {A3A_milAdministrations isNotEqualTo []}) then {
    private _adminMarker = [milAdministrationsX,_city] call BIS_fnc_nearestPosition;
    if (_adminMarker isEqualType "" && {getMarkerPos _adminMarker distance2D getMarkerPos _city < 800}) then {
        private _building = [A3A_milAdministrations,_adminMarker] call BIS_fnc_nearestPosition;
        if (!isNull _building) then {[_building,"CAPTURE"] call SCRT_fnc_location_removeMilAdmin};
    };
};
[{
    params ["_city"];
    {[_city,_x] spawn A3A_fnc_deleteControls} forEach controlsX;
    [] call A3A_fnc_tierCheck;
},[_city],5] call CBA_fnc_waitAndExecute;
true
