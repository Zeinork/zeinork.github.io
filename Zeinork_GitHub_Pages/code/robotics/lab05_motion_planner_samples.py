# Task-method excerpts from motion_planner.py
# Requires the original class context and ROS 2 / MoveIt helper APIs.
# Not a standalone executable. Supplied framework code is omitted.

class TaskMethodSamples:
    def run_milestone_2(self) -> None:
        self.get_logger().info("Milestone 2: Cartesian motion")

        current_pose = self.moveit2.compute_fk()
        if current_pose is None:
            self.get_logger().error("Could not read the current pose.")
            return

        # First move 20 cm upward.
        target_1 = copy.deepcopy(current_pose.pose)
        target_1.position.z += 0.20

        # Then move 10 cm sideways from the first target.
        target_2 = copy.deepcopy(target_1)
        target_2.position.y += 0.10

        self.pen.down()

        try:
            for segment, target in enumerate([target_1, target_2], start=1):
                trajectory = self.moveit2.plan(
                    pose=target,
                    cartesian=True,
                    max_step=0.005,
                    cartesian_fraction_threshold=0.9,
                )

                if trajectory is None:
                    self.get_logger().error(
                        f"Segment {segment} planning failed; stopping."
                    )
                    return

                self.moveit2.execute(trajectory)

                if not self.moveit2.wait_until_executed():
                    self.get_logger().error(
                        f"Segment {segment} execution failed; stopping."
                    )
                    return

                self.get_logger().info(f"Segment {segment} completed.")

        finally:
            self.pen.up()
    def run_milestone_3(self) -> None:
        self.get_logger().info("Milestone 3: the planning scene")

        if self.retract_joints is None:
            self.get_logger().error(
                "Retract pose is not set. Run motion_planner 1 3."
            )
            return

        self.pen.up()
        self.moveit2.remove_collision_object("blocker")
        time.sleep(1.0)

        self.get_logger().info("Moving to Home.")
        if not self.move_to_joints(HOME):
            self.get_logger().error("Could not reach Home; stopping.")
            return

        retract_pose = self.moveit2.compute_fk(
            joint_state=self.retract_joints
        )

        if retract_pose is None:
            self.get_logger().error("Could not calculate the retract pose.")
            return

        position = retract_pose.pose.position

        self.moveit2.add_collision_box(
            id="blocker",
            size=(0.10, 0.10, 0.10),
            position=(position.x, position.y, position.z),
            quat_xyzw=(0.0, 0.0, 0.0, 1.0),
            frame_id="base_link",
        )

        try:
            time.sleep(1.0)

            self.get_logger().info(
                "Box added at Retract. Capture the screenshot "
                "while the following planning attempts fail."
            )

            blocked_result = self.move_to_joints(self.retract_joints)

            if not blocked_result:
                self.get_logger().info(
                    "With blocker: motion failed as expected. "
                    "Check the MoveIt terminal for the planning reason."
                )
            else:
                self.get_logger().error(
                    "With blocker: motion unexpectedly succeeded. "
                    "Check the box placement and size."
                )

            self.get_logger().info(
                "Keeping the box visible for 10 seconds."
            )
            time.sleep(10.0)

        finally:
            self.moveit2.remove_collision_object("blocker")
            time.sleep(1.0)

        self.get_logger().info("Box removed. Trying Retract again.")
        clear_result = self.move_to_joints(self.retract_joints)

        if clear_result:
            self.get_logger().info(
                "Without blocker: motion to Retract succeeded."
            )
        else:
            self.get_logger().error(
                "Without blocker: motion still failed; check MoveIt."
            )
    def run_milestone_4(self) -> None:
        self.get_logger().info("Milestone 4: gripper control")

        for label, command, target in [
            ("Open", self.gripper.open, 0.0),
            ("Close", self.gripper.close, 0.8),
        ]:
            self.get_logger().info(
                f"{label}: commanding finger position {target:.2f}"
            )

            command()
            self.gripper.wait_until_executed()
            time.sleep(0.5)

            measured = self.joint_position(GRIPPER_JOINT)

            if measured is None:
                self.get_logger().error(
                    f"{label}: FAIL — no measured finger position available."
                )
                continue

            error = abs(measured - target)
            passed = error <= 0.05

            message = (
                f"{label}: commanded={target:.3f}, "
                f"measured={measured:.3f}, "
                f"error={error:.3f}, "
                f"within 0.05: {'PASS' if passed else 'FAIL'}"
            )

            if passed:
                self.get_logger().info(message)
            else:
                self.get_logger().error(message)
