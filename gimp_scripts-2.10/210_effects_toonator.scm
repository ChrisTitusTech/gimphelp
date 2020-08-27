; 210_effects_toonator.scm
; last modified/tested by Paul Sherman [gimphelp.org]
; 01/08/2019 on GIMP 2.10.8
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
; based upon an original script by Saul Goode
; sg-tooninator.scm
; http://chiselapp.com/user/saulgoode/repository/script-fu/home
;==============================================================

(define (210-effects-tooninator image drawable)

  (unless (zero? (car (gimp-drawable-is-layer drawable)))
    (gimp-image-undo-group-start image)

    (let ((gray-mode? (= (car (gimp-image-base-type image)) 1))
          (retinex-layer 0)
          (edge-layer 0) )
	(if gray-mode?
	(gimp-image-convert-rgb image) )
		
	(if (= 1 (car (gimp-drawable-is-indexed drawable)))
		(gimp-image-convert-rgb image))
		
      (set! retinex-layer (car (gimp-layer-copy drawable TRUE)))
      (gimp-drawable-set-name retinex-layer "Retinex")
      (gimp-image-add-layer image retinex-layer -1)
      (plug-in-retinex RUN-NONINTERACTIVE image retinex-layer 16 3 0 0.1)
      (gimp-image-set-active-layer image retinex-layer)
      (gimp-layer-set-mode retinex-layer VALUE-MODE)
      (set! edge-layer (car (gimp-layer-copy drawable TRUE)))
      (gimp-drawable-set-name edge-layer "Edges")
      (gimp-image-add-layer image edge-layer -1)
      (let ((retinex-mask (car (gimp-layer-create-mask retinex-layer 0)))
            (buffer (car (gimp-edit-named-copy drawable "orig"))) )
        (gimp-layer-add-mask retinex-layer retinex-mask)
        (gimp-floating-sel-anchor (car (gimp-edit-named-paste retinex-mask buffer TRUE)))
        (gimp-threshold retinex-mask 36 255) )
      (let ((temp-layer (car (gimp-layer-copy retinex-layer TRUE))))
        (gimp-image-set-active-layer image edge-layer)
        (gimp-image-add-layer image temp-layer -1)
        (set! edge-layer (car (gimp-image-merge-down image temp-layer EXPAND-AS-NECESSARY))) )
      (plug-in-gauss RUN-NONINTERACTIVE image edge-layer 2.0 2.0 0)
      (plug-in-gauss RUN-NONINTERACTIVE image edge-layer 2.0 2.0 0)
	  (gimp-image-remove-layer image edge-layer)
	  
     (when (zero? (car (gimp-selection-is-empty image)))
        (gimp-selection-invert image)
;		(gimp-edit-clear edge-layer)
        (gimp-edit-clear retinex-layer)
        (gimp-selection-invert image) )
		)
    (gimp-image-undo-group-end image) 
	)
  (gimp-displays-flush)
  )
        
(script-fu-register "210-effects-tooninator"
  "Toon-inator"
  "Add two layers which result in a cartoon-like appearance, \nleft un-flattened to enable adjusting layers after script runs."
  "Paul Sherman"
  "Paul Sherman"
  "February, 2014"
  "*"
  SF-IMAGE    "Image"    0
  SF-DRAWABLE "Layer" 0
  )
(script-fu-menu-register "210-effects-tooninator" "<Image>/Script-Fu/Effects")
