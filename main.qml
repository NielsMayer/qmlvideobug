// Copyright (C) 2022 Niels P. Mayer (http://nielsmayer.com)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import QtQuick 2.12;
import QtQml.Models 2.12;      //ListModel, ListElement
import QtQuick.Controls 2.12;  //ApplicationWindow, ToolBar, Button, Text, etc.
import QtQuick.Layouts 1.12;   //RowLayout and Layout.fillWidth settings
//import QtMultimedia;      //MediaPlayer, VideoOutput, AudioOutput, etc.

import com.nielsmayer.Utils       1.0;  //for Utils.getUiDuration(), Utils.formatDuration()

ApplicationWindow {
    id:                              app;
    title:                           mediaPlayer.title;
    visible:                         true;
    width:                           640;
    height:                          480;
    // NO DON'T
    // Size the app-window based on size of source video, with a minimum size of 320x240 if not defined
    // and a default size of 640x480 otherwise.
//    width: ((typeof videoRender.sourceRect.width === "number")
//            && (videoRender.sourceRect.width > 320))
//           ? videoRender.sourceRect.width + Qt.application.font.pixelSize
//           : 640;
//    height: ((typeof videoRender.sourceRect.height === "number")
//             && (videoRender.sourceRect.height > 240))
//            ? videoRender.sourceRect.height + Qt.application.font.pixelSize
//              + header.height + footer.height
//            : 480;

    ListModel {
        id: sourcesModel;
        ListElement {
            title: "BBB HTTP"; //default media selection which will be played back automatically at start-up, see Component.onCompleted: below.
            source: "https://www.rmp-streaming.com/media/big-buck-bunny-360p.mp4"}
        ListElement {
            title: "BBB RTSP MP4 (crash qt<6.2.2)";
            source: "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mp4"} //--> for Qt6.2.1: "unexpectedly finished" with "GLib-GObject-WARNING... invalid cast from 'GstRTSPSrc' to 'GstBaseSrc'"
        ListElement {
            title: "BBB RTSP MOV (crash qt<6.2.2)";
            source: "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov"} //--> for Qt6.2.1: "unexpectedly finished" with "GLib-GObject-WARNING... invalid cast from 'GstRTSPSrc' to 'GstBaseSrc'"
        ListElement {
            title: "Mixcloud Audio";
            source: "https://stream11.mixcloud.com/secure/c/m4a/64/d/0/3/6/6974-3b65-43f5-82a9-b05f5fb326a1.m4a?sig=3UPFfSKX0qiOR43rTXEN0A"; }
        ListElement {
            title: "Worldwide FM HTTP";
            source: "http://worldwidefm.out.airtime.pro:8000/worldwidefm_a"}
        ListElement {
            title: "Worldwide FM HTTPS";
            source: "https://worldwidefm.out.airtime.pro:8443/worldwidefm_a"}  //supplying this stream causes it to hang uninterruptibly.
        ListElement {
            title: "Media Monarchy M3U";
            source: "https://www.mediamonarchy.com/mediamonarchy.m3u"} //--> "Error: 1... Internal data stream error." output to message area, stdout: 'qt.multimedia.player: Warning: "No decoder available for type 'text/uri-list'."'
        ListElement {
            title: "Media Monarchy PLS";
            source: "https<://www.mediamonarchy.com/mediamonarchy.pls"} //--> "MediaPlayer -- invalid media!" output to message area. Nothing to stdout.
        ListElement {
            title: "BBC Radio One";
            source: "https://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_radio_one.m3u8"}
        ListElement {
            title: "BBC Radio One Extra";
            source: "https://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_1xtra.m3u8"}
        ListElement {
            title: "BBC Radio Two";
            source: "https://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_radio_two.m3u8"}
        ListElement {
            title: "BBC Radio Three";
            source: "https://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_radio_three.m3u8"}
        ListElement {
            title: "BBC Radio Four FM";
            source: "https://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_radio_fourfm.m3u8"}
        ListElement {
            title: "BBC Radio Four Extra";
            source: "https://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_radio_four_extra.m3u8"}
        ListElement {
            title: "BBC Radio Five Live";
            source: "https://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_radio_five_live.m3u8"}
        ListElement {
            title: "BBC Radio Six Music";
            source: "https://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/hls/nonuk/sbr_low/ak/bbc_6music.m3u8"}
    }

    //Depending on which version of Qt we run on, bind an instance of Qt MediaPlayer6 or MediaPlayer5 to 'mediaPlayer'
    property var mediaPlayer: (Utils.qtVersionMajor() === 6)
                              ? Qt.createQmlObject(
                                    'import QtQuick; MediaPlayer6 { videoOutput: videoRender; }',
                                    app)
                              : Qt.createQmlObject(
                                    'import QtQuick 2.2; MediaPlayer5 { }',
                                    app);

    property string mediaFolder:    sourcesModel.get(sourceSelector.currentIndex).source;
    property string mediaBaseName: sourcesModel.get(sourceSelector.currentIndex).title;

    header: ToolBar {
        RowLayout {
            anchors.fill:            parent;
            /*Tool*/Button {
                text:                qsTr("Quit");
                onClicked:           Qt.quit();
                highlighted:         true;
            }
            /*Tool*/Button {
                text:                ((mediaPlayer.is_playing) ? "\u23F8" /*qsTr("Pause")*/ : "\u23EF" /*qsTr("Play")*/);
                onClicked:           play_pause();
                highlighted:         true;
            }
            Label {
                text:                 "Playback " + speedSlider.value.toLocaleString(locale, 'f', 2) + "x";
            }
            Slider {
                id:                     speedSlider;
//              enabled:                (mediaPlayer.duration > 0);
                from:                   0.1;                //minimum speed is 0.1x
                to:                     2.0;                //max is 2x
                value:                  1.0;                //default is unity gain.
                onValueChanged:         mediaPlayer.playbackRate = value;
                Layout.fillWidth:       true;
            }
            ComboBox {
                id: sourceSelector;
                textRole: "title";
                model: sourcesModel;
                Layout.fillWidth: true;
                onActivated: function (index) {
                    Qt.callLater(function () {
                        mediaPlayer.reset();
                        mediaPlayer.source = sourcesModel.get(index).source;
                        mediaPlayer.play();
                    });
                }
              }
        }
    }

    footer: Label {
        id:                  messageArea;
        elide:               Label.ElideRight;
        horizontalAlignment: Qt.AlignHCenter;
        verticalAlignment:   Qt.AlignVCenter;
        Layout.fillWidth:    true;
    }

    // the contentItem:
    Item {
        id:     contentArea;
        anchors.fill:         parent;
        anchors.margins:      Qt.application.font.pixelSize/2.0;
        implicitWidth:        app.width - Qt.application.font.pixelSize;
        implicitHeight:       app.height - Qt.application.font.pixelSize;

//        Image {
//            source:       mediaPlayer.metaDataCoverArtImage
//            x:            Qt.application.font.pixelSize/2;
//            y:            Qt.application.font.pixelSize/2;
//            width:        app.width - Qt.application.font.pixelSize;
//            height:       app.height - Qt.application.font.pixelSize;
//            z:1
//            onStatusChanged: console.log("image status=" + image.status)
//        }

      focus:                       true;

      Keys.onSpacePressed:         play_pause();
      Keys.onUpPressed:            seek(- 10000)
      Keys.onDownPressed:          seek(10000);
      Keys.onLeftPressed:          seek(- 1000);
      Keys.onRightPressed:         seek(1000);

      TapHandler {  onTapped: { console.log("item tapped"); play_pause(); } }
    }

    // For Qt6, due to gratuitous incompatible syntax and API changes,
    // must dynamically load version-dependent VidepOutput
    // (associated MediaPlayer is similarly dynloaded as topwin.mediaPlayer (see main_qqc2_sidepanel.qml)
    property var videoRender: (Utils.qtVersionMajor() === 6)
                ? Qt.createQmlObject(
                      'import QtQuick; import QtMultimedia; VideoOutput { anchors.fill: contentArea; }',
                      contentArea)
                : Qt.createQmlObject(
                      'import QtQuick 2.2; import QtMultimedia 5.6; VideoOutput { source:mediaPlayer; anchors.fill: contentArea; }',
                      contentArea);

    onClosing: function(close) { 
    	if (mediaPlayer.is_playing) {
            console.log("DEBUG: onClosing -- stopping media player & persisting current playback session...");
            mediaPlayer.stop();
            close.accepted = false;
            message("Application close aborted because media playing ... try closing again. ")
        }
        else {
            console.log("DEBUG: onClosing -- media stopped, accepting close.");
            close.accepted = true;
        }
    }


    //Use Timer{} to substitute for missing/removed functionality from Qt5 MediaPlayer -- notifyInterval: 20
    // Note when both timers are set we see that mediaplayer implicitly runs w/ notifyInterval at 100
    // and there's about 5 timer notifies per property notity and it correctly seems to support a
    // monotinically increasing position (.00 .02 .04 .06 .08, etc) at each subinterval....
    //    qml: position = 11.2990 seconds
    //    qml: tposition = 11.3000 seconds
    //    qml: tposition = 11.3200 seconds
    //    qml: tposition = 11.3400 seconds
    //    qml: tposition = 11.3600 seconds
    //    qml: tposition = 11.3800 seconds
    //    qml: position = 11.4000 seconds
    //    qml: tposition = 11.4010 seconds
    //    qml: tposition = 11.4200 seconds
    //    qml: tposition = 11.4410 seconds
    //    qml: tposition = 11.4610 seconds
    //    qml: tposition = 11.4810 seconds
    //    qml: position = 11.5000 seconds

    // works even for a 10ms timer:
    //    qml: position = 3.9710 seconds
    //    qml: tposition = 3.9740 seconds
    //    qml: tposition = 3.9840 seconds
    //    qml: tposition = 3.9940 seconds
    //    qml: tposition = 4.0040 seconds
    //    qml: tposition = 4.0140 seconds
    //    qml: tposition = 4.0240 seconds
    //    qml: tposition = 4.0340 seconds
    //    qml: tposition = 4.0440 seconds
    //    qml: tposition = 4.0530 seconds
    //    qml: tposition = 4.0640 seconds
    Timer {
        interval:    20; //update at 50fps
        repeat:      true;
        running:     mediaPlayer.is_playing;
        onTriggered: displayPlaybackInfo();
    }

    //at start-up, automatically load and play the default selection in 'sourceSelector',
    //which is the first entry in 'sourcesModel'.
    Component.onCompleted: {
        mediaPlayer.reset();
        mediaPlayer.source = sourcesModel.get(sourceSelector.currentIndex).source;
        mediaPlayer.play();
        contentArea.forceActiveFocus();
    }

    function message(txt)  { messageArea.text = txt }

    function play_pause() {
        if (mediaPlayer.is_playing)
            mediaPlayer.pause();
        else
            mediaPlayer.play();
    }

    function displayPlaybackInfo() {
        message((mediaPlayer.mediaInfo /*|| (mediaPlayer.is_playing && (mediaPlayer.position>0))*/) //replace initial "loading video" with metadata from media, once video loaded.
                    ? ((mediaPlayer.is_playing)
                       ? qsTr("Playing: ")
                       : qsTr("Paused: "))
                      + mediaPlayer.mediaInfo
                      + " -- "
                      + (mediaPlayer.position/1000).toLocaleString(locale, 'f', 4) + " seconds"
                    : ((mediaPlayer.hasVideo)       //mediaPlayer.hasVideo isn't set during loading, so use file extension to determine if video
                       ? qsTr("... Loading Video ...")
                       : qsTr("... Loading Media ...")));
    }

    //wrap/replace mediaPlayer.seek() which appears to be missing for Qt6. In addition to mediaPlayer.seek() functionality,
    //app.seek() forces GUI qnanopainteritem elements such as 'title, 'details' and 'ruler' to update the displayed position.
    property var seek: (Utils.qtVersionMajor() === 6)
                       ? function (pos) {
                           mediaPositionUpdate(pos);
                           mediaPlayer.position = pos; //Qt6 MediaPlayer missing seek() but allows mediaPlayer.position to be set directly
                       }
                       : function (pos) {
                           mediaPositionUpdate(pos);
                           mediaPlayer.seek(pos);    //Qt5 mediaPlayer.position is readonly, but seek() allows setting the position.
                       };


//    readonly property int   _CURSOR_RESOLUTION_MILLISECONDS_:                   500; //update ruler cursor every 0.5seconds
    function mediaPositionUpdate(pos) {
//         ruler.position = _CURSOR_RESOLUTION_MILLISECONDS_ * Math.round(pos / _CURSOR_RESOLUTION_MILLISECONDS_); //unlike title.position, the position needs to update even if inactive, e.g. for auto-skip functionality, and logging stop-point if background playback terminated by system, etc.
    }


    Connections {
        target: mediaPlayer;

        function onMediaInfoChanged() {
            console.log("MediaPlayer -- mediaInfo='" + mediaPlayer.mediaInfo + "'");
            displayPlaybackInfo();
        }

        function onMediaPlaying(is_playing) {
            Utils.keepScreenOn(is_playing);
            displayPlaybackInfo();
        }

        function onMediaCleared() {
            console.log("MediaPlayer -- waiting for new media...");
        }

        function onMediaLoading() {
            console.log("MediaPlayer -- loading media ...");
        }

        function onMediaLoaded() {
            console.log("MediaPlayer -- media loaded! " + mediaPlayer.mediaInfo);
        }

        function onMediaBuffering() {
            console.log("MediaPlayer -- media buffering...");
        }

        function onMediaStalled() {
            console.log("MediaPlayer -- stalled..." + mediaPlayer.mediaInfo);
        }

        function onMediaBuffered() {
            console.log("MediaPlayer -- buffered..." + mediaPlayer.mediaInfo);
            displayPlaybackInfo();
        }

        function onMediaEnded() {
            console.log("DEBUG: MediaPlayer.EndOfMedia hit for mediaInfo=\"" + mediaPlayer.mediaInfo
                        + "\" duration="                                     + mediaPlayer.duration
                        + " position="                                       + mediaPlayer.position);
            message("MediaPlayer -- stopped at end... " + mediaPlayer.mediaInfo);
            if (mediaPlayer.is_playing)
                mediaPlayer.pause();
        }

        function onMediaInvalid() {
            message("MediaPlayer -- invalid media!");
        }

    } //end: Connections { target: mediaPlayer; ... }
}
