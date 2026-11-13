/* Validated native cell/crate indices. Unknown building layouts use their own
   engine building positions; no guessed room indices or center fallback.
   [building] -> [survivor candidates, crate candidates, layout source]. */
params ["_building"];
if (isNull _building || {!alive _building}) exitWith {[[],[],"unavailable"]};
private _positions = [_building] call BIS_fnc_buildingPositions;
private _indices = switch (toLower typeOf _building) do {
    case "land_zachytka": {[[43,44,53,54,55,59,61],[64]]};
    case "land_policestation_01_f": {[[0,4],[6]]};
    case "land_i_barracks_v1_f";
    case "land_barracks_01_dilapidated_f";
    case "land_barracks_01_grey_f";
    case "land_barracks_01_camo_f";
    case "land_i_barracks_v2_f";
    case "land_u_barracks_v2_f";
    case "land_vn_i_barracks_v1_f";
    case "land_vn_barracks_01_dilapidated_f";
    case "land_vn_barracks_01_grey_f";
    case "land_vn_barracks_01_camo_f";
    case "land_vn_i_barracks_v2_f": {[[15,16,48,49],[11,12,21,22,23,29]]};
    case "land_gm_euro_office_02": {[[1,2,3,4],[12,49,50]]};
    default {[]};
};
private _source = "mapped";
if (_indices isEqualTo []) then {
    _source = "engine_positions";
    private _all = [];
    for "_index" from 0 to (((count _positions) min 64) - 1) do {_all pushBack _index};
    _indices = [_all,_all];
};
private _resolved = _indices apply {
    (_x select {_x >= 0 && {_x < count _positions}}) apply {_positions # _x}
};
[_resolved # 0,_resolved # 1,_source]
