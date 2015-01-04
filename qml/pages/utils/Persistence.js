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

// Persistence.js
.import QtQuick.LocalStorage 2.0 as PersistenceLS

// First, let's create a short helper function to get the database connection
function database() {
	return PersistenceLS.LocalStorage.openDatabaseSync("wordzup", "1.0", "PersistenceDatabase", 100000);
}

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
	database().transaction(
		function(tx,er) {
			// Create the settings table if it doesn't already exist
			tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT, value TEXT)');
			// Creates tables if it doesn't already exist
			tx.executeSql('CREATE TABLE IF NOT EXISTS categories(id INTEGER PRIMARY KEY, name TEXT, info TEXT, image TEXT, visible INTEGER DEFAULT 1)');

			tx.executeSql('CREATE TABLE IF NOT EXISTS gameWords(sid TEXT PRIMARY KEY NOT NULL, words TEXT, categoryId INTEGER, lastUsage DATETIME DEFAULT CURRENT_TIMESTAMP)');
		});
}

function setting(settingName, defaultValue) {
	var value = defaultValue
	database().readTransaction(function(tx) {
		var rs = tx.executeSql('SELECT * FROM settings WHERE setting=?', [settingName])
		if (rs.rows.length > 0) {
			value = rs.rows.item(0).value
		}
	});
//	console.log("setting '" + settingName + "' value: " + value);
	return value;
}
function stringToBoolean(str) {
	switch(str.toString().toLowerCase()) {
	case "true": case "yes": case "1":
		return true;
	case "false": case "no": case "0": case null:
		return false;
	default:
		return Boolean(string);
	}
}

function settingBool(settingName, defaultValue) {
	var value = setting(settingName, defaultValue)
	return stringToBoolean(value);
}

function settingInt(settingName, defaultValue) {
	var value = setting(settingName, defaultValue)
	return parseInt(value, 10);
}

// This function is used to update settings into the database
function setSetting(settingName, value) {
	var res = "";
	database().transaction(function(tx) {
		res = "OK";
		var stringValue = value.toString();
		var rs = tx.executeSql('UPDATE settings SET value=? WHERE setting=?', [stringValue, settingName]);
		if (rs.rowsAffected === 0) {
			rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [settingName, stringValue]);
			if (rs.rowsAffected === 0) {
				res = "Error";
			}
		}
	});
	// The function returns "OK" if it was successful, or "Error" if it wasn't
//	console.log("setSetting '" + setting + "' result: " + res);
	return res;
	}

function populateVisibleCategories(model) {
	database().readTransaction(function(tx) {
		var rs = tx.executeSql("SELECT id,name,info,image FROM categories WHERE visible=1 ORDER BY name");
		for (var i = 0; i < rs.rows.length; i++) {
			model.append({ 
				"id": rs.rows.item(i).id,
				"text": rs.rows.item(i).name,
				"info": rs.rows.item(i).info,
				"img": rs.rows.item(i).image
			});
		}
	});
}

function persistCategory(name, info, image) {
	var res = "";
	database().transaction(function(tx) {
		res = "OK";
		var rs = tx.executeSql("INSERT INTO categories (name, info, image) VALUES (?, ?, ?)", [name, info, image]);
		if (rs.rowsAffected === 0) {
			res = "Error";
		}
	});
	return res;
}

function getCategoryId(name) {
	var res = "";
	database().readTransaction(function(tx) {
		res = "OK";
		var rs = tx.executeSql("SELECT id FROM categories WHERE name=?", [name]);
		if (rs.rows.length === 1) {
			res = rs.rows.item(0).id;
		} else {
			res = "Error";
		}
	});
	return res;
}

function removeAllCategories() {
	var res = "";
	database().transaction(function(tx) {
		res = "OK";
		var rs = tx.executeSql("DELETE FROM categories");
		if (rs.rowsAffected === 0) {
			res = "Error";
		}
	});
	return res;
}

function populateGameWords(model, categoryId, max) {
	database().readTransaction(function(tx) {
		var rs = tx.executeSql("SELECT sid, words FROM gameWords WHERE categoryId=? ORDER BY lastUsage LIMIT ?", [categoryId, max]);
		for (var i = 0; i < rs.rows.length; i++) {
			model.append({ 
				"id": rs.rows.item(i).sid,
				"text": rs.rows.item(i).words
			});
		}
	});
}

function persistGameWord(sid, words, categoryId, lastUsage) {
	var res = "";
	database().transaction(function(tx) {
		res = "OK";
		var rs = tx.executeSql("INSERT OR REPLACE INTO gameWords (sid, words, categoryId, lastUsage) VALUES (?, ?, ?, datetime(?, 'utc'))", [sid, words, categoryId, lastUsage]);
		if (rs.rowsAffected === 0) {
			res = "Error";
		}
	});
	return res;
}

function updateGameWordUsage(sid) {
	database().transaction(function(tx) {
		tx.executeSql("UPDATE gameWords SET lastUsage = datetime('NOW') WHERE sid=?", [sid]);
	});
}

function removeGameWord(sid) {
	var res = "";
	database().transaction(function(tx) {
		res = "OK";
		var rs = tx.executeSql("DELETE FROM gameWords WHERE sid=?", [sid]);
		if (rs.rowsAffected === 0) {
			res = "Error";
		}
	});
	return res;
}

function removeAllGameWords() {
	var res = "";
	database().transaction(function(tx) {
		res = "OK";
		var rs = tx.executeSql("DELETE FROM gameWords");
		if (rs.rowsAffected === 0) {
			res = "Error";
		}
	});
	return res;
}

