class CfgPatches
{
    class A3I_core
    {
        name = "Antistasi Ultimate: Infection";
        author = "Antistasi Ultimate: Infection contributors";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.22;
        requiredAddons[] = {"A3A_core", "A3A_ultimate", "cba_main"};
        version = 0.1;
        versionStr = "0.1.0-dev";
        A3A_compatibility[] = {12, 4};
    };
};

class CfgFunctions
{
    class A3I
    {
        tag = "A3I";
        class Core
        {
            file = "\x\a3i\addons\core\functions";
            class bootstrap { preInit = 1; };
            class dependencies {};
            class isActive {};
            class isManagedUnit {};
            class initInfected {};
            class infectedDamageObserved {};
            class infectedKilled {};
            class infectedDeleted {};
        };
        class Garrison
        {
            file = "\x\a3i\addons\core\functions";
            class createFootGarrisonLine {};
            class originalCreateGarrisonLine
            {
                file = "\x\a3a\addons\core\functions\Garrison\fn_createGarrisonLine.sqf";
            };
        };
        class Originals
        {
            class originalNATOinit
            {
                file = "\x\a3a\addons\core\functions\CREATE\fn_NATOinit.sqf";
            };
        };
    };
    class A3A
    {
        class CREATE
        {
            class NATOinit { file = "\x\a3i\addons\core\overrides\fn_NATOinit.sqf"; };
        };
        class Garrison
        {
            class createGarrisonLine
            {
                file = "\x\a3i\addons\core\overrides\fn_createGarrisonLine.sqf";
            };
        };
    };
};

class CfgMarkers
{
    class flag_NATO;
    class A3I_infected : flag_NATO
    {
        name = "Infected";
        icon = "\A3\Data_F\Flags\Flag_red_CO.paa";
        texture = "\A3\Data_F\Flags\Flag_red_CO.paa";
    };
};

class A3A
{
    class Templates
    {
        class Vanilla_Base;
        class A3I_Infected : Vanilla_Base
        {
            side = "Occ";
            name = "Infection: infected Occupants";
            description = "WebKnight infected on BLUFOR. Requires a new Infection campaign.";
            basepath = "\x\a3i\addons\core\templates";
            file = "Infected";
            requiredAddons[] = {"WBK_ZombieCreatures", "WebKnight_StarWars_MoveSet"};
            flagTexture = "\A3\Data_F\Flags\Flag_red_CO.paa";
            maps[] = {};
            climate[] = {"arid", "arctic", "temperate", "tropical"};
            // Never silently replace the player's normal Occupant selection.
            priority = -10;
            equipFlags[] = {"vanilla"};
        };
    };
};
