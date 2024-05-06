#!/bin/bash
mv .theos/obj/MetroLockScreen.dylib .theos/obj/org.coolstar.metrolockscreen.license.signed
ldid -S .theos/obj/org.coolstar.metrolockscreen.license.signed
mv .theos/obj/org.coolstar.metrolockscreen.license.signed .theos/obj/MetroLockScreen.dylib
