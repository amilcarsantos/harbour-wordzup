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
import "utils/Persistence.js" as Persistence
import "utils"


Page {
	id: page



	ListModel {
		id: categoryModel
		property bool loaded: false
		ListElement{
			text: ''
			info: ''
			img: ''
		}
	}

	ListModel {
		id: scoreModel
	}

	Component.onCompleted: {
		mainWindow.initialUpdate.connect(function() {
			categoryModel.clear();
			Persistence.populateVisibleCategories(categoryModel);
			categoryModel.loaded = true;
		});
	}

	// To enable PullDownMenu, place our content in a SilicaFlickable
	SilicaFlickable {
		anchors.fill: parent

		// PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
		PullDownMenu {
			MenuItem {
				text: qsTr("Update")
				onClicked: pageStack.push(Qt.resolvedUrl("DataUpdatePage.qml"))
			}
			MenuItem {
				text: qsTr("Start Game")
				enabled: categoryModel.loaded
				onClicked: {
					var category = categoryModel.get(categoryView.currentIndex);
					var categoryId = category.id;
					mainWindow.currentCategory = category.text;
					pageStack.push(Qt.resolvedUrl("GamePage.qml"), {
										scoreModel: scoreModel,
										categoryId: categoryId
									}, PageStackAction.Animated);
				}
			}
		}

		// Tell SilicaFlickable the height of its content.
		contentHeight: page.height

		PageHeader {
			title: qsTr("Wordz Up!")
		}
		Label {
			anchors.bottom: categoryView.top
//				anchors.bottomMargin: Theme.paddingMedium
			x: Theme.paddingMedium
			text: qsTr("Select a category")
		}
		SlideshowView {
			id: categoryView
			model: categoryModel
			anchors.centerIn: parent
			width: parent.width
			height: parent.width

			delegate: Item {
				width: categoryView.itemWidth
				height: categoryView.itemHeight
				clip: true
				Rectangle {
					id: bgRect
					anchors.centerIn: parent
					width: categoryView.itemWidth - Theme.paddingMedium * 2
					height: categoryView.itemHeight - Theme.paddingMedium * 2
					border.width: 1
					color: Theme.primaryColor
					opacity: 0.05
				}
				Image {
					anchors.fill: bgRect
					anchors.margins: Theme.paddingMedium
					source: model.img
					opacity: 0.25
					fillMode: Image.PreserveAspectCrop
				}
				Label {
					id: categoryItem
					anchors.centerIn: parent
					color: Theme.primaryColor
					font.pixelSize: Theme.fontSizeLarge
					font.bold: true
					text: model.text
				}
				Label {
					anchors.top: categoryItem.bottom
					width: bgRect.width - Theme.paddingSmall * 2
					anchors.horizontalCenter: categoryItem.horizontalCenter
					color: Theme.primaryColor
					wrapMode: Text.WordWrap
					horizontalAlignment: Text.AlignHCenter
					text: model.info
					font.pixelSize: Theme.fontSizeSmall
				}
			}
		}
		Label {
			anchors {
				top: categoryView.bottom
				bottom: parent.bottom
				left: parent.left
				right: parent.right
				leftMargin: Theme.paddingMedium
			}
			font.pixelSize: Theme.fontSizeTiny

			text: "<b>Game play rules:</b><br>"
				+ "- Phone in front of you facing the screen to your friends<br>"
				+ "- Your friends give you clues<br>"
				+ "- Flip the screen face down for a correct guess<br>"
				+ "- Turn from landscape to portrait to skip<br>"
				+ "- Guess all 6 words under a minute."
			wrapMode: Text.WordWrap
		}
	}
}
