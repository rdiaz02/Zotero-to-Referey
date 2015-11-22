# Zotero to Referey #

_Convert Zotero db to use Referey in Androids_

The `zotero-to-referey.R` code will take a [Zotero](http://www.zotero.org)
sqlite database and convert it into a database that
[Referey](https://play.google.com/store/apps/details?id=com.kmk.Referey),
and Adroid application, can handle.


## Why ##

I use Android tablets heavily for reading, annotation, and highlighting
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



As I said, I recently started using Zotero, coming from Mendeley. When
using Mendeley, I used Referey in the tablets (see
[Zotero, Mendeley, a tablet, et al.](http://ligarto.org/rdiaz/Zotero-Mendeley-Tablet.html))
because it makes many things extremely simple and convenient. Basically, I
take care of syncing the database (db from now on) and the complete
directory with all the PDFs, and Referey works from there. If you use a
syncing system that keeps the db in your tablets updated and that syncs
the PDFs back and forth, the above requirements are automatically
satisfied.

When I moved to Zotero, I
[sorely missed the convenience of Referey](https://github.com/rdiaz02/Adios_Mendeley#using-a-tablet).








## Configuring Referey ##

There are two basic settings you need to configure:

      - The name of the sqlite file
      - How to deal with paths for the PDFs

Enter the preferences, and set the Database path to have the name of the
sqlite file.

For the PDFs you need to specify the "PDF folder path" (i.e., the place
relative to where all PDFs and their enclosing directories live) and how
to deal with PDF path levels.

For example, in my case I have the complete Zotero PDF structure residing
under `/sdcard/Zotero-storage` (that is what I enter in "PDF folder
path"). And since the file names in the sqlite are given as
`directory/name-of-file` in "Preserve PDF path levels" I have option
`folder\file.pdf`.  There are other options available (just check the
preferences help).




## Running automatically ##

ls ~/Zotero-data/zotero.sqlite | entr ~/Proyectos/Zotero-to-Referey/entr-zotero-referey.sh &


## Improvements ##

- Improve code speed.

- Use Rserve to save on start-up time (?)

- Use Zotero's notes properly




## License ##

All the code here is copyright, 2015, Ramon Diaz-Uriarte, and is licensed
under the [GNU Affero GPL Version 3 License](http://www.gnu.org/licenses/agpl-3.0.en.html).


<!---
Local Variables:
mode: gfm
--->
