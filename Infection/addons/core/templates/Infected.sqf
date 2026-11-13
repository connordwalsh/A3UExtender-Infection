// Loaded by A3A_fnc_loadFaction after Ultimate's EnemyDefaults.sqf.
// Vehicle pools require the Occupant route overrides before campaign use.
["infectionTemplate", "A3I_Infected"] call _fnc_saveToTemplate;
["name", "Infected"] call _fnc_saveToTemplate;
["spawnMarkerName", "Infected approach"] call _fnc_saveToTemplate;
["flag", "Flag_Red_F"] call _fnc_saveToTemplate;
["flagTexture", "\A3\Data_F\Flags\Flag_red_CO.paa"] call _fnc_saveToTemplate;
["flagMarkerType", "A3I_infected"] call _fnc_saveToTemplate;
["ammobox", "I_supplyCrate_F"] call _fnc_saveToTemplate;
["surrenderCrate", "Box_IND_Wps_F"] call _fnc_saveToTemplate;
["equipmentBox", "Box_AAF_Equip_F"] call _fnc_saveToTemplate;

// No dummy vehicles: unsupported conventional routes must be intercepted.
{
    [_x, []] call _fnc_saveToTemplate;
} forEach [
    "vehiclesBasic", "vehiclesLightUnarmed", "vehiclesLightArmed", "vehiclesTrucks",
    "vehiclesCargoTrucks", "vehiclesAmmoTrucks", "vehiclesRepairTrucks", "vehiclesFuelTrucks",
    "vehiclesMedical", "vehiclesLightAPCs", "vehiclesAPCs", "vehiclesAirborne", "vehiclesIFVs",
    "vehiclesTanks", "vehiclesLightTanks", "vehiclesAA", "vehiclesTransportBoats", "vehiclesGunBoats",
    "vehiclesAmphibious", "vehiclesSDV", "vehiclesPlanesCAS", "vehiclesPlanesAA",
    "vehiclesPlanesTransport", "vehiclesPlanesGunship", "vehiclesPlanesLargeCAS", "vehiclesPlanesLargeAA",
    "vehiclesHelisLight", "vehiclesHelisTransport", "vehiclesHelisLightAttack", "vehiclesHelisAttack",
    "vehiclesAirPatrol", "vehiclesArtillery", "vehiclesMilitiaLightArmed", "vehiclesMilitiaTrucks",
    "vehiclesMilitiaCars", "vehiclesMilitiaAPCs", "vehiclesPolice", "vehiclesDropPod",
    "uavsAttack", "uavsPortable", "staticMGs", "staticAT", "staticAA", "staticMortars", "staticHowitzers",
    "minefieldAT", "minefieldAPERS", "minesAT", "minesAPERS"
];
{
    [_x, ""] call _fnc_saveToTemplate;
} forEach ["vehicleRadar", "vehicleSam", "mortarMagazineHE", "mortarMagazineSmoke", "mortarMagazineFlare", "howitzerMagazineHE"];
["magazines", createHashMap] call _fnc_saveToTemplate;

// Preserve the prepared class's unarmed equipment and use infected identities.
["faces", ["WBK_ZombieFace_blood_1", "WBK_ZombieFace_blood_2", "WBK_ZombieFace_blood_3"]] call _fnc_saveToTemplate;
["voices", ["NoVoice"]] call _fnc_saveToTemplate;
["firstNames", ["Infected"]] call _fnc_saveToTemplate;
["lastNames", ["Survivor"]] call _fnc_saveToTemplate;

// Ultimate's generated groups reference human role names. They resolve to
// prepared infected here, with no medic/engineer/weapon trait added by this file.
private _roles = ["SquadLeader", "Rifleman", "Radioman", "Medic", "Engineer", "ExplosivesExpert",
    "Grenadier", "LAT", "AT", "AA", "MachineGunner", "Marksman", "Sniper", "PatrolSniper", "PatrolSpotter"];
{
    _x params ["_prefix", "_class"];
    {
        [_prefix + "_" + _x, [], [["baseClass", _class, true]], []] call _fnc_saveUnitToTemplate;
    } forEach _roles;
} forEach [
    ["militia", "Zombie_B_Walker_Civ"],
    ["military", "Zombie_B_Shambler_Civ"],
    ["elite", "Zombie_B_RA_Civ"],
    ["SF", "Zombie_B_RA_Civ"]
];
{
    ["police_" + _x, [], [["baseClass", "Zombie_B_Walker_Civ", true]], []] call _fnc_saveUnitToTemplate;
} forEach ["SquadLeader", "Standard"];
{
    ["other_" + _x, [], [["baseClass", "Zombie_B_Walker_Civ", true]], []] call _fnc_saveUnitToTemplate;
} forEach ["Crew", "Official", "Pilot", "Traitor", "Unarmed"];
// No special or largest creature is present in any generic group role.
