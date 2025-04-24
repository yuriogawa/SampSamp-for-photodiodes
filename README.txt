 _____                       _____                       
/  ___|                     /  ___|                      
\ `--.  __ _ _ __ ___  _ __ \ `--.  __ _ _ __ ___  _ __  
 `--. \/ _` | '_ ` _ \| '_ \ `--. \/ _` | '_ ` _ \| '_ \ 
/\__/ / (_| | | | | | | |_) /\__/ / (_| | | | | | | |_) |
\____/ \__,_|_| |_| |_| .__/\____/ \__,_|_| |_| |_| .__/ 
                      | |                         | |    
                      |_|                         |_|    

-- Requires Windows 10 and at least MATLAB 2021a --

SAMPSAMP is a data acquisition program that connects to National Instruments (NI) hardware, recording and displaying data in real-time in conjunction with a photo-diode light based trigger.

To run this program you will either need a full liscence of MATLAB or MATLAB runtime, with the Data Acquisition (DAQ) Toolbox installed.

The gui can be opened by running 'sampsamp' in the Command Window. 

Version History:

--- 2.1 ---
* Added a conversion script that converts the data output from SampSamp into a format useable by LabView
* Fixed issue with saving timestamps in incorrect format
* Fixed potential issue with 'dir' being used as variable name
* Added version info and sampling rate used to data output 

--- 2.0 ---
* Full update of SampSamp backend to bring it from Matlab 2009 to Matlab 2024b
* Added new parameter to edit the max size of a data block before a new one is created, improving stability of recording
* Handling of DAQ changed to instead use a FIFO buffer to optimise code and reduce risk of crash during recording
* How 'No Trigger' option saves data is changed to instead create new data blocks over time instead of one giant block
* Removed reduntant GUI features that had no code written for them to reduce clutter
