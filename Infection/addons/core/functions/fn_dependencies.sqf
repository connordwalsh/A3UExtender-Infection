/* Return dependency facts without changing any campaign or third-party setting. */
private _requiredPatches = ["WBK_ZombieCreatures", "WebKnight_StarWars_MoveSet"];
private _basicClasses = ["Zombie_B_Walker_Civ", "Zombie_B_Shambler_Civ", "Zombie_B_RA_Civ"];
private _missingPatches = _requiredPatches select { !isClass (configFile >> "CfgPatches" >> _x) };
private _invalidClasses = _basicClasses select {
    private _cfg = configFile >> "CfgVehicles" >> _x;
    !isClass _cfg || {getNumber (_cfg >> "scope") != 2} || {getNumber (_cfg >> "side") != 1}
};
createHashMapFromArray [
    ["available", _missingPatches isEqualTo [] && {_invalidClasses isEqualTo []}],
    ["missingPatches", _missingPatches],
    ["invalidClasses", _invalidClasses],
    ["basicClasses", _basicClasses],
    ["ace", isClass (configFile >> "CfgPatches" >> "ace_main")],
    ["aceMedical", isClass (configFile >> "CfgPatches" >> "ace_medical")]
]
