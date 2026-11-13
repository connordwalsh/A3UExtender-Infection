/* Side-specific guard for every subsequent Occupant override. */
params [["_side", west, [west]]];
if (_side != west) exitWith {false};
private _faction = missionNamespace getVariable ["A3A_faction_occ", createHashMap];
if !(_faction isEqualType createHashMap) exitWith {false};
(_faction getOrDefault ["infectionTemplate", ""]) isEqualTo "A3I_Infected"
    && {(missionNamespace getVariable ["A3I_dependencies", createHashMap]) getOrDefault ["available", false]}
