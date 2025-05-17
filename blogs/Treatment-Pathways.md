@def title = "Patient pathways"
# Exploring Patient Pathways within JuliaHealth

## What is Patient Pathways ?
Patient pathways refer to the journey that patients with specific medical conditions undergo in terms of their treatment. This concept goes beyond simple drug uptake statistics and looks at the sequence of treatments patients receive over time, including first-line treatments and subsequent therapies. Understanding patient pathways is essential for analyzing treatment patterns, adherence to clinical guidelines, and the rational use of drugs.
To analyze patient pathways, one would typically use real-world data from sources such as electronic health records, claims data, and registries. However, barriers such as data interoperability and resource requirements have hindered the full utilization of real-world data for this purpose.

So to address these challenges we wanna introduce to a set of tool to extract and analyze these patient pathways. These set of tool are based on the Observational Medical Outcomes Partnership (OMOP) common data model, which standardizes health care data to promote interoperability.

## Introduction
Here, we are going to have a walkthrough of how to filter out treatment pathways of interest for a given dataset present in CDM format.


## Environment Set-Up and Packages 📝

Here are the packages we will need for exploring patient pathways grouped by primary use cases in this exploration:

- Interfacing with databases

    * [`DBInterface.jl`](https://github.com/JuliaDatabases/DBInterface.jl) - Database interface definitions for Julia

    * [`SQLite`](https://github.com/JuliaDatabases/SQLite.jl) - A Julia interface to the SQLite library

- Health analytics built specifically for working with OMOP CDM databases


    * [`OMOPCDMCohortCreator`](https://github.com/JuliaHealth/OMOPCDMCohortCreator.jl) - Create cohorts from databases utilizing the OMOP CDM

- General data analytics tools

    * [`DataFrames.jl`](https://github.com/JuliaData/DataFrames.jl) - In-memory tabular data in Julia

- Miscellaneous packages

    * [`HealthSampleData.jl`](https://github.com/JuliaHealth/HealthSampleData.jl) - Sample health data for a variety of health formats and use cases

    * [`FunSQL`](https://github.com/MechanicalRabbit/FunSQL.jl) - Support for generating random numbers

    * `Base` - Default libraries built into Julia


## Adding the required Dependencies

```julia:./ex1
using Pkg
Pkg.add(["DBInterface", "SQLite", "DataFrames", "FunSQL", "HealthSampleData", "OMOPCDMCohortCreator"])
using DBInterface
using HealthSampleData
using OMOPCDMCohortCreator
using SQLite
using DataFrames
using FunSQL
```
\show{./ex1}

## Data

    For this tutorial, we will work with data from [`Eunomia`](https://github.com/OHDSI/Eunomia) that is stored in a SQLite format. To install the data on your machine, execute the following code block and follow the prompts - you will need a stable internet connection for the download to complete:

```julia:./ex2
import HealthSampleData: Eunomia
eunomia = Eunomia()
```

\show{./ex2}


## Connecting to the Eunomia Database 💾
After you have finished your set up in the Julia, we need to establish a connection to the Eunomia SQLite database that we will use for the rest of the tutorial:

```julia:./ex3
import SQLite: DB
conn = DB(eunomia)
```

\show{./ex3}

With Eunomia, the database's schema is simply called "main". We will use this to generate database connection details that will inform `OMOPCDMCohortCreator` about the type of queries we will write (i.e. SQLite) and the name of the database's schema. For this step, we will use `OMOPCDMCohortCreator`:

```julia:./ex4
import OMOPCDMCohortCreator as occ

occ.GenerateDatabaseDetails(
    :sqlite,
    "main"
)
```

\show{./ex4}

Then will generate internal representations of each table found within Eunomia for OMOPCDMCohortCreator to use:

```julia:./ex5
occ.GenerateTables(conn)
```

\show{./ex5}

## Characterizing Patients Who Have Had Strep Throat 🤒
Now to make things easy for this tutorial we will characterize a group of patients with a certain condition (or conditions) across various attributes like race, age, and combinations thereof. We are going to do miniature version of such a study looking at patients with strep throat. For this, we will use the ``condition_concept_id``: 28060 - this will be needed for you to get correct results.

```julia:./ex6
strep_patients = occ.ConditionFilterPersonIDs(28060, conn)
println(first(strep_patients, 10))
```

\show{./ex6}




## So now that we have the dataset to work with as well as all the functions to work with also ready, we from here can start work form PATHWAYS-STUDY.

* To start with we need to get the `drug ids` corresponding to each of the patients with strep throat.

```julia:./ex7
patient_drug_exposures = occ.GetDrugExposureIDs(strep_patients, conn)
println(first(patient_drug_exposures, 10))
```

\show{./ex7}


* We would also require `drug concepts` 
```julia:./ex8
pateints_drug_concept_id = occ.GetDrugConceptIDs(patient_drug_exposures, conn)
println(first(pateints_drug_concept_id, 10))
```

\show{./ex8}



* Now that we have the `drug ids` corresponding to each patients we now need to get the `start date` and `end date` corresponding to each `drug ids`

```julia:./ex9
exposure_start_date = occ.GetDrugExposureStartDate(patient_drug_exposures.drug_exposure_id, conn)
println(first(exposure_start_date, 10))


exposure_end_date = occ.GetDrugExposureEndDate(patient_drug_exposures.drug_exposure_id, conn)
println(first(exposure_end_date, 10))
```

\show{./ex9}

* A thing to notice here is that the dates here are in `unix` format, which preety annoying to understand so we need to convert it into `data-time` format. This can be done as follows
```julia:./ex10
exposure_start_date.drug_exposure_start_date = exposure_start_date.drug_exposure_start_date .|> unix2datetime

exposure_end_date.drug_exposure_end_date = exposure_end_date.drug_exposure_end_date .|> unix2datetime

println(first(exposure_end_date, 10))
```
\show{./ex10}

* Now to make the Dataframe look more appealing we try to combine the dataset like this:

```julia:./ex11
combined_df = DataFrames.outerjoin(patient_drug_exposures, exposure_start_date, on = :drug_exposure_id)
combined_df = DataFrames.outerjoin(combined_df, exposure_end_date, on = :drug_exposure_id)
combined_df = DataFrames.outerjoin(combined_df, pateints_drug_concept_id, on = :drug_exposure_id, makeunique=true)
println(first(combined_df, 10))
```
\show{./ex11}


* Now we need to sort the Dataframe in the ascending order of the dates.
```julia:./ex12
combined_df =  sort!(combined_df, :drug_exposure_start_date)
println(first(combined_df, 10))
```

\show{./ex12}

* An important thing to notice here is that some start and end dates seems to be preety weird. We need to make sure that the start date is less than the end date.

* So in-order to address this issue within the dataset, we will chop off such rows for our pathways study by doing something like this:

```julia:./ex13
combined_df = combined_df[combined_df.drug_exposure_start_date .< combined_df.drug_exposure_end_date, :]
println(first(combined_df, 10))
```

\show{./ex13}

* Now as a final step to exploring pathways, we peform a very naive approach to get the treatment-pathways by:
1. Itterate through each of the `patients_id`
2. Itterate through the combined_df and push the `drug_exposure_id` to the `drug_pathways` list if the two consecutive start dates are different as well as the two consecutive end dates are different.


```julia:./ex14
pathways_dict = Dict()

for person_id in unique(combined_df.person_id)
    my_patients = combined_df[combined_df.person_id .== person_id, :]
    pathways = []
    for i in 1:size(my_patients, 1)-1
        if ((my_patients[i, :drug_exposure_start_date] != my_patients[i+1, :drug_exposure_start_date] || my_patients[i, :drug_exposure_end_date] != my_patients[i+1, :drug_exposure_end_date]))
            push!(pathways, my_patients[i, :drug_exposure_id])
        end
    end
    pathways_dict[person_id] = pathways
end
```
\show{./ex14}

* Now the pathways of our interset are present in the dixtionary `pathways_dict`that would look like this:

```julia:./ex15
println(first(pathways_dict, 10))
```

\show{./ex15}

```
Dict{Any, Any} with 1677 entries:
  4986.0 => Any[59989.0, 59989.0, 59977.0, 59977.0, 59969.0, 59976.0, 59976.0, 59986.0, 59973.0, 59975.0, 59968.0, 59984.0, 59985.0, 59982.0, 59983.0, 59988.0, 59970.0]
  4700.0 => Any[56635.0, 56632.0, 56632.0, 56633.0, 56639.0, 56638.0, 56637.0]
  4576.0 => Any[55107.0, 55112.0, 55115.0, 55119.0, 55111.0, 55118.0, 55103.0, 55105.0, 55110.0, 55116.0, 55117.0, 55120.0]
  1175.0 => Any[14056.0, 14052.0, 14057.0, 14048.0, 14046.0, 14055.0, 14053.0, 14044.0, 14054.0, 53705.0, 53705.0, 53684.0, 53684.0, 14051.0, 14058.0, 14050.0, 53703.0…
  1144.0 => Any[52276.0, 13660.0, 13667.0, 13673.0, 13671.0, 13672.0, 13672.0, 52273.0, 52273.0, 13665.0, 13661.0, 13658.0, 13662.0, 52265.0, 52265.0, 13664.0, 13669.0…
  719.0  => Any[32930.0, 32930.0, 8612.0, 8614.0, 8618.0, 8608.0, 8621.0, 8617.0, 8616.0, 8623.0, 32928.0, 8606.0, 8625.0, 8619.0, 8622.0, 32928.0, 8610.0]
  3634.0 => Any[43874.0, 43875.0, 43872.0, 43871.0, 43878.0]
```
