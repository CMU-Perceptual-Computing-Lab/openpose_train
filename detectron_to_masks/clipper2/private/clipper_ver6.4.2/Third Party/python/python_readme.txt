
The clipper.py file included in this distribution contains a **very old** version of Clipper.

clipper.py was really just an exercise to teach myself Python and I realised very quickly that it wouldn't be possible for me to maintain 4 parallel translations of Clipper while I continued to improve it. Also, given that the Python code is about 100 times slower than compiled versions of Clipper, I would recommend compiling Clipper and wrapping it in a Python extension (see below).

Pyclipper: a Python package that provides an interface to the C++ compiled Clipper Library.
https://pypi.python.org/pypi/pyclipper
https://github.com/greginvm/pyclipper

A much older Python package can be found here:
https://sites.google.com/site/maxelsbackyard/home/pyclipper

