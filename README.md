# H-reflex and gait adaptation analysis

MATLAB and R research code for analysing gait, electromyography (EMG), and
soleus H-reflex responses during treadmill walking under altered weight-bearing
conditions.

The pipeline covers C3D conversion, H- and M-wave recruitment curves, gait-event
and spatiotemporal analysis, centre-of-mass and margin-of-stability measures,
EMG processing, and linear mixed-effects analysis.

## Associated publications

This code is associated with the following studies:

1. Y. K. Kim, M. Gwerder, W. R. Taylor, H. Baur and N. B. Singh,
   “Adaptive gait responses to varying weight-bearing conditions: Inferences
   from gait dynamics and H-reflex magnitude,” *Experimental Physiology*,
   vol. 109, no. 5, pp. 754–765, 2024.
   https://doi.org/10.1113/EP091492
2. M. Gwerder, U. Camenzind, S. Wild, Y. K. Kim, W. R. Taylor and N. B. Singh,
   “Probing gait adaptations: The impact of aging on dynamic stability and
   reflex control mechanisms under varied weight-bearing conditions,”
   *European Journal of Applied Physiology*, vol. 125, pp. 3753–3767, 2025.
   https://doi.org/10.1007/s00421-025-05884-1

## Release scope

This public release contains the study-authored processing and analysis scripts.
It deliberately excludes participant data, generated results, machine-specific
R workspaces, development archives, and bundled copies of third-party toolboxes
and proprietary SDK binaries.

The repository is therefore a source-code record rather than a self-contained
reproduction package. The publications state that study data are available from
the corresponding authors on reasonable request but are not public because of
privacy or ethical restrictions.

## Repository layout

- `Vicon/` — real-time acquisition and stimulus-trigger scripts
- `HM/` — C3D conversion, recruitment curves, H/M-wave and stance-phase analysis
- `Gait/` — gait events, spatiotemporal parameters, centre of mass and stability
- `EMG/` — muscle-activity segmentation and visualisation
- `Stats/` — data preparation, mixed-effects models and figure generation

The numbered filenames indicate the intended order within each stage. Some
stages depend on outputs from earlier directories.

## Requirements

- MATLAB with the toolboxes required by the selected analysis functions
- R; the 2024 study reports R 4.1.3
- Vicon Nexus and the Vicon DataStream SDK for the live acquisition scripts
- Biomechanical ToolKit (BTK) MATLAB bindings for C3D conversion
- emgGO for onset/offset detection
- spm1d for the EMG plotting functions that call `spm1d.plot`

Third-party projects are not vendored here. See `DEPENDENCIES.md` for their
official sources and `R-packages.txt` for the R packages referenced by the
analysis scripts.

## Nominal workflow

1. Configure and run the relevant acquisition script in `Vicon/`, if live
   stimulation is required.
2. Run `HM/HRX01_c3dtomat.m` through `HM/HRX06_HMtoxls.m` as applicable.
3. Run the numbered scripts in `Gait/` to derive gait and stability measures.
4. Run the numbered scripts in `EMG/` when EMG onset/offset analysis is needed.
5. Run the scripts in `Stats/` after supplying the derived workbook.

This order is inferred from the numbered entry points and code comments. Several
scripts still contain original machine paths and participant-specific loop
limits, so review `RELEASE_REVIEW.md` and configure a working copy before use.

## Reproducibility status

The release has been checked for generated data, large binaries and obvious
credentials. MATLAB, Vicon and R runtimes were not available in the release
environment, so the complete workflow has not been executed. Do not assume that
the repository regenerates the published results without resolving the points in
`RELEASE_REVIEW.md` and obtaining the study data.

## Citation

If this code supports your work, cite the publication corresponding to the
cohort and analysis you use. `CITATION.cff` provides the 2024 article as the
default citation.

## Licence

No open-source licence has been selected for the study-authored code. Until the
copyright holders add one, default copyright restrictions apply. Third-party
dependencies remain governed by their own licences.

## Contact

For questions about the study or code, contact Yong Kuk Kim.
