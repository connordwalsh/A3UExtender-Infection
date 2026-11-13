/* Return Ultimate's [vehicle, crew, infantry] contract without vehicle queries.
   Empty scenery/vehicle slots stay empty; troop-bearing slots become foot groups.
   This builds a virtual roster only. It does not spawn or replenish live AI. */
params [["_data", [], [[]]]];
private _empty = ["", [], []];
if (count _data != 3 || {!((_data # 2) isEqualType "")}) exitWith {
    diag_log format ["[INFECTION] Rejected malformed garrison preference: %1", _data];
    _empty
};
private _preference = toUpper (_data # 2);
if (_preference == "EMPTY") exitWith {_empty};
if !(_preference in ["SQUAD", "GROUP", "AA"]) exitWith {
    diag_log format ["[INFECTION] Unsupported garrison infantry preference: %1", _preference];
    _empty
};
private _faction = missionNamespace getVariable ["A3A_faction_occ", createHashMap];
private _groupTypes = if (_preference == "AA") then {
    [_faction getOrDefault ["groupTierAA", [[], [], []]]] call SCRT_fnc_unit_getTiered
} else {
    private _key = if (_preference == "SQUAD") then {"groupsTierSquads"} else {"groupsTierMedium"};
    private _groups = [_faction, _key] call SCRT_fnc_unit_flattenTier;
    if (_groups isEqualTo []) then {[]} else {selectRandom _groups}
};
// Copy the group so later garrison mutation cannot change the faction template.
["", [], +_groupTypes]
