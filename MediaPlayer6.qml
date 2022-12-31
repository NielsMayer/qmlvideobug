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

//Qt6 unified API subclass of QtMultimMedia MediaPlayer

import QtQuick 2.9;
import QtMultimedia 6.2; //Qt6 QtMultimMedia

MediaPlayer {

    audioOutput:
        AudioOutput {
            id:           audioRender;
        }

    //create a consistent API versus Qt5 version. Qt6 moved "volume" to "audioRender.volume"
    //causing gratuitous breakage. This alias prevents that breakage so that Qt5 API
    //"mediaPlayer.volume" can be used independent of Qt version (e.g. in PageMediaFile).
    property alias volume: audioRender.volume;

//    autoPlay: true;
//    volume: 1.0;

    // update position 15 times per second...
    // this feature needs QtMultimedia>=5.9, main reason why separate LinuxMediaPlayer.qml is needed,
    // to accomodate lack of this feature in Qt 5.6
    //notifyInterval: 66;

//Commented out for-Qt6: replace with Timer and signal/slot that it calls to update 'mediaPlayer.position'
//which was done declaratively in Qt5..

//    notifyInterval: (app.isAppActive)
//                    ? ( (   app.want_beat_animation
//                         || app.want_mzspectralflux_thresholdfunction
//                         || app.want_mzspectralflux_spectralfluxonsets
//                         || app.want_mzpowercurve_smoothpowerslope
//                         || app.want_mzpowercurve_powerslopeproduct)
//                       ? 20  //update at 50 fps for waveforms and beat animation.
//                       : 66) //update at 15 fps min otherwise when active/focused
//                    : 200;   //update at 5 fps when inactive/out of focus.

// Commented out for Qt6 because removed from API....
//    audioRole: (hasVideo)
//               ? MediaPlayer.VideoRole
//               : MediaPlayer.MusicRole;

    readonly property bool is_playing: (playbackState === MediaPlayer.PlayingState);
    signal mediaPlaying(bool is_playing);
    onIs_playingChanged: mediaPlaying(is_playing);

    //Desiring mediaPlayer.localMetaData to be scoped inside the mediaplayer subclass (aka this file)...
    //but ListModel{} doesn't like being parented by MediaPlayer, so create it dynamically, and parented by 'app'
    //doing ListModel{id:localMetadata; dynamicRoles:true} in place of this property gives error:
    //"Cannot assign to non-existent default property"
    property var localMetadata: Qt.createQmlObject(
                                    'import QtQuick; import QtQml.Models; ListModel { dynamicRoles: true; }',
                                    app);


    //because the new Qt6 mediaPlayer.metaData is nearly impossible to use, perhaps due to bugs,
    //make a more-easy-to-use duplicate of those values inside a ListModel...
    property string _metadata_title; //:           metaData.stringValue(MediaMetaData.Title);
    on_Metadata_titleChanged:                      console.log("DEBUG: Qt6 MediaPlayer Title=" + _metadata_title);
    property string _metadata_albumTitle; //:      metaData.stringValue(MediaMetaData.AlbumTitle);
    on_Metadata_albumTitleChanged:                 console.log("DEBUG: Qt6 MediaPlayer AlbumTitle=" + _metadata_albumTitle);
    property string _metadata_author; //:          metaData.stringValue(MediaMetaData.Author);
    on_Metadata_authorChanged:                     console.log("DEBUG: Qt6 MediaPlayer Author=" + _metadata_author);
    property string _metadata_contributingArtist;//:metaData.stringValue(MediaMetaData.ContributingArtist);
    on_Metadata_contributingArtistChanged:         console.log("DEBUG: Qt6 MediaPlayer ContributingArtist=" + _metadata_contributingArtist);
    property string _metadata_albumArtist; //:     metaData.stringValue(MediaMetaData.AlbumArtist);
    on_Metadata_albumArtistChanged:                console.log("DEBUG: Qt6 MediaPlayer AlbumArtist=" + _metadata_albumArtist);
    property string _metadata_leadPerformer; //:   metaData.stringValue(MediaMetaData.LeadPerformer);
    on_Metadata_leadPerformerChanged:              console.log("DEBUG: Qt6 MediaPlayer LeadPerformer=" + _metadata_leadPerformer);
    property string _metadata_Url; //:             metaData.value(MediaMetaData.Url);
    on_Metadata_UrlChanged:                        console.log("DEBUG: Qt6 MediaPlayer Url=" + _metadata_Url);
    property string _metadata_ContainerFormat; //: metaData.value("ContainerFormat");
    on_Metadata_ContainerFormatChanged:            console.log("DEBUG: Qt6 MediaPlayer ContainerFormat=" + _metadata_ContainerFormat);
    property variant _metadata_coverArtImage; //:  metaData.stringValue(MediaMetaData.CoverArtImage);
    on_Metadata_coverArtImageChanged:              console.log("DEBUG: Qt6 MediaPlayer CoverArtImage=" + _metadata_coverArtImage);
    property variant _metadata_thumbnailImage; //: metaData.stringValue(MediaMetaData.ThumbnailImage);
    on_Metadata_thumbnailImageChanged:             console.log("DEBUG: Qt6 MediaPlayer ThumbnailImage=" + _metadata_thumbnailImage);
    property string _metadata_videoCodec; //:      metaData.stringValue(MediaMetaData.VideoCodec);
    on_Metadata_videoCodecChanged:                 console.log("DEBUG: Qt6 MediaPlayer VideoCodec=" + _metadata_videoCodec);
    property int _metadata_videoBitRate; //:       metaData.value(MediaMetaData.VideoBitRate);
    on_Metadata_videoBitRateChanged:               console.log("DEBUG: Qt6 MediaPlayer VideoBitRate=" + _metadata_videoBitRate);
    property real _metadata_videoFrameRate; //:    metaData.value(MediaMetaData.VideoFrameRate);
    on_Metadata_videoFrameRateChanged:             console.log("DEBUG: Qt6 MediaPlayer VideoFrameRate=" + _metadata_videoFrameRate);
    property string _metadata_resolution; //:      metaData.value(MediaMetaData.Resolution);
    property string _metadata_mediaType;   //:     metaData.value(MediaMetaData.MediaType);
    on_Metadata_resolutionChanged:                 console.log("DEBUG: Qt6 MediaPlayer Resolution="+ _metadata_resolution);
    property string _metadata_audioCodec; //:      metaData.stringValue(MediaMetaData.AudioCodec);
    on_Metadata_audioCodecChanged:                 console.log("DEBUG: Qt6 MediaPlayer AudioCodec=" + _metadata_audioCodec);
    property int _metadata_audioBitRate; //:       metaData.value(MediaMetaData.AudioBitRate);
    on_Metadata_audioBitRateChanged:               console.log("DEBUG: Qt6 MediaPlayer AudioBitRate=" + _metadata_audioBitRate);

    onMetaDataChanged: /*function(metaData)*/ { //NB: due to bug with Qt6.2.1 QtMultiMedia using 6.2's "function(metaData){}" and/or (metaData)=>{} syntax results in this code never being called. Using old-fashion (Qt5) implicit function and parameters seems to work, however.
        for (var key of metaData.keys()) {
            var keystr = metaData.metaDataKeyToString(key);
            switch (keystr) {
            case 'Title':
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: _metadata_title = metaData.stringValue(key)});
                break;
            case 'Album title':
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: _metadata_albumTitle = metaData.stringValue(key)});
                break;
            case 'Author':
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: _metadata_author = metaData.stringValue(key)});
                break;
            case 'Contributing artist':
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: _metadata_contributingArtist = metaData.stringValue(key)});
                break;
            case 'Album artist':
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: _metadata_albumArtist = metaData.stringValue(key)});
                break;
            case 'Lead performer': //used by YouTube?
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: _metadata_leadPerformer = metaData.stringValue(key)});
                break;
            case 'Url':
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: _metadata_Url = metaData.stringValue(key)});
                break;
            case 'Container Format':
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: _metadata_ContainerFormat = metaData.stringValue(key)});
                break;
            case 'Cover art image': //CoverArtImage defined as type QImage in https://doc.qt.io/qt-6/qmediametadata.html
                localMetadata.append({ keystr: keystr, keyid: key, //but, _metadata_coverArtImage is set to QVariant(QImage, QImage(QSize(1200, 675),format=QImage::Format_RGB32,depth=32,devicePixelRatio=1,bytesPerLine=4800,sizeInBytes=3240000))
                                         value: _metadata_coverArtImage = metaData.value(key)});
                break;
            case 'Thumbnail image': //ThumbnailImage defined as type QImage in https://doc.qt.io/qt-6/qmediametadata.html
                localMetadata.append({ keystr: keystr, keyid: key, //but, _metadata_thumbnailImage is set to QVariant(QImage(...))
                                         value: _metadata_thumbnailImage = metaData.value(key)});
                break;
            case 'Audio codec':
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: _metadata_audioCodec = metaData.stringValue(key)});
                break;
            case 'Audio bit rate':
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: _metadata_audioBitRate = parseInt(metaData.value(key))});
                break;
            case 'Video codec':
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: _metadata_videoCodec = metaData.stringValue(key)});
                break;
            case 'Video bit rate':
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: _metadata_videoBitRate = parseInt(metaData.value(key))});
                break;
            case 'Video frame rate': //VideoFrameRate defined as type qreal in https://doc.qt.io/qt-6/qmediametadata.html
                localMetadata.append({ keystr: keystr, keyid: key, //...which is why parseFloat() is used.
                                         value: _metadata_videoFrameRate = parseFloat(metaData.value(key))});
                break;
            case 'Resolution':       //Resolution defined as type QSize in https://doc.qt.io/qt-6/qmediametadata.html
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: _metadata_resolution = metaData.stringValue(key)}); //TODO parse "HHH x WWW" as a tuple (HHH,WWW) rather than string?
                break;
            case 'Media type':
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: _metadata_mediaType = metaData.stringValue(key)});
                break;
            case 'Date':
            case 'Language':
            case 'Comment':
            case 'Genre':
            case 'Description':
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: metaData.stringValue(key)});
                break;
            case 'Track number':
            case 'Duration':
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: parseInt(metaData.value(key))});
                break;
            default:
                localMetadata.append({ keystr: keystr, keyid: key,
                                         value: metaData.stringValue(key)});

                //for debug, print out additional unrecognized metadata items.
                if (metaData.stringValue(key)) {
                    console.log("DEBUG: "
                                + metaData.metaDataKeyToString(key)
                                + " .... "
                                +  metaData.stringValue(key));
                }
                else {
                    console.log("DEBUG: "
                                + metaData.metaDataKeyToString(key)
                                + " ..?.. "
                                +  metaData.value(key));
                }
            }
        }
    }

    //"mediaPlayer.artist" is part of the TS:MediaPlayer "API" and is referenced in Trainspodder.qml
    readonly property string artist: (_metadata_author || _metadata_albumArtist || _metadata_leadPerformer || _metadata_albumTitle || _metadata_contributingArtist)
                                     ? (_metadata_author || _metadata_albumArtist || _metadata_leadPerformer || _metadata_albumTitle || _metadata_contributingArtist)
                                     : app.mediaFolder;

    onArtistChanged:         if (artist)
                                console.log("DEBUG: mediaPlayer.artist='" + artist + "' ...");

    //"mediaPlayer.title" is part of the TS:MediaPlayer "API" and is referenced in Trainspodder.qml
    readonly property string title:
        (    ((_metadata_author || _metadata_albumArtist || _metadata_leadPerformer || _metadata_albumTitle || _metadata_contributingArtist)
          &&  (_metadata_title || _metadata_albumTitle)))
        ? qsTr("%1 - %2")
          .arg(_metadata_author || _metadata_albumArtist || _metadata_leadPerformer || _metadata_albumTitle || _metadata_contributingArtist)
          .arg(_metadata_title || _metadata_albumTitle)
        : (_metadata_title || _metadata_albumTitle || _metadata_author || _metadata_albumArtist || _metadata_leadPerformer || _metadata_contributingArtist)
          ? qsTr("%1").arg((_metadata_title || _metadata_albumTitle || _metadata_author || _metadata_albumArtist || _metadata_leadPerformer || _metadata_contributingArtist))
          : app.mediaBaseName; //in case the above fails

    onTitleChanged:         if (title)
                                console.log("DEBUG: mediaPlayer.title='" + title + "'");

//    property variant coverart; /*:               _metadata_coverArtUrlLarge
//                                                 || _metadata_coverArtUrlSmall
//                                                || _metadata_posterURL;*/
////  onCoverartChanged:                       console.log("DEBUG: Qt6 MediaPlayer coverart=" + coverart);

    readonly property string mediaInfo:
        (hasVideo) // video case
        ? ((_metadata_videoCodec && _metadata_videoBitRate)
           ? qsTr("%L2kbps - %1").arg(_metadata_videoCodec).arg((_metadata_videoBitRate/1000).toFixed())
           : (_metadata_videoCodec && _metadata_resolution && _metadata_videoFrameRate)
             ? qsTr("%2 @ %L3fps - %1").arg(_metadata_videoCodec).arg(_metadata_resolution).arg(_metadata_videoFrameRate.toFixed())
             : ""
               || (_metadata_videoCodec && _metadata_resolution)
               ? qsTr("%2 - %1").arg(_metadata_videoCodec).arg(_metadata_resolution)
               : ""
                 || (_metadata_mediaType && _metadata_resolution)
                 ? qsTr("%2 - %1").arg(_metadata_mediaType).arg(_metadata_resolution)
                 : ""
                   || (_metadata_resolution)
                   ? qsTr("%1").arg(_metadata_resolution)
                   : ""
                     || (_metadata_videoBitRate)
                     ? qsTr("%L1kbps").arg((_metadata_videoBitRate/1000).toFixed())
                     : ""
                       || (_metadata_videoCodec && (_metadata_videoCodec !== 'Invalid')) //don't display when videoCodec returns "Invalid" (e.g. Odysee/Lbry stream).
                       ? qsTr("%1").arg(_metadata_videoCodec)
                       : ""
                         || (_metadata_mediaType)
                         ? qsTr("%1").arg(_metadata_mediaType)
                         : ""
//                           || (_metadata_videoCodec && (_metadata_videoCodec === 'Invalid')) //if "Invalid" videoCodec is all we get (e.g. Odysee/Lbry stream) then display "Video" as fallback.
//                           ? qsTr("Video")
//                           : ""
           )
          //audio case
        : (_metadata_audioCodec && _metadata_audioBitRate)
          ? qsTr("%L2kbps - %1").arg(_metadata_audioCodec).arg((_metadata_audioBitRate/1000).toFixed())
          : ""
            || (_metadata_mediaType && _metadata_audioBitRate)
            ? qsTr("%L2kbps - %1").arg(_metadata_mediaType).arg((_metadata_audioBitRate/1000).toFixed())
            : ""
              || (_metadata_audioBitRate)
              ? qsTr("%L1kbps").arg((_metadata_audioBitRate/1000).toFixed())
              : ""
                || (_metadata_mediaType)
                ? qsTr("%1").arg(_metadata_mediaType)
                : ""
                  || (_metadata_audioCodec && (_metadata_audioCodec !== 'Invalid')) ////don't display when audioCodec returns "Invalid" (e.g. Mixcloud HQ extracted MPD stream).
                  ? qsTr("%1").arg(_metadata_audioCodec)
                  : "";

    onErrorOccurred: (error, errorString) => {
        console.error("DEBUG: Qt6 MediaPlayer ErrorOccurred! error=" + error + " errorString=" + errorString);
        if (errorString === 'Forbidden')  {
            mediaPlayer.pause();   //mediaPlayer.isPlaying is still true even after error condition stopping playback.
                                   //TODO: as special-case, should also 'grey out' the resulting "play" button if displayed.
            app.message("MediaPlayer access forbidden: " + errorString);
        }
        else {
            mediaPlayer.pause();        //mediaPlayer.isPlaying is still true even after error condition stopping playback.
                                        //TODO: as special-case, should also 'grey out' the resulting "play" button if displayed.
            app.message("MediaPlayer internal error: " + errorString);
        }

    }

    signal mediaCleared();
    signal mediaLoading();
    signal mediaLoaded();
    signal mediaBuffering();
    signal mediaStalled();
    signal mediaBuffered();
    signal mediaEnded();
    signal mediaInvalid();

    onMediaStatusChanged: {             // was ".onStatusChanged" in Qt5, renamed to ".onMediaStatusChanged" in Qt6
         switch (mediaStatus) {         // was ".status" in Qt5, renamed to ".mediaStatus" in Qt6 (NB: ".status" still works in Qt6)
         case MediaPlayer.NoMedia:      // - no media has been set.
             mediaCleared();
             break;
         case MediaPlayer.Loading:      // - the media is currently being loaded.
             mediaLoading();
             break;
         case MediaPlayer.Loaded:       // - the media has been loaded.
             mediaLoaded();
             break;
         case MediaPlayer.Buffering:    // - the media is buffering data.
             mediaBuffering();
             break;
         case MediaPlayer.Stalled:        // - playback has been interrupted while the media is buffering data.
             mediaStalled();
             break;
         case MediaPlayer.Buffered:     // - the media has buffered data.
             mediaBuffered();
             break;
         case MediaPlayer.EndOfMedia:   // - the media has played to the end. --> persist the position/info to filesystem at the time playback stopped.
             mediaEnded();
             break;
         case MediaPlayer.InvalidMedia: // - the media cannot be played.
             mediaInvalid();
             break;
         case MediaPlayer.UnknownStatus:// - the status of the media is unknown.
	     console.log("MediaPlayer -- unknown status?");
             app.timedMessage("MediaPlayer -- unknown status?");
             break;
         }
     }

    // called out of app.reset(), this clears all internal state.
    function reset() {
        stop();
        localMetadata.clear();
        source /*= coverart = title*/
                = _metadata_title
                = _metadata_albumTitle
                = _metadata_author
                = _metadata_contributingArtist
                = _metadata_albumArtist
                = _metadata_leadPerformer
                = _metadata_Url
                = _metadata_ContainerFormat
                = _metadata_coverArtImage
                = _metadata_thumbnailImage
                = _metadata_videoCodec
                = _metadata_resolution
                = _metadata_mediaType
                = _metadata_audioCodec
                = "";
        _metadata_audioBitRate
                = _metadata_videoBitRate
                = _metadata_videoFrameRate
                = 0;
        //this happens automatically in MediaPlayer on resetting mediaPlayer.source...
//      volume
//              = playbackRate
//              = 1.0;
    }
}
