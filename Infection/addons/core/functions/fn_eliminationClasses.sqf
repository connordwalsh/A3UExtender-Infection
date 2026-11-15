// Owner-approved initial roster. Larger creatures remain excluded while their
// model/lifecycle failures are investigated. This does not spawn any actor.
if (!([west] call A3I_fnc_isActive)) exitWith {[]};
[
    "Zombie_Special_BLUFOR_Screamer",
    "Zombie_Special_BLUFOR_Boomer",
    "Zombie_Special_BLUFOR_Leaper_2"
] select {
    private _cfg = configFile >> "CfgVehicles" >> _x;
    isClass _cfg && {getNumber (_cfg >> "scope") == 2} && {getNumber (_cfg >> "side") == 1}
        && {_x isKindOf ["CAManBase",configFile >> "CfgVehicles"]}
}
