// Includes hidden preparation claims before native CONVOY registration exists.
"CONVOY" in (missionNamespace getVariable ["A3A_activeTasks",[]])
    || {(missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 1 == "CONVOY"} >= 0}
    || {(values (missionNamespace getVariable ["A3I_interceptions",createHashMap]))
        findIf {!(_x getOrDefault ["settled",false])} >= 0}
