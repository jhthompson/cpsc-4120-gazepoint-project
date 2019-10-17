#!/usr/bin/env python

import sys, os, math

def catDATFile(infile,df,ct):
  try:
    f = open(infile,'r')
  except IOError:
    print "Can't open file: " + infile
    return

  path, base = os.path.split(infile)

  print "Processing: ", infile, "[", base, "]"

  # split filename from extension
  filename, ext = os.path.splitext(base)

  print "path, base, filename, ext: ", path, base, filename, ext

  # TUTORIAL NOTE: edit this to properly parse the .dat files
  # extract stimulus name and subj id
  subj = filename.split('-')[0]
  group = filename.split('-')[1]
  block = filename.split('-')[2]
  trial = filename.split('-')[3]
  task = filename.split('-')[4]
  ftype = filename.split('-')[5]
  ttype = filename.split('-')[6]
  print "subj, group, block, trial, task, ftype, ttype: ", \
         subj, group, block, trial, task, ftype, ttype

  # read lines, throwing away first one (header)
# linelist = f.readlines()
# linelist = f.read().split('\r')
  linelist = f.read().splitlines()
# header = linelist[0].split(',')
# linelist = linelist[1:]

  epsilon = 0.00001

  for line in linelist:
    entry = line.split(' ')

    # get line elements
    timestamp = entry[0]
    x = entry[1]
    y = entry[2]
    duration = entry[3]
    msrn = entry[4]
    msrt = entry[5]

#   if float(msrt) > epsilon:

    # TUTORIAL NOTE: edit this to properly output the .csv files
    str = "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s" % ( \
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
                         msrn,\
                         msrt)

    print >> df,str
    ct += 1

  return ct

###############################################################################

# TUTORIAL NOTE: edit this to properly output the .csv file header
# clear out output file
df = open("msrt.csv",'w')
print >> df,"subj,group,block,trial,task,ftype,ttype,timestamp,x,y,duration,msrn,msrt"

dir = './data/'

# find all files in dir with .csv extension
lst = filter(lambda a: a.endswith('-msrt.dat'),os.listdir(dir))

lineno = 1

for item in lst:

  if "VALIDATION" in item:
    continue

  file = dir + item
  print 'Processing ', file

  # cat csv files into one
  lineno = catDATFile(file,df,lineno)

df.close()
