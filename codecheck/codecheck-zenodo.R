## Documentation
## https://cran.r-project.org/web/packages/zen4R/vignettes/zen4R.html

## Zenodo deposit; see vignette("codecheck_overview.Rmd")

library(codecheck)
library(yaml)
library(zen4R)
## This assumes your working directory is the codecheck directory

yaml_file <-  "../codecheck.yml"

metadata = read_yaml(yaml_file)

## To interact with the Zenodo API, you need to create a token.  This should
## not be shared, or stored in this script.  Here I am using the Unix password
## tool pass to retrieve the token.
my_token = system("pass show codechecker-token", intern=TRUE)

## make a connection to Zenodo API
zenodo <- ZenodoManager$new(token = my_token)


my_rec <- get_zenodo_record(zenodo, metadata)

## Careful -- make sure your yaml file is saved before running this next chunk; if there is not
## zenodo record, it will create one.
if ( is.null(my_rec)) {
  my_rec <- zenodo$createEmptyRecord()
  add_id_to_yml(my_rec$id, yaml_file) ## may want to have warning on this.
  metadata <- read_yaml(yaml_file)  ## re-read metadata as there is now a proper ID.
}


## Now update the zenodo record with any new metadata
my_rec <- upload_zenodo_metadata(zenodo, my_rec, metadata)


upload_zenodo_metadata <- function(zen, myrec, metadata) {
  

  ##draft$setPublicationType("report")
  ##draft$setCommunities(communities = c("codecheck"))
  myrec$metadata <- NULL
  myrec$setTitle(paste("CODECHECK certificate", metadata$certificate))
  myrec$addLanguage(language = "eng")
  myrec$setLicense("cc-by-4.0")

  myrec$metadata$creators <- NULL
  num_creators <- length(metadata$codechecker)
  for (i in 1:num_creators) {
    myrec$addCreator(
            name  = metadata$codechecker[[i]]$name,
            orcid = metadata$codechecker[[i]]$ORCID)
  }

  description_text <- paste("CODECHECK certificate for paper:",
                           metadata$paper$title)
  repo_url <- gsub("[<>]", "", metadata$repository)
  description_text <- paste(description_text,
                           sprintf('<p><p>Repository: <a href="%s">%s</a>',
                                   repo_url, repo_url))
  myrec$setDescription(description_text)
  myrec$setSubjects(subjects= c("CODECHECK"))
  myrec$setNotes(notes = c("See file LICENSE for license of the contained code. The report document codecheck.pdf is published under CC-BY 4.0 International."))
  ##myrec$setAccessRight(accessRight = "open")
  ##myrec$addRelatedIdentifier(relation = "isSupplementTo", identifier = metadata$repository)
  ##myrec$addRelatedIdentifier(relation = "isSupplementTo", identifier = metadata$paper$reference)
  cat(paste0("Check your record online at ",  myrec$links$self_html, "\n"))
  myrec <- zen$depositRecord(myrec)

}


record = get_zenodo_record(metadata$report)




myrec <- zenodo$depositRecord(myrec, publish = FALSE)




## If you have already uploaded the certificate once, you will need to
## delete it via the web page before uploading it again.
codecheck:::set_zenodo_certificate(zenodo, my_rec, "codecheck.pdf")
## this could be checked...

## You may also create a ZIP archive of of any data or code files that
## you think should be included in the CODECHECK's record.

## Now go to zenodo and check the record (the URL is printed
## by set_zenodo_metadata() ) and then publish.



## find the list of languages supported
zenodo$getLanguages()

l <- zenodo$getLicenses()
