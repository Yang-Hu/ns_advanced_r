library(Rmusic)

# Note to code:
# http://www.sengpielaudio.com/calculator-notenames.htm



#  Create a vector for the notes of Jingle Bells.  I like to do this by thinking about strings of notes for each bar of music and then using `strsplit()` to convert this to a vector with each note as an entry.  Here I am writing quite a fun, virtuoso version of Jingle Bells.


interst_pitch <- paste(
  "A3 E",
  "A3 E",
  "B3 E",
  "B3 E",
  "C E",
  "C E",
  "D E",
  "D E B3",
  "A4 E5",
  "A4 E5",
  "B4 E5",
  "B4 E5",
  "C5 E5",
  "C5 E5",
  "D5 E5",
  "D5 E5")


interst_pitch <- strsplit(interst_pitch, " ")[[1]]

# Now create a similar vector with the durations of each notes as proportion of a beat.  This vector should be the same length as the notes vector.  I like to do this with a line for each bar of music.


interst_duration <- c(
  2, 4,
  2, 4,
  2, 4,
  2, 4,
  2, 4,
  2, 4,
  2, 4,
  2, 2, 2,
  2, 4,
  2, 4,
  2, 4,
  2, 4,
  2, 4,
  2, 4,
  2, 4,
  3, 6)


# To play or save, pick the right tempo and go:


play_music(interst_pitch, interst_duration, tempo = 180)

save_music(interst_pitch, interst_duration, output_file = "inters.wav", tempo = 180)
