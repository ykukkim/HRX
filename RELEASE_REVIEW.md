# Pre-release review

The following points were found during static inspection. They are documented
instead of being silently changed because several could alter the participant
set, transformations, model specification or published outputs.

## High-priority scientific and execution points

1. **Participant loops contain debugging limits.** `HM/HRX01_c3dtomat.m` runs
   only the first top-level directory; `HM/HRX02_HM_RCandEMG.m` and
   `HM/HRX03_ConcatenateRC.m` run only subject index 3; and
   `Gait/Gait01_spatiotemporal.m` runs only subject index 22. Confirm the exact
   scripts used for the published analyses before restoring full ranges.
2. **The primary gait script cannot save as written.** It uses the undefined
   name `Particiapnt_Name`, passes the `GaitSummary` structure to `fullfile`, and
   then asks `save` for a variable named by `Name`. Define and test the intended
   participant key, output filename and saved structure.
3. **Failures can be hidden.** Several broad MATLAB `catch` blocks print only a
   generic message and continue, which can silently remove trials or
   participants. Record filenames and full exceptions in a structured exclusion
   log.
4. **Anonymous identifiers are not reproducible.** `randomName` creates random
   participant labels without a fixed seed or collision check. It also generates
   the displayed digits separately from the returned digits. Use a stable,
   securely stored subject-to-code mapping outside the repository.
5. **Statistical preprocessing needs confirmation.** `Stats/01_Data_cleaning.R`
   converts every zero to missing and takes the absolute value of every numeric
   gait column. Its Tukey outlier function is defined but the line applying it is
   commented out. Verify these transformations against the analysis plan and
   manuscript.
6. **One mixed model is overwritten.** `Stats/02_Running_Stats.R` assigns the raw
   H-reflex model and the background-EMG-normalised model to the same object
   name, so subsequent tables contain only the second specification.
7. **The plotting script depends on interactive state.** `Stats/03_Plots.R`
   expects models and data created elsewhere, and creates `plot_list` without
   adding plots to it before `grid.arrange`.

## Reproducibility and maintenance points

1. Input, output and network paths are hard-coded throughout the MATLAB and R
   scripts. Replace them with function arguments or one local configuration file.
2. R scripts install packages during analysis and do not record versions. Use a
   locked environment such as `renv` after identifying the publication versions.
3. Many functions share names across directories. Recursive `addpath` calls can
   therefore select different implementations depending on MATLAB path order.
4. The exported folder mixed study code with BTK, Vicon, FieldTrip, spm1d,
   emgGO, historical code and generated data. The public release excludes those
   copies and links to upstream dependencies instead.
5. Select a licence only after confirming agreement from the copyright holders.
6. Add a de-identified synthetic C3D/MAT fixture and expected summary outputs so
   the pipeline can be checked without participant data.
