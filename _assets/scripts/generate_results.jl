"""
    genplain(s)

Small helper function to run some code and redirect the output (stdout) to a file.
"""
function genplain(s::String)
    open(joinpath(dir, "output", "$(splitext(s)[1]).txt"), "w") do outf
        redirect_stdout(outf) do
            include(joinpath(dir, s))
        end
    end
end

const FILE = abspath(@__FILE__) # _assets/scripts/generate_results.jl
const DIR = abspath(dirname(FILE)) # _assets/scripts/

const package_list_jl_file = abspath(DIR, "package_list.jl") # _assets/scripts/package_list.jl
include(package_list_jl_file)
const package_list_md_file = abspath(DIR, "package_list.md") # _assets/scripts/package_list.md
const packages_to_exclude = String[
    "FHIRClientJSON.jl", # deprecated in favor of JuliaHealth/FHIRClient.jl
    "FHIRClientXML.jl",  # most users should use JuliaHealth/FHIRClient.jl instead
    "HealthMLBase.jl",   # deprecated
]
const packages_to_include = String[]
generate_package_list("JuliaHealth",
                      package_list_md_file;
                      packages_to_exclude = packages_to_exclude,
                      packages_to_include = packages_to_include)
