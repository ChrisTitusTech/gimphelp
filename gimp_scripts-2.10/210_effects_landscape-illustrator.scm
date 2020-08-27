; 210_effects_landscape-illustrator.scm
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
; Original author: Mark Lowry
;
; Tags: photo, artistic
; Author statement:
; A GIMP script-fu to generate a painted look to a
; landscape photo.  Sometimes provides an interesting
; effect on portraits and animal shots.
;
; First, if desired it will over-sharpen the image.  This
; helps improve definition in the final product.  A value of 5
; is a good place to start.
;
; Next, it creates a top layer set to Darken Only mode and
; then blurs it.  Varying the blur radius will change
; the effect, as will applying a Levels or Curves adjustment
; to the Darken Only layer.  Just play with it and see
; what you get!
;
; Created on 5/31/2006 for v.2.2.8
;==============================================================


(define (210-Land_illust  
			img
			drawable
			blur-rad
			sharpen-flag
			merge-flag
			strength
			)

	(gimp-image-undo-group-start img)
	(if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img))
			 
   (let* (
         (darken-layer 0)
         (merged-layer 0)
         )

   ; SHARPEN FIRST, IF DESIRED
   (if (equal? sharpen-flag TRUE)
       (over_sharpen  img drawable strength)
       ()
   )

   ; CREATE THE DARKEN ONLY LAYER
   (set! darken-layer (car (gimp-layer-copy drawable 0)))

   ; Give it a name
   (gimp-item-set-name darken-layer "Darken Only layer")

   ; Add the new layer to the image
   (gimp-image-insert-layer img darken-layer 0 0)

   ; Set opacity to 100%
   (gimp-layer-set-opacity darken-layer 100)
   (gimp-layer-set-mode darken-layer DARKEN-ONLY-MODE )

   ; Blur the layer
   (if (> blur-rad 0)
       (plug-in-gauss-iir 1 img darken-layer blur-rad 1 1 )
       ()
   )

   ; NOW MERGE EVERYTHING DOWN IF DESIRED
   (if (equal? merge-flag TRUE)
       (set! merged-layer (car(gimp-image-merge-down img darken-layer 1 )))
       ()
   )

   (if (equal? merge-flag TRUE)
       (gimp-item-set-name merged-layer "Result of Landscape Illustrator")
       ()
   )

   ; Complete the undo group
   (gimp-image-undo-group-end img)

   ; Flush the display
   (gimp-displays-flush)
   )
)

(define (over_sharpen img drawable strength )

   (let* (
         (matrix 0)
         (divisor 0)
         )

   (set! strength (- 11 (/ strength 5) ) 'double )

     (let* (   (matrix-list '(    0     -.2     -.2     -.2     0
                          -.2   -.5     -1      -.5    -.2
                          -.2   -1     10  -1   -.2
                          -.2   -.5     -1      -.5    -.2
                           0     -.2     -.2     -.2     0  ))
             (channels (make-vector 5 'long ))
           )

     (set! matrix (get-matrix matrix-list))

     (vector-set! channels 0 0 )
     (vector-set! channels 1 1 )
     (vector-set! channels 2 1 )
     (vector-set! channels 3 1 )
     (vector-set! channels 4 0 )

     (vector-set! matrix 12 strength)
     (set! divisor (- strength 8.4))
     (plug-in-convmatrix 1 img drawable 25 matrix 0 1.5999 0 5 channels 0 )


     ; Flush the display
     (gimp-displays-flush)

     )
   )

)

; Convert maxtrix list (25) into matrix array (5x5)
(define (get-matrix matrix-list)
  (let* (
        (n 0)
        )
  (set! n 25 )
  (define (list-ref l n) (nth n l))
    (let* ((count 0)
           (matrix (cons-array 25 'double)))
      (while (< count 25 )
      (aset matrix count (list-ref matrix-list count))
      (set! count (+ count 1)))
      matrix ; Return the matrix array
    )
  )
)


(script-fu-register "210-Land_illust"
      "Landscape Illustrator"
      "Similar to Landscape Painter, but with a bit of a sketch effect as well.  Over-sharpen, then add Darken Only layer and blur it"
      "Mark Lowry"
      "Technique by Mark Lowry"
      "2006"
      "*"
      SF-IMAGE "Image" 0
      SF-DRAWABLE "Current Layer" 0
      SF-VALUE "Blur radius?"   "15"
      SF-TOGGLE "Sharpen First?" TRUE
	  SF-TOGGLE "Merge Layers?"  TRUE
      SF-ADJUSTMENT "Sharpening strength?"  '(5 0 10 1 10 0 0)
 )
(script-fu-menu-register "210-Land_illust" "<Image>/Script-Fu/Effects")
