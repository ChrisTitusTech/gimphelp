; 210_create-new_scribbled-text.scm
; last modified/tested by Paul Sherman [gimphelp.org]
; 05/11/2019 on GIMP 2.10.10
;==================================================
;
; Installation:
; This script should be placed in the user or system-wide script folder.
;
;	Windows 7/10
;	C:\Program Files\GIMP 2\share\gimp\2.0\scripts
;	or
;	C:\Users\YOUR-NAME\AppData\Roaming\GIMP\2.10\scripts
;	
;    
;	Linux
;	/home/yourname/.config/GIMP/2.10/scripts  
;	or
;	Linux system-wide
;	/usr/share/gimp/2.0/scripts
;
;==================================================
;
; LICENSE
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;==============================================================
; Original information 
; 
;;; i26-gunya2.scm -*-scheme-*-
;;; Time-stamp: <1997/05/11 18:46:26 narazaki@InetQ.or.jp>
;;; Author: Shuji Narazaki (narazaki@InetQ.or.jp)
; ************************************************************************
; Changed on Feb 4, 1999 by Piet van Oostrum <piet@cs.uu.nl>
; For use with GIMP 1.1.
; All calls to gimp-text-* have been converted to use the *-fontname form.
; The corresponding parameters have been replaced by an SF-FONT parameter.
; ************************************************************************
;;;  This is the first font decoration of Imigre-26 (i26)
;==============================================================


(define (210-scribbled-text 
		text 
		text-color 
		frame-color 
		font 
		font-size 
		frame-size 
		merge 
		transparent
	)
	
  (let* (
        (img (car (gimp-image-new 256 256 RGB)))
        (border (/ font-size 10))
        (text-layer (car (gimp-text-fontname img -1 0 0 text (* border 2)
                                             TRUE font-size PIXELS font)))
        (width (car (gimp-drawable-width text-layer)))
        (height (car (gimp-drawable-height text-layer)))
        (dist-text-layer (car (gimp-layer-new img width height RGBA-IMAGE
                                              "Distorted text" 100 LAYER-MODE-NORMAL-LEGACY)))
        (dist-frame-layer (car (gimp-layer-new img width height RGBA-IMAGE
                                               "Distorted text" 100 LAYER-MODE-NORMAL-LEGACY)))
        (distortion-img (car (gimp-image-new width height GRAY)))
        (distortion-layer (car (gimp-layer-new distortion-img width height
                                               GRAY-IMAGE "temp" 100 LAYER-MODE-NORMAL-LEGACY)))
        (radius (/ font-size 10))
        (prob 0.5)
        )

    (gimp-context-push)

    (gimp-image-undo-disable img)
    (gimp-image-undo-disable distortion-img)
    (gimp-image-resize img width height 0 0)
    (gimp-image-insert-layer img dist-text-layer 0 -1)
    (gimp-image-insert-layer img dist-frame-layer 0 -1)
    (gimp-image-insert-layer distortion-img distortion-layer 0 -1)
    (gimp-selection-none img)
    (gimp-edit-clear dist-text-layer)
    (gimp-edit-clear dist-frame-layer)
    ;; get the text shape
    (gimp-image-select-item img CHANNEL-OP-REPLACE text-layer)
    ;; fill it with the specified color
    (gimp-context-set-foreground text-color)
    (gimp-edit-fill dist-text-layer FOREGROUND-FILL)
    ;; get the border shape
    (gimp-selection-border img frame-size)
    (gimp-context-set-background frame-color)
    (gimp-edit-fill dist-frame-layer BACKGROUND-FILL)
    (gimp-selection-none img)
    ;; now make the distortion data
    (gimp-context-set-background '(255 255 255))
    (gimp-edit-fill distortion-layer BACKGROUND-FILL)
    (plug-in-noisify RUN-NONINTERACTIVE distortion-img distortion-layer FALSE prob prob prob 0.0)
    (plug-in-gauss-rle RUN-NONINTERACTIVE distortion-img distortion-layer radius 1 1)
    (plug-in-c-astretch RUN-NONINTERACTIVE distortion-img distortion-layer)
    (plug-in-gauss-rle RUN-NONINTERACTIVE distortion-img distortion-layer radius 1 1)
    ;; OK, apply it to dist-text-layer
    (plug-in-displace RUN-NONINTERACTIVE img dist-text-layer radius radius 1 1
                      distortion-layer distortion-layer 1)
    ;; make the distortion data once again fro the frame
    (gimp-edit-fill distortion-layer BACKGROUND-FILL)
    (plug-in-noisify RUN-NONINTERACTIVE distortion-img distortion-layer FALSE prob prob prob 0.0)
    (plug-in-gauss-rle RUN-NONINTERACTIVE distortion-img distortion-layer radius 1 1)
    (plug-in-c-astretch RUN-NONINTERACTIVE distortion-img distortion-layer)
    (plug-in-gauss-rle RUN-NONINTERACTIVE distortion-img distortion-layer radius 1 1)
    ;; then, apply it to dist-frame-layer
    (plug-in-displace RUN-NONINTERACTIVE img dist-frame-layer radius radius 1 1
                      distortion-layer distortion-layer 1)
    ;; Finally, clear the bottom layer (text-layer)
    (gimp-selection-all img)
    (gimp-context-set-background '(255 255 255))
    (gimp-edit-fill text-layer BACKGROUND-FILL)
	
    (if (= transparent 1)
	(begin
		(gimp-layer-add-alpha text-layer)
		(gimp-drawable-fill text-layer TRANSPARENT-FILL)
	  )
	)		
    ;; post processing
    (gimp-image-set-active-layer img dist-text-layer)
    (gimp-selection-none img)
	
    (if (= merge TRUE)
;        (gimp-image-flatten img)
		(gimp-image-merge-visible-layers img CLIP-TO-IMAGE)
    )	
	
    (gimp-image-undo-enable img)
    (gimp-image-delete distortion-img)
    (gimp-display-new img)

    (gimp-context-pop)
  )
)

(script-fu-register "210-scribbled-text"
	"Scribbled Text"
	"Create a logo in a two-color, scribbled text style"
	"Shuji Narazaki"
	"Shuji Narazaki"
	"1997"
	""
	SF-STRING     	"Text"               	"GIMP"
	SF-COLOR      	"Text color"         	"red"
	SF-COLOR      	"Frame color"        	'(0 34 255)
	SF-FONT       	"Font"               	"Becker"
	SF-ADJUSTMENT 	"Font size (pixels)" 	'(100 2 1000 1 10 0 1)
	SF-ADJUSTMENT 	"Frame size"         	'(2 1 20 1 5 0 1)
	SF-TOGGLE		"Merge Layers"			TRUE
	SF-TOGGLE		"Transparent"			TRUE
)
(script-fu-menu-register "210-scribbled-text" "<Image>/Script-Fu/Create New")
