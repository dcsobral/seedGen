# seedGen
7 Days to Die Random Seed Generator

I use this project to automatically generate random seeds in 7 Days to Die,
create and save a map preview for each seed, and analyse the results to
search for insteresting maps.

# Usage

There's multiple "entry points" in here, depending on what I want to do,
the most common ones being:

* Generation & Preview
  - `genWorlds.sh`: generate multiple seeds, save preview and delete;
  - `genSeed.sh`: generate a seed, and preview;
  - `drawMap.sh`: generate a map preview without prefabs;
  - `drawPrefabs.sh`: overlay prefab previews on a map;
  - `legend.png`: this is the color legend for the map previews;
* Retrieving Seeds
  - `uz.sh`: Extracts a preview into its own directory;
  - `prefabs.sh`: Extracts prefab information of all previews of a size;
  - `previews.sh`: Extracts all previews of a size, and generates a montage;
  - `spawnpoints.sh`: Extracts spawn points from all seeds (for debugging);
* Comparing Seeds
  - `sortBySpecialPrefabs.sh`: Sort prefabs by the number of unique "interesting" prefabs;
  - `sortByPrefabs.sh`: Sort prefabs by number of prefabs;
  - `sortByTotalSpecialPrefabs.sh`: Sort prefabs by number of special prefabs;
  - `sortByUniquePrefabs.sh`: Sort prefabs by number of unique prefabs;
  - `allSorts.sh`: Displays seeds sorted by the four different criteria above side by side;
  - `allSpecials.sh`: Displays seeds sorted by various special categories (work in progress);
  - `speadsheet.sh`: Saves various analysis as a csv file
  - `highlight.sh`: Highlights words (seeds) from stdin (use: `allSorts.sh | highlight seedName`);
  - `greatest.sh`: Highlights seeds that are first in multiple criteria (use: `greatest.sh allSpecials.sh`);
  - `tops.sh`: Highlights seeds that are first in at least one criteria (use: `tops.sh allSorts.sh`);
  - `bestSeeds.sh`: Sort top seeds by number of criteria they are top of;
  - `special.sh`: Select special list (example: `special.sh -top5.txt allSorts.sh`);
* Evaluating seed:
  - `prefabRules.sh`: Shows prefab distribution by rule;
  - `listSpecials.sh`: Shows insteresting prefabs on a preview;
  - `missingPrefabs.sh`: Shows what prefabs are missing, optionally filtered by special list;
  - `showBiomeDistribution.sh`: Shows how prefabs are distributed among biomes;
  - `special/special.txt`: List of prefabs deemed "interesting". Other lists can be found on
    the same folder;
* Helpful stuff:
 - `showPrefab.sh`: displays the image preview of a prefab.
 - `bash_completion.sh`: auto-complete for these scripts;

There's more in here, some used by the above scripts, others used by me for more arcane
purposes. Some, in fact, I no longer have use for at all.

Special prefabs come in many different types. By default, it includes all tier 4 and 5
prefabs plus traders. It can be changed by setting SPECIAL to one of the included
categories (check `special/` folder). You can point to your own separately maintained list
of special prefabs with the `SPECIAL_FOLDER`, which is where files mentioned by `SPECIAL`
will be looked for. One can also use `special.sh` to pick a special file to use from
the special folder, and both `listSpecials.sh` and `missingPrefabs.sh` accept an optional
parameter with the special list to use, from the special folder.

Many of these scripts rely on an environment variable called `F7D2D`. You have to assign
it to the path to the folder where 7 Days to Die is installed. It does work with mods --
in fact, it was created to be used with Ravenhearst, though it doesn't depend on that.

This should work to point to 7 Days to Die for most people:

```bash
export F7D2D='/mnt/c/Program Files (x86)/Steam/steamapps/common/7 Days to Die'
```

Most scripts, when invoked, display a help message with the parameters it expects to receive.

# Requirements

This is incomplete, most likely, but:

* AutoHotKey (not needed for seed generation with server, though)
* ImageMagick 6 (if using 7, you'll need to fix calls on the `draw*` scripts);
* XMLStarlet
* expect
* zip/unzip

Note that ImageMagick comes with some rather restrictive (imho) limits by default. I fixed it
doing something someone recommended on their forums, which is commenting out the policies in
policy.xml (/etc/ImageMagick-6/policy.xml on Ubuntu). Like this:

```xml
  <!--
  <policy domain="resource" name="memory" value="256MiB"/>
  <policy domain="resource" name="map" value="512MiB"/>
  <policy domain="resource" name="width" value="16KP"/>
  <policy domain="resource" name="height" value="16KP"/>
  <policy domain="resource" name="area" value="128MB"/>
  <policy domain="resource" name="disk" value="1GiB"/>
  -->
```

# How it works

This whole setup expects to be run under WSL on Windows 10, with 7 Days to Die for
Windows. I have all of it on `~/seedGen`, and I often add that to the path when working,
though it is not necessary.

I run everything from a wsl session, using Ubuntu. I require a number of extra packages to
be installed, though I honestly can't say what all of them are. See requirements above for
an incomplete list. My scripts, however, will start a *Windows* version of 7 Days to Die.

Whenever a seed is generated, 7 Days to Die is started by `startClient.sh`, with
seed and world size passed on the command line. Everything it writes is written to the
folder `UserData`, which will be created inside `$F7D2D`. Not a very good location, I
admit, but the install locations I actually used were all on folders in my desktop, which
is fine.

To make the client generate seeds, I use an AutoHotKey script, which is basically a
program that simulates clicking and typing. It does require hard-coding locations for
mouse clicks, and I couldn't make it keyboard-only. The locations work for screen
resolutions of 2560x1440. If your resolution is different, you'll need to change the
locations on the two scripts: `previewSeed.ahk` and `exitGame.ahk`. The locations are
all defined as X and Y coordinates at the beginning of the files.

The seed generatior, `genSeed.sh`, then looks at the log looking for a message that
the generation has finished, or that an error occurred and it has aborted. Not all errors
are detected, unfortunately, so sometimes you have to kill 7 Days to Die by hand and
cancel the generation.

Once the generation has finished, `savePreview.sh` is called and it creates a zip file
with a text file called "<seed>-<size>.txt" with the "County" name (what 7d2d calls the
seed when you look it up), the prefabs.xml file renamed to "<seed>-<size>.xml", and a
preview image of the map called "<seed>-<size>.png". That zip file is then moved to
`${F7D2D}/previews/`.

By default the prefabs are draw in the map preview, but you can save time by creating
a file called `nodraw`, and only the basic map will be created. It can still be slow, but
I found I wanted the preview readily available more than I wanted to generate seeds faster.

The map preview is created by two scripts: `drawMap.sh` is the one that creates the basic
map, and `drawPrefabs.sh` is the one that overlays a preview image of each prefab at it's
location, and with that prefab's dimension. The preview image is "part" of the prefab,
though it is optional and, therefore, might not be present. In such cases, a rectangle is
drawn.

If you are using `genSeed.sh` directly, that's where it stops. If you are using
`genWorlds.sh`, however, it will go on to the next seed until it creates all the seeds you
asked for for that size, and then on to the next size. Often enough, however, I want to
stop the generation, but given how long it can take to generate a single seed, I'm loath
to just abort it. To avoid angst, you can create a file called "stop" in the directory
you are calling `genWorlds.sh` from (not `genWorlds.sh`'s directory), and it will finish
as soon as the current seed has been generated. It will also delete "stop" at the end,
so you don't risk starting a generation and leaving the computer, only to find out later
that it stopped right after the first seed.

When analysing seeds, I start by going to the `previews` folder and using `prefabs.sh`
to get all prefabs.xml files (which were renamed before being saved, as described above)
for a particular seed size into a directory. For example, `prefabs.sh 4096`, run
from the `previews` folder, will extract all these xml files into the `previews/4096`
folder.

Next I go inside the size folder and run commands like `tops.sh allSorts.sh` and
`greatest.sh allSpecials.sh` to get a quick summary of what seeds stand out according
to multiple criteria. Sometimes I'll see seeds that are high-rated on multiple criteria
right away. Sometimes nothing will stand out, so I pick some of the highest rate in one
criteria and another and check how they fare overall. For example, if X, Y and Z are the
top three seeds in unique prefabs, I might do `allSpecials.sh X Y Z` to hightlight them
on the lists by special prefabs and see if any one of them fares well enough.

Once I spot some candidate seeds, I use the seed evaluation commands to evaluate that seed.
For example, I might do `listSpecials.sh X skyscrapers.txt` to see which skyscrapers seed
X has, or `missingPrefabs.sh X top7.txt` to see which of my top 7 prefabs is missing on
seed X. If a seed is really great, I might just do `missingPrefabs.sh X` to list all prefabs
it does not have.

The final step for me is to look at what the maps look like. I run `previews.sh` which,
similar to `prefabs.sh`, will extract the map previews of seeds of a size (or all sizes)
into a folder. For example, `preview.sh` will created the folders `4096-previews` and
`8192-previews`, assuming I have seeds of both 4096 and 8192 sizes. It also creates
a montage with the thumbnails of every map, in case I'm looking for seeds based on what
the map looks like.

I then go into that seed folder, look at the map (I have an "open" alias that makes it easy),
and maybe do some more evaluation. Looking at maps for multiple seeds side by side is often
useful, particularly when they each have different strengths and weaknesses.

My "open" alias, by the way, is this:

```bash
open() {
    cmd.exe /C start "" "$(wslpath -w "$1")"
    }
```

And I load my bash completions with this line in the file `~/.bash_completion`:

```bash
source ~/seedGen/bash_completion.sh
```

# Using Server for Seeds

This can use the server for seed generation, which is how it worked at first. But
since alpha 18, seed generation on servers is different than on clients. It uses
alpha 17 code, essentially. I don't believe this has changed on alpha 19.

You need to change `genSeed.sh` and uncomment `startServer.sh`, and comment
`startClient.sh`. It is possible that other adjustments are necessary, since I
haven't used that code in a long while.

# Seed names

The random seeds are created by `seed.sh`. It can be configured with the following
variables:

* `SEED_DICTIONARY_FOLDER`: folder containing word files to be used;
* `SEED_FIRST_WORD_FILE`: file inside the folder above containing the first word;
* `SEED_SECOND_WORD_FILE`: file inside the folder above containing the second word.

By default, the `dictionary` folder inside the folder containing the scripts is
used for the seed dicitonary folder, the first word file is a file containing a list
of adjectives, and the second file is a file containing a list of nouns.

The dictionary included comes from a "parts of speech files" file compiled by
Ashley Bovan, which I found on the internet. See readme on that folder for more
information. Also provided, and usable, are lists of adverbs and verbs. These lists
are also broken down into 1, 2, 3 and 4 syllables, so if you want short seeds, you
could set first and second word to dictionaries that are just one or two syllables.

Examples:

```
$ export SEED_FIRST_WORD_FILE='adjectives/1syllableadjectives.txt'
$ export SEED_SECOND_WORD_FILE='nouns/1syllablenouns.txt'
$ seed.sh
DenseBurk
$ export SEED_FIRST_WORD_FILE='adverbs/2syllableadverbs.txt'
$ export SEED_SECOND_WORD_FILE='verbs/2syllableverbs.txt'
$ seed.sh
MezzoConceal
```

