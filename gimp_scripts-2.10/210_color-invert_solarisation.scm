; 210_color-invert_solarisation.scm
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
; Solarization script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii@hotmail.com>
; 
; version 0.1  by Iccii 2001/12/08
;     - Initial relase
; version 0.1a by Iccii 2001/12/09
;     - Added Threshold adjuster
;==============================================================


(define (210-solarisation
			img
			drawable
			threshold
			target-channel
			invert?
			value-change?
	)

	(gimp-image-undo-group-start img)
	(if (not (= RGB (car (gimp-image-base-type img))))
			 (gimp-image-convert-rgb img))
			 
  (define (apply-solarization channel)
    (let* ((point-num 256)
           (control_pts (cons-array point-num 'byte))
           (start-value (if (< threshold 128) (- 255 (* threshold 2)) 0))
           (end-value   (if (< threshold 128) 0 (* (- threshold 128) 2)))
           (grad (if (< threshold 128)
                     (/ (- 127 start-value) 127)
                     (/ (- end-value 127)   127)))
           (count 0))
      (while (< count point-num)
        (let* ((value1 (if (< threshold 128)
                           (if (< count 128)
                               (+ start-value (* grad count))
                               (- 255 count))
                           (if (< count 128)
                               count
                               (+ 127 (* grad (- count 128))))))
               (value2 (if (equal? value-change? TRUE) (+ value1 127) value1))
               (value  (if (equal? invert? TRUE) (- 255 value2) value2)))
          (aset control_pts count value)
          (set! count (+ count 1))))
      (gimp-curves-explicit drawable channel point-num control_pts)))


  (let* (
         (image-type (car (gimp-image-base-type img)))
         (has-alpha? (car (gimp-drawable-has-alpha drawable)))
        ) ; end variable definition

    (if (or (= target-channel 0) (equal? image-type GRAY))
        (apply-solarization HISTOGRAM-VALUE)
        (cond ((= target-channel 1)
                (apply-solarization HISTOGRAM-RED))
              ((= target-channel 2)
                (apply-solarization HISTOGRAM-GREEN))
              ((= target-channel 3)
                (apply-solarization HISTOGRAM-BLUE ))
              ((= target-channel 4)
                (if (equal? has-alpha? TRUE)
                    (apply-solarization HISTOGRAM-ALPHA)
                    (gimp-message "Drawable doesn't have an alpha channel! Abort."))) ))

    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
))

(script-fu-register
	"210-solarisation"
	"Solarisation"
	"Apply solarization effect, basically a tone reversal. This version has several parameters that can be tweaked."
	"Iccii <iccii@hotmail.com>"
	"Iccii"
	"2001, Dec"
	"*"
	SF-IMAGE      "Image"          0
	SF-DRAWABLE   "Drawable"       0
	SF-ADJUSTMENT "Threshold"      '(127 0 255 1 1 0 0)
	SF-OPTION     "Target Channel" '("RGB (Value)" "Red" "Green" "Blue" "Alpha")
	SF-TOGGLE     "Invert"         FALSE
	SF-TOGGLE     "Value Change"   FALSE
)
(script-fu-menu-register "210-solarisation" "<Image>/Script-Fu/Color/Invert")
