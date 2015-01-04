
function copyCategoriesModel(sourceModel, targetModel) {
	targetModel.clear();
	for (var i = 0; i< sourceModel.count; i++) {
		targetModel.append({
			text:sourceModel.get(i).name,
			info:sourceModel.get(i).info
		});
	}
}


function copyWordsModel(sourceModel, targetModel) {
	targetModel.clear();
	for (var i = 0; i< sourceModel.count; i++) {
		targetModel.append({text:sourceModel.get(i).word});
//		console.log(get(i).word)
	}
}
