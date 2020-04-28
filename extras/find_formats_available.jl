using Pkg
using Cascadia: parsehtml, Selector, getattr
using HTTP: HTTP, request
using CSV

data = CSV.File(joinpath("data", "FreeGermanTextbooks.csv") |> CSV.DataFrame
DOIs = SubString.(data[!,Symbol("DOI URL")], 16)
fields = data[!,Symbol("English Package Name")]
titles = data[!,Symbol("Book Title")]
URLs = replace.(data[!,Symbol("OpenURL")], "http://" => "https://")

const SELECTOR_EPUB = Selector(".c-button[title=\"Download this book in EPUB format\"]")
const SELECTOR_PDF = Selector(".c-button[title=\"Download this book in PDF format\"]")

function links(url)
    response = HTTP.get(url)
    html = parsehtml(String(response.body))
    epub = eachmatch(SELECTOR_EPUB, html.root)
    pdf = eachmatch(SELECTOR_PDF, html.root)
    (ISBN = match(r"(?<=isbn=).*", url).match,
     epub = isempty(epub) ? "" : string(HTTP.URI(scheme = "https",
                                                 host = HTTP.header(response.request, "Host"),
                                                 path = getattr(epub[1], "href"))),
     pdf = isempty(pdf) ? "" : string(HTTP.URI(scheme = "https",
                                               host = HTTP.header(response.request, "Host"),
                                               path = getattr(pdf[1], "href"))),
    )
end

output = Vector{NamedTuple{(:ISBN, :epub, :pdf), NTuple{3, String}}}()

for url in URLs
    println(url)
    push!(output, links(url))
end
isbn_links = CSV.DataFrame(output)
awesome = CSV.join(data, isbn_links, on = [Symbol("Electronic ISBN") => :ISBN])
CSV.write(joinpath(@__DIR__, "data", "FreeGermanTextbooksEnhanced.tsv"), awesome, delim = '\t')
