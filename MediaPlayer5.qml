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

//Qt5 unified API subclass of QtMultimMedia MediaPlayer

import QtQuick 2.9;
import QtMultimedia 5.9; //5.9 is earliest version supporting 'notifyInterval'

MediaPlayer {
//  autoPlay: true;   //for compatibility with Qt6, autoPlay is off, and app-specific mechanism is used instead.
    volume: 1.0;

    notifyInterval: 100 //to be consistent with internal setting in Qt6 which doesn't support this property.

    audioRole: (hasVideo)
               ? MediaPlayer.VideoRole
               : MediaPlayer.MusicRole;

    readonly property bool is_playing: (playbackState === MediaPlayer.PlayingState);
    signal mediaPlaying(bool is_playing);
    onIs_playingChanged: mediaPlaying(is_playing);

    //Desiring mediaPlayer.localMetaData to be scoped inside the mediaplayer subclass (aka this file)...
    //but ListModel{} doesn't like being parented by MediaPlayer, so create it dynamically, and parented by 'app'
    //doing ListModel{id:localMetadata; dynamicRoles:true} in place of this property gives error:
    //"Cannot assign to non-existent default property"
    //Note this is currently a partial implementation for Qt5 mediaPlayer, in order to have consistent API
    //with the Qt6 mediaPlayer in MediaPlayer6.qml ... mediaPlayer.localMetadata will be empty and ignored for Qt5.
    //betweeen Qt5&Qt6 to allow relevant media metdata to be displayed in the Media Info panel.
    //See PageMediaInfo.qml for GUI populating a page with this retrieved metaData information.
    //see "localMetadata.append({ keystr:"...", value: "..." });" below for calls populating this model.
    //cleared by reset()
    property var localMetadata: Qt.createQmlObject(
                                    'import QtQuick 2.2; import QtQml.Models 2.2; ListModel { dynamicRoles: true; }',
                                    app);

    //"mediaPlayer.artist" is part of the TS:MediaPlayer "API" and is referenced in Trainspodder.qml and RemoteControlLinux.qml
    readonly property string artist: ((metaData.author !== undefined) && (typeof(metaData.author) === 'string') && (metaData.author))
                                     ? metaData.author
                                     : app.mediaFolder;
    onArtistChanged:                     if (artist) {
                                             console.log("DEBUG: mediaPlayer.artist='" + artist + "' ...");
                                             localMetadata.append({ keystr: "Artist", value: artist });
                                         }
    //"mediaPlayer.title" is part of the TS:MediaPlayer "API" and is referenced in Trainspodder.qml and RemoteControlLinux.qml
    readonly property string title: (   ((metaData.author !== undefined) && (typeof(metaData.author) === 'string') && (metaData.author))
                                     && ((metaData.title  !== undefined) && (typeof(metaData.title ) === 'string') && (metaData.title)))
                                    ? qsTr("%1 - %2").arg(metaData.author).arg(metaData.title)
                                    : metaData.title || metaData.author || app.mediaBaseName
    onTitleChanged:                      if (title) {
                                             console.log("DEBUG: mediaPlayer.title='" + title + "'");
                                             localMetadata.append({ keystr: "Title", value: title });
                                         }
    readonly property bool   mediaInfoVideoCodecValid:   (metaData.videoCodec !== undefined) && (typeof(metaData.videoCodec) === 'string');
    onMediaInfoVideoCodecValidChanged:   if (mediaInfoVideoCodecValid) {
                                             console.log("videoCodec: " + metaData.videoCodec);
                                             localMetadata.append({ keystr: "Video Codec", value: metaData.videoCodec });
                                         }
    readonly property bool   mediaInfoVideoBitrateValid: (typeof(metaData.videoBitRate) === 'number');
    onMediaInfoVideoBitrateValidChanged: if (mediaInfoVideoBitrateValid) {
                                             console.log("videoBitRate: " + metaData.videoBitRate);
                                             localMetadata.append({ keystr: "Video BitRate", value: metaData.videoBitRate });
                                         }
    readonly property bool   mediaInfoAudioCodecValid:   (metaData.audioCodec !== undefined) && (typeof(metaData.audioCodec)   === 'string');
    onMediaInfoAudioCodecValidChanged:   if (mediaInfoAudioCodecValid) {
                                             console.log("audioCodec: " + metaData.audioCodec);
                                             localMetadata.append({ keystr: "Audio Codec", value: metaData.audioCodec });
                                         }
    readonly property bool   mediaInfoAudioBitrateValid: (typeof(metaData.audioBitRate) === 'number');
    onMediaInfoAudioBitrateValidChanged: if (mediaInfoAudioBitrateValid) {
                                             console.log("audioBitRate: " + metaData.audioBitRate);
                                             localMetadata.append({ keystr: "Audio BitRate", value: metaData.audioBitRate });
                                         }
    readonly property string mediaInfo:
            (hasVideo) // video case
            ? ((mediaInfoVideoCodecValid && mediaInfoVideoBitrateValid)
               ? qsTr("%1 - %L2kb/s").arg(metaData.videoCodec).arg((metaData.videoBitRate/1000).toFixed(0))
               : (mediaInfoVideoCodecValid)
                 ? qsTr("%1").arg(metaData.videoCodec)
                 : ""
                   || (mediaInfoVideoBitrateValid)
                   ? qsTr("%L1kb/s").arg((metaData.videoBitRate/1000).toFixed(0))
                   : "")
            //audio case
            : (mediaInfoAudioCodecValid && mediaInfoAudioBitrateValid)
              ? qsTr("%1 - %L2kb/s").arg(metaData.audioCodec).arg((metaData.audioBitRate/1000).toFixed(0))
              : (mediaInfoAudioCodecValid)
                ? qsTr("%1").arg(metaData.audioCodec)
                : ""
                  || (mediaInfoAudioBitrateValid)
                  ? qsTr("%L1kb/s").arg((metaData.audioBitRate/1000).toFixed(0))
                  : "";

    //TODO: commented out because not used, and also their API is inconsistent with the new Qt6MultiMedia implementation.
    //YES-BUT: not shared by Qt6 MediaPlayer "api" and also not used by 'app' so commented out:
//    readonly property variant coverartImage: metaData.coverartImage;
//    readonly property variant coverart:      metaData.coverArtUrlLarge;
//    readonly property variant coverartIcon:  metaData.coverArtUrlSmall;
//    readonly property variant poster:        metaData.posterUrl;
//    onCoverartImageChanged: if ((coverartImage !== undefined) && coverartImage)
//                                console.log("MediaPlayer Cover art image: " + coverartImage);
//    onCoverartChanged:      if ((coverart !== undefined) && coverart)
//                                console.log("MediaPlayer Cover art URL: " + coverart);
//    onCoverartIconChanged:  if ((coverartIcon !== undefined) && coverartIcon)
//                                console.log("MediaPlayer Cover art icon URL: "  + coverartIcon);
//    onPosterChanged:        if ((poster !== undefined) && poster)
//                                console.log("MediaPlayer Cover art poster URL: " + poster);
//    onError: console.error("error with audio " + error);

    onErrorStringChanged:   {
        if (errorString === 'Forbidden')  {
            if (app.mediaRetries >= 0) {        //prevent infinite loop -- app.mediaRetries initialized to 4 in setMedia() for non 'failedToPlay' case
                app.mediaStop();
                app.timedMessage("MediaPlayer retrying, retries=" + app.mediaRetries)
                console.log("DEBUG MediaPlayerNew#onErrorStringChanged: stopped and retrying media on error at lastPosition="
                            + app.lastPosition
                            + " lastMedia="
                            + app.lastMedia
                            + " mediaRetries="
                            + app.mediaRetries);
                app.setMedia(app.lastMedia, app.lastPosition, true);
                app.mediaRetries--;            //different levels of retry, e.g. 1, 2, 3, 4 try successively lower bitrates, e.g. to work around geo-ip based blockage of high sample rate tracks like for BBC see Trainspodder#setMediaFromBBCJSON()
            }
        }
        else
	    mediaPlayer.pause();   //mediaPlayer.isPlaying is still true even after error condition stopping playback.
                                   //TODO: as special-case, should also 'grey out' the resulting "play" button if displayed.
            app.message("MediaPlayer internal error: " + errorString);

    }

    signal mediaCleared();
    signal mediaLoading();
    signal mediaLoaded();
    signal mediaBuffering();
    signal mediaStalled();
    signal mediaBuffered();
    signal mediaEnded();
    signal mediaInvalid();

    onStatusChanged: {
        switch (status) {
        case MediaPlayer.NoMedia: // - no media has been set.
            mediaCleared();
            break;
        case MediaPlayer.Loading: // - the media is currently being loaded.
	    mediaLoading();
            break;
        case MediaPlayer.Loaded: // - the media has been loaded.
            mediaLoaded();
            break;
        case MediaPlayer.Buffering: // - the media is buffering data.
	    mediaBuffering();
            break;
        case MediaPlayer.Stalled: // - playback has been interrupted while the media is buffering data.
            mediaStalled();
            break;
        case MediaPlayer.Buffered: // - the media has buffered data.
	    mediaBuffered();
            break;
        case MediaPlayer.EndOfMedia:   // - the media has played to the end. --> persist the position/info to filesystem at the time playback stopped.
	    mediaEnded();
            break;
        case MediaPlayer.InvalidMedia: // - the media cannot be played.
            mediaInvalid();
            break;
        case MediaPlayer.UnknownStatus: // - the status of the media is unknown.
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
                = "";
    }
}
