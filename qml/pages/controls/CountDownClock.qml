/*
  Copyright (C) 2015 Amilcar Santos
  Contact: Amilcar Santos <amilcar.santos@gmail.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
	* Redistributions of source code must retain the above copyright
	  notice, this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright
	  notice, this list of conditions and the following disclaimer in the
	  documentation and/or other materials provided with the distribution.
	* Neither the name of the Amilcar Santos nor the
	  names of its contributors may be used to endorse or promote products
	  derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Canvas {
	id:canvas

	property int pos: 60
	property color warningColor: 'red'				// FIXME escolher 1vermelho do color picker
	property color highlightColor: Theme.highlightColor
	property color backgroundColor: Theme.rgba(Theme.secondaryColor, 0.2)
	property int lineWidth: Theme.iconSizeSmall

	signal countDownCompleted()

	onPaint: {
		var ctx = canvas.getContext("2d");
		ctx.clearRect(0,0,width, height)

		ctx.lineWidth = canvas.lineWidth;
		var circlePos = width / 2;
		var circleSize = width / 2 - lineWidth / 2;
		var arcPos = (60 - pos) * 0.1047 - 1.57;
		if (pos < 60) {
			ctx.beginPath();
			ctx.strokeStyle = canvas.backgroundColor;
			ctx.arc(circlePos, circlePos, circleSize,  -1.57, arcPos, false);
			ctx.stroke();
		}
		if (pos > 0) {
			ctx.beginPath();
			if (pos > 10) {
				ctx.strokeStyle = canvas.highlightColor;
			} else {
				if (pos == 10) {
					smoothColor.start()
				}
				ctx.strokeStyle = warning.color;
			}

			ctx.arc(circlePos, circlePos, circleSize, arcPos, 4.712, false);
			ctx.stroke();
		}
	}

	function start() {
		clock.start()
	}

	function stop() {
		clock.stop()
	}

	Rectangle {
		id: warning
		x:0
		y:0
		width: 0
		height: 0
	}

	ColorAnimation {
		running: false
		id: smoothColor
		from : highlightColor
		to: warningColor
		target: warning
		property: "color"
		duration: 6000
	}

	Timer {
		id: clock
		repeat: true
		interval: 1000
		onTriggered: {
//			console.log(pos);
			pos = pos - 1
			if (pos == 0) {
				running = false
				countDownCompleted()
			}
		}
	}
	onPosChanged: {
		canvas.requestPaint()
	}
}
