params ["_arguments","_function"];
if (!isServer) exitWith {};
private _siteFunctions = ["a3a_fnc_createairesources","a3a_fnc_createaioutposts","a3a_fnc_createaimilbase","a3a_fnc_createaiairplane","a3a_fnc_createaicontrols","a3a_fnc_createaicities"];
if !(_function isEqualType "" && {toLower _function in _siteFunctions}
    && {_arguments isEqualType []}) exitWith {_this call A3I_fnc_originalScheduler};
private _marker = _arguments param [0,"",[""]];
if (!isNil "sidesX"
    && {[sidesX getVariable [_marker,sideUnknown]] call A3I_fnc_isActive}) exitWith {
    // Infection's budget is authoritative on the server; never select an HC.
    _arguments remoteExec [_function,2];
};
_this call A3I_fnc_originalScheduler
