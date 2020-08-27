; 210_crerate-new_text-balloon.scm
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
; creates a balloon like in comics
; it sucks a bit ;-)
; (C) Copyright 2000 by Michael Spunt <t0mcat@gmx.de>

;; Version de abcdugimp.free.fr
;==============================================================


(define (round-balloon 
		img 
		drawable 
		bw 
		bh 
		np 
		orientation 
		revert 
		lw
	)
	
	(let* ((x 0))
	(if (= np FALSE) 
		(begin
			(set! x (- (* bw 0.5) (* bw 0.2)))
			(gimp-image-select-ellipse img CHANNEL-OP-REPLACE x (* bh 0.5) (* bw 0.4) (* bh 0.4))
			(set! x (- (* bw 0.5) (* bw 0.2) (* bw orientation -0.1)))
			(gimp-image-select-ellipse img CHANNEL-OP-SUBTRACT x (* bh 0.5) (* bw 0.4) (* bh 0.4))
		)
	)
	(if (= revert FALSE) (gimp-selection-translate img (* bw orientation 0.3) 0))
	(gimp-image-select-ellipse img CHANNEL-OP-ADD (* bw 0.1) (* bh 0.1) (* bw 0.8) (* bh 0.65))
	(gimp-edit-fill drawable 0)
	(gimp-selection-shrink img lw)
	(gimp-edit-fill drawable 1))
)

(define (round-think-balloon 
		img drawable 
		bw 
		bh 
		np 
		orientation 
		revert 
		lw
	)
	
	(let* ((x 0))
	(if (= np FALSE) 
		(begin
			(set! x (+ (* bw 0.5) (* bw -0.025) (* bw orientation 0.3)))
			(gimp-image-select-ellipse img CHANNEL-OP-REPLACE x (* bh 0.85) (* bw 0.05) (* bh 0.05))
			(set! x (+ (* bw 0.5) (* bw -0.05) (* bw orientation 0.2)))
			(gimp-image-select-ellipse img CHANNEL-OP-ADD x (* bh 0.75) (* bw 0.1) (* bh 0.1))
		)
	)
	(if (= revert TRUE) (gimp-selection-translate img (* orientation bw -0.3) 0))
	(gimp-image-select-ellipse img CHANNEL-OP-ADD (* bw 0.1) (* bh 0.1) (* bw 0.8) (* bh 0.65))
	(gimp-edit-fill drawable 0)
	(gimp-selection-shrink img lw)
	(gimp-edit-fill drawable 1))
)

(define (210-balloon 
		bw 
		bh 
		np 
		think 
		right 
		revert 
		lw
		color
		flatten
	)

	(define old-bg   (car (gimp-context-get-background)))
	(define old-fg   (car (gimp-context-get-foreground)))
		
	(let* (
		(orientation 1)
		(side 1)
		(img (car (gimp-image-new bw bh RGB)))
		(balloon (car (gimp-layer-new img bw bh RGBA-IMAGE "Balloon" 100 LAYER-MODE-NORMAL-LEGACY))))
		(if (= right FALSE) (set! orientation -1))
		(gimp-image-insert-layer img balloon 0 1)
		(gimp-display-new img)
		(gimp-edit-clear balloon)

		(gimp-context-set-background '(255 255 255))
		(gimp-context-set-foreground color)
		
		(if (= think FALSE) (round-balloon img balloon bw bh np orientation revert lw))
		(if (= think TRUE) (round-think-balloon img balloon bw bh np orientation revert lw))
		(if (= flatten TRUE)
			(gimp-image-flatten img)
		)		
		(gimp-selection-none img)
		(gimp-context-set-foreground old-fg)
		(gimp-context-set-background old-bg)
		(gimp-displays-flush)
	)
)

(script-fu-register "210-balloon"
  "Text Balloon"
  "Creates a balloon like used in comics. Version de abcdugimp.free.fr"
  "Michael Spunt"
  "Copyright 2000, Michael Spunt"
  "May 20, 2000"
  ""
  SF-VALUE 	"Width"							"240"
  SF-VALUE 	"Height"						"160"
  SF-TOGGLE "No pointer"					FALSE
  SF-TOGGLE "Think"							FALSE
  SF-TOGGLE "Right oriented"				FALSE
  SF-TOGGLE "Change side"					FALSE
  SF-VALUE 	"Line width"					"2"
  SF-COLOR  "Outline Color"     			'(0 0 0)
  SF-TOGGLE "Flatten image when completed?"	FALSE
)
(script-fu-menu-register "210-balloon" "<Image>/Script-Fu/Create New")
