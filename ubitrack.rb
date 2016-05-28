class UbitrackDownloadStrategy < GitDownloadStrategy
  def submodules?
    cached_location.join(".gitmodules-disabled").exist?
  end
end


class Ubitrack < Formula
  desc "The UbiTrack Framework from TUM/FAR"
  homepage "http://campar.in.tum.de"
  version "1.0.0"
  url "git@intern.far.in.tum.de:Ubitrack/buildEnvironment.git", :using => UbitrackDownloadStrategy
  sha256 ""

  option :cxx11
  # option :libcxx

  depends_on "cmake"      => :build
  depends_on :java        => :optional
  depends_on "opencv"     => :build
  depends_on "boost"     => :build
  depends_on "tbb"     => :build
  depends_on "swig"     => :build
  depends_on "zmq"     => :build
  depends_on "glfw3"     => :build

  def arg_switch(opt)
    (build.with? opt) ? "ON" : "OFF"
  end

  def install
    ENV.cxx11 if build.cxx11?
    # -stdlib=libc++
    ENV.libcxx if build.cxx11?
    dylib = OS.mac? ? "dylib" : "so"

    args = std_cmake_args + %W[
      -DCMAKE_OSX_DEPLOYMENT_TARGET=
      -DPYTHON_INCLUDE_DIR=/usr/local/include/python2.7
      -DPYTHON_LIBRARY=/usr/local/Frameworks/Python.framework/Python
      -DFreeglut_INCLUDE_DIR=/System/Library/Frameworks/GLUT.framework/Headers
      -DFreeglut_glut_LIBRARY=/System/Library/Frameworks/GLUT.framework/GLUT
      -DENABLE_DTRACE=ON
      -DUT_ENABLE_DTRACE=ON
    ]
    args << "-DCOMPILE_WITH_CXX11="   + arg_switch("cxx11")
    args << "-DENABLE_BASICFACADE="   + arg_switch("cxx11")

    system "git", "submodule", "deinit", "-f", "modules/artdriver" 
    system "git", "submodule", "deinit", "-f", "modules/mswindows" 
    system "git", "submodule", "deinit", "-f", "modules/utcomponents" 
    system "git", "submodule", "deinit", "-f", "modules/utcore" 
    system "git", "submodule", "deinit", "-f", "modules/utdataflow" 
    system "git", "submodule", "deinit", "-f", "modules/utfacade" 
    system "git", "submodule", "deinit", "-f", "modules/utvision" 
    system "git", "submodule", "deinit", "-f", "modules/utvisioncomponents" 
    system "git", "submodule", "deinit", "-f", "modules/utvisualization" 
    system "rm", "-Rf", "modules/*"

    system "git", "clone", "-b", "multiple_eventqueues", "git@intern.far.in.tum.de:Ubitrack/utDataflow.git", "modules/utdataflow"
    system "git", "clone", "-b", "multiple_eventqueues", "git@intern.far.in.tum.de:Ubitrack/utFacade.git", "modules/utfacade"

    system "git", "clone", "git@intern.far.in.tum.de:UbitrackContrib/ARTDriver.git", "modules/art"
    system "git", "clone", "git@intern.far.in.tum.de:UbitrackContrib/FirewireCameraDriver.git", "modules/firewirecamera"
    system "git", "clone", "git@intern.far.in.tum.de:Ubitrack/utComponents.git", "modules/utcomponents"
    system "git", "clone", "git@intern.far.in.tum.de:Ubitrack/utCore.git", "modules/utcore"
    system "git", "clone", "git@intern.far.in.tum.de:UbitrackContrib/HapticCalibrationComponents.git", "modules/uthaptics"
    system "git", "clone", "git@intern.far.in.tum.de:Ubitrack/utVision.git", "modules/utvision"
    system "git", "clone", "git@intern.far.in.tum.de:Ubitrack/utVisionComponents.git", "modules/utvisioncomponents"
    system "git", "clone", "git@intern.far.in.tum.de:Ubitrack/utVisualization.git", "modules/utvisualization"
    system "git", "clone", "git@intern.far.in.tum.de:UbitrackContrib/ZMQ.git", "modules/utzmq"


    mkdir "macbuild" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    system "false"
  end
end