#!/bin/sh
# FFMPEG streaming script
# Things to be tweaked:
# framerate should be 15 for programming/screencasts, maybe 30+ for games
# audio-rate should be 44.1khz to work in flv
# crf can change, maxrate depends on your upload speed. bufsize is maxrate*num of secs to buff
# the tee output allows you to have multiple outputs, here it's a local file
# and a stream
# -g option should be framerate/2 for youtube
# b:a can change depending on if it is human speech (32,48,64) or music (96,128,...)
# ac can change depending if it's voice (mono ok, ac 1) or game (probably want stereo)

# Change pulse mic  volume to 30%
# route mic input to ffmpeg in pavucontrol
# use Stream gnome-terminal profile, DejaVu Sans Mono, 14pt

# Youtube Live Recommended Settings:
# LIVE STREAMING GUIDE
# Live encoder settings, bitrates and resolutions
# Video resolution
#
# Protocol:   RTMP Flash Streaming
# Video codec:    H.264, 4.1
# Frame rate: up to 60 fps
# Keyframe frequency: do not exceed 2 seconds
# Audio codec:    AAC or MP3
# Bitrate encoding:   CBR
# Recommended advanced settings
# Pixel aspect ratio: Square
# Frame types:    Progressive Scan, 2 B-Frames, 1 Reference Frame
# Entropy coding: CABAC
# Audio sample rate:  44.1 KHz
# Audio bitrate:  128 Kbps stereo


# Make sure to copy latest rtmp url/key from youtube's my live event page
RTMPURL="rtmp://a.rtmp.youtube.com/live2/"
LOCALNAME=`date | sed "s/[^A-Za-z0-9]\+/_/g"`

ffmpeg \
    -f alsa -i pulse \
    -f x11grab -framerate 15 -video_size 1366x768 -i :0.0+0,0 \
    -vcodec libx264 -preset slow -crf 19 -maxrate 3000k -bufsize 6000k -vf "scale=1280:-1,format=yuv420p" -profile:v high -level 4.1 -bf 2 -refs 1 -g 30  \
    -acodec libmp3lame -b:a 128k -ar 44100 \
    -f tee -map 0:a:0 -flags +global_header -map 1:v -flags +global_header \
    "[f=flv]$LOCALNAME.flv|[f=flv]$RTMPURL"