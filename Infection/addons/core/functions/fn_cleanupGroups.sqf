// Retain exact retired group references after their controller has released its
// campaign slot. Bodies keep their normal lifetime; only empty groups are deleted.
params [["_groups",[],[[]]]];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
if (canSuspend) exitWith {[A3I_fnc_cleanupGroups,_this] call CBA_fnc_directCall};
if (isNil "A3I_retiredGroups") then {A3I_retiredGroups = []};
{
    if (!(_x isEqualType grpNull) || {isNull _x}) then {continue};
    if (local _x && {units _x isEqualTo []}) then {deleteGroup _x};
    if (!isNull _x) then {A3I_retiredGroups pushBackUnique _x};
} forEach _groups;
if (A3I_retiredGroups isNotEqualTo [] && {isNil "A3I_groupCleanupHandle"}) then {
    A3I_groupCleanupHandle = [A3I_fnc_cleanupGroupTick,0.5] call CBA_fnc_addPerFrameHandler;
};
