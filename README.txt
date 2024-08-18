# Half-Life Map Zipper

## Requirements
Docker

## Usage

Modify Makefile:
```
/media/Data1/SteamLibrary/steamapps/common/Half-Life/ts
```
with your mod location.

then:
```
make build
make run
```

Now inside of the output directory you'll have zip files and a missing.txt file with a full list of all assets that are missing.
Each zip file will also contain its own missing.txt for any missing assets per map.