; 210_effects_chrome-image.scm
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
; Chrome image script  for GIMP 1.2
; Copyright (C) 2001-2002 Iccii <iccii@hotmail.com>
;==============================================================


(define (210-chrome-image
			img		
			drawable			
			contrast
			deform
			random
			emboss?
	)

	(gimp-image-undo-group-start img)
	(if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img))
			 
  (let* (
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
	 (old-fg (car (gimp-context-get-foreground)))
	 (image-type (if (eqv? (car (gimp-drawable-is-gray drawable)) TRUE)
                         GRAYA-IMAGE
                         RGBA-IMAGE))
	 (point-num (+ 2 (* random 2)))
	 (step (/ 255 (+ (* random 2) 1)))
	 (control_pts (cons-array (* point-num 2) 'byte))
         (count 0)
        )

    (if (eqv? (car (gimp-drawable-is-gray drawable)) FALSE)
        (gimp-desaturate drawable))
    (plug-in-gauss-iir2 1 img drawable deform deform)
    (if (eqv? emboss? TRUE)
        (plug-in-emboss 1 img drawable 30 45.0 20 1))

    (while (< count random)
      (aset control_pts (+ (* count 4) 2) (* step (+ (* count 2) 1)))
      (aset control_pts (+ (* count 4) 3) (+ 128 contrast))
      (aset control_pts (+ (* count 4) 4) (* step (+ (* count 2) 2)))
      (aset control_pts (+ (* count 4) 5) (- 128 contrast))
      (set! count (+ count 1)))
    (aset control_pts 0 0)
    (aset control_pts 1 0)
    (aset control_pts (- (* point-num 2) 2) 255)
    (aset control_pts (- (* point-num 2) 1) 255)
    (gimp-curves-spline drawable 0 (* point-num 2) control_pts)


    (gimp-context-set-foreground old-fg)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)

(script-fu-register
	"210-chrome-image"
	"Chrome Image"
	"Create chrome image.  Usefull when you want to create metallic surfaces"
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"2002, Feb"
	"*"
	SF-IMAGE      "Image"		0
	SF-DRAWABLE   "Drawable"	0
	SF-ADJUSTMENT "Contrast"      '(20 0 127 1 1 0 0)
	SF-ADJUSTMENT "Deformation"   '(3 1 50 1 10 0 0)
	SF-ADJUSTMENT "Ramdomeness"   '(4 1 7 1 10 0 1)
	SF-TOGGLE     "Enable Emboss" FALSE
)
(script-fu-menu-register "210-chrome-image" "<Image>/Script-Fu/Effects")
