"""
    SpringerQuarantineBooks

Module for downloading the SpringerQuarantineBooks.
"""
module SpringerQuarantineBooks
using DelimitedFiles: readdlm
const fields = Ref{Vector{String}}()
const titles = Ref{Vector{String}}()
const epubs = Ref{Vector{String}}()
const pdfs = Ref{Vector{String}}()
function init()
    data = readdlm(joinpath(@__DIR__, "data", "FreeEnglishTextbooksEnhanced.tsv"), '\t',
                   header = true)
    fields.x = convert(Vector{String}, data[1][:,findfirst(isequal("English Package Name"), vec(data[2]))])
    titles.x = replace.(string.(data[1][:,findfirst(isequal("Book Title"), vec(data[2]))], " - ", data[1][:,findfirst(isequal("Edition"), vec(data[2]))]),
                        "/" => "_")
    epubs.x = data[1][:,findfirst(isequal("epub"), vec(data[2]))]
    pdfs.x = data[1][:,findfirst(isequal("pdf"), vec(data[2]))]
end
"""
    download_book(basepath::AbstractString, field::AbstractString, title::AbstractString, epub::AbstractString, pdf::AbstractString)

Save the ePUB (if available or PDF otherwise) version of the textbook at the given basepath.
The structure will be `basepath/field/title.epub` or `basepath/field/title.pdf`
"""
function download_book(basepath, field, title, epub, pdf)
    path = mkpath(joinpath(basepath, field))
    if isfile(joinpath(path, "$title.epub"))
        @info "$title.epub was detected"
    elseif isfile(joinpath(path, "$title.pdf"))
        @info "$title.pdf was detected"
    else
        if !ismissing(epub)
            try
                download(epub, joinpath(path, "$title.epub"))
                @info "$title.epub was downloaded"
            catch err
                download(pdf, joinpath(path, "$title.pdf"))
                @info "$title.pdf was downloaded"
            end
        else
            download(pdf, joinpath(path, "$title.pdf"))
            @info "$title.pdf was downloaded"
        end
    end
end
"""
    download_springer_quarantine_books(basepath::AbstractString)

Uses `download_book` to download all books at the given basepath.
The schema is `basepath/field/title - edition.epub` or `basepath/field/title - edition.pdf` if epub is not available.
"""
function download_springer_quarantine_books(basepath::AbstractString)
    for (field, title, epub, pdf) in zip(fields.x, titles.x, epubs.x, pdfs.x)
        download_book(basepath, field, title, epub, pdf)
    end
end
export download_springer_quarantine_books,
       download_book
end
