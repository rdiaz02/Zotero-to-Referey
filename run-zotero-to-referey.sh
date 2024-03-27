#!/bin/bash

## Copies the Zotero sqlite file ($ZOTERO_SQLITE) to a temporary file
## (ZOTTMP) and runs zotero-to-referey.R, producing as output a sqlite for
## Referey (left in the TMPDIR).  Then it copies this file to the files
## for the Android tablet(s) (REFEREY1, REFEREY2, ...).

######################### Variables
## The value of these variables is taken from environment variables
## if not specified here.

ZOT_SQLITE=$ZOTERO_SQLITE
TMPDIR=$ZOTERO_REFEREY_TMPDIR
ZOTTMP=$TMPDIR/zotero-cp.sqlite

## Output from R: sqlite for Referey
REFEREYSQLITE=$TMPDIR/minimal-Referey.sqlite
## A copy of $REF_SQLITE that will be sent to the tablet
REFEREY_TABLET=$REFEREY_DB1
REFEREY_TABLET_BCKP=$REFEREY_DB1_BKP

## I assume the R code, in zotero-to-referey.R, lives in the same place as
## this script. I assume you want to leave the output there as well.
BASEDIR=$(dirname $BASH_SOURCE)

######################### Run

## For safety, input to the R script is a temporary copy of the
## zotero sqlite DB.
cp "$ZOT_SQLITE" "$ZOTTMP"

## Create a backup in case minor disasters happen
## This gives an error the first time it is run,
## since $REFEREY1_DB1 does not exist
cp "$REFEREY_TABLET" "$REFEREY_TABLET_BCKP"

R --vanilla -s --args ZOTTMP=$ZOTTMP REFEREYSQLITE=$REFEREYSQLITE < $BASEDIR/zotero-5-to-referey.R &> $BASEDIR/zotero-to-referey.Rout

cp $REFEREYSQLITE $REFEREY_TABLET






