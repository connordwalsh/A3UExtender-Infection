// Patch only the removed controls. Native labels/actions/layout for every
// remaining category stay intact until its replacement behavior is ready.
class A3A_DefaultDialog;
class A3A_RequestMissionDialog: A3A_DefaultDialog
{
    class Controls
    {
        class MainContent
        {
            class Controls
            {
                class DestroyIcon { onLoad = "_this call A3I_fnc_hideRemovedMissionControl"; };
                class DestroyButton { onLoad = "_this call A3I_fnc_hideRemovedMissionControl"; };
                class RandomIcon { onLoad = "_this call A3I_fnc_hideRemovedMissionControl"; };
                class RandomButton { onLoad = "_this call A3I_fnc_hideRemovedMissionControl"; };
            };
        };
    };
};
class SimpleMenuBig;
class missionMenu: SimpleMenuBig
{
    class Controls
    {
        class destroyButton { onLoad = "_this call A3I_fnc_hideRemovedMissionControl"; };
        class randomButton { onLoad = "_this call A3I_fnc_hideRemovedMissionControl"; };
    };
};
