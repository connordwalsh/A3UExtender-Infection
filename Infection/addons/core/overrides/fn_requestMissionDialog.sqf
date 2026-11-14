// The native GUI expands RAN locally, so reject it before native dispatch.
params [["_mode","",[""]],["_params",[],[[]]]];
if ([west] call A3I_fnc_isActive && {_mode == "missionButtonClicked"}
    && {(_params param [0,"RAN"]) in ["DES","RAN"]}) exitWith {};
_this call A3I_fnc_originalRequestMissionDialog
