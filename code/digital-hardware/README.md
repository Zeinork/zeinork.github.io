# Wynton Zhang — Digital hardware code samples

Selected RTL from Duke ECE 350 coursework. This package preserves the uploaded implementation and excludes supplied flip-flop primitives, course testbenches, assignment material, and generated simulation binaries.

## Contents
- alu/: 32-bit structural ALU, hierarchical carry-lookahead arithmetic, barrel shifters, and flag logic.
- regfile/: dual-read, single-write 32 x 32 register file.
- multdiv/: EARLY multiplication-only checkpoint; division is unimplemented and signed exception handling is unfinished in this archived version.

## Dependencies and verification
The register file and multiplier require dffe_ref, a course-provided flip-flop module not redistributed here. Obtain a compatible flip-flop dependency through your own environment. The package is source for inspection, not a self-contained runnable project.

Saved register-file evidence in the original archive reported 34,096 cases with zero errors. No board implementation or timing result is claimed. The full CPU remains in progress.

Project samples were selected from the student's uploaded files. Publication is not a claim of authorship of the course framework or provided modules.
