// Attach before preparation, so interrupted spawn workers cannot strand a claim.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_watchInterceptionLifecycle,_this] call CBA_fnc_directCall};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_interceptions",createHashMap]) getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]
    || {_record getOrDefault ["lifecycleHandle",-1] >= 0}
    || {_record getOrDefault ["retired",true]}) exitWith {false};
_record set ["lifecycleHandle",[A3I_fnc_interceptionLifecycleTick,0.5,
    [_name,_record get "serial"]] call CBA_fnc_addPerFrameHandler];
true
