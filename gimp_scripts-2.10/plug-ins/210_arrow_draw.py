#!/usr/bin/env python
#
# 210_arrow_draw.py
# last modified/tested by Paul Sherman [gimphelp.org]
# 09/02/2018 on GIMP-2.10.6
#==================================================
#
# edited by Paul Sherman
#
# original by Gene Cash
# GIMP Python plug-in script to make nice arrows
#
# requires that Python scripting support be compiled into GIMP with
# --enable-python option to ./configure
#
# 07-DEC-2005 CEC Written
#===============================================
# Python script installation:
#
# This script should be placed in the user or system-wide <b>plug-ins</b> folder.
#
#	Windows Vista/7/8/10)
#	C:\Program Files\GIMP 2\lib\gimp\2.0\plug-ins
#	or
#      C:\Users\YOUR-NAME\AppData\Roaming\gimp-2.10\plug-ins
#      (AppData is a hidden directory, you have to "Show Hidden Directories"
#      under folder options in order to see it.)
#	 
#
#	Linux
#      Make sure to set the file as executable!
#
#	/home/yourname/.config/GIMP/2.10/plug-ins
#	or
#	Linux system-wide
#	/usr/lib64/gimp/2.0/plug-ins
#
#===============================================
# LICENSE
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY# without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#===============================================

from gimpfu import *
import math

default_arrow_len=20
default_arrow_aspect=0.35
default_line_thickness=2

def arrow_draw(image, drawable, arrow_len, arrow_aspect, thickness, aColor, solid):

    # attempt to retrieve details of current path
    try:
        curpath=pdb.gimp_path_get_current(image)
    except:
        pdb.gimp_message('No path found!\n\nYou need to create a path\nfor the arrow\nbefore running this script.\n')
        return
    try:
        ppoints=pdb.gimp_path_get_points(image, curpath)[3]
    except:
        pdb.gimp_message('Path must be a simple single-component connected path')
        return

    pdb.gimp_image_undo_group_start(image)
    # save some pre-existing settings and emporarily set to what is needed
    foreground = pdb.gimp_context_get_foreground()
    size = pdb.gimp_context_get_brush_size()
    antialiasOrig = pdb.gimp_context_get_antialias()
    pdb.gimp_context_set_foreground(aColor)
    pdb.gimp_context_set_brush_size(thickness)

    # get the line info...
    x1, y1=ppoints[0:2]
    # "arrow_len" is length of arrowhead
    x2, y2, slope=pdb.gimp_path_get_point_at_dist(image, arrow_len)

    # copy (and later paste) the section near the end of the line
    # so that the thickness of the line will not hang out past the arrowhead
    diff = thickness / 2
    pdb.gimp_context_set_antialias(FALSE)
    pdb.gimp_image_select_ellipse(image, 0, x1, y1, 1, 1)
    pdb.gimp_selection_grow(image, thickness + diff)
    pdb.gimp_edit_copy(drawable)
    pdb.gimp_selection_none(image)

    # stroke and delete current path
    # making the line
    pdb.gimp_path_stroke_current(image)
    pdb.gimp_path_delete(image, curpath)

    # paste that original section over the end of the line
    # so we get a clean arrowhead
    pdb.gimp_image_select_ellipse(image, 0, x1, y1, 1, 1)
    pdb.gimp_selection_grow(image, thickness + diff)
    floating_sel = pdb.gimp_edit_paste(drawable, TRUE)
    pdb.gimp_floating_sel_anchor(floating_sel)
    pdb.gimp_selection_none(image)
    pdb.gimp_context_set_antialias(antialiasOrig)

    # calculate arrowhead endpoints
    # "arrow_aspect" is width/height ratio of arrowhead
    x3=x2-(y1-y2)*arrow_aspect
    y3=y2+(x1-x2)*arrow_aspect
    x4=x2+(y1-y2)*arrow_aspect
    y4=y2-(x1-x2)*arrow_aspect

    # make arrowhead path from (x3, y3) to (x1, y1) to (x4, y4)
    pdb.gimp_path_set_points(image, curpath, 1, 24, (x3, y3, 1.0,
                                                     x3, y3, 2.0,
                                                     x1, y1, 2.0,
                                                     x1, y1, 1.0,
                                                     x1, y1, 2.0,
                                                     x4, y4, 2.0,
                                                     x4, y4, 1.0,
                                                     x4, y4, 2.0))

    # stroke and delete arrowhead path
    # doing a selection fill if "solid" was chosen
    if solid:
        pdb.gimp_path_to_selection(image, curpath, 0, TRUE, FALSE, 0, 0)
        pdb.gimp_edit_fill(drawable, 0)
        pdb.gimp_selection_none(image)
    else:
        pdb.gimp_path_stroke_current(image)

    # finish restoring  original settings and close out undo group
    pdb.gimp_path_delete(image, curpath)
    pdb.gimp_context_set_foreground(foreground)
    pdb.gimp_context_set_brush_size(size)
    pdb.gimp_image_undo_group_end(image)


register(
    "arrow_draw",
    "Arrow Draw\n\n(Requires a Path)\n\nTurns a path into an arrow -->\nwith an arrowhead at the starting point.\n\n",
    "",
    "Paul Sherman",
    "original - 2005 Gene Cash",
    "10/22/2015",
    "<Image>/Script-Fu/Arrow Draw",
    "*",
    [(PF_SLIDER,  'arrow_len', 'Arrowhead Length', default_arrow_len, (4, 100, 2)),
     (PF_SLIDER, 'arrow_aspect', 'Arrowhead Width %', default_arrow_aspect, (.35, .85, .05)),
    (PF_SLIDER, "thickness",  "Line Thickness", default_line_thickness, (1, 20, 1)),
    (PF_COLOR,    "aColor",    "Arrow Color", "black"),
    (PF_BOOL,  "solid",   "Solid Arrowhead?",   False)
    ],
    [],
    arrow_draw)

main()
