missionNamespace getVariable ["A3A_supplyMissionActive",false]
    || {"SUPP" in (missionNamespace getVariable ["A3A_activeTasks",[]])}
    || {(missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 1 == "SUPP"} != -1}
    || {(values (missionNamespace getVariable ["A3I_aidTasks",createHashMap])) findIf {!(_x getOrDefault ["settled",true])} != -1}
