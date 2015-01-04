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
import QtQuick.XmlListModel 2.0
import "Persistence.js" as Persistence

Item {

	signal categoriesLoaded(var model)
	signal indexComplete()

	XmlListModel {
		id: categoriesLoader
		query: "/Categories/c"
		XmlRole { name: "name"; query: "t/string()" }
		XmlRole { name: "info"; query: "i/string()" }
		XmlRole { name: "file"; query: "f/string()" }
		XmlRole { name: "image"; query: "b/string()" }
		onStatusChanged: {
			if (status == XmlListModel.Ready) {
				Persistence.removeAllCategories();
				for (var i = 0; i < count; i++) {
					var info = get(i).info.replace("\\n", "\n");
					Persistence.persistCategory(get(i).name, info, get(i).image);
				}
				categoriesLoaded(categoriesLoader);
				wordsIndexer.categoryIndex = 0;
				wordsLoader.source = "qrc:/data/" + get(0).file;
				console.log(wordsLoader.source);
			}
		}
	}


	Component.onCompleted: {
		console.log("First load...")
		categoriesLoader.source = "qrc:/data/Categories.xml"
	}

	XmlListModel {
		id: wordsLoader

		query: "/Words/w"
		XmlRole { name: "word"; query: "string()" }
		onStatusChanged: {
			console.log("status " + status);
			console.log("status " + errorString());
			if (status == XmlListModel.Ready) {
				wordsIndexer.startIndex()
			}
		}
	}


	Timer {
		id: wordsIndexer

		property int lastPos: 0
		property int categoryIndex: -1
		property int categoryId: -1

		interval: 10
		repeat: true

		function startIndex() {
			lastPos = 0
			print(categoriesLoader.get(categoryIndex).name);
			categoryId = Persistence.getCategoryId(categoriesLoader.get(categoryIndex).name);
			print(categoryId);
			restart();
		}

		onTriggered: {
			var endPos = Math.min(wordsLoader.count, lastPos + 100);
			var lastUsage = new Date();
			var now = new Date();

			for (var i = lastPos; i < endPos; i++) {
				var text = wordsLoader.get(i).word;
				var sid = sidFromName('int', text);
//					print(sid, text);
				lastUsage.setTime(now.getTime() - Math.random() * 90000);
				Persistence.persistGameWord(sid, text, categoryId, lastUsage);
			}
			lastPos = endPos
			if (endPos === wordsLoader.count) {
				stop()
				categoryIndex++;
				if (categoryIndex < categoriesLoader.count) {
					wordsLoader.source = "qrc:/data/" + categoriesLoader.get(categoryIndex).file;
				} else {
					indexComplete()
				}
			}
		}
	}

	function sidFromName(region, text) {
		var sidPart2 = text.replace(/[ _.\\']/g, "");
		if (sidPart2.length < 8) {
			sidPart2 = sidPart2 + "00000000";
		}
		return region + '_' + sidPart2.substring(0,8).toUpperCase();
	}
}
