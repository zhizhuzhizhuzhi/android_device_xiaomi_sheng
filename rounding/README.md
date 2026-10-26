# Official Sheng screen corner masks

The matching official DevicesOverlay.apk supplies full-width2032x208 PNG strips.
AOSP ScreenDecorations expects one top-left-oriented tile per corner drawable.
The extractor selects the original left208x208 pixel region and reverses bottom
rows to the AOSP base orientation. No resize, thresholding or curve redraw occurs;
all source antialias alpha samples remain intact. Original PNG strips are retained
byte-for-byte in official/; provenance.json records APK/file/pixel SHA256 values.

The framework66px radius comes from official DevicesAndroidOverlay.apk. The208px
transparent tile frame is distinct from the66px framework logical radius and the
mask's93x92 nonzero-alpha extent. drawable-nodpi keeps physical pixel alignment at
400dpi and in both rotations; the SystemUI provider handles orientation itself.
