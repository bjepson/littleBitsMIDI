#!/usr/bin/perl -w

# not too shabby: http://www.tc.umn.edu/~sorem002/xmas_midi.html
# nifty: https://www.westnet.com/Holiday/midi/

use strict;

my $track = shift;

# Set up an array that maps MIDI numbers to notes in Hertz
my @midi;
for (my $i = 0; $i < 127; ++$i)
{
    $midi[$i] = 440 * 2 ** (($i - 69)/12);
}

my %times;      # An array of time steps
my %curr_notes; # Current stack of notes
my $prev_time = 0; # The preceding time step

while (<>) {

    # Match a "note on" or "note off" command
    if (/^(\d+), (\d+), Note_o(?:n|ff)_c, \d+, (\d+), (\d+)/) {

        # Only extract the track specified on the command line
        my $curr_track = $1; 
        next unless $curr_track == $track;

        # Get the current point in time, the note, and velocity
        my $time = $2;
        my $note = $3;
        my $velocity = $4;

        # Store the notes whenever we reach a new time step
        if ($time > $prev_time) {
            foreach my $note (keys %curr_notes) {
                $times{$time}->{$note} = 1;
            }
        }

        # A velocity of 0 means we need to turn off the note.
        # A velocity of more than 0 means to play it.
        if ($velocity > 0) {
            $curr_notes{$note} = 1;
        } else {
            delete $curr_notes{$note};
        }

        $prev_time = $time;
    }
}

# Get a sorted list of time steps
my @keys = sort {$a <=> $b} keys %times;

# This is the time at which the current step began
my $start_time = 0;

# These arrays store the notes and their corresponding durations.
my @notes;
my @durations;

for (my $i = 0; $i < @keys; $i++) {

    my $time = $keys[$i]; # Get current time and calculate duration
    my $duration = $time - $start_time;

    # These are the MIDI notes to play
    my @play_notes = keys %{ $times{$time}};

    # If the length of the array is exactly 1, just play the note
    if (@play_notes == 1) {
        push @notes, int( $midi[$play_notes[0]] + .5);
        push @durations, $duration * 2;
    } else {
        # If there's more than one note at this point in time,
        # make a crude arpeggio.
        
        my $sum = 0; # To make sure we don't get wildly out of sync.

        # Calculate the length of each slice of the arpeggio
        my $slice = ($duration/scalar(@play_notes)) / 2;

        # Loop through the chord, over and over, until we
        # reach the duration.
        #
        my $j = 0; # start at the beginning of the array

        for (my $k = 0; $k < $duration; $k += $slice) {

            # Add the notes and durations to the array
            push @notes, int( $midi[$play_notes[$j]] + .5);
            push @durations, int($slice * 2 + .5);
            $sum += $slice;
            
            $j++; # increment the array index counter.

            # When we hit the end of the array, start at the
            # beginning.
            if ($j > $#play_notes) {
                $j = 0;
            }
        }
        if ($sum != $duration) {
           warn "sum $sum vs $duration @ $time";
        } 
    }
    $start_time = $time;
}

# print out the melody, noteDurations, and count array for
# pasting into Arduino
#
print "int melody[] = {\n";
print join(", ", @notes);
print "};\n";

print "int noteDurations[] = {\n";
print join(", ", @durations);
print "};\n";

print "int count = " . scalar @notes . ";\n";

