// Internal package/progress record. No public task, reward or package creation.
params [["_name","",[""]],["_marker","",[""]],["_package",objNull,[objNull]],
    ["_deadline",0,[0]],["_difficult",false,[false]]];
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}) exitWith {createHashMap};
if (canSuspend) exitWith {[A3I_fnc_createAidLedger,_this] call CBA_fnc_directCall};
if (_name == "" || {isNull _package} || {!alive _package} || {!local _package}
    || {typeOf _package != "Land_FoodSacks_01_cargo_brown_F"}
    || {!isNil {_package getVariable "A3I_aidOwner"}} || {!finite _deadline} || {_deadline <= time}
    || {isNil "sidesX"} || {isNil "teamPlayer"}
    || {!(_marker in (missionNamespace getVariable ["citiesX",[]]))}
    || {!(_marker in allMapMarkers)} || {sidesX getVariable [_marker,sideUnknown] != west})
    exitWith {createHashMap};
if (isNil "A3I_aidLedgers") then {A3I_aidLedgers = createHashMap};
if (_name in A3I_aidLedgers) exitWith {createHashMap};
A3I_aidSerial = (missionNamespace getVariable ["A3I_aidSerial",0]) + 1;
private _serial = A3I_aidSerial;
private _record = createHashMapFromArray [["name",_name],["serial",_serial],["marker",_marker],
    ["package",_package],["deadline",_deadline],["requiredSeconds",[180,90] select _difficult],
    ["unloadedSeconds",0],["lastCheck",time],["wasEligible",false],
    ["outcome","pending"],["reason",""],["settledAt",-1]];
A3I_aidLedgers set [_name,_record];
_package setVariable ["A3I_aidOwner",[_name,_serial]];
if (isNil "A3I_aidLedgerHandle") then {
    A3I_aidLedgerHandle = [{
        {[_y] call A3I_fnc_updateAidLedger} forEach A3I_aidLedgers;
        if ((values A3I_aidLedgers findIf {_x get "outcome" == "pending"}) == -1) then {
            [_this # 1] call CBA_fnc_removePerFrameHandler; A3I_aidLedgerHandle = nil;
        };
    },1] call CBA_fnc_addPerFrameHandler;
};
_record
