Welcome to RealTITracker v0.2
=============================

RealTITracker (Real-Time Image-based Tracker) is a free software written in C++, optimised for multi-CPU architecture and available on Linux and Windows platforms. The software consists of a collection of fast optical flow algorithms that are commonly used to solve real-time 2D/3D image registration problems.

The RealTItracker toolbox is a Matlab software based on C++ Mex-Functions compiled for Linux 64-bit (GLIBC version of 2.13 or newer is required) and Windows 64 bit. The Open Source POSIX threads library for Microsoft Windows was employed to cope with multi-CPU architectures on Windows platforms. The licence of POSIX threads library for Microsoft Windows is available here: https://www.sourceware.org/pthreads-win32/copying.html

A Matlab interface is provided to quickly configure, test, and integrate optical-flow registration methods in a specific application. The following Matlab sample codes are included in the archive:
- "test_RTTracker_2D.m": Perform 2D motion estimation/registration on dynamically acquired MR-images.
- "test_RTTracker_2D_multislice.m": Perform 2D motion estimation/registration on multislice MR-images acquired dynamically.
- "test_RTTracker_3D.m" => Perform 3D motion estimation/registration on 3D MR-images.

The subdirectory "./Data/" contains some sample data-sets.

The author underlines that RealTITracker has been developped for academic purpose only. The authors disclaim any responsability for any potential damage caused by the RealTITracker toolbox.

Additional informations can be found in the homepage of RealTITracker (http://bsenneville.free.fr/RealTITracker/). It contains sample codes, data-sets, as well as additional informations about the algorithm implementation, the accuracy of the motion estimation process and how the performance was assessed.
