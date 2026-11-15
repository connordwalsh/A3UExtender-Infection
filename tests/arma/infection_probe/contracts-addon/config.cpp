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
            class originalDialogCivFinished { file = "\x\a3i\tests\contracts\fn_originalDialogCivFinished.sqf"; };
            class originalRepairAntenna { file = "\x\a3i\tests\contracts\fn_originalRepairAntenna.sqf"; };
            class originalRESShipwreck { file = "\x\a3i\tests\contracts\fn_originalRESShipwreck.sqf"; };
            class originalRESInformer { file = "\x\a3i\tests\contracts\fn_originalRESInformer.sqf"; };
            class originalRESRefugees { file = "\x\a3i\tests\contracts\fn_originalRESRefugees.sqf"; };
            class originalRESPrisoners { file = "\x\a3i\tests\contracts\fn_originalRESPrisoners.sqf"; };
            class originalRESDeserters { file = "\x\a3i\tests\contracts\fn_originalRESDeserters.sqf"; };
            class originalRIVRESPrisoners { file = "\x\a3i\tests\contracts\fn_originalRIVRESPrisoners.sqf"; };

            class originalSelectIntel { file = "\x\a3i\tests\contracts\fn_originalSelectIntel.sqf"; };
            class originalConvoy { file = "\x\a3i\tests\contracts\fn_originalConvoy.sqf"; };
            class originalRequestMissionDialog { file = "\x\a3i\tests\contracts\fn_originalRequestMissionDialog.sqf"; };
            class originalDestroyVehicle { file = "\x\a3i\tests\contracts\fn_originalDestroyVehicle.sqf"; };
            class originalDestroyHeli { file = "\x\a3i\tests\contracts\fn_originalDestroyHeli.sqf"; };
            class originalDestroyAntenna { file = "\x\a3i\tests\contracts\fn_originalDestroyAntenna.sqf"; };
            class originalDestroyArtillery { file = "\x\a3i\tests\contracts\fn_originalDestroyArtillery.sqf"; };
            class originalASAmbush { file = "\x\a3i\tests\contracts\fn_originalASAmbush.sqf"; };
            class originalASOfficial { file = "\x\a3i\tests\contracts\fn_originalASOfficial.sqf"; };
            class originalASSmasher { file = "\x\a3i\tests\contracts\fn_originalASSmasher.sqf"; };
            class originalASspecOP { file = "\x\a3i\tests\contracts\fn_originalASspecOP.sqf"; };
            class originalASTraitor { file = "\x\a3i\tests\contracts\fn_originalASTraitor.sqf"; };
            class originalASZombies { file = "\x\a3i\tests\contracts\fn_originalASZombies.sqf"; };
            class originalRIVASTraitor { file = "\x\a3i\tests\contracts\fn_originalRIVASTraitor.sqf"; };
            class testEliminationNativeSupport { file = "\x\a3a\addons\core\functions\Base\fn_citySupportChange.sqf"; };
            class originalSUPPSupplies { file = "\x\a3i\tests\contracts\fn_originalSUPPSupplies.sqf"; };
            class originalRIVSUPPSalvage { file = "\x\a3i\tests\contracts\fn_originalRIVSUPPSalvage.sqf"; };
            class originalLOGAmmo { file = "\x\a3i\tests\contracts\fn_originalLOGAmmo.sqf"; };
            class originalLOGBank { file = "\x\a3i\tests\contracts\fn_originalLOGBank.sqf"; };
            class originalLOGSalvage { file = "\x\a3i\tests\contracts\fn_originalLOGSalvage.sqf"; };
            class originalLOGAirdrop { file = "\x\a3i\tests\contracts\fn_originalLOGAirdrop.sqf"; };
            class originalLOGCrashsite { file = "\x\a3i\tests\contracts\fn_originalLOGCrashsite.sqf"; };
            class originalLOGHelicrash { file = "\x\a3i\tests\contracts\fn_originalLOGHelicrash.sqf"; };
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
            class testNativeCitySupportChange { file = "\x\a3a\addons\core\functions\Base\fn_citySupportChange.sqf"; };
            class testNativeAddAggression { file = "\x\a3a\addons\core\functions\Base\fn_addAggression.sqf"; };
            class testNativeAddLoadAction { file = "\x\a3a\addons\logistics\Public\fn_addLoadAction.sqf"; };
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
