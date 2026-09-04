# External dependencies

Large or externally maintained toolboxes and SDK binaries are intentionally not
copied into this repository. Install the versions appropriate for your MATLAB
and operating-system environment, then add them to the MATLAB path.

- [Vicon DataStream SDK](https://www.vicon.com/software/datastream-sdk/) — live
  streaming used by the scripts in `Vicon/`. The checked source used legacy
  native MATLAB bindings; newer SDK releases use .NET from MATLAB.
- [Biomechanical ToolKit](https://biomechanical-toolkit.github.io/docs/) — C3D
  input used by `HM/HRX01_c3dtomat.m`.
- [emgGO](https://github.com/GallVp/emgGO) — onset/offset detection used by
  `EMG/EMG01_DetectFiringPattern.m`.
- [spm1d for MATLAB](https://spm1d.org/Downloads.html) — plotting calls in
  several EMG helper functions.

The source export also contained copies of FieldTrip and other unrelated or
historical analysis toolboxes. They were excluded because the released entry
points do not directly require them and their upstream projects should remain
the authoritative distribution sources.
