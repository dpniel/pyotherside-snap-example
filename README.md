This is a simple ubuntu app that inlines CSS of a html document using the
premailer python library and pyotherside.

To build and run the snap you need to be on xenial and have the overlay ppa
installed to be able to use the ubuntu-app-platform

```bash
$ sudo add-apt-repository ppa:ci-train-ppa-service/stable-phone-overlay
$ sudo apt update && sudo apt full-upgrade
$ sudo apt install snapcraft git
$ git clone https://code.dekkoproject.org/dpniel/pyotherside-snap-example.git
$ cd pyotherside-snap-example
$ snapcraft snap
$ snap install --dangerous premailer-example_0.1_amd64.snap
$ premailer-example
```

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