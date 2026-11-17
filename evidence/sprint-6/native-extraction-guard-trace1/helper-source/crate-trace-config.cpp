// Diagnostic only: native crate initializer with before/after observations.
class CfgPatches {
    class A3I_crate_trace {
        requiredAddons[] = {"A3I_core", "A3_3DEN"};
        units[] = {}; weapons[] = {}; requiredVersion = 2.22;
    };
};
class CfgFunctions {
    class A3ITrace {
        class Startup {
            class originalInitAmmoBox { file = "\A3\3DEN\Functions\fn_initAmmoBox.sqf"; };
            class observe { file = "\x\a3i\tests\campaign\observe.sqf"; preInit = 1; };
        };
    };
    class 3DEN {
        class Default {
            class initAmmoBox { file = "\x\a3i\tests\campaign\traceInitAmmoBox.sqf"; };
        };
    };
};
