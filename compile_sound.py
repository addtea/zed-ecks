#!/usr/bin/python

import sys
import os.path

SOUND_PATH="assets/sound/"

QUARTERBEAT=80
REST="R"
TWONOTES="2"
TEMPO="TEMPO"
BREAK="BREAK"

CUT = False  # cut the music into small pieces?
CUTSIZE = 20

# W->Whole Note
# H->Half Note
# Q->Quarter Note
# E->Eighth Note
# S->Sixteenth Note
# T->Thirty-Secondth Note
#
# D->With Dot
# T->Triplet (TODO)
# Format: [TIME] [NOTE] [OCTAVE]
# Example: ED C# 1
TIMETABLE={
	"W"  : QUARTERBEAT*4,
	"H"  : QUARTERBEAT*2,
	"HD" : QUARTERBEAT*2*1.5,
	"HT" : QUARTERBEAT*2*0.33,
	"Q"  : QUARTERBEAT,
	"QD" : QUARTERBEAT*1.5,
	"QT" : QUARTERBEAT*0.33,
	"E"  : QUARTERBEAT*0.5,
	"ED" : QUARTERBEAT*0.75,
	"ET" : QUARTERBEAT*0.5*0.33,
	"S"  : QUARTERBEAT*0.25,
	"SD" : QUARTERBEAT*0.375,
	"T"  : QUARTERBEAT*0.125,
	"TD" : QUARTERBEAT*0.1875,
	"SF" : QUARTERBEAT*0.0625
}

NOTETABLE={
	"C"	 : 234,
	"C#" : 222,
	"Db" : 222,
	"D"	 : 208,
	"D#" : 196,
	"Eb" : 196,
	"E"  : 185,
	"F"  : 175,
	"F#" : 166,
	"Gb" : 166,
	"G"  : 157,
	"G#" : 148,
	"Ab" : 148,
	"A"  : 139,
	"A#" : 132,
	"Bb" : 132,
	"B"  : 124
}

def redo_timetable(newtempo):
	TIMETABLE.update({
	"W"  : newtempo*4,
	"H"  : newtempo*2,
	"HD" : newtempo*2*1.5,
	"HT" : newtempo*2*0.33,
	"Q"  : newtempo,
	"QD" : newtempo*1.5,
	"QT" : newtempo*0.33,
	"E"  : newtempo*0.5,
	"ED" : newtempo*0.75,
	"ET" : newtempo*0.5*0.33,
	"S"  : newtempo*0.25,
	"SD" : newtempo*0.375,
	"T"  : newtempo*0.125,
	"TD" : newtempo*0.1875,
	"SF" : newtempo*0.0625
	})

def write_music(f,o):
    for line in f:
	if line[0] == "#":
		continue

	if line[0] == "$":
		break

	tokens = line.split()
	if len(tokens) == 0:
		continue

	# Two Note Format:
	# 2 [TIME] [KEY1] [OCTAVE1] [KEY2] [OCTAVE2]
	if tokens[0] == TWONOTES:
		time = int(TIMETABLE[tokens[1]])
		note1 = int(NOTETABLE[tokens[2]])
		octave1 = pow(2,int(tokens[3]))
		if octave1 != 0:
			note1 = note1 / octave1
		note2 = int(NOTETABLE[tokens[4]])
		octave2 = pow(2,int(tokens[5]))
		if octave2 != 0:
			note2 = note2 / octave2
		o.write("\tdefb " + str(time) + "," +
			str(note1) + "," + str(note2) + "\n")
	# Rest Format:
	# R [TIME]
	elif tokens[0] == REST:
		time = int(TIMETABLE[tokens[1]])
		if CUT and time > CUTSIZE:
			numpieces = time / CUTSIZE
			rem = time % CUTSIZE
			for i in range(numpieces):
				o.write("\tdefb " + "254," +
					str(CUTSIZE) + "\n")
			if rem != 0:
				o.write("\tdefb " + "254," +
					str(rem) + "\n")
		else:
			o.write("\tdefb " + "254," +
				str(time) + "\n")
	elif tokens[0] == TEMPO:
		redo_timetable(int(tokens[1]))
	elif tokens[0] == BREAK:
		o.write("\tdefb 255\n")
	else:
		time = 0
		# 3E10    mult[TIMETABLE]division
		rawtime = tokens[0]
		mult = 1
		division = 1
		index = 0
		while not rawtime[index].isalpha():
			index += 1
		if index != 0:
			mult = int(rawtime[:index])
			rawtime = rawtime[index:]
			index = 0
			while rawtime[index].isalpha():
				index += 1
			time = int(TIMETABLE[rawtime[:index]])
			division = int(rawtime[index:])
		else:
			time = int(TIMETABLE[tokens[0]])

		note = 0
		if tokens[1] in NOTETABLE:
			note = int(NOTETABLE[tokens[1]])
		else:
			note = int(tokens[1])
		octave = 0
		time = int(time * mult / division)

		# check if there is octave adjustment
		if len(tokens) == 3:
			octave = pow(2,int(tokens[2]))
			note = note / octave

		if CUT and time > CUTSIZE:
			numpieces = time / CUTSIZE
			rem = time % CUTSIZE
			for i in range(numpieces):
				o.write("\tdefb " + str(CUTSIZE) + "," +
					str(note) + "\n")
			if rem != 0:
				o.write("\tdefb " + str(rem) + "," +
					str(note) + "\n")
		else:
			o.write("\tdefb " + str(time) + "," +
				str(note) + "\n")


# Main
if len(sys.argv) != 2:
	if len(sys.argv) == 4 and sys.argv[2] == "CUT":
		CUT = True
		CUTSIZE = int(sys.argv[3])
	else:
		print "Usage: ./compile_sound.py [theme name]"
		exit(-1)

INFILE = SOUND_PATH + "input/" + sys.argv[1]
OUTFILE = SOUND_PATH + sys.argv[1] + ".asm"

f = open(INFILE, 'r')
o = open(OUTFILE, 'w')

print "Reading from " + INFILE + "."
print "Writing music data to " + OUTFILE + "."

label = sys.argv[1]+"_music_data:\n"
print "...with asm label " + label

o.write("\n" + label)
write_music(f,o)
o.write("\tdefb 255\n")
