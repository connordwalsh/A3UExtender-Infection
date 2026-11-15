// Test addon only: never ship with Infection gameplay builds.
class CfgPatches {
    class A3I_campaign_probe {
        requiredAddons[] = {"A3I_core", "A3_Functions_F_Curator"};
        units[] = {}; weapons[] = {}; requiredVersion = 2.22;
    };
};
// Diagnostic-only alias: records inputs, then calls the installed handler unchanged.
class CfgFunctions {
    class A3ITrace {
        class Startup {
            class originalActivateAddons { file = "\A3\functions_f_curator\Misc\fn_activateAddons.sqf"; };
            class observe { file = "\x\a3i\tests\campaign\observe.sqf"; preInit = 1; };
        };
    };
    class A3_Functions_F_Curator {
        class Misc {
            class activateAddons { file = "\x\a3i\tests\campaign\traceActivateAddons.sqf"; };
        };
    };
};
class Extended_PostInit_EventHandlers {
    class A3I_campaign_probe {
        serverInit = "[] execVM '\x\a3i\tests\campaign\run.sqf'";
    };
};
