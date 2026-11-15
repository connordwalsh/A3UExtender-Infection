params [["_package",objNull,[objNull]]];
if (!hasInterface || {isNull _package} || {!(_package getVariable ["A3I_aidPackage",false])}
    || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
if (!isNil {_package getVariable "A3I_aidInfoAction"}) exitWith {};
private _id = _package addAction ["Delivery information", {
    private _data = (_this # 0) getVariable ["A3I_aidDisplay",[]];
    if (count _data == 4) then {_data call A3I_fnc_aidProgressHint};
},nil,0,false,true,"","isPlayer _this && alive _target",4];
_package setVariable ["A3I_aidInfoAction",_id];
