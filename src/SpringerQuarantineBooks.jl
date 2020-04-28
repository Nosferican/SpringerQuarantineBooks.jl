"""
    SpringerQuarantineBooks

Module for downloading the SpringerQuarantineBooks.
"""
module SpringerQuarantineBooks
using DelimitedFiles: readdlm
const en_fields = Ref{Vector{String}}()
const en_titles = Ref{Vector{String}}()
const en_epubs = Ref{Vector{String}}()
const en_pdfs = Ref{Vector{String}}()
const de_fields = Ref{Vector{String}}()
const de_titles = Ref{Vector{String}}()
const de_epubs = Ref{Vector{String}}()
const de_pdfs = Ref{Vector{String}}()
function __init__()
    data = readdlm(joinpath(@__DIR__, "..", "data", "FreeEnglishTextbooksEnhanced.tsv"), '\t',
                   header = true)
    en_fields.x = convert(Vector{String}, data[1][:,findfirst(isequal("English Package Name"), vec(data[2]))])
    en_titles.x = replace.(string.(data[1][:,findfirst(isequal("Book Title"), vec(data[2]))], " - ", data[1][:,findfirst(isequal("Edition"), vec(data[2]))]),
                        "/" => "_")
    en_epubs.x = data[1][:,findfirst(isequal("epub"), vec(data[2]))]
    en_pdfs.x = data[1][:,findfirst(isequal("pdf"), vec(data[2]))]
    data = readdlm(joinpath(@__DIR__, "..", "data", "FreeGermanTextbooksEnhanced.tsv"), '\t',
                   header = true)
    de_fields.x = convert(Vector{String}, data[1][:,findfirst(isequal("English Package Name"), vec(data[2]))])
    de_titles.x = replace.(string.(data[1][:,findfirst(isequal("Book Title"), vec(data[2]))], " - ", data[1][:,findfirst(isequal("Edition"), vec(data[2]))]),
                        "/" => "_")
    de_epubs.x = data[1][:,findfirst(isequal("epub"), vec(data[2]))]
    de_pdfs.x = data[1][:,findfirst(isequal("pdf"), vec(data[2]))]
    nothing
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
    download_springer_quarantine_books(basepath::AbstractString, lang::AbstractString = "en")

Uses `download_book` to download all books at the given basepath.
The schema is `basepath/field/title - edition.epub` or `basepath/field/title - edition.pdf` if epub is not available.
For the German textbooks, pass `lang` as `de`.
"""
function download_springer_quarantine_books(basepath::AbstractString, lang::AbstractString = "en")
    if lang == "en"
        for (field, title, epub, pdf) in zip(en_fields.x, en_titles.x, en_epubs.x, en_pdfs.x)
            download_book(basepath, field, title, epub, pdf)
        end
    elseif lang == "de"
        for (field, title, epub, pdf) in zip(de_fields.x, de_titles.x, de_epubs.x, de_pdfs.x)
            download_book(basepath, field, title, epub, pdf)
        end
    else
        throw(ArgumentError("lang must be either en for English or de for German"))
    end
end
export download_springer_quarantine_books,
       download_book
end
