@def title = "JuliaHealth - Tutorials"

** How to create a patient-Level prediction model using JuliaHealth **

This notebook uses the packages:
* [MLJ](https://alan-turing-institute.github.io/MLJ.jl/) for machine learning tasks, including data
* [OMOPCDMCohortCreator](https://github.com/JuliaHealth/OMOPCDMCohortCreator.jl) for dealing with OMOP Databases
* [LibPQ](https://github.com/chris-b1/LibPQ.jl#dbinterface) to connect to the database on the server (hidden for the server security)

[The notebook](/assets/JuliaHealth-Patient-level-prediction.ipynb)

The model predicts patients of AFib that got stroke and produces accuracy of 87% 
