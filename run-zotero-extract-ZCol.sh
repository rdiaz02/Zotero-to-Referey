#!/bin/bash

## 2025-12-19: a minimal script to generate the ZCol data frame
## that I use with ebib.



## Copies the Zotero sqlite file ($ZOTERO_SQLITE) to a temporary file
## (ZOTTMP) and runs zotero-to-referey.R, producing as output a sqlite for
## Referey (left in the TMPDIR).  Then it copies this file to the files
## for the Android tablet(s) (REFEREY1, REFEREY2, ...).

######################### Variables
## The value of these variables is taken from environment variables
## if not specified here.

ZOT_SQLITE=$ZOTERO_SQLITE
ZOTTMP=$TMPDIR/zotero-cp.sqlite

## I assume the R code, in zotero-to-referey.R, lives in the same place as
## this script. I assume you want to leave the output there as well.
BASEDIR=$(dirname $BASH_SOURCE)

######################### Run

## For safety, input to the R script is a temporary copy of the
## zotero sqlite DB.
cp "$ZOT_SQLITE" "$ZOTTMP"


R --vanilla -s --args ZOTTMP=$ZOTTMP < $BASEDIR/zotero-ZCol.R &> $BASEDIR/zotero-ZCol.Rout
