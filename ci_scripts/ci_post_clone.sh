#!/bin/sh
set -euo pipefail

defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
