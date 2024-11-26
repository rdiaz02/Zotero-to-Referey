## This code writes an Emacs org-mode file with the collections.
## I find this useful when using ebib, citar, or helm-bibtex
## to keep track of the Zotero collections.
## I can even display it sideways relative to my ebib display.

## Run this after ZCol is created and filled.
## Last line is ZColItems <- dbReadTable(conZ, "collectionItems")
## Or run by loading that object and running this code.

zcol_RData <- Sys.getenv("ZCOL_RDATA")
out <- Sys.getenv("ZOTERO_COLLECTIONS_ORG_FILENAME")

ZCol_2_org_mode <- function(ZCol, FILENAME_Zot_Collections) {
  ## To allow playing if I do not use the function
  ZCol0 <- ZCol

  ## Logic
  ## 1. Create an igraph object
  ## 2. A matrix with all paths to the leaves
  ## 3. In the matrix, leave only the names of the unique elements
  ## 4. Write as org

  ## 1. igraph object using the names (not numeric IDs)
  tmp_CN_ID <- c(ZCol0$collectionName, "My_Library")
  names(tmp_CN_ID) <- c(as.character(ZCol0$collectionID), "-1")
  ZCol0$parentCollectionName <- tmp_CN_ID[as.character(ZCol0$parentCollectionID)]
  ZCol01 <- ZCol0[, c("parentCollectionName", "collectionName")]

  require(igraph)
  g1 <- graph_from_data_frame(data.frame(From = ZCol01$parentCollectionName,
                                         To = ZCol01$collectionName))

  ## 2. Matrix with paths
  ##   2.1 Paths to leaves
  root <- "My_Library"
  leaves <- V(g1)[degree(g1, mode="out")==0]
  allp <- all_simple_paths(g1, from = root, to = leaves)
  np <- lapply(allp, names)
  maxd <- max(unlist(lapply(np, length)))

  ##  2.2 Matrix of paths
  m1 <- matrix("", nrow = length(np), ncol = maxd)
  for (i in 1:length(np)) {
    ## The "ZZZZZZZZ" is to ease sorting
    m1[i, ] <- c(np[[i]], rep("ZZZZZZZZ", maxd - length(np[[i]])))
  }
  ## 2.3 Matrix of paths, sorted alphabetically
  m2 <- m1[do.call(order, as.data.frame(m1)), ]
  m2[m2 == "ZZZZZZZZ"] <- ""
  ## rm "My_Library"
  m3 <- m2[, -1]


  ## 3. Matrix: leave only the unique, first elements, and star
  ##    them as required for org

  ## x: column; stars: number of stars
  replace_by_single_entry <- function(x, stars) {
    tmp <- rle(x)
    out <- NULL
    for (i in 1:length(tmp$values)) {
      value <- ifelse(tmp$values[i] == "",
                      "",
                      paste0(paste(rep("*", stars), collapse = ""),
                             " ", tmp$values[i]))
      out <- c(out, c(value, rep("", tmp$lengths[i] - 1)))
    }
    return(out)
  }

  m4 <- m3

  for (cc in 1:ncol(m3)) {
    m4[, cc] <- replace_by_single_entry(m3[, cc], cc)
  }

  ## 4. Write as org. As a compact file, without unneeded newlines
  mat_to_vec_org <- function(x) {
    out <- NULL
    xt <- t(x)
    lxt <- length(xt)
    for (i in 1:lxt) {
      ## if (xt[i] != "") out <- c(out, paste0("\n", xt[i]))
      if (xt[i] != "") out <- c(out, xt[i])
    }
    return(out)
  }

  writeLines(mat_to_vec_org(m4), con = FILENAME_Zot_Collections)
}

load(zcol_RData)
ZCol_2_org_mode(ZCol, out)



######################################################################
##  We could try reading the RDF but that is much more of a mess

## ## Locate the first "<z:Collection rdf"

## f1 <- readLines(THE_NAME_OF_THE_RDF)

## first_hit <- which(grepl("<z:Collection rdf:about", f1, fixed = TRUE))[1]
## f2 <- f1[first_hit:length(f1)]


## get_coll_id <- function(x) {
##   as.numeric(gsub(" ", "",
##                   gsub("\">", "",
##                        gsub("<z:Collection rdf:about=\"#collection_",
##                             "", x, fixed = TRUE),
##                        fixed = TRUE)))
##   ## as.numeric(
##   ##   strsplit(
##   ##     strsplit(x,
##   ##              "<z:Collection rdf:about=\"#collection_",
##   ##              fixed = TRUE)[[1]][2], "\">", fixed = TRUE)[[1]][1])
## }

## get_coll_name <- function(x) {
##   tmp <- gsub("</dc:title>", "", gsub("<dc:title>", "", x,
##                                       fixed = TRUE),
##               fixed = TRUE)
##   return(gsub(" ", "", tmp))
## }

## collection_id <- vector("character", length = length(f2))
## collection_name <- vector("character", length = length(f2))
## j <- 0
## for (i in 1:length(f2)) {

##   if (grepl("<z:Collection rdf:about=\"#collection",
##             f2[i], fixed = TRUE)) {
##     j <- j + 1
##     collection_id[j] <- get_coll_id(f2[i])
##     collection_name[j] <- get_coll_name(f2[i + 1])
##   }
## }

## collection_id <- collection_id[1:j]
## collection_name <- collection_name[1:j]


## text_out <- vector("character", length = length(f2))
## t <- 0

## for (i in 1:length(f2)) {
##   if (grepl("<z:Collection rdf:about=\"#collection",
##             f2[i], fixed = TRUE)) {
##     t <- t + 1

##   }
## }

## This will end up being more of a pain than using
## the sqlite db.
