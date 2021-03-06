# The script measures the following acoustic characteristics in annotaeted tokens
# 1. voicing ratio
# 2. Total duration
# 3. Mean Intensity
# 4. Center of Gravity
#
# Kostis Dimos 
# Zurich 2015


rdir$ = "/User/database/"
wdir$ = "/Users/output/"
mylist = Create Strings as file list... mylist 'rdir$'/*.TextGrid

nFiles = Get number of strings
	voicingTable = Create Table with column names... 'sVoicing' 0 name speaker gender boundary vowel sibilant consonant vow_dur  
												... voic_ratio dur int cog
	stepwiseRow = 0

for iFile to nFiles
	select mylist
	file$ = Get string... iFile
	name$ = file$-".TextGrid"
	textgrid = Read from file... 'rdir$'/'name$'.TextGrid
	sound = Read from file... 'rdir$'/'name$'.wav
	speaker$ = left$ (name$, 2)
	gender$ = right$ (name$, 1)
	if gender$ == "2"
		gender$ = "f"
	endif
select textgrid
nInt = Get number of intervals... 3
	
		for iInt from 1 to nInt
			select textgrid
			label$ = Get label of interval... 3 iInt
 			if index_regex(label$, "[sz]")
					stepwiseRow += 1
 					vowelStart = Get starting point... 3 iInt-1
  					vowelEnd = Get end point... 3 iInt-1
    				vowelDur = vowelEnd - vowelStart
   				sStart = Get starting point... 3 iInt
   				sEnd = Get end point... 3 iInt
    				sDur = sEnd - sStart
    				intLevel = Get interval at time... 1 (sStart+sEnd)/2
    				boundary$ = Get label of interval... 1 intLevel
    				vowel$ = Get label of interval... 3 iInt-1
    				cons$ = Get label of interval... 3 iInt+1

					if index_regex(cons$, "[mn]")
						consType$ = "nasal"
					elif index_regex(cons$, "[vδγ]")
						consType$ = "fricative"
					elif index_regex(cons$, "[bdg]")
						consType$ = "plosive"
					elif index_regex(cons$, "[lr]")
						consType$ = "approximant"
					elif index_regex(cons$, "[r]")
						consType$ = "tap"					elif cons$ == ""
						consType$ = "NA"
					endif

# Extract values

				ex_textgrid = Extract part... sStart sEnd 0
				ex_nInt = Get number of intervals... 5
				ex_totalDur = Get total duration
				voicedDur = 0

					for i from 1 to ex_nInt
						vLabel$ = Get label of interval... 5 i
							if vLabel$ == "V"
								vStart = Get starting point... 5 i
								vEnd = Get end point... 5 i
								vdur = vEnd - vStart
								voicedDur += vdur
							endif
					endfor
				select ex_textgrid
				Remove

voicingRatio = voicedDur / ex_totalDur

# End of Voicing part

    	select sound
   		inten_sound1 = Extract part... sStart-0.1 sEnd+0.1 rectangular 1 yes
    		inten_sound2 = Filter (stop Hann band)... 0 2000 100
   		To Intensity... 100 0 yes
   		meanInt = Get mean... sStart sStart energy
    		maxInt  = Get maximum... sStart sStart Parabolic
   	plus inten_sound1
    	plus inten_sound2
    	Remove

    	select sound
    	cog_sound = Extract part... sStart sEnd rectangular 1 yes
    	To Spectrum... yes
    	cog = Get centre of gravity... 2
    	plus cog_sound
    	Remove

		select voicingTable
		
		Append row
		
		Set string value... stepwiseRow name 'name$'
		Set string value... stepwiseRow speaker 'speaker$'
		Set string value... stepwiseRow gender 'gender$'
		Set string value... stepwiseRow boundary 'boundary$'
		Set string value... stepwiseRow vowel 'vowel$'
		Set string value... stepwiseRow sibilant 'label$'
		Set string value... stepwiseRow consonant 'consType$'
		Set numeric value... stepwiseRow vow_dur vowelDur
		Set numeric value... stepwiseRow dur sDur
		Set numeric value... stepwiseRow voic_ratio voicingRatio
		Set numeric value... stepwiseRow int meanInt
		Set numeric value... stepwiseRow cog cog

		endif
		endfor

	select textgrid
	plus sound
	Remove

endfor


