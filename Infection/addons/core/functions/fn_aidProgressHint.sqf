params [["_serial",-1,[0]],["_town","",[""]],["_remaining",0,[0]],["_state","",[""]]];
if (!hasInterface || {isRemoteExecuted && {remoteExecutedOwner != 2}} || {_serial < 0}) exitWith {};
private _last = missionNamespace getVariable ["A3I_aidHintSerial",-1];
if (_serial < _last) exitWith {};
private _header = "Humanitarian Aid";
private _messages = missionNamespace getVariable ["A3A_customHint_MSGs",[]];
private _top = count _messages-1;
if (_state == "stop") exitWith {
    if (_serial == _last && {_top >= 0} && {(_messages # _top # 0) == _header}) then {[false] call A3A_fnc_customHintDismiss};
};
A3I_aidHintSerial = _serial;
private _body = switch (_state) do {
    case "unloading": {format ["Unloading supplies for %1: %2 seconds remaining.",_town,_remaining]};
    case "paused": {format ["Supplies for %1: %2 seconds of unloading remaining.<br/>Drop the package within 40 metres of the town marker, keep a capable Rebel escort within 80 metres, and clear infected within 50 metres.",_town,_remaining]};
    case "delivered": {"The supplies have been distributed."};
    case "failed": {"This delivery mission has failed."};
    default {"This delivery has been cancelled without a penalty."};
};
if (_top >= 0 && {(_messages # _top # 0) == _header}) then {
    (A3A_customHint_MSGs # _top) set [1,parseText _body]; A3A_customHint_UpdateTime = serverTime;
} else {[_header,_body,true] call A3A_fnc_customHint};
