#!/usr/bin/env python2
# was using /sw/bin/python2.7 -tt
# filter.py
# this file is the driver for the python analysis script

# system includes
import sys
import os
import getopt
import glob
import numpy as np

# local includes
from scanpath import Scanpath
from aoi import AOI

import plotter

def usage():
  print "Usage: python filter.py " \
        " --width=? --height=? --screen=? --dist=?" \
        " --xtiles=? --ytiles=?\n" \
        " --indir=? --imgdir=? --outdir=? --pltdir=?\n" \
        " --file=?\n" \
        " --hertz=?\n" \
        " --sfdegree=? --sfcutoff=?\n" \
        " --dfdegree=? --dfwidth=?\n" \
        " --vt=?\n" \
        " --baselineT=? --endT=?\n" \
        " --smooth=?\n"\
        "   width, height: screen dimensions (in pixels)\n" \
        "   screen: screen diagonal dimension (in inches)\n" \
        "   dist: viewing distance (in inches)\n" \
        "   xtiles: number of AOI tiles (in x direction)\n" \
        "   ytiles: number of AOI tiles (in y direction)\n" \
        "   indir: a directory containing input files to be processed\n" \
        "   imgdir: a directory containing image files\n" \
        "   outdir: a directory containing output files\n" \
        "   pltdir: a directory containing plot files\n" \
        "   file: a single file to process\n" \
        "   hertz: the sampling rate of the data\n" \
        "   sfdegree: butterworth filter smoothing degree \n" \
        "   sfcutoff: butterworth filter smoothing cutoff \n" \
        "   dfdegree: savitzky-golay filter degree \n" \
        "   dfwidth: savitzky-golay filter width \n" \
        "   vt: min velocity for change to be a saccade\n"\
        "   baselineT: time for pupil diameter baseline\n"\
        "   endT: max time to average pupil diameter difference\n"\
        "   smooth: True enables butterworth smoothing\n"

def main(argv):
# if not len(argv):
#   usage()

  try:
    opts, args = getopt.getopt(argv, '', \
                 ['width=','height=',\
                  'hertz=',\
                  'screen=','dist=',\
                  'xtiles=','ytiles=',\
                  'indir=','imgdir=','outdir=','pltdir=',\
                  'file=',\
                  'hertz=','sfdegree=','sfcutoff=',\
                  'dfdegree=','dfwidth=',\
                  'baselineT=','endT=',\
                  'vt=','smooth='])
  except getopt.GetoptError, err:
    usage()
    exit()

  # Enable/disable butterworth smoothing.
  smooth = False
  # screen height in pixels
  width = 1024
  height = 768
  # screen diagonal (in inches)
  screen = 17
  # viewing distance (in inches)
  dist = 23.62
  # sampling rate
  herz = 500.0
  # smoothing (Butterworth) filter parameters: degree, cutoff
  sfdegree = 2
  sfcutoff = 1.15 # more smooth
# sfcutoff = 1.65
# sfcutoff = 1.85
# sfcutoff = 2.15 # last used
# sfcutoff = 2.35
# sfcutoff = 3.15
# sfcutoff = 4.15
# sfcutoff = 6.15 # less smooth
  # differentiation (SG) filter parameters: width, degree, order
# dfwidth = 5
  if smooth:
      dfwidth = 3
      dfdegree = 2
  else: 
      dfwidth = 5
      dfdegree = 3
  dfo = 1
  # velocity threshold
# T = 5.0  # more fixations
# T = 18.0
# T = 20.0
# T = 25.0
# T = 30.0
# T = 35.0 # fewer fixations
# T = 40.0 # last used
  T = 100.0 # last used
# T = 120.0 # last used
# T = 150.0 # last used

  baselineT = 2.0
  endT = 200.0

  file = None
  # initially don't use an image (just plain white bgnd for plots)
  image = None

  # set up AOI grid
  xtiles = 4
  ytiles = 3

  outdir = "./data"
  pltdir = "./plots"

  # checkedbeforehand so that custom parameters could still be used...
  # check if smooth is an option. We will set default parameters based on 
  # value. If others are provided via the command line, we will use them.
  try:
    arg = opts[[t[0] for t in opts].index('--smooth')][1]
    if arg.lower() == 'true':
        smooth = True
    elif arg.lower() == 'false':
        smooth = False
    else:
        print "Warning, invalid smooth value. Assuming default."
    if (smooth):
      dfwidth = 3
      dfdegree = 2
    else:
      dfwidth = 5
      dfdegree = 3
  except Exception as e:
    print e
    sys.exit()
    pass

  dfwidth = 3
  dfdegree = 3

  for opt,arg in opts:
    opt = opt.lower()
    if(opt != '--file'):
      arg = arg.lower()

    if opt == '--indir':
      indir = arg
    elif opt == '--imgdir':
      imgdir = arg
    elif opt == '--outdir':
      outdir = arg
    elif opt == '--width':
      width = arg
    elif opt == '--height':
      height = arg
    elif opt == '--screen':
      screen = float(arg)
    elif opt == '--dist':
      dist = float(arg)
    elif opt == '--xtiles':
      xtiles = int(arg)
    elif opt == '--ytiles':
      ytiles = int(arg)
    elif opt == '--file':
      file = arg
    elif opt == '--hertz':
      herz = float(arg)
    elif opt == '--sfdegree':
      sfdegree = float(arg)
    elif opt == '--sfcutoff':
      sfcutoff = float(arg)
    elif opt == '--dfdegree':
      dfdegree = float(arg)
    elif opt == '--dfwidth':
      dfwidth = float(arg)
    elif opt == '--vt':
      T = float(arg)
    elif opt == '--baselinet':
      baselineT = float(arg)
    elif opt == '--endt':
      endT = float(arg)
    else:
      sys.argv[1:]

  basescanpath = None

  # get .raw input files to process
  if os.path.isdir(indir):
    files = glob.glob('%s/*.raw' % (indir))

  # if user specified --file="..." then we use that as the only one to process
  if file != None:
    file = indir + file
    if os.path.isfile(file):
      files = [file]
      print "overriding files with: ", files

  prev_subj = None
  prev_block = None

  for file in files:

    # don't process empty files
    if os.path.getsize(file) == 0:
      continue

#   base = os.path.basename(file)
    path, base = os.path.split(file)

    print "Processing: ", file, "[", base, "]"

    # split filename from extension
    filename, ext = os.path.splitext(base)

    scanpath = Scanpath()
    scanpath.parseFile(file,width,height,herz)

    # must be called after pdwt
    scanpath.smooth("%s/%s-smth%s" % (outdir,filename,".dat"),\
                            width,height,herz,sfdegree,sfcutoff,smooth)
    scanpath.differentiate("%s/%s-diff%s" % (outdir,filename,".dat"),\
                            width,height,screen,dist,herz,dfwidth,dfdegree,dfo)
    scanpath.threshold("%s/%s-fxtn%s" % (outdir,filename,".dat"),\
                            width,height,T)
    scanpath.saccades("%s/%s-sacc%s" % (outdir,filename,".dat"),\
                            width,height,screen,dist,herz)
#   scanpath.gridify("%s/%s-aois%s" % (outdir,filename,".csv"),\
#                           subj,cond,width,height,xtiles,ytiles)
#   scanpath.dumpFixatedAOIs("%s/%s-fxtn-aoi%s" % (outdir,filename,".csv"),\
#                           width,height,\
#                           aoidict,\
#                           imagebase)

#   scanpath.dumpDAT("%s/%s%s" % (outdir,filename,".dat"),width,height)
#   scanpath.dumpXML("%s/%s%s" % (outdir,filename,".xml"),width,height)

    print " "

    del scanpath

if __name__ == "__main__":
  main(sys.argv[1:])
