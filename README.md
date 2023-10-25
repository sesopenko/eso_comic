# eso comic

An open-source comic book reader powered by [Godot](https://godotengine.org/), designed to offer a dual-language comic reading experience. Open two comics, each in a different language, and have their pages synchronized for dual reading language. Scroll through both comics simultaneously, as you immerse yourself in the captivating world of visual storytelling, seamlessly bridging English and Japanese, and other languages.

![Screenshot](docs/images/screenshot_2.jpg)

## System Requirements

* Tested on Windows 11 but should work on Windows 7 & 10 as well
* Requires about 100MB of free ram.

## How to build the project

You may be prompted to download export profiles by Godot.  Just let it do this automatically (takes 1-10 minutes, depending on your internet speed).

1. [Download Godot](https://godotengine.org/download/windows/)
2. Download this project (and extract zip file if you downloaded a zip)
3. Import the project with Godot
4. Menu: Project->Export
5. Add->Windows Desktop (or linux if you're on linux, mac and mobile are out of scope)
6. Export Path: Click folder icon and choose where to save the file
7. Binary Format: Embed PCK: On (so that it's a single file exe)
8. Export All

## Motivation

While learning a second language, I've desired to capture some of the nuances lost in translation when reading comics. Opening two reader applications works, but paging them independently was a pain. I wanted something that lets me page through them simultaneously.

## Supported Files

* [CBZ](https://en.wikipedia.org/wiki/Comic_book_archive) files containing jpg/png files
* ZIP files containing jpg/png files
* Directories containing jpg/png files (nested directories unsupported)

## License

This application code is free and open source, licenced with the GNU GPL V3 license.  It may be read in [LICENSE.txt](LICENCE.txt).

## Copyright

This software is Copyright (c) Sean Esopenko 2023.