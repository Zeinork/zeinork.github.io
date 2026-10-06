# Task-method excerpts from m5_detour.py
# Requires the original class context and ROS 2 / MoveIt helper APIs.
# Not a standalone executable. Supplied framework code is omitted.

class TaskMethodSamples:
    def run(self) -> None:
        start = HOME
        goal = [0.90, 0.55, 2.10, -1.10, -0.90, -0.60]

        box_size = (0.08, 0.08, 0.08)
        path_fraction = 0.50

        self.pen.up()
        self.moveit2.remove_collision_object("detour_box")
        self.moveit2.remove_collision_object("blocker")
        time.sleep(1.0)
        self.pen.clear()

        try:
            self.get_logger().info("Moving to the starting configuration.")
            if not self.move_to_joints(start):
                return

            # First motion: no obstacle, blue trail.
            self.pen.set_color(0.1, 0.3, 0.9)
            self.pen.down()

            started = time.time()
            baseline_ok = self.move_to_joints(goal)
            baseline_duration = time.time() - started
            baseline_attempts = self.last_attempts
            baseline_trajectory = self.last_trajectory

            self.pen.up()

            self.get_logger().info(
                f"NO OBSTACLE: success={baseline_ok}, "
                f"planning_attempts={baseline_attempts}, "
                f"duration={baseline_duration:.2f} s"
            )

            if not baseline_ok:
                self.get_logger().error(
                    "The baseline failed. Fix it before adding an obstacle."
                )
                return

            # Locate an interior point of the trajectory just executed.
            points = baseline_trajectory.points
            if len(points) < 3:
                self.get_logger().error(
                    "Too few trajectory points to choose an interior point."
                )
                return

            index = int((len(points) - 1) * path_fraction)
            index = max(1, min(index, len(points) - 2))

            positions_by_name = dict(zip(
                baseline_trajectory.joint_names,
                points[index].positions,
            ))
            middle_joints = [
                positions_by_name[name] for name in ARM_JOINTS
            ]

            middle_pose = self.moveit2.compute_fk(
                joint_state=middle_joints
            )

            if middle_pose is None:
                self.get_logger().error(
                    "Could not calculate the obstacle position."
                )
                return

            p = middle_pose.pose.position
            box_position = (p.x, p.y, p.z)

            # Return before adding the box. Do not draw the return trip.
            self.get_logger().info("Returning to the same start, pen up.")
            if not self.move_to_joints(start):
                return

            self.moveit2.add_collision_box(
                id="detour_box",
                size=box_size,
                position=box_position,
                quat_xyzw=(0.0, 0.0, 0.0, 1.0),
                frame_id="base_link",
            )
            time.sleep(1.0)

            self.get_logger().info(
                f"Box center: x={p.x:.3f}, y={p.y:.3f}, z={p.z:.3f}; "
                f"size={box_size} m"
            )

            # Second motion: same start and goal, red trail.
            self.pen.set_color(0.9, 0.1, 0.1)
            self.pen.down()

            started = time.time()
            detour_ok = self.move_to_joints(goal)
            detour_duration = time.time() - started
            detour_attempts = self.last_attempts

            self.pen.up()

            self.get_logger().info(
                f"WITH OBSTACLE: success={detour_ok}, "
                f"planning_attempts={detour_attempts}, "
                f"duration={detour_duration:.2f} s"
            )

            if detour_ok:
                self.get_logger().info(
                    "Both motions succeeded. Check that the red trail "
                    "visibly avoids the box and differs from the blue trail."
                )
            else:
                self.get_logger().warn(
                    "Detour failed. Check whether the box blocks the start, "
                    "goal, or all routes; reduce or reposition it."
                )

            self.get_logger().info(
                "SCREENSHOT NOW: keeping the box visible for 30 seconds."
            )
            time.sleep(30.0)

        finally:
            self.pen.up()
            self.moveit2.remove_collision_object("detour_box")
            time.sleep(1.0)
            self.get_logger().info("Detour box removed.")
