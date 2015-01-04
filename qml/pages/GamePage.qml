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
import QtSensors 5.0
import "controls"
import "utils/Persistence.js" as Persistence

Page {
	id: gamePage

	allowedOrientations: Orientation.Landscape

//	property variant wordsModel

//	TODO property variant gameRules

	property int categoryId

	property int maxWords: 6

	property string _currentText: ''

	function saveResult(gessed) {
		if (state == 'in_game') {
			scoreModel.append({
				text: _currentText,
				gessed: gessed,
				score: 'game'
			});
		}
		if (countdown.pos > 0) {
			if (gessed) {
				successPopup.showMessage();
				skipPopup.visible = false;
			} else {
				successPopup.visible = false;
				skipPopup.showMessage();
			}
			if (scoreModel.count < maxWords) {
				state = 'game_score'
			} else {
				countdown.stop();
				state = 'game_over'
			}
		} else {
//			gameText.text = ""
			state = 'game_over'
//			gameOverTimer.start();
		}
	}

	function nextText() {
//		console.log(wordsModel)
		if (state != 'get_ready' && state != 'game_score') {
//			console.log("skip next text request: " + state)
			return;
		}

		var rndOffset = Math.floor(Math.random() * wordsModel.count);
		var text = wordsModel.get(rndOffset).text;
		text = text.replace("\\n", "\n");
		Persistence.updateGameWordUsage(wordsModel.get(rndOffset).id)
		wordsModel.remove(rndOffset);
//		console.log(gamePage._currentText & " - rnd:" & rndOffset);
		gameText.text = text;
		gamePage._currentText = text;
		state = 'in_game'
	}

	MessagePopup {
		id: successPopup
		visible: false
		text: "Correct"
		color: "green"
	}

	MessagePopup {
		id: skipPopup
		visible: false
		text: "Skip"
		color: "orange"
	}


	SilicaFlickable {
		anchors.fill: parent

		PullDownMenu {
			id: pullMenu
			visible: pullMenuVisible()
			function pullMenuVisible() {
				if (gamePage.state == 'game_over_score' && gamePage.status !== PageStatus.Deactivating) {
					return true;
				}
				if (gamePage.state == 'get_ready' && pullMenu.active) {
					return true;
				}
				return false;
			}
			MenuItem {
				text: qsTr("Restart")
				onClicked: {
					gamePage.state = 'get_ready';
				}
			}
		}

		CountDownClock {
			id: countdown
			anchors.centerIn: parent
			width: gamePage.height - Theme.itemSizeSmall
			height: gamePage.height - Theme.itemSizeSmall

			onCountDownCompleted: {
				saveResult(false)
				gameText.text = ''
			}
		}

		FlippingText {
			id: readyCountdownText
			font.pixelSize: Theme.fontSizeLarge * 10
			font.bold: true
			anchors.centerIn: parent
			color: 'white'
		}

		FlippingText {
			id: gameText
			visible: false
			font.bold: true
//			anchors.centerIn: parent
			anchors.fill: parent
			color: 'white'
			opacity: 0.8

			onFlipping: {
				hiddenText.text = text;
				font.pixelSize = hiddenText.calcFontSize(Theme.fontSizeLarge * 10)
			}
		}
	}

	Text {
		id: hiddenText
		visible: false
		font.bold: true

		function calcFontSize(startSize) {
			var h = gamePage.height - Theme.paddingLarge * 2
			var w = gamePage.width - Theme.paddingLarge * 2
			var size2 = startSize
			var testHW = (h + w) * 1.2

			hiddenText.font.pixelSize = size2
			hiddenText.width = w
//					console.log("pw2: " + hiddenText.paintedWidth + ", ph2:" + hiddenText.paintedHeight)
			while (hiddenText.paintedWidth >= w || hiddenText.paintedHeight >= h) {
				size2 = size2  - (hiddenText.paintedHeight + hiddenText.paintedWidth > testHW ? 40 : 8)
				hiddenText.font.pixelSize = size2
				if (size2 < 16) {
					break
				}
//						console.log("pixelSize: " + size2 + " painted W: " + hiddenText.paintedWidth + ", H: " + hiddenText.paintedHeight + "; w+h: " + (hiddenText.paintedHeight+hiddenText.paintedWidth))
			}
			return size2
		}
	}

	Timer {
		property int count: 3
		id: readyCountdown
		repeat: true
		interval: 1000
		onRunningChanged: {
			if (running) {
				readyCountdown.count = 3
//				readyCountdownText.visible = true
				readyCountdownText.animate = false
				readyCountdownText.text = readyCountdown.count

				scoreModel.clear();
				wordsModel.clear();
				Persistence.populateGameWords(wordsModel, categoryId, 30);

			} else {
//				readyCountdownText.visible = false
				readyCountdownText.text = ""
				gameText.visible = true
				nextText()
				countdown.start()
			}
		}

		onTriggered: {
			if (count > 1) {
				readyCountdown.count = readyCountdown.count - 1
				readyCountdownText.animate = true
				readyCountdownText.text = readyCountdown.count
			} else {
				stop()
			}
		}
	}

	ListModel {
		id:wordsModel
	}

	ListModel {
		id: scoreModel
	}

	states: [
		State {
			name: 'get_ready'
			PropertyChanges {
				target: countdown
				restoreEntryValues: false
				pos: 60
			}
			PropertyChanges {
				target: readyCountdown
				restoreEntryValues: false
				running: true
				count: 3
			}
		},
		State {
			name: 'in_game'
		},
		State {
			name: 'game_score'
		},
		State {
			name: 'game_over'
			PropertyChanges {
				target: gameText
				restoreEntryValues: false
				text: ""
			}
			PropertyChanges {
				target: gameOverTimer
				restoreEntryValues: false
				running: true
			}
		},
		State {
			name: 'game_over_score'
		}
	]

//	onStateChanged: {
//		console.log(state)
//	}

	Timer {
		id:gameOverTimer
		interval: 1000
		onTriggered: {
			var scorePage = pageStack.push(Qt.resolvedUrl("ScorePage.qml"), {
					resultModel: scoreModel,
					remainTime: countdown.pos
				});

			scorePage.restartGame.connect(function () {
//				console.log("--- RESTART !!!!");
				state = 'get_ready';
			});
			state = 'game_over_score';
		}
	}

	Component.onCompleted: {
		state = 'get_ready'
	}


/*	MouseArea {
		// TODO: passar pros Accelarators
		id: sensorDetectorEmul

		enabled: gamePage.state == 'in_game'

		anchors.fill: gamePage
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: {
//			console.log(mouse.x + " - " + mouse.y)
			if (mouse.y < 250) {
				saveResult(true)
			} else {
				saveResult(false)
			}
			ingameResumeTimer.start()
		}

	}*/

	Timer {
		id: ingameResumeTimer
		interval: 1500
		onTriggered: {
			nextText()
		}
	}

	Accelerometer {
		property int posCount
		property string posDirection

		function calcDirection(x, y, z) {
			if (z > 8.5) {
				return "z"
			}
			if (z < -8.5) {
				return "-z"
			}
			if (y > 8) {
				return "y"
			}
			if (y < -8) {
				return "-y"
			}
			return "off"
		}

		id: accel
		active: Qt.application.active && (state == 'in_game' || state == 'game_score')
		dataRate: 4
		onReadingChanged: {
			if (state == 'game_score') {
				// skip detection while processing score
				return
			}

			var direction = calcDirection(reading.x, reading.y, reading.z)
//			console.log(direction + " ---onReadingChanged--- x:" + reading.x + "; y: " + reading.y + "; z: "+ reading.z);
			if (direction !== posDirection) {
				posDirection = direction
				if (direction.indexOf("y") >= 0) {
					saveResult(false)
					ingameResumeTimer.start();
				} else if (direction === "-z") {
					saveResult(true)
					ingameResumeTimer.start();
				}
			}
		}

		onActiveChanged: {
			if (active) {
				posCount = 0
				posDirection = ""
			}
		}
	}
}
