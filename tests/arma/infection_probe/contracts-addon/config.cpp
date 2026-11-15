// ISOLATED TEST HARNESS ONLY. Never include this addon in a gameplay build.
class CfgPatches
{
    class A3I_test_contracts
    {
        requiredAddons[] = {"A3I_core"};
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.22;
    };
};
class CfgFunctions
{
    class A3A
    {
        class Base
        {
            class citySupportChange { file = "\x\a3i\tests\contracts\fn_citySupportChange.sqf"; };
            class addAggression { file = "\x\a3i\tests\contracts\fn_addAggression.sqf"; };
            class zoneCheck { file = "\x\a3i\tests\contracts\fn_zoneCheck.sqf"; };
            class mrkUpdate { file = "\x\a3i\tests\contracts\fn_mrkUpdate.sqf"; };
            class commsMP { file = "\x\a3i\tests\contracts\fn_commsMP.sqf"; };
        };
        class Missions
        {
            class underAttack { file = "\x\a3i\tests\contracts\fn_underAttack.sqf"; };
        };
        class AI
        {
            class vehicleConvoyTravel { file = "\x\a3i\tests\contracts\fn_vehicleConvoyTravel.sqf"; };
            class AIreactOnKill { file = "\x\a3i\tests\contracts\fn_AIreactOnKill.sqf"; };
        };
        class Garrison
        {
            class selectVehicleType { file = "\x\a3i\tests\contracts\fn_selectVehicleType.sqf"; };
        };
        class Ammunition
        {
            class fillLootCrate { file = "\x\a3i\tests\contracts\fn_fillLootCrate.sqf"; };
        };
        class Civilian
        {
            class createResourceCiv { file = "\x\a3i\tests\contracts\fn_createResourceCiv.sqf"; };
        };
        class CREATE
        {
            class crewTypeForVehicle { file = "\x\a3i\tests\contracts\fn_crewTypeForVehicle.sqf"; };
            class cargoSeats { file = "\x\a3i\tests\contracts\fn_cargoSeats.sqf"; };
            class AIVEHinit { file = "\x\a3i\tests\contracts\fn_AIVEHinit.sqf"; };
            class VEHdespawner { file = "\x\a3i\tests\contracts\fn_VEHdespawner.sqf"; };
            class groupDespawner { file = "\x\a3i\tests\contracts\fn_groupDespawner.sqf"; };
        };
    };
    class A3I
    {
        class Core
        {
            class finishInterception { file = "\x\a3i\tests\contracts\fn_finishInterception.sqf"; };
            class interceptionTaskOutcome { file = "\x\a3i\tests\contracts\fn_interceptionTaskOutcome.sqf"; };
            class liquidationMarkerChange { file = "\x\a3i\tests\contracts\fn_liquidationMarkerChange.sqf"; };
            class spawnObservers { file = "\x\a3i\tests\contracts\fn_spawnObservers.sqf"; };
        };
        class Originals
        {
            class originalSelectIntel { file = "\x\a3i\tests\contracts\fn_originalSelectIntel.sqf"; };
            class originalConvoy { file = "\x\a3i\tests\contracts\fn_originalConvoy.sqf"; };
            class originalRequestMissionDialog { file = "\x\a3i\tests\contracts\fn_originalRequestMissionDialog.sqf"; };
            class originalDestroyVehicle { file = "\x\a3i\tests\contracts\fn_originalDestroyVehicle.sqf"; };
            class originalDestroyHeli { file = "\x\a3i\tests\contracts\fn_originalDestroyHeli.sqf"; };
            class originalDestroyAntenna { file = "\x\a3i\tests\contracts\fn_originalDestroyAntenna.sqf"; };
            class originalDestroyArtillery { file = "\x\a3i\tests\contracts\fn_originalDestroyArtillery.sqf"; };
            class originalMissionRequest { file = "\x\a3i\tests\contracts\fn_originalMissionRequest.sqf"; };
            class originalConquestMission { file = "\x\a3i\tests\contracts\fn_originalConquestMission.sqf"; };
            class originalAdministrationMission { file = "\x\a3i\tests\contracts\fn_originalAdministrationMission.sqf"; };
            class originalZombieConquestMission { file = "\x\a3i\tests\contracts\fn_originalZombieConquestMission.sqf"; };
            class originalCompetitiveMission { file = "\x\a3i\tests\contracts\fn_originalCompetitiveMission.sqf"; };
            class originalChooseAttack { file = "\x\a3i\tests\contracts\fn_originalChooseAttack.sqf"; };
            class originalFindAttackTargets { file = "\x\a3i\tests\contracts\fn_originalFindAttackTargets.sqf"; };
            class originalNATOinit { file = "\x\a3i\tests\contracts\fn_originalNATOinit.sqf"; };
            class originalScheduler { file = "\x\a3i\tests\contracts\fn_originalScheduler.sqf"; };
            class originalPatrolReinf { file = "\x\a3i\tests\contracts\fn_originalPatrolReinf.sqf"; };
            class originalReinforcementsAI { file = "\x\a3i\tests\contracts\fn_originalReinforcementsAI.sqf"; };
            class originalAAFroadPatrol { file = "\x\a3i\tests\contracts\fn_originalAAFroadPatrol.sqf"; };
            class originalCreateSupport { file = "\x\a3i\tests\contracts\fn_originalCreateSupport.sqf"; };
            class originalSUPQRFLand { file = "\x\a3i\tests\contracts\fn_originalSUPQRFLand.sqf"; };
            class originalSUPQRFAir { file = "\x\a3i\tests\contracts\fn_originalSUPQRFAir.sqf"; };
            class originalSingleAttack { file = "\x\a3i\tests\contracts\fn_originalSingleAttack.sqf"; };
            class originalCreateAIResources { file = "\x\a3i\tests\contracts\fn_originalCreateAIResources.sqf"; };
            class originalCreateAIOutposts { file = "\x\a3i\tests\contracts\fn_originalCreateAIOutposts.sqf"; };
            class originalCreateAIMilbase { file = "\x\a3i\tests\contracts\fn_originalCreateAIMilbase.sqf"; };
            class originalCreateAIAirplane { file = "\x\a3i\tests\contracts\fn_originalCreateAIAirplane.sqf"; };
            class originalCreateAIcontrols { file = "\x\a3i\tests\contracts\fn_originalCreateAIcontrols.sqf"; };
            class originalCreateAICities { file = "\x\a3i\tests\contracts\fn_originalCreateAICities.sqf"; };
            class originalCreateAIMilAdmin { file = "\x\a3i\tests\contracts\fn_originalCreateAIMilAdmin.sqf"; };
            class originalRemoveMilAdmin { file = "\x\a3i\tests\contracts\fn_originalRemoveMilAdmin.sqf"; };
            class originalMarkerChange { file = "\x\a3i\tests\contracts\fn_originalMarkerChange.sqf"; };
            class originalMrkWIN { file = "\x\a3i\tests\contracts\fn_originalMrkWIN.sqf"; };
            class originalSurrenderAction { file = "\x\a3i\tests\contracts\fn_originalSurrenderAction.sqf"; };
        };
        class TestOriginals
        {
            class testNativeFinishInterception { file = "\x\a3i\addons\core\functions\fn_finishInterception.sqf"; };
            class testNativeInterceptionTaskOutcome { file = "\x\a3i\addons\core\functions\fn_interceptionTaskOutcome.sqf"; };
            class testNativeLiquidationMarkerChange { file = "\x\a3i\addons\core\functions\fn_liquidationMarkerChange.sqf"; };
            class testNativeSpawnObservers { file = "\x\a3i\addons\core\functions\fn_spawnObservers.sqf"; };
            class testNativeCrewTypeForVehicle { file = "\x\a3a\addons\core\functions\CREATE\fn_crewTypeForVehicle.sqf"; };
            class testNativeCargoSeats { file = "\x\a3a\addons\core\functions\CREATE\fn_cargoSeats.sqf"; };
            class testNativeAIVEHinit { file = "\x\a3a\addons\core\functions\CREATE\fn_AIVEHinit.sqf"; };
            class testNativeVEHdespawner { file = "\x\a3a\addons\core\functions\CREATE\fn_VEHdespawner.sqf"; };
            class testNativeVehicleConvoyTravel { file = "\x\a3a\addons\core\functions\AI\fn_vehicleConvoyTravel.sqf"; };
            class testNativeMarkerChange { file = "\x\a3a\addons\core\functions\Base\fn_markerChange.sqf"; };
            class testNativeZoneCheck { file = "\x\a3a\addons\core\functions\Base\fn_zoneCheck.sqf"; };
            class testNativeRemoveMilAdmin { file = "\x\a3a\addons\scrt\Location\fn_location_removeMilAdmin.sqf"; };
            class testOriginalSelectVehicleType
            {
                file = "\x\a3a\addons\core\functions\Garrison\fn_selectVehicleType.sqf";
            };
        };
    };
    class A3A_Logistics
    {
        class Public
        {
            class addLoadAction { file = "\x\a3i\tests\contracts\fn_addLoadAction.sqf"; };
        };
    };
};
