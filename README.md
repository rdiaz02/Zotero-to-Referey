# Zotero to Referey #

_Use Referey on Androids with your Zotero db. Or export your Zotero db in
a way that Referey will be able to use._

The `zotero-to-referey.R` or, if you use Zotero 5, `zotero5-to-referey.R` code will take a [Zotero](http://www.zotero.org)
sqlite database (db) and convert it into a database that
[Referey](https://play.google.com/store/apps/details?id=com.kmk.Referey),
and Android application, can handle.

Before we get going, a **WARNING**: as the license clearly states, this is 
provided without any warranty. The instructions below change paths, 
sync files, etc. I am not responsible if trying to follow these instructions
or using this code destroys your Zotero db, converts the PDFs 
of your collection of scientific papers into unedible cooking recipes,
makes your dishwasher eat your fridge, or whatever. And please,
use common sense (for starters, do a backup).


## New: Zotero 5 (2017-12-28) ##

I have added a new file, **zotero5-to-referey.R** that should work with
Zotero 5. Use this instead of **zotero-to-referey.R** in file
**run-zotero-to-referey.sh**.

## Why ##

I use Android tablets heavily for reading, annotating, and highlighting
PDFs (and most of that time I am offline) and I use this in combination
with some reference management software (Mendeley in the past, Zotero
now). A few essential features for me are:

- Being able to read, annotate, and highlight any PDF in my library while
**offline**, **without** having had to pre-download them before (e.g., I
do not want to spend 10' minutes before I leave the lab thinking what I
might be reading in the train on my way home). This means that any
solution that tries to fetch the PDF from a server when you want to open
it is not acceptable to me.

- Having the **PDFs synced with my computer(s) automagically** as soon as
I am online again. And, of course, having any annotations I make in the
PDFs on my computer(s) show up in my tablets without any manual
intervention.

- Being able to **select entries by collection and/or tag** and **order
  by date** (and, ideally, order by author, or title, and other
  combinations).



## What ##

Referey does exactly what I want but it was designed for Mendeley
dbs. What I have done is take the Zotero db and, from it, generate a
minimal db that Referey can deal with. 

(Does this work with Windows, or Mac or ...? No idea. Most of it should,
but I only use GNU Linux).

## Why Referey ##

Referey makes many things extremely simple and convenient. The user takes
care of syncing the database (db) and the complete directory with all the
PDFs, and Referey works from there. If you use a syncing system that keeps
the db in your tablets updated and that syncs the PDFs back and forth
(e.g., see [Syncthing](#syncthing)), the above requirements are automatically
satisfied. As a plus, I really like the UI of Referey and the many ways of
searching for references, selecting intersections of tags, drilling down
by collection, or searching by the intersection of collection and tag or
searching within subcollections, sorting by several criteria (including
reverse order), etc.



### A better way ###

Note that the author of Referey has made the code available from Github:
[Referey Github Repo](https://github.com/kleinkm/Referey). Thus, as I
mention [below](#improvements), a much better approach than using my code
would be to directly modify the Referey code to allow it to deal with
Zotero's db.




#### The code ####

I do the conversion using R. I use R instead of, say, Python because it is
just simpler for me. The R script **zotero5-to-referey.R** (or
**zotero-to-referey.R**) gets the needed
data from the Zotero sqlite db, modifies/restructures it, and creates a
new db that Referey understands.


You can use the R script **zotero5-to-referey.R** directly (you should only
need to modify the first few lines). However, I have a shell script,
**run-zotero-to-referey.sh**, that is actually in charge of calling the R
script. This script is called automatically whenever there is a change in
the Zotero db (see
[Running automatically](#running-automatically)). **run-zotero-to-referey.sh**
is a bash script and I do not think it will run under Windows (but it
should be easy to adapt it).


There are other reasons to use **run-zotero-to-referey.sh**. It takes care of
making a temporary copy of the Zotero db to a temporary directory and it
copies the output for Referey into two different files (for different
tablets ---reasons in [Syncing](#syncing)).


### Using it (user configuration) and requirements ###

You need to have:
- R
- The following R packages
  - digest
  - uuid
  - RSQLite
  - reshape2
  - dplyr

You will need to specify:
- If using the bash script:
    - The path to your zotero.sqlite file (in variable `ZOTSQLITE`)
    - The temporary directory (variable `TMPDIR`)
    - The full path and names of the files that will be sent to the
      tablest (I use two, called `REFEREY1` and `REFEREY2`; modify as
      needed).
    - You will probably want to modify the bash script to suit your needs
      (e.g., the files to be sent to the tablet(s) or where the output
      from R is left).
- If using the R script directly, modify `conZf`, `conRf`, and possibly
change the working directory (`setwd`) in the lines that follow `##     #######   MODIFY THIS     #######`.




### Configuring Referey ###

There are two basic settings you need to configure in Referey itself:

  - The name of the sqlite file
  - How to deal with paths for the PDFs

Enter the Referey preferences, and set the "Database path" to the path of
the sqlite file.

For the PDFs you need to specify the "PDF folder path" (i.e., the place
relative to where all PDFs and their enclosing directories live) and how
to deal with PDF path levels.

For example, in my case I have the complete Zotero PDF structure residing
under `/sdcard/Zotero-storage` (that is what I enter in "PDF folder
path"), so a particular PDF might be located at
`/sdcard/Zotero/storage/ABCD1234/somefile.pdf`. And since the PDF file
names in the sqlite db are stored as
`eight-capital-letters-and-numbers-directory/name-of-file` (so the above
would be stored in the db as `ABCD1234/somefile.pdf`) in "Preserve PDF
path levels" I have option `folder\file.pdf`.  There are other options
available (just check the preferences help).

#### Configuring Referey in recent (post 2018?) Androids ####

You need access to the "menu burguer" icon (sometimes it looks like a burger
and sometimes like three vertical dots, I think) to configure Refery and specify: a) the location of the 
db; b) the location of the PDF directory (folder); c) what levels of the pdf paths to preserve.
What I do is install a "Menu button" app, so I have access to the "menu" button (often shown as
the "burger" or as three vertical dots). Then, once in the main menu of Referey, pressing the menu
button will give you access to the "Preferences", as well as to "Search" and "Help".


### Syncthing ###

I use [Syncthing](https://syncthing.net/) for syncing. I sync the Zotero
directory from which all the PDFs hang (remember that the structure is
often
`some-directory/eight-capital-letters-and-numbers-directory/the-pdf`; so I
sync `some-directory`). I also sync the dbs for Referey (**NOT** the
Zotero dbs). By syncing the directory of the PDFs all of my PDF
annotations, highlights, etc, are always shared between all machines as
soon as they get back online.

With Zotero,
[as is clearly explained in the documentation](https://www.zotero.org/support/sync),
it is generally OK to sync the directory of the PDFs and attachments
however you see fit, but you should not be syncing the Zotero db yourself
this way. So I sync the directory of the PDFs between computers and
tablets using Syncthing. I also sync the dbs for Referey. But the Zotero
db between computers is synced in the usual Zotero way, and has nothing to
do with this setup.

Why do I make two copies of the dbs for Referey? Referey can make
modifications to the dbs, and in my setup both tablets share a directory
with the computers, so I do not want there to be conflicts or races and
setting up one-way syncs is more trouble than just copying the file.


#### My setup ####

These are the details of my setup, which also explain some paths in the
bash script. I have a `Zotero-data` directory, where the Zotero dbs live
(you can configure this at will in Zotero). In this directory, the
`storage` directory is a symbolic link to the directory
`Zotero-storage`. Now I can sync `Zotero-storage` using Syncthing (without
ever touching the Zotero db itself with Syncthing) between the computers
and the tablets.

I could place the dbs for Referey under `Zotero-storage` but, for reasons
that don't matter here, I have them in another directory called
`Files-to-tablet` which is synced between computers and the tablets.




### Running automatically ###

I want to trigger the creation of a new db for Referey whenever there is a
change in the Zotero db. I use
[inotify-tools](https://github.com/rvoicilas/inotify-tools/wiki) to
monitor `zotero.sqlite` and call the bash script when there are
changes. So as not to forget to run it, I have this line in my `.xsession` file:

     while inotifywait -e close -e modify ~/Zotero-data/zotero.sqlite; do ~/Proyectos/Zotero-to-Referey/run-zotero-to-referey.sh; done &



(You might want to use [entr](http://entrproject.org/), which is nice and
simple, but I was missing some events; it would be triggered at open and
close of Zotero, but not at intermediate changes with Zotero open, such as
reorganizing the library, deleting tags, etc).



### What this won't do ###

In contrast to some of the applications we discuss
[below](#alternative-zotero-and-android-routes), this code does not allow
you to make modifications of your Zotero db from the Android. This is OK
for me but might not be for others.

To repeat: the syncing that is two way is the one of PDFs. The db is not
synced back (so even if you were to make changes to the db in your tablet,
those would not propagate back to your Zotero db).

Of course, it is possible to use this solution AND also run one of the
apps we discuss under [Alternative Zotero and Android routes](#alternative-zotero-and-android-routes) that do
allow you to make changes to your Zotero db. For instance, you could add
tags or notes to an entry (not a PDF) in your Zotero db because of
something that you realized while reading the PDF.



##  Alternatives ##



### Alternative Zotero and Android routes ###

As I said, I recently started using Zotero, coming from Mendeley. When
using Mendeley, I used Referey in the tablets (see
[Zotero, Mendeley, a tablet, et al.](http://ligarto.org/rdiaz/Zotero-Mendeley-Tablet.html)). When
I moved to Zotero,
[I sorely missed the convenience of Referey](https://github.com/rdiaz02/Adios_Mendeley#using-a-tablet).

There are some apps listed under
[Zotero for Mobile](https://www.zotero.org/support/mobile), but none will
do [what I want](#why), at least in Android systems. In fact, I have tried
all of those listed:
[Zandy](http://www.gimranov.com/avram/w/zandy-user-guide),
[Zed](http://www.favand.net/zed),
[Zed Lite](https://play.google.com/store/apps/details?id=net.favand.zedlite),
[Zojo](https://play.google.com/store/apps/details?id=com.phani.zojo),
[Zotfile](http://zotfile.com/), plus
[Zotable](https://play.google.com/store/apps/details?id=com.mattrobertson.zotable.app),
but none satisfy the requirements above. Zandy, Zotable, Zed, and Zed Lite
so far will not allow you to get PDFs that already live locally in your
tablet. Yes, you might be able with some of those apps to fetch PDFs,
either from Zotero's servers, if you keep them there, of using WebDAV from
a user-specified server, but then, that is not a workable solution if you
want offline access to all and any of your PDFs. Zojo seems to have a
[way to access your local PDFs](https://forums.zotero.org/discussion/45461/zojo-an-android-app-for-viewing-citations-stored-at-zotero/), but Zojo does not show
collections or tags (yes, you can search, but I do not find this very
convenient). Zotfile often requires too much manual intervention (see my
[attempts to use Zotfile](http://ligarto.org/rdiaz/Zotero-Mendeley-Tablet.html#sec-6-2)
---this might be that I never actually fully understood how to use
Zotfile) and, even if you manage to automate that, you have the PDFs in
the tablet but you loose the rest of the structure (tags, collections)
from your Zotero db which, again, makes things a lot less useful: I do not
want just the bare PDFs.


Given the above,
[I tried using BibTeX Android applications](https://github.com/rdiaz02/Adios_Mendeley#using-a-tablet).
This idea has been mentioned in other places
([e.g., the comment by smatthie, on 2015-09-15](https://forums.zotero.org/discussion/51234/zotable-a-modern-zotero-client-for-android/?Focus=239548)):
basically, export the Zotero db as a BibTeX file, using the
[Zotero BBT extension](https://zotplus.github.io/better-bibtex/) that
exports Zotero collections as
[JabRef's groups](http://jabref.sourceforge.net/help/GroupsHelp.php), and
use an Android BibTeX app. There are three Android apps that will deal
with BibTeX files but I did not like this solution either. Briefly, of the
available ones,
[Library](https://play.google.com/store/apps/details?id=com.cgogolin.library)
cannot show your Zotero collections or sort by date,
[RefMaster](https://play.google.com/store/apps/details?id=me.bares.refmaster)
does not support more than one file per entry and does not support Zotero
collections, and
[Erathostenes](https://play.google.com/store/apps/details?id=com.mm.eratos)
will only show the lower-most level of collections, is extremely slow, and
often I need to kill and restart it as the app will hang. By extremely
slow I mean that reloading my library of about 3000 references and about
100 collections/groups on an Asus TF201 can take over 40 minutes (10 to load
the db and over 30 to deal with the JabRef groups); a Nexus 7 can do it in
between 10 and 20' total. Changes in Zotero, thus, are painful to update
in the tablets.

When using Referey, in contrast, I launch Referey and load the complete db
in about 20 seconds in the Asus TF201 and 5 in the Nexus. Those are speed
ups of 100x to 200x. And I keep my complete collection structure.


### What about ZotDroid (2017-12-28; 2018-03-25) ###

ZotDroid was announced in the [Zotero forum](https://forums.zotero.org/discussion/67409/zotdroid-a-zotero-client-for-android)
and is available from the Play Store. It seems a very interesting app and
it ought to allow syncing changes back. In addition, it is also possible
to specify a local path for the PDFs (see this comment in the [Zotero forum](https://forums.zotero.org/discussion/comment/285410/#Comment_285410)).

However, I've tried using it with no luck. Basically, it is very slow when
syncing and loading the collection and then it hangs in any of the usual
operations (searching, scrolling, jumping to a collection, etc.). I've
posted these problems in the [Zotero forum](https://forums.zotero.org/discussion/comment/296781/#Comment_296781).

I have tried again with version 1.1.5 (as of 2018-03-25). Still way too slow
for real usage, and it is not possible to use, in a sensible way,
the local collection of PDFs. Sorting and searching are also
very limited compared to Referey. Finally, syncing requires, well,
remembering to sync your collection (i.e., is not something 
that happens automagically via a general syncing solution for the tablet).

See my report of these problems in the [Zotero forum](https://forums.zotero.org/discussion/comment/304449/#Comment_304449).
And it continues to be mostly just a read-only option (i.e., does
not provide anything else beyond my current setup).

So, at least for now, I'll definitely continue using Referey since
ZotDroid is not (yet?) a viable alternative at least for my collection
and/or hardware.

(I just stumbled upon another app, ZotEZ, but is seems it is still in beta
and is also read only; moreover, instructions on how to use a local collection force you to place things
in specific locations. I see no advantage over my currently working setup).

### Doing the Zotero to Referey conversion with Mendeley itself? ###

I tried that too, but it won't work well. You might think, for instance,
about configuring Mendeley to have continuous integration of your Zotero
db, and then launching mendeley whenever there is a change by issuing
something like `mendeleydesktop --sync-then-quit` (yes, you need to sync;
running mendeley offline will not trigger a conversion of the Zotero
db). But this will rarely be a satisfactory experience. Why?

- It is unreliable: I often got crashes (looking at the logs I could not understand what was happening) so that changes in Zotero would actually not propagate.
- Even when it works, it is very slow (can take over 10 minutes to do the
  conversion).
- Mendeley does not import Zotero's collections correctly. This is a
  [well known, more than six years old problem](http://feedback.mendeley.com/forums/4941-general/suggestions/389900-allow-importing-nested-hierarchical-zotero-collect). (I
  must be missing something, because it seems trivial to map from Zotero's
  collections to Mendeley's folders, or at least to do it in a way that
  will allow Referey to show the right thing).
- Keeping Mendeley continuously open (i.e., not issuing the  `mendeleydesktop --sync-then-quit`) did not help either (many Zotero changes did not propagate after waiting for up to 10 minutes and Mendeley can use a fair amount of CPU).




## Improvements ##

Lots are possible. For instance:

- Make using it simpler (there are three or four variables too many that
  are specific for *my* setup).

- Improve speed (it takes about 3 to 4 seconds to run the R script in my
laptop). Main things:

	- Maybe using [Rserve](https://rforge.net/Rserve/) could save on
	start-up and package loading time.
	
    - In the code I almost always do `Zotero db -> R data frame -> Referey
    db` but in several cases we could easily do `Zotero db -> Referey
    db` directly, skipping the conversion to and from an R data frame
    (even if the SQLite commands are issues from R).

	- Any other improvements to the code: I am an sqlite ignorant. 

- Make use of other fields in Zotero I am ignoring for now (I ignore
  notes, for instance).

- And, of course, the definitive improvement would be to directly use
  Referey on the Zotero db and stop using this code here :smiley:. Since
  the [code for Referey is available](https://github.com/kleinkm/Referey),
  it should be possible to modify it to deal with Zotero's db.

## Ramblings ##

The first requirement above, in [Why](#why), does not strike me as
unreasonable. However, maybe my use case is unusual; this is what I gather
based upon what is the most common design of virtually all Zotero Android
apps: if PDF access is provided at all, it is by fetching them from the
web (i.e., requiring being online). The exceptions are Zojo (partially)
and Zotfile (but Zotfile in a sense is a different idea).  I think I must
be missing something obvious, so here goes my reasoning: my whole PDF
collection is about 8 GB, which fits easily even in tablets from a few
years ago. Now, if your daily routine often includes two one-hour train
commutes, or if you take an 8-hour airplane flight or if you meet friends
that can make you wait for 50 minutes... , I think it is reasonable to
want to have all of your PDFs in your tablet without any need to
pre-decide what to read. I just don't want to have to think about "did I
download the PDF to the tablet? Am I awake enough to read paper X?". That
is the nice thing about tablets (compared to paper): even if aliens abduct
you for a few days, as long as they let you charge your tablet, you can
just keep reading :-) ).


## License ##

All the code here is copyright, 2015, Ramon Diaz-Uriarte, and is licensed
under the [GNU Affero GPL Version 3 License](http://www.gnu.org/licenses/agpl-3.0.en.html).


<!---
Local Variables:
mode: gfm
--->
