// Preserve native faction-then-role selection, filtering unsupported definitions
// before creation. Scene bodies never introduce the special-creature families.
if (!([west] call A3I_fnc_isActive) || {isNil "A3A_customUnitTypes"}) exitWith {[]};
private _result = [];
{
    _x params ["_key","_roles"];
    private _faction = missionNamespace getVariable ["A3A_faction_" + _key,createHashMap];
    if !(_faction isEqualType createHashMap) then {continue};
    private _entries = [];
    {
        private _role = _faction getOrDefault [_x,""];
        if !(_role isEqualType "" && {_role != ""}) then {continue};
        private _definition = A3A_customUnitTypes getVariable [_role,[]];
        if !(_definition isEqualType [] && {count _definition == 4}
            && {(_definition # 0) isEqualType []}
            && {(_definition # 1) isEqualType []} && {(_definition # 2) isEqualType []})
            then {continue};
        private _traits = _definition # 1;
        if ((_traits findIf {!(_x isEqualType []) || {count _x < 2}}) != -1) then {continue};
        private _skipLoadout = (_traits findIf {count _x >= 3 && {_x # 2 isEqualTo true}}) != -1;
        if ((_definition # 0) isEqualTo [] && {!_skipLoadout}) then {continue};
        private _baseTraits = _traits select {_x # 0 isEqualTo "baseClass"};
        if (count _baseTraits > 1) then {continue};
        private _base = if (_baseTraits isEqualTo []) then {_definition # 3} else {_baseTraits # 0 # 1};
        // A scalar base ensures placement and native creation use the same body.
        if !(_base isEqualType "" && {isClass (configFile >> "CfgVehicles" >> _base)}
            && {_base isKindOf "CAManBase"}) then {continue};
        if (getText (configFile >> "CfgVehicles" >> _base >> "faction") == "WBK_AI_ZHAMBIES"
            && {!(_base in (A3I_dependencies get "basicClasses"))}) then {continue};
        _entries pushBack [_key,_role,_base];
    } forEach _roles;
    if (_entries isNotEqualTo []) then {_result pushBack _entries};
} forEach [
    ["civ",["unitMan","unitWorker"]],
    ["reb",["unitRifle","unitSL","unitEng","unitLAT","unitSniper","unitMG","unitExp"]],
    ["occ",["unitMilitiaGrunt","unitMilitiaMarksman","unitMilitiaGrenadier","unitMilitiaSniper","unitMilitiaMedic","unitPoliceOfficer"]]
];
_result
