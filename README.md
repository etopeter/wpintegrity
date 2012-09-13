wpintegrity.sh
=============


Description
-----------

wpintegrity.sh is a simple bash script created to perform integrity check of files on remote host.
Script makes use of 2 tools:
   1. mtree
   2. diff

   It checks first if remote host has mtree installed. If it does it creates hash file and downloads it.
Second time you run the script it will compare 2 hashes and display results.
   If remote host doesnt have mtree installed it will perform full folder backup and download the file.
Then it will uncompress the content and perform mtree localy.


Runtime Requirements
--------------------
   mtree
   scp
   ssh
   tar


Version 1.0 - Initial version.



Copyright (c) 2012

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

