#!/bin/bash

## Copies the zotero.sqlite file (ZOTSQLITE) to a temporary directory
## (TMPDIR) and runs zotero-to-referey.R, producing as output a sqlite for
## Referey (left in the TMPDIR).  Then it copies this file to the files
## for the Android tablets (REFEREY1, REFEREY2).

ZOTSQLITE="/home/ramon/Zotero-data/zotero.sqlite"
TMPDIR="/home/ramon/tmp"

REFEREY1="/home/ramon/Sync-tablet/Zot-Referey-Nexus/referey-nexus.sqlite"
## REFEREY2="/home/ramon/Files-to-tablet/referey-tf.sqlite"
REFEREY3="/home/ramon/Sync-tablet/Zot-Referey-BQ/referey-bq.sqlite"


## I assume the R code, in zotero-to-referey.R, lives in the same place as
## this script. I assume you want to leave the output there as well.
BASEDIR=$(dirname $BASH_SOURCE)


ZOTTMP=$TMPDIR/zotero-cp.sqlite
REFEREYSQLITE=$TMPDIR/minimal-Referey.sqlite

cp $ZOTSQLITE $ZOTTMP

## substitute zotero5-to-referey.R bu zotero-to-referey.R if you are using Zotero 4
R --slave --args ZOTTMP=$ZOTTMP REFEREYSQLITE=$REFEREYSQLITE < $BASEDIR/zotero5-to-referey.R &> $BASEDIR/zotero-to-referey.Rout

cp $REFEREYSQLITE $REFEREY1
## cp $REFEREYSQLITE $REFEREY2
cp $REFEREYSQLITE $REFEREY3

