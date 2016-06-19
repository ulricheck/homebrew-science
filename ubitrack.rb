class UbitrackDownloadStrategy < GitDownloadStrategy
  def submodules?
    cached_location.join(".gitmodules-disabled").exist?
  end
end


class Ubitrack < Formula
  desc "The UbiTrack Framework from TUM/FAR"
  homepage "http://campar.in.tum.de"
  version "1.0.0"
  url "git@intern.far.in.tum.de:Ubitrack/buildEnvironment.git", :using => UbitrackDownloadStrategy, :branch => "release_13"
  sha256 ""

  option :cxx11

  depends_on "cmake"      => :build
  depends_on :java        => :optional
  depends_on "opencv3ut"     => :build
  depends_on "boost"     => :build
  depends_on "tbb"     => :build
  depends_on "swig"     => :build
  depends_on "zmq"     => :build
  depends_on "glfw3"     => :build

  # depends_on "python"    => :build

  def install
    ENV.cxx11 if build.cxx11?
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
    args << "-DCOMPILE_WITH_CXX11=ON"  if build.cxx11?
    args << "-DENABLE_BASICFACADE=ON"  if build.cxx11?

    system "git", "clone", "-b", "release_13", "git@intern.far.in.tum.de:Ubitrack/utDataflow.git", "modules/utdataflow"
    system "git", "clone", "-b", "release_13", "git@intern.far.in.tum.de:Ubitrack/utFacade.git", "modules/utfacade"

    system "git", "clone", "-b", "release_13", "git@intern.far.in.tum.de:UbitrackContrib/ARTDriver.git", "modules/art"
    system "git", "clone", "-b", "release_13", "git@intern.far.in.tum.de:UbitrackContrib/FirewireCameraDriver.git", "modules/firewirecamera"
    system "git", "clone", "-b", "release_13", "git@intern.far.in.tum.de:Ubitrack/utComponents.git", "modules/utcomponents"
    system "git", "clone", "-b", "release_13", "git@intern.far.in.tum.de:Ubitrack/utCore.git", "modules/utcore"
    system "git", "clone", "-b", "release_13", "git@intern.far.in.tum.de:UbitrackContrib/HapticCalibrationComponents.git", "modules/uthaptics"
    system "git", "clone", "-b", "release_13", "git@intern.far.in.tum.de:Ubitrack/utVision.git", "modules/utvision"
    system "git", "clone", "-b", "release_13", "git@intern.far.in.tum.de:Ubitrack/utVisionComponents.git", "modules/utvisioncomponents"
    system "git", "clone", "-b", "release_13", "git@intern.far.in.tum.de:Ubitrack/utVisualization.git", "modules/utvisualization"
    system "git", "clone", "-b", "release_13", "git@intern.far.in.tum.de:UbitrackContrib/ZMQ.git", "modules/utzmq"


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
