## Copyright  2015 Ramon Diaz-Uriarte

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




## This script is often called from another script (e.g.,
## run-zotero-to-referey.sh) that passes appropriate command line
## arguments with names of input and output files. If you run this from an
## R session or the shell without passing arguments, you might want to
## modify some defaults marked as  MODIFY THIS.

cat("\n Job started at ", date(), "\n")

ca <- commandArgs(trailingOnly = TRUE)
if(length(ca) == 2) {
    c1 <- strsplit(ca[1], "=")[[1]]
    if(c1[1] != "ZOTTMP")
        stop("First argument must be ZOTTMP=sometmpfile")
    conZf <- c1[2]
    c2 <- strsplit(ca[2], "=")[[1]]
    if(c2[1] != "REFEREYSQLITE")
        stop("First argument must be REFEREYSQLITE=somefile")
    conRf <- c2[2]
    cat("\n Using files supplied via command line arguments\n")
} else {
    ##     #######   MODIFY THIS     #######
    ## Ideally, you should only need to modify these three lines.
    ## Name of Zotero sqlite. For safety, we use a copy
    conZf <- "~/tmp/zotero-cp.sqlite"
    ## Directory for all temp stuff
    setwd("~/tmp/")
    ## Name of sqlite for Referey, left under the temporary
    ## directory. Will be deleted and overwritten
    conRf <- "minimal-Referey.sqlite"
}

## End of configuration part 




library(uuid, quietly = TRUE, verbose = FALSE, warn.conflicts = FALSE)
library(RSQLite, quietly = TRUE, verbose = FALSE, warn.conflicts = FALSE)
library(reshape2, quietly = TRUE, verbose = FALSE, warn.conflicts = FALSE)
library(dplyr, quietly = TRUE, verbose = FALSE, warn.conflicts = FALSE)
library(digest, quietly = TRUE, verbose = FALSE, warn.conflicts = FALSE)

conZ <- dbConnect(SQLite(), conZf)
## tablesZ <- dbListTables(conZ)



######################################################################
######################################################################
######################################################################


fd <- function(x) {
    ## A kludge to get year, date, month
    v <- as.integer(unlist(strsplit(strsplit(x, " ")[[1]][1], "-")))
    if((length(v) == 1) && (is.na(v)))
        return(c(NA, NA, NA))
    else
        return(v)
}

fillTable <- function(table, input, namecon = minimalReferey) {
    dbWriteTable(namecon, table, input, append = TRUE)
}

createTable <- function(text, namecon = minimalReferey) {
    ## saves a few characters of typing
    dbSendQuery(namecon, text)
}

ZtoDocuments <- function(Z = ZfullWideNoAttach) {
    ## For now, a lot is left unfilled as I don't particularly care
    data.frame(
        id = Z$itemID,
	confirmed =	"true",
	deletionPending =	"false",
	favourite =	NA,
	read =	"true",
	onlyReference =	"false",
	type =	Z$typeName,
	uuid =	replicate(nrow(Z), UUIDgenerate()), ##?with {}
	abstract =	Z$abstractNote,
	added =	Z$added,
	modified =	Z$modified,
	importer =	NA,
	note =	NA, ## this would require pasting all Zotero's notes
	privacy =	"NormalDocument",
	title =	Z$title,
	advisor =	NA,
	articleColumn =	NA,
	applicationNumber =	NA,
	arxivId =	NA,
	chapter =	NA,
	citationKey =	NA, ###?
	city =	Z$place,
	code =	NA,
	codeNumber =	NA,
	codeSection =	NA,
	codeVolume =	NA,
	committee =	NA,
	counsel =	NA,
	country =	NA,
	dateAccessed =	NA,
	department =	NA,
	doi =	Z$DOI,
	edition =	Z$edition,
	genre =	NA,
	hideFromMendeleyWebIndex =	NA,
	institution =	Z$institution,
	internationalAuthor =	NA, #?
	internationalNumber =	NA,
	internationalTitle =	NA, ##?
	internationalUserType =	NA,
	isbn =	Z$ISBN,
	issn =	Z$ISSN,
	issue =	Z$issue,
	language =	Z$language,
	lastUpdate =	NA,
	legalStatus =	NA,
	length =	Z$numPages,
	medium =	NA,
	month =	Z$month,
	originalPublication =	NA,
	owner =	NA,
	pages =	Z$pages,
	pmid =	NA,
	publication =	Z$publicationTitle,
	publicLawNumber =	NA,
	publisher =	Z$publisher,
	reprintEdition =	NA,
	reviewedArticle =	NA,
	revisionNumber =	NA,
	sections =	NA,
	seriesEditor =	NA,
	series =	Z$series,
	seriesNumber =	Z$seriesNumber,
	session =	NA,
	shortTitle =	Z$shortTitle,
	sourceType =	NA,
	userType =	NA,
	volume =	Z$volume,
	year =	Z$year,
	day =	Z$day,
	deduplicated =	0)
}

ZtoFiles <- function(Z = ZAttach) {
    return(data.frame(hash = Z$hash,
                      localURL = Z$pathLast))
}

ZtoDocumentFiles <- function(Z = ZAttach) {
    return(data.frame(
        documentId = Z$sourceItemID,
        hash = Z$hash,
        unlinked = "false",
        downloadRestricted = "false",
        remoteFileUuid = " "
    ))
}

ZtoDocumentTags <- function(Z = ZTags) {
    return(data.frame(
        documentId = Z$itemID,
        tag = Z$name
    ))
}

ZtoDocumentContributors <- function(Z = ZAuthors) {
    return(data.frame(
        ## id = Z$creatorID, ## uniqueness is required!
        id = seq_len(nrow(Z)),
        documentId = Z$itemID,
        contribution = Z$contribution,
        firstNames = Z$firstName,
        lastName = Z$lastName
    ))
}

ZtoDocumentUrls <- function(Z = ZfullWideNoAttach) {
    Z <- na.omit(Z[, c("itemID", "url")])
    return(data.frame(
        documentId = Z$itemID,
        position = 0,
        url = Z$url
    ))
}

ZtoDocumentFolders <- function(Z = ZColItems) {
    return(data.frame(
        documentId = Z$itemID,
        folderId = Z$collectionID,
        status = "ObjectUnchanged"))
}

ZtoFolders <- function(Z = ZCol) {
    return(data.frame(
        id = Z$collectionID,
        uuid = paste0("{",
                      replicate(nrow(Z), UUIDgenerate()),
                      "}"),
        name = Z$collectionName,
        parentId = Z$parentCollectionID,
        access = "PrivateAccess",
        syncPolicy = "SyncFilesInSelectedCollections",
        downloadFilesPolicy = "false",
        uploadFilesPolicy = "false",
        publicUrl = "",
        description = "",
        creatorName = "",
        creatorProfileUrl = "" 
    ))
}

fillRemoteDocuments <- function(documentId,
                                namecon = minimalReferey){
    df <- data.frame(documentId = documentId,
                     remoteId = seq_along(documentId),
                     remoteUuid = replicate(length(documentId),
                                            UUIDgenerate()),
                     groupId = 0,
                     status = "ObjectUnchanged",
                     inTrash = "false"
                     )
  dbWriteTable(namecon, "RemoteDocuments", df,
               append = TRUE)  
}

fillRemoteFolders <- function(folderId,
                              namecon =minimalReferey) {
    df <- data.frame(folderId = folderId,
                     remoteUuid = replicate(length(folderId),
                                            UUIDgenerate()),
                     remoteId = seq_along(folderId),
                     parentRemoteId = 0,
                     groupId = 0,
                     status = "ObjectUnchanged",
                     version = -99999999
                     )
  dbWriteTable(namecon, "RemoteFolders", df,
               append = TRUE)  
}
######################################################################
######################################################################
######################################################################


#### Getting and processing Zotero's data

lid <- dbGetQuery(conZ, "
SELECT * FROM itemData
INNER JOIN itemDataValues using (valueID)
INNER JOIN fields using (fieldID)
")[, c(1, 4, 5)]
wideItemData <- dcast(lid, itemID ~ fieldName)
## not the fastest
## wideItemData <- with(lid, tapply(value, list(itemID, fieldName), identity))
## library(tidyr) ## slower than dcast?
## w3 <- spread(lid, fieldName, value)
##
## I'll need to play with dates, as Mendeley uses milliseconds since 1970
## but Zotero uses a decent date.
## iner or left outer are the same, of course, in this case
## items2 <- dbGetQuery(conZ, "
##           select * from items
##           left outer join itemTypes using (itemTypeID)
##           ")[, c(1, 2, 8, 7, 3, 4)]
items1 <- dbGetQuery(conZ, "
          select * from items
          inner join itemTypes using (itemTypeID)
          ")[, c(1, 2, 8, 7, 3, 4)]
## Nope, do not use milliseconds for Referey.
items1$added <- as.numeric(difftime(items1$dateAdded, "1970-01-01",
                                    units = "secs")) # * 1000
items1$modified <- as.numeric(difftime(items1$dateModified, "1970-01-01",
                                       units = "secs")) # * 1000
colnames(items1)[4] <- "directory"
items1 <- items1[, c(1:4, 7, 8)]
## ## Some checks 
## setdiff(wideItemData$itemID, items1$itemID)
## ## And these?
## setdiff(items1$itemID, wideItemData$itemID )
## ## those are all notes
## table(items1[items1$itemID %in%
##              setdiff(items1$itemID, wideItemData$itemID ), ]$typeName)
## ## and there is nothing in those directories anyway. Seems gone.
fullWide <- left_join(wideItemData, items1, by = "itemID")
dd <- t(sapply(fullWide$date, fd))
fullWide$year <- dd[, 1]
fullWide$month <- dd[, 2]
fullWide$day <- dd[, 3]
rm(dd)

ZfullWideNoAttach <- fullWide[fullWide$typeName != "attachment", ]
MendeleyColumnNames=c("itemID", "typeName", "abstractNote", "added", "modified", "title", "place", "DOI", "edition", "institution", "ISBN", "ISSN", "issue", "language", "numPages", "month", "pages", "publicationTitle", "publisher", "series", "seriesNumber", "shortTitle", "volume", "year", "day")
ZfullWideNoAttach[,setdiff(MendeleyColumnNames,names(ZfullWideNoAttach))]=NA

## Attachments
ZAttach <- fullWide[fullWide$typeName == "attachment",
                    c("itemID", "directory", "title")]
zia <- dbReadTable(conZ, "itemAttachments")[, c(1, 2, 6)]
if(length(setdiff(zia$itemID, ZAttach$itemID)) > 0)
    stop("zia > ZAttach")
if(length(setdiff(ZAttach$itemID, zia$itemID)) > 0)
    stop("ZAttach > zia")
ZAttach <- left_join(ZAttach, zia, by = "itemID")
## htmls for snapshots and some PDFs do not have the name in title
ZAttach$fileName <- unlist(sapply(ZAttach$path,
                                  function(x) {strsplit(x, "storage:")[[1]][2]}))
## FIXME: would sep need to be different for Windoze? But this affects Androids.
## No idea.
ZAttach$pathLast <- with(ZAttach, paste(directory, fileName, sep = "/"))
ZAttach$hash <- sapply(ZAttach$pathLast, digest)

## Closes #7.
ZAttach <- subset(ZAttach,sourceItemID>0)
ZTags <- left_join(dbReadTable(conZ, "itemTags"),
                   dbReadTable(conZ, "tags")[, c(1, 2)],
                   by = "tagID")
## I think Mendeley has them sorted by number of tags
count <- data.frame(table(ZTags$itemID))
count[, 1] <- as.numeric(as.character(count[, 1]))
colnames(count)[1] <- "itemID"
ZTags <- left_join(ZTags, count, by = "itemID")
ZTags <- ZTags[order(ZTags$Freq, ZTags$itemID), 1:3]
rownames(ZTags) <- NULL


ZAuthors <- left_join(dbReadTable(conZ, "itemCreators"),
                      dbReadTable(conZ, "creators")[, c(1, 2)],
                      by = "creatorID")
## Mendeley only seems to use "DocumentAuthor" and "DocumentEditor"
## which I think are "author + contributor" and "editor + seriesEditor"
## which are (see "creatorTypes") 1 and 2 and 3 and 5. I map those explicitly
## and do nothing with the rest.
ZAuthors <- left_join(ZAuthors,
                      dbReadTable(conZ, "creatorTypes"),
                      by = "creatorTypeID")
ZAuthors$contribution <- ZAuthors$creatorType
ZAuthors$contribution[ZAuthors$contribution %in% c("author", "contributor")] <-
    "DocumentAuthor"
ZAuthors$contribution[ZAuthors$contribution %in% c("editor", "seriesEditor")] <-
    "DocumentEditor"
ZAuthors <- left_join(ZAuthors,
                     dbReadTable(conZ, "creatorData")[, c(1, 2, 3)],
                     by = "creatorDataID")


ZCol <- dbReadTable(conZ, "collections")[, c(1, 2, 3)]
ZCol$parentCollectionID[is.na(ZCol$parentCollectionID)] <- -1
ZColItems <- dbReadTable(conZ, "collectionItems")


######################################################################
######################################################################
######################################################################
try(dbDisconnect(minimalReferey), silent = TRUE)
try(file.remove(conRf), silent = TRUE)
if(exists("minimalReferey"))
    try(rm("minimalReferey"))
minimalReferey <- dbConnect(SQLite(), conRf)
createTable(
'CREATE TABLE "Documents" (
	id	INTEGER PRIMARY KEY AUTOINCREMENT,
	confirmed	INT,
	deletionPending	INT,
	favourite	INT,
	read	INT,
	onlyReference	INT,
	type	VARCHAR,
	uuid	VARCHAR NOT NULL UNIQUE,
	abstract	VARCHAR,
	added	INT,
	modified	INT,
	importer	VARCHAR,
	note	VARCHAR,
	privacy	VARCHAR,
	title	VARCHAR,
	advisor	VARCHAR,
	articleColumn	VARCHAR,
	applicationNumber	VARCHAR,
	arxivId	VARCHAR,
	chapter	VARCHAR,
	citationKey	VARCHAR,
	city	VARCHAR,
	code	VARCHAR,
	codeNumber	VARCHAR,
	codeSection	VARCHAR,
	codeVolume	VARCHAR,
	committee	VARCHAR,
	counsel	VARCHAR,
	country	VARCHAR,
	dateAccessed	VARCHAR,
	department	VARCHAR,
	doi	VARCHAR,
	edition	VARCHAR,
	genre	VARCHAR,
	hideFromMendeleyWebIndex	INT,
	institution	VARCHAR,
	internationalAuthor	VARCHAR,
	internationalNumber	VARCHAR,
	internationalTitle	VARCHAR,
	internationalUserType	VARCHAR,
	isbn	VARCHAR,
	issn	VARCHAR,
	issue	VARCHAR,
	language	VARCHAR,
	lastUpdate	VARCHAR,
	legalStatus	VARCHAR,
	length	VARCHAR,
	medium	VARCHAR,
	month	INT,
	originalPublication	VARCHAR,
	owner	VARCHAR,
	pages	VARCHAR,
	pmid	BIGINT,
	publication	VARCHAR,
	publicLawNumber	VARCHAR,
	publisher	VARCHAR,
	reprintEdition	VARCHAR,
	reviewedArticle	VARCHAR,
	revisionNumber	VARCHAR,
	sections	VARCHAR,
	seriesEditor	VARCHAR,
	series	VARCHAR,
	seriesNumber	VARCHAR,
	session	VARCHAR,
	shortTitle	VARCHAR,
	sourceType	VARCHAR,
	userType	VARCHAR,
	volume	VARCHAR,
	year	INT,
	day	INT,
	deduplicated	INT
)
')
createTable('CREATE TABLE "Files" (
	hash	CHAR[40],
	localUrl	VARCHAR NOT NULL,
	PRIMARY KEY(hash)
)')
## Yes, I use "" so I can use '' at end
createTable("CREATE TABLE `DocumentFiles` (
	`documentId`	INTEGER NOT NULL,
	`hash`	CHAR[40] NOT NULL,
	`unlinked`	BOOLEAN NOT NULL,
	`downloadRestricted`	BOOLEAN NOT NULL DEFAULT 0,
	`remoteFileUuid`	CHAR[38] NOT NULL DEFAULT ''
)")
createTable('CREATE TABLE "DocumentTags" (
	documentId	INTEGER NOT NULL,
	tag	VARCHAR NOT NULL,
	PRIMARY KEY(documentId,tag)
)')
createTable('
CREATE TABLE "DocumentContributors" (
	id	INTEGER,
	documentId	INTEGER NOT NULL,
	contribution	VARCHAR NOT NULL,
	firstNames	VARCHAR,
	lastName	VARCHAR NOT NULL,
	PRIMARY KEY(id)
)
')
createTable('CREATE TABLE "DocumentUrls" (
	documentId	INTEGER NOT NULL,
	position	INTEGER NOT NULL,
	url	VARCHAR NOT NULL,
	PRIMARY KEY(documentId,position)
)')
createTable(
'CREATE TABLE "Folders" (
	id	INTEGER PRIMARY KEY AUTOINCREMENT,
	uuid	VARCHAR UNIQUE,
	name	VARCHAR NOT NULL,
	parentId	INTEGER,
	access	VARCHAR NOT NULL,
	syncPolicy	VARCHAR NOT NULL,
	downloadFilesPolicy	INTEGER NOT NULL,
	uploadFilesPolicy	INTEGER NOT NULL,
	publicUrl	VARCHAR,
	description	VARCHAR,
	creatorName	VARCHAR,
	creatorProfileUrl	VARCHAR
)'
)
createTable('
CREATE TABLE "DocumentFolders" (
	documentId	INTEGER NOT NULL,
	folderId	INTEGER NOT NULL,
	status	VARCHAR NOT NULL DEFAULT ObjectCreated,
	PRIMARY KEY(documentId,folderId)
)
')
## We only need the documentId
createTable('CREATE TABLE "RemoteDocuments" (
	documentId	INTEGER,
	remoteId	INTEGER,
	remoteUuid	VARCHAR UNIQUE,
	groupId	INTEGER NOT NULL,
	status	VARCHAR NOT NULL,
	inTrash	BOOLEAN NOT NULL,
	PRIMARY KEY(documentId,remoteUuid)
)')
### Next are created, but never populated. Referey needs them to be there.
createTable('
CREATE TABLE "RemoteFolders" (
	folderId	INTEGER,
	remoteUuid	VARCHAR UNIQUE,
	remoteId	INTEGER,
	parentRemoteId	INTEGER,
	groupId	INTEGER,
	status	VARCHAR NOT NULL,
	version	INTEGER NOT NULL,
	PRIMARY KEY(folderId)
)
')
createTable('
CREATE TABLE "Groups" (
	id	INTEGER PRIMARY KEY AUTOINCREMENT,
	remoteId	INTEGER,
	remoteUuid	VARCHAR UNIQUE,
	name	VARCHAR,
	groupType	VARCHAR NOT NULL,
	status	VARCHAR NOT NULL,
	access	VARCHAR NOT NULL,
	syncPolicy	VARCHAR NOT NULL,
	downloadFilesPolicy	INTEGER NOT NULL,
	uploadFilesPolicy	INTEGER NOT NULL,
	publicUrl	VARCHAR,
	isOwner	BOOL NOT NULL,
	isReadOnly	BOOLEAN NOT NULL,
	isPrivate	BOOLEAN NOT NULL,
	iconName	VARCHAR
)
')
createTable('
CREATE TABLE "DocumentCanonicalIds" (
	documentId	INTEGER,
	canonicalId	INTEGER NOT NULL,
	timestamp	INTEGER NOT NULL,
	PRIMARY KEY(documentId)
)')
createTable('CREATE TABLE "DocumentKeywords" (
	documentId	INTEGER NOT NULL,
	keyword	VARCHAR NOT NULL,
	PRIMARY KEY(documentId,keyword)
)')
createTable('CREATE TABLE "FileNotes" (
	id	INTEGER PRIMARY KEY AUTOINCREMENT,
	author	VARCHAR,
	uuid	CHAR[38] NOT NULL UNIQUE,
	documentId	INTEGER NOT NULL,
	fileHash	CHAR[40] NOT NULL,
	page	INTEGER NOT NULL,
	x	FLOAT NOT NULL,
	y	FLOAT NOT NULL,
	note	VARCHAR NOT NULL,
	modifiedTime	VARCHAR NOT NULL,
	createdTime	VARCHAR NOT NULL,
	unlinked	BOOLEAN NOT NULL,
	baseNote	VARCHAR,
	FOREIGN KEY(documentId) REFERENCES Documents ( id )
)')

fillTable("Documents", ZtoDocuments()) 
fillTable("Files", ZtoFiles()) 
fillTable("DocumentContributors", ZtoDocumentContributors()) 
fillTable("Folders", ZtoFolders())
fillTable("DocumentFolders", ZtoDocumentFolders())
try(fillTable("DocumentTags", ZtoDocumentTags())) ## Can fail if same document
                                             ## has same tag repeated, in
                                             ## successive rows in ZTags
fillTable("DocumentFiles", ZtoDocumentFiles()) 
fillTable("DocumentUrls", ZtoDocumentUrls())
fillRemoteDocuments(ZfullWideNoAttach$itemID)
fillRemoteFolders(ZCol$collectionID)

dbSendQuery(minimalReferey,'
  CREATE INDEX DocumentCanonicalids_CanonicalIndex ON DocumentCanonicalids(canonicalid)
')
dbSendQuery(minimalReferey,'
  CREATE INDEX DocumentContributors_DocumentIndex ON
  DocumentContributors (documentId)
')
dbSendQuery(minimalReferey,'
  CREATE INDEX DocumentFiles_DocumentIndex ON DocumentFiles(documentId)
')
dbSendQuery(minimalReferey,'
  CREATE INDEX DocumentFiles_HashIndex ON DocumentFiles(hash)
')
dbSendQuery(minimalReferey,'
  CREATE INDEX FileNotes_DocumentIndex ON FileNotes(documentId)
')
dbSendQuery(minimalReferey,'
  CREATE INDEX FileNotes_FileHashIndex ON FileNotes(fileHash)
')
dbSendQuery(minimalReferey,'
  CREATE INDEX RemoteDocuments_DocumentIndex ON RemoteDocuments(documentId)
')
dbListTables(minimalReferey) ## needed to prevent Closing open result set
dbDisconnect(minimalReferey)


cat("\n Job finished at ", date(), "\n")







