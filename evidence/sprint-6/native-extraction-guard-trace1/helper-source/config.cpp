// Test addon only: never ship with Infection gameplay builds.
class CfgPatches {
    class A3I_campaign_probe {
        requiredAddons[] = {"A3I_core"};
        units[] = {}; weapons[] = {}; requiredVersion = 2.22;
    };
};
class Extended_PostInit_EventHandlers {
    class A3I_campaign_probe {
        serverInit = "[] execVM '\x\a3i\tests\campaign\run.sqf'";
    };
};
