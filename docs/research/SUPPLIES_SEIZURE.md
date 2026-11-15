# Supplies Seizure adaptation

The owner requests recovery of ammunition, fuel or repair trucks from infected
territory to HQ or Rebel-held permanent sites. Delivered trucks remain usable.
This replaces the requested Logistics category, including its bank, salvage,
airdrop and crash-site variants; ordinary campaigns must retain native dispatch.

## Pinned source findings

Ultimate 12.4.2 commit c7c8247672ed5e7d4aa317d47efb371c41de4e7d:

- Missions/fn_LOG_Ammo.sqf selects an Occupant ammunition truck and conventional
  escorts. Infection's empty conventional pools cannot provide them. Its two
  independent settlement conditions can award success for a destroyed truck,
  including after a timeout. Neither behavior fits actual truck recovery.
- Native HQ delivery uses 100 metres. Infection's tested deliveryDestination
  extends this to the six owner-approved permanent-site types and current
  ownership. Towns and administrations are excluded.
- CREATE/fn_AIVEHinit.sqf installs useful capture/logistics hooks but initializes
  faction ownership. Enemy ownership charges army pools on capture/destruction;
  CIV ownership charges a theft penalty. Native skin initialization requires
  a compiled faction, so sideUnknown cannot be supplied directly.
- CREATE/fn_vehKilledOrCaptured.sqf reads current ownerSide at capture, changes it
  to the Rebels and terminates a pending vehicle despawner. Its economic branches
  exclude sideUnknown. EventHandler/fn_vehicleDeletedEH.sqf also excludes neutral
  abandoned assets from enemy refunds/charges.
- CREATE/fn_VEHdespawner.sqf returns immediately for Rebel-owned vehicles.

## Asset implementation

supplyTruckClasses uses the selected Invader template's declared ammunition,
fuel and repair pools, filtering absent/invalid/non-car/UAV entries while keeping
native selection weights. If no suitable configured entry exists, vanilla
Tempest/Zamak service trucks provide the approved minimal-mod stand-ins. This
uses optional faction data without making a Russian equipment mod mandatory.

createSupplyTruck creates an empty recoverable service truck at a validated,
unobserved outdoor location. It refuses incomplete campaign setup and remote
requests. In one unscheduled call, native civilian initialization installs the
capture/logistics hooks and ownership becomes neutral. No infected crew, army
cost, new loot or automatic vehicle despawner is introduced. The truck starts
with its native service contents and is unlocked. Ambient damaged vehicles remain
a separate feature. The eventual mission controller owns retention and cleanup.

## Evidence and remaining work

Dev1 passes all 35 corrected focused engine checks, 11 actual missing-dependency
checks, packaging and three parser tests without engine/SQF errors. Sixteen
startup/dependency notices were reviewed. All 184 production inputs and the PBO
match after execution. Both test servers exited.

The first run remains REJECTED despite all 35 runtime assertions passing:
the claimed-truck retention check called the shared despawner stub, which raised
an undefined-variable error instead of exercising native retention. The corrected fixture calls a separately compiled native function and now passes
without errors. Production code is unchanged. The rejected report is
supply-trucks-rejected-1.json; the accepted report is supply-trucks-engine.json.
Build and absent-dependency reports are recorded alongside them. Artifact
@Infection_SupplyTrucks_Dev1, SHA-256
`af23a7e871d695b3d6c305780e090fed84ea89ae068f0d48f916c24cf37c28e8`.

The first controller increment now passes 43 focused checks and eleven actual
missing-dependency checks. It provides bounded parking, guarded creation, native
tasks, delivery/destruction/deadline settlement, once-only native rewards, save
registration and observer-safe asset/task retirement. Public/direct/intel/
civilian routes and connected play remain unfinished. The owner confirmed that Rebel or Russian capture after the truck exists does
not cancel recovery. Its delivery, destruction or original deadline resolves the
mission. The owner confirmed fuel trucks only in towns; permanent sites permit all three
service kinds. Capturing the permanent source site counts as delivery if the
truck remains within its now-friendly boundary. That specific captured-source
case will receive an explicit focused test before integration. The usable truck contract is separate from currently unanswered
Extraction survivor disposition. No Computer Use or manual-install changes.


## Controller evidence boundary

The 43-check controller run uses actual empty trucks, native tasks, FIA resources,
army timing rewards, native capture and save-list registration. Travel and
deadlines are injected. The result has no engine/SQF errors and 18 reviewed
warnings: 16 startup notices and two missing-fixture-commander income targets.
All 194 production inputs and the PBO match the frozen manifest; both completed
servers exited. SupplyTask Dev1 SHA-256:
`47ec4609d92043cd7ee6bd7912d1e36c7fbe87b9d295b5eabdb6e2a1368d8f8d`.

Normal/difficult durations use 60/30 minutes and native 1x/2x LOG rewards.
Destruction and timeout fail; missing/reassigned assets or interrupted setup
cancel without mission rewards. Once spawned, source ownership never cancels
recovery. A delivered or previously captured Rebel truck is retained; an
unclaimed failed asset waits while occupied, attached/towed, or near observers.
Task metadata retires independently using the native 20-minute average window.
The controller does not create conventional guards; existing infected site/town
forces remain responsible for their location.

This evidence does not establish real terrain travel, optional faction packs,
ACE, connected driving/towing, player rewards, garage/disk campaign saves or
full mission acceptance. No Computer Use or manual-install changes.
