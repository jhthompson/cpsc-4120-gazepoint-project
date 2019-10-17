#!/usr/bin/env python2

# system includes
import sys
import os
#import xml.etree.ElementTree as ET
from xml.etree import ElementTree as ET
from xml.etree.ElementTree import tostring
import numpy as np

# local includes
from aoi import AOI

def main(argv):

  indir = "../../stimulus/static/"

  aoi = AOI(179,764.0,211,108)

  aoi.dump()

  print "in" if aoi.inside(180.0,780) else "out"
  print "in" if aoi.inside(0.0,0.0) else "out"

  # process AOI file
  aoidir = "../../stimulus/static/"
  aoifile = aoidir + "aoidefinition.sla"
  print "aoifile = ", aoifile

  aoidict = {}
  aoilist = []

  if(os.path.isfile(aoifile)):

    print "parsing: ", aoifile

    tree = ET.parse(aoifile)
    #print "tree = %s" % tree

    # should be something like Experiment, {}
    root = tree.getroot()
  # print "root.tag = %s, root.attrib = %s" % (root.tag, root.attrib)

    # iterate through PAGEOBJECT objects, look for PTYPE=''6'
    print "PAGE INFO:"
    for obj in root.iter('MASTERPAGE'):
      px = obj.get('PAGEXPOS')
      py = obj.get('PAGEYPOS')
      pw = obj.get('PAGEWIDTH')
      ph = obj.get('PAGEHEIGHT')
      bl = obj.get('BORDERLEFT')
      br = obj.get('BORDERRIGHT')
      bt = obj.get('BORDERTOP')
      bb = obj.get('BORDERBOTTOM')
      print "%s %s %s %s" % (px,py,pw,ph)
      print "%s %s %s %s" % (bl,br,bt,bb)

    print "IMAGE INFO:"
    for obj in root.iter('PAGEOBJECT'):
      if obj.get('PTYPE') == '2':
        x = obj.get('XPOS')
        y = obj.get('YPOS')
        w = obj.get('WIDTH')
        h = obj.get('HEIGHT')
        print "%s %s %s %s" % (x,y,w,h)

    # iterate through PAGEOBJECT objects, look for PTYPE=''6'
    for obj in root.iter('PAGEOBJECT'):
      if obj.get('PTYPE') == '6':
        x = obj.get('XPOS')
        y = obj.get('YPOS')
        w = obj.get('WIDTH')
        h = obj.get('HEIGHT')
        label = obj.get('ANNAME')
        x = str(float(x) - float(px))
        y = str(float(y) - float(py))
        print "%s: %s %s %s %s" % (label,x,y,w,h)

#       for (0,0) at bottom
#       aoi = AOI(x,y,w,h-y)
#       for (0,0) at top
        aoi = AOI(x,y,w,h)
        aoi.setAOILabel(label)
#       aoi.dump()
#       if aoidict.has_key(stimulus):
#         aoidict[stimulus].append(aoi)
#       else:
#         aoidict[stimulus] = [aoi]
        aoilist.append(aoi)

        del aoi

# print aoidict
# for key in aoidict:
#   print key
#   print "number of AOIs: ",len(aoidict[key])
#   for aoi in aoidict[key]:
#     aoi.dump()
  print "number of AOIs: ",len(aoilist)
  for aoi in aoilist:
    aoi.dump()

if __name__ == "__main__":
  main(sys.argv[1:])
