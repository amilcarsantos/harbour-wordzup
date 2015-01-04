import QtQuick 2.0

Item {
    id: root

	property alias font: label1.font
	property alias color: label1.color

    property string text
    property bool animate: true

    property real _target: 0
    property real _rotation: _target

	signal flipping()

	Behavior on _rotation { SmoothedAnimation { velocity: 2 } }

    height: label1.height
    opacity: 0.8

	Text {
        id: label1
        visible: !label2.visible
//		anchors.centerIn: parent
		anchors.fill: parent
		verticalAlignment: Text.AlignVCenter
		horizontalAlignment: Text.AlignHCenter

		transform: Rotation {
            origin { x: label1.width / 2; y: label1.height / 2 }
            axis { x: 1; y: 0; z: 0 }
            angle: (root._rotation % 2) * 180
        }
		onVisibleChanged: {
			checkFlipping()
		}
    }

	function checkFlipping() {
		if (label1.visible != label2.visible) {
			flipping()
		}
	}

	Text {
        id: label2
        function label2visible() { return r.angle > -90 && r.angle < 90 }
        visible: label2visible()
//		anchors.centerIn: parent
		anchors.fill: parent
		color: label1.color
		font: label1.font
		verticalAlignment: Text.AlignVCenter
		horizontalAlignment: Text.AlignHCenter

        transform: Rotation {
            id: r
            origin { x: label1.width / 2; y: label1.height / 2 }
            axis { x: 1; y: 0; z: 0 }
            angle: -180 * (1 - (root._rotation % 2))
        }
		onVisibleChanged: {
			checkFlipping()
		}
    }

    onTextChanged: {
        if (animate) {
			if (!label2.label2visible()) {
				label2.text = text
			} else {
				label1.text = text
			}
            if (_target - _rotation < 0.5) _target++
        } else {
            if (!label2.label2visible()) label1.text = text
            else label2.text = text
        }
    }

    Component.onCompleted: label1.text = root.text
}
