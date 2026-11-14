// Direct native entry. Political fallback belongs only to resourcecheck's
// support-qualified request, never to an arbitrary direct mission call.
private _side = _this param [0,sideUnknown,[sideUnknown]];
if (!([_side] call A3I_fnc_isActive)) exitWith {_this call A3I_fnc_originalTownBattle};
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {};
private _town = _this param [1,"",[""]];
// The old outpost argument cannot authorize a distant launch. Choose from the
// approved nearby towns/permanent sites through the controller's source policy.
[_town] call A3I_fnc_startLiberation
