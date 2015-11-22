# Zotero to Referey #

_Use Referey on Androids with your Zotero db. Or export your Zotero db in
a way that Referey will be able to use_

The `zotero-to-referey.R` code will take a [Zotero](http://www.zotero.org)
sqlite database (db) and convert it into a database that
[Referey](https://play.google.com/store/apps/details?id=com.kmk.Referey),
and Android application, can handle.


## Why ##

I use Android tablets heavily for reading, annotating, and highlighting
PDFs (and most of that time I am offline) and I use this in combination
with some reference management software (Mendeley in the past, Zotero
now). A few essential features for me are:

- Being able to read, annotate, and highlight any PDF in my library while
offline, **without** having had to pre-download them before (e.g., I do
not want to spend 10' minutes before I leave the lab thinking what I might
be reading in the train on my way home). This means that any solution that
tries to fetch the PDF from a server when you want to open it is not
acceptable to me. 

- Having the PDFs synced with my computer(s) automagically as soon as I am
online again. And, of course, having any annotations I make in the PDFs on
my computer(s) show up in my tablets without any manual intervention.

- Being able to order the entries by collection, by tag, and by date (and,
  ideally, select by combination of tag and collection, and order by date,
  author, or title in those searches).


### What ###

Referey does exactly what I want but it expects Mendeley dbs. What I have
done is take the Zotero db and, from it, generate a minimal db that
Referey can deal with.

(Does this work with Windows, or Mac or ...? No idea. Most of it should,
but I only use GNU Linux).


#### The code ####

I do the conversion using R. I use R instead of, say, Python because it is
just simpler for me for this task. The R script **zotero-to-referey.R**
gets the needed data from the Zotero sqlite db, modifies/restructures it,
and creates a new db.


You can use the R script **zotero-to-referey.R** directly (you should only
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




### Configuring Referey ###

There are two basic settings you need to configure:

  - The name of the sqlite file
  - How to deal with paths for the PDFs

Enter the Referey preferences, and set the "Database path" to the path of
the sqlite file.

For the PDFs you need to specify the "PDF folder path" (i.e., the place
relative to where all PDFs and their enclosing directories live) and how
to deal with PDF path levels.

For example, in my case I have the complete Zotero PDF structure residing
under `/sdcard/Zotero-storage` (that is what I enter in "PDF folder
path"). And since the PDF file names in the sqlite db are given as
`directory/name-of-file` in "Preserve PDF path levels" I have option
`folder\file.pdf`.  There are other options available (just check the
preferences help).


### Syncing ###

I use [syncthing](https://syncthing.net/) for syncing. I sync the
directory where all the PDFs (and their parent directories) live and
another directory where the dbs live. By syncing the directory of the PDFs
all of my PDF annotations, highlights, etc, are always shared between all
machines as soon as they get back online.

Referey can make modifications to the dbs and that is the reason why I
make two copies of the dbs for Referey: in my setup both tablets share a
directory with the computers, so I do not want there to be conflicts and
setting up one-way syncs is more trouble than just copying the file.



### Running automatically ###

I want to trigger the creation of a new db for Referey whenever there is a
change in the Zotero db. I use
[inotify-tools](https://github.com/rvoicilas/inotify-tools/wiki) to
monitor for changes in `zotero.sqlite` and call the script when there are
changes. So as not to forget it, I have this line in my `.xsession` file:

     while inotifywait -e close -e modify ~/Zotero-data/zotero.sqlite; do ~/Proyectos/Zotero-to-Referey/run-zotero-to-referey.sh; done &



(You might want to use [entr](http://entrproject.org/), which I like a
lot, but I was missing some events; it would be triggered at open and
close of Zotero, but not at intermediate changes with Zotero open, such as
reorganizing the library, deleting tags, etc).



### What this won't do ###

In contrast to some of the applications we discuss below, this code does
not allow you to make modifications of your Zotero db from the
Android. This is OK for me but might not be for others.



##  Alternatives to using Referey with Zotero, or Zotero and Androids ##

(Before we get into details, the first requirement above does not strike
me as unreasonable. However, maybe my use case is unusual, or so I'd think
based upon what is the most common design of many Zotero Android
apps. Regardless, and to be explicit, this is my reasoning: my whole PDF
collection is about 8 GB, which fits easily even in tablets from a few
years ago. If you take daily one-hour train commutes or if you go on an
8-hour airplane flight or ... , I think it is reasonable to want to have
all of your PDFs in your tablet without any need to pre-decide what to
read. I just don't want to have to think about "did I download the PDF to
the tablet?". That is the nice thing about tablets: even if aliens abduct
you for a few days, as long as they let you charge your tablet, you can
just keep reading :-) ).


As I said, I recently started using Zotero, coming from Mendeley. When
using Mendeley, I used Referey in the tablets (see
[Zotero, Mendeley, a tablet, et al.](http://ligarto.org/rdiaz/Zotero-Mendeley-Tablet.html))
because it makes many things extremely simple and convenient. Basically, I
take care of syncing the database and the complete directory with all the
PDFs, and Referey works from there. If you use a syncing system that keeps
the db in your tablets updated and that syncs the PDFs back and forth, the
above requirements are automatically satisfied. (And I really like the UI
of Referey and the many ways of selecting and searching for references).

When I moved to Zotero,
[I sorely missed the convenience of Referey](https://github.com/rdiaz02/Adios_Mendeley#using-a-tablet). Yes,
there are some apps listed under
[Zotero for Mobile](https://www.zotero.org/support/mobile), but none will
do the above, at least in Android systems. In fact, I have tried all of
those listed: [Zandy](http://www.gimranov.com/avram/w/zandy-user-guide),
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
want offline access to all and any of your PDFs. Zojo seems to have an
option where you can access your local PDFs, but Zojo does not show
collections or tags (yes, you can search, but this is not very
convenient). Zotfile often requires too much manual intervention (see my
[attempts to use Zotfile](http://ligarto.org/rdiaz/Zotero-Mendeley-Tablet.html#sec-6-2)
---this might be that I never actually fully understood how to use
Zotfile) and, even if you manage to automate that,
you have the PDFs in the tablet but you loose the rest of the structure
(tags, collections) from your Zotero db which, again, makes things
a lot less useful: I do not just want the bare PDFs.


Given the above,
[I tried using BibTeX Android applications](https://github.com/rdiaz02/Adios_Mendeley#using-a-tablet).
This idea has been mentioned in other places
([e.g., the comment by smatthie, on 2015-09-15](https://forums.zotero.org/discussion/51234/zotable-a-modern-zotero-client-for-android/?Focus=239548)):
basically, export the Zotero db as a BibTeX file, using the
[Zotero BBT extension](https://zotplus.github.io/better-bibtex/) that
exports Zotero collections as
[JabRef's groups](http://jabref.sourceforge.net/help/GroupsHelp.php), and
use an Android BibTeX app. There are three Android apps that will deal
with BibTeX files but this is not a great solution either. Briefly, of the
available ones,
[Library](https://play.google.com/store/apps/details?id=com.cgogolin.library)
cannot show your Zotero collections,
[RefMaster](https://play.google.com/store/apps/details?id=me.bares.refmaster)
does not support more than one file per entry and does not support Zotero
collections, and
[Erathostenes](https://play.google.com/store/apps/details?id=com.mm.eratos)
will only show the lower-most level of groups, is extremely slow, and
often you need to kill and restart it as the app will hang. By extremely
slow I mean that reloading my library of about 3000 references and about
100 collections/groups on an Asus TF201 can take over 10 minutes to load
the db and over 40 to deal with the JabRef groups; a Nexus 7 can do it in
between 10 and 20' total. Changes in Zotero, thus, are painful to update
in the tablets.

When using Referey, in contrast, I launch Referey and load the complete db
in about 20 seconds in the Asus TF201 and 5 in the Nexus. Those are speed
ups of 100x to 200x. And I keep my complete collection structure.


## Doing the Zotero to Referey with Mendeley itself? ##

(To be completed)



## Improvements ##

Lots are possible. For instance:

- Improve speed (it takes about 3 to 4 seconds to run the R script in my
  laptop). Maybe using [Rserve](https://rforge.net/Rserve/) could save on
  start-up and package loading time.

- Make use of other fields in Zotero I am ignoring for now (I ignore
  notes, for instance).




## License ##

All the code here is copyright, 2015, Ramon Diaz-Uriarte, and is licensed
under the [GNU Affero GPL Version 3 License](http://www.gnu.org/licenses/agpl-3.0.en.html).


<!---
Local Variables:
mode: gfm
--->
