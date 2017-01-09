import QtQuick 2.4
import io.thp.pyotherside 1.5

Item {

    signal transformed(var text)
    signal transformError(var error)

    function transform(text) {
        if (text) {
            py.importModule('premailer', function() {
                py.call('premailer.transform', [text], function (result) {
                    transformed(result)
                })
            })
        }
    }

    Python {
        id: py
        onError: transformError(traceback)
        Component.onCompleted: {
            py.addImportPath(Qt.resolvedUrl("./"))
            // This speeds up first time execution once we actually transform something
            py.importModule('premailer', function() {})
        }
    }
}
