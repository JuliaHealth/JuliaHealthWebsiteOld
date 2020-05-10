import GitHub

@inline function _gh_try_auth(env_dict = ENV,
                              key_name = "GITHUB_TOKEN")
    if haskey(env_dict, key_name)
        token = env_dict[key_name]
        return GitHub.authenticate(token)
    end
    return GitHub.AnonymousAuth()
end

@inline function _gh_all_repos(orgname::AbstractString;
                               auth = GitHub.AnonymousAuth())::Vector{GitHub.Repo}
    owner = GitHub.owner(orgname;
                         auth = auth)
    return _gh_all_repos(owner;
                         auth = auth)
end

@inline function _gh_all_repos(owner::GitHub.Owner;
                               auth = GitHub.AnonymousAuth())::Vector{GitHub.Repo}
    page_limit = 100
    per_page = 100
    all_repos = Vector{GitHub.Repo}(undef, 0)
    repos, page_data = GitHub.repos(owner;
                                    auth = auth,
                                    params = Dict("page_limit" => page_limit,
                                                  "per_page" => per_page,
                                                  "start_page" => 1))
    append!(all_repos, repos)
    while haskey(page_data, "next")
        repos, page_data = GitHub.repos(owner;
                                        auth = auth,
                                        params = Dict("page_limit" => page_limit,
                                                      "per_page" => per_page,
                                                      "start_page" => page_data["next"]))
        append!(all_repos, repos)
    end
    unique!(all_repos)
    return all_repos
end

@inline function _gh_is_private(repo::GitHub.Repo;
                                auth = GitHub.AnonymousAuth())::Bool
    return repo.private
end

@inline function _gh_is_public(repo::GitHub.Repo;
                               auth = GitHub.AnonymousAuth())::Bool
    return ! _gh_is_private(repo)
end

@inline function _gh_description(repo::GitHub.Repo;
                                 auth = GitHub.AnonymousAuth())::String
    return repo.description
end

@inline function _gh_name(repo::GitHub.Repo;
                          auth = GitHub.AnonymousAuth())::String
    return repo.name
end

@inline function _gh_name_is_julia_package(repo::GitHub.Repo;
                                           auth = GitHub.AnonymousAuth())::Bool
    name = _gh_name(repo; auth = auth)
    return _gh_name_is_julia_package(name; auth = auth)
end

@inline function _gh_name_is_julia_package(name::AbstractString;
                                           auth = GitHub.AnonymousAuth())::Bool
    _name::String = convert(String, lowercase(strip(name)))::String
    return endswith(_name, ".jl")
end

@inline function _gh_organization_base_html_url(org::GitHub.Owner;
                                                auth = GitHub.AnonymousAuth())::String
    return org.html_url.uri
end

@inline function _gh_get_public_julia_packages(orgname::AbstractString;
                                               auth = GitHub.AnonymousAuth(),
                                               exclude = String[])::Vector{Tuple{String, String, String}}
    owner = GitHub.owner(orgname; auth = auth)
    return _gh_get_public_julia_packages(owner; auth = auth)
end

@inline function _gh_get_public_julia_packages(org::GitHub.Owner;
                                               auth = GitHub.AnonymousAuth(),
                                               exclude::Vector{String} = String[])::Vector{Tuple{String, String, String}}
    _exclude::Vector{String} = convert(Vector{String}, strip.(exclude))::Vector{String}
    repos = _gh_all_repos(org; auth = auth)
    filter!(x -> ( (_gh_is_public(x; auth = auth)) && (_gh_name_is_julia_package(x; auth = auth)) ), repos)
    # names = setdiff([r.name for r in repos], exclude)
    # unique!(names)
    # sort!(names)
    base_url = _gh_organization_base_html_url(org)
    name_to_info = Dict{String, Tuple{String, String, String}}()
    for r in repos
        name = convert(String, strip(_gh_name(r)))::String
        url = convert(String, strip(string(base_url, "/", name)))::String
        description = convert(String, strip(_gh_description(r)))::String
        if name in _exclude
        else
            key = name
            value = (name, url, description)
            name_to_info[key] = value
        end
    end
    names = sort(unique(collect(keys(name_to_info))))
    result = Vector{Tuple{String, String, String}}(undef, length(names))
    for i = 1:length(names)
        name = names[i]
        result[i] = name_to_info[name]
    end
    return result
end

@inline function _gh_julia_packages_to_markdown_content(orgname::AbstractString;
                                                        auth = GitHub.AnonymousAuth(),
                                                        exclude = String[])::String
    packages = _gh_get_public_julia_packages(orgname;
                                             auth = auth,
                                             exclude = exclude)
    result = "\n"
    result *= "| Package | Description |\n"
    result *= "| ------- | ----------- |\n"
    for info in packages
        name, url, description = info
        line = "| [$(name)]($(url)) | $(description) |\n"
        result *= line
    end
    result::String = convert(String, strip(result))::String
    return result
end

@inline function _gh_julia_packages_to_markdown_file(orgname::AbstractString,
                                                     output_filename::AbstractString;
                                                     auth = GitHub.AnonymousAuth(),
                                                     exclude = String[])::Nothing
    content = _gh_julia_packages_to_markdown_content(orgname;
                                                     auth = auth,
                                                     exclude = exclude)
    rm(output_filename; force = true)
    open(output_filename, "w") do io
        println(io, content)
    end
    return nothing
end

auth = _gh_try_auth()

@inline function generate_package_list(orgname::AbstractString,
                                       output_filename::AbstractString;
                                       auth = _gh_try_auth(),
                                       exclude = String[])::Nothing
    _gh_julia_packages_to_markdown_file(orgname::AbstractString,
                                        output_filename;
                                        auth = auth,
                                        exclude = exclude)
    return nothing
end
