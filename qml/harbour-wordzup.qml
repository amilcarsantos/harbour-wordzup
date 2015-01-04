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
import "pages"
import "pages/utils/Persistence.js" as Persistence

ApplicationWindow {
	id: mainWindow

	property string version: "0.1"
	property string appname: "Wordz Up"
	property string appicon: "qrc:/harbour-wordzup.png"
	property string appurl:  "https://github.com/amilcarsantos/harbour-wordzup"

	property string currentCategory: ""

	signal initialUpdate

	initialPage: Component {
		FirstPage {
			id: firstPage
		}
	}
	cover: Qt.resolvedUrl("cover/CoverPage.qml")

	Rectangle {
		id: indexingPopup
		visible: false
		width: parent ? parent.width : Screen.width
		height: Theme.itemSizeSmall
		color: Theme.highlightBackgroundColor
		Label {
			text: "Indexing, please wait..."
			anchors.fill: parent
			anchors.margins: Theme.paddingSmall
			font.family: Theme.fontFamilyHeading
			font.pixelSize: Theme.fontSizeMedium
			color: "black"
			truncationMode: TruncationMode.Fade
			opacity: 0.7
		}
	}

	Component.onCompleted: {
		print ("ApplicationWindow init")
		Persistence.initialize();
		if (Persistence.settingBool("firstLoad", "true")) {
			indexingPopup.visible = true
			firstLoad();
			Persistence.setSetting("firstLoad", "false");
		} else {
			initialUpdate();
		}
	}

	function firstLoad() {
		var component = Qt.createComponent(Qt.resolvedUrl("pages/utils/FirstLoad.qml"));

		var incubator = component.incubateObject(mainWindow);
		if (incubator.status !== Component.Ready) {
			incubator.onStatusChanged = function(status) {
				if (status === Component.Ready) {

					print ("Object", incubator.object, "is now ready!");
					incubator.object.categoriesLoaded.connect(initialUpdate)
					incubator.object.indexComplete.connect(function() {
						indexingPopup.visible = false;
					});
				}
			}
		}
	}
}


