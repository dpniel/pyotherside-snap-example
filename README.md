# Pyotherside snap app example.

This is a simple ubuntu app that inlines CSS of a html document using the
premailer python library and pyotherside.

This example uses the qbs build tool with a custom snapcraft plugin for no other
reason than i love being able to script my builds in QML. It's a dream!
But you can always use cmake/qmake if you prefer and just adapting the logic
in `app.qbs` for your specific tool.

The example also makes use of the ubuntu-app-platform snap content interface
to reduce snap size.

I have extensively documented `app.qbs` so hopefully you shouldn't have
any problems with this.

## Setup

At the moment you need to be on xenial with the overlay ppa installed. So that
we compile against the correct Qt libraries that are in the ubuntu-app-platform snap

```bash
$ sudo add-apt-repository ppa:ci-train-ppa-service/stable-phone-overlay
$ sudo apt update && sudo apt full-upgrade
$ sudo apt install snapcraft qbs git ubuntu-sdk-libs
```

## Build a snap

Building the snap is somewhat easier than running on desktop as snapcraft
has been configured to take care of everything for you

If you don't already have the ubuntu-app-platform snap installed then

```bash
$ snap install --edge --devmode ubuntu-app-platform
```
and then

```bash
$ cd pyotherside-snap-example
$ snapcraft snap
$ snap install --dangerous premailer-example_0.1_amd64.snap
$ premailer-example
```

## Run locally

Firstly I don't know what qbs support is like in the ubuntu-sdk-ide
as i use qtcreator from upstream. But it should work i suppose?? or
you can just do it all from the command line.

To run locally you will need to build and install pyotherside.
This is because it needs to be compiled against the qt libs from the
overlay ppa which the pyotherside in the archive is not (AFAIK).

```bash
$ git clone https://github.com/thp/pyotherside.git
$ cd pyotherside
$ qmake
$ make
$ sudo make install
```

### QtCreator

You should be able to just open `app.qbs` with qtcreator and run
the "PreMailer App"

### Command line

Or if you want to do it from the command line you will need
to setup a qt toolchain.

```base
$ export QT_SELECT=qt5
$ qbs setup-toolchains --detect
$ qbs setup-qt /usr/bin/qmake xenialqt5
```

You will now have a build profile called `xenialqt5`

```bash
$ cd pyotherside-snap-example
$ qbs build profile:xenialqt5 debug
$ qbs run profile:xenialqt5
```

And BOOM! it should run.

## Some sample input

When the app launches add this text to the top text area

```html
<html>
  <head>
  <style type="text/css">
    body {
      background-color: #f2f2f2;
    }
  </style>
  </head>
  <body>
    <p>Style should be in the body tag ^^ above ^^</p>
  </body>
</html>
```

You should see the css has been inlined in the bottom text area.
