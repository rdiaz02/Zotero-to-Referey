## Copyright  2017-2024 Ramon Diaz-Uriarte

## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU Affero General Public License as published
## by the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## You should have received a copy of the GNU Affero General Public
## License along with this program.  If not, see
## <http://www.gnu.org/licenses/>.


## 2025-12-19: a minimal script to generate the ZCol data frame
## that I use with ebib.



## 2022-07-08: Exporting only libraryID == 1

## This is very quick hack. I will only export those with libraryID = 1
## I think libraryID = 1 is the "primary library". I've started using group
## libraries, and if I export all, it upsets sorting by date added (as the ones
## in the new library are much more recent, even if the original paper was in my
## library long ago).

## If you want to export all libraries, got to line
## where it says "Only libraryID == 1". Comment the next four lines
## and uncomment the line after "If you want all libraries"


## I guess more sophisticated schemes would be possible, like getting the
## libraryID name, and putting that in a field of Mendeley. Not now, as I do not
## need it.


## This script is often called from another script (e.g.,
## run-zotero-to-referey.sh) that passes appropriate command line
## arguments with names of input and output files. If you run this from an
## R session or the shell without passing arguments, you might want to
## modify some defaults marked as  MODIFY THIS.

cat("\n Job started at ", date(), "\n")

ca <- commandArgs(trailingOnly = TRUE)
if (length(ca) == 1) { ## Run from a script, passing arguments
    c1 <- strsplit(ca[1], "=")[[1]]
    if (c1[1] != "ZOTTMP")
      stop("First argument must be ZOTTMP=sometmpfile")
    conZf <- c1[2]

    cat("\n Using files supplied via command line arguments\n")
} else { ## Run interactively from R
  ##     #######   MODIFY THIS     #######
  ## Ideally, you should only need to modify these three lines.
  ## Name of Zotero sqlite. For safety, we use a copy
  ## Same as variable ZOTTMP
  conZf <- paste0(Sys.getenv("ZOTERO_REFEREY_TMPDIR"), "/zotero-cp.sqlite")
    ## FIXME: rm  conRf <- "minimal-Referey.sqlite"
}

## End of configuration part

library(parallel)
library(uuid, quietly = TRUE, verbose = FALSE, warn.conflicts = FALSE)
library(RSQLite, quietly = TRUE, verbose = FALSE, warn.conflicts = FALSE)
library(reshape2, quietly = TRUE, verbose = FALSE, warn.conflicts = FALSE)
library(dplyr, quietly = TRUE, verbose = FALSE, warn.conflicts = FALSE)
library(digest, quietly = TRUE, verbose = FALSE, warn.conflicts = FALSE)

conZ <- dbConnect(SQLite(), conZf)



#### Getting and processing Zotero's data

lid <- dbGetQuery(conZ, "
SELECT * FROM itemData
INNER JOIN itemDataValues using (valueID)
INNER JOIN fields using (fieldID)
")[, c(1, 4, 5)]


ZCol <- dbReadTable(conZ, "collections")[, c(1, 2, 3)]
ZCol$parentCollectionID[is.na(ZCol$parentCollectionID)] <- -1

cat("\n Job finished at ", date(), "\n")

## If you want to export
## collections as an Emacs org-mode file. See file
## export_zotero_collections_to_org.R
save(file = Sys.getenv("ZCOL_RDATA"), ZCol)
