import qbs
import qbs.Process

/*
  I Was going to tidy this up into nice Qbs modules like
  PythonQmlPlugin{} and UbuntuApplication {} and hide the internals
  but for clarity I thought it best to show it all in one file.
  It's basic qml/js, nothing too unfamiliar going on, so you
  should get a good idea on how it works.

  If anyone is interested in having a template tidied up into nice
  easy modules let me know.
*/

Project {
    id: premailer
    name: "PreMailer"

    property string binDir: ""
    PropertyOptions {
        name: "binDir"
        description: "
            The location to install the app binary to.

            Typically '/usr/bin'

            NOTE: You should only set this at build time using the
            qbs tool, e.g 'qbs build project.buildDir:/usr/bin ...'
            Take a look in /parts/plugins/x-qbs.py to see it being set
        "
    }

    property string qmlPluginDir: ""
    PropertyOptions {
        name: "qmlPluginDir"
        description: "
            The location to install the qml plugin to.

            Typically '/usr/lib/<arch_triplet>/qt5/qml'

            NOTE: You should only set this at build time using the
            qbs tool, e.g 'qbs build project.qmlPluginDir:/usr/bin ...'
            Take a look in /parts/plugins/x-qbs.py to see it being set
        "
    }

    /* This Product creates a qml Plugin containing the PreMailer.qml transfomer
       and includes the required python packages which we download from pypi.

       We will make use of Ubuntu Cores Python3 standard library so we don't have to include
       those in the snap. and instead we carefully pick out the python directories we need
       to reduce the snap size.
    */
    Product {
        name: project.name + " Plugin"
        type: "python-qml-plugin"

        // This probe does all the hard work of fetching from pypi
        Probe {
            id: pip3
            // Declare your list of pypi packages here
            readonly property var pythonPackages: [
                "premailer"
            ]
            // DO NOT EDIT MANUALLY. this would normally be hidden
            // inside a module.
            property bool installed: false
            // The directory where you want to install pypi packages
            // You might like to add this directory to you .gitignore/.bzrignore
            property string sourceDir: project.sourceDirectory + "/pylibs"

            configure: {
                if (!pythonPackages.length) {
                    console.info("No python packages to install")
                    return
                }
                // we use the Process service to run pip3
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
        // make the qml types available in the editor
        // NOTE: requires you build the project first.
        property stringList qmlImportPaths: [qbs.installRoot]

        // Here we define the python directories we want to include in our
        // qml plugin.
        Group {
            // Only enable this if pip3 installed correctly
            condition: pip3.installed
            name: "Python Libs"
            prefix: pip3.sourceDir + "/lib/python3.5/site-packages/"
            // List the package dirs you want in the qml plugin
            // The idea here is to only declare what's _required_ to reduce our size a bit
            files: [
                "premailer/**",
                "cssselect/**",
                "cssutils/**",
                "lxml/**",
                "requests/**",
                "encutils/**"
            ]
            // cssutils comes with a large test suite
            // which we don't really need in the snap
            // it saves us about 1MB
            excludeFiles: [
                "cssutils/tests/**"
            ]
            fileTags: ["premailer-py"]
        }
        // Install directive for the python libs above
        Group {
            fileTagsFilter: "premailer-py"
            qbs.install: true
            qbs.installDir: premailer.qmlPluginDir + "/" + project.name
            // This ensures we maintain the directory structure
            qbs.installSourceBase: pip3.sourceDir + "/lib/python3.5/site-packages"
        }

        Group {
            name: "QML components"
            files: "backend/**/*.qml"
            fileTags: ["premailer-component"]
        }

        Group {
            name: "QML directory"
            files: "backend/qmldir"
            fileTags: ["premailer-component"]
        }
        // Install directive for all the qml files and qmldir
        // these are installed to the same location as the python dirs.
        Group {
            fileTagsFilter: "premailer-component"
            qbs.install: true
            qbs.installDir: premailer.qmlPluginDir + "/" + project.name
            qbs.installSourceBase: "backend"
        }
    }

    /*
      Create the app binary. We make use of the qt resource system
      for including the qml/js files in the application binary and not
      have to care about their location within the snap. Just remember
      to prefix your file paths with 'qrc:/' in your qml files.

      e.g Qt.resolvedUrl("qrc:///qml/MyComponent.qml")
    */
    QtGuiApplication {
        name: project.name + " App"
        targetName: project.name.toLowerCase()
        // Setup the binary dependencies
        Depends { name : "cpp" }
        Depends {
            name: "Qt"
            submodules: [
                "core",
                "quick",
                "qml",
                "gui"
            ]
        }
        // Just some configs/optimizations
        // these shouldn't need changing really.
        cpp.optimization: qbs.buildVariant === "debug" ? "none" : "fast"
        cpp.debugInformation: qbs.buildVariant === "debug"
        cpp.cxxLanguageVersion: "c++11";
        cpp.cxxStandardLibrary: "libstdc++";
        cpp.includePaths: [ path ]

        // Simple binary launcher that instantiates
        // a QQmlApplicationEngine to load the UI.
        Group {
            name: "C++ Sources"
            prefix: "app/"
            files: [
                "main.cpp"
            ]
        }
        // app.qrc contains all the qml/js UI files.
        // You will find them in qtcreator in the UI Files folder
        // These get compiled into the application binary
        // and are accessed using the qt resource system.
        Group {
            name: "UI Files"
            prefix: "app/"
            files: [
                "app.qrc"
            ]
        }

        Group {
            qbs.install: true
            qbs.installDir: project.binDir
            fileTagsFilter: product.type
        }
    }

    // This Product just makes useful files visible in qtcreator
    // but doesn't install or include them in the build step
    Product {
        name: "Other Files"
        type: "docs"
        files: [
            "*.yaml",
            "*.yml",
            "*.md",
        ]
    }
}
