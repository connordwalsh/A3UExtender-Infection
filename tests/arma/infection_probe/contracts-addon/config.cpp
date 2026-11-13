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
    };
    class A3I
    {
        class Originals
        {
            class originalNATOinit { file = "\x\a3i\tests\contracts\fn_originalNATOinit.sqf"; };
        };
        class TestOriginals
        {
            class testOriginalSelectVehicleType
            {
                file = "\x\a3a\addons\core\functions\Garrison\fn_selectVehicleType.sqf";
            };
        };
    };
};
