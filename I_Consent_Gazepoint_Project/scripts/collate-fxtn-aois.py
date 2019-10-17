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
  print "subj, group, block, trial, ftype, ttype: ", \
         subj, group, block, trial, ftype, ttype

  # read lines, throwing away first one (header)
# linelist = f.readlines()
# linelist = f.read().split('\r')
  linelist = f.read().splitlines()
  header = linelist[0].split(',')
  linelist = linelist[1:]

  # timestamp,x,y,duration,prev_sacc_amplitude,aoi_label
  for idx, label in enumerate(header):
    if label.strip() == "timestamp":
      TIMESTAMP = idx
    if label.strip() == "x":
      X = idx
    if label.strip() == "y":
      Y = idx
    if label.strip() == "duration":
      DURATION = idx
    if label.strip() == "prev_sacc_amplitude":
      PREV_SACC_AMPLITUDE = idx
    if label.strip() == "aoi_label":
      AOI_LABEL = idx

  for line in linelist:
    entry = line.split(',')

    # get line elements
    timestamp = entry[TIMESTAMP]
    x  = entry[X]
    y  = entry[Y]
    duration  = entry[DURATION]
    prev_sacc_amplitude  = entry[PREV_SACC_AMPLITUDE]
    aoi_label  = entry[AOI_LABEL]
    if aoi_label == "leye":
      aoi_numb = '1'
    elif aoi_label == "reye":
      aoi_numb = '2'
    elif aoi_label == "nose":
      aoi_numb = '3'
    elif aoi_label == "mouth":
      aoi_numb = '4'
    else:
      aoi_numb = '0'
      print "************ ERROR: ", infile, " has strange AOI label"

    # TUTORIAL NOTE: edit this to properly output the .csv files
    str = "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s" % ( \
                         subj, \
                         group, \
                         block, \
                         trial, \
                         task, \
                         ftype, \
                         ttype, \
                         timestamp,\
                         x,y,\
                         duration,\
                         prev_sacc_amplitude,\
                         aoi_numb,\
                         ct)
    print >> df,str
    ct += 1

  return ct

###############################################################################

# TUTORIAL NOTE: edit this to properly output the .csv file header
# clear out output file
df = open("fxtn-aois.csv",'w')
print >> df,"subj,group,block,trial,task,ftype,ttype,timestamp,x,y,duration,prev_sacc_amplitude,aoi_label,order"

dir = './data/'

# find all files in dir with .csv extension
lst = filter(lambda a: a.endswith('-fxtn-aoi.csv'),os.listdir(dir))

lineno = 1

for item in lst:

  file = dir + item
  print 'Processing ', file

  # cat csv files into one
  lineno = catCSVFile(file,df,lineno)

df.close()
