; 210_effects-selection_highlight-from-selection.scm
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
;highlight-from-selection.scm
; by Dirk Sohler
; https://0x7be.de

; Version 1.0 (2013-01-21)

; Description
;
; This script adds a filter for highlighting the contents of a selection by
; adding blur and desaturation (both optional) to the other contents.
;==============================================================


(define (
	 210-highlight-from-selection
	 inImage
	 inLayer
	 inRadius
	 inBlur
	 inOpacity
	 inDesaturate
	 inFlatten)


(if (= (car (gimp-selection-is-empty inImage)) TRUE)
(begin
  (message-box "The current image doesn't have a selection.\n\nThis plugin works on a \nSELECTED AREA of the image.\n\nSelect an area and try again :-)"))
(begin

  (gimp-image-undo-group-start inImage)

  (if (not (= RGB (car (gimp-image-base-type inImage))))
		    	 (gimp-image-convert-rgb inImage))
				 
  (let

    (
     (colorLayer (car (gimp-layer-copy inLayer TRUE)))
     (grayLayer (car (gimp-layer-copy inLayer TRUE)))
     (layername (car (gimp-drawable-get-name inLayer)))
     )

    (gimp-image-add-layer inImage colorLayer -1)
    (gimp-image-add-layer inImage grayLayer -1)
    (gimp-layer-set-name colorLayer (string-append layername _" highlight layer"))

    (gimp-selection-feather inImage inRadius)
    (gimp-edit-clear colorLayer)
    (gimp-edit-clear grayLayer)
    (gimp-selection-none inImage)

    (gimp-layer-set-opacity grayLayer inOpacity)

    (if (= inDesaturate TRUE)
      (gimp-desaturate grayLayer)
      )

    (if (> inBlur 0)
      (plug-in-gauss 1 inImage (car (gimp-image-merge-down inImage grayLayer 2)) inBlur inBlur 0)
	)

    (if (= inBlur 0)
      (car (gimp-image-merge-down inImage grayLayer 2))
      )

  )
	
  (if (= inFlatten TRUE)(gimp-image-flatten inImage))
  (gimp-image-undo-group-end inImage)
  (gimp-displays-flush)
  )
))

(script-fu-register
  "210-highlight-from-selection"
  "Highlight from selection"
  "Highlights the selection by adding blur and desaturation to other contents."
  "Dirk Sohler <spam@0x7be.de>"
  "Dirk Sohler"
  "2013-01-21"
  "*"
  SF-IMAGE		"Image"									0
  SF-DRAWABLE	"Drawable"								0
  SF-ADJUSTMENT	"Highlight Radius"						'(100 0 500 1 10 0 0)
  SF-ADJUSTMENT	"Blur strenght"							'(3 0 10 1 10 0 0)
  SF-ADJUSTMENT	"Opacity of desaturation"				'(50 0 100 1 10 0 0)
  SF-TOGGLE	    "Desaturate the not highlighted parts"	TRUE
  SF-TOGGLE     "Flatten image" 						TRUE
  )
(script-fu-menu-register "210-highlight-from-selection" "<Image>/Script-Fu/Effects Selection")

