class CfgPatches
{
    class A3I_core
    {
        name = "Antistasi Ultimate: Infection";
        author = "Antistasi Ultimate: Infection contributors";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.22;
        requiredAddons[] = {"A3A_core", "A3A_ultimate", "A3A_scrt", "cba_main", "cba_settings"};
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
            class initSettings { preInit = 1; };
            class dependencies {};
            class isActive {};
            class isManagedUnit {};
            class initInfected {};
            class infectedDamageObserved {};
            class infectedKilled {};
            class infectedDeleted {};
            class budget {};
            class spawnObservers {};
            class positionSafety {};
            class findSpawnPosition {};
            class spawnGroup {};
            class adoptReinforcement {};
            class reinforcementEligible {};
            class reinforcementSources {};
            class requestReinforcement {};
            class runReinforcement {};
            class reinforcementWatchdog {};
            class reinforcementTick {};
            class roamingEligible {};
            class roamingBases {};
            class roamingRoute {};
            class startRoaming {};
            class runRoaming {};
            class roamingWatchdog {};
            class counterattackEligible {};
            class counterattackSourceEligible {};
            class counterattackSources {};
            class startCounterattack {};
            class runCounterattack {};
            class counterattackWatchdog {};
            class startSite {};
            class runSite {};
            class cleanupSite {};
            class siteWatchdog {};
            class siteCaptureBlocked {};
            class controlRoster {};
            class runPatrol {};
            class cityRoster {};
            class cityPopulationTarget {};
            class findCitySpawnPosition {};
            class patrolWaypoints {};
            class administrationRoster {};
            class runAdministration {};
            class trackAdministrationDefender {};
            class administrationDefenderEvent {};
            class tryCaptureAdministration {};
            class administrationPositions {};
            class indoorPosition {};
            class administrationAssets {};
            class survivorAction {};
            class requestRescue {};
            class beginRescue {};
            class rescueTick {};
            class tryCaptureControl {};
            class controlResetTick {};
            class elapsedDateMinutes {};
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
            class originalScheduler { file = "\x\a3a\addons\core\functions\Base\fn_scheduler.sqf"; };
            class originalPatrolReinf { file = "\x\a3a\addons\core\functions\CREATE\fn_patrolReinf.sqf"; };
            class originalReinforcementsAI { file = "\x\a3a\addons\core\functions\CREATE\fn_reinforcementsAI.sqf"; };
            class originalAAFroadPatrol { file = "\x\a3a\addons\core\functions\CREATE\fn_AAFroadPatrol.sqf"; };
            class originalSingleAttack { file = "\x\a3a\addons\core\functions\CREATE\fn_singleAttack.sqf"; };
            class originalCreateAIResources { file = "\x\a3a\addons\core\functions\CREATE\fn_createAIResources.sqf"; };
            class originalCreateAIOutposts { file = "\x\a3a\addons\core\functions\CREATE\fn_createAIOutposts.sqf"; };
            class originalCreateAIMilbase { file = "\x\a3a\addons\core\functions\CREATE\fn_createAIMilbase.sqf"; };
            class originalCreateAIAirplane { file = "\x\a3a\addons\core\functions\CREATE\fn_createAIAirplane.sqf"; };
            class originalCreateAIcontrols { file = "\x\a3a\addons\core\functions\CREATE\fn_createAIcontrols.sqf"; };
            class originalCreateAICities { file = "\x\a3a\addons\core\functions\CREATE\fn_createAICities.sqf"; };
            class originalCreateAIMilAdmin { file = "\x\a3a\addons\core\functions\CREATE\fn_createAIMilAdmin.sqf"; };
            class originalRemoveMilAdmin { file = "\x\a3a\addons\scrt\Location\fn_location_removeMilAdmin.sqf"; };
            class originalMarkerChange { file = "\x\a3a\addons\core\functions\Base\fn_markerChange.sqf"; };
            class originalMrkWIN { file = "\x\a3a\addons\core\functions\Base\fn_mrkWIN.sqf"; };
            class originalSurrenderAction { file = "\x\a3a\addons\core\functions\AI\fn_surrenderAction.sqf"; };
        };
    };
    class A3A
    {
        class CREATE
        {
            class NATOinit { file = "\x\a3i\addons\core\overrides\fn_NATOinit.sqf"; };
            class patrolReinf { file = "\x\a3i\addons\core\overrides\fn_patrolReinf.sqf"; };
            class reinforcementsAI { file = "\x\a3i\addons\core\overrides\fn_reinforcementsAI.sqf"; };
            class AAFroadPatrol { file = "\x\a3i\addons\core\overrides\fn_AAFroadPatrol.sqf"; };
            class singleAttack { file = "\x\a3i\addons\core\overrides\fn_singleAttack.sqf"; };
            class createAIResources { file = "\x\a3i\addons\core\overrides\fn_createAIResources.sqf"; };
            class createAIOutposts { file = "\x\a3i\addons\core\overrides\fn_createAIOutposts.sqf"; };
            class createAIMilbase { file = "\x\a3i\addons\core\overrides\fn_createAIMilbase.sqf"; };
            class createAIAirplane { file = "\x\a3i\addons\core\overrides\fn_createAIAirplane.sqf"; };
            class createAIcontrols { file = "\x\a3i\addons\core\overrides\fn_createAIcontrols.sqf"; };
            class createAICities { file = "\x\a3i\addons\core\overrides\fn_createAICities.sqf"; };
            class createAIMilAdmin { file = "\x\a3i\addons\core\overrides\fn_createAIMilAdmin.sqf"; };
        };
        class Base
        {
            class scheduler { file = "\x\a3i\addons\core\overrides\fn_scheduler.sqf"; };
            class markerChange { file = "\x\a3i\addons\core\overrides\fn_markerChange.sqf"; };
            class mrkWIN { file = "\x\a3i\addons\core\overrides\fn_mrkWIN.sqf"; };
        };
        class AI
        {
            class surrenderAction { file = "\x\a3i\addons\core\overrides\fn_surrenderAction.sqf"; };
        };
        class Garrison
        {
            class createGarrisonLine
            {
                file = "\x\a3i\addons\core\overrides\fn_createGarrisonLine.sqf";
            };
        };
    };
    class SCRT
    {
        class Location
        {
            class location_removeMilAdmin { file = "\x\a3i\addons\core\overrides\fn_location_removeMilAdmin.sqf"; };
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
