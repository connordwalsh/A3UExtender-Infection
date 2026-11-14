// Local native capture event: preserve the first decisive ownership transition,
// even if another side retakes the marker before the scheduled worker wakes.
params ["_target","_winner"];
if (!isServer || {isRemoteExecuted}) exitWith {};
if !(_winner in [teamPlayer,west]) exitWith {};
if (sidesX getVariable [_target,sideUnknown] != _winner) exitWith {};
{
    if (_y get "target" == _target && {_y get "outcome" == "pending"}) then {
        _y set ["outcome",if (dateToNumber date > _y get "deadline") then {"timeout"}
            else {["lost_race","won"] select (_winner == teamPlayer)}];
        [_y] call A3I_fnc_finishCompetitiveMission;
    };
} forEach (missionNamespace getVariable ["A3I_competitiveMissions",createHashMap]);
