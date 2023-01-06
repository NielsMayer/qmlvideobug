# qmlvideobug

Minimal example Qt5/Qt6 "portable' test app to demonstrate regressions
seen in Qt 6.4.2, 6.5.0beta1 and 6.6.0 "dev" releases on Android. They work
correctly across Qt Versions on Linux, for example.

See https://bugreports.qt.io/browse/QTBUG-109731 for details.
> QTBUG-109731: 
> 6.5beta1 & 6.6 regression QML MediaPlayer shows Corrupt/Blank Video If Playback Starts at Launch

In all prior versions of 
Qt 5.15, 6.2, 6.3, 6.4.0, 6.4.1, this app works correctly -- playing back an internet
copy of the open-source "Big Buck Bunny" test video. 

Beginning with 6.4.2, 6.5.0beta1 and 6.6.0 "dev" releases, the expected video display is either blank or corrupted.

In 6.5, the video area is blank, and the reported video speed is (per reported playback position) is faster than actual time. Sometimes the audio seems pitched wrong.

This problem only manifests if the video playback starts immediately on application launch. If the QML QQC2 display in which the VideoOutput item resides is otherwise used for selecting the video file, e.g. "Examples/Qt-6.4.0/multimedia/video/qmlvideo/", then the video will play back normally.

Likewise in Qt5.5 or Qt5.6, selecting a different video source, in this qmlvideobug app, e.g. the second or third entries in the menu "BBB RTSP ...." should display the video normally;  Also, re-selecting, after playing a different source, the default source "BBB HTTP", results in correct playback and display.
