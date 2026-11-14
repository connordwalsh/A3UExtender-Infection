// The mission can commit immediately after full clearance; road controls do
// not additionally require a surviving Rebel contender for this assignment.
params ["_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {false};
private _target = _record get "target";
if (([_target] call A3I_fnc_liquidationClaim) getOrDefault ["name",""] != _record get "name"
    || {!(([_target] call A3I_fnc_siteClearance) # 0)}) exitWith {false};
switch (_record get "kind") do {
    case "City": {[_target] call A3I_fnc_liquidationCityCapture};
    case "MilAdmin": {[_target] call A3I_fnc_tryCaptureAdministration};
    case "Control": {
        private _committed = [_target,teamPlayer,{
            params ["_target"];
            private _site = A3I_sites get _target;
            _site set ["captured",teamPlayer];
            sidesX setVariable [_target,teamPlayer,true];
            true
        },[_target]] call A3I_fnc_liquidationTransition;
        if (_committed) then {
            ["TaskSucceeded",["","Roadblock Destroyed"]] remoteExec ["BIS_fnc_showNotification",teamPlayer];
            ["TaskFailed",["","Roadblock Lost"]] remoteExec ["BIS_fnc_showNotification",west];
        };
    };
    default {[teamPlayer,_target] call A3A_fnc_markerChange};
};
_record get "outcome" == "won"
