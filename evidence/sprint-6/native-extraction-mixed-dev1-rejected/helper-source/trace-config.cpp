// Opt-in diagnostic helper; does not start or save a campaign.
class CfgPatches {
    class A3I_campaign_trace {
        requiredAddons[] = {"A3I_core", "A3_Functions_F_Curator"};
        units[] = {}; weapons[] = {}; requiredVersion = 2.22;
    };
};
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
