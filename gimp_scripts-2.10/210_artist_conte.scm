; 210_artist_conte.scm
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
; ALSO NEED TO COPY:
; ev_strokes45r.txt
; graphite2.txt
;
;	Windows 7/10
;	C:\Program Files\GIMP 2\share\gimp\2.0\gimpressionist\presets
;	or
;	C:\Users\YOUR-NAME\AppData\Roaming\GIMP\2.10\gimpressionist\presets
;	
;    
;	Linux
;	/home/yourname/.config/GIMP/2.10/gimpressionist\presets  
;	or
;	Linux system-wide
;	/usr/share/gimp/2.0/gimpressionist\presets
;==========================================================
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
; Conte image script  for GIMP 2.2
; Copyright (C) 2007 Eddy Verlinden <eddy_verlinden@hotmail.com>
;==============================================================

(define (210-conte
		img
		drawable
		brightness
		contrast
		wild?
		canvas?
		inMerge
	)

    (gimp-image-undo-group-start img)
    (if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img))
  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-selection (car (gimp-selection-save img)))
	 (image-type (car (gimp-image-base-type img)))
	 (layer-type (car (gimp-drawable-type drawable)))
	 (layer-tempa (car (gimp-layer-new img width height layer-type "tempa"  100 LAYER-MODE-NORMAL-LEGACY)))
	 (layer-tempb (car (gimp-layer-new img width height layer-type "tempb"  100 LAYER-MODE-NORMAL-LEGACY)))
	 (layer-tempc (car (gimp-layer-new img width height layer-type "tempc"  100 LAYER-MODE-NORMAL-LEGACY)))
	 (layer-tempd (car (gimp-layer-new img width height layer-type "tempd"  100 LAYER-MODE-NORMAL-LEGACY)))
	 (layer-tempe (car (gimp-layer-new img width height layer-type "tempe"  100 LAYER-MODE-NORMAL-LEGACY)))
	 (img2 (car (gimp-image-new width height image-type)))
	 (layer-temp2 (car (gimp-layer-new img2 width height layer-type "temp2" 100 LAYER-MODE-NORMAL-LEGACY)))
        ) 

    (if (eqv? (car (gimp-selection-is-empty img)) TRUE)
        (gimp-drawable-fill old-selection 2)) ; so Empty and All are the same.
    (gimp-selection-none img)
;-------------------------------------------------------
    (if (eqv? (car (gimp-palettes-get-list "conte_ev8")) 0)
    (begin
    (gimp-palette-new "conte_ev8")
    (gimp-palette-add-entry "conte_ev8" "1" '(117 96 91))
    (gimp-palette-add-entry "conte_ev8" "2" '(139 91 87))
    (gimp-palette-add-entry "conte_ev8" "3" '(164 91 85))
    (gimp-palette-add-entry "conte_ev8" "4" '(185 103 89))
    (gimp-palette-add-entry "conte_ev8" "5" '(240 238 239))
    (gimp-palette-add-entry "conte_ev8" "6" '(205 212 220))
    (gimp-palette-add-entry "conte_ev8" "7" '(90 93 100))
    (gimp-palette-add-entry "conte_ev8" "8" '(51 51 51))
    ))
    (if (> (car (gimp-palettes-get-list "conte_ev8 ")) 0)
        (gimp-message "There is/are palette(s) 'conte_ev8 *'. The best is to delete all palettes 'conte_ev8' (in the dialog 'palettes'). A new original will be created the next time this script is activated"))
    (if (> (car (gimp-palettes-get-list "conte_ev8#")) 0)
        (gimp-message "There is/are palette(s) 'conte_ev8#'. The best is to delete all palettes 'conte_ev8' (in the dialog 'palettes'). A new original will be created the next time this script is activated"))
;-------------------------------------------------------
    (gimp-drawable-fill layer-tempa 3)
    (gimp-image-insert-layer img layer-tempa 0 -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempa 0)))
    (gimp-drawable-fill layer-tempb 3)
    (gimp-image-insert-layer img layer-tempb 0 -1)
    (gimp-edit-copy drawable)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempb 0)))

    (plug-in-neon 1 img layer-tempa 5.0 0)
    (gimp-invert layer-tempa)
    (gimp-desaturate layer-tempa)

    (gimp-brightness-contrast layer-tempb (* brightness 1.25) (* contrast 1.25))
    (plug-in-gauss 1 img layer-tempb 2.0 2.0 0)
    (gimp-image-insert-layer img layer-tempc 0 -1)
    (gimp-edit-copy layer-tempb)

    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempc 0)))
    (plug-in-gimpressionist 1 img layer-tempc "ev_strokes45r.txt")
    (plug-in-dog 1 img layer-tempc 7.0 2.0 TRUE TRUE)
    (gimp-threshold layer-tempc 250 255)

    (gimp-layer-set-mode layer-tempc 3)
    (gimp-layer-set-mode layer-tempb 3)
    (gimp-image-merge-down img layer-tempc 0)
    (set! layer-tempb (car (gimp-image-get-active-layer img)))
    (gimp-image-merge-down img layer-tempb 0)
    (set! layer-tempa (car (gimp-image-get-active-layer img)))
    (gimp-edit-copy layer-tempa)

;    (set! img2 (car (gimp-image-new width height image-type)))
;    (set! layer-temp2 (car (gimp-layer-new img2 width height layer-type "temp2"  100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer img2 layer-temp2 0 -1)
    (gimp-drawable-fill layer-temp2 3)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-temp2 0)))
    (gimp-image-convert-indexed img2 0 4 0 0 0 "conte_ev8")
    (gimp-edit-copy layer-temp2)
    (gimp-image-delete img2)

    (gimp-layer-add-alpha layer-tempa)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempa 0)))
    (gimp-image-insert-layer img layer-tempd 0 -1)
    (gimp-edit-copy layer-tempa)
    (gimp-floating-sel-anchor (car (gimp-edit-paste layer-tempd 0)))
    (if (eqv? wild? TRUE)
        (begin
    (plug-in-gimpressionist 1 img layer-tempd "graphite2.txt")
      ))
    (gimp-layer-set-mode layer-tempd 19)
    (gimp-image-merge-down img layer-tempd 0)
    (set! layer-tempa (car (gimp-image-get-active-layer img)))

    (if (eqv? canvas? TRUE)
        (begin
    (gimp-image-insert-layer img layer-tempe 0 -1)
    (gimp-context-set-foreground '(234 220 190))
    (gimp-drawable-fill layer-tempe 0)
    (plug-in-apply-canvas 1 img layer-tempe 1 1)
    (gimp-layer-set-mode layer-tempa 9)
    (gimp-image-lower-item img layer-tempe)
    (gimp-image-merge-down img layer-tempa 0)
    (set! layer-tempa (car (gimp-image-get-active-layer img)))
       ))

;-------------------------------------------------------
    (gimp-image-select-item img CHANNEL-OP-REPLACE old-selection)
    (gimp-selection-invert img)
    (if (eqv? (car (gimp-selection-is-empty img)) FALSE) ; both Empty and All are denied
        (begin
        (gimp-edit-clear layer-tempa)
        ))

    (gimp-item-set-name layer-tempa "Conte")
    (gimp-image-select-item img CHANNEL-OP-REPLACE old-selection)
    (gimp-image-remove-channel img old-selection)

	(if (= inMerge TRUE)(gimp-image-merge-visible-layers img EXPAND-AS-NECESSARY))
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
  "210-conte"
  "Conte - charcoal crayon"
  "Creates an image that looks like a conte sketch."
  "Eddy Verlinden <eddy_verlinden@hotmail.com>"
  "Eddy Verlinden"
  "2007, juli"
  "*"
  SF-IMAGE      "Image"							0
  SF-DRAWABLE   "Drawable"         				0
  SF-ADJUSTMENT "Brightness"        			'(50 -100 100 1 10 0 0)
  SF-ADJUSTMENT "Contrast"          			'(80 -100 100 1 10 0 0)
  SF-TOGGLE     "Wild" 							TRUE
  SF-TOGGLE     "Canvas" 						TRUE
  SF-TOGGLE     "Merge layers when complete?" 	FALSE
)
(script-fu-menu-register "210-conte" "<Image>/Script-Fu/Artist")