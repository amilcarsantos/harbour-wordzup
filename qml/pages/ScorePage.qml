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


Page {
	id: page

	property variant resultModel
	property int remainTime: 0
	property int _gessedCount
	property int _score

	signal restartGame()

	Component.onCompleted: {
		_gessedCount = 0
		for (var i=0; i < resultModel.count; i++) {
			if (resultModel.get(i).gessed) {
				_gessedCount = _gessedCount + 1
			}
		}
		_score = _gessedCount * 20 + remainTime;		// TODO
	}

	SilicaListView {
		id: listView
		model: resultModel
		anchors.fill: parent
		header: PageHeader {
			title: qsTr("Score")
		}

		PullDownMenu {
			MenuItem {
				text: qsTr("Restart")
				onClicked: {
					restartGame()
					pageStack.pop();
				}
			}
		}

		Component {
			id: sectionHeading

			Rectangle {
				width: page.width
				height: Theme.fontSizeExtraLarge + Theme.paddingLarge * 2
				color: 'transparent'
//				opacity: 0.05
				Rectangle {
					anchors.fill: parent
					color: Theme.primaryColor
					opacity: 0.05
				}
				Image {
					anchors.fill: parent
					fillMode: Image.Stretch
					source: "image://theme/graphic-gradient-home-bottom?" + Theme.secondaryColor
					opacity: 0.3
				}
				Text {
					anchors.left: parent.left
					anchors.leftMargin: Theme.paddingLarge
					anchors.verticalCenter: parent.verticalCenter
					text: qsTr("Correct")
					font.pixelSize: Theme.fontSizeExtraLarge
					color: Theme.primaryColor
				}
				Text {
					anchors.right: scoreLabel.left
					anchors.verticalCenter: parent.verticalCenter
					width: 80
					text: _gessedCount
					horizontalAlignment: Text.AlignHCenter
					font.bold: true
					font.pixelSize: Theme.fontSizeExtraLarge
					color: Theme.primaryColor
				}
				Text {
					id: scoreLabel
					anchors.right: parent.right
					anchors.rightMargin: Theme.paddingLarge
					anchors.verticalCenter: parent.verticalCenter
					width: 80
					text: _score
					horizontalAlignment: Text.AlignHCenter
					font.bold: true
					font.pixelSize: Theme.fontSizeExtraLarge
					color: Theme.highlightColor
				}
			}
		}

		section.property: "score"
		section.criteria: ViewSection.FullString
		section.delegate: sectionHeading

		delegate: Item {
			id: delegate

			height: Theme.fontSizeLarge + Theme.paddingLarge * 2
			width: ListView.view.width
			Rectangle {
				width: parent.width
				height: parent.height
				color: Theme.primaryColor
				opacity: 0.05
				visible: model.index & 1
			}

			Label {
				anchors.left: parent.left
				anchors.leftMargin: Theme.paddingLarge
				anchors.verticalCenter: parent.verticalCenter
				anchors.right: gessedIcon.left
				text: model.text
//				anchors.verticalCenter: parent.verticalCenter
				color: Theme.primaryColor
				font.pixelSize: Theme.fontSizeLarge
				truncationMode: TruncationMode.Fade
			}
			Image {
				id: gessedIcon
				anchors.right: pointsLabel.left
				anchors.rightMargin: model.gessed ? 0 : Theme.paddingSmall
				anchors.verticalCenter: parent.verticalCenter
				source: "image://theme/icon-header-" + (model.gessed? "accept?green" : "cancel?orange")
			}
			Text {
				id: pointsLabel
				anchors.right: parent.right
				anchors.rightMargin: Theme.paddingLarge
				anchors.verticalCenter: parent.verticalCenter
				width: 80
				text: model.gessed ? "20" : "0"
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: Theme.fontSizeExtraLarge
				color: Theme.highlightColor
			}
		}

		footer: Item {
			id: footer

			height: Theme.fontSizeLarge + Theme.paddingLarge * 2
			width: page.width
			Rectangle {
				width: parent.width
				height: parent.height
				color: Theme.primaryColor
				opacity: 0.05
				visible: resultModel.count & 1
			}

			Label {
				anchors.left: parent.left
				anchors.leftMargin: Theme.paddingLarge
				anchors.verticalCenter: parent.verticalCenter
				anchors.right: timeLabel.left
				text: qsTr("Remaining time")
				color: Theme.primaryColor
				font.pixelSize: Theme.fontSizeLarge
				truncationMode: TruncationMode.Fade
			}
			Text {
				id: timeLabel
				anchors.right: timePointsLabel.left
				anchors.verticalCenter: parent.verticalCenter
				width: 80
				text: remainTime
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: Theme.fontSizeExtraLarge
				color: Theme.primaryColor
			}
			Text {
				id:timePointsLabel
				anchors.right: parent.right
				anchors.rightMargin: Theme.paddingLarge
				anchors.verticalCenter: parent.verticalCenter
				width: 80
				text: remainTime
				horizontalAlignment: Text.AlignHCenter
				font.pixelSize: Theme.fontSizeExtraLarge
				color: Theme.highlightColor
			}
		}

		VerticalScrollDecorator {}
	}
}
