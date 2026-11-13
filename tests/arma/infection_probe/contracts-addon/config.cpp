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
        };
        class Missions
        {
            class underAttack { file = "\x\a3i\tests\contracts\fn_underAttack.sqf"; };
        };
        class AI
        {
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
            class VEHdespawner { file = "\x\a3i\tests\contracts\fn_VEHdespawner.sqf"; };
        };
    };
    class A3I
    {
        class Originals
        {
            class originalNATOinit { file = "\x\a3i\tests\contracts\fn_originalNATOinit.sqf"; };
            class originalScheduler { file = "\x\a3i\tests\contracts\fn_originalScheduler.sqf"; };
            class originalCreateAIResources { file = "\x\a3i\tests\contracts\fn_originalCreateAIResources.sqf"; };
            class originalCreateAIOutposts { file = "\x\a3i\tests\contracts\fn_originalCreateAIOutposts.sqf"; };
            class originalCreateAIMilbase { file = "\x\a3i\tests\contracts\fn_originalCreateAIMilbase.sqf"; };
            class originalCreateAIAirplane { file = "\x\a3i\tests\contracts\fn_originalCreateAIAirplane.sqf"; };
            class originalMarkerChange { file = "\x\a3i\tests\contracts\fn_originalMarkerChange.sqf"; };
            class originalMrkWIN { file = "\x\a3i\tests\contracts\fn_originalMrkWIN.sqf"; };
            class originalSurrenderAction { file = "\x\a3i\tests\contracts\fn_originalSurrenderAction.sqf"; };
        };
        class TestOriginals
        {
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
