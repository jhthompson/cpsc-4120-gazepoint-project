#!/usr/bin/env python

import sys, os, math

def catCSVFile(infile,df,ct):
  try:
    f = open(infile,'r')
  except IOError:
    print "Can't open file: " + infile
    return

  base = os.path.basename(infile)

  print "Processing: ", infile, "[", base, "]"

  # TUTORIAL NOTE: edit this to properly parse the .dat files
  # extract stimulus name and subj id
  subj = base.split('-')[0]
  group = base.split('-')[1]
  block = base.split('-')[2]
  trial = base.split('-')[3]
  task = base.split('-')[4]
  ftype = base.split('-')[5]
  ttype = base.split('-')[6]
# stim = base.split('_')[1].split('-')[0]
  print "subj, group, block, trial, task, ftype, ttype: ", \
         subj, group, block, trial, task, ftype, ttype

  # read lines, throwing away first one (header)
# linelist = f.readlines()
# linelist = f.read().split('\r')
  linelist = f.read().splitlines()
# header = linelist[0].split(',')
# linelist = linelist[1:]

  # timestamp,x,y,duration,prev_sacc_amplitude
  TIMESTAMP = 0
  X = 1
  Y = 2
  DURATION = 3
  SACC_AMPLITUDE = 4
  SACC_DUR = 5

  for line in linelist:
    entry = line.split(' ')

    # get line elements
    timestamp = entry[TIMESTAMP]
    x  = entry[X]
    y  = entry[Y]
    duration  = entry[DURATION]
    sacc_amplitude  = entry[SACC_AMPLITUDE]
    sacc_dur  = entry[SACC_DUR]

    # TUTORIAL NOTE: edit this to properly output the .csv files
    str = "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s" % ( \
                                    subj, \
                                    group,\
                                    block,\
                                    trial,\
                                    task,\
                                    ftype,\
                                    ttype,\
                                    timestamp,\
                                    x,y,\
                                    duration,\
                                    sacc_amplitude,\
                                    sacc_dur)
    print >> df,str
    ct += 1

  return ct

###############################################################################

# TUTORIAL NOTE: edit this to properly output the .csv file header
# clear out output file
df = open("fxtn.csv",'w')
print >> df,"subj,group,block,trial,task,ftype,ttype,timestamp,x,y,duration,sacc_amplitude,sacc_dur"

dir = './data/'

# find all files in dir with .csv extension
lst = filter(lambda a: a.endswith('-fxtn.dat'),os.listdir(dir))

lineno = 1

for item in lst:

  file = dir + item
  print 'Processing ', file

  # cat csv files into one
  lineno = catCSVFile(file,df,lineno)

df.close()
