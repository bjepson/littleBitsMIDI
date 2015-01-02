Convert polyphonic MIDI files to something you can play on
an Arduino.

This script takes the output of midicsv and creates two arrays and
a variable you can use with a modified version of Manny Alvear's
project from RadioShack. 

Step 1: Get Manny's project working: http://blog.radioshack.com/2014/12/maker-monday-project-littlebits-synth-kit/

Step 2: Install midicsv: http://www.fourmilab.ch/webtools/midicsv/

Step 3: Download a MIDI file, and inspect it with midicsv. Figure out the number of the track you want.

Step 4: Feed the output of midicsv into this script, and supply the track number as the script's argument, as in:

midicsv Coventry_Carol.mid | ./midi2littleBits_arp.pl 2

Step 5: Take the output and replace the melody[], noteDurations[], and count declarations in the Arduino file.

Upload the Arduino file to your littleBits Arduino and feed it into the speaker, preferably through some of the synth filters!
