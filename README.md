# MACS (Matlab Audio Creation Suite)

## What Is MACS?
MACS is an extremely stripped down version of Apple's GarageBand recreated in Matlab. It comes equipped with 4 programmable audio tracks, each of which is capable of holding 8 4 second audio loops. Several instruments can be selected, but there can only be one used per track. Tracks can be muted, played individually, cleared, or played together via drop-down menus and toggles within the MACS GUI. And that's really about it......oh....track inputs are controlled via an 3-way accelerometer and arduino, which is visualized by a 3D plot in the bottom left of the GUI. 

## Why Was This MACS?
This project was a made in response to a university course that was heavily based in Matlab. Students were required to design a Matlab program that could interface with an accelerometer in real-time. We were also discouraged from making games, which is how we came up with MACS. 

## Is MACS Practical Or Useful In Any Way?
To be perfectly honest, no it isn't. There are many other professional and free programs that accomplish what MACS does in far better and less limited ways. MACS is more of a labor of love and frustration created in a total 3 very long days.

## What Do I Need To Use MACS?
MACS was written for Matlab 2015b and has not been tested with any other Matlab version, so version 2015b is a requirement due to some of the design decisions made.
You will also need an Arduino with a 3-way analog accelerometer loaded with the provided arduino code.

## How Do I Use MACS?
MACS is actually quite easy to use simple download with repository and run the "Music.m" file, this will launch the MACS GUI. From here you will need to connect your arduino to one of your computer's USB ports and click the "Initialize Connection" button in the top left hand corner of the GUI. You will then be walked through several steps to calibrate the accelerometer. After completing the calibration, you're ready to start using MACS. 

###	Additional Information 
-  Instruments are selected on a per track basis.
 - Tracks are individually recorded, muted, and cleared their corresponding menu.
 - The X and Y components of the accelerometer control what loop will be selected for the current track index. While Z component, allows you to move the track index forward or back, this allows for correction of mistakes and addition of rests within a track.
 - The "Play All" button will play all tracks.
