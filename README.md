# Zotero to Referey #

*Convert Zotero db to use Referey in Androids*




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
