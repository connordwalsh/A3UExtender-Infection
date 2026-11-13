// Called in the template fixture's scope; use its _check logger and loaded faction.
private _savedFaction = A3A_faction_occ;
private _savedDependencies = +A3I_dependencies;
private _originalSelector = A3A_fnc_selectVehicleType;
private _fixtureGarrison = [true] call A3A_fnc_createNamespace;
private _fixtureSides = [true] call A3A_fnc_createNamespace;
garrison = _fixtureGarrison;
sidesX = _fixtureSides;
debug = false;
plusGarrison = true;
private _types = ["Airport", "MilitaryBase", "Outpost", "City", "Other"];
call A3A_fnc_initPreference;
private _preferences = [];
{_preferences append (garrison getVariable (_x + "_preference"))} forEach _types;
["garrison_preferences_present", count _preferences == 25, [count _preferences]] call _check;
private _isFootLine = {
    params ["_line"];
    _line isEqualType [] && {count _line == 3} && {_line # 0 isEqualTo ""}
        && {_line # 1 isEqualTo []} && {_line # 2 isEqualType []}
        && {(_line # 2) findIf {isNil {A3A_customUnitTypes getVariable _x}} == -1}
};
A3I_test_vehicleQueries = 0;
A3A_fnc_selectVehicleType = {A3I_test_vehicleQueries = A3I_test_vehicleQueries + 1; "C_Offroad_01_F"};
{
    _x params ["_war", "_prefix"];
    tierWar = _war;
    private _bad = [];
    {
        private _preference = _x;
        private _line = [_preference, west] call A3A_fnc_createGarrisonLine;
        private _shouldBeEmpty = toUpper (_preference # 2) == "EMPTY";
        private _valid = [_line] call _isFootLine;
        if (_valid) then {
            _valid = ((_line # 2) isEqualTo []) isEqualTo _shouldBeEmpty;
            if (!_shouldBeEmpty) then {
                _valid = _valid && {(_line # 2) findIf {_x find ("loadouts_occ_" + _prefix + "_") != 0} == -1};
            };
        };
        if (!_valid) then {_bad pushBack [_preference, _line]};
    } forEach _preferences;
    ["garrison_lines_war" + str _war, _bad isEqualTo [], _bad] call _check;
} forEach [[1,"militia"], [5,"military"], [8,"elite"]];
plusGarrison = false;
private _badWeighted = [];
{
    tierWar = _x;
    {
        private _line = [_x, west] call A3A_fnc_createGarrisonLine;
        if !([_line] call _isFootLine) then {_badWeighted pushBack [tierWar, _x, _line]};
    } forEach _preferences;
} forEach [1,5,10];
["garrison_weighted_tiers", _badWeighted isEqualTo [], _badWeighted] call _check;
["garrison_no_vehicle_queries", A3I_test_vehicleQueries == 0, [A3I_test_vehicleQueries]] call _check;
A3A_fnc_selectVehicleType = _originalSelector;

private _invalidResults = [[], ["LAND_LIGHT",0], ["LAND_LIGHT",0,23], ["LAND_LIGHT",0,"UNKNOWN"]] apply {
    [_x] call A3I_fnc_createFootGarrisonLine
};
["garrison_invalid_input", _invalidResults findIf {!(_x isEqualTo ["",[],[]])} == -1, _invalidResults] call _check;
// A minimal ordinary faction makes pass-through observable without random choices.
private _controlFaction = createHashMapFromArray [
    ["vehiclesLightArmed", []], ["vehiclesLightUnarmed", ["C_Offroad_01_F"]],
    ["vehiclesTanks", []], ["vehiclesAA", []]
];
A3A_faction_inv = +_controlFaction;
private _controlArgs = [["LAND_LIGHT",0,"EMPTY"], east];
private _native = _controlArgs call A3I_fnc_originalCreateGarrisonLine;
private _wrapped = _controlArgs call A3A_fnc_createGarrisonLine;
["garrison_invader_passthrough", _native isEqualTo ["C_Offroad_01_F",[],[]] && {_wrapped isEqualTo _native}, [_native, _wrapped]] call _check;
A3A_faction_occ = +_controlFaction;
_controlArgs set [1, west];
_native = _controlArgs call A3I_fnc_originalCreateGarrisonLine;
_wrapped = _controlArgs call A3A_fnc_createGarrisonLine;
["garrison_normal_occupant_passthrough", _wrapped isEqualTo _native && {_native # 0 == "C_Offroad_01_F"}, [_native, _wrapped]] call _check;
A3A_faction_occ set ["infectionTemplate", "A3I_Infected"];
A3I_dependencies set ["available", false];
_wrapped = _controlArgs call A3A_fnc_createGarrisonLine;
["garrison_missing_dependency_passthrough", _wrapped isEqualTo _native, [_wrapped]] call _check;
A3A_faction_occ = _savedFaction;
A3I_dependencies = _savedDependencies;

// Real initial-roster and reinforcement-ratio consumers accept the foot lines.
plusGarrison = true;
tierWar = 1;
airportsX = ["a3i_contract_Airport"];
milbases = ["a3i_contract_MilitaryBase"];
outposts = ["a3i_contract_Outpost"];
reinforceMarkerOccupants = [];
reinforceMarkerInvaders = [];
canReinforceOccupants = [];
canReinforceInvaders = [];
private _badRosters = [];
{
    private _marker = "a3i_contract_" + _x;
    sidesX setVariable [_marker, west];
    [[_marker], _x, [1,1,0]] call A3A_fnc_createGarrison;
    private _rows = garrison getVariable (_marker + "_garrison");
    private _requested = garrison getVariable (_marker + "_requested");
    private _count = count (garrison getVariable (_x + "_preference"));
    private _ratio = [_marker] call A3A_fnc_getGarrisonRatio;
    if (count _rows != _count || {count _requested != _count}
        || {(_rows + _requested) findIf {!([_x] call _isFootLine)} != -1}
        || {_ratio < 0 || {_ratio > 1}}) then {
        _badRosters pushBack [_x, _rows, _requested, _ratio];
    };
} forEach _types;
["garrison_initial_rosters", _badRosters isEqualTo [], _badRosters] call _check;
deleteVehicle _fixtureGarrison;
deleteVehicle _fixtureSides;
garrison = nil;
sidesX = nil;
A3I_test_vehicleQueries = nil;
