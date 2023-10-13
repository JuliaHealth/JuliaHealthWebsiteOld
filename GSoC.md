@def title = "JuliaHealth - Google Summer of Code"

This page lists our [Google Summer of Code (GSoC)](https://summerofcode.withgoogle.com) fellows and their experiences working across the JuliaHealth ecosystem.
Students interested in being a GSoC fellow should review these past projects to get a sense for what we look for in building projects that contribute to the JuliaHealth ecosystem. 

\toc 

# GSoC 2023

## JuliaHealth's Tools for Patient-Level Predictions: Strengthening Capacity and Innovation

**Student:** Fareeda Abdelazeez

**Mentor:** Jacob Zelko

[Project Proposal](https://docs.google.com/document/d/18-p6VG6MwvzFdyA45MvXyqxOLVEByFP6D_gff9-E1XE/edit#heading=h.zgq6k5hzq0t) ##add the pdf

**Summary:** Working with the OMOP CDM (Observational Medical Outcomes Partnership Common Data Model) involves handling large datasets that require a set of tools for extracting necessary data efficiently for various analyses.
The first part of the project focused on improving JuliaHealth's infrastructure by increasing the range of tools available to users.
This involved enabling connections to various databases and working with building understanding on how to robustly work with observational health data.
The second goal was to leverage the capacity built in the previous phase to develop a comprehensive framework for patient-level prediction.
This framework explored how to predict patient cohort outcomes with given treatments and was tested on the [MIMIC III dataset](https://physionet.org/content/mimiciii/1.4/) that was converted to the OMOP CDM.



**Fellowship core accomplishments:**

The [PR](https://github.com/JuliaHealth/OMOPCDMCohortCreator.jl/pull/54) for OMOPCDMCohortCreator added new features:

- Enriched OMOPCDMCohortCreator tools
- Intensive tests for new functions
- Updated the documentation

The [PR](https://github.com/JuliaDatabases/DBConnector.jl/pull/13)
for DBConnector

- Created a documentation
- Rewired tools used to connect to SQLite,postgresql, MySQL
- Created test unit

This Jupyter notebook shows the flow of creating a prediction model from OMOP CDM using developed packages through the program.
You can find it on juliahealth website - the tutorial section.
For more details, this [blogpost] (https://medium.com/@fareedaabdelazeez/google-summer-of-code-2023-strengthening-healthcare-with-juliahealth-7b8fde5af9ec) wraps up the details of GSoC program achievements. Check Acknowledgments too!

- Poster presentation at [JuliaCon 2023, _JuliaHealth's Tools for Patient-Level Predictions: Strengthening Capacity and Innovation_](/assets/JuliaCon-gsoc.pdf)
