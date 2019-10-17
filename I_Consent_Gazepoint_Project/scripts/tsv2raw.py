#!/usr/bin/env python2

import platform,sys,os,getopt,glob
import locale
import numpy as np
import math

class Blink:

  def __init__(self, st, et):
    self.st = st
    self.et = et

class Point:

  def __init__(self, x, y, t, d):
    self.x = x
    self.y = y
    self.t = t
    self.d = d

# TUTORIAL NOTE: edit this to store desired information
#                (changes for every experiment, how to generalize?)
class Run:

  def __init__(self):
    self.block = '-1'
    self.trial = '-1'
    self.task = 'UNKNOWN'
    self.ttype = 'UNKNOWN'
    self.ftype = 'UNKNOWN'
    self.morphs = []
    self.points = []

  def setInfo(self,block,trial,task,ttype,ftype):
    self.block = block
    self.trial = trial
    self.task = task
    self.ttype = ttype
    self.ftype = ftype

def is_odd(a):
  return bool(a - ((a>>1)<<1))

def isfloat(value):
  try:
#   float(value)
    float(locale.atof(value))
    return True
  except:
    return False

def usage():
  print "Usage: python tsv2raw.py " \
        " --indir=? -outdir=?\n" \
        " --width=? -height=?\n" \
        " --file=?\n" \
        " --downsample\n" \
        "   indir: a directory containing input files to be processed\n" \
        "   outdir: a directory containing output files\n" \
        "   width: horiz. gaze coord extents\n" \
        "   height: vert. gaze coord extents\n" \
        "   file: a single file to process\n" \
        "   downsample: yes or no\n"

# convert asc file to raw
def tsv2raw(infile,outdir,width,height,dist,downsample,removeblinks,group):
  try:
    f = open(infile,'r')
  except IOError:
    print "Can't open file: " + infile
    return

  # parse the subject name from the file name
# base = infile[:infile.rfind('.')]
  path = infile
  base = os.path.basename(path)
  dname = path.split('/')[2]
  if base.endswith('.tsv'):
    basename = base[:base.rfind('.tsv')]
    print path, dname, base, "[",basename,"]","[",file,"]"
  if base.endswith('.txt'):
    basename = base[:base.rfind('.txt')]
    print path, dname, base, "[",basename,"]","[",file,"]"

  # read lines, throwing away first one (header)
  linelist = f.read().splitlines()
  header = linelist[0].split('\t')
  linelist = linelist[1:]

  # TUTORIAL NOTE: subj, group come from directory and file name
  print "Processing: ", infile, "[", base, "]"
  subj = basename
  print "subj: ", subj
  print "group: ", group

  # TUTORIAL NOTE: edit this by looking at data file header
  for idx, label in enumerate(header):
    if label.strip().strip("\"") == 'blocknr':
      BLOCKNR = idx
    if label.strip().strip("\"") == 'trialnr':
      TRIALNR = idx
    if label.strip().strip("\"") == 'emotion':
      EMOTION = idx
    if label.strip().strip("\"") == 'face':
      FACE = idx
    if label.strip().strip("\"") == "task":
      TASK = idx
    if label.strip().strip("\"") == "gender":
      GENDER = idx
    if label.strip().strip("\"") == "TIMESTAMP":
      TIMESTAMP = idx
    if label.strip().strip("\"") == "LEFT_GAZE_X":
      LEFT_GAZE_X = idx
    if label.strip().strip("\"") == "LEFT_GAZE_Y":
      LEFT_GAZE_Y = idx
    if label.strip().strip("\"") == "LEFT_PUPIL_SIZE":
      LEFT_PUPIL_SIZE = idx
    if label.strip().strip("\"") == "RIGHT_GAZE_X":
      RIGHT_GAZE_X = idx
    if label.strip().strip("\"") == "RIGHT_GAZE_Y":
      RIGHT_GAZE_Y = idx
    if label.strip().strip("\"") == "RIGHT_PUPIL_SIZE":
      RIGHT_PUPIL_SIZE = idx

  # pass 1: find blinks

  blinks = []
# blinkdict = {}

  withinblink = False

  for line in linelist:

    elements = line.split('\t')
    entry = np.asarray(elements)

    # blink can be either left eye or right eye
    if not withinblink and \
      (entry[LEFT_PUPIL_SIZE] == '.' or entry[RIGHT_PUPIL_SIZE] == '.'):

      withinblink = True

#     print "found SBLINK at time: ", entry[TIMESTAMP]

      value = entry[TIMESTAMP].strip()
      bst = locale.atof(value)

    elif withinblink and \
       entry[LEFT_PUPIL_SIZE] != '.' and entry[RIGHT_PUPIL_SIZE] != '.':

      withinblink = False

#     print "found EBLINK at time: ", entry[TIMESTAMP]

      value = entry[TIMESTAMP].strip()
      bet = locale.atof(value)

#     print "adding blink at times: ", bst, ":", bet

      blinks.append(Blink(bst,bet))
#     blinkdict[bst] = bet

  outfile = None

  # pass 2: get data
  # reset coords
  x = ''
  y = ''
  d = ''
  t = ''

  block = ''
  trial = ''
  task = ''
  emotion = ''

  runs = []
  run = Run()

  for line in linelist:

    elements = line.split('\t')
    entry = np.asarray(elements)

    t = locale.atof(entry[TIMESTAMP])

    xl = -1.0
    yl = -1.0
    pl = -1.0
    xr = -1.0
    yr = -1.0
    pr = -1.0

    if isfloat(entry[LEFT_GAZE_X]) and isfloat(entry[LEFT_GAZE_Y]):
      xl = locale.atof(entry[LEFT_GAZE_X])/width
      # do not do the y-coord flip, origin is at upper-left
      yl = locale.atof(entry[LEFT_GAZE_Y])/height
      # do the y-coord flip as origin seems to be at lower-left
#     yl = (height - locale.atof(entry[LEFT_GAZE_Y]))/height

    if isfloat(entry[LEFT_PUPIL_SIZE]):
      pl = locale.atof(entry[LEFT_PUPIL_SIZE])

    if isfloat(entry[RIGHT_GAZE_X]) and isfloat(entry[RIGHT_GAZE_Y]):
      xr = locale.atof(entry[RIGHT_GAZE_X])/width
      # do not do the y-coord flip, origin is at upper-left
      yr = locale.atof(entry[RIGHT_GAZE_Y])/height
      # do the y-coord flip as origin seems to be at lower-left
#     yr = (height - locale.atof(entry[RIGHT_GAZE_Y]))/height

    if isfloat(entry[RIGHT_PUPIL_SIZE]):
      pr = locale.atof(entry[RIGHT_PUPIL_SIZE])

    # data not already normalized, need to divide by screen size
    if xl > 0.0 and xr > 0.0:
      x = str((xl + xr)/2.0)
    elif xl > 0.0:
      x = str(xl)
    elif xr > 0.0:
      x = str(xr)
    else:
      x = '-1'

    if yl > 0.0 and yr > 0.0:
      y = str((yl + yr)/2.0)
    elif yl > 0.0:
      y = str(yl)
    elif yr > 0.0:
      y = str(yr)
    else:
      y = '-1'

    if pl > 0.0 and pr > 0.0:
#     d = str((pl + pr)/2.0)
      # get average pupil diameter in arbitrary units
      d_arb = (pl + pr)/2.0
      # convert to mm as per Hayes and Petrov 2016
      d = str(0.000170 * d_arb * dist)
    elif pl > 0.0:
      d = str(pl)
    elif pr > 0.0:
      d = str(pr)
    else:
      d = '0.0'

    # special case for participant SOR_es30xsa use only right eye
    if base == "SOR_es30xsa":

      if xr > 0.0:
        x = str(xr)
      else:
        x = '-1'

      if yr > 0.0:
        y = str(yr)
      else:
        y = '-1'

      if pr > 0.0:
        d = str(pr)
      else:
        d = '0.0'

#   print "xl,yl = %s,%s" % (entry[LEFT_GAZE_X],entry[LEFT_GAZE_Y])
#   print "xr,yr = %s,%s" % (entry[RIGHT_GAZE_X],entry[RIGHT_GAZE_Y])
#   print "x,y = %f,%f" % (float(x),float(y))

    if entry[BLOCKNR] != run.block or entry[TRIALNR] != run.trial:

      # TUTORIAL NOTE: edit this to extract desired information
      #                (changes for every experiment, how to generalize?)
      block = entry[BLOCKNR]
      trial = entry[TRIALNR]
      task = entry[TASK]
      print "block, trial, type: ", block, trial, entry[EMOTION]

      # new run
      if run.block == '-1' and run.ttype == 'UNKNOWN':
        # first run
        pass
      else:
        # if not first run, add current run to list and start new one
        runs.append(run)
        run = Run()

      # we've got a new run, need to set info
      run.setInfo(block,trial,task,entry[EMOTION],entry[FACE])

    # add point to run
    if float(x) > 0.0 and float(y) > 0.0:
      run.points.append(Point(x,y,t,d))

  # don't forget the last run
  runs.append(run)

  # pass 2.5: dump data
# allpoints = 0
# for run in runs:
#   print "%s %s %s" % (run.block, run.trial, run.ttype)
#   print "%d points" % (len(run.points))
#   allpoints += len(run.points)
# print "number of blinks: %d" % (len(blinks))

# print "TOTAL POINTS: %d" % allpoints

  # pass 3: dump data

  trial = ''

  for run in runs:

    # TUTORIAL NOTE: edit this to output desired information
    #                (changes for every experiment, how to generalize?)
    oname = "%s%s-%s-%s-%s-%s-%s-%s.raw" % \
            (outdir,\
             subj,\
             group,\
             run.block,\
             run.trial,\
             run.task,\
             run.ftype,\
             run.ttype)

    outfile = open(oname,'w+')

    print "oname: ", oname

    bk = 0
    k = 0
    for pt in run.points:

      withinblink = False

      if removeblinks and len(blinks):

        # get next blink
        bst = blinks[bk].st
        bet = blinks[bk].et

        if int(pt.t) <= (bst - 200):
          # point ok
          pass

        elif (bst - 200) < int(pt.t) and int(pt.t) < (bet + 200):
#         print "point at %d is [-200,200] ms of blink at %d:%d" % \
#                   (int(pt.t),bst,bet)
          withinblink = True

        elif (bet + 200) <= int(pt.t):
          # point has passed the blink in time, advance to next blink
          while bk < len(blinks)-1 and (blinks[bk].st - 200) < int(pt.t):
            bk += 1

        if not withinblink:
  
            if downsample:
              if is_odd(k):
                strout = "%f %f %f %f" % \
                         (float(pt.x), float(pt.y), float(pt.d), float(pt.t))
                outfile.write(strout + '\n')
            else:
              strout = "%f %f %f %f" % \
                       (float(pt.x), float(pt.y), float(pt.d), float(pt.t))
              outfile.write(strout + '\n')

      else:

        # don't remove blinks
        if downsample:
          if is_odd(k):
            strout = "%f %f %f %f" % \
                         (float(pt.x), float(pt.y), float(pt.d), float(pt.t))
            outfile.write(strout + '\n')
          else:
            strout = "%f %f %f %f" % \
                         (float(pt.x), float(pt.y), float(pt.d), float(pt.t))
            outfile.write(strout + '\n')
        else:
          # don't remove blinks, don't downsample
          strout = "%f %f %f %f" % \
                        (float(pt.x), float(pt.y), float(pt.d), float(pt.t))
          outfile.write(strout + '\n')

      k += 1

    outfile.close()

def main(argv):
# if not len(argv):
#   usage()

  try:
    opts, args = getopt.getopt(argv, '', \
                 ['indir=','outdir=',\
                  'file=',\
                  'group=',\
                  'downsample','removeblinks',\
                  'width=','height=','dist='])
  except getopt.GetoptError, err:
    usage()
    exit()

  file = None
  downsample = False
  removeblinks = False

  group = 'pilot'

  for opt,arg in opts:
    opt = opt.lower()
    if opt != '--file' and opt != '--indir':
      arg = arg.lower()

    if opt == '--indir':
      indir = arg
    elif opt == '--outdir':
      outdir = arg
    elif opt == '--group':
      group = arg
    elif opt == '--width':
      width = float(arg)
    elif opt == '--height':
      height = float(arg)
    elif opt == '--dist':
      # convert distance to cm and then to mm
      dist = float(arg) * 2.54 * 10.0
    elif opt == '--downsample':
      downsample = True
    elif opt == '--removeblinks':
      removeblinks = True
    else:
      sys.argv[1:]

  indir = indir + group + '/'

  files = []

  # get .csv input files to process
  if os.path.isdir(indir):
#   files = glob.glob('%s/*.asc' % (indir))
    for top, dirs, listing in os.walk(indir):
      for file in listing:
        path = os.path.join(top,file)
        dname = path.split('/')[2]
        base = os.path.basename(path)
        if base.endswith('.tsv'):
          basename = base[:base.rfind('.tsv')]
#         print path, top, dname, base, "[",basename,"]","[",file,"]"
          files.extend([path])
        if base.endswith('.txt'):
          basename = base[:base.rfind('.txt')]
#         print path, top, dname, base, "[",basename,"]","[",file,"]"
          files.extend([path])

  # if user specified --file="..." then we use that as the only one to process
  if(file != None and os.path.isfile(file)):
    files = [file]

  for file in files:
    tsv2raw(file,outdir,width,height,dist,downsample,removeblinks,group)

#######################
# on Windows, see bottom of this web page:
# http://stackoverflow.com/questions/19709026/how-can-i-list-all-available-windows-locales-in-python-console

#locale.setlocale( locale.LC_ALL, 'en_US.UTF-8' )
#locale.setlocale( locale.LC_ALL, 'de_DE' )
if platform.system() == 'Windows':
  locale.setlocale( locale.LC_ALL, 'German' )
else:
  locale.setlocale( locale.LC_ALL, 'de_DE' )

if __name__ == "__main__":
  main(sys.argv[1:])
