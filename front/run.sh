#!/bin/bash
export PATH="$HOME/flutter/bin:$PATH"
flutter pub get
flutter run -d web-server --web-port=4200 --web-hostname=0.0.0.0
