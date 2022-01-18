#!/bin/sh

iw dev wlan0 iwlwav s11nProtection 1
iw dev wlan2 iwlwav s11nProtection 1

iw dev wlan0 iwlwav sCcaTh -62 -72 -72 -72 0
iw dev wlan2 iwlwav sCcaTh -62 0 -72 0 0
