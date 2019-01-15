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
## Create a backup in case minor disasters happen
REFEREY3_BKP="/home/ramon/Sync-tablet/Zot-Referey-BQ/referey-bq.sqlite_bckp"


REFEREY4="/home/ramon/Sync-tablet/Zot-Referey-S3/referey-s3.sqlite"
REFEREY4_BKP="/home/ramon/Sync-tablet/Zot-Referey-S3/referey-s3.sqlite_bckp"


## I assume the R code, in zotero-to-referey.R, lives in the same place as
## this script. I assume you want to leave the output there as well.
BASEDIR=$(dirname $BASH_SOURCE)


ZOTTMP=$TMPDIR/zotero-cp.sqlite
REFEREYSQLITE=$TMPDIR/minimal-Referey.sqlite

cp $ZOTSQLITE $ZOTTMP


cp $REFEREY3 $REFEREY3_BKP
cp $REFEREY4 $REFEREY4_BKP




## substitute zotero5-to-referey.R bu zotero-to-referey.R if you are using Zotero 4
R --slave --args ZOTTMP=$ZOTTMP REFEREYSQLITE=$REFEREYSQLITE < $BASEDIR/zotero5-to-referey.R &> $BASEDIR/zotero-to-referey.Rout

cp $REFEREYSQLITE $REFEREY1
## cp $REFEREYSQLITE $REFEREY2
cp $REFEREYSQLITE $REFEREY3

cp $REFEREYSQLITE $REFEREY4

