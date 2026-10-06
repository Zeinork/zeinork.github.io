# Wynton Zhang — ROS 2 manipulation code samples

Selected task-method excerpts from completed course-scaffold extensions for simulated Kinova Gen3 Lite manipulation.

- lab05_motion_planner_samples.py: Cartesian segments, collision-scene changes, gripper-position checks.
- lab05_m5_detour_samples.py: baseline/detour experiment using recorded trajectory points and forward kinematics.
- lab06_pick_and_place_samples.py: placement, stacking, grasp checking, and stop-on-miss recovery.

These files are for source inspection. They require their original class context, constants, imports, ROS 2, pymoveit2, and course-provided arm/simulation helpers. They are not standalone runnable scripts. Original scaffolds and instructor helper implementations are intentionally excluded.

The grasp threshold is an implementation choice in the uploaded version; this package does not establish repeated recovery performance or threshold calibration. The project runs in simulation; no physical robot result is claimed.
