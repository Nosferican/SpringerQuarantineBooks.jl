using Documenter, SpringerQuarantineBooks

DocMeta.setdocmeta!(SpringerQuarantineBooks,
                    :DocTestSetup,
                    :(using SpringerQuarantineBooks;),
                    recursive = true)
makedocs(sitename = "SpringerQuarantineBooks",
         modules = [SpringerQuarantineBooks],
         pages = [
             "Home" => "index.md",
             "API" => "api.md"
             ]
         )

deploydocs(repo = "github.com/Nosferican/SpringerQuarantineBooks.jl.git", push_preview = true)
