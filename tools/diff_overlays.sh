#!/bin/bash
#
# Copyright (C) 2021-2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

if [[ -z "${1}" ]] || [[ -z "${2}" ]]; then
    echo "Usage: diff_overlays.sh /path/to/dump1 /path/to/dump2"
    exit
fi

if [[ -d out ]]; then
    echo "[WARNING] Out is not empty"
fi

mkdir -p out/1
mkdir -p out/2

# This must be the exact filename in product/overlay/ without .apk extension
unversioned_overlays="GoogleConfigOverlay PixelConfigOverlay2018 PixelConfigOverlay2019Midyear PixelConfigOverlay2019 PixelConfigOverlay2021 PixelConfigOverlayCommon PixelDocumentsUIGoogleOverlay/PixelDocumentsUIGoogleOverlay PixelSetupWizard__auto_generated_rro_product PixelSetupWizardOverlay"

for i in ${unversioned_overlays}
do
    if [[ ! -f "${1}"/product/overlay/"${i}".apk ]]; then
        echo ""${1}"/product/overlay/"${i}".apk does not exit!"
    fi

    if [[ ! -f "${2}"/product/overlay/"${i}".apk ]]; then
        echo ""${2}"/product/overlay/"${i}".apk does not exit!"
    fi

    apktool d "${1}"/product/overlay/"${i}".apk -o out/1/"${i}" > /dev/null
    apktool d "${2}"/product/overlay/"${i}".apk -o out/2/"${i}" > /dev/null

    diff -ur out/1/"${i}" out/2/"${i}"

    echo ""
    echo ""
    echo ""
done

# These overlays should have just one year per dump
versioned_overlays=" PixelConnectivityOverlay PixelSetupWizardOverlay"
years="2018 2019Midyear 2019 2020Midyear 2020 2021"

for i in ${versioned_overlays}
do
    for y in ${years}
    do
        apktool d "${1}"/product/overlay/"${i}""${y}".apk -o out/1/"${i}" > /dev/null
        apktool d "${2}"/product/overlay/"${i}""${y}".apk -o out/2/"${i}" > /dev/null
    done

    apktool d "${1}"/product/overlay/"${i}".apk -o out/1/"${i}" > /dev/null
    apktool d "${2}"/product/overlay/"${i}".apk -o out/2/"${i}" > /dev/null


    if [[ ! -d out/1/"${i}" ]]; then
        echo "${i} does not exit on device 1!"
    fi

    if [[ ! -d out/2/"${i}" ]]; then
        echo "${i} does not exit on device 2!"
    fi

    diff -ur out/1/"${i}" out/2/"${i}"

    echo ""
    echo ""
    echo ""
done
