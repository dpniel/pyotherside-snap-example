import qbs
import qbs.Process

Project {
    id: premailer
    name: "Premailer QML"
    // This is usually in the format /usr/lib/<arch_triplet>/qt5/qml
    // We have to manually set this at build time.
    // Take a look in /parts/plugins/x-qbs.py
    property string qmlPluginDir: ""

    // Location to store the apps qml ui
    // you can override this either here or from the qbs snapcraft plugin
    property string qmlDir: "/usr/share/premailer"

    // Create a
    Product {
        name: "PreMailer Plugin"
        type: "premailer-qml-plugin"

        Probe {
            id: pip3
            // Declare your list of pypi packages here
            property var pythonPackages: [
                "premailer"
            ]
            // DO NOT EDIT MANUALLY.
            property bool installed: false
            // The directory packages are installed to
            property string sourceDir: project.sourceDirectory + "/pylibs"

            configure: {
                var p = new Process();
                p.setWorkingDirectory(path)
                // override pip's idea of --user location
                p.setEnv("PYTHONUSERBASE", sourceDir)
                var pipDeps = pythonPackages
                // prepend install command to package list
                pipDeps.unshift("install", "--user")
                // Finally run pip
                if (p.exec("/usr/bin/pip3", pipDeps , true) === 0) {
                    installed = true
                } else {
                   throw "Pip Not working"
                }
            }
        }

        // Here we define the
        Group {
            // Only enable this if pip3 installed correctly
            condition: pip3.installed
            name: "Python Libs"
            prefix: pip3.sourceDir + "/lib/python3.5/site-packages/"
            // List the package dirs you want in the qml plugin
            // The idea here is to only declare what's _required_ to reduce our size a bit
            // Snap core comes bundled with the py3 standard library so we make use
            // of that instead of shipping our own.
            files: [
                "premailer/**",
                "cssselect/**",
                "cssutils/**",
                "lxml/**",
                "requests/**",
                "encutils/**"
            ]
            fileTags: ["premailer-py"]
        }
        // Install directive for the python libs above
        Group {
            fileTagsFilter: "premailer-py"
            qbs.install: true
            qbs.installDir: premailer.qmlPluginDir + "/PreMailer"
            qbs.installSourceBase: "pylibs/lib/python3.5/site-packages"
        }

        Group {
            name: "QML components"
            files: "plugin/**/*.qml"
            fileTags: ["premailer-component"]
        }

        Group {
            name: "QML directory"
            files: "plugin/qmldir"
            fileTags: ["premailer-component"]
        }

        Group {
            fileTagsFilter: "premailer-component"
            qbs.install: true
            qbs.installDir: premailer.qmlPluginDir + "/PreMailer"
            qbs.installSourceBase: "plugin"
        }
    }

    Product {
        name: "PreMailer UI"
        type: "premailer-ui"

        Group {
            name: "QML components"
            files: "ui/Main.qml"
            qbs.install: true
            qbs.installDir: premailer.qmlDir
        }
    }
}
