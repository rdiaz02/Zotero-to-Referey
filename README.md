# Zotero to Referey #

_Use Referey on Androids with your Zotero db. Or export your Zotero db in
a way that Referey will be able to use._


`zotero-to-referey.R` will take a [Zotero](http://www.zotero.org)
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




<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Zotero to Referey](#zotero-to-referey)
    - [New (July 2022): Exporting only libraryID == 1](#new-july-2022-exporting-only-libraryid--1)
    - [Why](#why)
    - [What](#what)
    - [Why Referey](#why-referey)
        - [A better way](#a-better-way)
            - [The code](#the-code)
        - [Using it (user configuration) and requirements](#using-it-user-configuration-and-requirements)
        - [Configuring Referey](#configuring-referey)
            - [Configuring Referey in recent (post 2018?) Androids](#configuring-referey-in-recent-post-2018-androids)
        - [Syncthing](#syncthing)
            - [My setup](#my-setup)
        - [Running automatically](#running-automatically)
        - [What this won't do](#what-this-wont-do)
        - [If you still use Zotero 4](#if-you-still-use-zotero-4)
    - [Alternatives](#alternatives)
        - [Zotero for Android apps in 2015: Zandy, Zed, Zojo, Zotfile, Zotable](#zotero-for-android-apps-in-2015-zandy-zed-zojo-zotfile-zotable)
        - [Using BibTeX in the Android tablet](#using-bibtex-in-the-android-tablet)
        - [ZotDroid](#zotdroid)
        - [ZotEZ2](#zotez2)
        - [Zoo for Zotero](#zoo-for-zotero)
        - [The "official" Zotero for Android](#the-official-zotero-for-android)
    - [Improvements](#improvements)
    - [Ramblings](#ramblings)
    - [License](#license)

<!-- markdown-toc end -->





## New (July 2022): Exporting only libraryID == 1 ##

I've modified the script so that only libraryID = 1 is exported. I think libraryID = 1 is the "primary library". I've started using group libraries, and if I export all, it upsets sorting by date added (as the ones in the new library are much more recent, even if the original paper was in my library long ago). If you want to export all libraries, see instructions on file **zotero-5-to-referey.R**.


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
just simpler for me. The R script **zotero-5-to-referey.R** gets the needed
data from the Zotero sqlite db, modifies/restructures it, and creates a
new db that Referey understands.


You can use the R script **zotero-5-to-referey.R** directly (you should only
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


### If you still use Zotero 4

If you use Zotero 4, use **zotero-4-to-referey.R** in file
**run-zotero-to-referey.sh**. **zotero-5-to-referey.R** works with Zotero 5, 6, and 7.


##  Alternatives ##



<!-- ### Alternative Zotero and Android routes ### -->

<!-- As I said, I started using Zotero in 2015, coming from Mendeley. When -->
<!-- using Mendeley, I used Referey in the tablets (see -->
<!-- [Zotero, Mendeley, a tablet, et al.](http://ligarto.org/rdiaz/Zotero-Mendeley-Tablet.html)). When -->
<!-- I moved to Zotero, -->
<!-- [I sorely missed the convenience of Referey](https://github.com/rdiaz02/Adios_Mendeley#using-a-tablet). -->

### Zotero for Android apps in 2015: Zandy, Zed, Zojo, Zotfile, Zotable ###

(This is left here for historical purposes: most of these apps are no longer available)

When I started using Zotero in 2025, there were some apps listed under [Zotero for Mobile](https://www.zotero.org/support/mobile), but none did do [what I wanted](#why), at least in Android systems. I tried all of those listed: [Zandy](http://www.gimranov.com/avram/w/zandy-user-guide), [Zed](http://www.favand.net/zed), [Zed Lite](https://play.google.com/store/apps/details?id=net.favand.zedlite), [Zojo](https://play.google.com/store/apps/details?id=com.phani.zojo), [Zotfile](http://zotfile.com/), plus [Zotable](https://play.google.com/store/apps/details?id=com.mattrobertson.zotable.app), but none satisfy the requirements above.


Zandy, Zotable, Zed, and Zed Lite so far will not allow you to get PDFs that already live locally in your tablet. Yes, you might be able with some of those apps to fetch PDFs, either from Zotero's servers, if you keep them there, of using WebDAV from a user-specified server, but then, that is not a workable solution if you want offline access to all and any of your PDFs. 

Zojo seems to have a [way to access your local PDFs](https://forums.zotero.org/discussion/45461/zojo-an-android-app-for-viewing-citations-stored-at-zotero/), but Zojo does not show collections or tags (yes, you can search, but I do not find this very convenient). 

Zotfile often requires too much manual intervention (see my [attempts to use Zotfile](http://ligarto.org/rdiaz/Zotero-Mendeley-Tablet.html#sec-6-2) ---this might be that I never actually fully understood how to use Zotfile) and, even if you manage to automate that, you have the PDFs in the tablet but you loose the rest of the structure (tags, collections) from your Zotero db which, again, makes things a lot less useful: I do not want just the bare PDFs. 



### Using BibTeX in the Android tablet ###

Given the above, [I tried using BibTeX Android applications](https://github.com/rdiaz02/Adios_Mendeley#using-a-tablet). This idea has been mentioned in other places ([e.g., the comment by smatthie, on 2015-09-15](https://forums.zotero.org/discussion/51234/zotable-a-modern-zotero-client-for-android/?Focus=239548)): basically, export the Zotero db as a BibTeX file, using the [Zotero BBT extension](https://zotplus.github.io/better-bibtex/) that exports Zotero collections as [JabRef's groups](http://jabref.sourceforge.net/help/GroupsHelp.php), and use an Android BibTeX app. 


In 2015, there were three Android apps that dealt with BibTeX files but I did not like this solution either. Briefly, of the available ones, [Library](https://play.google.com/store/apps/details?id=com.cgogolin.library) cannot show your Zotero collections or sort by date, [RefMaster](https://play.google.com/store/apps/details?id=me.bares.refmaster) does not support more than one file per entry and does not support Zotero collections, and [Erathostenes](https://play.google.com/store/apps/details?id=com.mm.eratos) will only show the lower-most level of collections, is extremely slow, and often I need to kill and restart it as the app will hang. By extremely slow I mean that reloading my library of about 3000 references and about 100 collections/groups on an Asus TF201 can take over 40 minutes (10 to load the db and over 30 to deal with the JabRef groups); a Nexus 7 can do it in between 10 and 20' total. Changes in Zotero, thus, are painful to update in the tablets. When using Referey, in contrast, I launch Referey and load the complete db in about 20 seconds in the Asus TF201 and 5 in the Nexus. Those are speed ups of 100x to 200x. And I keep my complete collection structure. 


On December 2023 I tried [BibTex Manager](https://play.google.com/store/apps/details?id=org.eu.thedoc.bibtexmanager). Loading the database is much slower that using Referey, and I loose the hierarchical view of the Zotero collections. This last problem is, for me, a serious one: I often use Zotero to organize what I am reading, putting together in a "collection" or "folder" the papers of a particular thing I am reading about (this is a great feature of Zotero, where the same paper can live in multiple folders). With BibTeX Manager, there are not collections or folders. I'd need to use tags to search for entries, instead of simply navigating to the "folder" or "collection". This would then require me to start duplicating, via tags, the collections, or else create fake tags from collections during the export of the BibTeX file to the tablet, so these tags appear first. In addition, opening local PDFs those not work out-of-the-box: it would require re-writing the path of the PDFs on sending the BibTeX file to the tablet; this is easy to do, but given the former problems I did not try it. 


### ZotDroid ### 

ZotDroid was announced in the [Zotero forum](https://forums.zotero.org/discussion/67409/zotdroid-a-zotero-client-for-android) and was available from the Play Store (update on 2024-03-28: ZotDroid no longer seems available from the Play Store; see also [ZotDroid is down](https://forums.zotero.org/discussion/95452/zotdroid-is-down); the sources are [available from GitHub](https://github.com/ARF1/ZotDroid)). 

It seems a very interesting app and it ought to allow syncing changes back. In addition, it is also possible to specify a local path for the PDFs (see this comment in the [Zotero forum](https://forums.zotero.org/discussion/comment/285410/#Comment_285410)). However, I've tried using it with no luck. Basically, it is very slow when syncing and loading the collection and then it hangs in any of the usual operations (searching, scrolling, jumping to a collection, etc.). I've posted these problems in the [Zotero forum](https://forums.zotero.org/discussion/comment/296781/#Comment_296781). 

I have tried again with version 1.1.5 (as of 2018-03-25). Still way too slow for real usage, and it is not possible to use, in a sensible way, the local collection of PDFs. Sorting and searching are also very limited compared to Referey. Finally, syncing requires, well, remembering to sync your collection (i.e., is not something that happens automagically via a general syncing solution for the tablet). See my report of these problems in the [Zotero forum](https://forums.zotero.org/discussion/comment/304449/#Comment_304449). And it continues to be mostly just a read-only option (i.e., does not provide anything else beyond my current setup). 


So, at least for now, I'll definitely continue using Referey since ZotDroid is not (yet?) a viable alternative at least for my collection and/or hardware. 

### ZotEZ2 ###

I tried [ZotEZ2](https://play.google.com/store/apps/details?id=net.ezbio.zotez2) around 2019 and 2021. The databases was read only, like my current setup. Instructions on how to use a local collection force you to place things in specific locations; the syncying of PDF annotations seems to require manually forcing a set of steps (see [this comment in the Zotero forums](https://forums.zotero.org/discussion/comment/343632/#Comment_343632)). I see no advantage over my currently working setup.


On March 2024 I tried it again. As ZotEZ2 would seem to be able to use a local Zotero sqlite database that I can sync easily and local paths for PDFs, this would be exactly what I need (see [ZotEZ2 web page](https://zotez2.ezbio.net/)).  However, trying to use a local copy of the Zotero sqlite database does not work for (it gives me an error). That can be overcome by login into Zotero. But specifying a local path for the attachment gives again an error (it seems to be the same one); this has been reported, with no answer, in the Play Store comments. So I cannot use ZotEZ2. Most reviews I found in the Play Store for the last two years report different sorts of problems (yes, I know, there might be a bias in reviews, so that you get an over-representation of negative reviews, and many of the problems concerned syncing to cloud platforms, which does not affect my setup), and the app was last updated on April 2021. I give up trying.



### Zoo for Zotero ###

Zoo for Zotero would do all I need. And it seems to work very well for many people. But, alas, it is very slow with my library: more than 2 minutes to load it ---these are more than 2 minutes after the initial sync---, whereas Refery takes less than 10 seconds), I get error messages, and I often experience problems opening PDFs (i.e., very rarely can I open the PDF, instead getting the "Zoo for Zotero isn't responding" message) ---this is a known issue https://github.com/mickstar/Zoo-For-Zotero/issues/118. 




### The "official" Zotero for Android ###

In December 2023 Zotero launched a [Zotero for Android] (https://forums.zotero.org/discussion/110371/available-for-beta-testing-zotero-for-android/p1) !! This is still in beta, and I have not (yet) been able to get into the beta testing program (slots are limited, and they run out shortly after new slots are announced). 

I am very excited about this app, but yet it might not be what I need. Why? Because the Android app will not support opening PDFs in exernal applications, so one needs to use the built-in Zotero PDF editor (see discussion in [this post and the following ones](https://forums.zotero.org/discussion/comment/455807/#Comment_455807) ) in Android. This will severely impact my use of Emacs to read and annotate PDFs in the computer. Yes, the wording is correct: not being able to use an external PDF editor in Android can affect what one uses in the computer, *because the built-in Zotero PDF editor does not add annotations directly in the PDF*: it stores annotation in the Zotero database (see [this discussion](https://forums.zotero.org/discussion/comment/404109/) and the [explanation in Zotero's support](https://www.zotero.org/support/kb/annotations_in_database))

I've explained why using the Android app would affect my use of Emacs to annotate PDFs, and what I think are the terms of the trade-off [here](https://forums.zotero.org/discussion/113164/zotero-the-native-android-app-and-emacs-pdf-annotation-in-the-computer). (Using Zotero's Android app would probably also require using Zotero for storage of all of my PDFs, breaking some of my setup, but this is not a major concern; they key problem is not storing PDF annotations in the PDFs themselves).



<!-- ### Doing the Zotero to Referey conversion with Mendeley itself? ### -->

<!-- THIS IS OLD AND WILL NOT WORK. Left just for historical reasons. -->

<!-- I tried that too, but it won't work well. You might think, for instance, -->
<!-- about configuring Mendeley to have continuous integration of your Zotero -->
<!-- db, and then launching mendeley whenever there is a change by issuing -->
<!-- something like `mendeleydesktop --sync-then-quit` (yes, you need to sync; -->
<!-- running mendeley offline will not trigger a conversion of the Zotero -->
<!-- db). But this will rarely be a satisfactory experience. Why? -->

<!-- - It is unreliable: I often got crashes (looking at the logs I could not understand what was happening) so that changes in Zotero would actually not propagate. -->
<!-- - Even when it works, it is very slow (can take over 10 minutes to do the -->
<!--   conversion). -->
<!-- - Mendeley does not import Zotero's collections correctly. This is a -->
<!--   [well known, more than six years old problem](http://feedback.mendeley.com/forums/4941-general/suggestions/389900-allow-importing-nested-hierarchical-zotero-collect). (I -->
<!--   must be missing something, because it seems trivial to map from Zotero's -->
<!--   collections to Mendeley's folders, or at least to do it in a way that -->
<!--   will allow Referey to show the right thing). -->
<!-- - Keeping Mendeley continuously open (i.e., not issuing the  `mendeleydesktop --sync-then-quit`) did not help either (many Zotero changes did not propagate after waiting for up to 10 minutes and Mendeley can use a fair amount of CPU). -->




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

The first requirement above, in [Why](#why), does not strike me as unreasonable. However, maybe my use case is unusual; this is what I gather based upon what is the most common design of virtually all Zotero Android apps: if PDF access is provided at all, it is by fetching them from the web (i.e., requiring being online). There are exceptions, though.<!-- The exceptions are Zojo (partially) --> <!-- and Zotfile (but Zotfile in a sense is a different idea). --> I think I must be missing something obvious, so here goes my reasoning: my whole PDF collection is about 20 GB, which fits easily even in tablets from a few years ago. Now, if your daily routine often includes two one-hour train commutes, or if you take an 8-hour airplane flight or if you meet friends that can make you wait for 50 minutes... , I think it is reasonable to want to have all of your PDFs in your tablet without any need to pre-decide what to read. I just don't want to have to think about "did I download the PDF to the tablet? Am I awake enough to read paper X?". That is the nice thing about tablets (compared to paper): even if aliens abduct you for a few days, as long as they let you charge your tablet, you can just keep reading :-) ). 

## License ##

All the code here is copyright, 2015-2024, Ramon Diaz-Uriarte, and is licensed under the [GNU Affero GPL Version 3 License](http://www.gnu.org/licenses/agpl-3.0.en.html).


<!---
Local Variables:
mode: gfm
--->
