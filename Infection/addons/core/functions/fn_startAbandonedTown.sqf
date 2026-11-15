params [["_town","",[""]]];
if (!isServer || {isRemoteExecuted} || {!canSuspend} || {!([west] call A3I_fnc_isActive)}
    || {isNil "sidesX"} || {isNil "spawner"} || {!(_town in allMapMarkers)}
    || {!(_town in (missionNamespace getVariable ["citiesX",[]]))}
    || {sidesX getVariable [_town,sideUnknown] != west}
    || {spawner getVariable [_town+"_civ",2] == 2}) exitWith {false};
private _accepted = false;
isNil {
    if (isNil "A3I_abandonedTowns") then {A3I_abandonedTowns = createHashMap};
    if (_town in A3I_abandonedTowns) exitWith {};
    A3I_abandonedTownSerial = (missionNamespace getVariable ["A3I_abandonedTownSerial",0])+1;
    private _record = createHashMapFromArray [["town",_town],["serial",A3I_abandonedTownSerial],
        ["vehicles",[]],["nativeParked",[]],["trafficVehicles",[]],["trafficGroups",[]],
        ["ended",false],["nativeRetired",false]];
    A3I_abandonedTowns set [_town,_record];
    _record set ["script",[_record] spawn A3I_fnc_runAbandonedTown];
    if (isNil "A3I_abandonedTownHandle") then {
        A3I_abandonedTownHandle = [A3I_fnc_abandonedTownTick,1] call CBA_fnc_addPerFrameHandler;
    };
    _accepted = true;
};
_accepted
