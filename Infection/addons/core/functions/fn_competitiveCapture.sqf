// Local native capture event: preserve the first decisive ownership transition,
// even if another side retakes the marker before the scheduled worker wakes.
params [["_target","",[""]],["_winner",sideUnknown,[sideUnknown]]];
if (!isServer) exitWith {};
if (canSuspend) exitWith {[A3I_fnc_competitiveCapture,_this] call CBA_fnc_directCall};
if !(_winner in [teamPlayer,west]) exitWith {};
if (sidesX getVariable [_target,sideUnknown] != _winner) exitWith {};
{
    if (_y get "target" == _target && {_y get "outcome" == "pending"}) then {
        _y set ["outcome",if (dateToNumber date > _y get "deadline") then {"timeout"}
            else {["lost_race","won"] select (_winner == teamPlayer)}];
        // Native markerChange can inherit a remote zoneCheck/mrkWIN caller.
        // Freeze the verified ownership result now, then settle on a local frame.
        // A remote claim alone cannot change the authoritative sidesX value.
        [{_this call A3I_fnc_finishCompetitiveMission},[_y]] call CBA_fnc_execNextFrame;
    };
} forEach (missionNamespace getVariable ["A3I_competitiveMissions",createHashMap]);
