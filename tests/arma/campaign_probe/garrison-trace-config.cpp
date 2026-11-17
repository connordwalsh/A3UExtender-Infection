// Diagnostic only. Compile the unchanged native receiver under a second name.
#include "config.cpp"
class CfgFunctions {
    class A3ITrace {
        class Casualties {
            class nativeGarrisonUpdate { file = "\x\a3a\addons\core\functions\CREATE\fn_garrisonUpdate.sqf"; };
        };
    };
    class A3A {
        class CREATE {
            class garrisonUpdate { file = "\x\a3i\tests\campaign\traceGarrisonUpdate.sqf"; };
        };
    };
};
