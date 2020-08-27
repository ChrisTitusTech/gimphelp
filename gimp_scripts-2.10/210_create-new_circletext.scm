; 210_create-new_circletext.scm
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
;; text-circle.scm -- a script for The GIMP 1.1
;; Author: Shuji Narazaki <narazaki@gimp.org>
;; Time-stamp: <1998/11/25 13:26:51 narazaki@gimp.org>
;; Version 2.5
;; Thanks:
;;   jseymour@jimsun.LinxNet.com (Jim Seymour)
;;   Sven Neumann <neumanns@uni-duesseldorf.de>

;; Note:
;;  Please remove /usr/local/share/gimp/scripts/circle-logo.scm, which is
;;  obsolete version of this script.

;; Implementation memo:
;; This script uses "extra-pole".
;; Namely, when rendering a letter, gimp-text is invoked with the letter
;; followed by " lAgy", then strips it by gimp-layer-resize. I call this " lAgy"
;; extra-pole. Why is it needed?
;; Since a text is located by its left-upper corner's position, THERE IS NO WAY
;; TO PLACE LETTERS ON A BASE LINE!
;; (FURTHERMORE, GIMP-TEXT EATS WHITESPACES AT THE BEGINNING/END OF LINE.)
;; Thus, as a dirty trick, by adding tall letters: "lA", and "gy" which have
;; large descent value to each letter temporally, most letters in most fonts
;; are aligned correctly. But don't expect completeness :-<
;==============================================================


(define (210-circletext text radius start-angle fill-angle
			       font-size antialias make-arc TRANS font-name)
				   
	(define extra-pole TRUE)		; for debugging purpose
	(define modulo fmod)			; in R4RS way
	(define (wrap-string str) (string-append "\"" str "\"")) 
	(define (white-space-string? str)
	(or (equal? " " str) (equal? "	" str)))

	; make transparent is checked
	(define lay-opacity 100)
	(if (= TRANS 1)(set! lay-opacity 0))
	 
  (let* ((drawable-size (* 2.0 (+ radius (* 2 font-size))))
	 (img (car (gimp-image-new drawable-size drawable-size RGB)))

	 
	 (BG-layer (car (gimp-layer-new img drawable-size drawable-size 1 "background" lay-opacity LAYER-MODE-NORMAL-LEGACY)))
	 (merged-layer #f)
	 (char-num (string-length text))
	 
	 (radian-step 0)
	 (start-angle-rad 0)
	 (fill-angle-rad 0)
	 
	 (rad-90 (/ *pi* 2))
	 (center-x (/ drawable-size 2))
	 (center-y center-x)
	 ;; widths of " lAgy" and of "l Agy" will be different, because gimp-text
	 ;; strips spaces at the beginning of a string![Mon Apr 27 15:10:39 1998]
	 (fixed-pole0 "l Agy")
	 ;; the following used as real pad.
	 (fixed-pole " lAgy")
	 (font-infos (gimp-text-get-extents-fontname fixed-pole font-size
						     PIXELS font-name))
	 (desc (nth 3 font-infos))
	 (extra 0)			; extra is calculated from real layer
	 (angle-list #f)
	 (letter "")
	 (new-layer #f)
	 (index 0))
	 
	;; this stuff here to make an arc (instead of circle) 
	(if (= make-arc 1)(begin
	(set! start-angle -90)
	(set! fill-angle 180)
	))	 
	
    (gimp-image-undo-disable img)
    (gimp-image-add-layer img BG-layer 0)
    (gimp-edit-fill BG-layer FILL-BACKGROUND)
    ;; change units
    (set! start-angle-rad (* (/ (modulo start-angle 360) 360) 2 *pi*))
    (set! fill-angle-rad (* (/ fill-angle 360) 2 *pi*))
    (set! radian-step (/ fill-angle-rad char-num))
    ;; set extra
    (if (eq? extra-pole TRUE)
	(let ((temp-pole-layer (car (gimp-text-fontname img -1 0 0
					       fixed-pole0
					       1 antialias
					       font-size PIXELS
					       font-name))))
	  (set! extra (car (gimp-drawable-width temp-pole-layer)))
	  (gimp-image-remove-layer img temp-pole-layer))
	(set! extra 0))
    ;; make width-list
    ;;  In a situation,
    ;; (car (gimp-drawable-width (car (gimp-text ...)))
    ;; != (car (gimp-text-get_extent ...))
    ;; Thus, I changed to gimp-text from gimp-text-get-extent at 2.2 !!
    (let ((temp-list '())
	  (temp-str #f)
	  (temp-layer #f)
	  (scale 0)
	  (temp #f))
      (set! index 0)
      (while (< index char-num)
	(set! temp-str (substring text index (+ index 1)))
	(if (white-space-string? temp-str)
	    (set! temp-str "x"))
	(set! temp-layer (car (gimp-text-fontname img -1 0 0
						  temp-str
						  1 antialias
						  font-size PIXELS
						  font-name)))
	(set! temp-list (cons (car (gimp-drawable-width temp-layer)) temp-list))
	(gimp-image-remove-layer img temp-layer)
	(set! index (+ index 1)))
      (set! angle-list (nreverse temp-list))
      (set! temp 0)
      (set! angle-list
	    (mapcar (lambda (angle)
		      (let ((tmp temp))
			(set! temp (+ angle temp))
			(+ tmp (/ angle 2))))
		    angle-list))
      (set! scale (/ fill-angle-rad temp))
      (set! angle-list (mapcar (lambda (angle) (* scale angle)) angle-list)))
    (set! index 0)
    (while (< index char-num)
      (set! letter (substring text index (+ index 1)))
      (if (not (white-space-string? letter))
	  ;; Running gimp-text with " " causes an error!
	  (let* ((new-layer
		  (car (gimp-text-fontname img -1 0 0
					   (if (eq? extra-pole TRUE)
					       (string-append letter fixed-pole)
					       letter)
					   1 antialias
					   font-size PIXELS
					   font-name)))
		 (width (car (gimp-drawable-width new-layer)))
		 (height (car (gimp-drawable-height new-layer)))
		 (rotate-radius (- (/ height 2) desc))
		 (new-width (- width extra))
		 (angle (+ start-angle-rad (- (nth index angle-list) rad-90))))
	    ;; delete fixed-pole
	    (gimp-layer-resize new-layer new-width height 0 0)
	    (set! width (car (gimp-drawable-width new-layer)))
		
		

	  (gimp-layer-translate new-layer
				(+ center-x
				   (* radius (cos angle))
				   (* rotate-radius
					  (cos (if (< 0 fill-angle-rad)
						   angle
						   (+ angle *pi*))))
				   (- (/ width 2)))
				(+ center-y
				   (* radius (sin angle))
				   (* rotate-radius
					  (sin (if (< 0 fill-angle-rad)
						   angle
						   (+ angle *pi*))))
				   (- (/ height 2))))
	  (gimp-rotate new-layer 1
			   ((if (< 0 fill-angle-rad) + -) angle rad-90))))
				   
				   
      (set! index (+ index 1)))
	  
    (gimp-layer-set-visible BG-layer 0)
	
	(wrap-string text)	
	(set! merged-layer
	(car (gimp-image-merge-visible-layers img CLIP-TO-IMAGE)))
	(gimp-drawable-set-name merged-layer "Text Circle")

    (gimp-layer-set-visible BG-layer 1)
    (gimp-image-undo-enable img)
    (gimp-image-clean-all img)
    (gimp-display-new img)
    (gimp-displays-flush)))

(script-fu-register
 "210-circletext"
 "Text Circle"
 "Render the specified text along the perimeter of a circle"
 "Shuji Narazaki <narazaki@gimp.org>"
 "Shuji Narazaki"
 "1997-1998"
 ""
 SF-STRING     _"Text" "GNU Image Manipulation Program"
 SF-ADJUSTMENT _"Radius" '(80 1 8000 1 1 0 1)
 SF-ADJUSTMENT _"Start Angle" '(0 -180 180 1 1 0 1)
 SF-ADJUSTMENT _"Fill Angle" '(360 -360 360 1 1 0 1)
 SF-ADJUSTMENT _"Font Size (pixels)" '(18 1 1000 1 1 0 1)
 SF-TOGGLE     _"Antialias" TRUE
 SF-TOGGLE     _"Create Arc (not a full circle.  = Start-Angle -90, Fill Angle 180)" FALSE
 SF-TOGGLE     _"Transparent - easier to paste into another image" TRUE
 SF-FONT       _"Font" "-adobe-helvetica-bold-r-normal-*-30-*-*-*-p-*-*-*"
)
(script-fu-menu-register "210-circletext" "<Image>/Script-Fu/Create New")
