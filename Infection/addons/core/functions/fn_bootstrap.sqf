// Loading the addon alone does not activate Infection or alter normal factions.
A3I_dependencies = call A3I_fnc_dependencies;
A3I_version = "0.1.0-dev";
diag_log format ["[INFECTION] addon=%1 dependencies=%2", A3I_version, A3I_dependencies];
if !(A3I_dependencies get "available") then {
    diag_log "[INFECTION] Infected faction unavailable: load Zombies and Creatures and Improved Melee System. Normal factions remain available.";
};
