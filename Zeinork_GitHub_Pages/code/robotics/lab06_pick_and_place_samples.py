# Task-method excerpts from pick_and_place.py
# Requires the original class context and ROS 2 / MoveIt helper APIs.
# Not a standalone executable. Supplied framework code is omitted.

class TaskMethodSamples:
    def place(self, block_id: str, x: float, y: float, layer: int) -> bool:
        """Place the held block on top of `layer` blocks."""
        release_z = GRASP_HEIGHT + layer * BLOCK_SIZE + PLACE_CLEARANCE

        # 1. Carry the block above the destination.
        if not self.move_to_pose(x, y, APPROACH_HEIGHT):
            return False

        # 2. Lower it slowly in a straight line.
        if not self.move_to_pose(
            x, y, release_z,
            cartesian=True,
            speed=PLACE_SPEED,
        ):
            return False

        # 3. Release the block before detaching it in MoveIt.
        self.open_gripper()
        self.moveit2.detach_collision_object(block_id)
        time.sleep(0.5)

        # 4. Lift the empty gripper straight up.
        if not self.move_to_pose(
            x, y, APPROACH_HEIGHT,
            cartesian=True,
        ):
            return False

        return True
    def run_milestone_2(self) -> None:
        """Pick block_1 and place it on top of block_2."""
        log = self.get_logger()
        log.info("Milestone 2: two-block stack")

        if not self.start():
            return

        reset_blocks(self, self.moveit2)

        # Pick the red block from its starting position.
        x, y = BLOCKS["block_1"][1]
        if self.pick("block_1", x, y) is None:
            log.error("Milestone 2: the pick did not finish.")
            return

        # Place it above the blue block: one block below it.
        tower_x, tower_y = TOWER_XY
        if not self.place("block_1", tower_x, tower_y, layer=1):
            log.error("Milestone 2: the place did not finish.")
            return

        self.move_to_joints(WORK)
        log.info("Milestone 2 done.")
    def run_milestone_3(self) -> None:
        """Stack block_1 and then block_3 on block_2."""
        log = self.get_logger()
        log.info("Milestone 3: three-block tower")

        if not self.start():
            return

        reset_blocks(self, self.moveit2)

        order = ("block_1", "block_3")
        tower_x, tower_y = TOWER_XY
        placed = 0

        for layer, block_id in enumerate(order, start=1):
            x, y = BLOCKS[block_id][1]

            log.info(
                f"Picking {block_id} at ({x:.3f}, {y:.3f}); "
                f"placing on layer {layer}."
            )

            if self.pick(block_id, x, y) is None:
                log.error(
                    f"Pick failed for {block_id}. "
                    f"{placed} of {len(order)} blocks were placed."
                )
                return

            if not self.place(block_id, tower_x, tower_y, layer):
                log.error(
                    f"Place failed for {block_id}. "
                    f"{placed} of {len(order)} blocks were placed."
                )
                return

            placed += 1

        log.info(f"{placed} of {len(order)} blocks were placed.")
        self.move_to_joints(WORK)
        log.info("Milestone 3 done.")
    def pick_checked(self, block_id: str, x: float, y: float) -> float | None:
        """Check the grasp before attaching; retreat and stop on a miss."""
        log = self.get_logger()
        threshold = 0.64

        # Approach above the block.
        if not self.move_to_pose(x, y, APPROACH_HEIGHT):
            log.error(f"{block_id}: approach failed.")
            return None

        self.open_gripper()

        # Descend straight down.
        if not self.move_to_pose(x, y, GRASP_HEIGHT, cartesian=True):
            log.error(f"{block_id}: descent failed.")
            return None

        reading = self.close_gripper()

        if reading is None:
            log.error(
                f"{block_id}: no finger reading. "
                "Stopping without attaching."
            )
            return None

        # Decide BEFORE attaching or planning the lift.
        holding_block = 0.0 <= reading < threshold

        if not holding_block:
            log.warning(
                f"{block_id}: grasp rejected, reading={reading:.3f}, "
                f"threshold={threshold:.3f}. No block attached."
            )

            # Recovery: open, retreat straight up, and stop at WORK.
            self.open_gripper()

            if not self.move_to_pose(
                x, y, APPROACH_HEIGHT, cartesian=True
            ):
                log.error("Recovery retreat failed; stopping.")
                return None

            if not self.move_to_joints(WORK):
                log.error("Recovery move to WORK failed; stopping.")
                return None

            log.info("Recovery complete: stopped at WORK.")
            return None

        log.info(
            f"{block_id}: grasp accepted, reading={reading:.3f}, "
            f"threshold={threshold:.3f}. Attaching block."
        )

        self.moveit2.attach_collision_object(
            block_id, "end_effector_link", TOUCH_LINKS
        )
        time.sleep(0.5)

        # Lift only after a successful grasp check.
        if not self.move_to_pose(
            x, y, APPROACH_HEIGHT, cartesian=True
        ):
            log.error(f"{block_id}: lift failed.")
            return None

        return reading
    def run_milestone_4(self) -> None:
        """Build the tower with grasp checking and stop-on-miss recovery."""
        log = self.get_logger()
        log.info("Milestone 4: threshold=0.64; recovery=stop at WORK")

        if not self.start():
            return

        # Do NOT reset here: preserve the deliberately nudged block.
        order = ("block_1", "block_3")
        tower_x, tower_y = TOWER_XY
        placed = 0

        for layer, block_id in enumerate(order, start=1):
            x, y = BLOCKS[block_id][1]

            log.info(
                f"Picking {block_id} at ({x:.3f}, {y:.3f}); "
                f"target layer={layer}."
            )

            if self.pick_checked(block_id, x, y) is None:
                log.error(
                    f"Milestone 4 stopped during pick of {block_id}. "
                    f"{placed} of {len(order)} blocks were placed."
                )
                return

            if not self.place(block_id, tower_x, tower_y, layer):
                log.error(
                    f"Place failed for {block_id}. "
                    f"{placed} of {len(order)} blocks were placed."
                )
                return

            placed += 1
            log.info(f"{placed} of {len(order)} blocks were placed.")

        if not self.move_to_joints(WORK):
            log.error("Return to WORK failed.")
            return

        log.info("Milestone 4 done.")
