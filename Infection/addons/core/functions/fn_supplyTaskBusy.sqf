"LOG" in (missionNamespace getVariable ["A3A_activeTasks",[]])
    || {(missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 1 == "LOG"} != -1}
    || {(values (missionNamespace getVariable ["A3I_supplyTasks",createHashMap]))
        findIf {!(_x getOrDefault ["settled",true])} != -1}
