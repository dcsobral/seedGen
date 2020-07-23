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
  - `tops.sh`: Highlights words in the last line (use: `tops.sh allSorts.sh`);
* Evaluating seed:
  - `prefabRules.sh`: Shows prefab distribution by rule;
  - `interestingPrefabs.sh`: Shows insteresting prefabs on a preview;
  - `interesting.txt`: List of prefabs deemed "interesting".

There's more in here, some used by the above scripts, others used by me for more arcane
purposes. Some, in fact, I no longer have use for at all. There's also `bash_completion.sh`
which adds, you guessed it, bash completion for the stuff I use the most.

Special prefabs come in many different types. By default, it includes all tier 4 and 5
prefabs plus traders. It can be changed by setting SPECIAL to one of the included
categories (check `special/` folder). You can point to your own separately maintained list
of special prefabs with the `SPECIAL_FOLDER`, which is where files mentioned by `SPECIAL`
will be looked for.

Many of these scripts rely on an environment variable called `F7D2D`. You have to assign
it to the path to the folder where 7 Days to Die Server is installed. It does work with
mods -- in fact, it was created to be used with Ravenhearst, though it doesn't depend on
that. The list of interesting prefabs, however, does include Ravenhearst-specific prefabs,
and would need to be adjusted for other mods. It will work fine with vanilla, since RH
includes all of vanilla's prefabs.

This should work to point to 7 Days to Die Server for most people:

```bash
export F7D2D='/mnt/c/Program Files (x86)/Steam/steamapps/common/7 Days to Die Dedicated Server'
```

Most scripts, when invoked, display a help message with the parameters it expects to receive.

# Requirements

This is incomplete, most likely, but:

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

This whole setup expects to be run under WSL on Windows 10, with 7 Days to Die Server for
Windows. I have all of it on `~/seedGen`, and I often add that to the path when working,
though it is not necessary.

I run everything from a wsl session, using Ubuntu. I require a number of extra packages to
be installed, though I honestly can't say what all of them are. See requirements above for
an incomplete list. My scripts, however, will start a *Windows* version of 7 Days to Die.

Whenever a seed is generated, 7 Days to Die Server is started by `startServer.sh`, with
seed and world size passed on the command line. Everything it writes is written to the
folder `UserData`, which will be created inside `$F7D2D`. Not a very good location, I
admit, but the install locations I actually used were all on folders in my desktop, which
is fine.

The seed generatior, `genSeed.sh`, then looks at the log looking for a message that
the generation has finished, or that an error occurred and it has aborted. Not all errors
are detected, unfortunately, so sometimes you have to kill 7 Days to Die Server by hand
and cancel the generation.

Once the server has started, and, therefore, the generation has finished, `savePreview.sh`
is called and it creates a zip file with a text file called "<seed>-<size>.txt" with the
"County" name (what 7d2d calls the seed when you look it up), the prefabs.xml file renamed
to "<seed>-<size>.xml", and a preview image of the map called "<seed>-<size>.png". That
zip file is then moved to `${F7D2D}/previews/`.

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

When analysing seeds, I start by going to the `previews` folder and using `extractPrefabs.sh`
to get all prefabs.xml files (which were renamed before being saved, as described above)
for a particular seed size into a directory. For example, `extractPrefabs.sh 4096`, run
from the `previews` folder, will extract all these xml files into the `previews/4096`
folder. I then change into that folder, and use the sorting commands to examine the seeds.

Once I spot some candidate seeds, I use the seed evaluation commands to evaluate that seed.
I then go back into the `previews` folder, and use the `uz.sh` command to extract a specific
seed into a directory. That's basically `unzip`, but it creates a folder and extracts the
preview into that folder, which keeps the `previews` folder cleaner.

I then go into that seed folder, look at the map (I have an "open" alias that makes it easy),
and maybe do some more evaluation. Looking at maps for multiple seeds side by side is often
useful, particularly when they each have different strengths and weaknesses.

My "open" alias, by the way, is this:

```bash
open() {
    cmd.exe /C start $(wslpath -w "$1")
    }
```

And I load my bash completions with this line in the file `~/.bash_completion`:

```bash
source ~/seedGen/bash_completion.sh
```

