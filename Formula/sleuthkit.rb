class Sleuthkit < Formula
  desc "Forensic toolkit"
  homepage "https://www.sleuthkit.org/"
  url "https://github.com/sleuthkit/sleuthkit/releases/download/sleuthkit-4.11.0/sleuthkit-4.11.0.tar.gz"
  sha256 "8d6b0ed7f6f0612e7ba10b3a9713bc9e4ec85b5fb77af06a9fbe16d1c1d433ee"
  license all_of: ["IPL-1.0", "CPL-1.0", "GPL-2.0-or-later"]

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/sleuthkit[._-]v?(\d+(?:\.\d+)+)["' >]}i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_monterey: "58e7691787275b5ab4465f2f83608866a2a8351726b3d6823d6d47991e8e25a3"
    sha256 cellar: :any,                 arm64_big_sur:  "af763b17f8d5719e6b3707ee5f65c477afe98471bb82ba486922b46921d1d06e"
    sha256 cellar: :any,                 monterey:       "574e7dc3ed9f518b6677addcf5920e80c6148e322c36e74f9558bee937c4c36e"
    sha256 cellar: :any,                 big_sur:        "30758d782ad89676473e292682b9ec78dfef75e3ad974cde8154cc99e3f2386b"
    sha256 cellar: :any,                 catalina:       "3e0ffa38afd90e47d953c8462df5a20408151ca0da75f2c03da333302d3a797d"
    sha256 cellar: :any,                 mojave:         "6cc145c75c073678a80e07acdb0b7543917c39117b27ef6f7ed9f62fc0b533fd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "0ae9d2f33d4abb4a291767c8b71687e25ee414b0813423dc11e39a3e838b6038"
  end

  depends_on "ant" => :build
  depends_on "afflib"
  depends_on "libewf"
  depends_on "libpq"
  depends_on "openjdk"

  uses_from_macos "sqlite"

  conflicts_with "ffind", because: "both install a `ffind` executable"

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff"
    sha256 "35acd6aebc19843f1a2b3a63e880baceb0f5278ab1ace661e57a502d9d78c93c"
  end

  def install
    ENV["JAVA_HOME"] = Formula["openjdk"].opt_prefix
    ENV["ANT_FOUND"] = Formula["ant"].opt_bin/"ant"
    ENV.append_to_cflags "-DNDEBUG"

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"

    cd "bindings/java" do
      system "ant"

      inreplace ["Makefile", "jni/Makefile"], Superenv.shims_path/"ld", "ld" if OS.linux?
    end
    prefix.install "bindings"
  end

  test do
    system "#{bin}/tsk_loaddb", "-V"
  end
end
